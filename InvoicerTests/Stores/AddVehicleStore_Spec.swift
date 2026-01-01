////
////  AddVehicleStore_Spec.swift
////  InvoicerTests
////
////  Created by Claude Code on 24/10/2025.
////
//
//import ComposableArchitecture
//import XCTest
//@testable import Invoicer
//
//@MainActor
//final class AddVehicleStore_Spec: XCTestCase {
//    
//    private let fixedDate = Date(timeIntervalSince1970: 1704067200)
//        
//    func test_Returns_true_when_all_required_fields_are_filled() async {
//        givenStore(initialBrand: "Brand", initialModel: "Model", initialPlate: "AAAAAA")
//        thenIsFormIsValid()
//    }
//    
//    func test_Returns_false_when_brand_is_empty() async {
//        givenStore(initialBrand: "", initialModel: "Model", initialPlate: "AAAAAA")
//        thenIsFormIsNotValid()
//    }
//    
//    func test_Returns_false_when_model_is_empty() async {
//        givenStore(initialBrand: "Brand", initialModel: "", initialPlate: "AAAAAA")
//        thenIsFormIsNotValid()
//    }
//    
//    func test_Returns_false_when_plate_is_empty() async {
//        givenStore(initialBrand: "Brand", initialModel: "Model", initialPlate: "")
//        thenIsFormIsNotValid()
//    }
//    
//    func test_Returns_false_when_all_fields_are_empty() async {
//        givenStore(initialBrand: "", initialModel: "", initialPlate: "")
//        thenIsFormIsNotValid()
//    }
//    
//    func test_Returns_true_when_only_required_fields_are_filled() async {
//        givenStore(initialBrand: "Brand", initialModel: "Model", initialPlate: "AAAAAA")
//        thenIsFormIsValid()
//    }
//        
//    func test_Returns_existing_primary_vehicle_when_one_exists_in_list() async {
//        let vehicle1 = Vehicle(id: String(0), type: .car, brand: "Tesla", model: "Model 3", plate: "AA-111-BB", isPrimary: false)
//        let vehicle2 = Vehicle(id: String(1), type: .car, brand: "BMW", model: "X3", plate: "CC-222-DD", isPrimary: true)
//        givenStore(initialVehicles: [vehicle1, vehicle2])
//        thenExistingPrimaryVehicle(equals: vehicle2)
//    }
//    
//    func test_Returns_nil_when_no_primary_vehicle_exists() async {
//        let vehicle1 = Vehicle(id: String(0), type: .car, brand: "Tesla", model: "Model 3", plate: "AA-111-BB", isPrimary: false)
//        let vehicle2 = Vehicle(id: String(1), type: .car, brand: "BMW", model: "X3", plate: "CC-222-DD", isPrimary: false)
//        givenStore(initialVehicles: [vehicle1, vehicle2])
//        thenExistingPrimaryVehicle(isNil: true)
//    }
//    
//    func test_Returns_nil_when_vehicle_list_is_empty() async {
//        givenStore(initialVehicles: [])
//        thenExistingPrimaryVehicle(isNil: true)
//    }
//    
//    func test_Shows_primary_warning_when_replacing_existing_primary_vehicle() async {
//        let existingPrimary = Vehicle(id: String(0), type: .car, brand: "Tesla", model: "Model 3", plate: "AA-111-BB", isPrimary: true)
//        givenStore(initialIsPrimary: true, initialVehicles: [existingPrimary])
//        thenShouldShowPrimaryWarning(equals: true)
//    }
//    
//    func test_Hides_primary_warning_when_vehicle_is_not_primary() async {
//        let existingPrimary = Vehicle(id: String(0), type: .car, brand: "Tesla", model: "Model 3", plate: "AA-111-BB", isPrimary: true)
//        givenStore(initialIsPrimary: false, initialVehicles: [existingPrimary])
//        thenShouldShowPrimaryWarning(equals: false)
//    }
//    
//    func test_Hides_primary_warning_when_no_existing_primary_vehicle() async {
//        givenStore(initialIsPrimary: true, initialVehicles: [])
//        thenShouldShowPrimaryWarning(equals: false)
//    }
//        
//    func test_Saves_vehicle_directly_and_dimiss_when_no_primary_conflict_exists() async {
//        givenStore(
//            initialBrand: "Tesla",
//            initialModel: "Model 3",
//            initialPlate: "AA-111-BB",
//            initialIsPrimary: true,
//            loadAllVehiclesResponse: [.make(id: String(0),
//                                            type: .car,
//                                            brand: "Tesla",
//                                            model: "Model 3",
//                                            mileage: nil,
//                                            registrationDate: self.fixedDate,
//                                            plate: "AA-111-BB",
//                                            isPrimary: true)]
//        )
//        
//        await store.send(.view(.saveVehicleButtonTapped))
//        await store.receive(.verifyPrimaryVehicleExistance) {
//            $0.$vehicles.withLock { vehicles in
//                vehicles = [
//                    .make(
//                        id: String(0),
//                        type: .car,
//                        brand: "Tesla",
//                        model: "Model 3",
//                        mileage: nil,
//                        registrationDate: self.fixedDate,
//                        plate: "AA-111-BB",
//                        isPrimary: true
//                    )]
//            }
//            $0.$selectedVehicle.withLock { $0 =
//                    .make(
//                        id: String(0),
//                        type: .car,
//                        brand: "Tesla",
//                        model: "Model 3",
//                        mileage: nil,
//                        registrationDate: self.fixedDate,
//                        plate: "AA-111-BB",
//                        isPrimary: true
//                    )
//            }
//        }
//        await store.receive(.saveVehicle) {
//            $0.isLoading = true
//        }
//        await store.receive(.updateVehiclesListAndSetNewVehicleAsSelected(vehicles: [.make(id: String(0),
//                                                                                           type: .car,
//                                                                                           brand: "Tesla",
//                                                                                           model: "Model 3",
//                                                                                           mileage: nil,
//                                                                                           registrationDate: self.fixedDate,
//                                                                                           plate: "AA-111-BB",
//                                                                                           isPrimary: true)],
//                                                                          newVehicle: .make(
//                                                                            id: String(0),
//                                                                            type: .car,
//                                                                            brand: "Tesla",
//                                                                            model: "Model 3",
//                                                                            mileage: nil,
//                                                                            registrationDate: self.fixedDate,
//                                                                            plate: "AA-111-BB",
//                                                                            isPrimary: true
//                                                                          )))
//        await store.receive(.newVehicleAdded)
//        await store.receive(.dismiss)
//        thenViewIsDismissed()
//    }
//        
//    func test_Shows_alert_when_primary_vehicle_conflict_detected() async {
//        let existingPrimary = Vehicle(
//            id: String(0),
//            type: .car,
//            brand: "Tesla",
//            model: "Model 3",
//            plate: "AA-111-BB",
//            isPrimary: true
//        )
//        
//        givenStore(
//            initialBrand: "BMW",
//            initialModel: "X3",
//            initialPlate: "CC-222-DD",
//            initialIsPrimary: true,
//            initialVehicles: [existingPrimary],
//            hasPrimaryVehicleResponse: true
//        )
//        
//        await store.send(.view(.saveVehicleButtonTapped))
//        await store.receive(.verifyPrimaryVehicleExistance)
//        await store.receive(.showIsPrimaryAlert) {
//            $0.alert = AlertState.saveNewPrimaryVehicleAlert()
//        }
//    }
//    
//    func test_Replaces_existing_primary_and_saves_when_warning_confirmed() async {
//        let existingPrimary = Vehicle(
//            id: String(1),
//            type: .car,
//            brand: "Tesla",
//            model: "Model 3",
//            registrationDate: Date(timeIntervalSince1970: 1),
//            plate: "AA-111-BB",
//            isPrimary: true
//        )
//        
//        givenStore(
//            initialBrand: "BMW",
//            initialModel: "X3",
//            initialPlate: "CC-222-DD",
//            initialIsPrimary: true,
//            initialVehicles: [existingPrimary],
//            loadAllVehiclesResponse: [
//                .make(id: String(1),
//                      type: .car,
//                      brand: "Tesla",
//                      model: "Model 3",
//                      registrationDate: Date(timeIntervalSince1970: 1),
//                      plate: "AA-111-BB",
//                      isPrimary: false
//                     ),
//                .make(id: String(0),
//                      type: .car,
//                      brand: "BMW",
//                      model: "X3",
//                      mileage: nil,
//                      registrationDate: self.fixedDate,
//                      plate: "CC-222-DD",
//                      isPrimary: true
//                     )
//            ],
//            hasPrimaryVehicleResponse: true
//        )
//        
//        await store.send(.view(.saveVehicleButtonTapped))
//        await store.receive(.verifyPrimaryVehicleExistance)
//        await store.receive(.showIsPrimaryAlert) {
//            $0.alert = AlertState.saveNewPrimaryVehicleAlert()
//        }
//        await store.send(.alert(.presented(.yes))) {
//            $0.alert = nil
//        }
//        await store.receive(.saveVehicle) {
//            $0.isLoading = true
//            $0.$vehicles.withLock { vehicles in
//                vehicles = [
//                    .make(id: String(1),
//                          type: .car,
//                          brand: "Tesla",
//                          model: "Model 3",
//                          registrationDate: Date(timeIntervalSince1970: 1),
//                          plate: "AA-111-BB",
//                          isPrimary: false
//                         ),
//                    .make(id: String(0),
//                          type: .car,
//                          brand: "BMW",
//                          model: "X3",
//                          mileage: nil,
//                          registrationDate: self.fixedDate,
//                          plate: "CC-222-DD",
//                          isPrimary: true
//                         )
//                ]
//            }
//            $0.$selectedVehicle.withLock { $0 =
//                    .make(id: String(0),
//                          type: .car,
//                          brand: "BMW",
//                          model: "X3",
//                          mileage: nil,
//                          registrationDate: self.fixedDate,
//                          plate: "CC-222-DD",
//                          isPrimary: true
//                    )
//            }
//        }
//        thenRepositoryCreateVehicleHasBeenCall()
//        await store.receive(.updateVehiclesListAndSetNewVehicleAsSelected(
//            vehicles: [
//                .make(id: String(1),
//                      type: .car,
//                      brand: "Tesla",
//                      model: "Model 3",
//                      registrationDate: Date(timeIntervalSince1970: 1),
//                      plate: "AA-111-BB",
//                      isPrimary: false
//                     ),
//                .make(id: String(0),
//                      type: .car,
//                      brand: "BMW",
//                      model: "X3",
//                      mileage: nil,
//                      registrationDate: self.fixedDate,
//                      plate: "CC-222-DD",
//                      isPrimary: true
//                     )
//            ],
//            newVehicle: .make(id: String(0),
//                              type: .car,
//                              brand: "BMW",
//                              model: "X3",
//                              mileage: nil,
//                              registrationDate: self.fixedDate,
//                              plate: "CC-222-DD",
//                              isPrimary: true
//                             )))
//    }
//    
//    func test_Cancels_save_operation_when_primary_warning_dismissed() async {
//        let existingPrimary = Vehicle(
//            id: String(0),
//            type: .car,
//            brand: "Tesla",
//            model: "Model 3",
//            plate: "AA-111-BB",
//            isPrimary: true
//        )
//        
//        givenStore(
//            initialBrand: "BMW",
//            initialModel: "X3",
//            initialPlate: "CC-222-DD",
//            initialIsPrimary: true,
//            initialVehicles: [existingPrimary],
//            hasPrimaryVehicleResponse: true
//        )
//        store.exhaustivity = .off
//        await store.send(.view(.saveVehicleButtonTapped))
//        await store.receive(.verifyPrimaryVehicleExistance)
//        await store.receive(.showIsPrimaryAlert) {
//            $0.alert = AlertState.saveNewPrimaryVehicleAlert()
//        }
//        await store.send(.alert(.presented(.no))) {
//            $0.alert = nil
//        }
//    }
//
//    func test_Opens_scan_store_when_scan_button_tapped() async {
//        givenStore()
//
//        await store.send(.view(.scanButtonTapped))
//        await store.receive(.openScanStore) {
//            $0.scanStore = VehicleCardDocumentScanStore.State()
//        }
//    }
//    
//    private func givenStore(
//        initialBrand: String = "",
//        initialModel: String = "",
//        initialPlate: String = "",
//        initialIsPrimary: Bool = false,
//        initialVehicles: [Vehicle] = [],
//        loadAllVehiclesResponse: [Vehicle] = [],
//        hasPrimaryVehicleResponse: Bool = false,
//    ) {
//        @Shared(.vehicles) var vehicles = initialVehicles
//        
//        store = TestStore(
//            initialState: AddVehicleStore.State(
//                brand: initialBrand,
//                model: initialModel,
//                plate: initialPlate,
//                registrationDate: fixedDate,
//                isPrimary: initialIsPrimary
//            ),
//            reducer: { AddVehicleStore() },
//            withDependencies: { dependencies in
//                dependencies.vehicleRepository.createVehicle = { _ in await self.createVehicleHasBeenCall.setValue(true) }
//                dependencies.vehicleRepository.getAllVehicles = { return loadAllVehiclesResponse }
//                dependencies.vehicleRepository.hasPrimaryVehicle = { hasPrimaryVehicleResponse }
//                dependencies.String = .incrementing
//                dependencies.date = .constant(fixedDate)
//                dependencies.dismiss = effect.dismissEffect
//            }
//        )
//    }
//    
//    private func thenIsFormIsValid(line: UInt = #line) {
//        XCTAssertTrue(store.state.isFormValid, line: line)
//    }
//    
//    private func thenIsFormIsNotValid(line: UInt = #line) {
//        XCTAssertFalse(store.state.isFormValid, line: line)
//    }
//    
//    private func thenExistingPrimaryVehicle(equals expectedVehicle: Vehicle, line: UInt = #line) {
//        XCTAssertEqual(store.state.existingPrimaryVehicle, expectedVehicle, line: line)
//    }
//    
//    private func thenExistingPrimaryVehicle(isNil: Bool, line: UInt = #line) {
//        if isNil {
//            XCTAssertNil(store.state.existingPrimaryVehicle, line: line)
//        } else {
//            XCTAssertNotNil(store.state.existingPrimaryVehicle, line: line)
//        }
//    }
//    
//    private func thenShouldShowPrimaryWarning(equals expected: Bool, line: UInt = #line) {
//        XCTAssertEqual(expected, store.state.shouldShowPrimaryWarning, line: line)
//    }
//    
//    private func thenRepositoryCreateVehicleHasBeenCall() {
//        XCTAssertTrue(createVehicleHasBeenCall.value)
//    }
//    
//    private func thenViewIsDismissed() {
//        XCTAssertEqual(effect.isDismissInvoked.value, [true])
//    }
//    
//    private var store: TestStoreOf<AddVehicleStore>!
//    private var createVehicleHasBeenCall = LockIsolated(false)
//    private var effect: DismissEffectSpy = DismissEffectSpy()
//}
