//
//  UnitAndMeasureSettingStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 03/01/2026.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct UnitAndMeasureSettingStore {

    @ObservableState
    struct State: Equatable {
        @Shared(.selectedCurrency) var selectedCurrency: Currency = .euro
        @Shared(.selectedDistanceUnit) var selectedDistanceUnit: DistanceUnit = .kilometers
    }

    enum Action: Equatable {
        case view(ActionView)
        case currencyChanged(Currency)
        case distanceUnitChanged(DistanceUnit)

        enum ActionView: Equatable {
            case onAppear
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                print("📊 [UnitAndMeasureSettings] Préférences actuelles")
                print("   ├─ Devise : \(state.selectedCurrency.symbol)")
                print("   └─ Distance : \(state.selectedDistanceUnit.symbol)")
                return .none

            case .currencyChanged(let newCurrency):
                print("💱 [UnitAndMeasureSettings] Changement de devise")
                print("   ├─ Avant : \(state.selectedCurrency.symbol)")
                print("   └─ Après : \(newCurrency.symbol)")

                state.$selectedCurrency.withLock { $0 = newCurrency }
                return .none

            case .distanceUnitChanged(let newUnit):
                print("📏 [UnitAndMeasureSettings] Changement d'unité de distance")
                print("   ├─ Avant : \(state.selectedDistanceUnit.symbol)")
                print("   └─ Après : \(newUnit.symbol)")

                state.$selectedDistanceUnit.withLock { $0 = newUnit }
                return .none
            }
        }
    }
}
