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
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle?
        var currentVehicleTotalCost: Double = 0
    }
    
    enum Action: Equatable {
        case computeVehicleTotalCost
        case vehicleTotalCostCalculated(Double)
    }
    
    @Dependency(\.statisticsRepository) var statisticsRepository
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .computeVehicleTotalCost:
                guard let selectedVehicle = state.selectedVehicle else { return .none }
                    return .run { send in
                        let total = statisticsRepository.calculateTotalCost(selectedVehicle.documents)
                        await send(.vehicleTotalCostCalculated(total))
                    }
            case .vehicleTotalCostCalculated(let totalCost):
                state.currentVehicleTotalCost = totalCost
                return .none
            }
        }
    }
}

