//
//  DocumentParserService.swift
//  Invoicer
//
//  Created by Claude Code on 20/10/2025.
//

import Foundation
import Dependencies

/// Service de parsing intelligent du texte OCR selon le type de document
struct DocumentParserService: Sendable {

    /// Parse le texte OCR selon le mode de scan
    var parse: @Sendable (String, ScanMode) -> ScannedVehicleData
}

// MARK: - Dependency Key

extension DocumentParserService: DependencyKey {
    static let liveValue = DocumentParserService(
        parse: { text, mode in
            print("📄 [DocumentParser] Parsing OCR text for mode: \(mode.displayName)")
            print("   ├─ Text length: \(text.count) characters")

            switch mode {
            case .registrationCard:
                return Self.parseRegistrationCard(text: text)
            case .invoice:
                return Self.parseInvoice(text: text)
            case .receipt:
                return Self.parseReceipt(text: text)
            }
        }
    )

    // MARK: - Carte Grise Parser

    /// Parse une carte grise française
    private static func parseRegistrationCard(text: String) -> ScannedVehicleData {
        print("📋 [DocumentParser] Parsing carte grise française")

        var data = ScannedVehicleData(
            confidence: .low,
            sourceDocument: .registrationCard
        )

        let lines = text.components(separatedBy: .newlines)

        // Champ A : Plaque d'immatriculation (format AA-123-AA ou 1234 AB 12)
        let platePatterns = [
            "[A-Z]{2}-\\d{3}-[A-Z]{2}",        // Format nouveau : AB-123-CD
            "\\d{1,4}\\s*[A-Z]{2,3}\\s*\\d{2}" // Format ancien : 1234 AB 12
        ]

        for pattern in platePatterns {
            if let plate = Self.extractPattern(pattern, from: text, label: "Plaque") {
                data.plate = plate.uppercased().replacingOccurrences(of: " ", with: "-")
                print("   ├─ ✅ Plaque détectée: \(data.plate!)")
                break
            }
        }

        // Champ B : Date de première immatriculation
        if let dateString = Self.extractDate(from: text, near: "B") {
            data.registrationDate = Self.parseDate(dateString)
            print("   ├─ ✅ Date détectée: \(dateString)")
        }

        // Champ D.1 : Marque
        if let brand = Self.extractField(label: "D\\.1", from: lines) {
            data.brand = brand.uppercased()
            print("   ├─ ✅ Marque détectée: \(data.brand!)")
        }

        // Champ D.3 : Modèle (version commerciale)
        if let model = Self.extractField(label: "D\\.3", from: lines) {
            data.model = model.uppercased()
            print("   ├─ ✅ Modèle détecté: \(data.model!)")
        }

        // Calculer le niveau de confiance
        data.confidence = Self.calculateConfidence(for: data)
        print("   └─ Confiance: \(data.confidence.rawValue) (\(data.filledFieldsCount)/4 champs)\n")

        return data
    }

    // MARK: - Invoice Parser

    /// Parse une facture de garage
    private static func parseInvoice(text: String) -> ScannedVehicleData {
        print("📄 [DocumentParser] Parsing facture garage")

        var data = ScannedVehicleData(
            confidence: .low,
            sourceDocument: .invoice
        )

        // Recherche de plaque d'immatriculation
        let platePattern = "[A-Z]{2}-\\d{3}-[A-Z]{2}"
        if let plate = Self.extractPattern(platePattern, from: text, label: "Plaque") {
            data.plate = plate.uppercased()
            print("   ├─ ✅ Plaque détectée: \(data.plate!)")
        }

        // Recherche de marques automobiles courantes
        let commonBrands = [
            "RENAULT", "PEUGEOT", "CITROEN", "CITROËN", "TOYOTA", "BMW", "MERCEDES",
            "VOLKSWAGEN", "AUDI", "FORD", "OPEL", "NISSAN", "HONDA", "HYUNDAI",
            "KIA", "MAZDA", "SEAT", "SKODA", "VOLVO", "FIAT", "ALFA ROMEO",
            "MINI", "JEEP", "LAND ROVER", "PORSCHE", "TESLA", "DACIA"
        ]

        let upperText = text.uppercased()
        for brand in commonBrands {
            if upperText.contains(brand) {
                data.brand = brand
                print("   ├─ ✅ Marque détectée: \(brand)")
                break
            }
        }

        // Recherche de date
        if let dateString = Self.extractDate(from: text, near: nil) {
            data.registrationDate = Self.parseDate(dateString)
            print("   ├─ ✅ Date détectée: \(dateString)")
        }

        data.confidence = Self.calculateConfidence(for: data)
        print("   └─ Confiance: \(data.confidence.rawValue) (\(data.filledFieldsCount)/4 champs)\n")

        return data
    }

    // MARK: - Receipt Parser

    /// Parse un ticket de carte bancaire
    private static func parseReceipt(text: String) -> ScannedVehicleData {
        print("🧾 [DocumentParser] Parsing ticket CB")

        var data = ScannedVehicleData(
            confidence: .low,
            sourceDocument: .receipt
        )

        // Extraction de date
        if let dateString = Self.extractDate(from: text, near: nil) {
            data.registrationDate = Self.parseDate(dateString)
            print("   ├─ ✅ Date détectée: \(dateString)")
        }

        data.confidence = Self.calculateConfidence(for: data)
        print("   └─ Confiance: \(data.confidence.rawValue) (\(data.filledFieldsCount)/4 champs)\n")

        return data
    }

    // MARK: - Helper Methods

    /// Extrait un pattern regex du texte
    private static func extractPattern(_ pattern: String, from text: String, label: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }

        let range = NSRange(text.startIndex..., in: text)
        if let match = regex.firstMatch(in: text, options: [], range: range),
           let matchRange = Range(match.range, in: text) {
            return String(text[matchRange])
        }

        return nil
    }

    /// Extrait un champ de carte grise (ex: "D.1 RENAULT")
    private static func extractField(label: String, from lines: [String]) -> String? {
        let pattern = "\(label)\\s*[:\\-]?\\s*([A-Z0-9À-ÿ\\s]+)"

        for line in lines {
            if let value = Self.extractPattern(pattern, from: line, label: label) {
                // Nettoyer le résultat
                let cleaned = value
                    .replacingOccurrences(of: label, with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: ":", with: "")
                    .replacingOccurrences(of: "-", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if !cleaned.isEmpty {
                    return cleaned
                }
            }
        }

        return nil
    }

    /// Extrait une date du texte (formats DD/MM/YYYY, DD-MM-YYYY, etc.)
    private static func extractDate(from text: String, near keyword: String?) -> String? {
        let datePattern = "\\d{1,2}[/\\-\\.:]\\d{1,2}[/\\-\\.:]\\d{2,4}"

        if let keyword = keyword {
            // Chercher près du mot-clé
            let lines = text.components(separatedBy: .newlines)
            for line in lines {
                if line.contains(keyword),
                   let date = Self.extractPattern(datePattern, from: line, label: "Date") {
                    return date
                }
            }
        }

        // Chercher partout
        return Self.extractPattern(datePattern, from: text, label: "Date")
    }

    /// Parse une date string en Date
    private static func parseDate(_ dateString: String) -> Date? {
        let formatters: [DateFormatter] = {
            let formats = ["dd/MM/yyyy", "dd-MM-yyyy", "dd.MM.yyyy", "dd/MM/yy"]
            return formats.map { format in
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale(identifier: "fr_FR")
                return formatter
            }
        }()

        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        return nil
    }

    /// Calcule le niveau de confiance basé sur le nombre de champs détectés
    private static func calculateConfidence(for data: ScannedVehicleData) -> ScannedVehicleData.ScanConfidence {
        let filledCount = data.filledFieldsCount
        let totalFields = 4.0 // brand, model, plate, date

        let percentage = Double(filledCount) / totalFields

        if percentage >= 0.75 {
            return .high
        } else if percentage >= 0.5 {
            return .medium
        } else {
            return .low
        }
    }
}

// MARK: - Test/Preview Values

extension DocumentParserService {
    static let testValue = DocumentParserService(
        parse: { text, mode in
            ScannedVehicleData(
                brand: "TOYOTA",
                model: "COROLLA",
                plate: "AB-123-CD",
                registrationDate: Date(),
                confidence: .high,
                sourceDocument: mode
            )
        }
    )

    static let previewValue = testValue
}

// MARK: - Dependency Extension

extension DependencyValues {
    var documentParser: DocumentParserService {
        get { self[DocumentParserService.self] }
        set { self[DocumentParserService.self] = newValue }
    }
}
