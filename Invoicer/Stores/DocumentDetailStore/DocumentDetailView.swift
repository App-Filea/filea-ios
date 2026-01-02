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
                ColorTokens.background
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
                            .toolbar {
                                ToolbarItem(placement: .primaryAction) {
                                    Button(action: { store.send(.deleteDocument) }) {
                                        Image(systemName: "trash.fill")
                                            .foregroundStyle(.black)
                                    }
                                }
                            }
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
        VStack(spacing: Spacing.sectionSpacing) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: document.type.imageName)
                        .font(.system(size: 36))
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(document.type.displayName)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            VStack(spacing: 12) {
                DetailCard(
                    icon: "eurosign",
                    label: "Montant",
                    value: document.amount?.asCurrencyStringNoDecimals ?? "-- €"
                )
                
                DetailCard(
                    icon: "gauge.open.with.lines.needle.33percent",
                    label: "Kilométrage",
                    value: document.mileage.isEmpty ? "-- km" : document.mileage.asFormattedMileage
                )
                
                DetailCard(
                    icon: "calendar",
                    label: "Date",
                    value: document.date.shortDateString
                )
            }
            
            Spacer()
            
            VStack {
                Button(action: {
                    selectedDocumentURL = URL(fileURLWithPath: document.fileURL)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "text.document")
                        Text("Afficher")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.black)
                    .cornerRadius(14)
                }
                
                Button(action: { store.send(.editDocumentButtonTapped) }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                        Text("Modifier")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white)
                    .cornerRadius(14)
                }
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
