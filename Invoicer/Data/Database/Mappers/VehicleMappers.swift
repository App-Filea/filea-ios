//
//  VehicleMappers.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 18/10/2025.
//

import Foundation

// MARK: - Vehicle → VehicleRecord

extension Vehicle {
    /// Convertit un Vehicle (domain) vers un VehicleRecord (database)
    /// - Parameters:
    ///   - folderPath: Chemin du dossier du véhicule
    ///   - createdAt: Date de création (utilise Date() si nil)
    ///   - updatedAt: Date de modification (utilise Date() si nil)
    /// - Returns: VehicleRecord pour la persistence
    func toRecord(
        folderPath: String,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) -> VehicleRecord {
        VehicleRecord(
            id: id,
            type: type.rawValue,
            brand: brand,
            model: model,
            mileage: mileage,
            registrationDate: registrationDate,
            plate: plate,
            isPrimary: isPrimary,
            folderPath: folderPath,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
}

// MARK: - VehicleRecord → Vehicle

extension VehicleRecord {
    /// Convertit un VehicleRecord (database) vers un Vehicle (domain)
    func toDomain() -> Vehicle {
        Vehicle(
            id: id,
            type: VehicleType(rawValue: type) ?? .car,
            brand: brand,
            model: model,
            mileage: mileage,
            registrationDate: registrationDate,
            plate: plate,
            isPrimary: isPrimary,
            documents: [] // Les documents seront chargés séparément
        )
    }
}

// MARK: - Vehicle → VehicleDTO

extension Vehicle {
    /// Convertit un Vehicle (domain) vers un VehicleDTO (transfer)
    func toDTO() -> VehicleDTO {
        VehicleDTO(
            id: id,
            type: type.rawValue,
            brand: brand,
            model: model,
            mileage: mileage,
            registrationDate: registrationDate,
            plate: plate,
            isPrimary: isPrimary,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - VehicleDTO → Vehicle

extension VehicleDTO {
    /// Convertit un VehicleDTO (transfer) vers un Vehicle (domain)
    func toDomain(documents: [Document] = []) -> Vehicle {
        Vehicle(
            id: id,
            type: VehicleType(rawValue: type) ?? .car,
            brand: brand,
            model: model,
            mileage: mileage,
            registrationDate: registrationDate,
            plate: plate,
            isPrimary: isPrimary,
            documents: documents
        )
    }
}

// MARK: - VehicleRecord → VehicleDTO

extension VehicleRecord {
    /// Convertit un VehicleRecord (database) vers un VehicleDTO (transfer)
    func toDTO() -> VehicleDTO {
        VehicleDTO(
            id: id,
            type: type,
            brand: brand,
            model: model,
            mileage: mileage,
            registrationDate: registrationDate,
            plate: plate,
            isPrimary: isPrimary,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - VehicleDTO → VehicleRecord

extension VehicleDTO {
    /// Convertit un VehicleDTO (transfer) vers un VehicleRecord (database)
    func toRecord(folderPath: String) -> VehicleRecord {
        VehicleRecord(
            id: id,
            type: type,
            brand: brand,
            model: model,
            mileage: mileage,
            registrationDate: registrationDate,
            plate: plate,
            isPrimary: isPrimary,
            folderPath: folderPath,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
