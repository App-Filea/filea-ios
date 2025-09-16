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
                switch store.currentStep {
                case .selectFile:
                    selectFileView()
                case .preview:
                    previewView()
                case .metadata:
                    metadataView()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(store.currentStep == .selectFile ? "Annuler" : "Retour") {
                        if store.currentStep == .selectFile {
                            store.send(.goBack)
                        } else {
                            store.send(.previousStep)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(nextButtonTitle) {
                        if store.currentStep == .metadata {
                            store.send(.saveDocument)
                        } else {
                            store.send(.nextStep)
                        }
                    }
                    .disabled(isNextButtonDisabled)
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
    
    // MARK: - Step Views
    
    @ViewBuilder
    private func selectFileView() -> some View {
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
    
    @ViewBuilder
    private func previewView() -> some View {
        if let image = store.capturedImage, store.documentSource == .camera {
            // Photo preview
            VStack(spacing: 16) {
                Text("Prévisualisation")
                    .font(.headline)
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 400)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                
                Button("Reprendre la Photo") {
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
        }
    }
    
    @ViewBuilder
    private func metadataView() -> some View {
        VStack(spacing: 20) {
            Text("Informations du Document")
                .font(.headline)
            
            VStack(spacing: 16) {
                // Document Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nom du document")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Nom du document", text: .init(
                        get: { store.documentName },
                        set: { store.send(.updateDocumentName($0)) }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
                
                // Date
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    DatePicker("Date", selection: .init(
                        get: { store.documentDate },
                        set: { store.send(.updateDocumentDate($0)) }
                    ), displayedComponents: .date)
                    .datePickerStyle(.compact)
                }
                
                // Mileage
                VStack(alignment: .leading, spacing: 8) {
                    Text("Kilométrage")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Kilométrage", text: .init(
                        get: { store.documentMileage },
                        set: { store.send(.updateDocumentMileage($0)) }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                }
                
                // Document Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type de document")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Type", selection: .init(
                        get: { store.documentType },
                        set: { store.send(.updateDocumentType($0)) }
                    )) {
                        ForEach(DocumentType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Computed Properties
    
    private var navigationTitle: String {
        switch store.currentStep {
        case .selectFile:
            return "Ajouter Document"
        case .preview:
            return "Prévisualisation"
        case .metadata:
            return "Informations"
        }
    }
    
    private var nextButtonTitle: String {
        switch store.currentStep {
        case .selectFile, .preview:
            return "Suivant"
        case .metadata:
            return store.isLoading ? "Sauvegarde..." : "Sauvegarder"
        }
    }
    
    private var isNextButtonDisabled: Bool {
        switch store.currentStep {
        case .selectFile:
            return store.capturedImage == nil && store.selectedFileURL == nil
        case .preview:
            return false
        case .metadata:
            return store.documentName.isEmpty || store.isLoading
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