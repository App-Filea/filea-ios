//
//  VehicleDatabaseRepository.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 18/10/2025.
//

import Foundation
import GRDB
import Dependencies

struct VehicleDatabaseRepositoryClient {
    var create: @Sendable (Vehicle, String) async throws -> Void
    var fetchAll: @Sendable () async throws -> [Vehicle]
    var fetch: @Sendable (UUID) async throws -> Vehicle?
    var fetchPrimary: @Sendable () async throws -> Vehicle?
    var fetchWithDocuments: @Sendable (UUID) async throws -> Vehicle?
    var update: @Sendable (Vehicle, String) async throws -> Void
    var setPrimary: @Sendable (UUID) async throws -> Void
    var delete: @Sendable (UUID) async throws -> Void
    var count: @Sendable () async throws -> Int
}

extension VehicleDatabaseRepositoryClient: DependencyKey {
    nonisolated static let liveValue: VehicleDatabaseRepositoryClient = {
        @Dependency(\.database) var database

        let vehicleRepository = VehicleDatabaseRepository(database: database)
        return VehicleDatabaseRepositoryClient(
            create: {
                try await vehicleRepository.create(vehicle: $0, folderPath: $1)
            },
            fetchAll: {
                try await vehicleRepository.fetchAll()
            },
            fetch: {
                try await vehicleRepository.fetch(id: $0)
            },
            fetchPrimary: {
                try await vehicleRepository.fetchPrimary()
            },
            fetchWithDocuments: {
                try await vehicleRepository.fetchWithDocuments(id: $0)
            },
            update: {
                try await vehicleRepository.update(vehicle: $0, folderPath: $1)
            },
            setPrimary: {
                try await vehicleRepository.setPrimary(id: $0)
            },
            delete: {
                try await vehicleRepository.delete(id: $0)
            },
            count: {
                try await vehicleRepository.count()
            })
    }()
    
    nonisolated static let testValue: VehicleDatabaseRepositoryClient = {
        VehicleDatabaseRepositoryClient(
            create: { _, _ in },
            fetchAll: { return [] },
            fetch: { _ in return nil },
            fetchPrimary: { return nil },
            fetchWithDocuments: { _ in return nil },
            update: { _, _ in },
            setPrimary: { _ in },
            delete: { _ in },
            count: { return 0 })
    }()
}

extension DependencyValues {
    var vehicleDatabaseRepository: VehicleDatabaseRepositoryClient {
        get { self[VehicleDatabaseRepositoryClient.self] }
        set { self[VehicleDatabaseRepositoryClient.self] = newValue }
    }
}
