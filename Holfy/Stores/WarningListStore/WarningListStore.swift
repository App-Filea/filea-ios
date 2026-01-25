//
//  WarningListStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 25/01/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct WarningListStore {

    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle

        var incompleteDocuments: [Document] {
            selectedVehicle.documents.filter { $0.amount == nil }
        }
    }

    enum Action: Equatable {
        case view(ActionView)
        case dismiss

        enum ActionView: Equatable {
            case incompleteDocumentTapped(Document)
            case dismissButtonTapped
        }
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.dismissButtonTapped):
                return .send(.dismiss)

            case .dismiss:
                return .run { _ in await self.dismiss() }

            default:
                return .none
            }
        }
    }
}
