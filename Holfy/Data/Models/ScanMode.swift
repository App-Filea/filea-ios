//
//  ScanMode.swift
//  Invoicer
//
//  Created by Claude Code on 20/10/2025.
//

import Foundation

/// Types de documents scannables pour extraction de données véhicule
enum ScanMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case registrationCard = "RegistrationCard"
    case invoice = "Invoice"
    case receipt = "Receipt"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .registrationCard: return "Carte grise"
        case .invoice: return "Facture garage"
        case .receipt: return "Ticket CB"
        }
    }

    var iconName: String {
        switch self {
        case .registrationCard: return "doc.text.fill"
        case .invoice: return "doc.richtext.fill"
        case .receipt: return "receipt.fill"
        }
    }

    var instructions: String {
        switch self {
        case .registrationCard:
            return "Placez la carte grise dans le cadre. Assurez-vous que les champs A, B, D.1 et D.3 sont visibles et bien éclairés."
        case .invoice:
            return "Scannez la facture de garage. Cherchez les informations de marque, modèle et plaque d'immatriculation."
        case .receipt:
            return "Scannez le ticket de carte bancaire. Les informations du garage et la date seront extraites."
        }
    }

    /// Champs clés à rechercher selon le type de document
    var expectedFields: [String] {
        switch self {
        case .registrationCard:
            return ["A", "B", "D.1", "D.3"]
        case .invoice:
            return ["Marque", "Modèle", "Immatriculation"]
        case .receipt:
            return ["Date", "Garage", "Montant"]
        }
    }
}
