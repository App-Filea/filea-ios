//
//  VehicleMetadataSyncManager.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 18/10/2025.
//

import Foundation
import GRDB
import Dependencies

/// Gestionnaire de synchronisation entre GRDB et les fichiers JSON
actor VehicleMetadataSyncManager {
    // MARK: - Properties

    private let database: DatabaseManager
    private let storageManager: VehicleStorageManagerClient
    private let jsonFileName = ".vehicle_metadata.json"
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private lazy var debouncer: JSONExportDebouncer = JSONExportDebouncer(syncManager: self)

    // MARK: - Initialization

    init(database: DatabaseManager, storageManager: VehicleStorageManagerClient) {
        self.database = database
        self.storageManager = storageManager

        // Configuration de l'encodeur JSON
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        // Configuration du décodeur JSON
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - GRDB → JSON (Export)

    /// Exporte les métadonnées d'un véhicule depuis GRDB vers un fichier JSON
    /// - Parameter vehicleId: Identifiant du véhicule à exporter
    /// - Throws: Erreur si l'export échoue
    func exportVehicleToJSON(vehicleId: String) async throws {
        print("💾 [SyncManager] Export vers JSON : \(vehicleId)")

        // 1. Récupérer le véhicule depuis la BDD
        let vehicleRecord = try await database.read { db in
            try VehicleRecord.where { $0.id.in([vehicleId]) }.fetchOne(db)
        }

        guard let vehicleRecord = vehicleRecord else {
            print("❌ [SyncManager] Véhicule introuvable pour l'export\n")
            throw SyncError.vehicleNotFound
        }

        // 2. Récupérer tous les fichiers du véhicule
        let fileRecords = try await database.read { db in
            try FileMetadataRecord.where { $0.vehicleId.in([vehicleId]) }.fetchAll(db)
        }

        print("   ├─ Véhicule : \(vehicleRecord.brand) \(vehicleRecord.model)")
        print("   ├─ Fichiers : \(fileRecords.count)")

        // 3. Convertir vers DTOs
        let vehicleDTO = vehicleRecord.toDTO()
        let fileDTOs = fileRecords.map { $0.toDTO() }

        // 4. Créer la structure complète du fichier JSON
        let metadataFile = VehicleMetadataFile(
            vehicle: vehicleDTO,
            files: fileDTOs,
            metadata: VehicleMetadataFile.MetadataInfo(
                version: "1.0",
                lastSyncedAt: Date(),
                appVersion: Bundle.main.appVersion
            )
        )

        // 5. Encoder en JSON
        let jsonData = try encoder.encode(metadataFile)

        // 6. Utiliser VehicleStorageManager pour écrire le JSON de manière cohérente
        try await storageManager.saveJSONFile(
            vehicleRecord.folderPath,
            jsonFileName,
            jsonData
        )

        print("✅ [SyncManager] Export JSON réussi\n")
    }

    // MARK: - JSON → GRDB (Import)

    /// Importe les métadonnées depuis un fichier JSON vers GRDB
    /// - Parameter folderPath: Chemin du dossier contenant le fichier .vehicle_metadata.json
    /// - Returns: L'identifiant du véhicule importé
    /// - Throws: Erreur si l'import échoue
    func importVehicleFromJSON(folderPath: String) async throws -> String {
        print("📥 [SyncManager] Import depuis JSON")
        print("   └─ Dossier : \(folderPath)")

        // 1. Vérifier que le fichier JSON existe
        let jsonURL = URL(fileURLWithPath: folderPath)
            .appendingPathComponent(jsonFileName)

        guard FileManager.default.fileExists(atPath: jsonURL.path) else {
            print("❌ [SyncManager] Fichier JSON introuvable\n")
            throw SyncError.jsonFileNotFound
        }

        // 2. Lire et décoder le JSON
        let jsonData = try Data(contentsOf: jsonURL)
        let metadataFile = try decoder.decode(VehicleMetadataFile.self, from: jsonData)

        print("   ├─ Véhicule : \(metadataFile.vehicle.brand) \(metadataFile.vehicle.model)")
        print("   ├─ Fichiers : \(metadataFile.files.count)")
        print("   └─ Version : \(metadataFile.metadata.version)")

        // 3. Convertir vers Records et insérer dans GRDB
        let vehicleRecord = metadataFile.vehicle.toRecord(folderPath: folderPath)

        try await database.write { db in
            // Insérer ou mettre à jour le véhicule
            try VehicleRecord.upsert { vehicleRecord }.execute(db)

            // Supprimer les anciens fichiers de ce véhicule (pour clean import)
            try FileMetadataRecord.where { $0.vehicleId.in([vehicleRecord.id]) }.delete().execute(db)

            // Insérer tous les nouveaux fichiers
            for fileDTO in metadataFile.files {
                let fileRecord = fileDTO.toRecord(vehicleId: vehicleRecord.id)
                try FileMetadataRecord.insert { fileRecord }.execute(db)
            }
        }

        print("✅ [SyncManager] Import JSON réussi\n")
        return metadataFile.vehicle.id
    }

    // MARK: - Scan et Reconstruction

    /// Scanne un dossier racine et reconstruit la BDD depuis tous les JSON trouvés
    /// - Parameter rootFolderPath: Chemin du dossier racine contenant les sous-dossiers de véhicules
    /// - Returns: Liste des identifiants de véhicules importés
    /// - Throws: Erreur si le scan échoue
    func scanAndRebuildDatabase(rootFolderPath: String) async throws -> [String] {
        print("🔄 [SyncManager] Scan et reconstruction de la BDD")
        print("   └─ Dossier racine : \(rootFolderPath)\n")

        let rootURL = URL(fileURLWithPath: rootFolderPath)
        let fileManager = FileManager.default

        // Lister tous les sous-dossiers
        let contents = try fileManager.contentsOfDirectory(
            at: rootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        print("📁 [SyncManager] \(contents.count) dossier(s) trouvé(s)")

        var importedVehicleIds: [String] = []

        // Parcourir chaque dossier
        for folderURL in contents {
            // Vérifier que c'est bien un dossier
            guard try folderURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
                continue
            }

            // Vérifier qu'il contient un fichier de métadonnées
            let jsonURL = folderURL.appendingPathComponent(jsonFileName)

            if fileManager.fileExists(atPath: jsonURL.path) {
                do {
                    let vehicleId = try await importVehicleFromJSON(folderPath: folderURL.path)
                    importedVehicleIds.append(vehicleId)
                } catch {
                    print("⚠️ [SyncManager] Erreur lors de l'import de \(folderURL.lastPathComponent): \(error)")
                    // Continue avec les autres dossiers
                }
            }
        }

        print("✅ [SyncManager] Reconstruction terminée : \(importedVehicleIds.count) véhicule(s) importé(s)\n")
        return importedVehicleIds
    }

    // MARK: - Sync Automatique

    /// Met à jour le JSON après une modification dans la BDD avec debouncing
    ///
    /// Utilise un debouncer pour éviter les exports multiples rapprochés.
    /// L'export effectif n'aura lieu que 500ms après le dernier appel.
    ///
    /// - Parameter vehicleId: Identifiant du véhicule modifié
    func syncAfterChange(vehicleId: String) async {
        print("🔄 [SyncManager] Scheduling debounced export for vehicle: \(vehicleId)")
        await debouncer.schedule(vehicleId: vehicleId)
    }

    // MARK: - Helpers

    /// Vérifie si un dossier contient un fichier de métadonnées valide
    /// - Parameter folderPath: Chemin du dossier à vérifier
    /// - Returns: true si le fichier existe et est valide
    nonisolated func hasValidMetadata(folderPath: String) -> Bool {
        let jsonURL = URL(fileURLWithPath: folderPath)
            .appendingPathComponent(jsonFileName)

        guard FileManager.default.fileExists(atPath: jsonURL.path) else {
            return false
        }

        do {
            let jsonData = try Data(contentsOf: jsonURL)
            _ = try decoder.decode(VehicleMetadataFile.self, from: jsonData)
            return true
        } catch {
            return false
        }
    }
}

// MARK: - Errors

enum SyncError: Error, LocalizedError, Equatable {
    case vehicleNotFound
    case jsonFileNotFound
    case invalidJSON
    case databaseError(String)
    case fileSystemError(String)

    var errorDescription: String? {
        switch self {
        case .vehicleNotFound:
            return "Véhicule introuvable dans la base de données"
        case .jsonFileNotFound:
            return "Fichier de métadonnées introuvable"
        case .invalidJSON:
            return "Format JSON invalide"
        case .databaseError(let message):
            return "Erreur de base de données : \(message)"
        case .fileSystemError(let message):
            return "Erreur système de fichiers : \(message)"
        }
    }
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

