//
//  VehicleGRDBClient.swift
//  Holfy
//
//  Created by Nicolas Barbosa on 10/01/2026.
//  Consolidated GRDB client - replaces 3-layer architecture
//

import Foundation
import GRDB
import Dependencies

/// Client consolidé pour les opérations véhicules
///
/// Remplace l'ancienne architecture à 3 couches :
/// - VehicleRepositoryClient (interface)
/// - VehicleRepository (wrapper)
/// - VehicleDatabaseRepository (implémentation)
///
/// Ce client combine toute la logique en un seul endroit pour simplifier la maintenance.
struct VehicleGRDBClient: Sendable {
    var createVehicle: @Sendable (Vehicle) async throws -> Void
    var updateVehicle: @Sendable (Vehicle) async throws -> Void
    var setPrimaryVehicle: @Sendable (String) async throws -> Void
    var hasPrimaryVehicle: @Sendable () async -> Bool
    var getAllVehicles: @Sendable () async throws -> [Vehicle]
    var getVehicle: @Sendable (String) async throws -> Vehicle?
    var deleteVehicle: @Sendable (String) async throws -> Void
}

// MARK: - Dependency Key

extension VehicleGRDBClient: DependencyKey {
    static let liveValue: VehicleGRDBClient = {
        @Dependency(\.database) var database
        @Dependency(\.syncManagerClient) var syncManager
        @Dependency(\.storageManager) var storageManager

        return VehicleGRDBClient(
            // MARK: - Create Vehicle
            createVehicle: { vehicle in
                print("➕ [VehicleGRDBClient] Creating vehicle: \(vehicle.brand) \(vehicle.model)")

                // 1. Compute folder path
                let folderName = "\(vehicle.brand)\(vehicle.model)"
                guard let rootURL = await storageManager.getRootURL() else {
                    print("❌ [VehicleGRDBClient] Storage not configured")
                    throw VehicleGRDBError.storageNotConfigured
                }
                let folderPath = rootURL
                    .appendingPathComponent("Vehicles")
                    .appendingPathComponent(folderName)
                    .path

                // 2. Create physical folder FIRST (required for JSON export)
                let _ = try await storageManager.createVehicleFolder(folderName)
                print("   📁 Folder created: \(folderName)")

                // 3. Create record in GRDB
                let record = vehicle.toRecord(folderPath: folderPath)
                try await database.write { db in
                    try VehicleRecord.insert { record }.execute(db)
                }
                print("   ✅ Vehicle saved to database")

                // 4. Export to JSON immediately (no debounce for creation)
                try await syncManager.exportVehicleToJSON(vehicle.id)
                print("   💾 JSON exported immediately\n")
            },

            // MARK: - Update Vehicle
            updateVehicle: { vehicle in
                print("✏️ [VehicleGRDBClient] Updating vehicle: \(vehicle.id)")

                // 1. Compute folder path
                let folderName = "\(vehicle.brand)\(vehicle.model)"
                guard let rootURL = await storageManager.getRootURL() else {
                    throw VehicleGRDBError.storageNotConfigured
                }
                let folderPath = rootURL
                    .appendingPathComponent("Vehicles")
                    .appendingPathComponent(folderName)
                    .path

                // 2. Update in GRDB
                var record = vehicle.toRecord(folderPath: folderPath)
                record.updatedAt = Date()
                try await database.write { db in
                    try VehicleRecord.upsert { record }.execute(db)
                }
                print("   ✅ Vehicle updated in database")

                // 3. Sync to JSON with debouncing
                await syncManager.syncAfterChange(vehicle.id)
                print("   💾 JSON sync scheduled\n")
            },

            // MARK: - Set Primary Vehicle
            setPrimaryVehicle: { id in
                print("⭐ [VehicleGRDBClient] Setting primary vehicle: \(id)")

                // 1. Update all vehicles in one transaction
                try await database.write { db in
                    let records = try VehicleRecord.all.fetchAll(db)

                    for var record in records {
                        let shouldBePrimary = record.id == id
                        if record.isPrimary != shouldBePrimary {
                            record.isPrimary = shouldBePrimary
                            record.updatedAt = Date()
                            try VehicleRecord.upsert { record }.execute(db)
                        }
                    }
                }
                print("   ✅ Primary status updated for all vehicles")

                // 2. Sync all vehicles to JSON (they all changed primary status)
                let allVehicles = try await database.read { db in
                    try VehicleRecord.all.fetchAll(db)
                }

                for vehicleRecord in allVehicles {
                    await syncManager.syncAfterChange(vehicleRecord.id)
                }
                print("   💾 JSON sync scheduled for \(allVehicles.count) vehicle(s)\n")
            },

            // MARK: - Has Primary Vehicle
            hasPrimaryVehicle: {
                do {
                    let primaryVehicle = try await database.read { db in
                        try VehicleRecord.where(\.isPrimary).fetchOne(db)
                    }
                    return primaryVehicle != nil
                } catch {
                    print("⚠️ [VehicleGRDBClient] Error checking primary vehicle: \(error.localizedDescription)")
                    return false
                }
            },

            // MARK: - Get All Vehicles
            getAllVehicles: {
                print("📖 [VehicleGRDBClient] Fetching all vehicles with documents")

                let vehicles = try await database.read { db -> [Vehicle] in
                    let vehicleRecords = try VehicleRecord.all.fetchAll(db)

                    return try vehicleRecords.map { vehicleRecord in
                        // Fetch documents for each vehicle
                        let fileRecords = try FileMetadataRecord
                            .where { $0.vehicleId.in([vehicleRecord.id]) }
                            .order { $0.date.desc() }
                            .fetchAll(db)

                        var vehicle = vehicleRecord.toDomain()
                        vehicle.documents = fileRecords.map {
                            $0.toDomain(vehicleFolderPath: vehicleRecord.folderPath)
                        }

                        return vehicle
                    }
                }

                // Sort: primary first, then alphabetically by brand
                let sortedVehicles = vehicles.sorted {
                    if $0.isPrimary != $1.isPrimary {
                        return $0.isPrimary
                    }
                    return $0.brand < $1.brand
                }

                print("   ✅ Fetched \(sortedVehicles.count) vehicle(s)\n")
                return sortedVehicles
            },

            // MARK: - Get Vehicle
            getVehicle: { id in
                print("📖 [VehicleGRDBClient] Fetching vehicle: \(id)")

                let vehicle = try await database.read { db -> Vehicle? in
                    guard let vehicleRecord = try VehicleRecord.where { $0.id.in([id]) }.fetchOne(db) else {
                        return nil
                    }

                    // Fetch documents
                    let fileRecords = try FileMetadataRecord
                        .where { $0.vehicleId.in([id]) }
                        .order { $0.date.desc() }
                        .fetchAll(db)

                    var vehicle = vehicleRecord.toDomain()
                    vehicle.documents = fileRecords.map {
                        $0.toDomain(vehicleFolderPath: vehicleRecord.folderPath)
                    }

                    return vehicle
                }

                if vehicle != nil {
                    print("   ✅ Vehicle found with \(vehicle?.documents.count ?? 0) document(s)\n")
                } else {
                    print("   ⚠️ Vehicle not found\n")
                }

                return vehicle
            },

            // MARK: - Delete Vehicle
            deleteVehicle: { id in
                print("🗑️ [VehicleGRDBClient] Deleting vehicle: \(id)")

                try await database.write { db in
                    // 1. Delete all associated documents (cascade delete)
                    try FileMetadataRecord
                        .where { $0.vehicleId.in([id]) }
                        .delete()
                        .execute(db)

                    // 2. Delete vehicle
                    try VehicleRecord.where { $0.id.in([id]) }.delete().execute(db)
                }

                print("   ✅ Vehicle and documents deleted from database\n")
            }
        )
    }()

    static let testValue: VehicleGRDBClient = VehicleGRDBClient(
        createVehicle: { _ in },
        updateVehicle: { _ in },
        setPrimaryVehicle: { _ in },
        hasPrimaryVehicle: { false },
        getAllVehicles: { [] },
        getVehicle: { _ in nil },
        deleteVehicle: { _ in }
    )
}

// MARK: - Dependency Values

extension DependencyValues {
    var vehicleGRDBClient: VehicleGRDBClient {
        get { self[VehicleGRDBClient.self] }
        set { self[VehicleGRDBClient.self] = newValue }
    }
}

// MARK: - Errors

enum VehicleGRDBError: Error, LocalizedError {
    case storageNotConfigured
    case vehicleNotFound(String)

    var errorDescription: String? {
        switch self {
        case .storageNotConfigured:
            return "Stockage non configuré. Veuillez sélectionner un dossier racine."
        case .vehicleNotFound(let id):
            return "Véhicule non trouvé : \(id)"
        }
    }
}
