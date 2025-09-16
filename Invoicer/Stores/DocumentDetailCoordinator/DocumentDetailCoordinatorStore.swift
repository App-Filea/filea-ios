//
//  DocumentDetailCoordinatorStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 14/09/2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct DocumentDetailCoordinatorStore {
    @ObservableState
    struct State: Equatable {
        let vehicleId: UUID
        let documentId: UUID
        var documentType: DocumentType = .unknown
        var photoDocumentDetail: PhotoDocumentDetailStore.State?
        var fileDocumentDetail: FileDocumentDetailStore.State?
        var isLoading = false
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        
        enum DocumentType: Equatable {
            case photo
            case file
            case unknown
        }
    }
    
    enum Action: Equatable {
        case determineDocumentType
        case documentTypeDetected(State.DocumentType)
        case photoDocumentDetail(PhotoDocumentDetailStore.Action)
        case fileDocumentDetail(FileDocumentDetailStore.Action)
        case showEditDocument
        case editDocumentLoaded(Document)
        case requestDeletion(UUID)
        case documentDeleted
        case goBack
    }
    
    @Dependency(\.fileStorageService) var fileStorageService
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .determineDocumentType:
                print("🔍 [DocumentDetailCoordinator] Détermination du type de document: \(state.documentId)")
                return .run { [vehicleId = state.vehicleId, documentId = state.documentId] send in
                    let vehicles = await fileStorageService.loadVehicles()
                    if let vehicle = vehicles.first(where: { $0.id == vehicleId }),
                       let document = vehicle.documents.first(where: { $0.id == documentId }) {
                        
                        let documentType = await determineDocumentType(from: document.fileURL)
                        await send(.documentTypeDetected(documentType))
                    } else {
                        print("❌ [DocumentDetailCoordinator] Document non trouvé")
                        await send(.documentTypeDetected(.unknown))
                    }
                }
                
            case .documentTypeDetected(let documentType):
                print("✅ [DocumentDetailCoordinator] Type de document détecté: \(documentType)")
                state.documentType = documentType
                
                // Initialize appropriate store based on document type
                switch documentType {
                case .photo:
                    state.photoDocumentDetail = PhotoDocumentDetailStore.State(
                        vehicleId: state.vehicleId,
                        documentId: state.documentId
                    )
                    return .run { send in
                        await send(.photoDocumentDetail(.loadDocument))
                    }
                case .file:
                    state.fileDocumentDetail = FileDocumentDetailStore.State(
                        vehicleId: state.vehicleId,
                        documentId: state.documentId
                    )
                    return .run { send in
                        await send(.fileDocumentDetail(.loadDocument))
                    }
                case .unknown:
                    return .none
                }
                
            case .photoDocumentDetail(.requestDeletion):
                print("📤 [DocumentDetailCoordinator] Photo demande fermeture puis suppression")
                return .run { [documentId = state.documentId] send in
                    await send(.requestDeletion(documentId))
                }
                
            case .photoDocumentDetail(.documentDeleted):
                print("🗑️ [DocumentDetailCoordinator] Photo supprimée par le store enfant (legacy)")
                return .run { send in
                    await send(.documentDeleted)
                }
                
            case .photoDocumentDetail(.showEditDocument):
                return .run { send in
                    await send(.showEditDocument)
                }
                
            case .photoDocumentDetail(.goBack):
                print("🔙 [DocumentDetailCoordinator] Retour depuis photo store")
                return .run { send in
                    await send(.goBack)
                }
                
            case .fileDocumentDetail(.requestDeletion):
                print("📤 [DocumentDetailCoordinator] Fichier demande fermeture puis suppression")
                return .run { [documentId = state.documentId] send in
                    await send(.requestDeletion(documentId))
                }
                
            case .fileDocumentDetail(.documentDeleted):
                print("🗑️ [DocumentDetailCoordinator] Fichier supprimé par le store enfant (legacy)")
                return .run { send in
                    await send(.documentDeleted)
                }
                
            case .fileDocumentDetail(.showEditDocument):
                return .run { send in
                    await send(.showEditDocument)
                }
                
            case .fileDocumentDetail(.goBack):
                print("🔙 [DocumentDetailCoordinator] Retour depuis file store")
                return .run { send in
                    await send(.goBack)
                }
                
            case .photoDocumentDetail:
                return .none
                
            case .fileDocumentDetail:
                return .none
                
            case .requestDeletion(let documentId):
                print("🗑️ [DocumentDetailCoordinator] Début de la suppression du document: \(documentId)")
                return .run { [vehicleId = state.vehicleId] send in
                    let vehicles = await fileStorageService.loadVehicles()
                    if let vehicle = vehicles.first(where: { $0.id == vehicleId }),
                       let document = vehicle.documents.first(where: { $0.id == documentId }) {
                        await fileStorageService.deleteDocument(document, for: vehicleId)
                        await send(.documentDeleted)
                    }
                }
                
            case .documentDeleted:
                print("🗑️ [DocumentDetailCoordinator] Document supprimé, mise à jour réactive")
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
                
            case .showEditDocument:
                state.isLoading = true
                return .run { [vehicleId = state.vehicleId, documentId = state.documentId] send in
                    let vehicles = await fileStorageService.loadVehicles()
                    if let vehicle = vehicles.first(where: { $0.id == vehicleId }),
                       let document = vehicle.documents.first(where: { $0.id == documentId }) {
                        await send(.editDocumentLoaded(document))
                    }
                }
                
            case .editDocumentLoaded(let document):
                state.isLoading = false
                return .none
                
            case .goBack:
                print("🔙 [DocumentDetailCoordinator] Retour à la vue précédente")
                return .run { _ in
                    await dismiss()
                }
            }
        }
        .ifLet(\.photoDocumentDetail, action: \.photoDocumentDetail) {
            PhotoDocumentDetailStore()
        }
        .ifLet(\.fileDocumentDetail, action: \.fileDocumentDetail) {
            FileDocumentDetailStore()
        }
    }
    
    private func determineDocumentType(from fileURL: String) async -> State.DocumentType {
        print("🕵️ [DocumentDetailCoordinator] Analyse du fichier: \(fileURL)")
        
        let url = URL(fileURLWithPath: fileURL)
        let pathExtension = url.pathExtension.lowercased()
        
        // Image extensions
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "heic", "heif"]
        if imageExtensions.contains(pathExtension) {
            print("📸 [DocumentDetailCoordinator] Détecté comme photo (extension: \(pathExtension))")
            return .photo
        }
        
        // Try to determine by content if extension is ambiguous or missing
        if pathExtension.isEmpty {
            // Check file content
            do {
                let data = try Data(contentsOf: url)
                if data.count > 8 {
                    // Check for image magic numbers
                    let header = data.prefix(8)
                    if isImageData(header) {
                        print("📸 [DocumentDetailCoordinator] Détecté comme photo (signature de fichier)")
                        return .photo
                    }
                }
            } catch {
                print("⚠️ [DocumentDetailCoordinator] Erreur lors de la lecture du fichier: \(error)")
            }
        }
        
        // Default to file for non-image types
        print("📄 [DocumentDetailCoordinator] Détecté comme fichier document")
        return .file
    }
    
    private func isImageData(_ data: Data) -> Bool {
        // Check for common image file signatures
        let bytes = [UInt8](data)
        
        // JPEG: FF D8
        if bytes.count >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8 {
            return true
        }
        
        // PNG: 89 50 4E 47
        if bytes.count >= 4 && bytes[0] == 0x89 && bytes[1] == 0x50 && 
           bytes[2] == 0x4E && bytes[3] == 0x47 {
            return true
        }
        
        // GIF: 47 49 46
        if bytes.count >= 3 && bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 {
            return true
        }
        
        // BMP: 42 4D
        if bytes.count >= 2 && bytes[0] == 0x42 && bytes[1] == 0x4D {
            return true
        }
        
        // TIFF: 49 49 2A 00 or 4D 4D 00 2A
        if bytes.count >= 4 {
            if (bytes[0] == 0x49 && bytes[1] == 0x49 && bytes[2] == 0x2A && bytes[3] == 0x00) ||
               (bytes[0] == 0x4D && bytes[1] == 0x4D && bytes[2] == 0x00 && bytes[3] == 0x2A) {
                return true
            }
        }
        
        return false
    }
}