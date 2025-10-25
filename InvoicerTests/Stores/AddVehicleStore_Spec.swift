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
//// MARK: - Test Helpers
//
/// Helper pour espionner les appels à dismiss()
//struct DismissEffectSpy {
//    var isDismissInvoked: LockIsolated<[Bool]> = .init([])
//
//    var dismissEffect: DismissEffect {
//        DismissEffect { self.isDismissInvoked.withValue { $0.append(true) } }
//    }
//}

//// MARK: - AddVehicleStore Tests
//
//@MainActor
//final class AddVehicleStore_Spec: XCTestCase {
//
//    private let fixedDate = Date(timeIntervalSince1970: 1704067200)
//
//    // MARK: - 1️⃣ VALIDATION DE FORMULAIRE
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
//    // MARK: - 2️⃣ COMPUTED PROPERTIES - VÉHICULE PRINCIPAL
//
//    func test_Returns_existing_primary_vehicle_when_one_exists_in_list() async {
//        let vehicle1 = Vehicle(id: UUID(0), type: .car, brand: "Tesla", model: "Model 3", plate: "AA-111-BB", isPrimary: false)
//        let vehicle2 = Vehicle(id: UUID(1), type: .car, brand: "BMW", model: "X3", plate: "CC-222-DD", isPrimary: true)
//        givenStore(initialVehicles: [vehicle1, vehicle2])
//        thenExistingPrimaryVehicle(equals: vehicle2)
//    }
//
//    func test_Returns_nil_when_no_primary_vehicle_exists() async {
//        let vehicle1 = Vehicle(id: UUID(0), type: .car, brand: "Tesla", model: "Model 3", plate: "AA-111-BB", isPrimary: false)
//        let vehicle2 = Vehicle(id: UUID(1), type: .car, brand: "BMW", model: "X3", plate: "CC-222-DD", isPrimary: false)
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
//        let existingPrimary = Vehicle(id: UUID(0), type: .car, brand: "Tesla", model: "Model 3", plate: "AA-111-BB", isPrimary: true)
//        givenStore(initialIsPrimary: true, initialVehicles: [existingPrimary])
//        thenShouldShowPrimaryWarning(equals: true)
//    }
//
//    func test_Hides_primary_warning_when_vehicle_is_not_primary() async {
//        let existingPrimary = Vehicle(id: UUID(0), type: .car, brand: "Tesla", model: "Model 3", plate: "AA-111-BB", isPrimary: true)
//        givenStore(initialIsPrimary: false, initialVehicles: [existingPrimary])
//        thenShouldShowPrimaryWarning(equals: false)
//    }
//
//    func test_Hides_primary_warning_when_no_existing_primary_vehicle() async {
//        givenStore(initialIsPrimary: true, initialVehicles: [])
//        thenShouldShowPrimaryWarning(equals: false)
//    }
//
//    // MARK: - 3️⃣ FLOW AJOUT - SANS VÉHICULE PRINCIPAL EXISTANT
//
//    func test_Saves_vehicle_directly_when_no_primary_conflict_exists() async {
//        givenStore(
//            initialBrand: "Tesla",
//            initialModel: "Model 3",
//            initialPlate: "AA-111-BB",
//            initialIsPrimary: false,
//            loadAllVehiclesResponse: [.make(id: UUID(0),
//                                            type: .car,
//                                            brand: "Tesla",
//                                            model: "Model 3",
//                                            mileage: nil,
//                                            registrationDate: self.fixedDate,
//                                            plate: "AA-111-BB",
//                                            isPrimary: false)]
//        )
//
//        await store.send(.addButtonTapped)
//        await store.receive(.saveVehicle) {
//            $0.isLoading = true
//            $0.$vehicles.withLock { vehicles in
//                vehicles = [
//                    .make(
//                        id: UUID(0),
//                        type: .car,
//                        brand: "Tesla",
//                        model: "Model 3",
//                        mileage: nil,
//                        registrationDate: self.fixedDate,
//                        plate: "AA-111-BB",
//                        isPrimary: false
//                    )]
//            }
//        }
//
//        await store.receive(\.updateVehiclesList) {
//            $0.isLoading = false
//        }
//    }
//
//    func test_Saves_first_primary_vehicle_directly_without_warning() async {
//        givenStore(
//            initialBrand: "Tesla",
//            initialModel: "Model 3",
//            initialPlate: "AA-111-BB",
//            initialIsPrimary: true,
//            initialVehicles: []
//        )
//
//        await store.send(.addButtonTapped)
//
//        await store.receive(.saveVehicle) {
//            $0.isLoading = true
//            $0.$vehicles.withLock { vehicles in
//                vehicles = [
//                    .make(
//                        id: UUID(0),
//                        type: .car,
//                        brand: "Tesla",
//                        model: "Model 3",
//                        mileage: nil,
//                        registrationDate: self.fixedDate,
//                        plate: "AA-111-BB",
//                        isPrimary: true
//                    )]
//            }
//        }
//
//        await store.receive(\.vehicleSaved) {
//            $0.isLoading = false
//        }
//    }
//
//    // MARK: - 4️⃣ FLOW AJOUT - AVEC CONFLIT VÉHICULE PRINCIPAL
//
//    func test_Shows_alert_when_primary_vehicle_conflict_detected() async {
//        let existingPrimary = Vehicle(
//            id: UUID(0),
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
//            initialVehicles: [existingPrimary]
//        )
//
//        await store.send(.addButtonTapped) {
//            $0.showPrimaryAlert = true
//        }
//    }
//
//    func test_Replaces_existing_primary_and_saves_when_warning_confirmed() async {
//        let existingPrimary = Vehicle(
//            id: UUID(1),
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
//            initialVehicles: [existingPrimary]
//        )
//
//        // Simuler l'état avec l'alerte affichée
//        await store.send(.addButtonTapped) {
//            $0.showPrimaryAlert = true
//        }
//        await store.send(.primaryWarningConfirmed) {
//            $0.showPrimaryAlert = false
//        }
//        await store.receive(.saveVehicle) {
//            $0.isLoading = true
//            $0.$vehicles.withLock { vehicles in
//                vehicles = [
//                    .make(
//                        id: UUID(1),
//                        type: .car,
//                        brand: "Tesla",
//                        model: "Model 3",
//                        registrationDate: Date(timeIntervalSince1970: 1),
//                        plate: "AA-111-BB",
//                        isPrimary: false
//                    ),
//                    .make(
//                        id: UUID(0),
//                        type: .car,
//                        brand: "BMW",
//                        model: "X3",
//                        mileage: nil,
//                        registrationDate: self.fixedDate,
//                        plate: "CC-222-DD",
//                        isPrimary: true
//                    )
//                ]
//            }
//        }
//
//        await store.receive(\.vehicleSaved) {
//            $0.isLoading = false
//        }
//    }
//
//    func test_Cancels_save_operation_when_primary_warning_dismissed() async {
//        let existingPrimary = Vehicle(
//            id: UUID(0),
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
//            initialVehicles: [existingPrimary]
//        )
//        await store.send(.addButtonTapped) {
//            $0.showPrimaryAlert = true
//        }
//
//        await store.send(.primaryWarningCancelled) {
//            $0.showPrimaryAlert = false
//        }
//    }
//
//    // MARK: - 5️⃣ SAUVEGARDE - SUCCÈS
//
//    func test_Saves_secondary_vehicle_successfully_to_database() async {
//        givenStore(
//            initialBrand: "Tesla",
//            initialModel: "Model 3",
//            initialPlate: "AA-111-BB",
//            initialIsPrimary: false
//        )
//
//        await store.send(.saveVehicle) {
//            $0.isLoading = true
//        }
//
//        await store.receive(\.vehicleSaved) {
//            $0.isLoading = false
//            $0.$vehicles.withLock { vehicles in
//                vehicles = [
//                    .make(
//                        id: UUID(0),
//                        type: .car,
//                        brand: "Tesla",
//                        model: "Model 3",
//                        mileage: nil,
//                        registrationDate: self.fixedDate,
//                        plate: "AA-111-BB",
//                        isPrimary: false
//                    )
//                ]
//            }
//        }
//    }
//
//    func test_Updates_existing_primary_to_secondary_before_saving_new_primary() async {
//        let existingPrimary = Vehicle(
//            id: UUID(0),
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
//            initialVehicles: [existingPrimary]
//        )
//
//        await store.send(.saveVehicle) {
//            $0.isLoading = true
//            $0.$vehicles.withLock { vehicles in
//                vehicles = [
//                    .make(
//                        id: UUID(0),
//                        type: .car,
//                        brand: "Tesla",
//                        model: "Model 3",
//                        registrationDate: Date(timeIntervalSince1970: 1),
//                        plate: "AA-111-BB",
//                        isPrimary: false
//                    ),
//                    .make(
//                        id: UUID(1),
//                        type: .car,
//                        brand: "BMW",
//                        model: "X3",
//                        mileage: nil,
//                        registrationDate: self.fixedDate,
//                        plate: "CC-222-DD",
//                        isPrimary: true
//                    )
//                ]
//            }
//        }
//
//        await store.receive(\.vehicleSaved) {
//            $0.isLoading = false
//        }
//    }
//
//    func test_Updates_all_existing_primaries_to_secondary_before_saving_new_primary() async {
//        let existingPrimary1 = Vehicle(
//            id: UUID(0),
//            type: .car,
//            brand: "Tesla",
//            model: "Model 3",
//            plate: "AA-111-BB",
//            isPrimary: true
//        )
//
//        let existingPrimary2 = Vehicle(
//            id: UUID(1),
//            type: .car,
//            brand: "Renault",
//            model: "Clio",
//            plate: "EE-333-FF",
//            isPrimary: true
//        )
//
//        givenStore(
//            initialBrand: "BMW",
//            initialModel: "X3",
//            initialPlate: "CC-222-DD",
//            initialIsPrimary: true,
//            initialVehicles: [existingPrimary1, existingPrimary2]
//        )
//
//        await store.send(.saveVehicle) {
//            $0.isLoading = true
//        }
//
//        await store.receive(\.vehicleSaved) {
//            $0.isLoading = false
//            $0.$vehicles.withLock { vehicles in
//                vehicles = [
//                    .make(
//                        id: UUID(0),
//                        type: .car,
//                        brand: "Tesla",
//                        model: "Model 3",
//                        plate: "AA-111-BB",
//                        isPrimary: false
//                    ),
//                    .make(
//                        id: UUID(1),
//                        type: .car,
//                        brand: "Renault",
//                        model: "Clio",
//                        plate: "EE-333-FF",
//                        isPrimary: false
//                    ),
//                    .make(
//                        id: UUID(2),  // Nouveau véhicule
//                        type: .car,
//                        brand: "BMW",
//                        model: "X3",
//                        mileage: nil,
//                        registrationDate: self.fixedDate,
//                        plate: "CC-222-DD",
//                        isPrimary: true
//                    )
//                ]
//            }
//        }
//    }
//
////    func test_Updates_shared_state_after_vehicle_saved() async {
////        givenStore(
////            initialBrand: "Tesla",
////            initialModel: "Model 3",
////            initialPlate: "AA-111-BB"
////        )
////
////        await store.send(.saveVehicle) {
////            $0.isLoading = true
////        }
////
////        await store.receive(\.vehicleSaved) {
////            $0.isLoading = false
////            $0.$vehicles.withLock { vehicles in
////                vehicles = [
////                    .make(
////                        id: UUID(0),
////                        type: .car,
////                        brand: "Tesla",
////                        model: "Model 3",
////                        mileage: nil,
////                        registrationDate: self.fixedDate,
////                        plate: "AA-111-BB",
////                        isPrimary: false
////                    )
////                ]
////            }
////        }
////    }
////
////    func test_Updates_shared_state_correctly_when_primary_vehicle_saved() async {
////        let existingPrimary = Vehicle(
////            id: UUID(0),
////            type: .car,
////            brand: "Tesla",
////            model: "Model 3",
////            plate: "AA-111-BB",
////            isPrimary: true
////        )
////
////        givenStore(
////            initialBrand: "BMW",
////            initialModel: "X3",
////            initialPlate: "CC-222-DD",
////            initialIsPrimary: true,
////            initialVehicles: [existingPrimary]
////        )
////
////        await store.send(.saveVehicle) {
////            $0.isLoading = true
////        }
////
////        await store.receive(\.vehicleSaved) {
////            $0.isLoading = false
////            $0.$vehicles.withLock { vehicles in
////                vehicles = [
////                    .make(
////                        id: UUID(0),
////                        type: .car,
////                        brand: "Tesla",
////                        model: "Model 3",
////                        plate: "AA-111-BB",
////                        isPrimary: false  // Ancien devient secondaire
////                    ),
////                    .make(
////                        id: UUID(1),
////                        type: .car,
////                        brand: "BMW",
////                        model: "X3",
////                        mileage: nil,
////                        registrationDate: self.fixedDate,
////                        plate: "CC-222-DD",
////                        isPrimary: true  // Nouveau est principal
////                    )
////                ]
////            }
////        }
////    }
////
////    func test_Uses_car_as_default_type_when_vehicle_type_is_nil() async {
////        @Shared(.vehicles) var vehicles: [Vehicle] = []
////
////        store = TestStore(
////            initialState: AddVehicleStore.State(
////                vehicleType: nil,  // Type explicitement nil
////                brand: "Tesla",
////                model: "Model 3",
////                plate: "AA-111-BB",
////                registrationDate: fixedDate
////            ),
////            reducer: { AddVehicleStore() },
////            withDependencies: { dependencies in
////                dependencies.vehicleRepository.save = { _ in }
////                dependencies.uuid = .incrementing
////                dependencies.date = .constant(fixedDate)
////            }
////        )
////
////        await store.send(.saveVehicle) {
////            $0.isLoading = true
////        }
////
////        await store.receive(\.vehicleSaved) {
////            $0.isLoading = false
////            $0.$vehicles.withLock { vehicles in
////                vehicles = [
////                    .make(
////                        id: UUID(0),
////                        type: .car,  // Devrait utiliser .car par défaut
////                        brand: "Tesla",
////                        model: "Model 3",
////                        mileage: nil,
////                        registrationDate: self.fixedDate,
////                        plate: "AA-111-BB",
////                        isPrimary: false
////                    )
////                ]
////            }
////        }
////    }
////
////    func test_Sets_mileage_to_nil_when_field_is_empty() async {
////        @Shared(.vehicles) var vehicles: [Vehicle] = []
////
////        store = TestStore(
////            initialState: AddVehicleStore.State(
////                brand: "Tesla",
////                model: "Model 3",
////                plate: "AA-111-BB",
////                registrationDate: fixedDate,
////                mileage: ""  // Mileage vide
////            ),
////            reducer: { AddVehicleStore() },
////            withDependencies: { dependencies in
////                dependencies.vehicleRepository.save = { _ in }
////                dependencies.uuid = .incrementing
////                dependencies.date = .constant(fixedDate)
////            }
////        )
////
////        await store.send(.saveVehicle) {
////            $0.isLoading = true
////        }
////
////        await store.receive(\.vehicleSaved) {
////            $0.isLoading = false
////            $0.$vehicles.withLock { vehicles in
////                vehicles = [
////                    .make(
////                        id: UUID(0),
////                        type: .car,
////                        brand: "Tesla",
////                        model: "Model 3",
////                        mileage: nil,  // Devrait être nil
////                        registrationDate: self.fixedDate,
////                        plate: "AA-111-BB",
////                        isPrimary: false
////                    )
////                ]
////            }
////        }
////    }
////
////    func test_Preserves_mileage_value_when_field_is_filled() async {
////        @Shared(.vehicles) var vehicles: [Vehicle] = []
////
////        store = TestStore(
////            initialState: AddVehicleStore.State(
////                brand: "Tesla",
////                model: "Model 3",
////                plate: "AA-111-BB",
////                registrationDate: fixedDate,
////                mileage: "50000"  // Mileage rempli
////            ),
////            reducer: { AddVehicleStore() },
////            withDependencies: { dependencies in
////                dependencies.vehicleRepository.save = { _ in }
////                dependencies.uuid = .incrementing
////                dependencies.date = .constant(fixedDate)
////            }
////        )
////
////        await store.send(.saveVehicle) {
////            $0.isLoading = true
////        }
////
////        await store.receive(\.vehicleSaved) {
////            $0.isLoading = false
////            $0.$vehicles.withLock { vehicles in
////                vehicles = [
////                    .make(
////                        id: UUID(0),
////                        type: .car,
////                        brand: "Tesla",
////                        model: "Model 3",
////                        mileage: "50000",  // Devrait préserver la valeur
////                        registrationDate: self.fixedDate,
////                        plate: "AA-111-BB",
////                        isPrimary: false
////                    )
////                ]
////            }
////        }
////    }
////
////    // MARK: - 6️⃣ SAUVEGARDE - ÉCHEC
////
////    func test_Shows_error_when_repository_save_fails() async {
////        // GIVEN - Mock repository qui lance une erreur lors de save()
////        // WHEN - Envoie .saveVehicle
////        // THEN - isLoading == true d'abord, reçoit .saveVehicleFailed("error message"),
////        //        isLoading == false, showErrorAlert == true, errorMessage == "error message"
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Shows_error_when_primary_update_fails() async {
////        // GIVEN - isPrimary = true, véhicule principal existant, mock repository échoue sur update()
////        // WHEN - Envoie .saveVehicle
////        // THEN - isLoading == true, reçoit .saveVehicleFailed(errorMessage),
////        //        isLoading == false, showErrorAlert == true,
////        //        @Shared n'est PAS modifié (pas de mutation en cas d'erreur)
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Closes_error_alert_when_dismissed() async {
////        // GIVEN - showErrorAlert = true, errorMessage = "Some error"
////        // WHEN - Envoie .dismissError
////        // THEN - showErrorAlert == false, errorMessage == nil
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    // MARK: - 7️⃣ OCR - SÉLECTION DE SOURCE
////
////    func test_Shows_document_source_picker_when_scan_button_tapped() async {
////        // GIVEN - State initial
////        // WHEN - Envoie .scanButtonTapped
////        // THEN - showDocumentSourcePicker == true, pas d'autres mutations
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Opens_camera_scan_store_when_camera_source_selected() async {
////        // GIVEN - showDocumentSourcePicker = true
////        // WHEN - Envoie .selectDocumentSource(.camera)
////        // THEN - showDocumentSourcePicker == false, scanStore != nil, scanStore?.scanSource == .camera
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Shows_image_picker_when_photo_library_source_selected() async {
////        // GIVEN - showDocumentSourcePicker = true
////        // WHEN - Envoie .selectDocumentSource(.photoLibrary)
////        // THEN - showDocumentSourcePicker == false, showImagePicker == true, scanStore == nil
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    // MARK: - 8️⃣ OCR - TRAITEMENT IMAGE
////
////    func test_Closes_image_picker_without_processing_when_no_image_selected() async {
////        // GIVEN - showImagePicker = true
////        // WHEN - Envoie .imageSelected(nil)
////        // THEN - showImagePicker == false, pendingImage == nil, pas d'autres effets
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Processes_OCR_when_valid_image_selected() async {
////        // GIVEN - showImagePicker = true
////        // WHEN - Envoie .imageSelected(UIImage())
////        // THEN - showImagePicker == false, reçoit .processImageForOCR(image)
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Opens_scan_store_and_captures_image_for_OCR_processing() async {
////        // GIVEN - State initial
////        // WHEN - Envoie .processImageForOCR(UIImage())
////        // THEN - scanStore != nil avec scanSource = .photoLibrary,
////        //        envoie .scanStore(.presented(.captureImage(image)))
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    // MARK: - 9️⃣ OCR - DONNÉES SCANNÉES
////
////    func test_Applies_scanned_data_when_all_fields_extracted() async {
////        // GIVEN - scanStore.extractedData contient brand, model, plate, date
////        // WHEN - Envoie .scanStore(.presented(.confirmData))
////        // THEN - Reçoit .applyScanData(extractedData)
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Applies_partial_scanned_data_when_only_some_fields_extracted() async {
////        // GIVEN - scanStore.extractedData avec seulement brand et plate
////        // WHEN - Envoie .scanStore(.presented(.confirmData))
////        // THEN - Reçoit .applyScanData(extractedData)
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Performs_no_action_when_no_scanned_data_available() async {
////        // GIVEN - scanStore.extractedData == nil
////        // WHEN - Envoie .scanStore(.presented(.confirmData))
////        // THEN - Pas d'effet (ne reçoit PAS .applyScanData)
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Updates_all_fields_when_complete_scanned_data_applied() async {
////        // GIVEN - ScannedVehicleData(brand: "Tesla", model: "Model 3", plate: "AB-123-CD", date: someDate)
////        // WHEN - Envoie .applyScanData(data)
////        // THEN - brand == "Tesla", model == "Model 3", plate == "AB-123-CD", registrationDate == someDate
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Updates_only_extracted_fields_when_partial_scanned_data_applied() async {
////        // GIVEN - ScannedVehicleData(brand: "Renault", model: "Clio", plate: nil, date: nil)
////        // WHEN - Envoie .applyScanData(data)
////        // THEN - brand == "Renault", model == "Clio", plate inchangé, registrationDate inchangé
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Updates_only_date_when_only_date_scanned() async {
////        // GIVEN - ScannedVehicleData(brand: nil, model: nil, plate: nil, date: specificDate)
////        // WHEN - Envoie .applyScanData(data)
////        // THEN - registrationDate == specificDate, autres champs inchangés
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Overwrites_existing_data_when_scanned_data_applied() async {
////        // GIVEN - brand = "Old", model = "Old", puis scan avec brand = "New", model = "New"
////        // WHEN - Envoie .applyScanData(newData)
////        // THEN - brand == "New", model == "New"
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    // MARK: - 🔟 OCR - RETRY
////
////    func test_Sends_retry_request_for_photo_library_when_requested() async {
////        // GIVEN - scanStore.scanSource = .photoLibrary
////        // WHEN - Envoie .scanStore(.presented(.requestRetry))
////        // THEN - Reçoit .handleScanRetry(.photoLibrary)
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Sends_retry_request_for_camera_when_requested() async {
////        // GIVEN - scanStore.scanSource = .camera
////        // WHEN - Envoie .scanStore(.presented(.requestRetry))
////        // THEN - Reçoit .handleScanRetry(.camera)
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Performs_no_action_when_retry_requested_without_source() async {
////        // GIVEN - scanStore.scanSource = nil
////        // WHEN - Envoie .scanStore(.presented(.requestRetry))
////        // THEN - Pas d'effet
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Reopens_image_picker_when_photo_library_scan_retried() async {
////        // GIVEN - scanStore != nil
////        // WHEN - Envoie .handleScanRetry(.photoLibrary)
////        // THEN - scanStore == nil, showImagePicker == true
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Reopens_camera_when_camera_scan_retried() async {
////        // GIVEN - scanStore != nil (avec erreur)
////        // WHEN - Envoie .handleScanRetry(.camera)
////        // THEN - scanStore == nil d'abord, puis nouveau scanStore avec scanSource = .camera
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    // MARK: - 1️⃣1️⃣ NAVIGATION & ANNULATION
////
////    func test_Dismisses_view_without_saving_when_creation_cancelled() async {
////        // GIVEN - State avec données partiellement remplies
////        // WHEN - Envoie .cancelCreation
////        // THEN - dismiss() appelé (vérifier avec DismissEffectSpy), pas de sauvegarde
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Performs_no_action_when_scan_store_dismissed() async {
////        // GIVEN - scanStore != nil
////        // WHEN - Envoie .scanStore(.dismiss)
////        // THEN - Pas d'effet (TCA gère le dismiss du child store automatiquement)
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    // MARK: - 1️⃣2️⃣ BINDING & VALIDATION ERROR
////
////    func test_Updates_state_through_binding_without_side_effects() async {
////        // GIVEN - State initial
////        // WHEN - Envoie .binding(.set(\.brand, "Tesla"))
////        // THEN - Pas d'effet, le binding met à jour brand automatiquement
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Shows_validation_error_when_flag_set_to_true() async {
////        // GIVEN - showValidationError = false
////        // WHEN - Envoie .setShowValidationError(true)
////        // THEN - showValidationError == true
////
////        XCTFail("TODO: Implémenter le test")
////    }
////
////    func test_Hides_validation_error_when_flag_set_to_false() async {
////        // GIVEN - showValidationError = true
////        // WHEN - Envoie .setShowValidationError(false)
////        // THEN - showValidationError == false
////
////        XCTFail("TODO: Implémenter le test")
////    }
//
//    private func givenStore(
//        initialBrand: String = "",
//        initialModel: String = "",
//        initialPlate: String = "",
//        initialIsPrimary: Bool = false,
//        initialVehicles: [Vehicle] = [],
//        loadAllVehiclesResponse: [Vehicle] = []
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
//                dependencies.vehicleRepository.save = { _ in }
//                dependencies.vehicleRepository.loadAll = { return loadAllVehiclesResponse }
//                dependencies.uuid = .incrementing
//                dependencies.date = .constant(fixedDate)
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
//    private var store: TestStoreOf<AddVehicleStore>!
//}
