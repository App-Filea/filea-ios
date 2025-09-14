//
//  DocumentDetailCoordinatorView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 14/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct DocumentDetailCoordinatorView: View {
    @Bindable var store: StoreOf<DocumentDetailCoordinatorStore>
    
    var body: some View {
        Group {
            switch store.documentType {
            case .photo:
                if let photoStore = store.scope(state: \.photoDocumentDetail, action: \.photoDocumentDetail) {
                    PhotoDocumentDetailView(store: photoStore)
                } else {
                    DocumentTypeLoadingView()
                }
                
            case .file:
                if let fileStore = store.scope(state: \.fileDocumentDetail, action: \.fileDocumentDetail) {
                    FileDocumentDetailView(store: fileStore)
                } else {
                    DocumentTypeLoadingView()
                }
                
            case .unknown:
                DocumentTypeLoadingView()
            }
        }
        .onAppear {
            if store.documentType == .unknown {
                store.send(.determineDocumentType)
            }
        }
    }
}

struct DocumentTypeLoadingView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Analyse du Document...")
                    .font(.headline)
                
                Text("Détermination du type de fichier en cours")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Document")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("Photo Document") {
    DocumentDetailCoordinatorView(
        store: Store(
            initialState: DocumentDetailCoordinatorStore.State(
                vehicleId: UUID(),
                documentId: UUID(),
                documentType: .photo
            )
        ) {
            DocumentDetailCoordinatorStore()
        }
    )
}

#Preview("File Document") {
    DocumentDetailCoordinatorView(
        store: Store(
            initialState: DocumentDetailCoordinatorStore.State(
                vehicleId: UUID(),
                documentId: UUID(),
                documentType: .file
            )
        ) {
            DocumentDetailCoordinatorStore()
        }
    )
}

#Preview("Loading") {
    DocumentDetailCoordinatorView(
        store: Store(
            initialState: DocumentDetailCoordinatorStore.State(
                vehicleId: UUID(),
                documentId: UUID(),
                documentType: .unknown
            )
        ) {
            DocumentDetailCoordinatorStore()
        }
    )
}