//
//  WarningVehicleView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 31/10/2025.
//

import SwiftUI
import ComposableArchitecture

struct WarningVehicleView: View {
    @Bindable var store: StoreOf<WarningVehicleStore>

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if store.alerts.isEmpty {
                emptyStateContent
            } else {
                ForEach(store.alerts) { alert in
                    alertRow(alert)
                }
            }
        }
        .padding(Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(Radius.card)
        .onAppear {
            store.send(.view(.initiate))
        }
    }

    private var emptyStateContent: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("stat_card_warnings_all_good")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.primary)

                Text("stat_card_warnings_no_alerts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private func alertRow(_ alert: VehicleAlert) -> some View {
        HStack(spacing: Spacing.sm) {
            
            alert.alertPriority.color
                .opacity(0.2)
                .frame(width: 32, height: 32)
                .cornerRadius(8)
                .overlay {
                    Image(systemName: image(according: alert.alertPriority))
                        .foregroundStyle(alert.alertPriority.color)
                }

            Text(alert.message)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            Spacer()
        }
    }
    
    func image(according alertPriority: VehicleAlert.AlertPriority) -> String {
        switch alertPriority {
        case .high: "exclamationmark.triangle.fill"
        case .medium: "exclamationmark.triangle.fill"
        case .low: "doc.badge.ellipsis"
        }
    }
}

#Preview("With alerts") {
    let ctDocument = Document(fileURL: "", name: "CT 2024", date: .now, mileage: "", type: .technicalInspection)

    WarningVehicleView(
        store: .init(
            initialState: WarningVehicleStore.State(
                alerts: [
                    VehicleAlert(
                        type: .technicalInspection,
                        message: "CT expire dans 10 jours",
                        daysRemaining: 10,
                        relatedDocument: ctDocument
                    ),
                    VehicleAlert(
                        type: .technicalInspection,
                        message: "Entretien dans 45 jours",
                        daysRemaining: 45,
                        relatedDocument: ctDocument
                    )
                ]
            ),
            reducer: { WarningVehicleStore() }
        )
    )
    .padding()
}

#Preview("No alerts") {
    WarningVehicleView(
        store: .init(
            initialState: WarningVehicleStore.State(alerts: []),
            reducer: { WarningVehicleStore() }
        )
    )
    .padding()
}
