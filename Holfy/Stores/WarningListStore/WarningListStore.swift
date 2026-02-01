//
//  WarningListStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 25/01/2026.
//

import ComposableArchitecture
import Dependencies
import Foundation

@Reducer
struct WarningListStore {

    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        var alerts: [VehicleAlert] = []

        var technicalInspectionAlerts: [VehicleAlert] {
            alerts.filter { $0.type == .technicalInspection }
        }

        var incompleteDocumentAlerts: [VehicleAlert] {
            alerts.filter { $0.type == .incompleteDocument }
        }

        var hasAlerts: Bool {
            !alerts.isEmpty
        }
    }

    enum Action: Equatable {
        case view(ActionView)
        case computeAlerts(Vehicle)
        case alertsCalculated([VehicleAlert])
        case dismiss

        enum ActionView: Equatable {
            case initiate
            case alertTapped(VehicleAlert)
            case dismissButtonTapped
        }
    }

    @Dependency(\.dismiss) var dismiss
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

            case .view(.alertTapped):
                return .none

            case .view(.dismissButtonTapped):
                return .send(.dismiss)

            case .dismiss:
                return .run { _ in await self.dismiss() }
            }
        }
    }
}
