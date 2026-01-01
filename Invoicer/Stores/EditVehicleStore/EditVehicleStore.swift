//
//  EditVehicleStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct EditVehicleStore {
    @ObservableState
    struct State: Equatable {
        var type: VehicleType
        var brand: String
        var model: String
        var mileage: String
        var registrationDate: Date
        var plate: String
        var isPrimary: Bool
        
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle

        init() {
            @Shared(.selectedVehicle) var selectedVehicle: Vehicle
            self.type = selectedVehicle.type
            self.brand = selectedVehicle.brand
            self.model = selectedVehicle.model
            self.mileage = selectedVehicle.mileage ?? ""
            self.registrationDate = selectedVehicle.registrationDate
            self.plate = selectedVehicle.plate
            self.isPrimary = selectedVehicle.isPrimary
        }
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case view(ActionView)
        case updateVehicle
        case updateShareds(selectedVehicle: Vehicle, vehiclesList: [Vehicle])
        case dismiss
        
        enum ActionView: Equatable {
            case saveButtonTapped
            case cancelButtonTapped
            case backButtonTapped
        }
    }
    
    @Dependency(\.vehicleRepository) var vehicleRepository
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding: return .none
                
            case .view(let actionView):
                switch actionView {
                case .saveButtonTapped: return .send(.updateVehicle)
                    case .cancelButtonTapped, .backButtonTapped: return .send(.dismiss)
                }
                
            case .updateVehicle:
                var updatedVehiclesList: [Vehicle] = state.vehicles
                let updatedVehicle = Vehicle(
                    id: state.selectedVehicle.id,
                    type: state.type,
                    brand: state.brand,
                    model: state.model,
                    mileage: state.mileage.isEmpty ? nil : state.mileage,
                    registrationDate: state.registrationDate,
                    plate: state.plate,
                    isPrimary: state.isPrimary,
                    documents: state.selectedVehicle.documents
                )
                
                for index in updatedVehiclesList.indices {
                    if updatedVehiclesList[index].id == state.selectedVehicle.id {
                        updatedVehiclesList[index] = updatedVehicle
                    } else {
                        updatedVehiclesList[index].isPrimary = !state.isPrimary
                    }
                }

                return .run { [updatedVehiclesList = updatedVehiclesList] send in
                    do {
                        for vehicle in updatedVehiclesList {
                            try await vehicleRepository.updateVehicle(vehicle)
                        }
                        await send(.updateShareds(selectedVehicle: updatedVehicle, vehiclesList: updatedVehiclesList))
                    } catch {}
                }

            case .updateShareds(let updatedVehicle, let updatedVehiclesList):
                state.$vehicles.withLock { $0 = updatedVehiclesList }
                state.$selectedVehicle.withLock { $0 = updatedVehicle }

                return .send(.dismiss)
                
            case .dismiss: return .run { _ in await dismiss() }
            }
        }
    }
}
