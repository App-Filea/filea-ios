//
//  MainStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct MainStore {
    enum Tab: LocalizedStringKey, CaseIterable, Sendable {
        case overview = "tab_overview_label"
        case statistics = "tab_statistics_label"
        case maintenance = "tab_maintain_and_repair_label"
//        case fuel = "Carburant"

        var icon: String {
            switch self {
            case .overview: return "rectangle.stack"
            case .statistics: return "chart.bar"
            case .maintenance: return "wrench.and.screwdriver"
//            case .fuel: return "fuelpump"
            }
        }
    }

    @ObservableState
    struct State: Equatable {
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        @Shared(.isStorageConfigured) var isStorageConfigured = false
        @Presents var vehicleDetail: VehicleDetailsStore.State?
        @Presents var deleteAlert: AlertState<Action.Alert>?
        @Presents var vehiclesList: VehiclesListStore.State?
        @Presents var addFirstVehicle: AddFirstVehicleStore.State?

        var selectedTab: Tab = .overview

        var preSelectedDocumentType: DocumentType? {
            switch selectedTab {
            case .overview, .statistics:
                return nil
            case .maintenance:
                return .maintenance
            }
        }

        // Child stores for tabs
        var statisticsStore: VehicleStatisticsStore.State = .init()
        var maintenanceStore: VehicleDocumentStore.State = .init()
        var fuelStore: VehicleFuelStore.State = .init()

        // overview stores
        var warningVehicle: WarningVehicleStore.State = WarningVehicleStore.State()
        var totalCostVehicle: TotalCostVehicleStore.State = TotalCostVehicleStore.State()
        var lastDocument: LastDocumentStore.State = LastDocumentStore.State()
        var technicalInspectionSheet: TechnicalInspectionSheetStore.State = TechnicalInspectionSheetStore.State()
        var vehicleMonthlyExpenses: VehicleMonthlyExpensesStore.State = VehicleMonthlyExpensesStore.State()
        var recentActivities: RecentActivitiesStore.State = RecentActivitiesStore.State()

        var showEmptyState: Bool = false
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case view(ActionView)
        case tabSelected(Tab)

        // Child stores actions
        case statisticsStore(VehicleStatisticsStore.Action)
        case maintenanceStore(VehicleDocumentStore.Action)
        case fuelStore(VehicleFuelStore.Action)

        // Overview stores actions
        case warningVehicle(WarningVehicleStore.Action)
        case totalCostVehicle(TotalCostVehicleStore.Action)
        case lastDocument(LastDocumentStore.Action)
        case technicalInspectionSheet(TechnicalInspectionSheetStore.Action)
        case vehicleMonthlyExpenses(VehicleMonthlyExpensesStore.Action)
        case recentActivities(RecentActivitiesStore.Action)

        case onAppear
        case vehicleDetail(PresentationAction<VehicleDetailsStore.Action>)
        case vehiclesList(PresentationAction<VehiclesListStore.Action>)
        case addFirstVehicle(PresentationAction<AddFirstVehicleStore.Action>)
        case presentAddFirstVehicleView
        case showVehicleDetail
        case presentVehiclesListView
        case showSettings
        case deleteCurrentVehicle
        case deleteAlert(PresentationAction<Alert>)
        case updateAllVehicles([Vehicle])

        enum ActionView: Equatable {
            case openCreateVehicleButtonTapped
            case deleteVehicleButtonTapped
            case settingsButtonTapped
            case warningVehicleTapped
        }
        
        enum Alert: Equatable {
            case confirmDelete
        }
    }
    
    @Dependency(\.vehicleGRDBClient) var vehicleRepository

    var body: some ReducerOf<Self> {
        BindingReducer()

        // Child stores for tabs
        Scope(state: \.statisticsStore, action: \.statisticsStore) { VehicleStatisticsStore() }
        Scope(state: \.maintenanceStore, action: \.maintenanceStore) { VehicleDocumentStore() }
        Scope(state: \.fuelStore, action: \.fuelStore) { VehicleFuelStore() }

        // Overview stores
        Scope(state: \.warningVehicle, action: \.warningVehicle) { WarningVehicleStore() }
        Scope(state: \.totalCostVehicle, action: \.totalCostVehicle) { TotalCostVehicleStore() }
        Scope(state: \.lastDocument, action: \.lastDocument) { LastDocumentStore() }
        Scope(state: \.technicalInspectionSheet, action: \.technicalInspectionSheet) { TechnicalInspectionSheetStore() }
        Scope(state: \.vehicleMonthlyExpenses, action: \.vehicleMonthlyExpenses) { VehicleMonthlyExpensesStore() }
        Scope(state: \.recentActivities, action: \.recentActivities) { RecentActivitiesStore() }

        Reduce { state, action in
            switch action {
            case .statisticsStore:
                return .none  // Pure compositeur

            case .recentActivities:
                return .none

            case .view(let actionView):
                switch actionView {
                case .openCreateVehicleButtonTapped: return .send(.presentAddFirstVehicleView)
                case .deleteVehicleButtonTapped: return .send(.deleteCurrentVehicle)
                case .settingsButtonTapped: return .send(.showSettings)
                default: return .none
                }
                
            case .onAppear:
                if state.vehicles.isEmpty {
                    state.showEmptyState = true
                    return .none
                } else if state.selectedVehicle.isNull {
                    return .send(.presentVehiclesListView)
                }
                return .send(.technicalInspectionSheet(.checkExpirationStatus))
                
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
                return .none

//            case .showSettings:
//                // Navigation handled by AppStore+Path (to be implemented)
//                return .none
//

            case .deleteCurrentVehicle:
                state.deleteAlert = AlertState.deleteCurrentVehicleAlert()
                return .none

            case .deleteAlert(.presented(.confirmDelete)):
                return .run { [vehicleId = state.selectedVehicle.id] send in
                    do {
                        try await vehicleRepository.deleteVehicle(vehicleId)
                        let newVehiclesList = try await vehicleRepository.getAllVehicles()
                        await send(.updateAllVehicles(newVehiclesList))
                        if !newVehiclesList.isEmpty {
                            await send(.presentVehiclesListView)
                        }
                    } catch {}
                }

            case .updateAllVehicles(let newVehiclesList):
                    state.$vehicles.withLock { $0 = newVehiclesList }
                return .none

            case let .tabSelected(tab):
                state.selectedTab = tab
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
    }
}
