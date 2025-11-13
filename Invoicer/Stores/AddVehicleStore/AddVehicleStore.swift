//
//  AddVehicleStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation
import UIKit

@Reducer
struct AddVehicleStore {

    @ObservableState
    struct State: Equatable {
        var vehicleType: VehicleType? = nil
        var brand: String = ""
        var model: String = ""
        var plate: String = ""
        var registrationDate: Date
        var mileage: String = ""
        var isPrimary: Bool = false
        var isLoading = false
        var showValidationError = false
        var showDocumentSourcePicker: Bool = false
        var showImagePicker: Bool = false
        var showErrorAlert: Bool = false
        var errorMessage: String? = nil
        var pendingImage: UIImage? = nil
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle?
        @Presents var scanStore: DocumentScanStore.State?
        @Presents var alert: AlertState<Action.Alert>?

        init(
            vehicleType: VehicleType? = nil,
            brand: String = "",
            model: String = "",
            plate: String = "",
            registrationDate: Date? = nil,
            mileage: String = "",
            isPrimary: Bool = false
        ) {
            @Dependency(\.date) var date

            self.vehicleType = vehicleType
            self.brand = brand
            self.model = model
            self.plate = plate
            self.registrationDate = registrationDate ?? date.now
            self.mileage = mileage
            self.isPrimary = isPrimary
            self._vehicles = Shared(.vehicles)
        }

        // MARK: - Computed Properties

        var existingPrimaryVehicle: Vehicle? {
            vehicles.first(where: { $0.isPrimary })
        }

        var isFormValid: Bool {
            !brand.isEmpty &&
            !model.isEmpty &&
            !plate.isEmpty
        }

        var shouldShowPrimaryWarning: Bool {
            isPrimary && existingPrimaryVehicle != nil
        }
    }

    enum Action: Equatable, BindableAction {
        case view(ActionView)
        case binding(BindingAction<State>)
        
        case verifyPrimaryVehicleExistance
        case showIsPrimaryAlert
        
        case primaryWarningConfirmed
        case primaryWarningCancelled
        case saveVehicle
        case saveVehicleFailed(String)
        case updateVehiclesListAndSetVehicleAsSelected(Vehicle)
        case dismissError
        case cancelCreation
        case setShowValidationError(Bool)
        case imageSelected(UIImage?)
        case processImageForOCR(UIImage)
        case scanButtonTapped
        case selectDocumentSource(DocumentSource)
        case handleScanRetry(DocumentSource)
        case scanStore(PresentationAction<DocumentScanStore.Action>)
        case applyScanData(ScannedVehicleData)
        case alert(PresentationAction<Alert>)
        case dismiss
        
        case vehicleIsCreatedAndSelected
        
        enum ActionView: Equatable {
            case saveVehicleButtonTapped
        }
        
        enum Alert: Equatable {
            case confirm
        }
    }

    @Dependency(\.vehicleRepository) var vehicleRepository
    @Dependency(\.uuid) var uuid
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(let actionView):
                switch actionView {
                case .saveVehicleButtonTapped:
                    return .send(.verifyPrimaryVehicleExistance)
                }
//            case .addButtonTapped:
//                if state.shouldShowPrimaryWarning {
//                    state.showPrimaryAlert = true
//                    return .none
//                }
//                return .send(.saveVehicle)

//            case .primaryWarningConfirmed:
//                state.showPrimaryAlert = false
//                return .send(.saveVehicle)
//
//            case .primaryWarningCancelled:
//                state.showPrimaryAlert = false
//                return .none

            case .imageSelected(let image):
                state.showImagePicker = false
                state.pendingImage = nil

                guard let image else {
                    return .none
                }

                return .send(.processImageForOCR(image))

            case .processImageForOCR(let image):
                state.scanStore = DocumentScanStore.State(scanSource: .photoLibrary)
                return .run { send in
                    await send(.scanStore(.presented(.captureImage(image))))
                }

            case .scanButtonTapped:
                state.showDocumentSourcePicker = true
                return .none

            case .selectDocumentSource(let source):
                state.showDocumentSourcePicker = false

                switch source {
                case .camera:
                    state.scanStore = DocumentScanStore.State(scanSource: .camera)

                case .photoLibrary:
                    state.showImagePicker = true
                }

                return .none

            case .scanStore(.presented(.confirmData)):
                if let extractedData = state.scanStore?.extractedData {
                    return .send(.applyScanData(extractedData))
                }
                return .none

            case .scanStore(.presented(.requestRetry)):
                if let source = state.scanStore?.scanSource {
                    return .send(.handleScanRetry(source))
                }
                return .none

            case .handleScanRetry(let source):
                state.scanStore = nil
                switch source {
                case .photoLibrary:
                    state.showImagePicker = true
                case .camera:
                    state.scanStore = DocumentScanStore.State(scanSource: .camera)
                }
                return .none

            case .applyScanData(let data):
                if let brand = data.brand {
                    state.brand = brand
                }
                if let model = data.model {
                    state.model = model
                }
                if let plate = data.plate {
                    state.plate = plate
                }
                if let date = data.registrationDate {
                    state.registrationDate = date
                }
    
                return .none
            case .verifyPrimaryVehicleExistance:
                return .run { send in
                    if await vehicleRepository.hasPrimaryVehicle() {
                        await send(.showIsPrimaryAlert)
                    } else {
                        await send(.saveVehicle)
                    }
                }
                
            case .showIsPrimaryAlert:
                state.alert = AlertState.saveNewPrimaryVehicleAlert()
                return .none
                
            case .alert(.presented(.confirm)):
                state.alert = nil
                return .send(.saveVehicle)
                
            case .saveVehicle:
                state.isLoading = true
                let vehicle = Vehicle(
                    id: self.uuid(),
                    type: state.vehicleType ?? .car,
                    brand: state.brand,
                    model: state.model,
                    mileage: state.mileage.isEmpty ? nil : state.mileage,
                    registrationDate: state.registrationDate,
                    plate: state.plate,
                    isPrimary: state.isPrimary
                )

                return .run { send in
                    do {
                        try await vehicleRepository.createVehicle(vehicle)

                        // Si véhicule principal, mettre à jour tous les autres
                        if vehicle.isPrimary {
                            try await vehicleRepository.setPrimaryVehicle(vehicle.id)
                        }
                        await send(.updateVehiclesListAndSetVehicleAsSelected(vehicle))
                    } catch {
                        await send(.saveVehicleFailed(error.localizedDescription))
                    }
                }

            case .dismiss:
                return .run { _ in
                    await dismiss()
                }
                
            case .updateVehiclesListAndSetVehicleAsSelected(let newSavedVehicle):
                var newVehiclesArray: [Vehicle] = state.vehicles
                newVehiclesArray.append(newSavedVehicle)
                state.$vehicles.withLock { $0 = newVehiclesArray }
                state.$selectedVehicle.withLock { $0 = newSavedVehicle }
                return .send(.dismiss)

            case .saveVehicleFailed(let errorMessage):
                state.isLoading = false
                state.errorMessage = errorMessage
                state.showErrorAlert = true
                return .none

            case .dismissError:
                state.showErrorAlert = false
                state.errorMessage = nil
                return .none

            case .cancelCreation:
                return .run { _ in
                    await dismiss()
                }

            case .setShowValidationError(let show):
                state.showValidationError = show
                return .none
                
            default: return .none
            }
        }
        .ifLet(\.$scanStore, action: \.scanStore) {
            DocumentScanStore()
        }
    }
}
