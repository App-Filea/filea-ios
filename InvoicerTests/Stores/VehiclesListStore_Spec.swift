//
//  VehicleListStore_Spec.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 31/10/2025.
//

import XCTest
import ComposableArchitecture
@testable import Invoicer

@MainActor
class VehiclesListStore_Spec: XCTestCase {
    
    func test_When_tapping_dismiss_sheet_button_then_dismiss_the_view() async {
        givenStore()
        await store.send(.view(.dimissSheetButtonTapped))
        await store.receive(.dismiss)
        thenViewIsDismissed()
    }
    
    func test_When_tapping_create_vehicle_button_then_open_add_vehicle_sheet() async {
        givenStore()
        await store.send(.view(.openCreateVehicleButtonTapped))
        await store.receive(.presentAddVehicleView) {
            $0.addVehicle = AddVehicleStore.State(registrationDate: Date(timeIntervalSince1970: 1))
        }
    }
    
    func test_When_Selecting_a_vehicle_then_update_shared_variables_and_dismiss_view() async {
        let selectedVehicle: Vehicle = .make()
        givenStore()
        await store.send(.view(.selectedVehicleButtonTapped(selectedVehicle))) {
            $0.$selectedVehicle.withLock { $0 = selectedVehicle }
            $0.$lastOpenedVehicleId.withLock { $0 = selectedVehicle.id}
        }
        await store.receive(.selectVehicle(selectedVehicle))
        await store.receive(.dismiss)
    }
    
    func test_When_presented_add_vehicle_create_a_new_one_then_send_same_action_to_parent() async {
        givenStore()
        await store.send(.view(.openCreateVehicleButtonTapped))
        await store.receive(.presentAddVehicleView) {
            $0.addVehicle = AddVehicleStore.State(registrationDate: Date(timeIntervalSince1970: 1))
        }
        await store.send(.addVehicle(.presented(.vehicleIsCreatedAndSelected)))
        await store.receive(.vehicleIsCreatedAndSelected)
    }
    
    private func givenStore() {
        store = TestStore(initialState: VehiclesListStore.State(),
                          reducer: { VehiclesListStore() },
                          withDependencies: {
            $0.dismiss = effect.dismissEffect
            $0.date.now = Date(timeIntervalSince1970: 1)
        })
    }
    
    private func thenViewIsDismissed() {
        XCTAssertEqual(effect.isDismissInvoked.value, [true])
    }
    
    private var store: TestStoreOf<VehiclesListStore>!
    private var effect: DismissEffectSpy = DismissEffectSpy()
}
