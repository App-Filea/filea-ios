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
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        @Shared(.isStorageConfigured) var isStorageConfigured = false
        @Presents var vehicleDetail: VehicleDetailsStore.State?
        @Presents var deleteAlert: AlertState<Action.Alert>?
        @Presents var vehiclesList: VehiclesListStore.State?
        @Presents var addFirstVehicle: AddFirstVehicleStore.State?
        @Presents var addDocument: AddDocumentStore.State?

        var warningVehicle: WarningVehicleStore.State = WarningVehicleStore.State()
        var totalCostVehicle: TotalCostVehicleStore.State = TotalCostVehicleStore.State()
        var vehicleMonthlyExpenses: VehicleMonthlyExpensesStore.State = VehicleMonthlyExpensesStore.State()

        var showEmptyState: Bool = false
    }

    enum Action: Equatable {
        case warningVehicle(WarningVehicleStore.Action)
        case totalCostVehicle(TotalCostVehicleStore.Action)
        case vehicleMonthlyExpenses(VehicleMonthlyExpensesStore.Action)

        case view(ActionView)

        case onAppear
        case vehicleDetail(PresentationAction<VehicleDetailsStore.Action>)
        case vehiclesList(PresentationAction<VehiclesListStore.Action>)
        case addFirstVehicle(PresentationAction<AddFirstVehicleStore.Action>)
        case addDocument(PresentationAction<AddDocumentStore.Action>)
        case presentAddFirstVehicleView
        case showVehicleDetail(Vehicle)
        case presentVehiclesListView
        case showSettings
        case showAddDocument
        case showDocumentDetail(Document)
        case deleteCurrentVehicle
        case deleteAlert(PresentationAction<Alert>)
        case updateAllVehicles([Vehicle])
        case setupVehicleStatistics

        enum ActionView: Equatable {
            case openCreateVehicleButtonTapped
            case deleteVehicleButtonTapped
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
                    return .send(.presentAddFirstVehicleView)
                case .deleteVehicleButtonTapped:
                    return .send(.deleteCurrentVehicle)
                }
                
            case .onAppear:
                if state.vehicles.isEmpty {
                    state.showEmptyState = true
                    return .none
                } else if state.selectedVehicle.isNull {
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

            case .presentAddFirstVehicleView:
                guard state.isStorageConfigured else {
                    return .none
                }
                state.addFirstVehicle = AddFirstVehicleStore.State()
                return .none
                
            case .addFirstVehicle(.presented(.firstVehicleAdded)):
                guard let firstVehicle = state.vehicles.first else {
                    return .none
                }
                state.$selectedVehicle.withLock { $0 = firstVehicle }
                return .send(.setupVehicleStatistics)

//            case .showSettings:
//                // Navigation handled by AppStore+Path (to be implemented)
//                return .none
//
            case .showAddDocument:
                state.addDocument = AddDocumentStore.State.initialState(vehicleId: state.selectedVehicle.id)
                return .none

            case .showDocumentDetail:
                // Navigation handled by AppStore+Path
                return .none

            case .deleteCurrentVehicle:
                state.deleteAlert = AlertState.deleteCurrentVehicleAlert()
                return .none

            case .deleteAlert(.presented(.confirmDelete)):
                return .run { [vehicleId = state.selectedVehicle.id] send in
                    do {
                        try await vehicleRepository.deleteVehicle(vehicleId)
                        let newVehiclesList = try await vehicleRepository.getAllVehicles()
                        await send(.updateAllVehicles(newVehiclesList))
                    } catch {}
                }

            case .updateAllVehicles(let newVehiclesList):
                    state.$vehicles.withLock { $0 = newVehiclesList }
                    state.$selectedVehicle.withLock { $0 = .null() }
                return .none

            case .addDocument(.dismiss):
                // Recalculer le coût total après la fermeture du modal d'ajout de document
                return .send(.setupVehicleStatistics)

            case .addDocument:
                return .none
                
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
        .ifLet(\.$addFirstVehicle, action: \.addFirstVehicle) {
            AddFirstVehicleStore()
        }
        .ifLet(\.$addDocument, action: \.addDocument) {
            AddDocumentStore()
        }
    }
}
