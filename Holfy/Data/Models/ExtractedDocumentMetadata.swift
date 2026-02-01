//
//  ExtractedDocumentMetadata.swift
//  Invoicer
//
//  Created by Claude Code on 01/02/2026.
//

import Foundation

/// Confidence level of the metadata extraction
enum ExtractionConfidence: String, Equatable, Sendable {
    case high       // Score >= 8 - Very confident
    case medium     // Score 5-7 - Reasonably confident
    case low        // Score < 5 - Low confidence, may need user validation

    var displayName: String {
        switch self {
        case .high: return "Élevée"
        case .medium: return "Moyenne"
        case .low: return "Faible"
        }
    }
}

/// Result of OCR metadata extraction from a document
struct ExtractedDocumentMetadata: Equatable, Sendable {
    /// The detected document type based on keywords analysis
    let detectedType: DocumentType

    /// Confidence level of the type detection
    let typeConfidence: ExtractionConfidence

    /// Detection score for the type (higher = more confident)
    let typeScore: Int

    /// Suggested name for the document (e.g., "Contrôle technique 15/01/2025")
    let suggestedName: String?

    /// Extracted date from the document
    let date: Date?

    /// Extracted amount from the document (TTC)
    let amount: Double?

    /// Extracted mileage from the document
    let mileage: String?

    /// Extracted expiration date (for technical inspection)
    let expirationDate: Date?

    /// The raw OCR text for debugging purposes
    let rawText: String

    init(
        detectedType: DocumentType,
        typeConfidence: ExtractionConfidence,
        typeScore: Int,
        suggestedName: String? = nil,
        date: Date? = nil,
        amount: Double? = nil,
        mileage: String? = nil,
        expirationDate: Date? = nil,
        rawText: String = ""
    ) {
        self.detectedType = detectedType
        self.typeConfidence = typeConfidence
        self.typeScore = typeScore
        self.suggestedName = suggestedName
        self.date = date
        self.amount = amount
        self.mileage = mileage
        self.expirationDate = expirationDate
        self.rawText = rawText
    }

    /// Creates an empty metadata result when extraction fails
    static func empty(rawText: String = "") -> ExtractedDocumentMetadata {
        ExtractedDocumentMetadata(
            detectedType: .other,
            typeConfidence: .low,
            typeScore: 0,
            rawText: rawText
        )
    }
}
