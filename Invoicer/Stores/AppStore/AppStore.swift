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
                if !state.vehicles.isEmpty {
                    // Si véhicules existent → push MainView
                    state.path.append(.main(MainStore.State()))
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
