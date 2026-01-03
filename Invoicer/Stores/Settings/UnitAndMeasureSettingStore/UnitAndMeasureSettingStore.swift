//
//  UnitAndMeasureSettingStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 03/01/2026.
//

import ComposableArchitecture

@Reducer
struct UnitAndMeasureSettingStore {
    
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
                .none
        }
    }
}
