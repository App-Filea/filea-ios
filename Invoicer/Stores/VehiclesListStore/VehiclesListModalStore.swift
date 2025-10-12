//
//  VehiclesListModalStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 11/10/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct VehiclesListModalStore {
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
        case dismiss
        case addVehicle(PresentationAction<AddVehicleStore.Action>)
    }

    @Dependency(\.fileStorageService) var fileStorageService
    @Dependency(\.dismiss) var dismiss

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
                // Update selected vehicle before dismissing
                state.$selectedVehicle.withLock { $0 = vehicle }
                return .run { _ in
                    await dismiss()
                }

            case .dismiss:
                return .run { _ in
                    await dismiss()
                }

            case .addVehicle:
                return .none
            }
        }
        .ifLet(\.$addVehicle, action: \.addVehicle) {
            AddVehicleStore()
        }
    }
}
