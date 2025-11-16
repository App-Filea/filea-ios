//
//  VehiclesListStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 11/10/2025.
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
        case view(ActionView)
        case presentAddVehicleView
        case selectVehicle(Vehicle)
        case dismiss
        case addVehicle(PresentationAction<AddVehicleStore.Action>)
        
        enum ActionView: Equatable {
            case dimissSheetButtonTapped
            case openCreateVehicleButtonTapped
            case selectedVehicleButtonTapped(Vehicle)
        }
    }

    @Dependency(\.vehicleRepository) var vehicleRepository
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(let actionView):
                switch actionView {
                case .dimissSheetButtonTapped:
                    return .send(.dismiss)
                case .openCreateVehicleButtonTapped:
                    return .send(.presentAddVehicleView)
                case .selectedVehicleButtonTapped(let selectedVehicle):
                    return .send(.selectVehicle(selectedVehicle))
                }

            case .presentAddVehicleView:
                state.addVehicle = AddVehicleStore.State()
                return .none

            case .selectVehicle(let selectedVehicle):
                state.$selectedVehicle.withLock { $0 = selectedVehicle }
                state.$lastOpenedVehicleId.withLock { $0 = selectedVehicle.id }
                return .send(.dismiss)

            case .dismiss:
                return .run { _ in
                    await self.dismiss()
                }
                
            default: return .none
            }
        }
        .ifLet(\.$addVehicle, action: \.addVehicle) {
            AddVehicleStore()
        }
    }
}
