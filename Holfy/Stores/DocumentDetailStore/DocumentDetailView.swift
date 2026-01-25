//
//  DocumentDetailView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct DocumentDetailView: View {
    @Bindable var store: StoreOf<DocumentDetailStore>
    @State private var selectedDocumentURL: URL?

    @Shared(.selectedCurrency) var currency: Currency
    @Shared(.selectedDistanceUnit) var distanceUnit: DistanceUnit

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView {
                    if let document = store.document {
                        documentView(document)
                            .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                    } else {
                        ContentUnavailableView(
                            "Document introuvable",
                            systemImage: "doc.questionmark",
                            description: Text("Ce document n'existe plus.")
                        )
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .quickLookPreview($selectedDocumentURL)
    }
    
    private func documentView(_ document: Document) -> some View {
        VStack(spacing: Spacing.lg) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.tertiarySystemGroupedBackground))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: document.type.imageName)
                        .font(.system(size: 36))
                        .foregroundColor(Color.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.name)
                        .largeTitle()
                        .lineLimit(1)

                    Text(document.type.displayName)
                        .subLargeTitle()
                }
                Spacer()
            }
            
            VStack(spacing: 12) {
                amountCard(document)

                DetailCard(
                    icon: "gauge.open.with.lines.needle.33percent",
                    label: "document_form_mileage_label",
                    value: {
                        if let mileageValue = document.mileage.asDouble {
                            return mileageValue.asDistanceString(unit: distanceUnit)
                        }
                        return String(localized: "all_not_specified")
                    }()
                )

                DetailCard(
                    icon: "calendar",
                    label: "document_form_date_label",
                    value: document.date.shortDateString
                )
            }
            
            Spacer()
            
            VStack {
                
                PrimaryButton("all_edit", systemImage: "square.and.pencil", action: {
                    store.send(.editDocumentButtonTapped)
                })

                SecondaryButton("all_display", systemImage: "text.document", action: {
                    selectedDocumentURL = URL(fileURLWithPath: document.fileURL)
                })

                DestructiveButton("all_delete", action: {
                    store.send(.deleteDocument)
                })
            }
        }
        .padding(.horizontal, Spacing.screenMargin)
    }

    private func amountCard(_ document: Document) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .frame(width: 36, height: 36)

                    Image(systemName: currency.iconName)
                        .font(.title3)
                        .foregroundColor(Color.secondary)
                }

                Text("document_form_amount_label")
                    .caption()

                Spacer()
            }

            HStack(spacing: Spacing.sm) {
                if let amount = document.amount {
                    Text(amount.asCurrencyStringNoDecimals(currency: currency))
                        .title()
                } else {
                    Text("all_not_specified")
                        .title()

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
        }
        .padding(16)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}

#Preview("Document") {
    let previewDocument = Document(
        id: "preview-doc-id",
        fileURL: "/fake/path/receipt.jpg",
        name: "Révision complète",
        date: Date(),
        mileage: "1000000000000",
        type: .maintenance,
        amount: nil
    )

    @Shared(.selectedVehicle) var selectedVehicle = Vehicle(
        id: "preview-vehicle",
        documents: [previewDocument]
    )

    return NavigationView {
        DocumentDetailView(store: Store(
            initialState: DocumentDetailStore.State(
                documentId: previewDocument.id
            )
        ) {
            DocumentDetailStore()
        })
    }
}

#Preview("Document not found") {
    @Shared(.selectedVehicle) var selectedVehicle = Vehicle(
        id: "preview-vehicle",
        documents: []
    )

    return NavigationView {
        DocumentDetailView(store: Store(
            initialState: DocumentDetailStore.State(
                documentId: "non-existent"
            )
        ) {
            DocumentDetailStore()
        })
    }
}
