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
    var createVehicle: @Sendable (Vehicle) async throws -> Void
    var updateVehicle: @Sendable (Vehicle) async throws -> Void
    var setPrimaryVehicle: @Sendable (String) async throws -> Void
    var hasPrimaryVehicle: @Sendable () async -> Bool
    var getAllVehicles: @Sendable () async throws -> [Vehicle]
    var getVehicle: @Sendable (String) async throws -> Vehicle?
    var deleteVehicle: @Sendable (String) async throws -> Void
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
            hasPrimaryVehicle: {
                await repository.hasPrimaryVehicle()
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
        hasPrimaryVehicle: { false },
        getAllVehicles: { [] },
        getVehicle: { _ in nil },
        deleteVehicle: { _ in }
    )

    static let previewValue = VehicleRepositoryClient(
        createVehicle: { _ in },
        updateVehicle: { _ in },
        setPrimaryVehicle: { _ in },
        hasPrimaryVehicle: { false },
        getAllVehicles: {
            [
                Vehicle(
                    id: String(),
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
                    id: String(),
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
                id: String(),
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

// MARK: - Dependency Values Extension

extension DependencyValues {
    var vehicleRepository: VehicleRepositoryClient {
        get { self[VehicleRepositoryClient.self] }
        set { self[VehicleRepositoryClient.self] = newValue }
    }
}
