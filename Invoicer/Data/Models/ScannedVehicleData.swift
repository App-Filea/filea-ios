//
//  ScannedVehicleData.swift
//  Invoicer
//
//  Created by Claude Code on 20/10/2025.
//

import Foundation

/// Données extraites d'un scan OCR de document automobile
struct ScannedVehicleData: Equatable, Sendable {
    var brand: String?
    var model: String?
    var plate: String?
    var registrationDate: Date?
    var confidence: ScanConfidence
    var sourceDocument: ScanMode

    /// Niveau de confiance de la détection
    enum ScanConfidence: String, Codable, Equatable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"

        var displayName: String {
            switch self {
            case .high: return "Élevée"
            case .medium: return "Moyenne"
            case .low: return "Faible"
            }
        }
    }

    /// Vérifie si au moins un champ a été détecté
    var hasData: Bool {
        brand != nil || model != nil || plate != nil || registrationDate != nil
    }

    /// Compte le nombre de champs remplis
    var filledFieldsCount: Int {
        var count = 0
        if brand != nil { count += 1 }
        if model != nil { count += 1 }
        if plate != nil { count += 1 }
        if registrationDate != nil { count += 1 }
        return count
    }
}
