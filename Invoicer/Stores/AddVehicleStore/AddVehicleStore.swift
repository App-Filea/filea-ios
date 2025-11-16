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
        var showErrorAlert: Bool = false
        var errorMessage: String? = nil
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle?
        @Presents var scanStore: VehicleCardDocumentScanStore.State?
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
        case saveVehicle
        case saveVehicleFailed(String)
        case updateVehiclesListAndSetNewVehicleAsSelected(vehicles: [Vehicle], newVehicle: Vehicle)
        case cancelCreation
        case scanStore(PresentationAction<VehicleCardDocumentScanStore.Action>)
        case applyScanData(ScannedVehicleData)
        case alert(PresentationAction<Alert>)
        case dismiss
        case openScanStore

        enum ActionView: Equatable {
            case saveVehicleButtonTapped
            case scanButtonTapped
        }

        enum Alert: Equatable {
            case yes
            case no
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
                    
                case .scanButtonTapped:
                    return .send(.openScanStore)
                }

            case .openScanStore:
                state.scanStore = VehicleCardDocumentScanStore.State()
                return .none

            case .scanStore(.presented(.confirmData)):
                if let extractedData = state.scanStore?.extractedData {
                    return .send(.applyScanData(extractedData))
                }
                return .none

            case .applyScanData(let data):
                state.scanStore = nil

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
                return .run { [isPrimary = state.isPrimary] send in
                    if await vehicleRepository.hasPrimaryVehicle() && isPrimary {
                        await send(.showIsPrimaryAlert)
                    } else {
                        await send(.saveVehicle)
                    }
                }
                
            case .showIsPrimaryAlert:
                state.alert = AlertState.saveNewPrimaryVehicleAlert()
                return .none
                
            case .alert(.presented(.yes)):
                state.alert = nil
                return .send(.saveVehicle)
                
            case .alert(.presented(.no)):
                state.alert = nil
                return .none
                
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
                        if vehicle.isPrimary {
                            try await vehicleRepository.setPrimaryVehicle(vehicle.id)
                        }
                        let updatedVehicles = try await vehicleRepository.getAllVehicles()
                        await send(.updateVehiclesListAndSetNewVehicleAsSelected(vehicles: updatedVehicles, newVehicle: vehicle))
                    } catch {
                        await send(.saveVehicleFailed(error.localizedDescription))
                    }
                }

            case .dismiss:
                return .run { _ in
                    await dismiss()
                }
                
            case .updateVehiclesListAndSetNewVehicleAsSelected(let vehicles, let newVehicle):
                state.$vehicles.withLock { $0 = vehicles }
                state.$selectedVehicle.withLock { $0 = newVehicle }
                return .send(.dismiss)

            case .saveVehicleFailed(let errorMessage):
                state.isLoading = false
                state.errorMessage = errorMessage
                state.showErrorAlert = true
                return .none

            case .cancelCreation:
                return .run { _ in
                    await dismiss()
                }

            default: return .none
            }
        }
        .ifLet(\.$scanStore, action: \.scanStore) {
            VehicleCardDocumentScanStore()
        }
    }
}
