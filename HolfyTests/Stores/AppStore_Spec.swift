////
////  AppStore_Spec.swift
////  Invoicer
////
////  Created by Nicolas Barbosa on 29/10/2025.
////
//
//import ComposableArchitecture
//import XCTest
//@testable import Invoicer
//
//@MainActor
//class AppStore_Spec: XCTestCase {
//    
//    func test_Shows_on_boarding_when_user_start_app_and_has_not_seen_in_yet() async {
//        givenStore(path: [])
//        await store.send(.initiate) {
//            $0.path[id: 0] = .main(MainStore.State())
//            $0.onboarding = OnboardingStore.State()
//        }
//    }
//    
//    func test_Shows_storage_on_boarding_when_initiate_and_basic_on_boarding_has_been_seen() async {
//        givenStore(initialHasCompleteOnboarding: true, storageStateResponse: .notConfigured, path: [])
//        await store.send(.initiate) {
//            $0.path[id: 0] = .main(MainStore.State())
//        }
//        await store.receive(.checkStorage)
//        await store.receive(.storageStateChecked(.notConfigured)) {
//            $0.storageOnboarding = StorageOnboardingStore.State()
//        }
//    }
//    
//    func test_When_persistent_folder_is_invalidAccess_then_show_StorageOnboardingStore() async {
//        givenStore(initialHasCompleteOnboarding: true, storageStateResponse: .invalidAccess, path: [])
//        await store.send(.initiate) {
//            $0.path[id: 0] = .main(MainStore.State())
//        }
//        await store.receive(.checkStorage)
//        await store.receive(.storageStateChecked(.invalidAccess)) {
//            $0.storageOnboarding = StorageOnboardingStore.State()
//        }
//    }
//    
//    func test_Shows_storage_on_boarding_when_initiate_and_basic_on_boarding_has_been_continue() async {
//        givenStore(path: [])
//        await store.send(.initiate) {
//            $0.path[id: 0] = .main(MainStore.State())
//            $0.onboarding = OnboardingStore.State()
//        }
//        
//        await store.send(.onboarding(.presented(.completeOnboarding))) {
//            $0.$hasCompletedOnboarding.withLock { $0 = true }
//            $0.onboarding = nil
//            $0.storageOnboarding = StorageOnboardingStore.State()
//        }
//    }
//    
//    func test_Gets_all_vehicles_when_storage_on_boarding_is_already_configured() async {
//        givenStore(initialHasCompleteOnboarding: true, storageStateResponse: .configured(.applicationDirectory))
//        
//        await store.send(.storageStateChecked(.configured(.applicationDirectory))) {
//            $0.$isStorageConfigured.withLock { $0 = true }
//        }
//        await store.receive(.getAllVehicles)
//    }
//    
//    func test_Gets_all_vehicles_when_storage_on_boarding_is_configured() async {
//        givenStore(storageStateResponse: .configured(.applicationDirectory))
//        
//        await store.send(.storageStateChecked(.invalidAccess)) {
//            $0.storageOnboarding = StorageOnboardingStore.State()
//        }
//        await store.send(.storageOnboarding(.presented(.folderSaved))) {
//            $0.storageOnboarding = nil
//            $0.$isStorageConfigured.withLock { $0 = true }
//        }
//        await store.receive(.getAllVehicles)
//    }
//    
//    func test_When_storage_is_configured_then_get_all_vehicles_in_shared() async {
//        let expectedVehicle: Vehicle = .make()
//        givenStore(getAllVehiclesResponse: [expectedVehicle])
//        store.exhaustivity = .off
//        await store.send(.getAllVehicles)
//        store.assert { state in
//            state.$vehicles.withLock { $0 = [expectedVehicle] }
//        }
//        await store.receive(.vehiclesLoaded([expectedVehicle]))
//    }
//    
//    func test_When_get_all_vehicles_succeed_then_it_opens_main_view() async {
//        givenStore(getAllVehiclesResponse: [])
//        store.exhaustivity = .off
//        await store.send(.getAllVehicles)
//        await store.receive(.vehiclesLoaded([]))
//        await store.receive(.initiateCompleted)
//        await store.receive(.initiateMainStore)
//        await store.receive(.path(.element(id: 0, action: .main(.onAppear))))
//    }
//    
//    func test_When_get_all_vehicles_gets_only_one_vehicle_then_it_opens_main_view_with_it_as_shared_vehicle() async {
//        let expectedVehicle: Vehicle = .make()
//        givenStore(getAllVehiclesResponse: [expectedVehicle])
//        
//        await store.send(.getAllVehicles)
//        await store.receive(.vehiclesLoaded([expectedVehicle])) {
//            $0.$vehicles.withLock { $0 = [expectedVehicle] }
//            $0.$selectedVehicle.withLock { $0 = expectedVehicle }
//            $0.$lastOpenedVehicleId.withLock { $0 = expectedVehicle.id }
//        }
//        await store.receive(.initiateCompleted)
//        await store.receive(.initiateMainStore)
//    }
//    
//    func test_When_get_all_vehicles_gets_two_vehicle_then_open_the_last_opened_vehicle() async {
//        let expectedVehicles: [Vehicle] = [.make(id: String(0)), .make(id: String(1))]
//        givenStore(initialLastOpenedVehicleId: String(1), getAllVehiclesResponse: expectedVehicles)
//        await store.send(.getAllVehicles)
//        await store.receive(.vehiclesLoaded(expectedVehicles)) {
//            $0.$vehicles.withLock { $0 = expectedVehicles}
//            $0.$selectedVehicle.withLock { $0 = .make(id: String(1)) }
//            $0.$lastOpenedVehicleId.withLock { $0 = String(1) }
//        }
//        await store.receive(.initiateCompleted)
//        await store.receive(.initiateMainStore)
//    }
//    
//    func test_When_get_all_vehicles_and_none_is_last_open_vehicle_then_open_the_primary_one() async {
//        let expectedVehicles: [Vehicle] = [.make(id: String(0)), .make(id: String(1), isPrimary: true)]
//        givenStore(initialLastOpenedVehicleId: nil, getAllVehiclesResponse: expectedVehicles)
//        await store.send(.getAllVehicles)
//        await store.receive(.vehiclesLoaded(expectedVehicles)) {
//            $0.$vehicles.withLock { $0 = expectedVehicles}
//            $0.$selectedVehicle.withLock { $0 = .make(id: String(1), isPrimary: true) }
//            $0.$lastOpenedVehicleId.withLock { $0 = String(1) }
//        }
//        await store.receive(.initiateCompleted)
//        await store.receive(.initiateMainStore)
//    }
//    
//    func test_When_get_all_vehicles_and_none_is_last_open_and_primary_vehicle_then_open_the_first_of_array() async {
//        let expectedVehicles: [Vehicle] = [.make(id: String(0)), .make(id: String(1))]
//        givenStore(initialLastOpenedVehicleId: nil, getAllVehiclesResponse: expectedVehicles)
//        await store.send(.getAllVehicles)
//        await store.receive(.vehiclesLoaded(expectedVehicles)) {
//            $0.$vehicles.withLock { $0 = expectedVehicles}
//            $0.$selectedVehicle.withLock { $0 = .make(id: String(0)) }
//            $0.$lastOpenedVehicleId.withLock { $0 = String(0) }
//        }
//        await store.receive(.initiateCompleted)
//        await store.receive(.initiateMainStore)
//    }
//
//    private func givenStore(initialSharedVehicles: [Vehicle] = [],
//                            initialSelectedVehicle: Vehicle = .null(),
//                            initialLastOpenedVehicleId: String? = nil,
//                            initialHasCompleteOnboarding: Bool = false,
//                            storageStateResponse: VehicleStorageManager.StorageState = .configured(.documentsDirectory),
//                            getAllVehiclesResponse: [Vehicle] = [],
//                            path: [AppStore.Path.State] = [.main(.init())]) {
//        @Shared(.vehicles) var vehicles = initialSharedVehicles
//        @Shared(.selectedVehicle) var selectedVehicle: Vehicle = initialSelectedVehicle
//        @Shared(.lastOpenedVehicleId) var lastOpenedVehicleId: String? = initialLastOpenedVehicleId
//        @Shared(.hasCompletedOnboarding) var hasCompletedOnboarding = initialHasCompleteOnboarding
//        store = TestStore(initialState: AppStore.State(path: StackState(path)),
//                          reducer: { AppStore() },
//                          withDependencies: {
//            $0.storageManager.restorePersistentFolder = { storageStateResponse }
//            $0.vehicleRepository.getAllVehicles = { getAllVehiclesResponse }
//            $0.String = .incrementing
//        })
//    }
//    
//    private var store: TestStoreOf<AppStore>!
//}
