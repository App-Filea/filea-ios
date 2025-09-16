//
//  MainStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct MainStore {
    @ObservableState
    struct State: Equatable {
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Presents var vehicleDetail: VehicleStore.State?
    }
    
    enum Action: Equatable {
        case vehicleDetail(PresentationAction<VehicleStore.Action>)
        case loadVehicles
        case vehiclesLoaded([Vehicle])
        case showAddVehicle
        case showVehicleDetail(Vehicle)
    }
    
    @Dependency(\.fileStorageService) var fileStorageService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadVehicles:
                return .run { send in
                    let loadedVehicles = await fileStorageService.loadVehicles()
                    await send(.vehiclesLoaded(loadedVehicles))
                }
                
            case .vehiclesLoaded(let vehicles):
                state.$vehicles.withLock { $0 = vehicles }
                return .none
                
            case .showVehicleDetail(let vehicle):
                state.vehicleDetail = VehicleStore.State(vehicle: vehicle)
                return .none
                
            case .vehicleDetail(.presented(.goBack)):
                state.vehicleDetail = nil
                return .none
                
            case .vehicleDetail:
                return .none
                
            default: return .none
            }
        }
        .ifLet(\.$vehicleDetail, action: \.vehicleDetail) {
            VehicleStore()
        }
    }
}
