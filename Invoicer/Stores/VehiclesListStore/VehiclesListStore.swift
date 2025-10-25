//
//  VehiclesListStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct VehiclesListStore {
    @ObservableState
    struct State: Equatable {
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle?
        @Shared(.lastOpenedVehicleId) var lastOpenedVehicleId: UUID?
        @Presents var addVehicle: AddVehicleStore.State?
        var isLoading = false
    }

    enum Action: Equatable {
        case vehiclesLoaded([Vehicle])
        case showAddVehicle
        case dismissAddVehicle
        case selectVehicle(Vehicle)
        case addVehicle(PresentationAction<AddVehicleStore.Action>)
    }

    @Dependency(\.vehicleRepository) var vehicleRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .vehiclesLoaded(let vehicles):
                state.isLoading = false
                state.$vehicles.withLock { $0 = vehicles }
                return .none

            case .showAddVehicle:
                state.addVehicle = AddVehicleStore.State()
                return .none
                
            case .dismissAddVehicle:
                state.addVehicle = nil
                return .none

            case .selectVehicle(let vehicle):
                // Update selected vehicle and save last opened ID (navigation handled by AppStore+Path)
                state.$selectedVehicle.withLock { $0 = vehicle }
                state.$lastOpenedVehicleId.withLock { $0 = vehicle.id }
                return .none

            case .addVehicle:
                return .none
            }
        }
        .ifLet(\.$addVehicle, action: \.addVehicle) {
            AddVehicleStore()
        }
    }
}
