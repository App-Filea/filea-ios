//
//  AppStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct AppStore {
    @ObservableState
    struct State: Equatable {
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle?
        @Shared(.lastOpenedVehicleId) var lastOpenedVehicleId: UUID?
        var path = StackState<Path.State>()
        var isStorageConfigured = false
    }

    enum Action: Equatable {
        case initiate
        case checkStorage
        case storageStateChecked(VehicleStorageManager.StorageState)
        case initiateCompleted
        case path(StackActionOf<Path>)
        case getAllVehicles
        case vehiclesLoaded([Vehicle])
        case vehicleListChanged
        case navigateToVehiclesList
        case navigateToCreatedVehicle(Vehicle, [Vehicle])
    }

    @Dependency(\.vehicleRepository) var vehicleRepository
    @Dependency(\.storageManager) var storageManager

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .initiate:
                // First, check if storage is configured
                return .send(.checkStorage)

            case .checkStorage:
                return .run { send in
                    let storageState = await storageManager.restorePersistentFolder()
                    await send(.storageStateChecked(storageState))
                }

            case .storageStateChecked(let storageState):
                switch storageState {
                case .notConfigured, .invalidAccess:
                    // Storage not configured or invalid, show onboarding
                    state.isStorageConfigured = false
                    state.path.removeAll()
                    state.path.append(.storageOnboarding(StorageOnboardingStore.State()))
                    return .none

                case .configured:
                    // Storage is configured, proceed with normal initialization
                    state.isStorageConfigured = true
                    return .send(.getAllVehicles)
                }

            case .getAllVehicles:
                // Now load vehicles from storage
                return .run { send in
                    do {
                        let vehicles = try await vehicleRepository.getAllVehicles()
                        await send(.vehiclesLoaded(vehicles))
                    } catch {
                        print("❌ [AppStore] Erreur lors du chargement: \(error.localizedDescription)")
                        await send(.vehiclesLoaded([]))
                    }
                }

            case .vehiclesLoaded(let vehicles):
                state.$vehicles.withLock { $0 = vehicles }
                return .send(.initiateCompleted)

            case .initiateCompleted:
                switch state.vehicles.count {
                case 0:
                    // Aucun véhicule → Navigation vers création de véhicule
                    state.path.append(.vehiclesList(VehiclesListStore.State()))
                    return .none

                case 1:
                    // Un seul véhicule → Le sélectionner et naviguer
                    let vehicle = state.vehicles[0]
                    state.$selectedVehicle.withLock { $0 = vehicle }
                    state.$lastOpenedVehicleId.withLock { $0 = vehicle.id }
                    state.path.append(.main(MainStore.State()))
                    return .none

                default:
                    // Plusieurs véhicules → Logique de sélection intelligente
                    guard let selectedVehicle =
                            state.vehicles.first(where: { $0.id == state.lastOpenedVehicleId }) ??
                            state.vehicles.first(where: { $0.isPrimary }) ??
                            state.vehicles.first else {
                        return .none
                    }

                    state.$selectedVehicle.withLock { $0 = selectedVehicle }
                    state.$lastOpenedVehicleId.withLock { $0 = selectedVehicle.id }
                    state.path.append(.main(MainStore.State()))
                    return .none
                }

            case .vehicleListChanged:
                // Recharger les véhicules depuis le storage
                return .run { send in
                    do {
                        let loadedVehicles = try await vehicleRepository.getAllVehicles()
                        await send(.vehiclesLoaded(loadedVehicles))
                        await send(.navigateToVehiclesList)
                    } catch {
                        print("❌ [AppStore] Erreur lors du rechargement: \(error.localizedDescription)")
                        await send(.vehiclesLoaded([]))
                        await send(.navigateToVehiclesList)
                    }
                }

            case .navigateToVehiclesList:
                // Rediriger vers VehiclesListView (après création ou suppression)
                state.path.removeAll()
                state.$selectedVehicle.withLock { $0 = nil }
                state.path.append(.vehiclesList(VehiclesListStore.State()))
                return .none

            case .navigateToCreatedVehicle(let vehicle, let vehicles):
                // Mettre à jour la liste des véhicules
                state.$vehicles.withLock { $0 = vehicles }

                // Sélectionner le véhicule créé
                state.$selectedVehicle.withLock { $0 = vehicle }
                state.$lastOpenedVehicleId.withLock { $0 = vehicle.id }

                // Retirer AddVehicleView et naviguer vers MainView
                state.path.removeAll()
                state.path.append(.main(MainStore.State()))
                return .none
                
            case .path(let action):
                switch action {
                // Handle storage configuration completion
                case .element(id: _, action: .storageOnboarding(.folderSaved)):
        //            return .send(.storageConfigured)
                    return .none

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
                    
                case let .element(id: id, action: .main(.vehiclesList(.presented(.addVehicle(.presented(.vehicleSaved(newSavedVehicle))))))):
                    return .run { send in
                        do {
                            let vehicles = try await vehicleRepository.getAllVehicles()
                            await send(.path(.element(id: id, action: .main(.vehiclesList(.presented(.dismiss))))))
                            await send(.navigateToCreatedVehicle(newSavedVehicle, vehicles))
                        } catch {
                            print("❌ [AppStore] Erreur lors du rechargement: \(error.localizedDescription)")
                        }
                    }
                    
                case let .element(id: id, action: .vehiclesList(.addVehicle(.presented(.vehicleSaved(newSavedVehicle))))):
                    return .run { send in
                        do {
                            let vehicles = try await vehicleRepository.getAllVehicles()
                            await send(.path(.element(id: id, action: .vehiclesList(.dismissAddVehicle))))
                            await send(.navigateToCreatedVehicle(newSavedVehicle, vehicles))
                        } catch {
                            print("❌ [AppStore] Erreur lors du rechargement: \(error.localizedDescription)")
                        }
                    }

                // Handle vehicle deletion - reload and navigate to appropriate view
                case .element(id: _, action: .main(.vehicleDeleted)):
                    return .send(.vehicleListChanged)

                case .element(id: _, action: .vehicleDetails(.vehicleDeleted)):
                    return .send(.vehicleListChanged)

                default: return .none
                }
                
            }
            return .none
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
    
    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable {
            case storageOnboarding(StorageOnboardingStore.State)
            case vehiclesList(VehiclesListStore.State)
            case main(MainStore.State)
            case vehicleDetails(VehicleDetailsStore.State)
            case addVehicle(AddVehicleStore.State)
            case editVehicle(EditVehicleStore.State)
            case documentDetail(DocumentDetailCoordinatorStore.State)
            case editDocument(EditDocumentStore.State)
            case settings(SettingsStore.State)
        }

        enum Action: Equatable {
            case storageOnboarding(StorageOnboardingStore.Action)
            case vehiclesList(VehiclesListStore.Action)
            case main(MainStore.Action)
            case vehicleDetails(VehicleDetailsStore.Action)
            case addVehicle(AddVehicleStore.Action)
            case editVehicle(EditVehicleStore.Action)
            case documentDetail(DocumentDetailCoordinatorStore.Action)
            case editDocument(EditDocumentStore.Action)
            case settings(SettingsStore.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: \.storageOnboarding, action: \.storageOnboarding) { StorageOnboardingStore() }
            Scope(state: \.vehiclesList, action: \.vehiclesList) { VehiclesListStore() }
            Scope(state: \.main, action: \.main) { MainStore() }
            Scope(state: \.vehicleDetails, action: \.vehicleDetails) { VehicleDetailsStore() }
            Scope(state: \.addVehicle, action: \.addVehicle) { AddVehicleStore() }
            Scope(state: \.editVehicle, action: \.editVehicle) { EditVehicleStore() }
            Scope(state: \.documentDetail, action: \.documentDetail) { DocumentDetailCoordinatorStore() }
            Scope(state: \.editDocument, action: \.editDocument) { EditDocumentStore() }
            Scope(state: \.settings, action: \.settings) { SettingsStore() }
        }
    }
}
