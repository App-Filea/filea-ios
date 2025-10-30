//
//  AppStore_Spec.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 29/10/2025.
//

import ComposableArchitecture
import XCTest
@testable import Invoicer

@MainActor
class AppStore_Spec: XCTestCase {
    
    func test_When_persistent_folder_is_not_configured_then_show_StorageOnboardingStore() async {
        givenStore(storageStateResponse: .notConfigured)
        await store.send(.initiate)
        await store.receive(.checkStorage)
        await store.receive(.storageStateChecked(.notConfigured)) {
            $0.isStorageConfigured = false
            $0.path[id: 0] = .storageOnboarding(StorageOnboardingStore.State())
        }
    }
    
    func test_When_persistent_folder_is_invalidAccess_then_show_StorageOnboardingStore() async {
        givenStore(storageStateResponse: .invalidAccess)
        await store.send(.initiate)
        await store.receive(.checkStorage)
        await store.receive(.storageStateChecked(.invalidAccess)) {
            $0.isStorageConfigured = false
            $0.path[id: 0] = .storageOnboarding(StorageOnboardingStore.State())
        }
    }
    
    func test_When_persistent_folder_configured_then_confirm_storage_is_config() async {
        givenStore(storageStateResponse: .configured(.applicationDirectory))
        await store.send(.initiate)
        await store.receive(.checkStorage)
        await store.receive(.storageStateChecked(.configured(.applicationDirectory))) {
            $0.isStorageConfigured = true
        }
    }
    
    func test_When_storage_is_configured_then_get_all_vehicles_in_shared() async {
        let expectedVehicle: Vehicle = .make()
        givenStore(getAllVehiclesResponse: [expectedVehicle])
        store.exhaustivity = .off
        await store.send(.storageStateChecked(.configured(.documentsDirectory))) {
            $0.isStorageConfigured = true
        }
        await store.receive(.getAllVehicles) {
            $0.$vehicles.withLock { $0 = [expectedVehicle] }
        }
        await store.receive(.vehiclesLoaded([expectedVehicle]))
    }
    
    func test_When_get_all_vehicles_gets_no_vehicle_then_it_opens_vehicle_list_view() async {
        givenStore(getAllVehiclesResponse: [])
        await store.send(.storageStateChecked(.configured(.documentsDirectory))) {
            $0.isStorageConfigured = true
        }
        await store.receive(.getAllVehicles)
        await store.receive(.vehiclesLoaded([]))
        await store.receive(.initiateCompleted) {
            $0.path[id: 0] = .vehiclesList(VehiclesListStore.State())
        }
    }
    
    func test_When_get_all_vehicles_gets_only_one_vehicle_then_it_opens_main_view_with_it_as_shared_vehicle() async {
        let expectedVehicle: Vehicle = .make()
        givenStore(getAllVehiclesResponse: [expectedVehicle])
        await store.send(.storageStateChecked(.configured(.documentsDirectory))) {
            $0.isStorageConfigured = true
        }
        await store.receive(.getAllVehicles) {
            $0.$vehicles.withLock { $0 = [expectedVehicle] }
            $0.$selectedVehicle.withLock { $0 = expectedVehicle }
            $0.$lastOpenedVehicleId.withLock { $0 = expectedVehicle.id }
        }
        await store.receive(.vehiclesLoaded([expectedVehicle]))
        await store.receive(.initiateCompleted) {
            $0.path[id: 0] = .main(MainStore.State())
        }
    }
    
    func test_When_get_all_vehicles_gets_two_vehicle_then_open_the_last_opened_vehicle() async {
        let expectedVehicles: [Vehicle] = [.make(id: UUID(0)), .make(id: UUID(1))]
        givenStore(initialLastOpenedVehicleId: UUID(1), getAllVehiclesResponse: expectedVehicles)
        await store.send(.storageStateChecked(.configured(.documentsDirectory))) {
            $0.isStorageConfigured = true
        }
        await store.receive(.getAllVehicles) {
            $0.$vehicles.withLock { $0 = expectedVehicles}
            $0.$selectedVehicle.withLock { $0 = .make(id: UUID(1)) }
            $0.$lastOpenedVehicleId.withLock { $0 = UUID(1) }
        }
        await store.receive(.vehiclesLoaded(expectedVehicles))
        await store.receive(.initiateCompleted) {
            $0.path[id: 0] = .main(MainStore.State())
        }
    }
    
    func test_When_get_all_vehicles_and_none_is_last_open_vehicle_then_open_the_primary_one() async {
        let expectedVehicles: [Vehicle] = [.make(id: UUID(0)), .make(id: UUID(1), isPrimary: true)]
        givenStore(initialLastOpenedVehicleId: nil, getAllVehiclesResponse: expectedVehicles)
        await store.send(.storageStateChecked(.configured(.documentsDirectory))) {
            $0.isStorageConfigured = true
        }
        await store.receive(.getAllVehicles) {
            $0.$vehicles.withLock { $0 = expectedVehicles}
            $0.$selectedVehicle.withLock { $0 = .make(id: UUID(1), isPrimary: true) }
            $0.$lastOpenedVehicleId.withLock { $0 = UUID(1) }
        }
        await store.receive(.vehiclesLoaded(expectedVehicles))
        await store.receive(.initiateCompleted) {
            $0.path[id: 0] = .main(MainStore.State())
        }
    }
    
    func test_When_get_all_vehicles_and_none_is_last_open_and_primary_vehicle_then_open_the_first_of_array() async {
        let expectedVehicles: [Vehicle] = [.make(id: UUID(0)), .make(id: UUID(1))]
        givenStore(initialLastOpenedVehicleId: nil, getAllVehiclesResponse: expectedVehicles)
        await store.send(.storageStateChecked(.configured(.documentsDirectory))) {
            $0.isStorageConfigured = true
        }
        await store.receive(.getAllVehicles) {
            $0.$vehicles.withLock { $0 = expectedVehicles}
            $0.$selectedVehicle.withLock { $0 = .make(id: UUID(0)) }
            $0.$lastOpenedVehicleId.withLock { $0 = UUID(0) }
        }
        await store.receive(.vehiclesLoaded(expectedVehicles))
        await store.receive(.initiateCompleted) {
            $0.path[id: 0] = .main(MainStore.State())
        }
    }
    
    func test_When_navigate_to_vehicle_list_then_it_push_vehicle_list_view_to_the_path() async {
        givenStore()
        await store.send(.navigateToVehiclesList) {
            $0.path[id: 0] = .vehiclesList(VehiclesListStore.State())
        }
    }
    
    private func givenStore(initialSharedVehicles: [Vehicle] = [],
                            initialSelectedVehicle: Vehicle? = nil,
                            initialLastOpenedVehicleId: UUID? = nil,
                            storageStateResponse: VehicleStorageManager.StorageState = .configured(.documentsDirectory),
                            getAllVehiclesResponse: [Vehicle] = []) {
        @Shared(.vehicles) var vehicles = initialSharedVehicles
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle? = initialSelectedVehicle
        @Shared(.lastOpenedVehicleId) var lastOpenedVehicleId: UUID? = initialLastOpenedVehicleId
        store = TestStore(initialState: AppStore.State(),
                          reducer: { AppStore() },
                          withDependencies: {
            $0.storageManager.restorePersistentFolder = { storageStateResponse }
            $0.vehicleRepository.getAllVehicles = { getAllVehiclesResponse }
            $0.uuid = .incrementing
        })
    }
    
    private var store: TestStoreOf<AppStore>!
}
