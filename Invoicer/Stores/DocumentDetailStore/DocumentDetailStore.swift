//
//  DocumentDetailStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct DocumentDetailStore {
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
        case documentDeleted
        case goBack
    }
    
    @Dependency(\.vehicleRepository) var vehicleRepository
    @Dependency(\.documentRepository) var documentRepository
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadDocument:
                print("📖 [DocumentDetailStore] Chargement du document: \(state.documentId)")
                return .run { [vehicleId = state.vehicleId, documentId = state.documentId] send in
                    do {
                        if let vehicle = try await vehicleRepository.getVehicle(vehicleId),
                           let document = vehicle.documents.first(where: { $0.id == documentId }) {
                            print("✅ [DocumentDetailStore] Document trouvé: \(document.fileURL)")
                            await send(.documentLoaded(document))
                        } else {
                            print("❌ [DocumentDetailStore] Document non trouvé avec ID: \(documentId)")
                            await send(.documentLoaded(nil))
                        }
                    } catch {
                        print("❌ [DocumentDetailStore] Erreur lors du chargement: \(error.localizedDescription)")
                        await send(.documentLoaded(nil))
                    }
                }
                
            case .documentLoaded(let document):
                state.document = document
                if let doc = document {
                    print("📄 [DocumentDetailStore] Document chargé, début du chargement de l'image")
                    return .run { send in
                        await send(.loadImage)
                    }
                } else {
                    print("⚠️ [DocumentDetailStore] Aucun document chargé")
                }
                return .none
                
            case .loadImage:
                guard let document = state.document else {
                    print("❌ [DocumentDetailStore] Impossible de charger l'image - aucun document")
                    return .none
                }
                print("🔄 [DocumentDetailStore] Début du chargement de l'image: \(document.fileURL)")
                state.isLoading = true
                return .run { [fileURL = document.fileURL] send in
                    let image = await loadImageFromFile(fileURL)
                    await send(.imageLoaded(image))
                }
                
            case .imageLoaded(let image):
                if image != nil {
                    print("✅ [DocumentDetailStore] Image chargée avec succès")
                } else {
                    print("❌ [DocumentDetailStore] Échec du chargement de l'image")
                }
                state.image = image
                state.isLoading = false
                return .none
                
            case .showCamera:
                print("📷 [DocumentDetailStore] Ouverture de la caméra")
                state.showCamera = true
                return .none
                
            case .hideCamera:
                print("🚫 [DocumentDetailStore] Fermeture de la caméra (appelé automatiquement par SwiftUI)")
                state.showCamera = false
                return .none
                
            case .imageCapture(let image):
                if let capturedImage = image {
                    print("✅ [DocumentDetailStore] Photo acceptée, remplacement direct en cours...")
                    print("🔍 [DocumentDetailStore] Taille de la nouvelle image: \(capturedImage.size)")
                    
                    // Remplacer directement sans prévisualisation
                    state.isLoading = true
                    state.showCamera = false
                    
                    return .run { [vehicleId = state.vehicleId, documentId = state.documentId] send in
                        do {
                            try await documentRepository.replacePhoto(documentId, for: vehicleId, with: capturedImage)
                            await send(.photoReplaced)
                        } catch {
                            print("❌ [DocumentDetailStore] Erreur lors du remplacement: \(error.localizedDescription)")
                            await send(.photoReplaced)
                        }
                    }
                } else {
                    print("❌ [DocumentDetailStore] Photo annulée avec le bouton 'Annuler' dans l'interface iOS")
                }
                state.showCamera = false
                return .none
                
            case .photoReplaced:
                print("✅ [DocumentDetailStore] Photo remplacée avec succès, rechargement du document")
                state.isLoading = false
                // Clear the current image to force reload
                state.image = nil
                return .run { send in
                    await send(.loadDocument)
                }
                
            case .deleteDocument:
                guard let document = state.document else {
                    print("❌ [DocumentDetailStore] Impossible de supprimer - aucun document")
                    return .none
                }
                print("🗑️ [DocumentDetailStore] Début de la suppression du document: \(state.documentId)")
                state.isLoading = true
                return .run { [vehicleId = state.vehicleId, documentId = state.documentId] send in
                    do {
                        try await documentRepository.delete(documentId, for: vehicleId)
                        await send(.documentDeleted)
                    } catch {
                        print("❌ [DocumentDetailStore] Erreur lors de la suppression: \(error.localizedDescription)")
                        await send(.documentDeleted)
                    }
                }
                
            case .documentDeleted:
                print("✅ [DocumentDetailStore] Document supprimé avec succès")
                state.isLoading = false
                return .run { send in
                    await send(.goBack)
                }
                
            case .goBack:
                print("🔙 [DocumentDetailStore] Retour à la vue précédente")
                return .none
            }
        }
    }
    
    private func loadImageFromFile(_ fileURL: String) async -> UIImage? {
        print("📸 [DocumentDetailStore] Chargement de l'image depuis: \(fileURL)")
        
        let url = URL(fileURLWithPath: fileURL)
        
        // Add a small delay to ensure file system operations are complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        do {
            let data = try Data(contentsOf: url)
            let image = UIImage(data: data)
            print("✅ [DocumentDetailStore] Image chargée avec succès, taille: \(data.count) bytes")
            print("🔍 [DocumentDetailStore] Données de l'image - premiers 10 bytes: \(Array(data.prefix(10)))")
            return image
        } catch {
            print("❌ [DocumentDetailStore] Erreur lors du chargement de l'image: \(error.localizedDescription)")
            print("🔍 [DocumentDetailStore] URL tentée: \(url.path)")
            
            // Check if file exists
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            print("📁 [DocumentDetailStore] Fichier existe: \(fileExists)")
            
            return nil
        }
    }
}