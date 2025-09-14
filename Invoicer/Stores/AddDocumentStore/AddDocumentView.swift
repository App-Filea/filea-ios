//
//  AddDocumentView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct AddDocumentView: View {
    @Bindable var store: StoreOf<AddDocumentStore>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = store.capturedImage {
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
                } else {
                    // No photo taken yet
                    VStack(spacing: 16) {
                        Image(systemName: "camera.fill")
                            .imageScale(.large)
                            .font(.system(size: 60))
                            .foregroundStyle(.tint)
                        
                        Text("Take a Photo")
                            .font(.headline)
                        
                        Text("Capture a document photo to add to this vehicle")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Open Camera") {
                            store.send(.showCamera)
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
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
                    .disabled(store.capturedImage == nil || store.isLoading)
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
    }
}

struct CameraView: UIViewControllerRepresentable {
    let onImageCapture: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            parent.onImageCapture(image)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImageCapture(nil)
        }
    }
}

#Preview {
    AddDocumentView(store: Store(initialState: AddDocumentStore.State(vehicleId: UUID())) {
        AddDocumentStore()
    })
}