//
//  FileVehicleRepository.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Legacy file-based repository for vehicle CRUD operations (JSON)
//

import Foundation
import Dependencies
import os.log

actor FileVehicleRepository {
    private let logger = Logger(subsystem: AppConstants.bundleIdentifier, category: "FileVehicleRepository")
    private let fileManager = FileManager.default
    @Dependency(\.storageManager) var storageManager

    // MARK: - Paths

    private var vehiclesDirectory: URL {
        get async throws {
            try await storageManager.getVehiclesDirectory()
        }
    }

    private var vehiclesFileURL: URL {
        get async throws {
            let vehiclesDir = try await vehiclesDirectory
            return vehiclesDir.appendingPathComponent(AppConstants.vehiclesFileName)
        }
    }

    // MARK: - Initialization

    init() {
        // Don't initialize storage here - it will be initialized when first accessed
        logger.info("📦 VehicleRepository créé (lazy initialization)")
    }

    /// Ensures the storage is initialized before any operation
    /// Note: The Vehicles directory is created by VehicleStorageManager, we only need to create the JSON file
    private func ensureStorageInitialized() async throws {
        try await createVehiclesFileIfNeeded()
    }

    private func createVehiclesFileIfNeeded() async throws {
        let vehiclesFile = try await vehiclesFileURL
        guard !fileManager.fileExists(at: vehiclesFile) else {
            logger.info("📄 Le fichier vehicles.json existe déjà")
            return
        }

        let emptyVehiclesList: [Vehicle] = []
        let jsonData = try JSONEncoder().encode(emptyVehiclesList)
        try jsonData.write(to: vehiclesFile)
        logger.info("📄 Fichier vehicles.json créé avec succès")
    }

    // MARK: - Public Methods

    func loadAll() async throws -> [Vehicle] {
        logger.info("📖 Chargement de tous les véhicules...")

        try await ensureStorageInitialized()

        let vehiclesFile = try await vehiclesFileURL
        guard fileManager.fileExists(at: vehiclesFile) else {
            logger.warning("⚠️ Le fichier vehicles.json n'existe pas encore")
            return []
        }

        let jsonData = try Data(contentsOf: vehiclesFile)
        var vehicles = try JSONDecoder().decode([Vehicle].self, from: jsonData)
        logger.info("✅ \(vehicles.count) véhicule(s) chargé(s)")

        // Clean up orphaned document references
        let cleanedVehicles = try await cleanOrphanedDocuments(vehicles)

        if cleanedVehicles.count != vehicles.count ||
           cleanedVehicles.enumerated().contains(where: { vehicles[$0.offset].documents.count != $0.element.documents.count }) {
            vehicles = cleanedVehicles
            try await saveAll(vehicles)
            logger.info("🧹 Références orphelines nettoyées")
        }

        return vehicles
    }

    func save(_ vehicle: Vehicle) async throws {
        logger.info("💾 Sauvegarde du véhicule: \(vehicle.brand) \(vehicle.model)")

        try await ensureStorageInitialized()

        // Create vehicle directory
        try await createVehicleDirectory(for: vehicle)

        var vehicles = try await loadAll()
        vehicles.append(vehicle)

        try await saveAll(vehicles)
        logger.info("✅ Véhicule sauvegardé avec succès")
    }

    func update(_ vehicle: Vehicle) async throws {
        logger.info("✏️ Mise à jour du véhicule: \(vehicle.id)")

        try await ensureStorageInitialized()

        var vehicles = try await loadAll()

        guard let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) else {
            throw RepositoryError.notFound("Véhicule non trouvé: \(vehicle.id)")
        }

        let oldVehicle = vehicles[index]

        // Handle directory rename if brand or model changed
        if oldVehicle.brand != vehicle.brand || oldVehicle.model != vehicle.model {
            try await renameVehicleDirectory(from: oldVehicle, to: vehicle)
        }

        vehicles[index] = vehicle
        try await saveAll(vehicles)
        logger.info("✅ Véhicule mis à jour avec succès")
    }

    func delete(_ vehicleId: UUID) async throws {
        logger.info("🗑️ Suppression du véhicule: \(vehicleId)")

        try await ensureStorageInitialized()

        var vehicles = try await loadAll()

        guard let index = vehicles.firstIndex(where: { $0.id == vehicleId }) else {
            throw RepositoryError.notFound("Véhicule non trouvé: \(vehicleId)")
        }

        let vehicle = vehicles[index]

        // Delete vehicle directory
        let vehicleDirectoryURL = try await vehicleDirectory(for: vehicle)
        try fileManager.safelyDelete(at: vehicleDirectoryURL)
        logger.info("🗂️ Dossier du véhicule supprimé")

        vehicles.remove(at: index)
        try await saveAll(vehicles)
        logger.info("✅ Véhicule supprimé avec succès")
    }

    func find(by id: UUID) async throws -> Vehicle? {
        let vehicles = try await loadAll()
        return vehicles.first(where: { $0.id == id })
    }

    // MARK: - Private Helpers

    private func saveAll(_ vehicles: [Vehicle]) async throws {
        let jsonData = try JSONEncoder().encode(vehicles)
        let vehiclesFile = try await vehiclesFileURL
        try jsonData.write(to: vehiclesFile)
        logger.info("💾 Liste des véhicules sauvegardée (\(vehicles.count) véhicules)")
    }

    private func cleanOrphanedDocuments(_ vehicles: [Vehicle]) async throws -> [Vehicle] {
        var cleanedVehicles = vehicles

        for vehicleIndex in 0..<cleanedVehicles.count {
            let vehicle = cleanedVehicles[vehicleIndex]
            let validDocuments = vehicle.documents.filter { document in
                let fileURL = URL(fileURLWithPath: document.fileURL)
                let exists = fileManager.fileExists(at: fileURL)
                if !exists {
                    logger.warning("🧹 Document orphelin trouvé: \(document.fileURL)")
                }
                return exists
            }

            if validDocuments.count != vehicle.documents.count {
                cleanedVehicles[vehicleIndex].documents = validDocuments
                logger.info("🔧 Nettoyé \(vehicle.documents.count - validDocuments.count) document(s) orphelin(s)")
            }
        }

        return cleanedVehicles
    }

    private func createVehicleDirectory(for vehicle: Vehicle) async throws {
        let directoryURL = try await vehicleDirectory(for: vehicle)
        try fileManager.createDirectoryCoordinated(at: directoryURL)
        logger.info("📁 Dossier véhicule créé: \(directoryURL.lastPathComponent)")
    }

    private func renameVehicleDirectory(from oldVehicle: Vehicle, to newVehicle: Vehicle) async throws {
        let oldDirectoryURL = try await vehicleDirectory(for: oldVehicle)
        let newDirectoryURL = try await vehicleDirectory(for: newVehicle)

        guard fileManager.fileExists(at: oldDirectoryURL) else {
            logger.warning("⚠️ Ancien dossier introuvable, création du nouveau")
            try await createVehicleDirectory(for: newVehicle)
            return
        }

        try fileManager.moveFileReplacing(from: oldDirectoryURL, to: newDirectoryURL)
        logger.info("📁 Dossier renommé: \(oldDirectoryURL.lastPathComponent) → \(newDirectoryURL.lastPathComponent)")
    }

    private func vehicleDirectory(for vehicle: Vehicle) async throws -> URL {
        let vehiclesDir = try await vehiclesDirectory
        return vehiclesDir.appendingPathComponent("\(vehicle.brand)\(vehicle.model)")
    }
}

// MARK: - Repository Errors

enum RepositoryError: LocalizedError {
    case notFound(String)
    case saveFailed(String)
    case loadFailed(String)
    case deleteFailed(String)
    case invalidData(String)

    var errorDescription: String? {
        switch self {
        case .notFound(let message):
            return "Élément introuvable: \(message)"
        case .saveFailed(let message):
            return "Échec de la sauvegarde: \(message)"
        case .loadFailed(let message):
            return "Échec du chargement: \(message)"
        case .deleteFailed(let message):
            return "Échec de la suppression: \(message)"
        case .invalidData(let message):
            return "Données invalides: \(message)"
        }
    }
}
