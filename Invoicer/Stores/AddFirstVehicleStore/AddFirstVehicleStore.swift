//
//  AddFirstVehicleStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 02/01/2026.
//

import ComposableArchitecture
import Foundation
import UIKit

@Reducer
struct AddFirstVehicleStore {

    @ObservableState
    struct State: Equatable {
        var type: VehicleType
        var brand: String
        var model: String
        var plate: String
        var registrationDate: Date
        var mileage: String
        var isPrimary: Bool
        
        var validationErrors: VehicleFieldsValidationErrors = []
        
        @Shared(.vehicles) var vehicles: [Vehicle] = []
//        @Presents var scanStore: VehicleCardDocumentScanStore.State?

        init(
            type: VehicleType = .car,
            brand: String = "",
            model: String = "",
            plate: String = "",
            registrationDate: Date? = nil,
            mileage: String = "",
            isPrimary: Bool = true
        ) {
            @Dependency(\.date) var date

            self.type = type
            self.brand = brand
            self.model = model
            self.plate = plate
            self.registrationDate = registrationDate ?? date.now
            self.mileage = mileage
            self.isPrimary = isPrimary
        }
    }

    enum Action: Equatable, BindableAction {
        case view(ActionView)
        case binding(BindingAction<State>)
        case saveVehicle
        case saveVehicleFailed(String)
        case updateVehiclesList(vehicles: [Vehicle])
//        case openScanStore
//        case scanStore(PresentationAction<VehicleCardDocumentScanStore.Action>)
//        case applyScanData(ScannedVehicleData)
        case firstVehicleAdded
        case dismiss

        enum ActionView: Equatable {
            case cancelButtonTapped
            case saveButtonTapped
//            case scanButtonTapped
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
                case .cancelButtonTapped: return .send(.dismiss)
                case .saveButtonTapped:
                    state.validationErrors = validateFields(state)
                    guard state.validationErrors.isEmpty else {
                        return .none
                    }
                    return .send(.saveVehicle)
                    
////                case .scanButtonTapped:
////                    return .send(.openScanStore)
                }

////            case .openScanStore:
////                state.scanStore = VehicleCardDocumentScanStore.State()
////                return .none
//
////            case .scanStore(.presented(.confirmData)):
////                if let extractedData = state.scanStore?.extractedData {
////                    return .send(.applyScanData(extractedData))
////                }
////                return .none
////
////            case .applyScanData(let data):
////                state.scanStore = nil
////
////                if let brand = data.brand {
////                    state.brand = brand
////                }
////                if let model = data.model {
////                    state.model = model
////                }
////                if let plate = data.plate {
////                    state.plate = plate
////                }
////                if let date = data.registrationDate {
////                    state.registrationDate = date
////                }
////                return .none
            case .saveVehicle:
                let newVehicle = Vehicle(
                    id: self.uuid().uuidString.lowercased(),
                    type: state.type,
                    brand: state.brand,
                    model: state.model,
                    mileage: state.mileage.isEmpty ? nil : state.mileage,
                    registrationDate: state.registrationDate,
                    plate: state.plate,
                    isPrimary: state.isPrimary
                )

                return .run { send in
                    do {
                        try await vehicleRepository.createVehicle(newVehicle)
                        if newVehicle.isPrimary {
                            try await vehicleRepository.setPrimaryVehicle(newVehicle.id)
                        }
                        let updatedVehicles = try await vehicleRepository.getAllVehicles()
                        await send(.updateVehiclesList(vehicles: updatedVehicles))
                    } catch {
                        await send(.saveVehicleFailed(error.localizedDescription))
                    }
                }

            case .dismiss:
                return .run { _ in
                    await dismiss()
                }
                
            case .updateVehiclesList(let vehicles):
                state.$vehicles.withLock { $0 = vehicles }
                return .merge([.send(.firstVehicleAdded),
                               .send(.dismiss)])

            case .saveVehicleFailed:
                return .none

            default: return .none
            }
        }
//        .ifLet(\.$scanStore, action: \.scanStore) {
//            VehicleCardDocumentScanStore()
//        }
    }
    
    private func validateFields(_ state: State) -> VehicleFieldsValidationErrors {
        var errors: VehicleFieldsValidationErrors = []

        if state.brand.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.insert(.brandEmpty)
        }
        if state.model.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.insert(.modelEmpty)
        }
        if state.plate.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.insert(.plateEmpty)
        }

        return errors
    }
}
