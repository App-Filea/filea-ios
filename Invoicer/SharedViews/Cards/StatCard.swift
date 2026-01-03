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
    let title: LocalizedStringKey
    let value: String
    let subtitle: LocalizedStringKey?
    let icon: String?
    let iconColor: Color
    let action: (() -> Void)?

    init(
        title: LocalizedStringKey,
        value: String,
        subtitle: LocalizedStringKey? = nil,
        icon: String? = nil,
        iconColor: Color = Color.orange,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
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
                        .secondarySubheadline()
                    
                    Spacer()
                    if action != nil {
                        Image(systemName: "chevron.right")
                            .secondarySubheadline()
                    }
                }

                Spacer()

                // Value with optional icon
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xxs) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(iconColor)
                            .frame(width: 28, height: 28)
                    }

                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }

                // Subtitle
                if let subtitle = subtitle {
                    Text(subtitle)
                        .caption()
                }
            }
            .padding(Spacing.cardPadding)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 140)
        .background(Color(.tertiarySystemGroupedBackground))
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
                iconColor: .purple
            )

            StatCard(
                title: "Alertes",
                value: "3",
                subtitle: "Nécessite votre attention",
                icon: "exclamationmark.triangle.fill",
                iconColor: .yellow,
                action: { print("Alerts tapped") }
            )
        }
    }
    .padding()
    .background(Color(.systemBackground))
}
