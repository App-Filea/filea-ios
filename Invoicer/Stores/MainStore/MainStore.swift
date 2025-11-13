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
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle?
        @Presents var vehicleDetail: VehicleDetailsStore.State?
        @Presents var deleteAlert: AlertState<Action.Alert>?
        @Presents var vehiclesList: VehiclesListStore.State?
        @Presents var addVehicle: AddVehicleStore.State?
        @Presents var addDocument: AddDocumentStore.State?
        
        var warningVehicle: WarningVehicleStore.State = WarningVehicleStore.State()
        var totalCostVehicle: TotalCostVehicleStore.State = TotalCostVehicleStore.State()
        var vehicleMonthlyExpenses: VehicleMonthlyExpensesStore.State = VehicleMonthlyExpensesStore.State()
        
        var showEmptyState: Bool = false
        var currentVehicleTotalCost: Double = 0
        var currentVehicleMonthlyExpenses: [MonthlyExpense] = []
        var currentVehicleIncompleteDocumentsCount: Int = 0

        var currentVehicle: Vehicle? {
            selectedVehicle
        }

        var currentVehicleDocuments: [Document] {
            currentVehicle?.documents ?? []
        }
    }

    enum Action: Equatable {
        case warningVehicle(WarningVehicleStore.Action)
        case totalCostVehicle(TotalCostVehicleStore.Action)
        case vehicleMonthlyExpenses(VehicleMonthlyExpensesStore.Action)
        
        case view(ActionView)
        
        case onAppear
        case vehicleDetail(PresentationAction<VehicleDetailsStore.Action>)
        case vehiclesList(PresentationAction<VehiclesListStore.Action>)
        case addVehicle(PresentationAction<AddVehicleStore.Action>)
        case addDocument(PresentationAction<AddDocumentStore.Action>)
        case presentAddVehicleView
        case showVehicleDetail(Vehicle)
        case presentVehiclesListView
        case showSettings
        case showAddDocument
        case showDocumentDetail(Document)
        case showEditVehicle
        case deleteVehicleTapped
        case deleteAlert(PresentationAction<Alert>)
        case vehicleDeleted
        case setupVehicleStatistics
        case vehicleMonthlyExpensesCalculated([MonthlyExpense])

        enum ActionView: Equatable {
            case openCreateVehicleButtonTapped
        }
        
        enum Alert: Equatable {
            case confirmDelete
        }
    }
    
    @Dependency(\.vehicleRepository) var vehicleRepository

    var body: some ReducerOf<Self> {
        Scope(state: \.warningVehicle, action: \.warningVehicle) { WarningVehicleStore() }
        Scope(state: \.totalCostVehicle, action: \.totalCostVehicle) { TotalCostVehicleStore() }
        Scope(state: \.vehicleMonthlyExpenses, action: \.vehicleMonthlyExpenses) { VehicleMonthlyExpensesStore() }

        Reduce { state, action in
            switch action {
                
            case .view(let actionView):
                switch actionView {
                case .openCreateVehicleButtonTapped:
                    return .send(.presentAddVehicleView)
                }
                
            case .onAppear:
                if state.vehicles.isEmpty {
                    state.showEmptyState = true
                    return .none
                } else if state.selectedVehicle == nil {
                    return .send(.presentVehiclesListView)
                }
                return .send(.setupVehicleStatistics)
                
            case .setupVehicleStatistics:
                return .concatenate(.send(.warningVehicle(.computeVehicleWarnings)),
                                    .send(.totalCostVehicle(.computeVehicleTotalCost)),
                                    .send(.vehicleMonthlyExpenses(.computeVehicleMontlyExpenses)))
                
            case \.showVehicleDetail:
                state.vehicleDetail = VehicleDetailsStore.State()
                return .none

            case .presentVehiclesListView:
                state.vehiclesList = VehiclesListStore.State()
                return .none

            case .presentAddVehicleView:
                state.addVehicle = AddVehicleStore.State()
                return .none
                
            case .addVehicle(.presented(.vehicleIsCreatedAndSelected)),
                    .vehiclesList(.presented(.vehicleIsCreatedAndSelected)):
                return .send(.setupVehicleStatistics) // maybe this could be done via publisher inside every store at selectedVehicle shared is updated

//            case .showSettings:
//                // Navigation handled by AppStore+Path (to be implemented)
//                return .none
//
//            case .showAddDocument:
//                guard let currentVehicle = state.currentVehicle else {
//                    return .none
//                }
//                state.addDocument = AddDocumentStore.State(vehicleId: currentVehicle.id)
//                return .none
//
//            case .showDocumentDetail:
//                // Navigation handled by AppStore+Path
//                return .none
//
//            case .showEditVehicle:
//                // Navigation handled by AppStore+Path
//                return .none
//
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
//
//            case .deleteAlert(.presented(.confirmDelete)):
//                guard let vehicleId = state.currentVehicle?.id else {
//                    return .none
//                }
//                return .run { send in
//                    do {
//                        try await vehicleRepository.deleteVehicle(vehicleId)
//                        await send(.vehicleDeleted)
//                    } catch {
//                        // Handle error - for now just continue
//                        await send(.vehicleDeleted)
//                    }
//                }
//
//            case .deleteAlert:
//                return .none
//
//            case .vehicleDeleted:
//                // Supprimer le véhicule de la liste partagée pour mise à jour réactive
//                if let vehicleId = state.currentVehicle?.id {
//                    state.$vehicles.withLock { vehicles in
//                        vehicles.removeAll { $0.id == vehicleId }
//                    }
//                    // La resélection sera gérée dans AppStore
//                    state.$selectedVehicle.withLock { $0 = nil }
//                }
//                return .none
//
//            case .addDocument(.dismiss):
//                // Recalculer le coût total après la fermeture du modal d'ajout de document
//                return .send(.setupVehicleStatistics)
//
//            case .addDocument:
//                return .none
                
            default: return .none
            }
        }
        .ifLet(\.$vehicleDetail, action: \.vehicleDetail) {
            VehicleDetailsStore()
        }
        .ifLet(\.$deleteAlert, action: \.deleteAlert)
        .ifLet(\.$vehiclesList, action: \.vehiclesList) {
            VehiclesListStore()
        }
        .ifLet(\.$addVehicle, action: \.addVehicle) {
            AddVehicleStore()
        }
        .ifLet(\.$addDocument, action: \.addDocument) {
            AddDocumentStore()
        }
    }
}
