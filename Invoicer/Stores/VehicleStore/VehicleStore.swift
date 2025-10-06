//
//  VehicleStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct VehicleStore {
    @ObservableState
    struct State: Equatable {
        var vehicle: Vehicle
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Presents var deleteAlert: AlertState<Action.Alert>?
    }

    enum Action: Equatable {
        case loadVehicleData
        case vehicleDataLoaded(Vehicle)
        case showAddDocument
        case showDocumentDetail(UUID)
        case showEditVehicle
        case deleteVehicleTapped
        case deleteAlert(PresentationAction<Alert>)
        case vehicleDeleted
        case goBack

        enum Alert: Equatable {
            case confirmDelete
        }
    }
    
    @Dependency(\.fileStorageService) var fileStorageService
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadVehicleData:
                return .run { [vehicleId = state.vehicle.id] send in
                    let vehicles = await fileStorageService.loadVehicles()
                    if let updatedVehicle = vehicles.first(where: { $0.id == vehicleId }) {
                        await send(.vehicleDataLoaded(updatedVehicle))
                    }
                }

            case .vehicleDataLoaded(let vehicle):
                state.vehicle = vehicle
                // Mettre à jour aussi dans le shared si pas encore fait
                state.$vehicles.withLock { vehicles in
                    if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
                        vehicles[index] = vehicle
                    }
                }
                return .none

            case .showAddDocument:
                return .none

            case .showDocumentDetail(let documentId):
                return .none

            case .showEditVehicle:
                return .none

            case .deleteVehicleTapped:
                state.deleteAlert = AlertState {
                    TextState("Supprimer le véhicule")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDelete) {
                        TextState("Supprimer")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Annuler")
                    }
                } message: {
                    TextState("Êtes-vous sûr de vouloir supprimer ce véhicule ? Cette action est irréversible.")
                }
                return .none

            case .deleteAlert(.presented(.confirmDelete)):
                return .run { [vehicleId = state.vehicle.id] send in
                    await fileStorageService.deleteVehicle(vehicleId)
                    await send(.vehicleDeleted)
                }

            case .deleteAlert:
                return .none

            case .vehicleDeleted:
                // Supprimer le véhicule de la liste partagée pour mise à jour réactive
                state.$vehicles.withLock { vehicles in
                    vehicles.removeAll { $0.id == state.vehicle.id }
                }
                return .run { _ in
                    await dismiss()
                }

            case .goBack:
                return .run { _ in
                    await dismiss()
                }
            }
        }
        .ifLet(\.$deleteAlert, action: \.deleteAlert)
    }
}