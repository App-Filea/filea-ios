//
//  VehicleRepositoryClient.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 25/10/2025.
//  Client interface for vehicle repository operations
//

import Foundation
import Dependencies

/// Client interface for vehicle repository operations
/// Delegates to VehicleRepository actor for actual implementation
struct VehicleRepositoryClient: Sendable {
    let createVehicle: @Sendable (Vehicle) async throws -> Void
    let updateVehicle: @Sendable (Vehicle) async throws -> Void
    let setPrimaryVehicle: @Sendable (UUID) async throws -> Void
    let getAllVehicles: @Sendable () async throws -> [Vehicle]
    let getVehicle: @Sendable (UUID) async throws -> Vehicle?
    let deleteVehicle: @Sendable (UUID) async throws -> Void
}

// MARK: - Dependency Key

extension VehicleRepositoryClient: DependencyKey {
    static let liveValue: VehicleRepositoryClient = {
        let repository = VehicleRepository()
        return VehicleRepositoryClient(
            createVehicle: { vehicle in
                try await repository.createVehicle(vehicle)
            },
            updateVehicle: { vehicle in
                try await repository.updateVehicle(vehicle)
            },
            setPrimaryVehicle: { id in
                try await repository.setPrimaryVehicle(id)
            },
            getAllVehicles: {
                try await repository.getAllVehicles()
            },
            getVehicle: { id in
                try await repository.getVehicle(id)
            },
            deleteVehicle: { id in
                try await repository.deleteVehicle(id)
            }
        )
    }()

    static let testValue = VehicleRepositoryClient(
        createVehicle: { _ in },
        updateVehicle: { _ in },
        setPrimaryVehicle: { _ in },
        getAllVehicles: { [] },
        getVehicle: { _ in nil },
        deleteVehicle: { _ in }
    )

    static let previewValue = VehicleRepositoryClient(
        createVehicle: { _ in },
        updateVehicle: { _ in },
        setPrimaryVehicle: { _ in },
        getAllVehicles: {
            [
                Vehicle(
                    id: UUID(),
                    type: .car,
                    brand: "Tesla",
                    model: "Model 3",
                    mileage: "15000",
                    registrationDate: Date(),
                    plate: "AB-123-CD",
                    isPrimary: true,
                    documents: []
                ),
                Vehicle(
                    id: UUID(),
                    type: .car,
                    brand: "BMW",
                    model: "i4",
                    mileage: "8000",
                    registrationDate: Date(),
                    plate: "EF-456-GH",
                    isPrimary: false,
                    documents: []
                )
            ]
        },
        getVehicle: { _ in
            Vehicle(
                id: UUID(),
                type: .car,
                brand: "Tesla",
                model: "Model 3",
                mileage: "15000",
                registrationDate: Date(),
                plate: "AB-123-CD",
                isPrimary: true,
                documents: []
            )
        },
        deleteVehicle: { _ in }
    )
}

// MARK: - Convenience Methods

extension VehicleRepositoryClient {
    /// Convenience method with `by:` label for backward compatibility
    func find(by id: UUID) async throws -> Vehicle? {
        try await self.getVehicle(id)
    }

    /// Convenience method for backward compatibility - alias for getAllVehicles
    func loadAll() async throws -> [Vehicle] {
        try await self.getAllVehicles()
    }

    /// Convenience method for backward compatibility - alias for updateVehicle
    func update(_ vehicle: Vehicle) async throws {
        try await self.updateVehicle(vehicle)
    }

    /// Convenience method for backward compatibility - alias for createVehicle
    func save(_ vehicle: Vehicle) async throws {
        try await self.createVehicle(vehicle)
    }

    /// Convenience method for backward compatibility - alias for deleteVehicle
    func delete(_ id: UUID) async throws {
        try await self.deleteVehicle(id)
    }
}

// MARK: - Dependency Values Extension

extension DependencyValues {
    var vehicleRepository: VehicleRepositoryClient {
        get { self[VehicleRepositoryClient.self] }
        set { self[VehicleRepositoryClient.self] = newValue }
    }
}
