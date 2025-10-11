//
//  AddDocumentStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct AddDocumentStore {
    @ObservableState
    struct State: Equatable {
        let vehicleId: UUID
        var capturedImage: UIImage?
        var isLoading = false
        var showCamera = false
        var showFilePicker = false
        var selectedFileURL: URL?
        var selectedFileName: String?
        var documentSource: DocumentSource = .none
        var currentStep: Step = .selectFile
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        
        // Document metadata
        var documentName: String = ""
        var documentDate: Date = Date()
        var documentMileage: String = ""
        var documentType: DocumentType = .entretien
        var documentAmount: String = ""
        
        enum DocumentSource: Equatable {
            case none
            case camera
            case file
        }
        
        enum Step: Equatable {
            case selectFile
            case preview
            case metadata
        }

        // Validation computed properties
        var canProceedFromPreview: Bool {
            capturedImage != nil || selectedFileURL != nil
        }

        var canSaveDocument: Bool {
            !documentName.isEmpty &&
            !documentMileage.isEmpty &&
            !documentAmount.isEmpty &&
            canProceedFromPreview
        }
    }
    
    enum Action: Equatable {
        case showCamera
        case hideCamera
        case showFilePicker
        case hideFilePicker
        case imageCapture(UIImage?)
        case fileSelected(URL?)
        case nextStep
        case previousStep
        case updateDocumentName(String)
        case updateDocumentDate(Date)
        case updateDocumentMileage(String)
        case updateDocumentType(DocumentType)
        case updateDocumentAmount(String)
        case saveDocument
        case documentSaved
        case goBack
    }
    
    @Dependency(\.fileStorageService) var fileStorageService
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showCamera:
                state.showCamera = true
                state.documentSource = .camera
                // Réinitialiser les données existantes
                state.capturedImage = nil
                return .none
                
            case .hideCamera:
                state.showCamera = false
                return .none
                
            case .showFilePicker:
                state.showFilePicker = true
                state.documentSource = .file
                // Réinitialiser les données existantes
                state.selectedFileURL = nil
                state.selectedFileName = nil
                return .none
                
            case .hideFilePicker:
                state.showFilePicker = false
                return .none
                
            case .imageCapture(let image):
                state.capturedImage = image
                state.showCamera = false
                if image != nil {
                    state.currentStep = .preview
                } else {
                    // Si aucune image n'a été capturée, revenir à selectFile
                    state.currentStep = .selectFile
                    state.documentSource = .none
                }
                return .none

            case .fileSelected(let url):
                state.selectedFileURL = url
                state.selectedFileName = url?.lastPathComponent
                state.showFilePicker = false
                if url != nil {
                    state.currentStep = .preview
                } else {
                    // Si aucun fichier n'a été sélectionné, revenir à selectFile
                    state.currentStep = .selectFile
                    state.documentSource = .none
                }
                return .none
                
            case .nextStep:
                switch state.currentStep {
                case .selectFile:
                    if state.capturedImage != nil || state.selectedFileURL != nil {
                        state.currentStep = .preview
                    }
                case .preview:
                    state.currentStep = .metadata
                case .metadata:
                    return .none
                }
                return .none
                
            case .previousStep:
                switch state.currentStep {
                case .selectFile:
                    return .none
                case .preview:
                    state.currentStep = .selectFile
                    // Keep captured data for non-destructive navigation
                case .metadata:
                    state.currentStep = .preview
                    // Keep metadata for non-destructive navigation
                }
                return .none
                
            case .updateDocumentName(let name):
                state.documentName = name
                return .none
                
            case .updateDocumentDate(let date):
                state.documentDate = date
                return .none
                
            case .updateDocumentMileage(let mileage):
                state.documentMileage = mileage
                return .none
                
            case .updateDocumentType(let type):
                state.documentType = type
                return .none

            case .updateDocumentAmount(let amount):
                state.documentAmount = amount
                return .none

            case .saveDocument:
                guard !state.documentName.isEmpty else { return .none }
                
                state.isLoading = true
                
                switch state.documentSource {
                case .camera:
                    guard let image = state.capturedImage else {
                        state.isLoading = false
                        return .none
                    }

                    let amount = Double(state.documentAmount.replacingOccurrences(of: ",", with: "."))

                    return .run { [vehicleId = state.vehicleId, name = state.documentName, date = state.documentDate, mileage = state.documentMileage, type = state.documentType] send in
                        await fileStorageService.saveDocument(
                            image: image,
                            for: vehicleId,
                            name: name,
                            date: date,
                            mileage: mileage,
                            type: type,
                            amount: amount
                        )
                        await send(.documentSaved)
                    }
                    
                case .file:
                    guard let fileURL = state.selectedFileURL else {
                        state.isLoading = false
                        return .none
                    }

                    let amount = Double(state.documentAmount.replacingOccurrences(of: ",", with: "."))

                    return .run { [vehicleId = state.vehicleId, name = state.documentName, date = state.documentDate, mileage = state.documentMileage, type = state.documentType] send in
                        await fileStorageService.saveDocument(
                            fileURL: fileURL,
                            for: vehicleId,
                            name: name,
                            date: date,
                            mileage: mileage,
                            type: type,
                            amount: amount
                        )
                        await send(.documentSaved)
                    }
                    
                case .none:
                    state.isLoading = false
                    return .none
                }
                
            case .documentSaved:
                state.isLoading = false
                // Recharger le véhicule pour mettre à jour la liste des documents
                return .run { [vehicleId = state.vehicleId, vehicles = state.$vehicles] send in
                    let updatedVehicles = await fileStorageService.loadVehicles()
                    if let updatedVehicle = updatedVehicles.first(where: { $0.id == vehicleId }) {
                        await vehicles.withLock { vehicles in
                            if let index = vehicles.firstIndex(where: { $0.id == vehicleId }) {
                                vehicles[index] = updatedVehicle
                            }
                        }
                    }
                    await dismiss()
                }
                
            case .goBack:
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}

extension UIImage: @retroactive @unchecked Sendable {}
