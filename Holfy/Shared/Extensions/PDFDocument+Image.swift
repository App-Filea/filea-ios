//
//  PDFDocument+Image.swift
//  Invoicer
//
//  Created by Claude Code on 16/11/2025.
//

import PDFKit
import UIKit

extension PDFDocument {

    /// Converts the first page of the PDF to a UIImage
    /// - Parameter scale: The scale factor for rendering (default: 2.0 for Retina)
    /// - Returns: UIImage of the first page, or nil if conversion fails
    func imageOfFirstPage(scale: CGFloat = 2.0) -> UIImage? {
        // Check if PDF has at least one page
        guard pageCount > 0 else {
            print("❌ [PDFDocument+Image] PDF has no pages")
            return nil
        }

        // Get the first page
        guard let page = page(at: 0) else {
            print("❌ [PDFDocument+Image] Cannot get first page")
            return nil
        }

        print("📄 [PDFDocument+Image] Converting PDF page to image")
        print("   ├─ Page count: \(pageCount)")

        // Get the page bounds
        let pageRect = page.bounds(for: .mediaBox)
        print("   ├─ Page size: \(pageRect.size.width) x \(pageRect.size.height)")

        // Create a renderer with proper scale
        let renderer = UIGraphicsImageRenderer(
            size: pageRect.size,
            format: UIGraphicsImageRendererFormat().apply {
                $0.scale = scale
            }
        )

        // Render the page
        let image = renderer.image { context in
            // Fill background with white
            UIColor.white.set()
            context.fill(pageRect)

            // Transform coordinate system for PDF rendering
            context.cgContext.translateBy(x: 0, y: pageRect.size.height)
            context.cgContext.scaleBy(x: 1.0, y: -1.0)

            // Draw the PDF page
            page.draw(with: .mediaBox, to: context.cgContext)
        }

        print("✅ [PDFDocument+Image] Image created: \(image.size.width) x \(image.size.height) @ \(image.scale)x")

        return image
    }
}

// MARK: - UIGraphicsImageRendererFormat Extension

private extension UIGraphicsImageRendererFormat {
    func apply(_ configure: (UIGraphicsImageRendererFormat) -> Void) -> UIGraphicsImageRendererFormat {
        configure(self)
        return self
    }
}
