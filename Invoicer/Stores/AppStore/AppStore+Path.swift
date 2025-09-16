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
        case .element(id: _, action: .main(.showAddVehicle)): 
            state.path.append(.addVehicle(AddVehicleStore.State()))
            
        case .element(id: _, action: .main(.showVehicleDetail(let vehicle))): 
            state.path.append(.vehicle(VehicleStore.State(vehicle: vehicle)))
            
        case .element(id: _, action: .vehicle(.showEditVehicle)):
            if case .vehicle(let vehicleState) = state.path.last {
                state.path.append(.editVehicle(EditVehicleStore.State(vehicle: vehicleState.vehicle)))
            }
            
        case .element(id: _, action: .vehicle(.showAddDocument)):
            if case .vehicle(let vehicleState) = state.path.last {
                state.path.append(.addDocument(AddDocumentStore.State(vehicleId: vehicleState.vehicle.id)))
            }
            
        case .element(id: _, action: .vehicle(.showDocumentDetail(let documentId))):
            if case .vehicle(let vehicleState) = state.path.last {
                state.path.append(.documentDetail(DocumentDetailCoordinatorStore.State(vehicleId: vehicleState.vehicle.id, documentId: documentId)))
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
