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
        var path = StackState<Path.State>()
        var isStorageInitialized = false
    }
    
    enum Action: Equatable {
        case initiate
        case path(StackActionOf<Path>)
        case initializeStorage
        case storageInitialized
    }
    
    @Dependency(\.fileStorageService) var fileStorageService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .initiate:
                state.path.append(.main(MainStore.State()))
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
            case main(MainStore.State)
            case vehicle(VehicleStore.State)
            case addVehicle(AddVehicleStore.State)
            case editVehicle(EditVehicleStore.State)
            case addDocument(AddDocumentStore.State)
            case documentDetail(DocumentDetailCoordinatorStore.State)
            case editDocument(EditDocumentStore.State)
        }
        
        enum Action: Equatable {
            case main(MainStore.Action)
            case vehicle(VehicleStore.Action)
            case addVehicle(AddVehicleStore.Action)
            case editVehicle(EditVehicleStore.Action)
            case addDocument(AddDocumentStore.Action)
            case documentDetail(DocumentDetailCoordinatorStore.Action)
            case editDocument(EditDocumentStore.Action)
        }
        var body: some ReducerOf<Self> {
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
