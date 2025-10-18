//
//  AppStore+Path.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 14/09/2025.
//

import ComposableArchitecture

extension AppStore {

    func switchAccordingActions(_ stackAction: StackAction<Path.State, Path.Action>, state: inout AppStore.State) -> Effect<AppStore.Action> {
        switch stackAction {
        // Handle storage configuration completion
        case .element(id: _, action: .storageOnboarding(.folderSaved)):
            return .send(.storageConfigured)

        // Navigation from VehiclesListView
        case .element(id: _, action: .vehiclesList(.selectVehicle)):
            state.path.append(.main(MainStore.State()))

        case .element(id: _, action: .main(.showAddVehicle)):
            state.path.append(.addVehicle(AddVehicleStore.State()))

        case .element(id: _, action: .main(.showVehicleDetail(let vehicle))):
            state.path.append(.vehicleDetails(VehicleDetailsStore.State()))

        // AddDocument now handled by sheet in MainView
        case .element(id: _, action: .main(.showAddDocument)):
            return .none

        case .element(id: _, action: .main(.showDocumentDetail(let document))):
            if case .main(let mainState) = state.path.last,
               let currentVehicle = mainState.currentVehicle {
                state.path.append(.documentDetail(DocumentDetailCoordinatorStore.State(vehicleId: currentVehicle.id, documentId: document.id)))
            }

        // Navigation from MainStore to EditVehicle
        case .element(id: _, action: .main(.showEditVehicle)):
            if case .main(let mainState) = state.path.last,
               let currentVehicle = mainState.currentVehicle {
                state.path.append(.editVehicle(EditVehicleStore.State(vehicle: currentVehicle)))
            }

        case .element(id: _, action: .documentDetail(.editDocumentLoaded(let document))):
            if case .documentDetail(let documentDetailState) = state.path.last {
                state.path.append(.editDocument(EditDocumentStore.State(vehicleId: documentDetailState.vehicleId, document: document)))
            }

        // Handle vehicle creation - reload and navigate to list
        case .element(id: _, action: .addVehicle(.vehicleSaved)):
            return .send(.vehicleListChanged)

        // Handle vehicle deletion - reload and navigate to appropriate view
        case .element(id: _, action: .main(.vehicleDeleted)):
            return .send(.vehicleListChanged)

        case .element(id: _, action: .vehicleDetails(.vehicleDeleted)):
            return .send(.vehicleListChanged)

        default: return .none
        }
        return .none
    }
}
