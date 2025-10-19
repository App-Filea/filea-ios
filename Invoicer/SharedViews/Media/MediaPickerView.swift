//
//  MediaPickerView.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Unified media picker for photos and files
//

import SwiftUI
import PhotosUI

/// Unified media picker supporting both photos and files
struct MediaPickerView: View {
    @Binding var selectedImage: UIImage?
    @Binding var selectedFileURL: URL?
    @State private var showingImagePicker = false
    @State private var showingDocumentPicker = false
    @State private var showingCameraPicker = false
    @State private var showingActionSheet = false

    let allowsCamera: Bool
    let allowsPhotoLibrary: Bool
    let allowsFiles: Bool

    init(
        selectedImage: Binding<UIImage?> = .constant(nil),
        selectedFileURL: Binding<URL?> = .constant(nil),
        allowsCamera: Bool = true,
        allowsPhotoLibrary: Bool = true,
        allowsFiles: Bool = true
    ) {
        self._selectedImage = selectedImage
        self._selectedFileURL = selectedFileURL
        self.allowsCamera = allowsCamera
        self.allowsPhotoLibrary = allowsPhotoLibrary
        self.allowsFiles = allowsFiles
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Preview area
            if let image = selectedImage {
                imagePreview(image)
            } else if let fileURL = selectedFileURL {
                filePreview(fileURL)
            } else {
                emptyState
            }

            // Action buttons
            HStack(spacing: Spacing.sm) {
                if allowsCamera {
                    Button {
                        showingCameraPicker = true
                    } label: {
                        Label("Caméra", systemImage: "camera.fill")
                            .font(Typography.button)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.md)
                            .background(ColorTokens.actionPrimary)
                            .foregroundColor(ColorTokens.onActionPrimary)
                            .cornerRadius(Radius.button)
                    }
                }

                if allowsPhotoLibrary {
                    Button {
                        showingImagePicker = true
                    } label: {
                        Label("Photos", systemImage: "photo.fill")
                            .font(Typography.button)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.md)
                            .background(ColorTokens.actionSecondary)
                            .foregroundColor(ColorTokens.onActionSecondary)
                            .cornerRadius(Radius.button)
                    }
                }

                if allowsFiles {
                    Button {
                        showingDocumentPicker = true
                    } label: {
                        Label("Fichiers", systemImage: "folder.fill")
                            .font(Typography.button)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.md)
                            .background(ColorTokens.actionSecondary)
                            .foregroundColor(ColorTokens.onActionSecondary)
                            .cornerRadius(Radius.button)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCameraPicker) {
            CameraPickerView(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPickerView(selectedFileURL: $selectedFileURL)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(ColorTokens.textTertiary)

            Text("Aucun document sélectionné")
                .font(Typography.headline)
                .foregroundColor(ColorTokens.textSecondary)

            Text("Choisissez une photo ou un fichier")
                .font(Typography.subheadline)
                .foregroundColor(ColorTokens.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(ColorTokens.surface)
        .cornerRadius(Radius.card)
    }

    private func imagePreview(_ image: UIImage) -> some View {
        VStack(spacing: Spacing.sm) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
                .cornerRadius(Radius.card)

            Button(role: .destructive) {
                selectedImage = nil
            } label: {
                Label("Supprimer", systemImage: "trash")
                    .font(Typography.caption1)
            }
        }
    }

    private func filePreview(_ url: URL) -> some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Image(systemName: DocumentTypeMapper.shared.symbolName(for: url.path))
                    .font(.largeTitle)
                    .foregroundStyle(ColorTokens.actionPrimary)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(url.lastPathComponent)
                        .font(Typography.body)
                        .foregroundColor(ColorTokens.textPrimary)

                    Text(DocumentTypeMapper.shared.displayName(for: url.path))
                        .font(Typography.caption1)
                        .foregroundColor(ColorTokens.textSecondary)
                }

                Spacer()
            }
            .padding(Spacing.md)
            .background(ColorTokens.surface)
            .cornerRadius(Radius.card)

            Button(role: .destructive) {
                selectedFileURL = nil
            } label: {
                Label("Supprimer", systemImage: "trash")
                    .font(Typography.caption1)
            }
        }
    }
}

// MARK: - Camera Picker

struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

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
        let parent: CameraPickerView

        init(_ parent: CameraPickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Image Picker

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Document Picker

struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding var selectedFileURL: URL?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .image, .text], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView

        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.selectedFileURL = url
            }
            parent.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var selectedImage: UIImage?
        @State private var selectedFileURL: URL?

        var body: some View {
            MediaPickerView(
                selectedImage: $selectedImage,
                selectedFileURL: $selectedFileURL
            )
            .padding()
        }
    }

    return PreviewContainer()
}
