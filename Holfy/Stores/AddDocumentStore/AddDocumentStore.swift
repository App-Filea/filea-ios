//
//  AddDocumentStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI
import PhotosUI
import PDFKit

struct DocumentFieldsValidationErrors: OptionSet, Sendable, Equatable {
    let rawValue: Int

    static let nameEmpty = DocumentFieldsValidationErrors(rawValue: 1 << 0)
}

@Reducer
struct AddDocumentStore {
    @ObservableState
    struct State: Equatable {
        let vehicleId: String
        var viewState: ViewState
        var showDocumentScanView = false
        var showPhotoPickerView = false
        var photoPickerItems: [PhotosPickerItem] = []
        var showFileManagerView = false
        var selectedFileURL: URL?
        var selectedFileName: String?
        var validationErrors: DocumentFieldsValidationErrors = []

        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        
        static func initialState(vehicleId: String, viewState: ViewState = .modeChoice) -> Self {
            .init(vehicleId: vehicleId, viewState: viewState)
        }

        // Document metadata
        var documentName: String = ""
        var documentDate: Date = Date()
        var documentMileage: String = ""
        var documentType: DocumentType = .maintenance
        var documentAmount: String = ""

        enum ViewState: Equatable {
            case modeChoice
            case metadataForm
        }

        // Validation computed properties
        var hasSourceSelected: Bool {
            selectedFileURL != nil
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case view(ActionView)
        case openCameraScan
        case openPhotoPicker
        case openFileManager
        case filePickedFromManager(URL)
        case fileSelected(URL?)
        case removeSource
        case saveDocument
        case documentSaved
        case cancelCreation
        case transformToPdf([UIImage])

        enum ActionView: Equatable {
            case openCameraViewButtonTapped
            case cancelCameraViewButtonTapped
            case openPhotoPickerButtonTapped
            case cancelPhotoPickerButtonTapped
            case openFileManagerButtonTapped
            case cancelFileManagerButtonTapped
            case documentScanned([UIImage])
            case backFromMetadataFormButtonTapped
            case closeButtonTapped
            case saveButtonTapped
        }
    }

    @Dependency(\.documentRepository) var documentRepository
    @Dependency(\.vehicleGRDBClient) var vehicleRepository
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.photoPickerItems) { oldValue, newValue in
                Reduce { state, action in
                    guard !newValue.isEmpty else { return .none }

                    let items = newValue
                    return .run { send in
                        var images: [UIImage] = []

                        for item in items {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                images.append(image)
                            }
                        }

                        guard !images.isEmpty else { return }
                        await send(.transformToPdf(images))
                    }
                }
            }

        Reduce { state, action in
            switch action {
            case .view(let actionView):
                switch actionView {
                case .openCameraViewButtonTapped:
                    return .send(.openCameraScan)
                case .cancelCameraViewButtonTapped:
                    state.showDocumentScanView = false
                    return .none
                case .openPhotoPickerButtonTapped:
                    return .send(.openPhotoPicker)
                case .cancelPhotoPickerButtonTapped:
                    state.showPhotoPickerView = false
                    return .none
                case .openFileManagerButtonTapped:
                    return .send(.openFileManager)
                case .cancelFileManagerButtonTapped:
                    state.showFileManagerView = false
                    return .none
                case .documentScanned(let images):
                    return .send(.transformToPdf(images))
                case .backFromMetadataFormButtonTapped:
                    state.viewState = .modeChoice
                    return .none
                case .closeButtonTapped:
                    return .send(.cancelCreation)
                case .saveButtonTapped:
                    state.validationErrors = validateFields(state)
                    guard state.validationErrors.isEmpty else {
                        return .none
                    }
                    return .send(.saveDocument)
                }

            case .openCameraScan:
                state.showDocumentScanView = true
                return .none

            case .openPhotoPicker:
                state.showPhotoPickerView = true
                return .none

            case .openFileManager:
                state.showFileManagerView = true
                return .none

            case .filePickedFromManager(let url):
                // Check if it's an image file that needs to be converted to PDF
                let imageExtensions = ["png", "jpg", "jpeg", "heic", "heif", "gif", "bmp", "tiff"]
                let fileExtension = url.pathExtension.lowercased()

                if imageExtensions.contains(fileExtension) {
                    // Convert image to PDF
                    return .run { send in
                        if let imageData = try? Data(contentsOf: url),
                           let image = UIImage(data: imageData) {
                            await send(.transformToPdf([image]))
                        }
                    }
                } else {
                    // It's already a PDF - use directly
                    return .send(.fileSelected(url))
                }

            case .fileSelected(let url):
                state.showFileManagerView = false
                state.showDocumentScanView = false
                state.showPhotoPickerView = false
                if let url = url {
                    state.selectedFileURL = url
                    state.selectedFileName = url.lastPathComponent
                    state.viewState = .metadataForm
                }
                return .none

            case .removeSource:
                state.selectedFileURL = nil
                state.selectedFileName = nil
                return .none

            case .saveDocument:
                let amount = Double(state.documentAmount.replacingOccurrences(of: ",", with: "."))

                guard let fileURL = state.selectedFileURL else {
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

            case .documentSaved:
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
                                if selected.id == vehicleId {
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

            case .transformToPdf(let images):
                guard !images.isEmpty else { return .none }

                return .run { send in
                    let pdfURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString.lowercased())
                        .appendingPathExtension("pdf")

                    // Create PDF from images
                    let pdfDocument = PDFDocument()
                    for (index, image) in images.enumerated() {
                        if let pdfPage = PDFPage(image: image) {
                            pdfDocument.insert(pdfPage, at: index)
                        }
                    }

                    // Write PDF to temp file
                    pdfDocument.write(to: pdfURL)

                    await send(.fileSelected(pdfURL))
                }
                
            default: return .none
            }
        }
    }
    
    private func validateFields(_ state: State) -> DocumentFieldsValidationErrors {
        var errors: DocumentFieldsValidationErrors = []

        if state.documentName.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.insert(.nameEmpty)
        }

        return errors
    }
}

extension UIImage: @retroactive @unchecked Sendable {}
