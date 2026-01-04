//
//  VehicleDTO.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 18/10/2025.
//

import Foundation

/// Data Transfer Object pour les véhicules
/// Utilisé pour l'export/import JSON
struct VehicleDTO: Codable {
    // MARK: - Properties

    var id: String
    var type: String
    var brand: String
    var model: String
    var mileage: String?
    var registrationDate: Date
    var plate: String
    var isPrimary: Bool
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case brand
        case model
        case mileage
        case registrationDate
        case plate
        case isPrimary
        case createdAt
        case updatedAt
    }
}
