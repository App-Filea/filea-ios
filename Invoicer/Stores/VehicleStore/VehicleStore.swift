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
        @Presents var addDocument: AddDocumentStore.State?
        @Presents var documentDetail: DocumentDetailStore.State?
        @Presents var editVehicle: EditVehicleStore.State?
    }
    
    enum Action: Equatable {
        case addDocument(PresentationAction<AddDocumentStore.Action>)
        case documentDetail(PresentationAction<DocumentDetailStore.Action>)
        case editVehicle(PresentationAction<EditVehicleStore.Action>)
        case loadVehicleData
        case vehicleDataLoaded(Vehicle)
        case showAddDocument
        case showDocumentDetail(UUID)
        case showEditVehicle
        case deleteVehicle
        case vehicleDeleted
        case goBack
    }
    
    @Dependency(\.fileStorageService) var fileStorageService
    
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
                return .none
                
            case .showAddDocument:
                state.addDocument = AddDocumentStore.State(vehicleId: state.vehicle.id)
                return .none
                
            case .showDocumentDetail(let documentId):
                state.documentDetail = DocumentDetailStore.State(vehicleId: state.vehicle.id, documentId: documentId)
                return .none
                
            case .showEditVehicle:
                state.editVehicle = EditVehicleStore.State(vehicle: state.vehicle)
                return .none
                
            case .addDocument(.presented(.documentSaved)):
                state.addDocument = nil
                return .run { send in
                    await send(.loadVehicleData)
                }
                
            case .addDocument(.presented(.goBack)):
                state.addDocument = nil
                return .none
                
            case .addDocument:
                return .none
                
            case .documentDetail(.presented(.documentDeleted)):
                state.documentDetail = nil
                return .run { send in
                    await send(.loadVehicleData)
                }
                
            case .documentDetail(.presented(.goBack)):
                state.documentDetail = nil
                return .none
                
            case .documentDetail:
                return .none
                
            case .editVehicle(.presented(.vehicleUpdated)):
                state.editVehicle = nil
                return .run { send in
                    await send(.loadVehicleData)
                }
                
            case .editVehicle(.presented(.goBack)):
                state.editVehicle = nil
                return .none
                
            case .editVehicle:
                return .none
                
            case .deleteVehicle:
                return .run { [vehicleId = state.vehicle.id] send in
                    await fileStorageService.deleteVehicle(vehicleId)
                    await send(.vehicleDeleted)
                }
                
            case .vehicleDeleted:
                return .run { send in
                    await send(.goBack)
                }
                
            case .goBack:
                return .none
            }
        }
        .ifLet(\.$addDocument, action: \.addDocument) {
            AddDocumentStore()
        }
        .ifLet(\.$documentDetail, action: \.documentDetail) {
            DocumentDetailStore()
        }
        .ifLet(\.$editVehicle, action: \.editVehicle) {
            EditVehicleStore()
        }
    }
}