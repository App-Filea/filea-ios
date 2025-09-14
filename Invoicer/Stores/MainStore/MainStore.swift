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
        var vehicles: [Vehicle] = []
        @Presents var addVehicle: AddVehicleStore.State?
        @Presents var vehicleDetail: VehicleStore.State?
    }
    
    enum Action: Equatable {
        case addVehicle(PresentationAction<AddVehicleStore.Action>)
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
                    let vehicles = await fileStorageService.loadVehicles()
                    await send(.vehiclesLoaded(vehicles))
                }
                
            case .vehiclesLoaded(let vehicles):
                state.vehicles = vehicles
                return .none
                
            case .showAddVehicle:
                state.addVehicle = AddVehicleStore.State()
                return .none
                
            case .showVehicleDetail(let vehicle):
                state.vehicleDetail = VehicleStore.State(vehicle: vehicle)
                return .none
                
            case .addVehicle(.presented(.vehicleSaved)):
                state.addVehicle = nil
                return .run { send in
                    await send(.loadVehicles)
                }
                
            case .addVehicle(.presented(.goBack)):
                state.addVehicle = nil
                return .none
                
            case .vehicleDetail(.presented(.goBack)):
                state.vehicleDetail = nil
                return .run { send in
                    await send(.loadVehicles)
                }
                
            case .addVehicle:
                return .none
                
            case .vehicleDetail:
                return .none
            }
        }
        .ifLet(\.$addVehicle, action: \.addVehicle) {
            AddVehicleStore()
        }
        .ifLet(\.$vehicleDetail, action: \.vehicleDetail) {
            VehicleStore()
        }
    }
}