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
        
    }
    
    enum Action: Equatable {
        case computeVehicleWarnings
    }
    
    @Dependency(\.statisticsRepository) var statisticsRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
                .none
            
//                .run { send in
                //                        let calendar = Calendar.current
                //                        let currentYear = calendar.component(.year, from: Date())
                //                        let monthlyExpenses = statisticsRepository.calculateMonthlyExpenses(for: documents, year: currentYear)
                //                    },
        }
    }
}

