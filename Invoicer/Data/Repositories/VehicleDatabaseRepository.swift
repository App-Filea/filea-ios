//
//  VehicleDatabaseRepository.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 18/10/2025.
//

import Foundation
import GRDB
import Dependencies

/// Repository pour les opérations CRUD sur les véhicules avec GRDB
actor VehicleDatabaseRepository {
    // MARK: - Properties

    private let database: DatabaseManager
    private let syncManager: VehicleMetadataSyncManager

    // MARK: - Initialization

    init(database: DatabaseManager, syncManager: VehicleMetadataSyncManager) {
        self.database = database
        self.syncManager = syncManager
    }

    // MARK: - Create

    /// Crée un nouveau véhicule dans la base de données
    /// - Parameters:
    ///   - vehicle: Le véhicule à créer
    ///   - folderPath: Le chemin du dossier du véhicule
    /// - Throws: Erreur si la création échoue
    func create(vehicle: Vehicle, folderPath: String) async throws {
        print("➕ [VehicleRepository] Création d'un véhicule")
        print("   ├─ ID : \(vehicle.id)")
        print("   ├─ Véhicule : \(vehicle.brand) \(vehicle.model)")
        print("   └─ Dossier : \(folderPath)")

        let record = vehicle.toRecord(folderPath: folderPath)

        try await database.write { db in
            try VehicleRecord.insert { record }.execute(db)
        }

        print("✅ [VehicleRepository] Véhicule créé en BDD")

        // Sync automatique vers JSON
        try await syncManager.syncAfterChange(vehicleId: vehicle.id)

        print("💾 [VehicleRepository] JSON synchronisé\n")
    }

    // MARK: - Read

    /// Récupère tous les véhicules
    /// - Returns: Liste de tous les véhicules
    func fetchAll() async throws -> [Vehicle] {
        print("📖 [VehicleRepository] Récupération de tous les véhicules")

        let vehicles = try await database.read { db in
            let records = try VehicleRecord.all.fetchAll(db)
            return records.map { $0.toDomain() }
        }

        print("✅ [VehicleRepository] \(vehicles.count) véhicule(s) récupéré(s)\n")
        return vehicles
    }

    /// Récupère un véhicule par son identifiant
    /// - Parameter id: Identifiant du véhicule
    /// - Returns: Le véhicule si trouvé, nil sinon
    func fetch(id: UUID) async throws -> Vehicle? {
        print("🔍 [VehicleRepository] Recherche du véhicule : \(id)")

        let vehicle = try await database.read { db in
            let record = try VehicleRecord.where { $0.id.in([id]) }.fetchOne(db)
            return record?.toDomain()
        }

        if let vehicle = vehicle {
            print("✅ [VehicleRepository] Véhicule trouvé : \(vehicle.brand) \(vehicle.model)\n")
        } else {
            print("⚠️ [VehicleRepository] Véhicule non trouvé\n")
        }

        return vehicle
    }

    /// Récupère le véhicule principal
    /// - Returns: Le véhicule principal si existant, nil sinon
    func fetchPrimary() async throws -> Vehicle? {
        try await database.read { db in
            let record = try VehicleRecord.where(\.isPrimary).fetchOne(db)
            return record?.toDomain()
        }
    }

    /// Récupère un véhicule avec tous ses documents
    /// - Parameter id: Identifiant du véhicule
    /// - Returns: Le véhicule avec ses documents
    func fetchWithDocuments(id: UUID) async throws -> Vehicle? {
        print("📚 [VehicleRepository] Récupération véhicule + documents : \(id)")

        let vehicle = try await database.read { db -> Vehicle? in
            // Récupérer le véhicule
            guard let vehicleRecord = try VehicleRecord.where { $0.id.in([id]) }.fetchOne(db) else {
                return nil
            }

            // Récupérer tous les fichiers associés
            let fileRecords = try FileMetadataRecord
                .where { $0.vehicleId.in([id]) }
                .order { $0.date.desc() }
                .fetchAll(db)

            // Convertir en domain models
            var vehicle = vehicleRecord.toDomain()
            vehicle.documents = fileRecords.map { $0.toDomain(vehicleFolderPath: vehicleRecord.folderPath) }

            return vehicle
        }

        if let vehicle = vehicle {
            print("✅ [VehicleRepository] Véhicule : \(vehicle.brand) \(vehicle.model)")
            print("   └─ \(vehicle.documents.count) document(s) chargé(s)\n")
        } else {
            print("⚠️ [VehicleRepository] Véhicule non trouvé\n")
        }

        return vehicle
    }

    // MARK: - Update

    /// Met à jour un véhicule existant
    /// - Parameters:
    ///   - vehicle: Le véhicule avec les nouvelles valeurs
    ///   - folderPath: Le chemin du dossier (peut être changé)
    /// - Throws: Erreur si la mise à jour échoue
    func update(vehicle: Vehicle, folderPath: String) async throws {
        print("✏️ [VehicleRepository] Mise à jour du véhicule")
        print("   ├─ ID : \(vehicle.id)")
        print("   └─ Véhicule : \(vehicle.brand) \(vehicle.model)")

        var record = vehicle.toRecord(folderPath: folderPath)
        record.updatedAt = Date()

        try await database.write { db in
            try VehicleRecord.upsert { record }.execute(db)
        }

        print("✅ [VehicleRepository] Véhicule mis à jour en BDD")

        // Sync automatique vers JSON
        try await syncManager.syncAfterChange(vehicleId: vehicle.id)

        print("💾 [VehicleRepository] JSON synchronisé\n")
    }

    /// Définit un véhicule comme principal (et retire le statut aux autres)
    /// - Parameter id: Identifiant du véhicule à définir comme principal
    /// - Throws: Erreur si l'opération échoue
    func setPrimary(id: UUID) async throws {
        try await database.write { db in
            // Retirer le statut principal de tous les véhicules
            try db.execute(sql: """
                UPDATE vehicleRecord SET isPrimary = 0, updatedAt = ?
            """, arguments: [Date()])

            // Définir le véhicule comme principal
            try db.execute(sql: """
                UPDATE vehicleRecord SET isPrimary = 1, updatedAt = ? WHERE id = ?
            """, arguments: [Date(), id])
        }

        // Sync tous les véhicules affectés
        let allVehicles = try await fetchAll()
        for vehicle in allVehicles {
            try await syncManager.syncAfterChange(vehicleId: vehicle.id)
        }
    }

    // MARK: - Delete

    /// Supprime un véhicule et tous ses fichiers associés
    /// - Parameter id: Identifiant du véhicule à supprimer
    /// - Throws: Erreur si la suppression échoue
    func delete(id: UUID) async throws {
        print("🗑️ [VehicleRepository] Suppression du véhicule : \(id)")

        try await database.write { db in
            // La suppression en cascade supprimera automatiquement les fichiers
            try VehicleRecord.where { $0.id.in([id]) }.delete().execute(db)
        }

        print("✅ [VehicleRepository] Véhicule supprimé (+ documents en cascade)\n")
    }

    // MARK: - Statistics

    /// Compte le nombre total de véhicules
    /// - Returns: Le nombre de véhicules
    func count() async throws -> Int {
        let count = try await database.read { db in
            try VehicleRecord.all.fetchCount(db)
        }

        print("🔢 [VehicleRepository] Nombre total de véhicules : \(count)\n")
        return count
    }
}

// MARK: - Dependency Key

extension VehicleDatabaseRepository: DependencyKey {
    nonisolated static let liveValue: VehicleDatabaseRepository = {
        @Dependency(\.database) var database
        @Dependency(\.syncManager) var syncManager
        return VehicleDatabaseRepository(database: database, syncManager: syncManager)
    }()
}

extension DependencyValues {
    var vehicleDatabaseRepository: VehicleDatabaseRepository {
        get { self[VehicleDatabaseRepository.self] }
        set { self[VehicleDatabaseRepository.self] = newValue }
    }
}
