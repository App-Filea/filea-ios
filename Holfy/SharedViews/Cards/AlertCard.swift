//
//  AlertCard.swift
//  Holfy
//
//  Created by Claude on 2026-01-28.
//

import SwiftUI

struct AlertCard: View {
    let alert: VehicleAlert
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Circle()
                    .fill(alert.alertPriority.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: iconName)
                            .font(.system(size: 20))
                            .foregroundStyle(alert.alertPriority.color)
                    }

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(alert.message)
                        .primaryBody()
                        .fontWeight(.semibold)

                    if let daysRemaining = alert.daysRemaining {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "calendar")
                            Text("alert_days_remaining \(daysRemaining)")
                        }
                        .callout()
                        .foregroundStyle(alert.alertPriority.color)
                    }

                    Text(alert.relatedDocument.name)
                        .callout()
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .caption()
                    .fontWeight(.semibold)
            }
            .padding(Spacing.cardPadding)
        }
        .buttonStyle(.plain)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(Radius.card)
    }

    private var iconName: String {
        switch alert.type {
        case .technicalInspection:
            return "car.badge.gearshape"
        case .incompleteDocument:
            return "doc.badge.ellipsis"
        }
    }
}

#Preview {
    let document = Document(
        fileURL: "",
        name: "Contrôle technique 2024",
        date: .now,
        mileage: "",
        type: .technicalInspection
    )

    VStack(spacing: Spacing.sm) {
        AlertCard(
            alert: VehicleAlert(
                type: .technicalInspection,
                message: "CT expire dans 15 jours",
                daysRemaining: 15,
                relatedDocument: document
            ),
            action: {}
        )

        AlertCard(
            alert: VehicleAlert(
                type: .technicalInspection,
                message: "CT expire dans 45 jours",
                daysRemaining: 45,
                relatedDocument: document
            ),
            action: {}
        )
    }
    .padding()
    .background(Color(.systemBackground))
}
