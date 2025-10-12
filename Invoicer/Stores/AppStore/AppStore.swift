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
        var path = StackState<Path.State>()
        var isStorageInitialized = false
    }

    enum Action: Equatable {
        case initiate
        case initiateCompleted
        case path(StackActionOf<Path>)
        case initializeStorage
        case storageInitialized
        case vehiclesLoaded([Vehicle])
        case reselectVehicleIfNeeded
        case vehicleListChanged
        case navigateToVehiclesList
    }

    @Dependency(\.fileStorageService) var fileStorageService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .initiate:
                return .run { send in
                    let vehicles = await fileStorageService.loadVehicles()
                    await send(.vehiclesLoaded(vehicles))
                }

            case .vehiclesLoaded(let vehicles):
                state.$vehicles.withLock { $0 = vehicles }
                return .send(.initiateCompleted)

            case .initiateCompleted:
                // Clear the path first to reset navigation
                state.path.removeAll()

                // Logique de sélection intelligente du véhicule
                if !state.vehicles.isEmpty {
                    // 1. Chercher un véhicule principal
                    if let primaryVehicle = state.vehicles.first(where: { $0.isPrimary }) {
                        state.$selectedVehicle.withLock { $0 = primaryVehicle }
                        state.path.append(.main(MainStore.State()))
                    }
                    // 2. Si un seul véhicule (même secondaire), le sélectionner
                    else if state.vehicles.count == 1 {
                        state.$selectedVehicle.withLock { $0 = state.vehicles.first }
                        state.path.append(.main(MainStore.State()))
                    }
                    // 3. Si plusieurs véhicules mais aucun principal → afficher la liste
                    else {
                        state.path.append(.vehiclesList(VehiclesListStore.State()))
                    }
                } else {
                    // Si pas de véhicules → push VehiclesListView
                    state.path.append(.vehiclesList(VehiclesListStore.State()))
                }
                return .none

            case .path(let action): return switchAccordingActions(action, state: &state)
            case .initializeStorage:
                return .run { send in
                    await fileStorageService.initializeStorage()
                    await send(.storageInitialized)
                }

            case .storageInitialized:
                state.isStorageInitialized = true
                return .none

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
                    let loadedVehicles = await fileStorageService.loadVehicles()
                    await send(.vehiclesLoaded(loadedVehicles))
                    await send(.navigateToVehiclesList)
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
            case vehiclesList(VehiclesListStore.State)
            case main(MainStore.State)
            case vehicle(VehicleStore.State)
            case addVehicle(AddVehicleStore.State)
            case editVehicle(EditVehicleStore.State)
            case addDocument(AddDocumentStore.State)
            case documentDetail(DocumentDetailCoordinatorStore.State)
            case editDocument(EditDocumentStore.State)
        }

        enum Action: Equatable {
            case vehiclesList(VehiclesListStore.Action)
            case main(MainStore.Action)
            case vehicle(VehicleStore.Action)
            case addVehicle(AddVehicleStore.Action)
            case editVehicle(EditVehicleStore.Action)
            case addDocument(AddDocumentStore.Action)
            case documentDetail(DocumentDetailCoordinatorStore.Action)
            case editDocument(EditDocumentStore.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: \.vehiclesList, action: \.vehiclesList) { VehiclesListStore() }
            Scope(state: \.main, action: \.main) { MainStore() }
            Scope(state: \.vehicle, action: \.vehicle) { VehicleStore() }
            Scope(state: \.addVehicle, action: \.addVehicle) { AddVehicleStore() }
            Scope(state: \.editVehicle, action: \.editVehicle) { EditVehicleStore() }
            Scope(state: \.addDocument, action: \.addDocument) { AddDocumentStore() }
            Scope(state: \.documentDetail, action: \.documentDetail) { DocumentDetailCoordinatorStore() }
            Scope(state: \.editDocument, action: \.editDocument) { EditDocumentStore() }
        }
    }
}
