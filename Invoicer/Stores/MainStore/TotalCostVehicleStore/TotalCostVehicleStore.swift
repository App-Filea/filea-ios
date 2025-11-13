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
        
    }
    
    enum Action: Equatable {
     case computeVehicleTotalCost
    }
    
    @Dependency(\.statisticsRepository) var statisticsRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
                .none
            
            //                return .merge(
            //                    // Effect 1: Calculate total cost
            //                    .run { send in
            //                        let total = statisticsRepository.calculateTotalCost(for: documents)
            //                        await send(.vehicleTotalCostCalculated(total))
            //                    },
        }
    }
}

