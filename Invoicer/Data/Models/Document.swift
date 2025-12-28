//
//  Document.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import Foundation

enum DocumentType: String, Codable, CaseIterable, Identifiable, Hashable, CustomStringConvertible {
    case technicalInspection = "Contrôle technique"
    case maintenance = "Entretien"
    case repair = "Réparation"
    case other = "Autre"

    var id: Self { self }

    var description: String { displayName }

    var displayName: String {
        return self.rawValue
    }

    var imageName: String {
        switch self {
        case .technicalInspection: "checkmark.seal.fill"
        case .maintenance: "wrench.fill"
        case .repair: "wrench.and.screwdriver.fill"
        case .other: "doc.fill"
        }
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

