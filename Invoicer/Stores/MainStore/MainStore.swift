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
        @Presents var vehiclesList: VehiclesListModalStore.State?
        @Presents var addDocument: AddDocumentStore.State?
        var currentVehicleTotalCost: Double = 0
        var currentVehicleMonthlyExpenses: [MonthlyExpense] = []

        var currentVehicle: Vehicle? {
            selectedVehicle
        }

        var currentVehicleDocuments: [Document] {
            currentVehicle?.documents ?? []
        }
    }

    enum Action: Equatable {
        case vehicleDetail(PresentationAction<VehicleDetailsStore.Action>)
        case vehiclesList(PresentationAction<VehiclesListModalStore.Action>)
        case addDocument(PresentationAction<AddDocumentStore.Action>)
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
        case calculateTotalCost
        case totalCostCalculated(Double)
        case monthlyExpensesCalculated([MonthlyExpense])

        enum Alert: Equatable {
            case confirmDelete
        }
    }
    
    @Dependency(\.fileStorageService) var fileStorageService
    @Dependency(\.vehicleCostCalculator) var costCalculator

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
                // Recalculer le coût total après le chargement des véhicules
                return .send(.calculateTotalCost)
                
            case .showVehicleDetail(let vehicle):
                state.vehicleDetail = VehicleDetailsStore.State()
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
                guard let currentVehicle = state.currentVehicle else {
                    return .none
                }
                state.addDocument = AddDocumentStore.State(vehicleId: currentVehicle.id)
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
                    // La resélection sera gérée dans AppStore
                    state.$selectedVehicle.withLock { $0 = nil }
                }
                return .none

            case .vehicleDetail(.presented(.goBack)):
                state.vehicleDetail = nil
                return .none

            case .vehicleDetail:
                return .none

            case .vehiclesList(.presented(.selectVehicle)):
                // Selection and dismiss handled by VehiclesListModalStore
                state.vehiclesList = nil
                return .none

            case .vehiclesList:
                return .none

            case .addDocument(.dismiss):
                // Recalculer le coût total après la fermeture du modal d'ajout de document
                return .send(.calculateTotalCost)

            case .addDocument:
                return .none

            case .calculateTotalCost:
                let documents = state.currentVehicleDocuments
                return .run { send in
                    let total = costCalculator.calculateTotalCost(documents)
                    await send(.totalCostCalculated(total))

                    // Calculate monthly expenses for current year
                    let calendar = Calendar.current
                    let currentYear = calendar.component(.year, from: Date())
                    let monthlyExpenses = costCalculator.calculateMonthlyExpenses(documents, for: currentYear)
                    await send(.monthlyExpensesCalculated(monthlyExpenses))
                }

            case .totalCostCalculated(let total):
                state.currentVehicleTotalCost = total
                return .none

            case .monthlyExpensesCalculated(let expenses):
                state.currentVehicleMonthlyExpenses = expenses
                return .none
            }
        }
        .ifLet(\.$vehicleDetail, action: \.vehicleDetail) {
            VehicleDetailsStore()
        }
        .ifLet(\.$deleteAlert, action: \.deleteAlert)
        .ifLet(\.$vehiclesList, action: \.vehiclesList) {
            VehiclesListModalStore()
        }
        .ifLet(\.$addDocument, action: \.addDocument) {
            AddDocumentStore()
        }
    }
}
