//
//  VehicleRepository_Spec.swift
//  InvoicerTests
//
//  Created by Nicolas Barbosa on 26/10/2025.
//

import XCTest
import Dependencies
@testable import Invoicer

final class VehicleRepository_Spec: XCTestCase {

    func test_createVehicle_savesToGRDBAndCallsFileRepo() async throws {
        let vehicle = Vehicle.make(brand: "Tesla", model: "Model 3")
        givenRepository()
        try await whenCreatingVehicle(vehicle)
        thenGRDBCreateShouldBeCalled(with: vehicle)
        thenSyncManagerShouldBeCalled(with: vehicle.id)
        thenFileRepoSaveShouldBeCalled()
        thenStorageManagerCreateFolderShouldBeCalled(with: "TeslaModel 3")
    }

    func test_updateVehicle_updatesInGRDBAndCallsFileRepo() async throws {
        let vehicle = Vehicle.make(brand: "BMW", model: "X5")
        givenRepository()
        try await whenUpdatingVehicle(vehicle)
        thenGRDBUpdateShouldBeCalled(with: vehicle)
        thenSyncManagerShouldBeCalled(with: vehicle.id)
        thenFileRepoUpdateShouldBeCalled()
    }

    func test_setPrimaryVehicle_callsGRDBAndSyncsAllVehicles() async throws {
        let vehicleId = UUID()
        let vehicles = [
            Vehicle.make(id: vehicleId, brand: "Audi", model: "A4"),
            Vehicle.make(brand: "BMW", model: "X3")
        ]
        givenRepository(vehicles: vehicles)
        try await whenSettingPrimaryVehicle(vehicleId)
        thenGRDBSetPrimaryShouldBeCalled(with: vehicleId)
        thenSyncManagerShouldBeCalledMultipleTimes(withCount: 2)
        thenFileRepoLoadAllShouldBeCalled()
    }

    func test_getAllVehicles_fetchesFromGRDBAndSorts() async throws {
        let vehicles = [
            Vehicle.make(brand: "BMW", model: "X5", isPrimary: false),
            Vehicle.make(brand: "Tesla", model: "Model 3", isPrimary: true),
            Vehicle.make(brand: "Audi", model: "A4", isPrimary: false)
        ]
        givenRepository(vehicles: vehicles)
        try await whenGettingAllVehicles()
        thenFetchedVehiclesShouldBeSorted()
    }

    func test_getVehicle_fetchesFromGRDB() async throws {
        let vehicleId = UUID()
        let vehicle = Vehicle.make(id: vehicleId, brand: "Mercedes", model: "C-Class")
        givenRepository(vehicles: [vehicle])
        try await whenGettingVehicle(vehicleId)
        thenGRDBFetchShouldBeCalled(with: vehicleId)
        thenFetchedVehicleShouldMatch(vehicle)
    }

    func test_deleteVehicle_deletesFromGRDBAndFileRepo() async throws {
        let vehicleId = UUID()
        givenRepository()
        try await whenDeletingVehicle(vehicleId)
        thenGRDBDeleteShouldBeCalled(with: vehicleId)
        thenFileRepoDeleteShouldBeCalled(with: vehicleId)
    }

    private func givenRepository(vehicles: [Vehicle] = []) {
        repository = withDependencies {

            $0.vehicleDatabaseRepository.create = { vehicle, fileUrlPath in
                self.databaseRepoCreateCalled = true
                self.databaseRepoCreateVehicle = vehicle
            }

            $0.vehicleDatabaseRepository.update = { vehicle, fileUrlPath in
                self.databaseRepoUpdateCalled = true
                self.databaseRepoUpdateVehicle = vehicle
            }

            $0.vehicleDatabaseRepository.setPrimary = { id in
                self.databaseRepoSetPrimaryCalled = true
                self.databaseRepoSetPrimaryId = id
            }

            $0.vehicleDatabaseRepository.fetchAll = {
                self.databaseRepoFetchAllCalled = true
                return vehicles
            }

            $0.vehicleDatabaseRepository.fetch = { id in
                self.databaseRepoFetchCalled = true
                self.databaseRepoFetchId = id
                return vehicles.first(where: { $0.id == id })
            }

            $0.vehicleDatabaseRepository.delete = { id in
                self.databaseRepoDeleteCalled = true
                self.databaseRepoDeleteId = id
            }

            $0.fileVehicleRepository.save = { vehicle in
                self.fileRepoSaveCalled = true
                self.fileRepoSaveVehicle = vehicle
            }

            $0.fileVehicleRepository.update = { vehicle in
                self.fileRepoUpdateCalled = true
                self.fileRepoUpdateVehicle = vehicle
            }

            $0.fileVehicleRepository.delete = { id in
                self.fileRepoDeleteCalled = true
                self.fileRepoDeleteId = id
            }

            $0.fileVehicleRepository.loadAll = {
                self.fileRepoLoadAllCalled = true
                return vehicles
            }

            $0.syncManagerClient.syncAfterChange = { vehicleId in
                self.syncManagerCallCount += 1
                self.syncManagerVehicleIds.append(vehicleId)
            }

            $0.storageManager.getRootURL = {
                return URL(fileURLWithPath: "/test/root")
            }

            $0.storageManager.createVehicleFolder = { name in
                self.storageManagerCreateFolderCalled = true
                self.storageManagerCreateFolderName = name
                return URL(fileURLWithPath: "/test/root/Vehicles/\(name)")
            }
        } operation: {
            VehicleRepository()
        }
    }

    private func whenCreatingVehicle(_ vehicle: Vehicle) async throws {
        try await repository.createVehicle(vehicle)
    }

    private func whenUpdatingVehicle(_ vehicle: Vehicle) async throws {
        try await repository.updateVehicle(vehicle)
    }

    private func whenSettingPrimaryVehicle(_ id: UUID) async throws {
        try await repository.setPrimaryVehicle(id)
    }

    private func whenGettingAllVehicles() async throws {
        fetchedVehicles = try await repository.getAllVehicles()
    }

    private func whenGettingVehicle(_ id: UUID) async throws {
        fetchedVehicle = try await repository.getVehicle(id)
    }

    private func whenDeletingVehicle(_ id: UUID) async throws {
        try await repository.deleteVehicle(id)
    }

    private func thenGRDBCreateShouldBeCalled(with expected: Vehicle) {
        XCTAssertTrue(databaseRepoCreateCalled, "GRDB create should be called")
        XCTAssertEqual(databaseRepoCreateVehicle?.id, expected.id, "GRDB should receive correct vehicle")
        XCTAssertEqual(databaseRepoCreateVehicle?.brand, expected.brand, "Brand should match")
        XCTAssertEqual(databaseRepoCreateVehicle?.model, expected.model, "Model should match")
    }

    private func thenGRDBUpdateShouldBeCalled(with expected: Vehicle) {
        XCTAssertTrue(databaseRepoUpdateCalled, "GRDB update should be called")
        XCTAssertEqual(databaseRepoUpdateVehicle?.id, expected.id, "GRDB should receive correct vehicle")
        XCTAssertEqual(databaseRepoUpdateVehicle?.brand, expected.brand, "Brand should match")
        XCTAssertEqual(databaseRepoUpdateVehicle?.model, expected.model, "Model should match")
    }

    private func thenGRDBSetPrimaryShouldBeCalled(with expectedId: UUID) {
        XCTAssertTrue(databaseRepoSetPrimaryCalled, "GRDB setPrimary should be called")
        XCTAssertEqual(databaseRepoSetPrimaryId, expectedId, "GRDB should receive correct vehicle ID")
    }

    private func thenGRDBFetchShouldBeCalled(with expectedId: UUID) {
        XCTAssertTrue(databaseRepoFetchCalled, "GRDB fetch should be called")
        XCTAssertEqual(databaseRepoFetchId, expectedId, "GRDB should receive correct vehicle ID")
    }

    private func thenGRDBDeleteShouldBeCalled(with expectedId: UUID) {
        XCTAssertTrue(databaseRepoDeleteCalled, "GRDB delete should be called")
        XCTAssertEqual(databaseRepoDeleteId, expectedId, "GRDB should receive correct vehicle ID")
    }

    private func thenSyncManagerShouldBeCalled(with expectedId: UUID) {
        XCTAssertEqual(syncManagerCallCount, 1, "Sync manager should be called once")
        XCTAssertTrue(syncManagerVehicleIds.contains(expectedId), "Sync manager should receive correct vehicle ID")
    }

    private func thenSyncManagerShouldBeCalledMultipleTimes(withCount expectedCount: Int) {
        XCTAssertEqual(syncManagerCallCount, expectedCount, "Sync manager should be called \(expectedCount) times")
    }

    private func thenFileRepoSaveShouldBeCalled() {
        XCTAssertTrue(fileRepoSaveCalled, "File repository save should be called")
        XCTAssertNotNil(fileRepoSaveVehicle, "File repository should receive vehicle")
    }

    private func thenFileRepoUpdateShouldBeCalled() {
        XCTAssertTrue(fileRepoUpdateCalled, "File repository update should be called")
        XCTAssertNotNil(fileRepoUpdateVehicle, "File repository should receive vehicle")
    }

    private func thenFileRepoDeleteShouldBeCalled(with expectedId: UUID) {
        XCTAssertTrue(fileRepoDeleteCalled, "File repository delete should be called")
        XCTAssertEqual(fileRepoDeleteId, expectedId, "File repository should receive correct vehicle ID")
    }

    private func thenFileRepoLoadAllShouldBeCalled() {
        XCTAssertTrue(fileRepoLoadAllCalled, "File repository loadAll should be called")
    }

    private func thenStorageManagerCreateFolderShouldBeCalled(with expectedName: String) {
        XCTAssertTrue(storageManagerCreateFolderCalled, "Storage manager should create folder")
        XCTAssertEqual(storageManagerCreateFolderName, expectedName, "Folder name should match brand+model")
    }

    private func thenFetchedVehicleShouldMatch(_ expected: Vehicle) {
        XCTAssertNotNil(fetchedVehicle, "Fetched vehicle should not be nil")
        XCTAssertEqual(fetchedVehicle?.id, expected.id, "Vehicle ID should match")
        XCTAssertEqual(fetchedVehicle?.brand, expected.brand, "Brand should match")
        XCTAssertEqual(fetchedVehicle?.model, expected.model, "Model should match")
    }

    private func thenFetchedVehiclesShouldBeSorted() {
        XCTAssertEqual(fetchedVehicles.count, 3, "Should have 3 vehicles")
        XCTAssertTrue(fetchedVehicles[0].isPrimary, "First vehicle should be primary")
        XCTAssertEqual(fetchedVehicles[0].brand, "Tesla", "Primary vehicle should be Tesla")
        XCTAssertFalse(fetchedVehicles[1].isPrimary, "Second vehicle should not be primary")
        XCTAssertEqual(fetchedVehicles[1].brand, "Audi", "Second vehicle should be Audi (alphabetically first)")
        XCTAssertFalse(fetchedVehicles[2].isPrimary, "Third vehicle should not be primary")
        XCTAssertEqual(fetchedVehicles[2].brand, "BMW", "Third vehicle should be BMW")
    }

    private var repository: VehicleRepository!
    private var databaseRepoCreateCalled: Bool = false
    private var databaseRepoCreateVehicle: Vehicle?
    private var databaseRepoUpdateCalled: Bool = false
    private var databaseRepoUpdateVehicle: Vehicle?
    private var databaseRepoSetPrimaryCalled: Bool = false
    private var databaseRepoSetPrimaryId: UUID?
    private var databaseRepoFetchAllCalled: Bool = false
    private var databaseRepoFetchCalled: Bool = false
    private var databaseRepoFetchId: UUID?
    private var databaseRepoDeleteCalled: Bool = false
    private var databaseRepoDeleteId: UUID?
    private var fileRepoSaveCalled: Bool = false
    private var fileRepoSaveVehicle: Vehicle?
    private var fileRepoUpdateCalled: Bool = false
    private var fileRepoUpdateVehicle: Vehicle?
    private var fileRepoDeleteCalled: Bool = false
    private var fileRepoDeleteId: UUID?
    private var fileRepoLoadAllCalled: Bool = false
    private var storageManagerCreateFolderCalled: Bool = false
    private var storageManagerCreateFolderName: String?
    private var syncManagerCallCount: Int = 0
    private var syncManagerVehicleIds: [UUID] = []
    private var fetchedVehicle: Vehicle?
    private var fetchedVehicles: [Vehicle] = []
}
