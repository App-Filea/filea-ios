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
                    icon: "eurosign",
                    label: "document_form_amount_label",
                    value: document.amount?.asCurrencyStringNoDecimals ?? String(localized: "document_detail_not_specified_amount")
                )

                DetailCard(
                    icon: "gauge.open.with.lines.needle.33percent",
                    label: "document_form_mileage_label",
                    value: document.mileage.isEmpty ? String(localized: "document_detail_not_specified_mileage") : document.mileage.asFormattedMileage
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

#Preview("Document") {
    let previewDocument = Document(
        id: String(),
        fileURL: "/fake/path/receipt.jpg",
        name: "Révision complète",
        date: Date(),
        mileage: "45000",
        type: .maintenance,
        amount: 450.00
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
