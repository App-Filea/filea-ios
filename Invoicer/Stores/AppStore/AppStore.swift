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
        var isStorageInitialized = false
        var isStorageConfigured = false
    }

    enum Action: Equatable {
        case initiate
        case checkStorage
        case storageStateChecked(VehicleStorageManager.StorageState)
        case storageConfigured
        case initiateCompleted
        case path(StackActionOf<Path>)
        case initializeStorage
        case storageInitialized
        case vehiclesLoaded([Vehicle])
        case reselectVehicleIfNeeded
        case vehicleListChanged
        case navigateToVehiclesList
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
                    return .send(.initializeStorage)
                }

            case .storageConfigured:
                // Called when storage is successfully configured from onboarding
                state.isStorageConfigured = true
                return .send(.initializeStorage)

            case .initializeStorage:
                // Now load vehicles from storage
                return .run { send in
                    do {
                        let vehicles = try await vehicleRepository.loadAll()
                        await send(.vehiclesLoaded(vehicles))
                    } catch {
                        print("❌ [AppStore] Erreur lors du chargement: \(error.localizedDescription)")
                        await send(.vehiclesLoaded([]))
                    }
                }

            case .storageInitialized:
                state.isStorageInitialized = true
                return .none

            case .vehiclesLoaded(let vehicles):
                state.$vehicles.withLock { $0 = vehicles }
                return .send(.initiateCompleted)

            case .initiateCompleted:
                // Clear the path first to reset navigation
                state.path.removeAll()

                if state.vehicles.isEmpty {
                    // Aucun véhicule → Navigation vers création de véhicule
                    state.path.append(.vehiclesList(VehiclesListStore.State()))
//                    state.path.append(.addVehicle(AddVehicleStore.State()))
                } else if state.vehicles.count == 1 {
                    // Un seul véhicule → Le sélectionner et naviguer
                    let vehicle = state.vehicles[0]
                    state.$selectedVehicle.withLock { $0 = vehicle }
                    state.$lastOpenedVehicleId.withLock { $0 = vehicle.id }
                    state.path.append(.main(MainStore.State()))
                } else {
                    // Plusieurs véhicules → Logique de sélection intelligente
                    var selectedVehicle: Vehicle?

                    // 1. Chercher le dernier véhicule ouvert
                    if let lastId = state.lastOpenedVehicleId,
                       let lastVehicle = state.vehicles.first(where: { $0.id == lastId }) {
                        selectedVehicle = lastVehicle
                    }
                    // 2. Sinon, chercher un véhicule principal
                    else if let primaryVehicle = state.vehicles.first(where: { $0.isPrimary }) {
                        selectedVehicle = primaryVehicle
                    }
                    // 3. Sinon, prendre le premier véhicule
                    else {
                        selectedVehicle = state.vehicles.first
                    }

                    // Sélectionner le véhicule trouvé et naviguer
                    if let vehicle = selectedVehicle {
                        state.$selectedVehicle.withLock { $0 = vehicle }
                        state.$lastOpenedVehicleId.withLock { $0 = vehicle.id }
                        state.path.append(.main(MainStore.State()))
                    }
                }
                return .none

            case .path(let action): return switchAccordingActions(action, state: &state)

            case .reselectVehicleIfNeeded:
                // Si le véhicule sélectionné n'existe plus ou est nil
                if let selectedVehicle = state.selectedVehicle,
                   !state.vehicles.contains(where: { $0.id == selectedVehicle.id }) {
                    // Le véhicule sélectionné a été supprimé, resélectionner intelligemment
                    state.$selectedVehicle.withLock { $0 = nil }
                }

                // Si aucun véhicule sélectionné, appliquer la logique de sélection intelligente
                if state.selectedVehicle == nil && !state.vehicles.isEmpty {
                    if let primaryVehicle = state.vehicles.first(where: { $0.isPrimary }) {
                        state.$selectedVehicle.withLock { $0 = primaryVehicle }
                    } else if state.vehicles.count == 1 {
                        state.$selectedVehicle.withLock { $0 = state.vehicles.first }
                    }
                }
                return .none

            case .vehicleListChanged:
                // Recharger les véhicules depuis le storage
                return .run { send in
                    do {
                        let loadedVehicles = try await vehicleRepository.loadAll()
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
            }
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
