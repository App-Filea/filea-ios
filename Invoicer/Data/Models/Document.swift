//
//  Document.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import Foundation

enum DocumentType: String, Codable, CaseIterable {
    // Administratif
    case carteGrise = "Carte grise"
    case assurance = "Assurance"
    case controleTechnique = "Contrôle technique"

    // Entretien
    case entretien = "Entretien"
    case vidange = "Vidange"
    case revision = "Révision"

    // Réparation
    case reparation = "Réparation"
    case panne = "Panne"
    case accident = "Accident"

    // Autres dépenses
    case carburant = "Carburant"
    case achatPiece = "Achat de pièce"
    case peage = "Péage/Parking"
    case autre = "Autre"

    var displayName: String {
        return self.rawValue
    }

    var imageName: String {
        switch self {
        // Administratif
        case .carteGrise: "menucard.fill"
        case .assurance: "shield.fill"
        case .controleTechnique: "checkmark.seal.fill"

        // Entretien
        case .entretien: "wrench.fill"
        case .vidange: "drop.fill"
        case .revision: "checklist"

        // Réparation
        case .reparation: "wrench.and.screwdriver.fill"
        case .panne: "exclamationmark.triangle.fill"
        case .accident: "car.side.fill"

        // Autres dépenses
        case .carburant: "fuelpump.fill"
        case .achatPiece: "cart.fill"
        case .peage: "road.lanes"
        case .autre: "doc.fill"
        }
    }

    var category: DocumentCategory {
        switch self {
        case .carteGrise, .assurance, .controleTechnique:
            return .administratif
        case .entretien, .vidange, .revision:
            return .entretien
        case .reparation, .panne, .accident:
            return .reparation
        case .carburant:
            return .carburant
        case .achatPiece, .peage, .autre:
            return .autres
        }
    }
}

enum DocumentCategory: String, CaseIterable {
    case administratif = "Administratif"
    case entretien = "Entretien"
    case reparation = "Réparation"
    case carburant = "Carburant"
    case autres = "Autres"

    var displayName: String {
        return self.rawValue
    }
}

struct Document: Codable, Equatable, Identifiable {
    let id: UUID
    var fileURL: String
    var name: String
    var date: Date
    var mileage: String
    var type: DocumentType
    var amount: Double?

    init(id: UUID? = nil, fileURL: String, name: String, date: Date, mileage: String, type: DocumentType, amount: Double? = nil) {
        self.id = id ?? UUID()
        self.fileURL = fileURL
        self.name = name
        self.date = date
        self.mileage = mileage
        self.type = type
        self.amount = amount
    }
    
    var fileType: String {
        let url = URL(fileURLWithPath: self.fileURL)
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "jpg", "jpeg", "png", "gif", "bmp", "tiff", "heic", "heif":
            return "Photo"
        default:
            return "Fichier"
        }
    }
}

extension Array where Element == Document {
    func groupedByMonth() -> [(title: String, items: [Document])] {
        let calendar = Calendar.current
        let now = Date()
        
        let grouped = Dictionary(grouping: self) { doc in
            calendar.dateComponents([.year, .month], from: doc.date)
        }
        
        return grouped
            .compactMap { (components, docs) -> (String, [Document])? in
                guard let _ = components.year, let _ = components.month else {
                    return nil
                }
                
                let monthDate = calendar.date(from: components)!
                
                if calendar.isDate(monthDate, equalTo: now, toGranularity: .month),
                   calendar.isDate(monthDate, equalTo: now, toGranularity: .year) {
                    return ("Ce mois-ci", docs)
                } else {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "fr_FR")
                    formatter.dateFormat = "LLLL yyyy"
                    
                    let title = formatter.string(from: monthDate).capitalized
                    return (title, docs)
                }
            }
            .sorted { lhs, rhs in
                guard let lhsDate = lhs.items.first?.date,
                      let rhsDate = rhs.items.first?.date else { return false }
                return lhsDate > rhsDate
            }
    }
}

