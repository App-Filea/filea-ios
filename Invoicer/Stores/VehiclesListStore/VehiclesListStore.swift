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
        @Presents var addVehicle: AddVehicleStore.State?
        var isLoading = false
    }

    enum Action: Equatable {
        case loadVehicles
        case vehiclesLoaded([Vehicle])
        case showAddVehicle
        case selectVehicle(Vehicle)
        case addVehicle(PresentationAction<AddVehicleStore.Action>)
    }

    @Dependency(\.fileStorageService) var fileStorageService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadVehicles:
                state.isLoading = true
                return .run { send in
                    let loadedVehicles = await fileStorageService.loadVehicles()
                    await send(.vehiclesLoaded(loadedVehicles))
                }

            case .vehiclesLoaded(let vehicles):
                state.isLoading = false
                state.$vehicles.withLock { $0 = vehicles }
                return .none

            case .showAddVehicle:
                state.addVehicle = AddVehicleStore.State()
                return .none

            case .selectVehicle(let vehicle):
                // Update selected vehicle (navigation handled by AppStore+Path)
                state.$selectedVehicle.withLock { $0 = vehicle }
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
