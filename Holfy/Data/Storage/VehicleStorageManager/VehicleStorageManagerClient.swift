//
//  VehicleStorageManagerClient.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 26/10/2025.
//

import Foundation
import Dependencies

struct VehicleStorageManagerClient {
    var saveStorageFolder: @Sendable (URL) async throws -> Void
    var restorePersistentFolder: @Sendable () async -> VehicleStorageManager.StorageState
    var getRootURL: @Sendable () async -> URL?
    var createVehicleFolder: @Sendable (String) async throws -> URL
    var saveFile: @Sendable (String, String, Data) async throws -> URL
    var resetStorage: @Sendable () async -> Void
    var getVehiclesDirectory: @Sendable () async throws -> URL
    var migrateContent: @Sendable (URL, URL) async throws -> Void
    var deleteOldVehiclesDirectory: @Sendable (URL) async throws -> Void
    var stopCurrentSecurityScopedAccess: @Sendable () async -> Void
}

extension VehicleStorageManagerClient: DependencyKey {
    nonisolated static let liveValue: VehicleStorageManagerClient = {
        let manager = VehicleStorageManager()
        return VehicleStorageManagerClient(
            saveStorageFolder: { url in
                try await manager.saveStorageFolder(url)
            },
            restorePersistentFolder: {
                await manager.restorePersistentFolder()
            },
            getRootURL: {
                await manager.getRootURL()
            },
            createVehicleFolder: { name in
                try await manager.createVehicleFolder(named: name)
            },
            saveFile: { vehicleName, filename, data in
                try await manager.saveFile(forVehicle: vehicleName, filename: filename, data: data)
            },
            resetStorage: {
                await manager.resetStorage()
            },
            getVehiclesDirectory: {
                try await manager.getVehiclesDirectory()
            },
            migrateContent: { oldURL, newURL in
                try await manager.migrateContent(from: oldURL, to: newURL)
            },
            deleteOldVehiclesDirectory: { url in
                try await manager.deleteOldVehiclesDirectory(at: url)
            },
            stopCurrentSecurityScopedAccess: {
                await manager.stopCurrentSecurityScopedAccess()
            }
        )
    }()

    nonisolated static let testValue: VehicleStorageManagerClient = VehicleStorageManagerClient(
        saveStorageFolder: { _ in
            unimplemented("saveStorageFolder")
        },
        restorePersistentFolder: { return .notConfigured },
        getRootURL: { return nil },
        createVehicleFolder: { _ in return URL(fileURLWithPath: "") },
        saveFile: { _, _, _ in return URL(fileURLWithPath: "") },
        resetStorage: { },
        getVehiclesDirectory: { return URL(fileURLWithPath: "") },
        migrateContent: { _, _ in
            unimplemented("migrateContent")
        },
        deleteOldVehiclesDirectory: { _ in
            unimplemented("deleteOldVehiclesDirectory")
        },
        stopCurrentSecurityScopedAccess: {
            unimplemented("stopCurrentSecurityScopedAccess")
        }
    )
}

extension DependencyValues {
    var storageManager: VehicleStorageManagerClient {
        get { self[VehicleStorageManagerClient.self] }
        set { self[VehicleStorageManagerClient.self] = newValue }
    }
}
