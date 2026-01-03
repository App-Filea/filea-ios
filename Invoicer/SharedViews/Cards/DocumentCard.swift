//
//  DocumentCard.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Reusable document card component
//

import SwiftUI

struct DocumentCard: View {
    let document: Document
    let action: () -> Void

    init(document: Document, action: @escaping () -> Void) {
        self.document = document
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                // Thumbnail
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
                            Text(amount.asCurrencyStringNoDecimals)
                                .callout()
                        } else {
                            Text("-- €")
                                .callout()
                        }

                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 4, height: 4)

                        Text(document.type.displayName)
                            .callout()
                    }

                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "gauge.open.with.lines.needle.33percent")
                        Text(document.mileage.asFormattedMileage)
                    }
                    .callout()

                    if document.amount == nil {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Incomplet")
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

                // Chevron
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
                mileage: "44500",
                type: .other,
                amount: nil
            ),
            action: {}
        )
    }
    .padding()
    .background(Color(.systemBackground))
}
