//
//  StatCard.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Reusable statistics card component
//

import SwiftUI

/// Reusable statistics card component
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String?
    let accentColor: Color
    let action: (() -> Void)?

    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String? = nil,
        accentColor: Color = ColorTokens.actionPrimary,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.accentColor = accentColor
        self.action = action
    }

    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Header
                HStack {
                    Text(title)
                        .font(Typography.subheadline)
                        .foregroundStyle(ColorTokens.textPrimary)
                    Spacer()
                    if action != nil {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(ColorTokens.textSecondary)
                    }
                }

                Spacer()

                // Value with optional icon
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xxs) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(accentColor)
                            .frame(width: 28, height: 28)
                    }

                    Text(value)
                        .font(Typography.currencyLarge.weight(.bold))
                        .foregroundStyle(ColorTokens.textPrimary)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }

                // Subtitle
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Typography.caption1)
                        .foregroundStyle(ColorTokens.textSecondary)
                }
            }
            .padding(Spacing.cardPadding)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 140)
        .background(ColorTokens.surface)
        .cornerRadius(Radius.card)
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        HStack(spacing: Spacing.sm) {
            StatCard(
                title: "Coût total",
                value: "1 234 €",
                subtitle: "Sur l'année en cours",
                accentColor: .purple
            )

            StatCard(
                title: "Alertes",
                value: "3",
                subtitle: "Nécessite votre attention",
                icon: "exclamationmark.triangle.fill",
                accentColor: .yellow,
                action: { print("Alerts tapped") }
            )
        }
    }
    .padding()
    .background(Color(.secondarySystemBackground))
}
