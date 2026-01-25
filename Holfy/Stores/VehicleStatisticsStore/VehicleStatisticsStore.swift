//
//  VehicleStatisticsStore.swift
//  Holfy
//
//  Created by Claude Code on 19/01/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct VehicleStatisticsStore {
    @ObservableState
    struct State: Equatable {
        var totalCostVehicle: TotalCostVehicleStore.State = .init()
        var vehicleMonthlyExpenses: VehicleMonthlyExpensesStore.State = .init()
    }

    enum Action: Equatable {
        case totalCostVehicle(TotalCostVehicleStore.Action)
        case vehicleMonthlyExpenses(VehicleMonthlyExpensesStore.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.totalCostVehicle, action: \.totalCostVehicle) {
            TotalCostVehicleStore()
        }
        Scope(state: \.vehicleMonthlyExpenses, action: \.vehicleMonthlyExpenses) {
            VehicleMonthlyExpensesStore()
        }

        Reduce { state, action in
            .none  // Pure compositeur, pas de logique propre
        }
    }
}
