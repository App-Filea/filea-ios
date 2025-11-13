//
//  VehicleMonthlyExpensesStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 31/10/2025.
//

import ComposableArchitecture

@Reducer
struct VehicleMonthlyExpensesStore {
    
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        case computeVehicleMontlyExpenses
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
                .none
        }
    }
}

