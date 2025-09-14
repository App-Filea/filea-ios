//
//  PhotoDocumentDetailStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 14/09/2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct PhotoDocumentDetailStore {
    @ObservableState
    struct State: Equatable {
        let vehicleId: UUID
        let documentId: UUID
        var document: Document?
        var image: UIImage?
        var isLoading = false
        var showCamera = false
    }
    
    enum Action: Equatable {
        case loadDocument
        case documentLoaded(Document?)
        case loadImage
        case imageLoaded(UIImage?)
        case showCamera
        case hideCamera
        case imageCapture(UIImage?)
        case photoReplaced
        case deleteDocument
        case requestDeletion
        case documentDeleted
        case goBack
    }
    
    @Dependency(\.fileStorageService) var fileStorageService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadDocument:
                print("📖 [PhotoDocumentDetailStore] Chargement du document photo: \(state.documentId)")
                return .run { [vehicleId = state.vehicleId, documentId = state.documentId] send in
                    let vehicles = await fileStorageService.loadVehicles()
                    if let vehicle = vehicles.first(where: { $0.id == vehicleId }),
                       let document = vehicle.documents.first(where: { $0.id == documentId }) {
                        print("✅ [PhotoDocumentDetailStore] Document photo trouvé: \(document.fileURL)")
                        await send(.documentLoaded(document))
                    } else {
                        print("❌ [PhotoDocumentDetailStore] Document photo non trouvé avec ID: \(documentId)")
                        await send(.documentLoaded(nil))
                    }
                }
                
            case .documentLoaded(let document):
                state.document = document
                if let doc = document {
                    print("📄 [PhotoDocumentDetailStore] Document photo chargé, début du chargement de l'image")
                    return .run { send in
                        await send(.loadImage)
                    }
                } else {
                    print("⚠️ [PhotoDocumentDetailStore] Aucun document photo chargé")
                }
                return .none
                
            case .loadImage:
                guard let document = state.document else {
                    print("❌ [PhotoDocumentDetailStore] Impossible de charger l'image - aucun document")
                    return .none
                }
                print("🔄 [PhotoDocumentDetailStore] Début du chargement de l'image: \(document.fileURL)")
                state.isLoading = true
                return .run { [fileURL = document.fileURL] send in
                    let image = await loadImageFromFile(fileURL)
                    await send(.imageLoaded(image))
                }
                
            case .imageLoaded(let image):
                if image != nil {
                    print("✅ [PhotoDocumentDetailStore] Image chargée avec succès")
                } else {
                    print("❌ [PhotoDocumentDetailStore] Échec du chargement de l'image")
                }
                state.image = image
                state.isLoading = false
                return .none
                
            case .showCamera:
                print("📷 [PhotoDocumentDetailStore] Ouverture de la caméra")
                state.showCamera = true
                return .none
                
            case .hideCamera:
                print("🚫 [PhotoDocumentDetailStore] Fermeture de la caméra")
                state.showCamera = false
                return .none
                
            case .imageCapture(let image):
                if let capturedImage = image {
                    print("✅ [PhotoDocumentDetailStore] Photo acceptée, remplacement en cours...")
                    print("🔍 [PhotoDocumentDetailStore] Taille de la nouvelle image: \(capturedImage.size)")
                    
                    state.isLoading = true
                    state.showCamera = false
                    
                    return .run { [vehicleId = state.vehicleId, documentId = state.documentId] send in
                        await fileStorageService.replaceDocumentPhoto(documentId, in: vehicleId, with: capturedImage)
                        await send(.photoReplaced)
                    }
                } else {
                    print("❌ [PhotoDocumentDetailStore] Photo annulée")
                }
                state.showCamera = false
                return .none
                
            case .photoReplaced:
                print("✅ [PhotoDocumentDetailStore] Photo remplacée avec succès, rechargement")
                state.isLoading = false
                state.image = nil
                return .run { send in
                    await send(.loadDocument)
                }
                
            case .deleteDocument:
                print("🗑️ [PhotoDocumentDetailStore] Demande de suppression - fermeture d'abord")
                return .run { send in
                    await send(.requestDeletion)
                }
                
            case .requestDeletion:
                print("📤 [PhotoDocumentDetailStore] Demande de fermeture puis suppression")
                return .none
                
            case .documentDeleted:
                print("✅ [PhotoDocumentDetailStore] Document photo supprimé avec succès (legacy)")
                state.isLoading = false
                return .run { send in
                    await send(.goBack)
                }
                
            case .goBack:
                print("🔙 [PhotoDocumentDetailStore] Retour à la vue précédente")
                return .none
            }
        }
    }
    
    private func loadImageFromFile(_ fileURL: String) async -> UIImage? {
        print("📸 [PhotoDocumentDetailStore] Chargement de l'image depuis: \(fileURL)")
        
        let url = URL(fileURLWithPath: fileURL)
        
        // Add a small delay to ensure file system operations are complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        do {
            let data = try Data(contentsOf: url)
            let image = UIImage(data: data)
            print("✅ [PhotoDocumentDetailStore] Image chargée avec succès, taille: \(data.count) bytes")
            return image
        } catch {
            print("❌ [PhotoDocumentDetailStore] Erreur lors du chargement de l'image: \(error.localizedDescription)")
            print("🔍 [PhotoDocumentDetailStore] URL tentée: \(url.path)")
            
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            print("📁 [PhotoDocumentDetailStore] Fichier existe: \(fileExists)")
            
            return nil
        }
    }
}