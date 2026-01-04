//
//  FileVehicleRepositoryClient.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 18/10/2025.
//

import Foundation
import Dependencies

struct FileVehicleRepositoryClient {
    var loadAll: @Sendable () async throws -> [Vehicle]
    var save: @Sendable (Vehicle) async throws -> Void
    var update: @Sendable (Vehicle) async throws -> Void
    var delete: @Sendable (String) async throws -> Void
    var find: @Sendable (String) async throws -> Vehicle?
}

extension FileVehicleRepositoryClient: DependencyKey {
    nonisolated static let liveValue: FileVehicleRepositoryClient = {
        let repository = FileVehicleRepository()
        return FileVehicleRepositoryClient(
            loadAll: {
                try await repository.loadAll()
            },
            save: {
                try await repository.save($0)
            },
            update: {
                try await repository.update($0)
            },
            delete: {
                try await repository.delete($0)
            },
            find: {
                try await repository.find(by: $0)
            }
        )
    }()

    nonisolated static let testValue: FileVehicleRepositoryClient = FileVehicleRepositoryClient(
        loadAll: { return [] },
        save: { _ in },
        update: { _ in },
        delete: { _ in },
        find: { _ in return nil }
    )
}

extension DependencyValues {
    var fileVehicleRepository: FileVehicleRepositoryClient {
        get { self[FileVehicleRepositoryClient.self] }
        set { self[FileVehicleRepositoryClient.self] = newValue }
    }
}
