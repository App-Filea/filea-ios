//
//  DocumentCard.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Reusable document card component
//

import SwiftUI

/// Reusable document card component for list display
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
                // Document type icon
                Image(systemName: document.type.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(ColorTokens.textSecondary)

                // Document info
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    // Title with date
                    HStack(spacing: Spacing.xxs) {
                        Text(document.name)
                            .font(Typography.body.weight(.semibold))
                            .foregroundStyle(ColorTokens.textPrimary)

                        Circle()
                            .fill(ColorTokens.textTertiary)
                            .frame(width: 4, height: 4)

                        Text(document.date.shortDateString)
                            .font(Typography.body.weight(.semibold))
                            .foregroundStyle(ColorTokens.textSecondary)
                    }
                    .lineLimit(1)

                    // Amount and type
                    HStack(spacing: Spacing.xxs) {
                        if let amount = document.amount {
                            Text(amount.asCurrencyStringNoDecimals)
                                .font(Typography.callout)
                                .foregroundStyle(ColorTokens.textSecondary)
                        } else {
                            Text("-- €")
                                .font(Typography.callout)
                                .foregroundStyle(ColorTokens.textTertiary)
                        }

                        Circle()
                            .fill(ColorTokens.textTertiary)
                            .frame(width: 4, height: 4)

                        Text(document.type.displayName)
                            .font(Typography.callout)
                            .foregroundStyle(ColorTokens.textSecondary)
                    }

                    // Incomplete badge
                    if document.amount == nil {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                            Text("Incomplet")
                                .font(Typography.caption2.weight(.medium))
                        }
                        .foregroundStyle(ColorTokens.warning)
                    }

                    // Mileage
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "gauge.open.with.lines.needle.33percent")
                            .font(.caption)
                        Text(document.mileage.asFormattedMileage)
                            .font(Typography.callout)
                    }
                    .foregroundStyle(ColorTokens.textSecondary)
                }

                Spacer()

                // Thumbnail
                ThumbnailView(
                    fileURL: document.fileURL,
                    width: 60,
                    height: 80
                )

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ColorTokens.textTertiary)
            }
            .padding(.vertical, Spacing.xs)
        }
        .buttonStyle(.plain)
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
                type: .vidange,
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
                type: .assurance,
                amount: nil
            ),
            action: {}
        )
    }
    .padding()
    .background(Color(.systemBackground))
}
