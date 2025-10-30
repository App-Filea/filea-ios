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
        var showValidationError = false
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle?

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

        // Validation computed properties
        var hasSourceSelected: Bool {
            capturedImage != nil || selectedFileURL != nil
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case showCamera
        case hideCamera
        case showFilePicker
        case hideFilePicker
        case imageCapture(UIImage?)
        case fileSelected(URL?)
        case removeSource
        case saveDocument
        case documentSaved
        case cancelCreation
        case setShowValidationError(Bool)
    }

    @Dependency(\.documentRepository) var documentRepository
    @Dependency(\.vehicleRepository) var vehicleRepository
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                // Clear validation error when user types
                if state.showValidationError {
                    state.showValidationError = false
                }
                return .none

            case .showCamera:
                state.showCamera = true
                return .none

            case .hideCamera:
                state.showCamera = false
                return .none

            case .showFilePicker:
                state.showFilePicker = true
                return .none

            case .hideFilePicker:
                state.showFilePicker = false
                return .none

            case .imageCapture(let image):
                state.showCamera = false
                if let image = image {
                    // Clear file selection if present
                    state.selectedFileURL = nil
                    state.selectedFileName = nil
                    state.capturedImage = image
                    state.documentSource = .camera
                }
                return .none

            case .fileSelected(let url):
                state.showFilePicker = false
                if let url = url {
                    // Clear image if present
                    state.capturedImage = nil
                    state.selectedFileURL = url
                    state.selectedFileName = url.lastPathComponent
                    state.documentSource = .file
                }
                return .none

            case .removeSource:
                state.capturedImage = nil
                state.selectedFileURL = nil
                state.selectedFileName = nil
                state.documentSource = .none
                return .none

            case .saveDocument:
                state.isLoading = true

                let amount = Double(state.documentAmount.replacingOccurrences(of: ",", with: "."))

                switch state.documentSource {
                case .camera:
                    guard let image = state.capturedImage else {
                        state.isLoading = false
                        return .none
                    }

                    return .run { [vehicleId = state.vehicleId, name = state.documentName, date = state.documentDate, mileage = state.documentMileage, type = state.documentType] send in
                        do {
                            let metadata = DocumentMetadata(
                                name: name,
                                date: date,
                                mileage: mileage,
                                type: type,
                                amount: amount
                            )
                            _ = try await documentRepository.save(image: image, for: vehicleId, metadata: metadata)
                            await send(.documentSaved)
                        } catch {
                            print("❌ [AddDocumentStore] Erreur lors de la sauvegarde de l'image: \(error.localizedDescription)")
                            await send(.documentSaved)
                        }
                    }

                case .file:
                    guard let fileURL = state.selectedFileURL else {
                        state.isLoading = false
                        return .none
                    }

                    return .run { [vehicleId = state.vehicleId, name = state.documentName, date = state.documentDate, mileage = state.documentMileage, type = state.documentType] send in
                        do {
                            let metadata = DocumentMetadata(
                                name: name,
                                date: date,
                                mileage: mileage,
                                type: type,
                                amount: amount
                            )
                            _ = try await documentRepository.save(fileURL: fileURL, for: vehicleId, metadata: metadata)
                            await send(.documentSaved)
                        } catch {
                            print("❌ [AddDocumentStore] Erreur lors de la sauvegarde du fichier: \(error.localizedDescription)")
                            await send(.documentSaved)
                        }
                    }

                case .none:
                    state.isLoading = false
                    return .none
                }

            case .documentSaved:
                state.isLoading = false
                // Recharger le véhicule pour mettre à jour la liste des documents
                return .run { [vehicleId = state.vehicleId, vehicles = state.$vehicles, selectedVehicle = state.$selectedVehicle] send in
                    do {
                        if let updatedVehicle = try await vehicleRepository.getVehicle(vehicleId) {
                            await vehicles.withLock { vehicles in
                                if let index = vehicles.firstIndex(where: { $0.id == vehicleId }) {
                                    vehicles[index] = updatedVehicle
                                }
                            }

                            // Also update selectedVehicle if it's the same vehicle
                            await selectedVehicle.withLock { selected in
                                if selected?.id == vehicleId {
                                    selected = updatedVehicle
                                }
                            }
                        }
                    } catch {
                        print("❌ [AddDocumentStore] Erreur lors du rechargement du véhicule: \(error.localizedDescription)")
                    }
                    await dismiss()
                }

            case .cancelCreation:
                return .run { _ in
                    await dismiss()
                }

            case .setShowValidationError(let show):
                state.showValidationError = show
                return .none
            }
        }
    }
}

extension UIImage: @retroactive @unchecked Sendable {}
