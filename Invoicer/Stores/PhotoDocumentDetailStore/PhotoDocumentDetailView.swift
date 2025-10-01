//
//  PhotoDocumentDetailView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 14/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct PhotoDocumentDetailView: View {
    @Bindable var store: StoreOf<PhotoDocumentDetailStore>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if store.isLoading || store.document == nil {
                    ProgressView("Chargement...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let document = store.document, let image = store.image {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Document info
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Détails du Document Photo")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Button("Éditer") {
                                        store.send(.showEditDocument)
                                    }
                                    .foregroundColor(.blue)
                                    .disabled(store.isLoading)
                                }
                                
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
                                        
                                    Spacer()
                                    
                                    Text("Photo")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            // Image display with zoom capability
                            VStack(spacing: 12) {
                                ZoomableImageView(image: image)
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                                
                                // Replace photo button
                                Button(action: {
                                    store.send(.showCamera)
                                }) {
                                    HStack {
                                        Image(systemName: "camera.fill")
                                        Text("Remplacer la Photo")
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
                        Text("Impossible de charger l'image")
                            .font(.headline)
                        Text("Le fichier image a peut-être été déplacé ou supprimé")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationTitle("Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Retour") {
                        store.send(.goBack)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Supprimer", role: .destructive) {
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

struct ZoomableImageView: View {
    let image: UIImage
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                scale = min(max(scale * delta, 1.0), 4.0)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                                if scale < 1.0 {
                                    withAnimation(.spring()) {
                                        scale = 1.0
                                        offset = .zero
                                    }
                                }
                            },
                        
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) {
                        if scale > 1.0 {
                            scale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2.0
                        }
                    }
                }
        }
        .clipped()
    }
}


#Preview {
    PhotoDocumentDetailView(store: Store(initialState: PhotoDocumentDetailStore.State(
        vehicleId: UUID(),
        documentId: UUID()
    )) {
        PhotoDocumentDetailStore()
    })
}
