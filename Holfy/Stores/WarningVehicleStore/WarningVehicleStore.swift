//
//  WarningVehicleStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 31/10/2025.
//

import ComposableArchitecture
import Dependencies
import Foundation

@Reducer
struct WarningVehicleStore {

    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        var alerts: [VehicleAlert] = []
    }

    enum Action: Equatable {
        case view(ActionView)
        case computeAlerts(Vehicle)
        case alertsCalculated([VehicleAlert])

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
                        .map(Action.computeAlerts)
                }

            case .computeAlerts:
                let alerts = statisticsRepository.calculateAlerts(state.selectedVehicle)
                return .send(.alertsCalculated(alerts))

            case let .alertsCalculated(alerts):
                state.alerts = alerts
                return .none
            }
        }
    }
}
