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
        @Presents var deleteAlert: AlertState<Action.Alert>?
        @Presents var vehiclesList: VehiclesListModalStore.State?

        var currentVehicle: Vehicle? {
            vehicles.first
        }

        var currentVehicleDocuments: [Document] {
            currentVehicle?.documents ?? []
        }
    }

    enum Action: Equatable {
        case vehicleDetail(PresentationAction<VehicleStore.Action>)
        case vehiclesList(PresentationAction<VehiclesListModalStore.Action>)
        case loadVehicles
        case vehiclesLoaded([Vehicle])
        case showAddVehicle
        case showVehicleDetail(Vehicle)
        case showVehiclesList
        case showSettings
        case showAddDocument
        case showDocumentDetail(Document)
        case showEditVehicle
        case deleteVehicleTapped
        case deleteAlert(PresentationAction<Alert>)
        case vehicleDeleted

        enum Alert: Equatable {
            case confirmDelete
        }
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

            case .showVehiclesList:
                // Afficher le fullScreenCover (en modal)
                state.vehiclesList = VehiclesListModalStore.State()
                return .none

            case .showAddVehicle:
                // Navigation handled by AppStore+Path
                return .none

            case .showSettings:
                // Navigation handled by AppStore+Path (to be implemented)
                return .none

            case .showAddDocument:
                // Navigation handled by AppStore+Path
                return .none

            case .showDocumentDetail:
                // Navigation handled by AppStore+Path
                return .none

            case .showEditVehicle:
                // Navigation handled by AppStore+Path
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
                guard let vehicleId = state.currentVehicle?.id else {
                    return .none
                }
                return .run { send in
                    await fileStorageService.deleteVehicle(vehicleId)
                    await send(.vehicleDeleted)
                }

            case .deleteAlert:
                return .none

            case .vehicleDeleted:
                // Supprimer le véhicule de la liste partagée pour mise à jour réactive
                if let vehicleId = state.currentVehicle?.id {
                    state.$vehicles.withLock { vehicles in
                        vehicles.removeAll { $0.id == vehicleId }
                    }
                }
                return .none

            case .vehicleDetail(.presented(.goBack)):
                state.vehicleDetail = nil
                return .none

            case .vehicleDetail:
                return .none

            case .vehiclesList(.presented(.selectVehicle)):
                // Dismiss le fullScreenCover après sélection
                state.vehiclesList = nil
                return .none

            case .vehiclesList:
                return .none
            }
        }
        .ifLet(\.$vehicleDetail, action: \.vehicleDetail) {
            VehicleStore()
        }
        .ifLet(\.$deleteAlert, action: \.deleteAlert)
        .ifLet(\.$vehiclesList, action: \.vehiclesList) {
            VehiclesListModalStore()
        }
    }
}
