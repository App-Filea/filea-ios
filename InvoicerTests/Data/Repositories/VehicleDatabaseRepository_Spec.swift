//
//  VehicleDatabaseRepository_Spec.swift
//  InvoicerTests
//
//  Created by Nicolas Barbosa on 25/10/2025.
//

import XCTest
@testable import Invoicer

final class VehicleDatabaseRepository_Spec: XCTestCase {
    
    override func setUp() async throws {
        try await super.setUp()
        testDatabase = try DatabaseManager(databasePath: ":memory:")
        repository = VehicleDatabaseRepository(database: testDatabase)
        fetchedVehicle = nil
        fetchedVehicles = []
        vehicleCount = 0
    }

    override func tearDown() async throws {
        testDatabase = nil
        repository = nil
        fetchedVehicle = nil
        fetchedVehicles = []
        vehicleCount = 0
        try await super.tearDown()
    }

    func test_create_vehicleExistsInDatabase() async throws {
        let vehicle = Vehicle.make(brand: "Tesla", model: "Model 3", plate: "ABC-123")
        try await givenVehicleCreated(vehicle)
        try await whenFetchingVehicle(id: vehicle.id)
        thenVehicleShouldExist(vehicle)
    }

    func test_create_allPropertiesAreCorrectlySaved() async throws {
        let vehicle = Vehicle.make(
            type: .car,
            brand: "BMW",
            model: "X5",
            mileage: "75000",
            plate: "XYZ-789",
            isPrimary: false
        )
        try await givenVehicleCreated(vehicle, at: "/test/vehicles/bmw")
        try await whenFetchingVehicle(id: vehicle.id)
        thenVehicleShouldMatchPropertiesOf(vehicle)
    }

    func test_create_vehicleTypeIsCorrectlySaved() async throws {
        let motorcycle = Vehicle.make(type: .motorcycle, brand: "Harley", model: "Iron 883")
        let truck = Vehicle.make(type: .truck, brand: "Ford", model: "F-150")
        let bicycle = Vehicle.make(type: .bicycle, brand: "Trek", model: "FX 3")

        try await givenVehicleCreated(motorcycle, at: "/test/motorcycle")
        try await givenVehicleCreated(truck, at: "/test/truck")
        try await givenVehicleCreated(bicycle, at: "/test/bicycle")

        try await whenFetchingVehicle(id: motorcycle.id)
        thenVehicleTypeShouldBe(.motorcycle)

        try await whenFetchingVehicle(id: truck.id)
        thenVehicleTypeShouldBe(.truck)

        try await whenFetchingVehicle(id: bicycle.id)
        thenVehicleTypeShouldBe(.bicycle)
    }

    func test_create_optionalMileageIsHandled() async throws {
        let vehicleWithMileage = Vehicle.make(mileage: "100000")
        let vehicleWithoutMileage = Vehicle.make(mileage: nil)

        try await givenVehicleCreated(vehicleWithMileage, at: "/test/with-mileage")
        try await givenVehicleCreated(vehicleWithoutMileage, at: "/test/without-mileage")

        try await whenFetchingVehicle(id: vehicleWithMileage.id)
        thenVehicleMileageShouldBe("100000")

        try await whenFetchingVehicle(id: vehicleWithoutMileage.id)
        thenVehicleMileageShouldBeNil()
    }

    func test_create_multipleVehiclesAreSavedIndependently() async throws {
        let vehicle1 = Vehicle.make(brand: "Audi", model: "A4", plate: "AAA-111")
        let vehicle2 = Vehicle.make(brand: "Mercedes", model: "C-Class", plate: "BBB-222")
        let vehicle3 = Vehicle.make(brand: "Volkswagen", model: "Golf", plate: "CCC-333")

        try await givenVehicleCreated(vehicle1, at: "/test/audi")
        try await givenVehicleCreated(vehicle2, at: "/test/mercedes")
        try await givenVehicleCreated(vehicle3, at: "/test/vw")

        try await whenFetchingAllVehicles()
        thenVehicleCountShouldBe(3)
        thenVehicleBrandsShouldBe(["Audi", "Mercedes", "Volkswagen"])
    }

    func test_create_primaryFlagIsCorrectlySaved() async throws {
        let primaryVehicle = Vehicle.make(brand: "Toyota", isPrimary: true)
        let secondaryVehicle = Vehicle.make(brand: "Honda", isPrimary: false)

        try await givenVehicleCreated(primaryVehicle, at: "/test/primary")
        try await givenVehicleCreated(secondaryVehicle, at: "/test/secondary")

        try await whenFetchingVehicle(id: primaryVehicle.id)
        thenVehiclePrimaryFlagShouldBe(true)

        try await whenFetchingVehicle(id: secondaryVehicle.id)
        thenVehiclePrimaryFlagShouldBe(false)
    }

    func test_create_registrationDateIsCorrectlySaved() async throws {
        let registrationDate = Date(timeIntervalSince1970: 1609459200)
        let vehicle = Vehicle.make(registrationDate: registrationDate)

        try await givenVehicleCreated(vehicle, at: "/test/date")
        try await whenFetchingVehicle(id: vehicle.id)
        thenVehicleRegistrationDateShouldBe(registrationDate)
    }

    func test_update_allPropertiesAreCorrectlyUpdated() async throws {
        let original = Vehicle.make(brand: "Tesla", model: "Model 3", plate: "ABC-123")
        try await givenVehicleCreated(original)

        var updated = original
        updated.brand = "BMW"
        updated.model = "X5"
        updated.plate = "XYZ-789"
        updated.mileage = "100000"

        try await whenUpdatingVehicle(updated, at: "/test/vehicles/updated")
        try await whenFetchingVehicle(id: original.id)
        thenVehicleShouldMatchPropertiesOf(updated)
    }

    func test_update_vehicleIdRemainsUnchanged() async throws {
        let original = Vehicle.make(brand: "Audi", model: "A4")
        try await givenVehicleCreated(original)

        var updated = original
        updated.brand = "Mercedes"
        updated.model = "C-Class"

        try await whenUpdatingVehicle(updated)
        try await whenFetchingVehicle(id: original.id)
        thenVehicleIdShouldBe(original.id)
    }

    func test_update_vehicleTypeCanBeModified() async throws {
        let original = Vehicle.make(type: .car, brand: "Honda", model: "Civic")
        try await givenVehicleCreated(original)

        var updated = original
        updated.type = .motorcycle

        try await whenUpdatingVehicle(updated)
        try await whenFetchingVehicle(id: original.id)
        thenVehicleTypeShouldBe(.motorcycle)
    }

    func test_update_mileageCanBeAddedOrRemoved() async throws {
        let withMileage = Vehicle.make(mileage: "50000")
        let withoutMileage = Vehicle.make(mileage: nil)

        try await givenVehicleCreated(withMileage, at: "/test/with")
        try await givenVehicleCreated(withoutMileage, at: "/test/without")

        var addMileage = withoutMileage
        addMileage.mileage = "75000"

        var removeMileage = withMileage
        removeMileage.mileage = nil

        try await whenUpdatingVehicle(addMileage, at: "/test/without")
        try await whenFetchingVehicle(id: withoutMileage.id)
        thenVehicleMileageShouldBe("75000")

        try await whenUpdatingVehicle(removeMileage, at: "/test/with")
        try await whenFetchingVehicle(id: withMileage.id)
        thenVehicleMileageShouldBeNil()
    }

    func test_update_primaryFlagCanBeModified() async throws {
        let original = Vehicle.make(isPrimary: false)
        try await givenVehicleCreated(original)

        var updated = original
        updated.isPrimary = true

        try await whenUpdatingVehicle(updated)
        try await whenFetchingVehicle(id: original.id)
        thenVehiclePrimaryFlagShouldBe(true)
    }

    func test_update_registrationDateCanBeModified() async throws {
        let originalDate = Date(timeIntervalSince1970: 1609459200)
        let newDate = Date(timeIntervalSince1970: 1640995200)

        let original = Vehicle.make(registrationDate: originalDate)
        try await givenVehicleCreated(original)

        var updated = original
        updated.registrationDate = newDate

        try await whenUpdatingVehicle(updated)
        try await whenFetchingVehicle(id: original.id)
        thenVehicleRegistrationDateShouldBe(newDate)
    }

    func test_update_folderPathCanBeChanged() async throws {
        let original = Vehicle.make(brand: "Volkswagen", model: "Golf")
        try await givenVehicleCreated(original, at: "/test/old/path")

        var updated = original
        updated.brand = "Volkswagen Updated"

        try await whenUpdatingVehicle(updated, at: "/test/new/path")
        try await whenFetchingVehicle(id: original.id)
        thenVehicleShouldMatchPropertiesOf(updated)
    }

    func test_fetch_returnsVehicleWhenFound() async throws {
        let vehicle = Vehicle.make(brand: "Renault", model: "Clio")
        try await givenVehicleCreated(vehicle)

        try await whenFetchingVehicle(id: vehicle.id)
        thenVehicleShouldExist(vehicle)
    }

    func test_fetch_returnsNilWhenNotFound() async throws {
        let nonExistentId = UUID()

        try await whenFetchingVehicle(id: nonExistentId)
        thenVehicleShouldBeNil()
    }

    func test_fetchAll_returnsAllVehicles() async throws {
        let vehicle1 = Vehicle.make(brand: "Peugeot", model: "208")
        let vehicle2 = Vehicle.make(brand: "Citroën", model: "C3")
        let vehicle3 = Vehicle.make(brand: "Renault", model: "Clio")

        try await givenVehicleCreated(vehicle1, at: "/test/peugeot")
        try await givenVehicleCreated(vehicle2, at: "/test/citroen")
        try await givenVehicleCreated(vehicle3, at: "/test/renault")

        try await whenFetchingAllVehicles()
        thenVehicleCountShouldBe(3)
    }

    func test_fetchAll_returnsEmptyArrayWhenNoVehicles() async throws {
        try await whenFetchingAllVehicles()
        thenVehicleCountShouldBe(0)
    }

    func test_fetchPrimary_returnsPrimaryVehicleWhenExists() async throws {
        let primary = Vehicle.make(brand: "Toyota", model: "Camry", isPrimary: true)
        let secondary = Vehicle.make(brand: "Honda", model: "Accord", isPrimary: false)

        try await givenVehicleCreated(primary, at: "/test/primary")
        try await givenVehicleCreated(secondary, at: "/test/secondary")

        try await whenFetchingPrimaryVehicle()
        thenVehicleShouldExist(primary)
        thenVehiclePrimaryFlagShouldBe(true)
    }

    func test_fetchPrimary_returnsNilWhenNoPrimaryVehicle() async throws {
        let vehicle = Vehicle.make(isPrimary: false)
        try await givenVehicleCreated(vehicle)

        try await whenFetchingPrimaryVehicle()
        thenVehicleShouldBeNil()
    }

    func test_fetchWithDocuments_returnsVehicleWithoutDocuments() async throws {
        let vehicle = Vehicle.make(brand: "Porsche", model: "911")
        try await givenVehicleCreated(vehicle)

        try await whenFetchingVehicleWithDocuments(id: vehicle.id)
        thenVehicleShouldExist(vehicle)
        thenDocumentCountShouldBe(0)
    }

    func test_fetchWithDocuments_returnsNilWhenVehicleNotFound() async throws {
        let nonExistentId = UUID()

        try await whenFetchingVehicleWithDocuments(id: nonExistentId)
        thenVehicleShouldBeNil()
    }

    func test_setPrimary_setsVehicleAsPrimary() async throws {
        let vehicle1 = Vehicle.make(brand: "Mazda", model: "CX-5", isPrimary: false)
        let vehicle2 = Vehicle.make(brand: "Subaru", model: "Outback", isPrimary: false)

        try await givenVehicleCreated(vehicle1, at: "/test/mazda")
        try await givenVehicleCreated(vehicle2, at: "/test/subaru")

        try await whenSettingPrimaryVehicle(id: vehicle1.id)
        try await whenFetchingVehicle(id: vehicle1.id)
        thenVehiclePrimaryFlagShouldBe(true)
    }

    func test_setPrimary_removesOtherPrimaryFlags() async throws {
        let vehicle1 = Vehicle.make(brand: "Nissan", model: "Altima", isPrimary: true)
        let vehicle2 = Vehicle.make(brand: "Hyundai", model: "Sonata", isPrimary: false)

        try await givenVehicleCreated(vehicle1, at: "/test/nissan")
        try await givenVehicleCreated(vehicle2, at: "/test/hyundai")

        try await whenSettingPrimaryVehicle(id: vehicle2.id)

        try await whenFetchingVehicle(id: vehicle1.id)
        thenVehiclePrimaryFlagShouldBe(false)

        try await whenFetchingVehicle(id: vehicle2.id)
        thenVehiclePrimaryFlagShouldBe(true)
    }

    func test_delete_removesVehicleFromDatabase() async throws {
        let vehicle = Vehicle.make(brand: "Kia", model: "Sportage")
        try await givenVehicleCreated(vehicle)

        try await whenDeletingVehicle(id: vehicle.id)
        try await whenFetchingVehicle(id: vehicle.id)
        thenVehicleShouldBeNil()
    }

    func test_delete_removesOnlySpecifiedVehicle() async throws {
        let vehicle1 = Vehicle.make(brand: "Jeep", model: "Wrangler")
        let vehicle2 = Vehicle.make(brand: "Dodge", model: "Durango")

        try await givenVehicleCreated(vehicle1, at: "/test/jeep")
        try await givenVehicleCreated(vehicle2, at: "/test/dodge")

        try await whenDeletingVehicle(id: vehicle1.id)
        try await whenFetchingAllVehicles()
        thenVehicleCountShouldBe(1)

        try await whenFetchingVehicle(id: vehicle2.id)
        thenVehicleShouldExist(vehicle2)
    }

    func test_count_returnsCorrectNumberOfVehicles() async throws {
        let vehicle1 = Vehicle.make(brand: "Chevrolet", model: "Malibu")
        let vehicle2 = Vehicle.make(brand: "GMC", model: "Terrain")
        let vehicle3 = Vehicle.make(brand: "Buick", model: "Enclave")

        try await givenVehicleCreated(vehicle1, at: "/test/chevrolet")
        try await givenVehicleCreated(vehicle2, at: "/test/gmc")
        try await givenVehicleCreated(vehicle3, at: "/test/buick")

        try await whenCountingVehicles()
        thenCountShouldBe(3)
    }

    func test_count_returnsZeroWhenNoVehicles() async throws {
        try await whenCountingVehicles()
        thenCountShouldBe(0)
    }

    private func givenVehicleCreated(
        _ vehicle: Vehicle,
        at folderPath: String? = nil
    ) async throws {
        let path = folderPath ?? "/test/vehicles/\(vehicle.id.uuidString)"
        try await repository.create(vehicle: vehicle, folderPath: path)
    }

    private func whenFetchingVehicle(id: UUID) async throws {
        fetchedVehicle = try await repository.fetch(id: id)
    }

    private func whenFetchingAllVehicles() async throws {
        fetchedVehicles = try await repository.fetchAll()
    }

    private func whenUpdatingVehicle(
        _ vehicle: Vehicle,
        at folderPath: String? = nil
    ) async throws {
        let path = folderPath ?? "/test/vehicles/\(vehicle.id.uuidString)"
        try await repository.update(vehicle: vehicle, folderPath: path)
    }

    private func whenFetchingPrimaryVehicle() async throws {
        fetchedVehicle = try await repository.fetchPrimary()
    }

    private func whenSettingPrimaryVehicle(id: UUID) async throws {
        try await repository.setPrimary(id: id)
    }

    private func whenDeletingVehicle(id: UUID) async throws {
        try await repository.delete(id: id)
    }

    private func whenCountingVehicles() async throws {
        vehicleCount = try await repository.count()
    }

    private func whenFetchingVehicleWithDocuments(id: UUID) async throws {
        fetchedVehicle = try await repository.fetchWithDocuments(id: id)
    }

    private func thenVehicleShouldExist(_ expected: Vehicle) {
        XCTAssertNotNil(fetchedVehicle, "Vehicle should exist in database")
        XCTAssertEqual(fetchedVehicle?.id, expected.id, "Vehicle ID should match")
    }

    private func thenVehicleShouldMatchPropertiesOf(_ expected: Vehicle) {
        XCTAssertEqual(fetchedVehicle?.type, expected.type, "Vehicle type should match")
        XCTAssertEqual(fetchedVehicle?.brand, expected.brand, "Brand should match")
        XCTAssertEqual(fetchedVehicle?.model, expected.model, "Model should match")
        XCTAssertEqual(fetchedVehicle?.mileage, expected.mileage, "Mileage should match")
        XCTAssertEqual(fetchedVehicle?.plate, expected.plate, "Plate should match")
        XCTAssertEqual(fetchedVehicle?.isPrimary, expected.isPrimary, "isPrimary should match")
    }

    private func thenVehicleTypeShouldBe(_ expected: VehicleType) {
        XCTAssertEqual(fetchedVehicle?.type, expected, "Should save \(expected) type")
    }

    private func thenVehicleMileageShouldBe(_ expected: String) {
        XCTAssertEqual(fetchedVehicle?.mileage, expected, "Should save mileage when provided")
    }

    private func thenVehicleMileageShouldBeNil() {
        XCTAssertNil(fetchedVehicle?.mileage, "Should save nil mileage when not provided")
    }

    private func thenVehicleCountShouldBe(_ expected: Int) {
        XCTAssertEqual(fetchedVehicles.count, expected, "Should have \(expected) vehicles saved")
    }

    private func thenVehicleBrandsShouldBe(_ expected: [String]) {
        let brands = fetchedVehicles.map { $0.brand }.sorted()
        XCTAssertEqual(brands, expected, "All vehicles should be independently saved")
    }

    private func thenVehiclePrimaryFlagShouldBe(_ expected: Bool) {
        XCTAssertEqual(fetchedVehicle?.isPrimary, expected, "Primary flag should be \(expected)")
    }

    private func thenVehicleRegistrationDateShouldBe(_ expected: Date) {
        let timeDifference = abs(fetchedVehicle!.registrationDate.timeIntervalSince1970 - expected.timeIntervalSince1970)
        XCTAssertLessThan(timeDifference, 1.0, "Registration date should be saved correctly")
    }

    private func thenVehicleIdShouldBe(_ expected: UUID) {
        XCTAssertEqual(fetchedVehicle?.id, expected, "Vehicle ID should remain unchanged")
    }

    private func thenVehicleShouldBeNil() {
        XCTAssertNil(fetchedVehicle, "Vehicle should not exist in database")
    }

    private func thenCountShouldBe(_ expected: Int) {
        XCTAssertEqual(vehicleCount, expected, "Count should be \(expected)")
    }

    private func thenDocumentCountShouldBe(_ expected: Int) {
        XCTAssertEqual(fetchedVehicle?.documents.count, expected, "Should have \(expected) document(s)")
    }

    private var testDatabase: DatabaseManager!
    private var repository: VehicleDatabaseRepository!
    private var fetchedVehicle: Vehicle?
    private var fetchedVehicles: [Vehicle] = []
    private var vehicleCount: Int = 0
}
