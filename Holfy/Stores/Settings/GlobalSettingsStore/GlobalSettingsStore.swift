//
//  GlobalSettingsStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 03/01/2026.
//

import ComposableArchitecture
import SwiftUI

struct Setting: Equatable, Identifiable {
    var id: String = UUID().uuidString
    var label: LocalizedStringKey
    var setting: SettingType
    
    enum SettingType: Equatable {
        case unitsAndMesures
        case storage
    }
}

@Reducer
struct GlobalSettingsStore {
    
    @ObservableState
    struct State: Equatable {
        var settings: [Setting] = [
            Setting(label: "settings_units_and_measure_title", setting: .unitsAndMesures),
            Setting(label: "settings_storage_title", setting: .storage)
        ]
    }
    
    enum Action: Equatable {
        case view(ActionView)
        case navigateToUnitAndMeasureSettings
        case navigateToStorageSettings
        
        enum ActionView: Equatable {
            case settingButtonTapped(Setting.SettingType)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.settingButtonTapped(let settingTapped)):
                switch settingTapped {
                case .storage: return .send(.navigateToStorageSettings)
                case .unitsAndMesures: return .send(.navigateToUnitAndMeasureSettings)
                }
                
            default: return .none
            }
        }
    }
}
