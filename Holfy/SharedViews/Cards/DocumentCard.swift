//
//  DocumentCard.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Reusable document card component
//

import SwiftUI
import ComposableArchitecture

struct DocumentCard: View {
    let document: Document
    let action: () -> Void

    @Shared(.selectedCurrency) var currency: Currency
    @Shared(.selectedDistanceUnit) var distanceUnit: DistanceUnit

    init(document: Document, action: @escaping () -> Void) {
        self.document = document
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                ThumbnailView(
                    fileURL: document.fileURL,
                    width: 60,
                    height: 80
                )

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    HStack(spacing: Spacing.xxs) {
                        Text(document.name)
                            .primaryBody()
                            .fontWeight(.semibold)

                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 4, height: 4)

                        Text(document.date.shortDateString)
                            .secondaryBody()
                            .fontWeight(.semibold)
                    }
                    .lineLimit(1)

                    HStack(spacing: Spacing.xxs) {
                        if let amount = document.amount {
                            Text(amount.asCurrencyStringAdaptive(currency: currency))
                                .callout()
                            
                            Circle()
                                .fill(Color.secondary)
                                .frame(width: 4, height: 4)
                        }

                        Text(document.type.displayName)
                            .callout()
                    }

                    if let mileageValue = document.mileage.asDouble {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "gauge.open.with.lines.needle.33percent")
                            Text(mileageValue.asDistanceString(unit: distanceUnit))
                        }
                        .callout()
                    }

                    if document.amount == nil {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("document_status_incomplete")
                        }
                        .foregroundStyle(Color.orange)
                        .caption()
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, Spacing.xxs)
                        .background(Color.orange.tertiary)
                        .cornerRadius(Radius.badge)
                    }
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
}

#Preview {
    VStack(spacing: 0) {
        DocumentCard(
            document: Document(
                fileURL: "/path/to/document.jpg",
                name: "Vidange moteur",
                date: Date(),
                mileage: "45000",
                type: .maintenance,
                amount: 89.99
            ),
            action: {}
        )

        Divider()

        DocumentCard(
            document: Document(
                fileURL: "/path/to/document2.pdf",
                name: "Assurance auto",
                date: Date().addingDays(-30) ?? Date(),
                mileage: "",
                type: .other,
                amount: nil
            ),
            action: {}
        )
    }
    .padding()
    .background(Color(.systemBackground))
}
