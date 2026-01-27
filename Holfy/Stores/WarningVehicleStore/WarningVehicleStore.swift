//
//  WarningVehicleStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 31/10/2025.
//

import ComposableArchitecture
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

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.initiate):
                return .publisher {
                    state.$selectedVehicle.publisher
                        .map(Action.computeAlerts)
                }

            case .computeAlerts:
                let alerts = calculateAlerts(for: state.selectedVehicle)
                return .send(.alertsCalculated(alerts))

            case let .alertsCalculated(alerts):
                state.alerts = alerts
                return .none
            }
        }
    }

    private func calculateAlerts(for vehicle: Vehicle) -> [VehicleAlert] {
        var alerts: [VehicleAlert] = []
        let now = Date()
        let calendar = Calendar.current

        // 1. Alertes d'expiration (CT)
        for document in vehicle.documents {
            guard let expirationDate = document.expirationDate else { continue }

            let daysRemaining = calendar.dateComponents([.day], from: now, to: expirationDate).day ?? 0

            guard daysRemaining >= 0 && daysRemaining <= 60 else { continue }

            switch document.type {
            case .technicalInspection:
                let message = String(
                    format: NSLocalizedString("alert_ct_expires_in_days", comment: ""),
                    daysRemaining
                )
                alerts.append(VehicleAlert(type: .technicalInspection, message: message, daysRemaining: daysRemaining))

            case .maintenance, .repair, .other:
                break
            }
        }

        // 2. Alerte documents incomplets
        let incompleteCount = countIncompleteDocuments(in: vehicle)
        if incompleteCount > 0 {
            let message = String(localized: "alert_incomplete_documents \(incompleteCount)")
            alerts.append(VehicleAlert(type: .incompleteDocuments, message: message))
        }

        // Trier par priorité (haute d'abord) puis par jours restants
        let sortedAlerts = alerts
            .sorted { lhs, rhs in
                if lhs.alertPriority != rhs.alertPriority {
                    return lhs.alertPriority > rhs.alertPriority
                }
                return (lhs.daysRemaining ?? Int.max) < (rhs.daysRemaining ?? Int.max)
            }
            .prefix(4)

        return Array(sortedAlerts)
    }

    private func countIncompleteDocuments(in vehicle: Vehicle) -> Int {
        vehicle.documents.filter { document in
            switch document.type {
            case .maintenance, .repair, .technicalInspection:
                return document.amount == nil
            case .other:
                return false
            }
        }.count
    }
}
