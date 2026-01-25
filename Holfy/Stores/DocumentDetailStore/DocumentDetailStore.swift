//
//  DocumentDetailStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct DocumentDetailStore {

    @ObservableState
    struct State: Equatable {
        let documentId: String
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle

        var document: Document? {
            selectedVehicle.documents.first { $0.id == documentId }
        }
    }

    enum Action: Equatable {
        case deleteDocument
        case documentDeleted
        case editDocumentButtonTapped
        case showEditDocument(String, Document)
        case dismiss
    }

    @Dependency(\.documentRepository) var documentRepository
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .deleteDocument:
                guard state.document != nil else {
                    print("❌ [DocumentDetailStore] Impossible de supprimer - aucun document")
                    return .none
                }
                print("🗑️ [DocumentDetailStore] Début de la suppression du document: \(state.documentId)")
                return .run { [vehicleId = state.selectedVehicle.id, documentId = state.documentId] send in
                    do {
                        try await documentRepository.delete(documentId, for: vehicleId)
                        await send(.documentDeleted)
                    } catch {
                        print("❌ [DocumentDetailStore] Erreur lors de la suppression: \(error.localizedDescription)")
                    }
                }

            case .documentDeleted:
                print("✅ [DocumentDetailStore] Document supprimé avec succès")
                let documentId = state.documentId

                state.$selectedVehicle.withLock { vehicle in
                    vehicle.documents.removeAll { $0.id == documentId }
                }
                return .send(.dismiss)

            case .dismiss:
                return .run { _ in await self.dismiss() }

            case .editDocumentButtonTapped:
                guard let document = state.document else { return .none }
                return .send(.showEditDocument(state.selectedVehicle.id, document))

            default:
                return .none
            }
        }
    }
}
