//
//  VehicleFuelStore.swift
//  Holfy
//
//  Created by Claude Code on 20/01/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct VehicleFuelStore {
    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        @Presents var addDocument: AddDocumentStore.State?

        var filteredDocuments: [Document] { [] }
        var documentCount: Int { 0 }
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
                state.addDocument = AddDocumentStore.State.initialState(vehicleId: state.selectedVehicle.id, documentType: .maintenance) // change to fuel when created
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
