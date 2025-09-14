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
        let originalVehicle: Vehicle
        var name: String
        var currentMileage: String
        var registrationDate: String
        var licensePlate: String
        var isLoading = false
        
        init(vehicle: Vehicle) {
            self.originalVehicle = vehicle
            self.name = vehicle.name
            self.currentMileage = vehicle.currentMileage
            self.registrationDate = vehicle.registrationDate
            self.licensePlate = vehicle.licensePlate
        }
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case updateVehicle
        case vehicleUpdated
        case goBack
    }
    
    @Dependency(\.fileStorageService) var fileStorageService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .updateVehicle:
                state.isLoading = true
                let updatedVehicle = Vehicle(
                    name: state.name,
                    currentMileage: state.currentMileage,
                    registrationDate: state.registrationDate,
                    licensePlate: state.licensePlate,
                    documents: state.originalVehicle.documents
                )
                
                return .run { [originalVehicleId = state.originalVehicle.id] send in
                    await fileStorageService.updateVehicle(originalVehicleId, with: updatedVehicle)
                    await send(.vehicleUpdated)
                }
                
            case .vehicleUpdated:
                state.isLoading = false
                return .none
                
            case .goBack:
                return .none
            }
        }
    }
}
