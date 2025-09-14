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
        @Presents var documentDetail: DocumentDetailCoordinatorStore.State?
        @Presents var editVehicle: EditVehicleStore.State?
    }
    
    enum Action: Equatable {
        case addDocument(PresentationAction<AddDocumentStore.Action>)
        case documentDetail(PresentationAction<DocumentDetailCoordinatorStore.Action>)
        case editVehicle(PresentationAction<EditVehicleStore.Action>)
        case loadVehicleData
        case vehicleDataLoaded(Vehicle)
        case showAddDocument
        case showDocumentDetail(UUID)
        case showEditVehicle
        case documentDeletedReloadAndClose
        case closeDocumentDetailThenDelete(UUID)
        case performBackgroundDeletion(UUID)
        case closeDocumentDetail
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
                state.documentDetail = DocumentDetailCoordinatorStore.State(vehicleId: state.vehicle.id, documentId: documentId)
                return .none
                
            case .showEditVehicle:
                state.editVehicle = EditVehicleStore.State(vehicle: state.vehicle)
                return .none
                
            case .documentDeletedReloadAndClose:
                print("📊 [VehicleStore] Rechargement des données véhicule après suppression")
                return .run { [vehicleId = state.vehicle.id] send in
                    let vehicles = await fileStorageService.loadVehicles()
                    if let updatedVehicle = vehicles.first(where: { $0.id == vehicleId }) {
                        print("✅ [VehicleStore] Données rechargées: \(updatedVehicle.documents.count) documents")
                        await send(.vehicleDataLoaded(updatedVehicle))
                        print("🚪 [VehicleStore] Fermeture de la modal après rechargement")
                        await send(.closeDocumentDetail)
                    }
                }
                
            case .closeDocumentDetailThenDelete(let documentId):
                print("🚪 [VehicleStore] Fermeture immédiate de la modal puis suppression en arrière-plan")
                state.documentDetail = nil
                return .run { send in
                    // Small delay to ensure UI closes smoothly
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                    await send(.performBackgroundDeletion(documentId))
                }
                
            case .performBackgroundDeletion(let documentId):
                print("🗑️ [VehicleStore] Suppression en arrière-plan du document: \(documentId)")
                return .run { [vehicleId = state.vehicle.id] send in
                    let vehicles = await fileStorageService.loadVehicles()
                    if let vehicle = vehicles.first(where: { $0.id == vehicleId }),
                       let document = vehicle.documents.first(where: { $0.id == documentId }) {
                        await fileStorageService.deleteDocument(document, for: vehicleId)
                        await send(.loadVehicleData)
                        print("✅ [VehicleStore] Suppression en arrière-plan terminée")
                    }
                }
                
            case .closeDocumentDetail:
                print("🚪 [VehicleStore] Fermeture de la modal document")
                state.documentDetail = nil
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
                
            case .documentDetail(.presented(.requestDeletion(let documentId))):
                print("📤 [VehicleStore] Demande de fermeture puis suppression reçue pour document: \(documentId)")
                return .run { send in
                    await send(.closeDocumentDetailThenDelete(documentId))
                }
                
            case .documentDetail(.presented(.documentDeleted)):
                print("🗑️ [VehicleStore] Document supprimé - méthode ancienne (ne devrait plus être utilisée)")
                return .run { send in
                    await send(.documentDeletedReloadAndClose)
                }
                
            case .documentDetail(.presented(.goBack)):
                state.documentDetail = nil
                return .run { send in
                    await send(.loadVehicleData)
                }
                
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
            DocumentDetailCoordinatorStore()
        }
        .ifLet(\.$editVehicle, action: \.editVehicle) {
            EditVehicleStore()
        }
    }
}