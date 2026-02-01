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

        static func initialState(vehicleId: String, documentType: DocumentType = .maintenance, viewState: ViewState = .modeChoice) -> Self {
            .init(vehicleId: vehicleId, viewState: viewState, documentType: documentType)
        }

        // Document metadata
        var documentName: String = ""
        var documentDate: Date = Date()
        var documentMileage: String = ""
        var documentType: DocumentType = .maintenance
        var documentAmount: String = ""
        var documentExpirationDate: Date = Calendar.current.date(byAdding: .year, value: 2, to: Date()) ?? Date()
        var preSelectedType: DocumentType? = nil  // Set when opened from Quick Action

        // Stored metadata for back navigation from form
        var storedMetadata: ExtractedDocumentMetadata?

        enum ViewState: Equatable {
            case modeChoice
            case extractingMetadata                              // En cours d'extraction
            case extractionSuccess(ExtractedDocumentMetadata)    // Extraction réussie
            case extractionError(String)                         // Extraction échouée
            case metadataForm
        }

        // Validation computed properties
        var hasSourceSelected: Bool {
            selectedFileURL != nil
        }

        var isTypePickerDisabled: Bool {
            preSelectedType != nil
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

        // OCR Extraction actions
        case startMetadataExtraction
        case metadataExtracted(ExtractedDocumentMetadata)
        case metadataExtractionFailed(String)
        case confirmDetectedType
        case skipMetadataExtraction

        enum ActionView: Equatable {
            case openCameraViewButtonTapped
            case cancelCameraViewButtonTapped
            case openPhotoPickerButtonTapped
            case cancelPhotoPickerButtonTapped
            case openFileManagerButtonTapped
            case cancelFileManagerButtonTapped
            case documentScanned([UIImage])
            case backFromMetadataFormButtonTapped
            case backFromExtractionButtonTapped
            case closeButtonTapped
            case saveButtonTapped
            case expirationDateChanged(Date)
        }
    }

    @Dependency(\.documentRepository) var documentRepository
    @Dependency(\.vehicleGRDBClient) var vehicleRepository
    @Dependency(\.ocrService) var ocrService
    @Dependency(\.metadataExtractor) var metadataExtractor
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
                    // Retour vers extractionSuccess si on a des metadata stockées, sinon modeChoice
                    if let metadata = state.storedMetadata {
                        state.viewState = .extractionSuccess(metadata)
                    } else {
                        state.viewState = .modeChoice
                    }
                    return .none
                case .backFromExtractionButtonTapped:
                    state.viewState = .modeChoice
                    state.storedMetadata = nil
                    return .none
                case .closeButtonTapped:
                    return .send(.cancelCreation)
                case .saveButtonTapped:
                    state.validationErrors = validateFields(state)
                    guard state.validationErrors.isEmpty else {
                        return .none
                    }
                    return .send(.saveDocument)

                case .expirationDateChanged(let date):
                    state.documentExpirationDate = date
                    return .none
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
                    state.viewState = .extractingMetadata
                    // Start extraction immediately
                    return .send(.startMetadataExtraction)
                }
                return .none

            case .startMetadataExtraction:
                guard let fileURL = state.selectedFileURL else {
                    return .send(.metadataExtractionFailed("Aucun fichier sélectionné"))
                }

                return .run { send in
                    print("🔍 [AddDocumentStore] Starting OCR extraction")
                    print("   └─ File: \(fileURL.lastPathComponent)")

                    do {
                        // Step 1: Get image from file
                        let image: UIImage

                        if fileURL.pathExtension.lowercased() == "pdf" {
                            // Convert PDF first page to image
                            guard let pdfDocument = PDFDocument(url: fileURL),
                                  let pdfImage = pdfDocument.imageOfFirstPage() else {
                                throw NSError(domain: "OCR", code: 1, userInfo: [NSLocalizedDescriptionKey: "Impossible de lire le PDF"])
                            }
                            image = pdfImage
                        } else {
                            // Load image directly
                            guard let imageData = try? Data(contentsOf: fileURL),
                                  let loadedImage = UIImage(data: imageData) else {
                                throw NSError(domain: "OCR", code: 2, userInfo: [NSLocalizedDescriptionKey: "Impossible de charger l'image"])
                            }
                            image = loadedImage
                        }

                        // Step 2: Perform OCR
                        let ocrText = try await ocrService.recognizeTextStatic(image)
                        print("")
                        print("╔══════════════════════════════════════════════════════════════╗")
                        print("║           📝 TEXTE OCR EXTRAIT                               ║")
                        print("╠══════════════════════════════════════════════════════════════╣")
                        let lines = ocrText.components(separatedBy: "\n").prefix(20)
                        for line in lines {
                            let truncated = String(line.prefix(58))
                            print("║ \(truncated.padding(toLength: 60, withPad: " ", startingAt: 0))║")
                        }
                        if ocrText.components(separatedBy: "\n").count > 20 {
                            print("║ ... (\(ocrText.components(separatedBy: "\n").count - 20) lignes supplémentaires)                            ║")
                        }
                        print("╚══════════════════════════════════════════════════════════════╝")
                        print("")

                        // Step 3: Extract metadata from OCR text
                        let metadata = await metadataExtractor.extract(ocrText)

                        await send(.metadataExtracted(metadata))

                    } catch {
                        print("❌ [AddDocumentStore] OCR extraction failed: \(error.localizedDescription)")
                        await send(.metadataExtractionFailed(error.localizedDescription))
                    }
                }

            case .metadataExtracted(let metadata):
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"

                print("")
                print("╔══════════════════════════════════════════════════════════════╗")
                print("║           📄 MÉTADONNÉES EXTRAITES                           ║")
                print("╠══════════════════════════════════════════════════════════════╣")
                print("║ Type détecté    : \(metadata.detectedType.displayName.padding(toLength: 42, withPad: " ", startingAt: 0))║")
                print("║ Score           : \(String(metadata.typeScore).padding(toLength: 42, withPad: " ", startingAt: 0))║")
                print("║ Confiance       : \(metadata.typeConfidence.displayName.padding(toLength: 42, withPad: " ", startingAt: 0))║")
                print("╠══════════════════════════════════════════════════════════════╣")
                if let name = metadata.suggestedName {
                    print("║ Nom suggéré     : \(name.padding(toLength: 42, withPad: " ", startingAt: 0))║")
                }
                if let date = metadata.date {
                    print("║ Date            : \(dateFormatter.string(from: date).padding(toLength: 42, withPad: " ", startingAt: 0))║")
                }
                if let amount = metadata.amount {
                    let amountStr = String(format: "%.2f €", amount)
                    print("║ Montant         : \(amountStr.padding(toLength: 42, withPad: " ", startingAt: 0))║")
                }
                if let mileage = metadata.mileage {
                    let mileageStr = "\(mileage) km"
                    print("║ Kilométrage     : \(mileageStr.padding(toLength: 42, withPad: " ", startingAt: 0))║")
                }
                if let expiration = metadata.expirationDate {
                    print("║ Expiration      : \(dateFormatter.string(from: expiration).padding(toLength: 42, withPad: " ", startingAt: 0))║")
                }
                print("╚══════════════════════════════════════════════════════════════╝")
                print("")

                // Only consider extraction successful if confidence is high
                guard metadata.typeConfidence == .high else {
                    print("⚠️ [AddDocumentStore] Confidence too low, treating as extraction failure")
                    state.viewState = .extractionError("Type de document non reconnu")
                    return .none
                }

                state.viewState = .extractionSuccess(metadata)
                state.storedMetadata = metadata
                return .none

            case .metadataExtractionFailed(let error):
                state.viewState = .extractionError(error)
                return .none

            case .confirmDetectedType:
                // Extract metadata from ViewState
                guard case .extractionSuccess(let metadata) = state.viewState else {
                    // No metadata, go to form with default type
                    state.viewState = .metadataForm
                    return .none
                }

                // Apply extracted metadata to form fields
                state.documentType = metadata.detectedType

                if let suggestedName = metadata.suggestedName {
                    state.documentName = suggestedName
                }
                if let date = metadata.date {
                    state.documentDate = date
                }
                if let amount = metadata.amount {
                    state.documentAmount = String(format: "%.2f", amount)
                        .replacingOccurrences(of: ".", with: ",")
                }
                if let mileage = metadata.mileage {
                    state.documentMileage = mileage
                }
                if let expirationDate = metadata.expirationDate {
                    state.documentExpirationDate = expirationDate
                }

                state.viewState = .metadataForm
                return .none

            case .skipMetadataExtraction:
                // Go to form with empty fields
                state.viewState = .metadataForm
                return .none

            case .removeSource:
                state.selectedFileURL = nil
                state.selectedFileName = nil
                return .none

            case .saveDocument:
                let amount = Double(state.documentAmount.replacingOccurrences(of: ",", with: "."))
                let expirationDate: Date? = state.documentType == .technicalInspection ? state.documentExpirationDate : nil

                guard let fileURL = state.selectedFileURL else {
                    return .none
                }

                return .run { [vehicleId = state.vehicleId, name = state.documentName, date = state.documentDate, mileage = state.documentMileage, type = state.documentType, expirationDate] send in
                    do {
                        let metadata = DocumentMetadata(
                            name: name,
                            date: date,
                            mileage: mileage,
                            type: type,
                            amount: amount,
                            expirationDate: expirationDate
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

            case .binding:
                return .none
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
