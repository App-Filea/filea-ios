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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if store.isLoading || store.document == nil {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let document = store.document, let image = store.image {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Document info
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Document Details")
                                    .font(.headline)
                                
                                HStack {
                                    Text("Nom:")
                                        .fontWeight(.medium)
                                    Text(document.name)
                                        .foregroundColor(.primary)
                                }
                                
                                HStack {
                                    Text("Date:")
                                        .fontWeight(.medium)
                                    Text(document.date, style: .date)
                                }
                                
                                HStack {
                                    Text("Kilométrage:")
                                        .fontWeight(.medium)
                                    Text(document.mileage.isEmpty ? "Non renseigné" : "\(document.mileage) km")
                                        .foregroundColor(document.mileage.isEmpty ? .secondary : .primary)
                                }
                                
                                HStack {
                                    Text("Type:")
                                        .fontWeight(.medium)
                                    Text(document.type.displayName)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
//                                        .background(getDocumentColor(for: document.type).opacity(0.2))
//                                        .foregroundColor(getDocumentColor(for: document.type))
                                        .cornerRadius(8)
                                }

                                if let amount = document.amount {
                                    HStack {
                                        Text("Montant:")
                                            .fontWeight(.medium)
                                        Text(String(format: "%.2f €", amount))
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            // Image display
                            VStack(spacing: 12) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                                
                                // Replace photo button
                                Button(action: {
                                    store.send(.showCamera)
                                }) {
                                    HStack {
                                        Image(systemName: "camera.fill")
                                        Text("Replace Photo")
                                    }
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .disabled(store.isLoading)
                            }
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .imageScale(.large)
                            .foregroundColor(.orange)
                        Text("Unable to load image")
                            .font(.headline)
                        Text("The document file might have been moved or deleted")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationTitle("Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        store.send(.goBack)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Delete", role: .destructive) {
                        store.send(.deleteDocument)
                    }
                    .disabled(store.isLoading)
                }
            }
            .onAppear {
                store.send(.loadDocument)
            }
        }
        .sheet(isPresented: .init(
            get: { store.showCamera },
            set: { _ in store.send(.hideCamera) }
        )) {
            CameraView { image in
                store.send(.imageCapture(image))
            }
        }
    }
}

#Preview {
    DocumentDetailView(store: Store(initialState: DocumentDetailStore.State(
        vehicleId: UUID(),
        documentId: UUID()
    )) {
        DocumentDetailStore()
    })
}
