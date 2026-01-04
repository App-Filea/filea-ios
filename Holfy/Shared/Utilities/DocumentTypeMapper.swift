//
//  DocumentTypeMapper.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Utility for mapping document types and file extensions
//

import Foundation

/// Utility for handling document type classifications and mappings
final class DocumentTypeMapper: @unchecked Sendable {
    // MARK: - Singleton

    static let shared = DocumentTypeMapper()

    private init() {}

    // MARK: - File Type Detection

    /// Returns the file type category for a given file URL
    func fileType(for fileURL: String) -> FileType {
        let url = URL(fileURLWithPath: fileURL)
        let pathExtension = url.pathExtension.lowercased()

        if imageExtensions.contains(pathExtension) {
            return .image
        } else if pdfExtensions.contains(pathExtension) {
            return .pdf
        } else if documentExtensions.contains(pathExtension) {
            return .document
        } else {
            return .other
        }
    }

    /// Checks if the file URL represents an image
    func isImage(_ fileURL: String) -> Bool {
        fileType(for: fileURL) == .image
    }

    /// Checks if the file URL represents a PDF
    func isPDF(_ fileURL: String) -> Bool {
        fileType(for: fileURL) == .pdf
    }

    /// Checks if the file URL represents a document
    func isDocument(_ fileURL: String) -> Bool {
        fileType(for: fileURL) == .document
    }

    /// Returns a human-readable display name for the file type
    func displayName(for fileURL: String) -> String {
        fileType(for: fileURL).displayName
    }

    /// Returns the SF Symbol name for the file type
    func symbolName(for fileURL: String) -> String {
        fileType(for: fileURL).symbolName
    }

    // MARK: - File Extensions

    private let imageExtensions: Set<String> = [
        "jpg", "jpeg", "png", "gif", "bmp", "tiff", "heic", "heif", "webp"
    ]

    private let pdfExtensions: Set<String> = [
        "pdf"
    ]

    private let documentExtensions: Set<String> = [
        "doc", "docx", "txt", "rtf", "pages", "xls", "xlsx", "numbers",
        "ppt", "pptx", "key", "csv"
    ]

    /// Returns all supported image extensions
    var supportedImageExtensions: [String] {
        Array(imageExtensions).sorted()
    }

    /// Returns all supported document extensions
    var supportedDocumentExtensions: [String] {
        Array(documentExtensions.union(pdfExtensions)).sorted()
    }

    /// Returns all supported extensions
    var supportedExtensions: [String] {
        Array(imageExtensions.union(pdfExtensions).union(documentExtensions)).sorted()
    }

    // MARK: - Category Keywords

    private let administrativeKeywords = [
        "carte grise", "assurance", "contrôle", "controle", "immatriculation"
    ]

    private let maintenanceKeywords = [
        "entretien", "vidange", "révision", "revision"
    ]

    private let repairKeywords = [
        "réparation", "reparation", "panne", "accident"
    ]

    private let fuelKeywords = [
        "carburant", "essence", "diesel", "gazole"
    ]

    // MARK: - MIME Types

    private let mimeTypes: [String: String] = [
        // Images
        "jpg": "image/jpeg",
        "jpeg": "image/jpeg",
        "png": "image/png",
        "gif": "image/gif",
        "bmp": "image/bmp",
        "tiff": "image/tiff",
        "heic": "image/heic",
        "heif": "image/heif",
        "webp": "image/webp",

        // PDF
        "pdf": "application/pdf",

        // Documents
        "doc": "application/msword",
        "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "txt": "text/plain",
        "rtf": "application/rtf",
        "xls": "application/vnd.ms-excel",
        "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "ppt": "application/vnd.ms-powerpoint",
        "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        "csv": "text/csv"
    ]
}

// MARK: - File Type Enum

extension DocumentTypeMapper {
    enum FileType: String {
        case image = "Photo"
        case pdf = "PDF"
        case document = "Document"
        case other = "Fichier"

        var displayName: String {
            rawValue
        }

        var symbolName: String {
            switch self {
            case .image:
                return "photo"
            case .pdf:
                return "doc.richtext"
            case .document:
                return "doc.text"
            case .other:
                return "doc"
            }
        }
    }
}

// MARK: - Document Category Helpers

extension DocumentTypeMapper {
    /// Returns a color-coded category for document types
    func category(for documentType: String) -> DocumentCategory {
        let lowercased = documentType.lowercased()

        if administrativeKeywords.contains(where: { lowercased.contains($0) }) {
            return .administrative
        } else if maintenanceKeywords.contains(where: { lowercased.contains($0) }) {
            return .maintenance
        } else if repairKeywords.contains(where: { lowercased.contains($0) }) {
            return .repair
        } else if fuelKeywords.contains(where: { lowercased.contains($0) }) {
            return .fuel
        } else {
            return .other
        }
    }
}

// MARK: - Document Category Enum

extension DocumentTypeMapper {
    enum DocumentCategory: String {
        case administrative = "Administratif"
        case maintenance = "Entretien"
        case repair = "Réparation"
        case fuel = "Carburant"
        case other = "Autres"

        var displayName: String {
            rawValue
        }

        var symbolName: String {
            switch self {
            case .administrative:
                return "doc.text"
            case .maintenance:
                return "wrench.and.screwdriver"
            case .repair:
                return "exclamationmark.triangle"
            case .fuel:
                return "fuelpump"
            case .other:
                return "folder"
            }
        }
    }
}

// MARK: - MIME Type Support

extension DocumentTypeMapper {
    /// Returns the MIME type for a given file extension
    func mimeType(for fileURL: String) -> String {
        let url = URL(fileURLWithPath: fileURL)
        let pathExtension = url.pathExtension.lowercased()

        return mimeTypes[pathExtension] ?? "application/octet-stream"
    }
}
