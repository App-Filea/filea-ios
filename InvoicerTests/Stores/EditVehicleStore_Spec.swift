//
//  EditVehicleStore_Spec.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 01/01/2026.
//

import ComposableArchitecture
import XCTest
@testable import Invoicer

@MainActor
class EditVehicleStore_Spec: XCTestCase {
    
    func test_Setups_individuals_fields_into_variable_according_selected_vehicle_shared_value_at_init() async {
        let vehicle: Vehicle = .make(id: String(),
                                     type: .car,
                                     brand: "Brand",
                                     model: "Model",
                                     mileage: "10000",
                                     registrationDate: Date(timeIntervalSince1970: 1),
                                     plate: "11-111-11",
                                     isPrimary: true,
                                     documents: [])
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle = vehicle
        
        givenStore()
        XCTAssertEqual(.car, store.state.type)
        XCTAssertEqual("Brand", store.state.brand)
        XCTAssertEqual("Model", store.state.model)
        XCTAssertEqual("10000", store.state.mileage)
        XCTAssertEqual(Date(timeIntervalSince1970: 1), store.state.registrationDate)
        XCTAssertEqual("11-111-11", store.state.plate)
        XCTAssertEqual(true, store.state.isPrimary)
    }
    
    func test_Updates_vehicles_repository_when_saving_current_vehicle_changes_then_updates_shared_then_dismiss() async {
        let vehicle: Vehicle = .make(id: "uuid",
                                     type: .car,
                                     brand: "Brand",
                                     model: "Model",
                                     mileage: "10000",
                                     registrationDate: Date(timeIntervalSince1970: 1),
                                     plate: "11-111-11",
                                     isPrimary: true,
                                     documents: [])
        @Shared(.vehicles) var vehicles: [Vehicle] = [vehicle]
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle = vehicle
        
        givenStore()
        await store.send(.binding(.set(\.brand, "Brand new"))) {
            $0.brand = "Brand new"
        }
        
        await store.send(.view(.saveButtonTapped))
        await store.receive(.updateVehicle) {
            $0.$vehicles.withLock { $0 = [.make(id: "uuid",
                                                type: .car,
                                                brand: "Brand new",
                                                model: "Model",
                                                mileage: "10000",
                                                registrationDate: Date(timeIntervalSince1970: 1),
                                                plate: "11-111-11",
                                                isPrimary: true,
                                                documents: [])] }
            
            $0.$selectedVehicle.withLock { $0 = .make(id: "uuid",
                                                      type: .car,
                                                      brand: "Brand new",
                                                      model: "Model",
                                                      mileage: "10000",
                                                      registrationDate: Date(timeIntervalSince1970: 1),
                                                      plate: "11-111-11",
                                                      isPrimary: true,
                                                      documents: []) }
        }
        await store.receive(.updateShareds(selectedVehicle: .make(id: "uuid",
                                                                  type: .car,
                                                                  brand: "Brand new",
                                                                  model: "Model",
                                                                  mileage: "10000",
                                                                  registrationDate: Date(timeIntervalSince1970: 1),
                                                                  plate: "11-111-11",
                                                                  isPrimary: true,
                                                                  documents: []),
                                           vehiclesList: [.make(id: "uuid",
                                                                type: .car,
                                                                brand: "Brand new",
                                                                model: "Model",
                                                                mileage: "10000",
                                                                registrationDate: Date(timeIntervalSince1970: 1),
                                                                plate: "11-111-11",
                                                                isPrimary: true,
                                                                documents: [])]))
        
        await store.receive(.dismiss)
    }
    
    func test_Updates_all_vehicles_in_repository_and_in_shared_when_is_primary_update_is_saved() async {
        let vehicle: Vehicle = .make(id: "uuid", isPrimary: false)
        @Shared(.vehicles) var vehicles: [Vehicle] = [vehicle, .make(id: "uuid2", isPrimary: true)]
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle = vehicle
        
        givenStore()
        await store.send(.binding(.set(\.isPrimary, true))) {
            $0.isPrimary = true
        }
        
        await store.send(.view(.saveButtonTapped))
        await store.receive(.updateVehicle) {
            $0.$vehicles.withLock { $0 = [.make(id: "uuid", isPrimary: true),
                                          .make(id: "uuid2", isPrimary: false)] }
            
            $0.$selectedVehicle.withLock { $0 = .make(id: "uuid", isPrimary: true) }
        }
    }
    
    func test_assert_that_validation_error_is_show_according_wrong_fields() async {
        await assertThatFields(brand: "", model: "", plate: "", makesError: [.brandEmpty, .modelEmpty, .plateEmpty])
        await assertThatFields(brand: "", model: "", plate: "Plate", makesError: [.brandEmpty, .modelEmpty])
        await assertThatFields(brand: "", model: "Model", plate: "", makesError: [.brandEmpty, .plateEmpty])
        await assertThatFields(brand: "", model: "Model", plate: "Plate", makesError: [.brandEmpty])
        await assertThatFields(brand: "Brand", model: "", plate: "", makesError: [.modelEmpty, .plateEmpty])
        await assertThatFields(brand: "Brand", model: "", plate: "Plate", makesError: [.modelEmpty])
        await assertThatFields(brand: "Brand", model: "Model", plate: "", makesError: [.plateEmpty])
    }
    
    func test_Removes_error_when_saving_a_second_time() async {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle = .make(brand: "", model: "Model", plate: "Plate")
        givenStore()
        store.exhaustivity = .off
        await store.send(.view(.saveButtonTapped)) {
            $0.validationErrors = [.brandEmpty]
        }
        await store.send(.binding(.set(\.brand, "Brand"))) {
            $0.brand = "Brand"
        }
        await store.send(.view(.saveButtonTapped)) {
            $0.validationErrors = []
        }
        await store.receive(.updateVehicle)
    }
    
    private func givenStore() {
        store = TestStore(initialState: EditVehicleStore.State(),
                          reducer: { EditVehicleStore() },
                          withDependencies: {
            $0.vehicleRepository.updateVehicle = { _ in }
        })
    }
    
    private func assertThatFields(brand: String, model: String, plate: String, makesError errors: VehicleFieldsValidationErrors) async {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        
        $selectedVehicle.withLock {
            $0 = .make(brand: brand, model: model, plate: plate)
        }
        
        givenStore()
        await store.send(.view(.saveButtonTapped)) {
            $0.validationErrors = errors
        }
    }
    
    private var store: TestStoreOf<EditVehicleStore>!
}
