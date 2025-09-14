//
//  AddDocumentView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture
import UniformTypeIdentifiers

struct AddDocumentView: View {
    @Bindable var store: StoreOf<AddDocumentStore>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = store.capturedImage, store.documentSource == .camera {
                    // Photo preview
                    VStack(spacing: 16) {
                        Text("Document Preview")
                            .font(.headline)
                        
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 400)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                        
                        Button("Retake Photo") {
                            store.send(.showCamera)
                        }
                        .foregroundColor(.blue)
                    }
                } else if let fileName = store.selectedFileName, store.documentSource == .file {
                    // File preview
                    VStack(spacing: 16) {
                        Text("Fichier Sélectionné")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "doc.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text(fileName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        Button("Choisir un Autre Fichier") {
                            store.send(.showFilePicker)
                        }
                        .foregroundColor(.blue)
                    }
                } else {
                    // No document selected yet
                    VStack(spacing: 20) {
                        Text("Ajouter un Document")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Choisissez comment ajouter votre document")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 16) {
                            // Camera option
                            Button(action: {
                                store.send(.showCamera)
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Prendre une Photo")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Utiliser l'appareil photo")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            
                            // File picker option
                            Button(action: {
                                store.send(.showFilePicker)
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "folder.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Importer un Fichier")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Depuis le stockage ou iCloud")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        store.send(.goBack)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        store.send(.saveDocument)
                    }
                    .disabled((store.capturedImage == nil && store.selectedFileURL == nil) || store.isLoading)
                }
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
        .sheet(isPresented: .init(
            get: { store.showFilePicker },
            set: { _ in store.send(.hideFilePicker) }
        )) {
            FilePickerView { url in
                store.send(.fileSelected(url))
            }
        }
    }
}


struct FilePickerView: UIViewControllerRepresentable {
    let onFileSelected: (URL?) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .jpeg, .png, .text, .plainText])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FilePickerView
        
        init(_ parent: FilePickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onFileSelected(urls.first)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onFileSelected(nil)
        }
    }
}

#Preview {
    AddDocumentView(store: Store(initialState: AddDocumentStore.State(vehicleId: UUID())) {
        AddDocumentStore()
    })
}