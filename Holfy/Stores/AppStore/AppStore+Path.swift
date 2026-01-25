//
//  AppStore+Path.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 01/01/2026.
//

import ComposableArchitecture

extension AppStore {
    func switchAccordingActions(_ stackAction: StackAction<Path.State, Path.Action>, state: inout AppStore.State) -> Effect<AppStore.Action> {
        switch stackAction {
        case .element(id: _, action: .storageOnboarding(.folderSaved)):
            return .send(.getAllVehicles)
            
        case .element(id: _, action: .main(.showVehicleDetail(let vehicle))):
            state.path.append(.vehicleDetails(VehicleDetailsStore.State()))
            return .none
            
        case .element(id: _, action: .main(.maintenanceStore(.documentTapped(let document)))),
                .element(id: _, action: .main(.administrationStore(.documentTapped(let document)))),
                .element(id: _, action: .main(.fuelStore(.documentTapped(let document)))):
            state.path.append(.documentDetail(DocumentDetailStore.State(documentId: document.id)))
            return .none
            
        case .element(id: _, action: .main(.showSettings)):
            state.path.append(.globalSettings(GlobalSettingsStore.State()))
            return .none
            
        case .element(id: _, action: .main(.view(.warningVehicleTapped))):
            state.path.append(.warningList(WarningListStore.State()))
            return .none
            
        case .element(id: _, action: .warningList(.view(.incompleteDocumentTapped(let document)))):
            state.path.append(.documentDetail(DocumentDetailStore.State(documentId: document.id)))
            return .none
            
        case .element(id: _, action: .globalSettings(.navigateToStorageSettings)):
            state.path.append(.storageSettings(StorageSettingsStore.State()))
            return .none
            
        case .element(id: _, action: .globalSettings(.navigateToUnitAndMeasureSettings)):
            state.path.append(.unitAndMeasureSettings(UnitAndMeasureSettingStore.State()))
            return .none
            
        case .element(id: _, action: .vehicleDetails(.editVehicle)):
            state.path.append(.editVehicle(.init()))
            return .none
            
        case .element(id: _, action: .documentDetail(.showEditDocument(let vehicleId, let document))):
            state.path.append(.editDocument(.init(vehicleId: vehicleId, document: document)))
            return .none
            
        default: return .none
        }
    }
}
