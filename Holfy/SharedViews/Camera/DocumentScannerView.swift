//
//  DocumentScannerView.swift
//  Invoicer
//
//  Created by Claude Code on 24/10/2025.
//

import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {

    // MARK: - Properties

    let onFinish: (VNDocumentCameraScan) -> Void
    let onCancel: () -> Void
    let onError: (Error) -> Void

    // MARK: - UIViewControllerRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onFinish: onFinish,
            onCancel: onCancel,
            onError: onError
        )
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // No updates needed
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onFinish: (VNDocumentCameraScan) -> Void
        let onCancel: () -> Void
        let onError: (Error) -> Void

        init(
            onFinish: @escaping (VNDocumentCameraScan) -> Void,
            onCancel: @escaping () -> Void,
            onError: @escaping (Error) -> Void
        ) {
            self.onFinish = onFinish
            self.onCancel = onCancel
            self.onError = onError
        }

        // MARK: - VNDocumentCameraViewControllerDelegate

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            print("✅ [DocumentScannerView] Document scanned successfully")
            print("   └─ Pages: \(scan.pageCount)")
            onFinish(scan)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            print("❌ [DocumentScannerView] Scan cancelled by user")
            onCancel()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("❌ [DocumentScannerView] Scan failed: \(error.localizedDescription)")
            onError(error)
        }
    }
}
