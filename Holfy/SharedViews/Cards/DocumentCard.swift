//
//  DocumentCard.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Reusable document card component
//

import SwiftUI
import ComposableArchitecture

// MARK: - Original Card

struct DocumentCard: View {
    let document: Document
    let action: () -> Void
    
    @Shared(.selectedCurrency) var currency: Currency
    @Shared(.selectedDistanceUnit) var distanceUnit: DistanceUnit
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                ThumbnailView(
                    fileURL: document.fileURL,
                    width: 56,
                    height: 72
                )
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(document.name)
                                .primaryBody()
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            
                            Text(document.type.displayName)
                                .callout()
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if let amount = document.amount {
                            Text(amount.asCurrencyStringAdaptive(currency: currency))
                                .primaryBody()
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                    }
                    
                    Divider()
                    
                    HStack(spacing: Spacing.xxs) {
                        Text(document.date.shortDateString)
                            .caption()
                            .foregroundStyle(.secondary)
                        
                        if let mileageValue = document.mileage.asDouble {
                            Text("•")
                                .caption()
                            
                            Text(mileageValue.asDistanceString(unit: distanceUnit))
                                .caption()
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                        
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text("Incomplet")
                        }
                        .font(.caption)
                        .foregroundStyle(.orange)
                        
                    }
                    .lineLimit(1)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
            }
            .padding(Spacing.cardPadding)
        }
        .buttonStyle(.plain)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(Radius.card)
    }
}

#Preview("Toutes les variantes") {
    let sampleDocumentComplete = Document(
        fileURL: "/path/to/document.jpg",
        name: "Vidange moteur",
        date: Date(),
        mileage: "45000",
        type: .maintenance,
        amount: 89.99
    )
    
    let sampleDocumentIncomplete = Document(
        fileURL: "/path/to/document2.pdf",
        name: "Assurance auto",
        date: Date().addingDays(-30) ?? Date(),
        mileage: "",
        type: .technicalInspection,
        amount: nil
    )
    
    ScrollView {
        VStack(alignment: .leading, spacing: Spacing.lg) {
                DocumentCard(document: sampleDocumentComplete, action: {})
                DocumentCard(document: sampleDocumentIncomplete, action: {})
        }
        .padding(Spacing.screenMargin)
    }
}
