//
//  Document.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import Foundation

enum DocumentType: String, Codable, CaseIterable {
    case carteGrise = "Carte grise"
    case facture = "Facture"
    
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
    
    init(fileURL: String, name: String, date: Date, mileage: String, type: DocumentType) {
        self.id = UUID()
        self.fileURL = fileURL
        self.name = name
        self.date = date
        self.mileage = mileage
        self.type = type
    }
}
