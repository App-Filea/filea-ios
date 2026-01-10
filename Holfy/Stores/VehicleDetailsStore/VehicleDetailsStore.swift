//
//  VehicleDetailsStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct VehicleDetailsStore {
    @ObservableState
    struct State: Equatable {
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
    }

    enum Action: Equatable {
        case dismiss
        case editVehicleButtonTapped
        case editVehicle
    }
    
    @Dependency(\.vehicleGRDBClient) var vehicleRepository
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .editVehicleButtonTapped:
                return .send(.editVehicle)

            case .editVehicle:
                return .none
                
            case .dismiss:
                return .run { _ in
                    await dismiss()
                }
            default: return .none
            }
        }
    }
}
