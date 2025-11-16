//
//  DocumentFilePickerView.swift
//  Invoicer
//
//  Created by Claude Code on 16/11/2025.
//  SwiftUI wrapper for UIDocumentPickerViewController for file selection
//

import SwiftUI
import UniformTypeIdentifiers

/// A SwiftUI view that presents UIDocumentPickerViewController for document file selection
struct DocumentFilePickerView: UIViewControllerRepresentable {

    /// Closure called when a file is selected
    let onFileSelected: (URL) -> Void

    /// Closure called when the picker is cancelled
    let onCancel: () -> Void

    // MARK: - UIViewControllerRepresentable

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Create a document picker configured for image and PDF files
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.image, .pdf],
            asCopy: true
        )

        // Configuration
        picker.shouldShowFileExtensions = true
        picker.allowsMultipleSelection = false

        // Set the delegate
        picker.delegate = context.coordinator

        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onFileSelected: onFileSelected,
            onCancel: onCancel
        )
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onFileSelected: (URL) -> Void
        let onCancel: () -> Void

        init(
            onFileSelected: @escaping (URL) -> Void,
            onCancel: @escaping () -> Void
        ) {
            self.onFileSelected = onFileSelected
            self.onCancel = onCancel
        }

        // MARK: - UIDocumentPickerDelegate

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                print("❌ [DocumentFilePickerView] Aucun fichier sélectionné")
                onCancel()
                return
            }

            print("📄 [DocumentFilePickerView] Fichier sélectionné: \(url.lastPathComponent)")
            onFileSelected(url)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("❌ [DocumentFilePickerView] Picker annulé")
            onCancel()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DocumentFilePickerView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Document Picker Preview")
            .sheet(isPresented: .constant(true)) {
                DocumentFilePickerView(
                    onFileSelected: { url in
                        print("Selected file: \(url)")
                    },
                    onCancel: {
                        print("Cancelled")
                    }
                )
            }
    }
}
#endif
