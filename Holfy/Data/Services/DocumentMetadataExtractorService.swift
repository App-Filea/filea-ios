//
//  DocumentMetadataExtractorService.swift
//  Invoicer
//
//  Created by Claude Code on 01/02/2026.
//

import Foundation
import Dependencies

/// Service for extracting document metadata from OCR text using intelligent parsing
struct DocumentMetadataExtractorService: Sendable {

    /// Extract metadata from OCR text
    var extract: @Sendable (String) async -> ExtractedDocumentMetadata
}

// MARK: - Dependency Key

extension DocumentMetadataExtractorService: DependencyKey {
    static let liveValue = DocumentMetadataExtractorService(
        extract: { text in
            let extractor = DocumentMetadataExtractor()
            return await extractor.extract(from: text)
        }
    )

    static let testValue = DocumentMetadataExtractorService(
        extract: { _ in
            ExtractedDocumentMetadata(
                detectedType: .maintenance,
                typeConfidence: .high,
                typeScore: 10,
                suggestedName: "Test Document",
                date: Date(),
                amount: 150.0,
                mileage: "50000"
            )
        }
    )
}

// MARK: - Dependency Extension

extension DependencyValues {
    var metadataExtractor: DocumentMetadataExtractorService {
        get { self[DocumentMetadataExtractorService.self] }
        set { self[DocumentMetadataExtractorService.self] = newValue }
    }
}

// MARK: - Document Metadata Extractor Implementation

private actor DocumentMetadataExtractor {

    // MARK: - Keyword Configuration

    /// Keywords and their weights for each document type
    private let typeKeywords: [DocumentType: [(keyword: String, weight: Int)]] = [
        .technicalInspection: [
            // French - Primary keywords
            ("contrôle technique", 10),
            ("controle technique", 10),
            ("visite technique", 8),
            ("procès-verbal", 6),
            ("proces-verbal", 6),
            ("pv de contrôle", 8),
            ("ct ", 5), // Space to avoid false positives
            ("validité", 4),
            ("valable jusqu", 5),
            ("contre-visite", 6),
            // English keywords
            ("technical inspection", 10),
            ("mot ", 8), // Ministry of Transport test
            ("roadworthiness", 8),
            ("vehicle inspection", 7),
            // OCR error tolerant variants
            ("contr0le technique", 8),
            ("controletechnique", 8),
            ("vislte technique", 6),
        ],
        .maintenance: [
            // French - Primary keywords
            ("entretien", 8),
            ("vidange", 10),
            ("révision", 10),
            ("revision", 10),
            ("huile moteur", 8),
            ("filtre", 5),
            ("filtre à huile", 7),
            ("filtre à air", 7),
            ("niveau", 3),
            ("points de contrôle", 5),
            ("carnet d'entretien", 8),
            ("forfait entretien", 9),
            ("service", 4),
            // English keywords
            ("maintenance", 8),
            ("oil change", 10),
            ("service", 6),
            ("filter", 5),
            ("oil filter", 7),
            ("air filter", 7),
            ("scheduled service", 8),
            // OCR error tolerant variants
            ("entretion", 6),
            ("entretein", 6),
            ("vldange", 8),
            ("v1dange", 8),
            ("revislon", 8),
        ],
        .repair: [
            // French - Primary keywords
            ("réparation", 10),
            ("reparation", 10),
            ("panne", 8),
            ("accident", 10),
            ("sinistre", 8),
            ("carrosserie", 8),
            ("dépannage", 7),
            ("depannage", 7),
            ("remplacement", 5),
            ("devis", 4),
            ("diagnostic", 5),
            ("main d'oeuvre", 4),
            ("pièces détachées", 5),
            // English keywords
            ("repair", 10),
            ("breakdown", 8),
            ("damage", 8),
            ("bodywork", 6),
            ("collision", 9),
            ("parts replacement", 6),
            // OCR error tolerant variants
            ("réparati0n", 8),
            ("reparati0n", 8),
            ("reparatlon", 8),
            ("accldent", 8),
        ],
        .other: []
    ]

    // MARK: - Main Extraction Method

    func extract(from text: String) async -> ExtractedDocumentMetadata {
        print("🔍 [MetadataExtractor] Starting extraction")
        print("   ├─ Text length: \(text.count) characters")

        // Detect document type with scoring
        let (detectedType, score) = detectType(from: text)
        let confidence = calculateConfidence(score: score)

        print("   ├─ Detected type: \(detectedType.displayName)")
        print("   ├─ Score: \(score)")
        print("   └─ Confidence: \(confidence.displayName)")

        // Extract other metadata fields
        let extractedDate = extractDate(from: text)
        let extractedAmount = extractAmount(from: text)
        let extractedMileage = extractMileage(from: text)
        let extractedExpirationDate = detectedType == .technicalInspection
            ? extractExpirationDate(from: text, documentDate: extractedDate)
            : nil

        // Generate suggested name
        let suggestedName = generateSuggestedName(
            type: detectedType,
            date: extractedDate
        )

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"

        print("✅ [MetadataExtractor] Extraction complete")
        print("   ├─ Type: \(detectedType.displayName) (score: \(score), confidence: \(confidence.displayName))")
        if let date = extractedDate {
            print("   ├─ Date: \(dateFormatter.string(from: date))")
        } else {
            print("   ├─ Date: non détectée")
        }
        if let amount = extractedAmount {
            print("   ├─ Montant: \(String(format: "%.2f", amount)) €")
        } else {
            print("   ├─ Montant: non détecté")
        }
        if let mileage = extractedMileage {
            print("   ├─ Kilométrage: \(mileage) km")
        } else {
            print("   ├─ Kilométrage: non détecté")
        }
        if let expiration = extractedExpirationDate {
            print("   ├─ Expiration: \(dateFormatter.string(from: expiration))")
        }
        if let name = suggestedName {
            print("   └─ Nom suggéré: \(name)")
        }
        print("")

        return ExtractedDocumentMetadata(
            detectedType: detectedType,
            typeConfidence: confidence,
            typeScore: score,
            suggestedName: suggestedName,
            date: extractedDate,
            amount: extractedAmount,
            mileage: extractedMileage,
            expirationDate: extractedExpirationDate,
            rawText: text
        )
    }

    // MARK: - Type Detection

    private func detectType(from text: String) -> (DocumentType, Int) {
        var scores: [DocumentType: Int] = [:]

        // Calculate score for each document type
        for type in DocumentType.allCases where type != .other {
            scores[type] = calculateScore(text: text, for: type)
        }

        // Find the type with the highest score
        if let best = scores.max(by: { $0.value < $1.value }), best.value >= 3 {
            return (best.key, best.value)
        }

        // Default to .other with score 0
        return (.other, 0)
    }

    private func calculateScore(text: String, for type: DocumentType) -> Int {
        guard let keywords = typeKeywords[type] else { return 0 }

        let normalizedText = normalizeText(text)
        var totalScore = 0

        for (keyword, weight) in keywords {
            let normalizedKeyword = normalizeText(keyword)
            if normalizedText.contains(normalizedKeyword) {
                totalScore += weight
            }
        }

        return totalScore
    }

    private func normalizeText(_ text: String) -> String {
        text.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
    }

    private func calculateConfidence(score: Int) -> ExtractionConfidence {
        switch score {
        case 8...: return .high
        case 5..<8: return .medium
        default: return .low
        }
    }

    // MARK: - Date Extraction

    private func extractDate(from text: String) -> Date? {
        // Date patterns to match
        let patterns = [
            // DD/MM/YYYY or DD-MM-YYYY or DD.MM.YYYY
            "\\b(\\d{1,2})[/\\-\\.](\\d{1,2})[/\\-\\.](\\d{4})\\b",
            // YYYY-MM-DD (ISO format)
            "\\b(\\d{4})[/\\-\\.](\\d{1,2})[/\\-\\.](\\d{1,2})\\b",
        ]

        var dates: [(date: Date, position: Int)] = []
        let calendar = Calendar.current
        let today = Date()

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }

            let range = NSRange(text.startIndex..., in: text)
            let matches = regex.matches(in: text, options: [], range: range)

            for match in matches {
                guard match.numberOfRanges >= 4 else { continue }

                let comp1 = extractSubstring(from: text, range: match.range(at: 1))
                let comp2 = extractSubstring(from: text, range: match.range(at: 2))
                let comp3 = extractSubstring(from: text, range: match.range(at: 3))

                guard let c1 = Int(comp1), let c2 = Int(comp2), let c3 = Int(comp3) else { continue }

                var dateComponents = DateComponents()

                // Determine format based on component values
                if c1 > 31 {
                    // YYYY-MM-DD format
                    dateComponents.year = c1
                    dateComponents.month = c2
                    dateComponents.day = c3
                } else {
                    // DD/MM/YYYY format
                    dateComponents.day = c1
                    dateComponents.month = c2
                    dateComponents.year = c3
                }

                // Validate and create date
                if let date = calendar.date(from: dateComponents),
                   date <= today {
                    dates.append((date, match.range.location))
                }
            }
        }

        // Return the most recent valid date
        return dates
            .sorted { $0.date > $1.date }
            .first?.date
    }

    // MARK: - Expiration Date Extraction

    private func extractExpirationDate(from text: String, documentDate: Date?) -> Date? {
        let normalizedText = text.lowercased()

        // Look for expiration context keywords
        let expirationContexts = [
            "valable jusqu",
            "valide jusqu",
            "expire le",
            "date limite",
            "échéance",
            "prochaine visite",
            "valid until",
            "expires"
        ]

        // Check if any expiration context exists
        let hasExpirationContext = expirationContexts.contains { normalizedText.contains($0) }

        // Date patterns
        let pattern = "\\b(\\d{1,2})[/\\-\\.](\\d{1,2})[/\\-\\.](\\d{4})\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }

        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, options: [], range: range)

        var futureDates: [Date] = []
        let calendar = Calendar.current
        let today = Date()

        for match in matches {
            guard match.numberOfRanges >= 4 else { continue }

            let dayStr = extractSubstring(from: text, range: match.range(at: 1))
            let monthStr = extractSubstring(from: text, range: match.range(at: 2))
            let yearStr = extractSubstring(from: text, range: match.range(at: 3))

            guard let day = Int(dayStr), let month = Int(monthStr), let year = Int(yearStr) else { continue }

            var dateComponents = DateComponents()
            dateComponents.day = day
            dateComponents.month = month
            dateComponents.year = year

            if let date = calendar.date(from: dateComponents), date > today {
                futureDates.append(date)
            }
        }

        // If we have expiration context and future dates, return the earliest future date
        if hasExpirationContext, let earliest = futureDates.min() {
            return earliest
        }

        // Default: If document date exists and type is CT, default to +2 years
        if let docDate = documentDate {
            return calendar.date(byAdding: .year, value: 2, to: docDate)
        }

        return nil
    }

    // MARK: - Amount Extraction

    private func extractAmount(from text: String) -> Double? {
        // Patterns for amounts with currency symbols or keywords
        let patterns = [
            // TTC amounts (priority)
            "(?:ttc|total\\s*ttc|montant\\s*ttc|net\\s*[àa]\\s*payer|total\\s*[àa]\\s*payer)[^0-9]*([0-9]+[\\s,\\.][0-9]{2})",
            "([0-9]+[\\s,\\.][0-9]{2})[^0-9]*(?:€|eur|euro)",
            // TOTAL keyword
            "(?:total)[^0-9]*([0-9]+[\\s,\\.][0-9]{2})",
            // Generic amount pattern
            "([0-9]+[\\s,\\.][0-9]{2})\\s*(?:€|eur|euro|\\$|usd)",
        ]

        var amounts: [(amount: Double, priority: Int)] = []

        for (index, pattern) in patterns.enumerated() {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { continue }

            let range = NSRange(text.startIndex..., in: text)
            let matches = regex.matches(in: text, options: [], range: range)

            for match in matches {
                guard match.numberOfRanges >= 2 else { continue }

                var amountStr = extractSubstring(from: text, range: match.range(at: 1))
                // Normalize: replace comma with dot, remove spaces
                amountStr = amountStr
                    .replacingOccurrences(of: ",", with: ".")
                    .replacingOccurrences(of: " ", with: "")

                if let amount = Double(amountStr), amount > 0 && amount < 100000 {
                    amounts.append((amount, index))
                }
            }
        }

        // Return the amount with highest priority (lowest index) and highest value
        return amounts
            .sorted { ($0.priority, -$0.amount) < ($1.priority, -$1.amount) }
            .first?.amount
    }

    // MARK: - Mileage Extraction

    private func extractMileage(from text: String) -> String? {
        // Patterns for mileage
        let patterns = [
            // With explicit keyword
            "(?:kilom[eé]trage|km|mileage|odometer)[^0-9]*([0-9][0-9\\s]{2,})",
            // Number followed by km/miles unit
            "([0-9][0-9\\s]{2,})\\s*(?:km|kms|kilometres|kilometers|miles|mi)\\b",
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { continue }

            let range = NSRange(text.startIndex..., in: text)
            if let match = regex.firstMatch(in: text, options: [], range: range),
               match.numberOfRanges >= 2 {

                var mileageStr = extractSubstring(from: text, range: match.range(at: 1))
                // Remove spaces from number
                mileageStr = mileageStr.replacingOccurrences(of: " ", with: "")

                // Validate: should be a reasonable mileage (1000 - 999999)
                if let mileage = Int(mileageStr), mileage >= 1000 && mileage <= 999999 {
                    return mileageStr
                }
            }
        }

        return nil
    }

    // MARK: - Suggested Name Generation

    private func generateSuggestedName(type: DocumentType, date: Date?) -> String? {
        let typeName = type.displayName

        guard let date = date else {
            return typeName
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: date)

        return "\(typeName) \(dateString)"
    }

    // MARK: - Helper Methods

    private func extractSubstring(from text: String, range: NSRange) -> String {
        guard let swiftRange = Range(range, in: text) else { return "" }
        return String(text[swiftRange])
    }
}
