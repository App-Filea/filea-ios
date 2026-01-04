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
                    switch store.viewState {
                    case .loading:
                        VStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                    case .document(let document):
                        documentView(document)
                            .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .onAppear {
                store.send(.loadDocument)
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
                DetailCard(
                    icon: self.currency.iconName,
                    label: "document_form_amount_label",
                    value: document.amount?.asCurrencyStringNoDecimals(currency: currency) ?? String(localized: "all_not_specified")
                )

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
}

#Preview("Document") {
    
    @Shared(.selectedCurrency) var currency = .euro
    @Shared(.selectedDistanceUnit) var distanceUnit = .kilometers
    
    let previewDocument = Document(
        id: String(),
        fileURL: "/fake/path/receipt.jpg",
        name: "Révision complète",
        date: Date(),
        mileage: "1000000000000",
        type: .maintenance,
        amount: 10000
    )
    
    NavigationView {
        DocumentDetailView(store: Store(
            initialState: DocumentDetailStore.State(
                viewState: .document(previewDocument),
                vehicleId: String(),
                documentId: previewDocument.id
            )
        ) {
            DocumentDetailStore()
        })
    }
}

#Preview("Loading") {
    NavigationView {
        DocumentDetailView(store: Store(
            initialState: DocumentDetailStore.State(
                viewState: .loading,
                vehicleId: String(),
                documentId: String()
            )
        ) {
            DocumentDetailStore()
        })
    }
}
