//
//  MainStore_Spec.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 31/10/2025.
//

import XCTest
import ComposableArchitecture
@testable import Invoicer

@MainActor
class MainStore_Spec: XCTestCase {
    
    func test_When_no_vehicles_exists_at_on_appear_then_does_nothing_and_show_empty_state() async {
        givenStore(initialSharedVehicles: [])
        await store.send(.onAppear) {
            $0.showEmptyState = true
        }
    }
    
    func test_When_tapping_on_create_vehicle_button_on_empty_state_then_open_add_vehicle_sheet() async {
        givenStore(initialSharedVehicles: [])
        await store.send(.onAppear) {
            $0.showEmptyState = true
        }
        await store.send(.view(.openCreateVehicleButtonTapped))
        await store.receive(.presentAddVehicleView) {
            $0.addVehicle = AddVehicleStore.State(registrationDate: Date(timeIntervalSince1970: 1))
        }
    }
    
//    func test_When_add_vehicle_is_completed_then_gets_statistics_on_creation_succeed() async {
//        givenStore(initialSharedVehicles: [])
//        await store.send(.onAppear) {
//            $0.showEmptyState = true
//        }
//        await store.send(.view(.openCreateVehicleButtonTapped))
//        await store.receive(.presentAddVehicleView) {
//            $0.addVehicle = AddVehicleStore.State(registrationDate: Date(timeIntervalSince1970: 1))
//        }
//        await store.send(.addVehicle(.presented(.vehicleIsCreatedAndSelected)))
//        await store.receive(.setupVehicleStatistics)
//    }
    
    func test_When_vehicles_exists_at_on_appear_but_no_one_is_selected_then_show_vehicles_list() async {
        givenStore(initialSharedVehicles: [.make()], initialSelectedVehicle: nil)
        await store.send(.onAppear)
        await store.receive(.presentVehiclesListView) {
            $0.vehiclesList = VehiclesListStore.State()
        }
    }
    
//a
    
    func test_When_vehicles_exists_at_on_appear_with_selected_one_then_gets_statistics_about_it() async {
        givenStore(initialSharedVehicles: [.make()], initialSelectedVehicle: .make())
        await store.send(.onAppear)
        await store.receive(.setupVehicleStatistics)
        await store.receive(.warningVehicle(.computeVehicleWarnings))
        await store.receive(.totalCostVehicle(.computeVehicleTotalCost))
        await store.receive(.vehicleMonthlyExpenses(.computeVehicleMontlyExpenses))
    }
    
    private func givenStore(initialSharedVehicles: [Vehicle] = [], initialSelectedVehicle: Vehicle? = nil) {
        store = TestStore(initialState: MainStore.State(vehicles: initialSharedVehicles,
                                                        selectedVehicle: Shared(value: initialSelectedVehicle)),
                          reducer: { MainStore() },
                          withDependencies: {
            $0.date.now = Date(timeIntervalSince1970: 1)
        })
    }
    
    private var store: TestStoreOf<MainStore>!
}
