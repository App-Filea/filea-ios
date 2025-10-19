//
//  FileMetadataDTO.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 18/10/2025.
//

import Foundation

/// Data Transfer Object pour les métadonnées de fichiers
/// Utilisé pour l'export/import JSON
struct FileMetadataDTO: Codable {
    // MARK: - Properties

    var id: UUID
    var fileName: String
    var relativePath: String
    var documentType: String
    var documentName: String
    var date: Date
    var mileage: String
    var amount: Double?
    var fileSize: Int64
    var mimeType: String
    var createdAt: Date
    var modifiedAt: Date

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case fileName
        case relativePath
        case documentType
        case documentName
        case date
        case mileage
        case amount
        case fileSize
        case mimeType
        case createdAt
        case modifiedAt
    }
}
