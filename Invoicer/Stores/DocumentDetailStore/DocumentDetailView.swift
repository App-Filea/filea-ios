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
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .onAppear {
                store.send(.loadDocument)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { store.send(.deleteDocument) }) {
                        Image(systemName: "trash.fill")
                            .foregroundStyle(.black)
                    }
                }
            }
        }
        .quickLookPreview($selectedDocumentURL)
    }

    private func documentView(_ document: Document) -> some View {
        VStack(spacing: Spacing.sectionSpacing) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.black)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: document.type.imageName)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
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
                MetricCard2(
                    icon: "eurosign",
                    label: "Montant",
                    value: document.amount?.asCurrencyStringNoDecimals ?? "-- €"
                )
                
                MetricCard2(
                    icon: "gauge.open.with.lines.needle.33percent",
                    label: "Kilométrage",
                    value: document.mileage.isEmpty ? "-- km" : document.mileage.asFormattedMileage
                )
                
                MetricCard2(
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
                            .font(.system(size: 18, weight: .semibold))
                        Text("Afficher")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white)
                    .cornerRadius(14)
                }
                
                Button(action: { store.send(.editDocumentButtonTapped) }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Modifier")
                            .font(.system(size: 17, weight: .semibold))
                    }
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
                vehicleId: UUID(),
                documentId: UUID()
            )
        ) {
            DocumentDetailStore()
        })
    }
}

#Preview("Document") {
    let previewDocument = Document(
        id: UUID(),
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
                vehicleId: UUID(),
                documentId: previewDocument.id
            )
        ) {
            DocumentDetailStore()
        })
    }
}

// MARK: - Metric Card Component
struct MetricCard2: View {
    let icon: String
    let label: String
    let value: String
    var valueSize: CGFloat = 28
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: valueSize, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}
