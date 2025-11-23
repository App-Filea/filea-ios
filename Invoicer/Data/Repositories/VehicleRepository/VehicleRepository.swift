import Foundation
import Dependencies

actor VehicleRepository {
    @Dependency(\.vehicleDatabaseRepository) var grdbRepo
    @Dependency(\.fileVehicleRepository) var fileRepo
    @Dependency(\.syncManagerClient) var syncManager
    @Dependency(\.storageManager) var storageManager

    func createVehicle(_ vehicle: Vehicle) async throws {
        let folderName = "\(vehicle.brand)\(vehicle.model)"
        guard let rootURL = await storageManager.getRootURL() else {
            throw VehicleRepositoryError.storageNotConfigured
        }
        let folderPath = rootURL
            .appendingPathComponent("Vehicles")
            .appendingPathComponent(folderName)
            .path

        try await grdbRepo.create(vehicle, folderPath)
        try await syncManager.syncAfterChange(vehicle.id)
        let folderURL = try await storageManager.createVehicleFolder(folderName)

        do {
            try await fileRepo.save(vehicle)
        } catch {
        }
    }

    func updateVehicle(_ vehicle: Vehicle) async throws {
        let folderName = "\(vehicle.brand)\(vehicle.model)"
        guard let rootURL = await storageManager.getRootURL() else {
            throw VehicleRepositoryError.storageNotConfigured
        }
        let folderPath = rootURL
            .appendingPathComponent("Vehicles")
            .appendingPathComponent(folderName)
            .path

        try await grdbRepo.update(vehicle, folderPath)
        try await syncManager.syncAfterChange(vehicle.id)

        do {
            try await fileRepo.update(vehicle)
        } catch {
        }
    }

    func setPrimaryVehicle(_ id: UUID) async throws {
        try await grdbRepo.setPrimary(id)

        let allVehicles = try await grdbRepo.fetchAll()
        for vehicle in allVehicles {
            try await syncManager.syncAfterChange(vehicle.id)
        }

        do {
            var vehicles = try await fileRepo.loadAll()

            for index in vehicles.indices {
                vehicles[index].isPrimary = false
            }

            if let index = vehicles.firstIndex(where: { $0.id == id }) {
                vehicles[index].isPrimary = true
            }

            for vehicle in vehicles {
                try await fileRepo.update(vehicle)
            }
        } catch {
        }
    }

    func hasPrimaryVehicle() async -> Bool {
        do {
            let hasPrimary = try await grdbRepo.fetchPrimary() != nil
            return hasPrimary
        } catch {
            return false
        }
    }

    func getAllVehicles() async throws -> [Vehicle] {
        let vehicles = try await grdbRepo.fetchAll()

        return vehicles.sorted {
            if $0.isPrimary != $1.isPrimary {
                return $0.isPrimary
            }
            return $0.brand < $1.brand
        }
    }

    func getVehicle(_ id: UUID) async throws -> Vehicle? {
        // ✅ Utiliser fetchWithDocuments() pour récupérer les documents depuis GRDB
        let vehicle = try await grdbRepo.fetchWithDocuments(id)
        return vehicle
    }

    func deleteVehicle(_ id: UUID) async throws {
        try await grdbRepo.delete(id)

        do {
            try await fileRepo.delete(id)
        } catch {
        }
    }
}

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
