//
//  AddVehicleStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AddVehicleStore {
    @ObservableState
    struct State: Equatable {
        var vehicle = Vehicle()
        var isLoading = false
        @Shared(.vehicles) var vehicles: [Vehicle] = []
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case saveVehicle
        case vehicleSaved
        case goBack
    }
    
    @Dependency(\.fileStorageService) var fileStorageService
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .saveVehicle:
                state.isLoading = true
                return .run { [vehicle = state.vehicle] send in
                    await fileStorageService.saveVehicle(vehicle)
                    await send(.vehicleSaved)
                }
                
            case .vehicleSaved:
                state.isLoading = false
                // Ajouter le véhicule à la liste partagée pour mise à jour réactive
                state.$vehicles.withLock { $0.append(state.vehicle) }
                return .run { _ in
                    await dismiss()
                }
                
            case .goBack:
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}