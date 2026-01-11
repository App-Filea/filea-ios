//
//  LegacyDataMigrator_Spec.swift
//  HolfyTests
//
//  Created by Claude on 2026-01-11.
//  Tests for LegacyDataMigrator
//

import XCTest
@testable import Holfy

final class LegacyDataMigrator_Spec: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()

        // Reset UserDefaults migration flag for tests
        UserDefaults.standard.removeObject(forKey: "LegacyDataMigrationCompleted_v1")
        UserDefaults.standard.synchronize()

        // Setup test database
        testDatabase = try DatabaseManager(databasePath: ":memory:")

        // Create test storage manager that points to temp directory
        let tempDir = FileManager.default.temporaryDirectory
        legacyVehiclesDir = tempDir.appendingPathComponent("Test_Vehicles_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: legacyVehiclesDir, withIntermediateDirectories: true)

        // Create test sync manager (mock)
        testSyncManager = VehicleMetadataSyncManagerClient(
            syncAfterChange: { _ in },
            exportVehicleToJSON: { _ in },
            importVehicleFromJSON: { _ in "" },
            scanAndRebuildDatabase: { _ in [] },
            hasValidMetadata: { _ in false }
        )

        // Create test storage manager (mock)
        testStorageManager = VehicleStorageManagerClient(
            saveStorageFolder: { _ in },
            restorePersistentFolder: { .notConfigured },
            getRootURL: { self.legacyVehiclesDir.deletingLastPathComponent() },
            createVehicleFolder: { _ in self.legacyVehiclesDir },
            saveFile: { _, _, _ in self.legacyVehiclesDir },
            saveJSONFile: { _, _, _ in },
            resetStorage: { },
            getVehiclesDirectory: { self.legacyVehiclesDir },
            migrateContent: { _, _ in },
            deleteOldVehiclesDirectory: { _ in },
            stopCurrentSecurityScopedAccess: { }
        )

        migrator = LegacyDataMigrator(
            database: testDatabase,
            syncManager: testSyncManager,
            storageManager: testStorageManager
        )
    }

    override func tearDown() async throws {
        // Cleanup test files
        if FileManager.default.fileExists(atPath: legacyVehiclesDir.path) {
            try? FileManager.default.removeItem(at: legacyVehiclesDir)
        }

        testDatabase = nil
        migrator = nil
        testSyncManager = nil
        testStorageManager = nil

        try await super.tearDown()
    }

    // MARK: - Tests

    func test_migrateIfNeeded_noLegacyData() async throws {
        let result = await migrator.migrateIfNeeded()

        thenResultShouldBe(.noLegacyData, actual: result)
        thenMigrationShouldBeMarkedComplete()
    }

    func test_migrateIfNeeded_alreadyMigrated() async throws {
        givenMigrationAlreadyCompleted()

        let result = await migrator.migrateIfNeeded()

        thenResultShouldBe(.alreadyMigrated, actual: result)
    }

    // MARK: - Helpers Given

    private func givenMigrationAlreadyCompleted() {
        UserDefaults.standard.set(true, forKey: "LegacyDataMigrationCompleted_v1")
        UserDefaults.standard.synchronize()
    }

    // MARK: - Helpers Then

    private func thenResultShouldBe(_ expected: MigrationResult, actual: MigrationResult) {
        switch (expected, actual) {
        case (.noLegacyData, .noLegacyData):
            XCTAssertTrue(true, "Result should be noLegacyData")
        case (.alreadyMigrated, .alreadyMigrated):
            XCTAssertTrue(true, "Result should be alreadyMigrated")
        case (.success(let ev, let ed), .success(let av, let ad)):
            XCTAssertEqual(ev, av, "Vehicles migrated count should match")
            XCTAssertEqual(ed, ad, "Documents migrated count should match")
        default:
            XCTFail("Result mismatch - expected: \(expected.userMessage), actual: \(actual.userMessage)")
        }
    }

    private func thenMigrationShouldBeMarkedComplete() {
        let isComplete = UserDefaults.standard.bool(forKey: "LegacyDataMigrationCompleted_v1")
        XCTAssertTrue(isComplete, "Migration should be marked as completed in UserDefaults")
    }

    // MARK: - Variables

    private var testDatabase: DatabaseManager!
    private var migrator: LegacyDataMigrator!
    private var testSyncManager: VehicleMetadataSyncManagerClient!
    private var testStorageManager: VehicleStorageManagerClient!
    private var legacyVehiclesDir: URL!
}
