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

        print("✅ [SyncManager] Import JSON réussi")

        // 4. Réparer les fichiers orphelins (présents physiquement mais pas dans le JSON)
        let repairedCount = try await repairOrphanedFiles(
            vehicleId: vehicleRecord.id,
            folderPath: folderPath
        )
        if repairedCount > 0 {
            print("🔧 [SyncManager] \(repairedCount) fichier(s) orphelin(s) récupéré(s)")
            // Re-export le JSON avec les fichiers récupérés
            try await exportVehicleToJSON(vehicleId: vehicleRecord.id)
        }

        print("")
        return metadataFile.vehicle.id
    }

    // MARK: - Repair Orphaned Files

    /// Scanne les fichiers physiques dans le dossier et ajoute ceux qui manquent dans la BDD
    /// - Parameters:
    ///   - vehicleId: Identifiant du véhicule
    ///   - folderPath: Chemin du dossier du véhicule
    /// - Returns: Nombre de fichiers récupérés
    private func repairOrphanedFiles(vehicleId: String, folderPath: String) async throws -> Int {
        let folderURL = URL(fileURLWithPath: folderPath)
        let fileManager = FileManager.default

        // Extensions de fichiers supportées
        let supportedExtensions = ["pdf", "jpg", "jpeg", "png", "heic", "heif", "gif"]

        // Récupérer la liste des fichiers déjà dans la BDD
        let existingFileNames = try await database.read { db -> Set<String> in
            let records = try FileMetadataRecord
                .where { $0.vehicleId.in([vehicleId]) }
                .fetchAll(db)
            return Set(records.map { $0.fileName })
        }

        // Scanner les fichiers physiques dans le dossier
        let contents = try fileManager.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.fileSizeKey, .creationDateKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )

        var repairedCount = 0

        for fileURL in contents {
            let fileName = fileURL.lastPathComponent
            let fileExtension = fileURL.pathExtension.lowercased()

            // Vérifier si c'est un fichier supporté et s'il n'est pas déjà dans la BDD
            guard supportedExtensions.contains(fileExtension),
                  !existingFileNames.contains(fileName) else {
                continue
            }

            print("   🔧 Fichier orphelin trouvé : \(fileName)")

            // Récupérer les attributs du fichier
            let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .creationDateKey, .contentModificationDateKey])
            let fileSize = Int64(resourceValues.fileSize ?? 0)
            let createdAt = resourceValues.creationDate ?? Date()
            let modifiedAt = resourceValues.contentModificationDate ?? Date()

            // Créer un record avec des métadonnées par défaut
            let record = FileMetadataRecord(
                id: UUID().uuidString.lowercased(),
                vehicleId: vehicleId,
                fileName: fileName,
                relativePath: fileName,
                documentType: inferDocumentType(from: fileName),
                documentName: inferDocumentName(from: fileName),
                date: createdAt,
                mileage: "",
                amount: nil,
                fileSize: fileSize,
                mimeType: inferMimeType(from: fileName),
                createdAt: createdAt,
                modifiedAt: modifiedAt,
                expirationDate: nil
            )

            // Insérer dans la BDD
            try await database.write { db in
                try FileMetadataRecord.insert { record }.execute(db)
            }

            repairedCount += 1
        }

        return repairedCount
    }

    /// Infère le type de document à partir du nom du fichier
    private nonisolated func inferDocumentType(from fileName: String) -> String {
        let lowercased = fileName.lowercased()

        if lowercased.contains("controle") || lowercased.contains("ct") || lowercased.contains("technical") {
            return DocumentType.technicalInspection.rawValue
        } else if lowercased.contains("vidange") || lowercased.contains("oil") || lowercased.contains("entretien") {
            return DocumentType.maintenance.rawValue
        } else if lowercased.contains("reparation") || lowercased.contains("repair") || lowercased.contains("panne") {
            return DocumentType.repair.rawValue
        }

        return DocumentType.other.rawValue
    }

    /// Génère un nom de document lisible à partir du nom de fichier
    private nonisolated func inferDocumentName(from fileName: String) -> String {
        // Retirer l'extension
        let name = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent

        // Remplacer les underscores et tirets par des espaces
        let cleaned = name
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")

        // Capitaliser la première lettre
        return cleaned.prefix(1).uppercased() + cleaned.dropFirst()
    }

    /// Infère le type MIME à partir de l'extension du fichier
    private nonisolated func inferMimeType(from fileName: String) -> String {
        let pathExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased()

        switch pathExtension {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "pdf":
            return "application/pdf"
        case "heic":
            return "image/heic"
        case "heif":
            return "image/heif"
        default:
            return "application/octet-stream"
        }
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

