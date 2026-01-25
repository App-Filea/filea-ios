//
//  VehicleMaintenanceStore.swift
//  Holfy
//
//  Created by Claude Code on 20/01/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct VehicleMaintenanceStore {
    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        @Presents var addDocument: AddDocumentStore.State?

        var filteredDocuments: [Document] {
            selectedVehicle.documents
                .filter { $0.type == .maintenance || $0.type == .repair }
                .sorted { $0.date > $1.date }
        }
    }

    enum Action: Equatable {
        case view(ActionView)
        case addDocument(PresentationAction<AddDocumentStore.Action>)

        case documentTapped(Document)
        case openAddDocument
        
        enum ActionView: Equatable {
            case addDocumentTapped
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(let actionView):
                switch actionView {
                case .addDocumentTapped:
                    return .send(.openAddDocument)
                }
                
            case .openAddDocument:
                state.addDocument = AddDocumentStore.State.initialState(vehicleId: state.selectedVehicle.id, documentType: .maintenance)
                return .none
            case .documentTapped:
                return .none // Delegated to parent
                
            default: return .none
            }
        }
        .ifLet(\.$addDocument, action: \.addDocument) {
            AddDocumentStore()
        }
    }
}
