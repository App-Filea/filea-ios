//
//  DocumentPreview.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 08/10/2025.
//

import SwiftUI
import PDFKit

struct DocumentPreview: View {
    let fileURL: URL
    let fileName: String

    @State private var previewImage: UIImage?
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            if isLoading {
                ProgressView()
                    .frame(height: 400)
            } else if let image = previewImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 400)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("outline"), lineWidth: 2)
                    )
            } else {
                // Fallback si impossible de charger la preview
                VStack(spacing: 12) {
                    Image(systemName: iconForFile(fileName))
                        .font(.system(size: 60))
                        .foregroundStyle(Color("primary"))

                    Text(fileName)
                        .bodyDefaultSemibold()
                        .foregroundStyle(Color("onSurface"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text(fileTypeDescription(fileName))
                        .bodySmallRegular()
                        .foregroundStyle(Color("onBackgroundSecondary"))
                }
                .padding()
                .frame(height: 400)
                .frame(maxWidth: .infinity)
                .background(Color("surface"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("outline"), lineWidth: 2)
                )
            }
        }
        .onAppear {
            loadPreview()
        }
    }

    private func loadPreview() {
        Task {
            // Accéder au fichier sécurisé
            let accessing = fileURL.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    fileURL.stopAccessingSecurityScopedResource()
                }
            }

            let ext = (fileName as NSString).pathExtension.lowercased()

            // Essayer de charger selon le type
            if ["jpg", "jpeg", "png", "heic"].contains(ext) {
                // Charger l'image
                if let data = try? Data(contentsOf: fileURL),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        previewImage = image
                        isLoading = false
                    }
                } else {
                    await MainActor.run {
                        isLoading = false
                    }
                }
            } else if ext == "pdf" {
                // Charger la première page du PDF
                if let pdfDocument = PDFDocument(url: fileURL),
                   let page = pdfDocument.page(at: 0) {
                    let pageRect = page.bounds(for: .mediaBox)
                    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                    let image = renderer.image { context in
                        UIColor.white.set()
                        context.fill(pageRect)
                        context.cgContext.translateBy(x: 0, y: pageRect.size.height)
                        context.cgContext.scaleBy(x: 1.0, y: -1.0)
                        page.draw(with: .mediaBox, to: context.cgContext)
                    }
                    await MainActor.run {
                        previewImage = image
                        isLoading = false
                    }
                } else {
                    await MainActor.run {
                        isLoading = false
                    }
                }
            } else {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }

    private func iconForFile(_ fileName: String) -> String {
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf":
            return "doc.fill"
        case "jpg", "jpeg", "png", "heic":
            return "photo.fill"
        case "txt":
            return "doc.text.fill"
        default:
            return "doc.fill"
        }
    }

    private func fileTypeDescription(_ fileName: String) -> String {
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf":
            return "Document PDF"
        case "jpg", "jpeg":
            return "Image JPEG"
        case "png":
            return "Image PNG"
        case "heic":
            return "Image HEIC"
        case "txt":
            return "Fichier texte"
        default:
            return "Document"
        }
    }
}
