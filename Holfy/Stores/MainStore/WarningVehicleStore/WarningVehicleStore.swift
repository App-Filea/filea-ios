//
//  WarningVehicleStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 31/10/2025.
//

import ComposableArchitecture

@Reducer
struct WarningVehicleStore {
    
    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        var currentVehicleIncompleteDocumentsCount: Int = 0
    }
    
    enum Action: Equatable {
        case view(ActionView)
        case computeVehicleWarnings
        case recomputeVehicleWarnings(Vehicle)
        case computedWarnings(Int)
        
        enum ActionView: Equatable {
            case initiate
        }
    }
    
    @Dependency(\.statisticsRepository) var statisticsRepository
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.initiate):
                return .publisher {
                    state.$selectedVehicle.publisher
                        .map(Action.recomputeVehicleWarnings)
                }
            case .computeVehicleWarnings, .recomputeVehicleWarnings:
                let incompleteDocumentCount = self.statisticsRepository.countIncompleteDocuments(state.selectedVehicle.documents)
                return .send(.computedWarnings(incompleteDocumentCount))
                
            case .computedWarnings(let count):
                state.currentVehicleIncompleteDocumentsCount = count
                return .none
            }
        }
    }
}

