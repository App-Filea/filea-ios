//
//  TotalCostVehicleStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 31/10/2025.
//

import ComposableArchitecture

@Reducer
struct TotalCostVehicleStore {
    
    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        var currentVehicleTotalCost: Double = 0
    }
    
    enum Action: Equatable {
        case view(ActionView)
        case computeVehicleTotalCost
        case recomputeVehicleTotalCost(Vehicle)
        case vehicleTotalCostCalculated(Double)
        
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
                        .map(Action.recomputeVehicleTotalCost)
                }
            case .computeVehicleTotalCost, .recomputeVehicleTotalCost:
                let total = statisticsRepository.calculateTotalCost(state.selectedVehicle.documents)
                return .send(.vehicleTotalCostCalculated(total))
                
            case .vehicleTotalCostCalculated(let totalCost):
                state.currentVehicleTotalCost = totalCost
                return .none
            }
        }
    }
}

