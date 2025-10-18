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
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle?
        @Presents var deleteAlert: AlertState<Action.Alert>?
        @Presents var editVehicle: EditVehicleStore.State?
    }

    enum Action: Equatable {
        case deleteVehicleTapped
        case deleteAlert(PresentationAction<Alert>)
        case vehicleDeleted
        case goBack
        case editVehicleTapped
        case editVehicle(PresentationAction<EditVehicleStore.Action>)

        enum Alert: Equatable {
            case confirmDelete
        }
    }
    
    @Dependency(\.vehicleRepository) var vehicleRepository
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .editVehicleTapped:
                guard let vehicle = state.selectedVehicle else { return .none }
                state.editVehicle = EditVehicleStore.State(vehicle: vehicle)
                return .none

            case .editVehicle(.presented(.vehicleUpdated)):
                // Vehicle has been updated, close the sheet
                state.editVehicle = nil
                return .none

            case .editVehicle:
                return .none

//            case .deleteVehicleTapped:
//                state.deleteAlert = AlertState {
//                    TextState("Supprimer le véhicule")
//                } actions: {
//                    ButtonState(role: .destructive, action: .confirmDelete) {
//                        TextState("Supprimer")
//                    }
//                    ButtonState(role: .cancel) {
//                        TextState("Annuler")
//                    }
//                } message: {
//                    TextState("Êtes-vous sûr de vouloir supprimer ce véhicule ? Cette action est irréversible.")
//                }
//                return .none

//            case .deleteAlert(.presented(.confirmDelete)):
//                guard let vehicleId = state.selectedVehicle?.id else { return .none }
//                return .run { send in
//                    await fileStorageService.deleteVehicle(vehicleId)
//                    await send(.vehicleDeleted)
//                }
//
//            case .deleteAlert:
//                return .none
//
//            case .vehicleDeleted:
//                // Supprimer le véhicule de la liste partagée pour mise à jour réactive
//                state.$vehicles.withLock { vehicles in
//                    vehicles.removeAll { $0.id == state.selectedVehicle.id }
//                }
//                return .run { _ in
//                    await dismiss()
//                }

            case .goBack:
                return .run { _ in
                    await dismiss()
                }
            default: return .none
            }
        }
        .ifLet(\.$deleteAlert, action: \.deleteAlert)
        .ifLet(\.$editVehicle, action: \.editVehicle) {
            EditVehicleStore()
        }
    }
}
