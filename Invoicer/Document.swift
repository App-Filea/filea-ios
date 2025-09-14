//
//  Document.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import Foundation

struct Document: Codable, Equatable, Identifiable {
    let id: UUID
    var fileURL: String
    let createdAt: Date
    
    init(fileURL: String) {
        self.id = UUID()
        self.fileURL = fileURL
        self.createdAt = Date()
    }
}
