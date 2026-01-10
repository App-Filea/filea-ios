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
    
    enum ViewState: Equatable {
        case loading
        case document(Document)
    }
    
    @ObservableState
    struct State: Equatable {
        var viewState: ViewState
        let vehicleId: String
        let documentId: String
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
    }
    
    enum Action: Equatable {
        case loadDocument
        case documentLoaded(Document)
        case loadImage
        case imageLoaded(UIImage?)
        case deleteDocument
        case documentDeleted
        case editDocumentButtonTapped
        case showEditDocument(String, Document)
        case dismiss
    }
    
    @Dependency(\.vehicleGRDBClient) var vehicleRepository
    @Dependency(\.documentRepository) var documentRepository
    @Dependency(\.dismiss) var dismiss
    
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
//                            await send(.documentLoaded(nil))
                        }
                    } catch {
                        print("❌ [DocumentDetailStore] Erreur lors du chargement: \(error.localizedDescription)")
//                        await send(.documentLoaded(nil))
                    }
                }
                
            case .documentLoaded(let document):
                state.viewState = .document(document)
//                if let doc = document {
//                    print("📄 [DocumentDetailStore] Document chargé, début du chargement de l'image")
//                    return .run { send in
//                        await send(.loadImage)
//                    }
//                } else {
//                    print("⚠️ [DocumentDetailStore] Aucun document chargé")
//                }
                return .none
                
            case .loadImage:
//                guard let document = state.document else {
//                    print("❌ [DocumentDetailStore] Impossible de charger l'image - aucun document")
//                    return .none
//                }
//                print("🔄 [DocumentDetailStore] Début du chargement de l'image: \(document.fileURL)")
//                state.isLoading = true
//                return .run { [fileURL = document.fileURL] send in
//                    let image = await loadImageFromFile(fileURL)
//                    await send(.imageLoaded(image))
//                }
                return .none
                
            case .imageLoaded(let image):
//                if image != nil {
//                    print("✅ [DocumentDetailStore] Image chargée avec succès")
//                } else {
//                    print("❌ [DocumentDetailStore] Échec du chargement de l'image")
//                }
//                state.image = image
//                state.isLoading = false
                return .none
                
            case .deleteDocument:
                guard case let .document(document) = state.viewState else {
                    print("❌ [DocumentDetailStore] Impossible de supprimer - aucun document")
                    return .none
                }
                print("🗑️ [DocumentDetailStore] Début de la suppression du document: \(state.documentId)")
                return .run { [vehicleId = state.vehicleId, documentId = state.documentId] send in
                    do {
                        try await documentRepository.delete(documentId, for: vehicleId)
                        await send(.documentDeleted)
                    } catch {
                        print("❌ [DocumentDetailStore] Erreur lors de la suppression: \(error.localizedDescription)")
                        await send(.documentDeleted)
                    }
                }
                return .none
                
            case .documentDeleted:
                print("✅ [DocumentDetailStore] Document supprimé avec succès")
                // Recharger le véhicule pour mettre à jour la liste des documents
                return .run { [vehicleId = state.vehicleId, vehicles = state.$vehicles, selectedVehicle = state.$selectedVehicle] send in
                    do {
                        if let updatedVehicle = try await vehicleRepository.getVehicle(vehicleId) {
                            print("🔄 [DocumentDetailStore] Mise à jour du véhicule dans @Shared")
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
                        await send(.dismiss)
                    } catch {
                        print("❌ [DocumentDetailStore] Erreur lors du rechargement du véhicule: \(error.localizedDescription)")
                    }
                }
                
            case .dismiss: return .run { _ in await self.dismiss() }
                
            case .editDocumentButtonTapped:
                guard case let .document(document) = state.viewState else { return .none }
                return .send(.showEditDocument(state.vehicleId, document))
            default: return .none
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
