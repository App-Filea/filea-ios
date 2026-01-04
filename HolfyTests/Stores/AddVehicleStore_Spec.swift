//
//  AddVehicleStore_Spec.swift
//  InvoicerTests
//
//  Created by Claude Code on 24/10/2025.
//

import ComposableArchitecture
import XCTest
@testable import Invoicer

@MainActor
final class AddVehicleStore_Spec: XCTestCase {
    
    private let fixedDate = Date(timeIntervalSince1970: 1704067200)
    
    func test_Saves_vehicle_directly_and_dimiss_when_no_primary_conflict_exists() async {
        givenStore(
            initialBrand: "Tesla",
            initialModel: "Model 3",
            initialPlate: "AA-111-BB",
            initialIsPrimary: true,
            loadAllVehiclesResponse: [.make(id: String(0),
                                            type: .car,
                                            brand: "Tesla",
                                            model: "Model 3",
                                            mileage: nil,
                                            registrationDate: self.fixedDate,
                                            plate: "AA-111-BB",
                                            isPrimary: true)]
        )
        
        await store.send(.view(.saveButtonTapped))
        await store.receive(.verifyPrimaryVehicleExistance) {
            $0.$vehicles.withLock { vehicles in
                vehicles = [
                    .make(
                        id: String(0),
                        type: .car,
                        brand: "Tesla",
                        model: "Model 3",
                        mileage: nil,
                        registrationDate: self.fixedDate,
                        plate: "AA-111-BB",
                        isPrimary: true
                    )]
            }
        }
        await store.receive(.saveVehicle)
        await store.receive(.updateVehiclesList(vehicles: [.make(id: "0",
                                                                 type: .car,
                                                                 brand: "Tesla",
                                                                 model: "Model 3",
                                                                 mileage: nil,
                                                                 registrationDate: self.fixedDate,
                                                                 plate: "AA-111-BB",
                                                                 isPrimary: true)]))
        await store.receive(.newVehicleAdded)
        await store.receive(.dismiss)
        thenViewIsDismissed()
    }
    
    func test_Shows_alert_when_primary_vehicle_conflict_detected() async {
        let existingPrimary = Vehicle(
            id: String(0),
            type: .car,
            brand: "Tesla",
            model: "Model 3",
            plate: "AA-111-BB",
            isPrimary: true
        )
        
        givenStore(
            initialBrand: "BMW",
            initialModel: "X3",
            initialPlate: "CC-222-DD",
            initialIsPrimary: true,
            initialVehicles: [existingPrimary],
            hasPrimaryVehicleResponse: true
        )
        
        await store.send(.view(.saveButtonTapped))
        await store.receive(.verifyPrimaryVehicleExistance)
        await store.receive(.showIsPrimaryAlert) {
            $0.alert = AlertState.saveNewPrimaryVehicleAlert()
        }
    }
    
    func test_Replaces_existing_primary_and_saves_when_warning_confirmed() async {
        let existingPrimary = Vehicle(
            id: String(1),
            type: .car,
            brand: "Tesla",
            model: "Model 3",
            registrationDate: Date(timeIntervalSince1970: 1),
            plate: "AA-111-BB",
            isPrimary: true
        )
        
        givenStore(
            initialBrand: "BMW",
            initialModel: "X3",
            initialPlate: "CC-222-DD",
            initialIsPrimary: true,
            initialVehicles: [existingPrimary],
            loadAllVehiclesResponse: [
                .make(id: String(1),
                      type: .car,
                      brand: "Tesla",
                      model: "Model 3",
                      registrationDate: Date(timeIntervalSince1970: 1),
                      plate: "AA-111-BB",
                      isPrimary: false
                     ),
                .make(id: String(0),
                      type: .car,
                      brand: "BMW",
                      model: "X3",
                      mileage: nil,
                      registrationDate: self.fixedDate,
                      plate: "CC-222-DD",
                      isPrimary: true
                     )
            ],
            hasPrimaryVehicleResponse: true
        )
        
        await store.send(.view(.saveButtonTapped))
        await store.receive(.verifyPrimaryVehicleExistance)
        await store.receive(.showIsPrimaryAlert) {
            $0.alert = AlertState.saveNewPrimaryVehicleAlert()
        }
        await store.send(.alert(.presented(.yes))) {
            $0.alert = nil
        }
        await store.receive(.saveVehicle) {
            $0.$vehicles.withLock { vehicles in
                vehicles = [
                    .make(id: String(1),
                          type: .car,
                          brand: "Tesla",
                          model: "Model 3",
                          registrationDate: Date(timeIntervalSince1970: 1),
                          plate: "AA-111-BB",
                          isPrimary: false
                         ),
                    .make(id: String(0),
                          type: .car,
                          brand: "BMW",
                          model: "X3",
                          mileage: nil,
                          registrationDate: self.fixedDate,
                          plate: "CC-222-DD",
                          isPrimary: true
                         )
                ]
            }
        }
        thenRepositoryCreateVehicleHasBeenCall()
        await store.receive(.updateVehiclesList(
            vehicles: [
                .make(id: String(1),
                      type: .car,
                      brand: "Tesla",
                      model: "Model 3",
                      registrationDate: Date(timeIntervalSince1970: 1),
                      plate: "AA-111-BB",
                      isPrimary: false
                     ),
                .make(id: String(0),
                      type: .car,
                      brand: "BMW",
                      model: "X3",
                      mileage: nil,
                      registrationDate: self.fixedDate,
                      plate: "CC-222-DD",
                      isPrimary: true
                     )
            ]))
    }
    
    func test_Cancels_save_operation_when_primary_warning_dismissed() async {
        let existingPrimary = Vehicle(
            id: String(0),
            type: .car,
            brand: "Tesla",
            model: "Model 3",
            plate: "AA-111-BB",
            isPrimary: true
        )
        
        givenStore(
            initialBrand: "BMW",
            initialModel: "X3",
            initialPlate: "CC-222-DD",
            initialIsPrimary: true,
            initialVehicles: [existingPrimary],
            hasPrimaryVehicleResponse: true
        )
        store.exhaustivity = .off
        await store.send(.view(.saveButtonTapped))
        await store.receive(.verifyPrimaryVehicleExistance)
        await store.receive(.showIsPrimaryAlert) {
            $0.alert = AlertState.saveNewPrimaryVehicleAlert()
        }
        await store.send(.alert(.presented(.no))) {
            $0.alert = nil
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
        givenStore(initialBrand: "", initialModel: "Model", initialPlate: "Plate")
        
        await store.send(.view(.saveButtonTapped)) {
            $0.validationErrors = [.brandEmpty]
        }
        
        await store.send(.binding(.set(\.brand, "Brand"))) {
            $0.brand = "Brand"
        }
        
        await store.send(.view(.saveButtonTapped)) {
            $0.validationErrors = []
        }
        
        await store.receive(.verifyPrimaryVehicleExistance)
    }
    
    //    func test_Opens_scan_store_when_scan_button_tapped() async {
    //        givenStore()
    //
    //        await store.send(.view(.scanButtonTapped))
    //        await store.receive(.openScanStore) {
    //            $0.scanStore = VehicleCardDocumentScanStore.State()
    //        }
    //    }
    
    private func givenStore(
        initialBrand: String = "",
        initialModel: String = "",
        initialPlate: String = "",
        initialIsPrimary: Bool = false,
        initialVehicles: [Vehicle] = [],
        loadAllVehiclesResponse: [Vehicle] = [],
        hasPrimaryVehicleResponse: Bool = false,
    ) {
        @Shared(.vehicles) var vehicles = initialVehicles
        
        store = TestStore(
            initialState: AddVehicleStore.State(
                brand: initialBrand,
                model: initialModel,
                plate: initialPlate,
                registrationDate: fixedDate,
                isPrimary: initialIsPrimary
            ),
            reducer: { AddVehicleStore() },
            withDependencies: { dependencies in
                dependencies.vehicleRepository.createVehicle = { _ in await self.createVehicleHasBeenCall.setValue(true) }
                dependencies.vehicleRepository.getAllVehicles = { return loadAllVehiclesResponse }
                dependencies.vehicleRepository.hasPrimaryVehicle = { hasPrimaryVehicleResponse }
                dependencies.uuid = .incrementing
                dependencies.date = .constant(fixedDate)
                dependencies.dismiss = effect.dismissEffect
            }
        )
    }
    
    private func thenRepositoryCreateVehicleHasBeenCall() {
        XCTAssertTrue(createVehicleHasBeenCall.value)
    }
    
    private func thenViewIsDismissed() {
        XCTAssertEqual(effect.isDismissInvoked.value, [true])
    }
    
    private func assertThatFields(brand: String, model: String, plate: String, makesError errors: VehicleFieldsValidationErrors) async {
        givenStore(initialBrand: brand, initialModel: model, initialPlate: plate)
        await store.send(.view(.saveButtonTapped)) {
            $0.validationErrors = errors
        }
    }
    
    private var store: TestStoreOf<AddVehicleStore>!
    private var createVehicleHasBeenCall = LockIsolated(false)
    private var effect: DismissEffectSpy = DismissEffectSpy()
}
