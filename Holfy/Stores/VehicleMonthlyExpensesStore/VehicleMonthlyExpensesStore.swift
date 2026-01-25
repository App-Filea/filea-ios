//
//  VehicleMonthlyExpensesStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 31/10/2025.
//

import Foundation
import ComposableArchitecture

@Reducer
struct VehicleMonthlyExpensesStore {
    
    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        var currentVehicleMonthlyExpenses: [MonthlyExpense] = []
    }
    
    enum Action: Equatable {
        case view(ActionView)
        case computeVehicleMontlyExpenses
        case recomputeVehicleMontlyExpenses(Vehicle)
        case vehicleMonthlyExpensesCalculated([MonthlyExpense])
        
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
                        .map(Action.recomputeVehicleMontlyExpenses)
                }
            case .computeVehicleMontlyExpenses, .recomputeVehicleMontlyExpenses:
                let calendar = Calendar.current
                let currentYear = calendar.component(.year, from: Date())
                let monthlyExpenses = self.statisticsRepository.calculateMonthlyExpenses(state.selectedVehicle.documents, currentYear)
                return .send(.vehicleMonthlyExpensesCalculated(monthlyExpenses))
            case .vehicleMonthlyExpensesCalculated(let monthlyExpenses):
                state.currentVehicleMonthlyExpenses = monthlyExpenses
                return .none
            }
        }
    }
}

