//
//  LegacyDataMigratorClient.swift
//  Holfy
//
//  Created by Claude on 2026-01-11.
//  Provides dependency injection for LegacyDataMigrator
//

import Foundation
import Dependencies

struct LegacyDataMigratorClient: Sendable {
    var migrateIfNeeded: @Sendable () async -> MigrationResult
}

// MARK: - Dependency Key

extension LegacyDataMigratorClient: DependencyKey {
    nonisolated static let liveValue: LegacyDataMigratorClient = {
        @Dependency(\.database) var database
        @Dependency(\.syncManagerClient) var syncManager
        @Dependency(\.storageManager) var storageManager

        let migrator = LegacyDataMigrator(
            database: database,
            syncManager: syncManager,
            storageManager: storageManager
        )

        return LegacyDataMigratorClient(
            migrateIfNeeded: {
                await migrator.migrateIfNeeded()
            }
        )
    }()

    nonisolated static let testValue: LegacyDataMigratorClient = LegacyDataMigratorClient(
        migrateIfNeeded: { .alreadyMigrated }
    )
}

extension DependencyValues {
    var legacyMigrator: LegacyDataMigratorClient {
        get { self[LegacyDataMigratorClient.self] }
        set { self[LegacyDataMigratorClient.self] = newValue }
    }
}
