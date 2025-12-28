//
//  FileVehicleRepository_Spec.swift
//  InvoicerTests
//
//  Created by Nicolas Barbosa on 26/10/2025.
//

import XCTest
import Dependencies
@testable import Invoicer

final class FileVehicleRepository_Spec: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()

        testDirectory = URL(fileURLWithPath: "/tmp/test-vehicles-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)

        let vehiclesFileURL = testDirectory.appendingPathComponent(AppConstants.vehiclesFileName)
        let emptyArray: [Vehicle] = []
        let jsonData = try JSONEncoder().encode(emptyArray)
        try jsonData.write(to: vehiclesFileURL)

        fetchedVehicle = nil
        fetchedVehicles = []
    }

    override func tearDown() async throws {
        if let testDirectory = testDirectory {
            try? FileManager.default.removeItem(at: testDirectory)
        }
        repository = nil
        testDirectory = nil
        fetchedVehicle = nil
        fetchedVehicles = []
        try await super.tearDown()
    }

    func test_save_vehicleIsSavedToJSON() async throws {
        givenRepository()
        let vehicle = Vehicle.make(brand: "Tesla", model: "Model 3")
        try await whenSavingVehicle(vehicle)
        try await whenLoadingAllVehicles()
        thenVehicleCountShouldBe(1)
        thenVehicleShouldExistInList(vehicle)
    }

    func test_save_vehicleFolderIsCreated() async throws {
        givenRepository()
        let vehicle = Vehicle.make(brand: "Peugeot", model: "3008")
        try await whenSavingVehicle(vehicle)
        thenVehicleFolderShouldExist(vehicle)
    }

    func test_save_multipleVehiclesAreSavedIndependently() async throws {
        givenRepository()
        let vehicle1 = Vehicle.make(brand: "Audi", model: "A4")
        let vehicle2 = Vehicle.make(brand: "BMW", model: "X5")
        let vehicle3 = Vehicle.make(brand: "Mercedes", model: "C-Class")

        try await whenSavingVehicle(vehicle1)
        try await whenSavingVehicle(vehicle2)
        try await whenSavingVehicle(vehicle3)
        try await whenLoadingAllVehicles()

        thenVehicleCountShouldBe(3)
        thenVehicleBrandsShouldBe(["Audi", "BMW", "Mercedes"])
    }

    func test_loadAll_returnsAllVehicles() async throws {
        givenRepository()
        let vehicle1 = Vehicle.make(brand: "Toyota", model: "Camry")
        let vehicle2 = Vehicle.make(brand: "Honda", model: "Accord")

        try await whenSavingVehicle(vehicle1)
        try await whenSavingVehicle(vehicle2)
        try await whenLoadingAllVehicles()

        thenVehicleCountShouldBe(2)
    }

    func test_loadAll_returnsEmptyArrayWhenNoVehicles() async throws {
        givenRepository()
        try await whenLoadingAllVehicles()
        thenVehicleCountShouldBe(0)
    }

    func test_update_vehicleIsModifiedInJSON() async throws {
        givenRepository()
        let original = Vehicle.make(brand: "Volkswagen", model: "Golf")
        try await whenSavingVehicle(original)

        var updated = original
        updated.brand = "Volkswagen Updated"
        updated.model = "Golf GTI"

        try await whenUpdatingVehicle(updated)
        try await whenLoadingAllVehicles()

        thenVehicleCountShouldBe(1)
        thenVehicleWithIdShouldHaveBrand(original.id, expectedBrand: "Volkswagen Updated")
    }

    func test_update_vehicleFolderIsRenamedWhenBrandOrModelChanges() async throws {
        givenRepository()
        let original = Vehicle.make(brand: "Renault", model: "Clio")
        try await whenSavingVehicle(original)
        thenVehicleFolderShouldExist(original)

        var updated = original
        updated.brand = "Renault Updated"
        updated.model = "Megane"

        try await whenUpdatingVehicle(updated)
        thenVehicleFolderShouldNotExist(original)
        thenVehicleFolderShouldExist(updated)
    }

    func test_update_vehicleFolderIsNotRenamedWhenOnlyOtherPropertiesChange() async throws {
        givenRepository()
        let original = Vehicle.make(brand: "Nissan", model: "Altima", mileage: "50000")
        try await whenSavingVehicle(original)

        var updated = original
        updated.mileage = "75000"
        updated.isPrimary = true

        try await whenUpdatingVehicle(updated)
        thenVehicleFolderShouldExist(updated)
    }

    func test_delete_vehicleIsRemovedFromJSON() async throws {
        givenRepository()
        let vehicle = Vehicle.make(brand: "Mazda", model: "CX-5")
        try await whenSavingVehicle(vehicle)
        try await whenDeletingVehicle(vehicle.id)
        try await whenLoadingAllVehicles()

        thenVehicleCountShouldBe(0)
    }

    func test_delete_vehicleFolderIsRemoved() async throws {
        givenRepository()
        let vehicle = Vehicle.make(brand: "Subaru", model: "Outback")
        try await whenSavingVehicle(vehicle)
        thenVehicleFolderShouldExist(vehicle)

        try await whenDeletingVehicle(vehicle.id)
        thenVehicleFolderShouldNotExist(vehicle)
    }

    func test_delete_removesOnlySpecifiedVehicle() async throws {
        givenRepository()
        let vehicle1 = Vehicle.make(brand: "Jeep", model: "Wrangler")
        let vehicle2 = Vehicle.make(brand: "Dodge", model: "Durango")

        try await whenSavingVehicle(vehicle1)
        try await whenSavingVehicle(vehicle2)
        try await whenDeletingVehicle(vehicle1.id)
        try await whenLoadingAllVehicles()

        thenVehicleCountShouldBe(1)
        thenVehicleShouldExistInList(vehicle2)
    }

    func test_find_returnsVehicleWhenFound() async throws {
        givenRepository()
        let vehicle = Vehicle.make(brand: "Kia", model: "Sportage")
        try await whenSavingVehicle(vehicle)
        try await whenFindingVehicle(id: vehicle.id)

        thenVehicleShouldExist(vehicle)
    }

    func test_find_returnsNilWhenNotFound() async throws {
        givenRepository()
        let nonExistentId = UUID()
        try await whenFindingVehicle(id: nonExistentId)

        thenVehicleShouldBeNil()
    }

    func test_loadAll_cleansOrphanedDocuments() async throws {
        givenRepository()
        let vehicle = Vehicle.make(brand: "Hyundai", model: "Sonata")
        try await whenSavingVehicle(vehicle)

        let orphanedDocumentURL = "/path/to/non/existent/document.pdf"
        var vehicleWithOrphan = vehicle
        vehicleWithOrphan.documents = [
            Document(
                id: UUID(),
                fileURL: orphanedDocumentURL,
                name: "Orphaned Doc",
                date: Date(),
                mileage: "0",
                type: .other
            )
        ]

        try await whenUpdatingVehicle(vehicleWithOrphan)
        try await whenLoadingAllVehicles()

        thenVehicleWithIdShouldHaveDocumentCount(vehicle.id, expectedCount: 0)
    }

    private func givenRepository() {
        repository = withDependencies {
            $0.storageManager.getVehiclesDirectory = { self.testDirectory }
        } operation: {
            FileVehicleRepository()
        }
    }

    private func whenSavingVehicle(_ vehicle: Vehicle) async throws {
        try await repository.save(vehicle)
    }

    private func whenLoadingAllVehicles() async throws {
        fetchedVehicles = try await repository.loadAll()
    }

    private func whenUpdatingVehicle(_ vehicle: Vehicle) async throws {
        try await repository.update(vehicle)
    }

    private func whenDeletingVehicle(_ id: UUID) async throws {
        try await repository.delete(id)
    }

    private func whenFindingVehicle(id: UUID) async throws {
        fetchedVehicle = try await repository.find(by: id)
    }

    private func thenVehicleCountShouldBe(_ expected: Int) {
        XCTAssertEqual(fetchedVehicles.count, expected, "Should have \(expected) vehicle(s)")
    }

    private func thenVehicleShouldExistInList(_ expected: Vehicle) {
        XCTAssertTrue(
            fetchedVehicles.contains(where: { $0.id == expected.id }),
            "Vehicle should exist in list"
        )
    }

    private func thenVehicleBrandsShouldBe(_ expected: [String]) {
        let brands = fetchedVehicles.map { $0.brand }.sorted()
        XCTAssertEqual(brands, expected, "All vehicles should be independently saved")
    }

    private func thenVehicleFolderShouldExist(_ vehicle: Vehicle) {
        let folderURL = testDirectory.appendingPathComponent("\(vehicle.brand)\(vehicle.model)")
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: folderURL.path),
            "Vehicle folder should exist at \(folderURL.path)"
        )
    }

    private func thenVehicleFolderShouldNotExist(_ vehicle: Vehicle) {
        let folderURL = testDirectory.appendingPathComponent("\(vehicle.brand)\(vehicle.model)")
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: folderURL.path),
            "Vehicle folder should not exist at \(folderURL.path)"
        )
    }

    private func thenVehicleWithIdShouldHaveBrand(_ id: UUID, expectedBrand: String) {
        let vehicle = fetchedVehicles.first(where: { $0.id == id })
        XCTAssertEqual(vehicle?.brand, expectedBrand, "Brand should be updated")
    }

    private func thenVehicleWithIdShouldHaveDocumentCount(_ id: UUID, expectedCount: Int) {
        let vehicle = fetchedVehicles.first(where: { $0.id == id })
        XCTAssertEqual(
            vehicle?.documents.count,
            expectedCount,
            "Should have \(expectedCount) document(s) after cleaning orphans"
        )
    }

    private func thenVehicleShouldExist(_ expected: Vehicle) {
        XCTAssertNotNil(fetchedVehicle, "Vehicle should exist")
        XCTAssertEqual(fetchedVehicle?.id, expected.id, "Vehicle ID should match")
    }

    private func thenVehicleShouldBeNil() {
        XCTAssertNil(fetchedVehicle, "Vehicle should not exist")
    }


    private var repository: FileVehicleRepository!
    private var testDirectory: URL!
    private var fetchedVehicle: Vehicle?
    private var fetchedVehicles: [Vehicle] = []
}
