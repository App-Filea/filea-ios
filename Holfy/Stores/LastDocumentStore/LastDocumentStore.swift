//
//  LastDocumentStore.swift
//  Holfy
//
//  Created by Claude on 2026-01-26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct LastDocumentStore {

    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        var lastDocument: Document?
    }

    enum Action: Equatable {
        case view(ActionView)
        case computeLastDocument(Vehicle)
        case lastDocumentCalculated(Document?)

        enum ActionView: Equatable {
            case initiate
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.initiate):
                return .publisher {
                    state.$selectedVehicle.publisher
                        .map(Action.computeLastDocument)
                }

            case .computeLastDocument:
                let lastDocument = state.selectedVehicle.documents
                    .filter { $0.type == .maintenance || $0.type == .repair }
                    .sorted { $0.date > $1.date }
                    .first

                return .send(.lastDocumentCalculated(lastDocument))

            case let .lastDocumentCalculated(document):
                state.lastDocument = document
                return .none
            }
        }
    }
}
