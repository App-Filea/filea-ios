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
    /// - Returns: Migration result with statistics
    func migrateIfNeeded() async -> MigrationResult {
        logger.info("🔍 [LegacyMigrator] Checking for legacy data...")

        // Check if migration already completed
        if UserDefaults.standard.bool(forKey: migrationCompletedKey) {
            logger.info("✅ [LegacyMigrator] Migration already completed previously")
            return .alreadyMigrated
        }

        // Check if legacy file exists
        guard fileManager.fileExists(atPath: legacyVehiclesFile.path) else {
            logger.info("✅ [LegacyMigrator] No legacy data found - fresh install")
            markMigrationCompleted()
            return .noLegacyData
        }

        logger.warning("⚠️ [LegacyMigrator] Legacy vehicles.json found - migration required")

        do {
            let result = try await performMigration()
            markMigrationCompleted()
            return result
        } catch {
            logger.error("❌ [LegacyMigrator] Migration failed: \(error.localizedDescription)")
            return .failed(error)
        }
    }

    // MARK: - Private Migration Logic

    private func performMigration() async throws -> MigrationResult {
        logger.info("🚀 [LegacyMigrator] Starting migration process...")

        // 1. Read legacy vehicles.json
        let legacyVehicles = try readLegacyVehiclesFile()
        logger.info("📖 [LegacyMigrator] Found \(legacyVehicles.count) vehicle(s) in legacy data")

        guard !legacyVehicles.isEmpty else {
            logger.info("📭 [LegacyMigrator] Empty legacy file - nothing to migrate")
            try backupLegacyFile()
            return .success(vehiclesMigrated: 0, documentsMigrated: 0)
        }

        // 2. Get user-selected storage root (or use legacy location)
        let storageRoot = try await determineStorageRoot()
        logger.info("📁 [LegacyMigrator] Storage root: \(storageRoot.path)")

        // 3. Rename "Vehicles" folder to "Holfy" if needed
        try migrateVehiclesFolderName(at: storageRoot)

        // 4. Migrate each vehicle
        var vehiclesMigrated = 0
        var documentsMigrated = 0
        var errors: [String] = []

        for vehicle in legacyVehicles {
            do {
                let docsCount = try await migrateVehicle(vehicle, storageRoot: storageRoot)
                vehiclesMigrated += 1
                documentsMigrated += docsCount
                logger.info("✅ [LegacyMigrator] Migrated: \(vehicle.brand) \(vehicle.model) (\(docsCount) docs)")
            } catch {
                let errorMsg = "Failed to migrate \(vehicle.brand) \(vehicle.model): \(error.localizedDescription)"
                logger.error("❌ [LegacyMigrator] \(errorMsg)")
                errors.append(errorMsg)
            }
        }

        // 5. Backup legacy file
        try backupLegacyFile()

        // 6. Return result
        if errors.isEmpty {
            logger.info("🎉 [LegacyMigrator] Migration completed successfully!")
            logger.info("   ├─ Vehicles migrated: \(vehiclesMigrated)")
            logger.info("   └─ Documents migrated: \(documentsMigrated)")
            return .success(vehiclesMigrated: vehiclesMigrated, documentsMigrated: documentsMigrated)
        } else {
            logger.warning("⚠️ [LegacyMigrator] Migration completed with errors:")
            errors.forEach { logger.warning("   - \($0)") }
            return .partialSuccess(
                vehiclesMigrated: vehiclesMigrated,
                documentsMigrated: documentsMigrated,
                errors: errors
            )
        }
    }

    private func migrateVehicle(_ vehicle: Vehicle, storageRoot: URL) async throws -> Int {
        // 1. Determine folder path
        let folderName = "\(vehicle.brand)\(vehicle.model)"
        let legacyVehiclePath = legacyVehiclesDirectory.appendingPathComponent(folderName)
        let newVehiclePath = storageRoot
            .appendingPathComponent(AppConstants.vehiclesDirectoryName)
            .appendingPathComponent(folderName)

        // 2. Move/Copy vehicle folder if it exists in legacy location
        if fileManager.fileExists(atPath: legacyVehiclePath.path),
           storageRoot.path != legacyDocumentsDirectory.path {
            // User selected a different storage location - move the folder
            try fileManager.moveItem(at: legacyVehiclePath, to: newVehiclePath)
            logger.info("📦 [LegacyMigrator] Moved folder: \(folderName)")
        } else if !fileManager.fileExists(atPath: newVehiclePath.path) {
            // Create new folder if it doesn't exist
            try fileManager.createDirectory(at: newVehiclePath, withIntermediateDirectories: true)
            logger.info("📁 [LegacyMigrator] Created folder: \(folderName)")
        }

        // 3. Insert vehicle into GRDB
        let vehicleRecord = vehicle.toRecord(folderPath: newVehiclePath.path)
        try await database.write { db in
            try VehicleRecord.insert { vehicleRecord }.execute(db)
        }

        // 4. Insert documents into GRDB
        var migratedDocsCount = 0
        for document in vehicle.documents {
            // Update document file path if folder was moved
            var updatedDocument = document
            if storageRoot.path != legacyDocumentsDirectory.path {
                let filename = URL(fileURLWithPath: document.fileURL).lastPathComponent
                updatedDocument.fileURL = newVehiclePath.appendingPathComponent(filename).path
            }

            let fileRecord = updatedDocument.toRecord(vehicleId: vehicle.id)
            try await database.write { db in
                try FileMetadataRecord.insert { fileRecord }.execute(db)
            }
            migratedDocsCount += 1
        }

        // 5. Create .vehicle_metadata.json
        try await syncManager.exportVehicleToJSON(vehicle.id)

        return migratedDocsCount
    }

    // MARK: - Helper Methods

    private func readLegacyVehiclesFile() throws -> [Vehicle] {
        let jsonData = try Data(contentsOf: legacyVehiclesFile)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Vehicle].self, from: jsonData)
    }

    private func determineStorageRoot() async throws -> URL {
        // Try to get user-selected storage root
        if let userRoot = await storageManager.getRootURL() {
            return userRoot
        }

        // Fallback to legacy Documents directory
        logger.warning("⚠️ [LegacyMigrator] No storage root configured, using legacy location")
        return legacyDocumentsDirectory
    }

    private func migrateVehiclesFolderName(at storageRoot: URL) throws {
        let oldVehiclesFolder = storageRoot.appendingPathComponent("Vehicles")
        let newVehiclesFolder = storageRoot.appendingPathComponent(AppConstants.vehiclesDirectoryName)

        // Check if old "Vehicles" folder exists
        guard fileManager.fileExists(atPath: oldVehiclesFolder.path) else {
            logger.info("ℹ️ [LegacyMigrator] No 'Vehicles' folder to migrate")
            return
        }

        // Check if new "Holfy" folder already exists
        if fileManager.fileExists(atPath: newVehiclesFolder.path) {
            logger.warning("⚠️ [LegacyMigrator] Both 'Vehicles' and 'Holfy' folders exist - keeping Holfy")
            return
        }

        // Rename Vehicles → Holfy
        logger.info("📦 [LegacyMigrator] Renaming 'Vehicles' folder to 'Holfy'...")
        try fileManager.moveItem(at: oldVehiclesFolder, to: newVehiclesFolder)
        logger.info("✅ [LegacyMigrator] Folder renamed: Vehicles → Holfy")
    }

    private func backupLegacyFile() throws {
        let backupURL = legacyVehiclesFile.appendingPathExtension("backup")

        // Remove existing backup if any
        if fileManager.fileExists(atPath: backupURL.path) {
            try fileManager.removeItem(at: backupURL)
        }

        // Rename to backup
        try fileManager.moveItem(at: legacyVehiclesFile, to: backupURL)
        logger.info("💾 [LegacyMigrator] Legacy file backed up: vehicles.json.backup")
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
