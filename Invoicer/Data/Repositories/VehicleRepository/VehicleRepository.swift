//
//  VehicleRepository.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 25/10/2025.
//  Main vehicle repository with dual persistence (GRDB + JSON)
//

import Foundation
import Dependencies

/// Main vehicle repository implementing dual persistence strategy
/// Saves to both GRDB database and legacy JSON file system
actor VehicleRepository {
    // MARK: - Dependencies

    @Dependency(\.vehicleDatabaseRepository) var grdbRepo
    @Dependency(\.fileVehicleRepository) var fileRepo
    @Dependency(\.syncManagerClient) var syncManager
    @Dependency(\.storageManager) var storageManager

    // MARK: - Create

    /// Creates a new vehicle in both persistence systems
    /// - Parameter vehicle: The vehicle to create
    /// - Throws: Error if creation fails in GRDB (continues if legacy fails)
    func createVehicle(_ vehicle: Vehicle) async throws {
        print("➕ [VehicleRepository] Création d'un véhicule")
        print("   ├─ ID : \(vehicle.id)")
        print("   ├─ Marque : \(vehicle.brand)")
        print("   └─ Modèle : \(vehicle.model)")

        // Step 1: Prepare folder path (without creating it yet)
        let folderName = "\(vehicle.brand)\(vehicle.model)"
        guard let rootURL = await storageManager.getRootURL() else {
            throw VehicleRepositoryError.storageNotConfigured
        }
        let folderPath = rootURL
            .appendingPathComponent("Vehicles")
            .appendingPathComponent(folderName)
            .path

        // Step 2: Save to GRDB database FIRST (source of truth)
        print("   💾 Sauvegarde dans GRDB...")
        try await grdbRepo.create(vehicle, folderPath)
        print("   ✅ Sauvegarde GRDB réussie")

        // Step 3: Sync to metadata JSON (will create folder if needed)
        print("   💾 Synchronisation vers JSON...")
        try await syncManager.syncAfterChange(vehicle.id)
        print("   ✅ JSON synchronisé")

        // Step 4: Ensure vehicle folder exists (idempotent)
        print("   📁 Vérification du dossier véhicule...")
        let folderURL = try await storageManager.createVehicleFolder(folderName)
        print("   ✅ Dossier confirmé : \(folderURL.path)")

        // Step 5: Save to legacy system (JSON) - non-blocking
        print("   💾 Sauvegarde dans système legacy (JSON)...")
        do {
            try await fileRepo.save(vehicle)
            print("   ✅ Sauvegarde legacy réussie")
        } catch {
            print("   ⚠️ Erreur sauvegarde legacy : \(error.localizedDescription)")
            print("   ℹ️ GRDB est la source de vérité, legacy optionnel")
            // Don't throw - GRDB is the source of truth
        }

        print("✅ [VehicleRepository] Véhicule créé avec succès\n")
    }

    // MARK: - Update

    /// Updates an existing vehicle in both persistence systems
    /// - Parameter vehicle: The vehicle to update
    /// - Throws: Error if update fails in GRDB
    func updateVehicle(_ vehicle: Vehicle) async throws {
        print("✏️ [VehicleRepository] Mise à jour d'un véhicule")
        print("   ├─ ID : \(vehicle.id)")
        print("   └─ Véhicule : \(vehicle.brand) \(vehicle.model)")

        // Get folder path
        let folderName = "\(vehicle.brand)\(vehicle.model)"
        guard let rootURL = await storageManager.getRootURL() else {
            throw VehicleRepositoryError.storageNotConfigured
        }
        let folderPath = rootURL
            .appendingPathComponent("Vehicles")
            .appendingPathComponent(folderName)
            .path

        // Step 1: Update GRDB FIRST (source of truth)
        print("   💾 Mise à jour GRDB...")
        try await grdbRepo.update(vehicle, folderPath)
        print("   ✅ GRDB mis à jour")

        // Step 2: Sync to metadata JSON
        print("   💾 Synchronisation vers JSON...")
        try await syncManager.syncAfterChange(vehicle.id)
        print("   ✅ JSON synchronisé")

        // Step 3: Update legacy system - non-blocking
        print("   💾 Mise à jour système legacy...")
        do {
            try await fileRepo.update(vehicle)
            print("   ✅ Legacy mis à jour")
        } catch {
            print("   ⚠️ Erreur maj legacy : \(error.localizedDescription)")
            print("   ℹ️ GRDB est la source de vérité, legacy optionnel")
        }

        print("✅ [VehicleRepository] Véhicule mis à jour\n")
    }

    /// Sets a vehicle as primary (removes primary status from others)
    /// - Parameter id: The ID of the vehicle to set as primary
    /// - Throws: Error if operation fails
    func setPrimaryVehicle(_ id: UUID) async throws {
        print("⭐ [VehicleRepository] Définition du véhicule principal")
        print("   └─ ID : \(id)")

        // Step 1: Use GRDB's setPrimary (updates all vehicles)
        print("   💾 Mise à jour GRDB...")
        try await grdbRepo.setPrimary(id)
        print("   ✅ GRDB mis à jour (tous véhicules)")

        // Step 2: Sync all vehicles to JSON (setPrimary affects all)
        print("   💾 Synchronisation de tous les véhicules vers JSON...")
        let allVehicles = try await grdbRepo.fetchAll()
        for vehicle in allVehicles {
            try await syncManager.syncAfterChange(vehicle.id)
        }
        print("   ✅ JSON synchronisé (\(allVehicles.count) véhicules)")

        // Step 3: Update legacy system - non-blocking
        print("   💾 Mise à jour système legacy...")
        do {
            // Get all vehicles
            var vehicles = try await fileRepo.loadAll()

            // Remove primary from all
            for index in vehicles.indices {
                vehicles[index].isPrimary = false
            }

            // Set new primary
            if let index = vehicles.firstIndex(where: { $0.id == id }) {
                vehicles[index].isPrimary = true
            }

            // Save all updated vehicles
            for vehicle in vehicles {
                try await fileRepo.update(vehicle)
            }
            print("   ✅ Legacy mis à jour")
        } catch {
            print("   ⚠️ Erreur maj legacy : \(error.localizedDescription)")
            // GRDB is source of truth, so this is not critical
        }

        print("✅ [VehicleRepository] Véhicule principal défini\n")
    }

    // MARK: - Read

    /// Retrieves all vehicles from GRDB
    /// - Returns: Array of all vehicles sorted by primary status then brand
    /// - Throws: Error if fetch fails
    func getAllVehicles() async throws -> [Vehicle] {
        print("📖 [VehicleRepository] Récupération de tous les véhicules")

        let vehicles = try await grdbRepo.fetchAll()
        print("✅ [VehicleRepository] \(vehicles.count) véhicule(s) récupéré(s)\n")

        // Sort: primary first, then alphabetically by brand
        return vehicles.sorted {
            if $0.isPrimary != $1.isPrimary {
                return $0.isPrimary
            }
            return $0.brand < $1.brand
        }
    }

    /// Retrieves a single vehicle by ID from GRDB
    /// - Parameter id: The vehicle ID
    /// - Returns: The vehicle if found, nil otherwise
    /// - Throws: Error if fetch fails
    func getVehicle(_ id: UUID) async throws -> Vehicle? {
        print("🔍 [VehicleRepository] Recherche du véhicule : \(id)")

        let vehicle = try await grdbRepo.fetch(id)

        if vehicle != nil {
            print("✅ [VehicleRepository] Véhicule trouvé\n")
        } else {
            print("⚠️ [VehicleRepository] Véhicule non trouvé\n")
        }

        return vehicle
    }

    // MARK: - Delete

    /// Deletes a vehicle from both persistence systems
    /// - Parameter id: The vehicle ID to delete
    /// - Throws: Error if deletion fails in GRDB
    func deleteVehicle(_ id: UUID) async throws {
        print("🗑️ [VehicleRepository] Suppression du véhicule : \(id)")

        // Delete from GRDB (source of truth)
        print("   💾 Suppression GRDB...")
        try await grdbRepo.delete(id)
        print("   ✅ GRDB supprimé")

        // Delete from legacy system - non-blocking
        print("   💾 Suppression legacy...")
        do {
            try await fileRepo.delete(id)
            print("   ✅ Legacy supprimé")
        } catch {
            print("   ⚠️ Erreur suppression legacy : \(error.localizedDescription)")
            print("   ℹ️ GRDB est la source de vérité, legacy optionnel")
        }

        print("✅ [VehicleRepository] Véhicule supprimé\n")
    }
}

// MARK: - Errors

enum VehicleRepositoryError: Error, LocalizedError {
    case storageNotConfigured
    case vehicleNotFound(UUID)

    var errorDescription: String? {
        switch self {
        case .storageNotConfigured:
            return "Stockage non configuré"
        case .vehicleNotFound(let id):
            return "Véhicule non trouvé : \(id)"
        }
    }
}
