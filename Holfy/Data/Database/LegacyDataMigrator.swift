//
//  LegacyDataMigrator.swift
//  Holfy
//
//  Created by Claude on 2026-01-11.
//  Migrates data from legacy FileStorageService (vehicles.json) to GRDB + individual JSON files
//

import Foundation
import GRDB
import Dependencies
import os.log

/// Actor responsible for migrating legacy data from FileStorageService to GRDB
///
/// Migration Process:
/// 1. Check if legacy vehicles.json exists
/// 2. Read and parse legacy data
/// 3. Insert vehicles into GRDB with proper folder paths
/// 4. Create individual .vehicle_metadata.json files
/// 5. Backup legacy vehicles.json
/// 6. Mark migration as complete
actor LegacyDataMigrator {

    // MARK: - Properties

    private let logger = Logger(subsystem: AppConstants.bundleIdentifier, category: "LegacyDataMigrator")
    private let fileManager = FileManager.default
    private let database: DatabaseManager
    private let syncManager: VehicleMetadataSyncManagerClient
    private let storageManager: VehicleStorageManagerClient

    // Legacy paths
    private var legacyDocumentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var legacyVehiclesDirectory: URL {
        legacyDocumentsDirectory.appendingPathComponent("Vehicles")
    }

    private var legacyVehiclesFile: URL {
        legacyVehiclesDirectory.appendingPathComponent("vehicles.json")
    }

    // Migration tracking
    private let migrationCompletedKey = "LegacyDataMigrationCompleted_v1"

    // MARK: - Initialization

    init(
        database: DatabaseManager,
        syncManager: VehicleMetadataSyncManagerClient,
        storageManager: VehicleStorageManagerClient
    ) {
        self.database = database
        self.syncManager = syncManager
        self.storageManager = storageManager
    }

    // MARK: - Public Migration API

    /// Migrates legacy data if needed
    /// - Parameter storageRoot: The root storage URL chosen by the user
    /// - Returns: Migration result with statistics
    func migrateIfNeeded(at storageRoot: URL) async -> MigrationResult {
        logger.info("🔍 [LegacyMigrator] Checking for legacy data at: \(storageRoot.path)")

        // 1. Check if "Vehicles" folder exists (needs renaming)
        let legacyVehiclesDir = storageRoot.appendingPathComponent("Vehicles")
        let newHolfyDir = storageRoot.appendingPathComponent(AppConstants.vehiclesDirectoryName)

        if fileManager.fileExists(atPath: legacyVehiclesDir.path) &&
           !fileManager.fileExists(atPath: newHolfyDir.path) {
            logger.info("📦 [LegacyMigrator] Renaming 'Vehicles' → 'Holfy'...")
            do {
                try fileManager.moveItem(at: legacyVehiclesDir, to: newHolfyDir)
                logger.info("✅ [LegacyMigrator] Folder renamed successfully")
            } catch {
                logger.error("❌ [LegacyMigrator] Failed to rename folder: \(error.localizedDescription)")
                return .failed(error)
            }
        }

        // 2. Check if vehicles.json exists in Holfy folder
        let vehiclesJsonFile = newHolfyDir.appendingPathComponent("vehicles.json")
        guard fileManager.fileExists(atPath: vehiclesJsonFile.path) else {
            logger.info("✅ [LegacyMigrator] No vehicles.json found - fresh install or already migrated")
            markMigrationCompleted()
            return .noLegacyData
        }

        // Check if migration already completed for this specific file
        if UserDefaults.standard.bool(forKey: migrationCompletedKey) {
            logger.info("✅ [LegacyMigrator] Migration already completed previously")
            return .alreadyMigrated
        }

        logger.warning("⚠️ [LegacyMigrator] Legacy vehicles.json found - migration required")

        // 3. Perform migration
        do {
            let result = try await performMigration(vehiclesJsonFile: vehiclesJsonFile, holfyDirectory: newHolfyDir)
            markMigrationCompleted()
            return result
        } catch {
            logger.error("❌ [LegacyMigrator] Migration failed: \(error.localizedDescription)")
            return .failed(error)
        }
    }

    // MARK: - Private Migration Logic

    private func performMigration(vehiclesJsonFile: URL, holfyDirectory: URL) async throws -> MigrationResult {
        logger.info("🚀 [LegacyMigrator] Starting migration process...")
        logger.info("   ├─ JSON file: \(vehiclesJsonFile.path)")
        logger.info("   └─ Holfy directory: \(holfyDirectory.path)")

        // 1. Read legacy vehicles.json
        let legacyVehicles = try readLegacyVehiclesFile(at: vehiclesJsonFile)
        logger.info("📖 [LegacyMigrator] Found \(legacyVehicles.count) vehicle(s) in legacy data")

        guard !legacyVehicles.isEmpty else {
            logger.info("📭 [LegacyMigrator] Empty legacy file - nothing to migrate")
            try deleteVehiclesJsonFile(at: vehiclesJsonFile)
            return .success(vehiclesMigrated: 0, documentsMigrated: 0)
        }

        // 2. Migrate each vehicle
        var vehiclesMigrated = 0
        var documentsMigrated = 0
        var errors: [String] = []

        for vehicle in legacyVehicles {
            do {
                let docsCount = try await migrateVehicle(vehicle, holfyDirectory: holfyDirectory)
                vehiclesMigrated += 1
                documentsMigrated += docsCount
                logger.info("✅ [LegacyMigrator] Migrated: \(vehicle.brand) \(vehicle.model) (\(docsCount) docs)")
            } catch {
                let errorMsg = "Failed to migrate \(vehicle.brand) \(vehicle.model): \(error.localizedDescription)"
                logger.error("❌ [LegacyMigrator] \(errorMsg)")
                errors.append(errorMsg)
            }
        }

        // 3. Delete vehicles.json after successful migration
        if errors.isEmpty {
            try deleteVehiclesJsonFile(at: vehiclesJsonFile)
        }

        // 4. Return result
        if errors.isEmpty {
            logger.info("🎉 [LegacyMigrator] Migration completed successfully!")
            logger.info("   ├─ Vehicles migrated: \(vehiclesMigrated)")
            logger.info("   ├─ Documents migrated: \(documentsMigrated)")
            logger.info("   └─ Legacy vehicles.json deleted")
            return .success(vehiclesMigrated: vehiclesMigrated, documentsMigrated: documentsMigrated)
        } else {
            logger.warning("⚠️ [LegacyMigrator] Migration completed with errors:")
            logger.warning("   ⚠️ Legacy vehicles.json NOT deleted due to errors")
            errors.forEach { logger.warning("   - \($0)") }
            return .partialSuccess(
                vehiclesMigrated: vehiclesMigrated,
                documentsMigrated: documentsMigrated,
                errors: errors
            )
        }
    }

    private func migrateVehicle(_ vehicle: Vehicle, holfyDirectory: URL) async throws -> Int {
        // 1. Determine vehicle folder path in Holfy directory
        let folderName = "\(vehicle.brand)\(vehicle.model)"
        let vehicleFolderPath = holfyDirectory.appendingPathComponent(folderName)

        // 2. Ensure vehicle folder exists
        if !fileManager.fileExists(atPath: vehicleFolderPath.path) {
            try fileManager.createDirectory(at: vehicleFolderPath, withIntermediateDirectories: true)
            logger.info("📁 [LegacyMigrator] Created folder: \(folderName)")
        }

        // 3. Insert vehicle into GRDB
        let vehicleRecord = vehicle.toRecord(folderPath: vehicleFolderPath.path)
        try await database.write { db in
            try VehicleRecord.insert { vehicleRecord }.execute(db)
        }

        // 4. Insert documents into GRDB
        var migratedDocsCount = 0
        for document in vehicle.documents {
            // Documents are already in the right folder (since we just renamed Vehicles → Holfy)
            // We just need to insert them into GRDB with their current paths
            let fileRecord = document.toRecord(vehicleId: vehicle.id)
            try await database.write { db in
                try FileMetadataRecord.insert { fileRecord }.execute(db)
            }
            migratedDocsCount += 1
        }

        // 5. Create .vehicle_metadata.json in the vehicle folder
        try await syncManager.exportVehicleToJSON(vehicle.id)

        return migratedDocsCount
    }

    // MARK: - Helper Methods

    private func readLegacyVehiclesFile(at fileURL: URL) throws -> [Vehicle] {
        let jsonData = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Vehicle].self, from: jsonData)
    }

    private func deleteVehiclesJsonFile(at fileURL: URL) throws {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            logger.info("ℹ️ [LegacyMigrator] No vehicles.json file to delete")
            return
        }

        logger.info("🗑️ [LegacyMigrator] Deleting vehicles.json file...")
        try fileManager.removeItem(at: fileURL)
        logger.info("✅ [LegacyMigrator] vehicles.json deleted successfully")
    }

    private func markMigrationCompleted() {
        UserDefaults.standard.set(true, forKey: migrationCompletedKey)
        UserDefaults.standard.synchronize()
        logger.info("✅ [LegacyMigrator] Migration marked as completed")
    }
}

// MARK: - Migration Result

enum MigrationResult {
    case success(vehiclesMigrated: Int, documentsMigrated: Int)
    case partialSuccess(vehiclesMigrated: Int, documentsMigrated: Int, errors: [String])
    case noLegacyData
    case alreadyMigrated
    case failed(Error)

    var isSuccess: Bool {
        switch self {
        case .success, .partialSuccess, .noLegacyData, .alreadyMigrated:
            return true
        case .failed:
            return false
        }
    }

    var userMessage: String {
        switch self {
        case .success(let vehicles, let documents):
            return "Migration réussie : \(vehicles) véhicule(s) et \(documents) document(s) migrés."
        case .partialSuccess(let vehicles, let documents, let errors):
            return "Migration partielle : \(vehicles) véhicule(s) et \(documents) document(s) migrés avec \(errors.count) erreur(s)."
        case .noLegacyData:
            return "Aucune donnée à migrer."
        case .alreadyMigrated:
            return "Migration déjà effectuée."
        case .failed(let error):
            return "Échec de la migration : \(error.localizedDescription)"
        }
    }
}
