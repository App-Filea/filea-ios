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
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle?
        var currentVehicleIncompleteDocumentsCount: Int = 0
    }
    
    enum Action: Equatable {
        case computeVehicleWarnings
        case computedWarnings(Int)
    }
    
    @Dependency(\.statisticsRepository) var statisticsRepository
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .computeVehicleWarnings:
                guard let selectedVehicle = state.selectedVehicle else { return .none }
                return .run { send in
                    let incompleteDocumentCount = self.statisticsRepository.countIncompleteDocuments(selectedVehicle.documents)
                    await send(.computedWarnings(incompleteDocumentCount))
                }
                
            case .computedWarnings(let count):
                state.currentVehicleIncompleteDocumentsCount = count
                return .none
            }
        }
    }
}

