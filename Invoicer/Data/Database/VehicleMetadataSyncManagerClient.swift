//
//  VehicleMetadataSyncManagerClient.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 26/10/2025.
//

import Foundation
import Dependencies

struct VehicleMetadataSyncManagerClient: Sendable {
    var syncAfterChange: @Sendable (String) async throws -> Void
    var exportVehicleToJSON: @Sendable (String) async throws -> Void
    var importVehicleFromJSON: @Sendable (String) async throws -> String
    var scanAndRebuildDatabase: @Sendable (String) async throws -> [String]
    var hasValidMetadata: @Sendable (String) -> Bool
}

// MARK: - Dependency Key

extension VehicleMetadataSyncManagerClient: DependencyKey {
    nonisolated static let liveValue: VehicleMetadataSyncManagerClient = {
        @Dependency(\.database) var database
        let syncManager = VehicleMetadataSyncManager(database: database)

        return VehicleMetadataSyncManagerClient(
            syncAfterChange: { vehicleId in
                try await syncManager.syncAfterChange(vehicleId: vehicleId)
            },
            exportVehicleToJSON: { vehicleId in
                try await syncManager.exportVehicleToJSON(vehicleId: vehicleId)
            },
            importVehicleFromJSON: { folderPath in
                try await syncManager.importVehicleFromJSON(folderPath: folderPath)
            },
            scanAndRebuildDatabase: { rootFolderPath in
                try await syncManager.scanAndRebuildDatabase(rootFolderPath: rootFolderPath)
            },
            hasValidMetadata: { folderPath in
                syncManager.hasValidMetadata(folderPath: folderPath)
            }
        )
    }()

    nonisolated static let testValue: VehicleMetadataSyncManagerClient = VehicleMetadataSyncManagerClient(
        syncAfterChange: { _ in },
        exportVehicleToJSON: { _ in },
        importVehicleFromJSON: { _ in "" },
        scanAndRebuildDatabase: { _ in [] },
        hasValidMetadata: { _ in false }
    )
}

extension DependencyValues {
    var syncManagerClient: VehicleMetadataSyncManagerClient {
        get { self[VehicleMetadataSyncManagerClient.self] }
        set { self[VehicleMetadataSyncManagerClient.self] = newValue }
    }
}
