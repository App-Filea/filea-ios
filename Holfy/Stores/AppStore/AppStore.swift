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
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        @Shared(.lastOpenedVehicleId) var lastOpenedVehicleId: String?
        @Shared(.hasCompletedOnboarding) var hasCompletedOnboarding = false
        @Shared(.isStorageConfigured) var isStorageConfigured = false
        @Presents var onboarding: OnboardingStore.State?
        @Presents var storageOnboarding: StorageOnboardingStore.State?
        var path = StackState<Path.State>()
    }

    enum Action: Equatable {
        case initiate
        case checkStorage
        case storageStateChecked(VehicleStorageManager.StorageState)
        case initiateCompleted
        case path(StackActionOf<Path>)
        case onboarding(PresentationAction<OnboardingStore.Action>)
        case storageOnboarding(PresentationAction<StorageOnboardingStore.Action>)
        case getAllVehicles
        case vehiclesLoaded([Vehicle])
        case vehicleListChanged
        case navigateToVehiclesList
        case navigateToCreatedVehicle(Vehicle, [Vehicle])
        case initiateMainStore
    }

    @Dependency(\.vehicleGRDBClient) var vehicleRepository
    @Dependency(\.storageManager) var storageManager

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .initiate:
                state.path.append(.main(MainStore.State()))

                if !state.hasCompletedOnboarding {
                    state.onboarding = OnboardingStore.State()
                    return .none
                }

                return .send(.checkStorage)

            case .checkStorage:
                return .run { send in
                    let storageState = await storageManager.restorePersistentFolder()
                    await send(.storageStateChecked(storageState))
                }

            case .storageStateChecked(let storageState):
                switch storageState {
                case .notConfigured, .invalidAccess:
                    state.storageOnboarding = StorageOnboardingStore.State()
                    return .none

                case .configured:
                    state.$isStorageConfigured.withLock { $0 = true }
                    return .send(.getAllVehicles)
                }

            case .getAllVehicles:
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
                case 0: return .send(.initiateMainStore)
                case 1:
                    let vehicle = state.vehicles[0]
                    state.$selectedVehicle.withLock { $0 = vehicle }
                    state.$lastOpenedVehicleId.withLock { $0 = vehicle.id }
                    return .send(.initiateMainStore)
                default:
                    guard let selectedVehicle =
                            state.vehicles.first(where: { $0.id == state.lastOpenedVehicleId }) ??
                            state.vehicles.first(where: { $0.isPrimary }) ??
                            state.vehicles.first else {
                        state.path.append(.main(MainStore.State()))
                        return .none
                    }
                    state.$selectedVehicle.withLock { $0 = selectedVehicle }
                    state.$lastOpenedVehicleId.withLock { $0 = selectedVehicle.id }
                    return .send(.initiateMainStore)
                }

            case .vehicleListChanged:
                return .run { send in
                    do {
                        let loadedVehicles = try await vehicleRepository.getAllVehicles()
                        await send(.vehiclesLoaded(loadedVehicles))
                    } catch {
                        print("❌ [AppStore] Erreur lors du rechargement: \(error.localizedDescription)")
                        await send(.vehiclesLoaded([]))
                    }
                }

            case .navigateToVehiclesList:
                return .none

            case .navigateToCreatedVehicle(let vehicle, let vehicles):
                state.$vehicles.withLock { $0 = vehicles }

                state.$selectedVehicle.withLock { $0 = vehicle }
                state.$lastOpenedVehicleId.withLock { $0 = vehicle.id }

                state.path.removeAll()
                state.path.append(.main(MainStore.State()))
                return .none
                
            case .onboarding(.dismiss):
                state.$hasCompletedOnboarding.withLock { $0 = true }
                state.onboarding = nil
                state.storageOnboarding = StorageOnboardingStore.State()
                return .none

            case .onboarding(.presented(.completeOnboarding)):
                state.$hasCompletedOnboarding.withLock { $0 = true }
                state.onboarding = nil
                state.storageOnboarding = StorageOnboardingStore.State()
                return .none

            case .storageOnboarding(.dismiss):
                state.storageOnboarding = StorageOnboardingStore.State()
                return .none

            case .storageOnboarding(.presented(.folderSaved)):
                state.storageOnboarding = nil
                state.$isStorageConfigured.withLock { $0 = true }
                return .send(.getAllVehicles)

            case .onboarding:
                return .none

            case .storageOnboarding:
                return .none
                
            case .path(let action):
                switchAccordingActions(action, state: &state)
                return .none
                
            case .initiateMainStore:
                guard let mainId = state.path.ids.first(where: { id in
                    if case .main = state.path[id: id] {
                        return true
                    }
                    return false
                }) else {
                    return .none
                }

                return .send(.path(.element(id: mainId, action: .main(.onAppear))))
                
            default: return .none
            }
        }
        .ifLet(\.$onboarding, action: \.onboarding) {
            OnboardingStore()
        }
        .ifLet(\.$storageOnboarding, action: \.storageOnboarding) {
            StorageOnboardingStore()
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
            case main(MainStore.State)
            case vehicleDetails(VehicleDetailsStore.State)
            case editVehicle(EditVehicleStore.State)
            case documentDetail(DocumentDetailStore.State)
            case editDocument(EditDocumentStore.State)
            case globalSettings(GlobalSettingsStore.State)
            case storageSettings(StorageSettingsStore.State)
            case unitAndMeasureSettings(UnitAndMeasureSettingStore.State)
        }

        enum Action: Equatable {
            case storageOnboarding(StorageOnboardingStore.Action)
            case main(MainStore.Action)
            case vehicleDetails(VehicleDetailsStore.Action)
            case editVehicle(EditVehicleStore.Action)
            case documentDetail(DocumentDetailStore.Action)
            case editDocument(EditDocumentStore.Action)
            case globalSettings(GlobalSettingsStore.Action)
            case storageSettings(StorageSettingsStore.Action)
            case unitAndMeasureSettings(UnitAndMeasureSettingStore.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: \.storageOnboarding, action: \.storageOnboarding) { StorageOnboardingStore() }
            Scope(state: \.main, action: \.main) { MainStore() }
            Scope(state: \.vehicleDetails, action: \.vehicleDetails) { VehicleDetailsStore() }
            Scope(state: \.editVehicle, action: \.editVehicle) { EditVehicleStore() }
            Scope(state: \.documentDetail, action: \.documentDetail) { DocumentDetailStore() }
            Scope(state: \.editDocument, action: \.editDocument) { EditDocumentStore() }
            Scope(state: \.globalSettings, action: \.globalSettings) { GlobalSettingsStore() }
            Scope(state: \.storageSettings, action: \.storageSettings) { StorageSettingsStore() }
            Scope(state: \.unitAndMeasureSettings, action: \.unitAndMeasureSettings) { UnitAndMeasureSettingStore() }
        }
    }
}
