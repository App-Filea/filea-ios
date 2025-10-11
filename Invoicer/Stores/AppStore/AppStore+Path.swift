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
        // Navigation from VehiclesListView
        case .element(id: _, action: .vehiclesList(.selectVehicle)):
            state.path.append(.main(MainStore.State()))

        case .element(id: _, action: .main(.showAddVehicle)):
            state.path.append(.addVehicle(AddVehicleStore.State()))

        case .element(id: _, action: .main(.showVehicleDetail(let vehicle))):
            state.path.append(.vehicle(VehicleStore.State(vehicle: vehicle)))

        // Navigation from MainStore to documents
        case .element(id: _, action: .main(.showAddDocument)):
            if case .main(let mainState) = state.path.last,
               let currentVehicle = mainState.currentVehicle {
                state.path.append(.addDocument(AddDocumentStore.State(vehicleId: currentVehicle.id)))
            }

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

        case .element(id: _, action: .vehicle(.showEditVehicle)):
            if case .vehicle(let vehicleState) = state.path.last {
                state.path.append(.editVehicle(EditVehicleStore.State(vehicle: vehicleState.vehicle)))
            }

        case .element(id: _, action: .documentDetail(.editDocumentLoaded(let document))):
            if case .documentDetail(let documentDetailState) = state.path.last {
                state.path.append(.editDocument(EditDocumentStore.State(vehicleId: documentDetailState.vehicleId, document: document)))
            }

        default: return .none
        }
        return .none
    }
}
