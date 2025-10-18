//
//  DocumentPickerView.swift
//  Invoicer
//
//  Created by Claude on 2025-01-18.
//  SwiftUI wrapper for UIDocumentPickerViewController
//

import SwiftUI
import UniformTypeIdentifiers

/// A SwiftUI view that presents UIDocumentPickerViewController for directory selection
struct DocumentPickerView: UIViewControllerRepresentable {

    /// Binding to control whether the picker is presented
    @Binding var isPresented: Bool

    /// Closure called when a folder is selected
    let onFolderSelected: (URL) -> Void

    /// Closure called when the picker is cancelled
    let onCancel: () -> Void

    // MARK: - UIViewControllerRepresentable

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Create a document picker configured for directory selection
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])

        // Allow the user to select a directory
        picker.directoryURL = nil
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
            isPresented: $isPresented,
            onFolderSelected: onFolderSelected,
            onCancel: onCancel
        )
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        @Binding var isPresented: Bool
        let onFolderSelected: (URL) -> Void
        let onCancel: () -> Void

        init(
            isPresented: Binding<Bool>,
            onFolderSelected: @escaping (URL) -> Void,
            onCancel: @escaping () -> Void
        ) {
            self._isPresented = isPresented
            self.onFolderSelected = onFolderSelected
            self.onCancel = onCancel
        }

        // MARK: - UIDocumentPickerDelegate

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                isPresented = false
                onCancel()
                return
            }

            // Call the completion handler with the selected URL
            onFolderSelected(url)
            isPresented = false
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            isPresented = false
            onCancel()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DocumentPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Document Picker Preview")
            .sheet(isPresented: .constant(true)) {
                DocumentPickerView(
                    isPresented: .constant(true),
                    onFolderSelected: { url in
                        print("Selected folder: \(url)")
                    },
                    onCancel: {
                        print("Cancelled")
                    }
                )
            }
    }
}
#endif
