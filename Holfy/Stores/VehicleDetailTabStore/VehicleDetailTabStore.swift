//
//  VehicleDetailTabStore.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct VehicleDetailTabStore {
    enum Tab: String, CaseIterable, Sendable {
        case overview = "Vue d'Ensemble"
        case statistics = "Statistiques"
        case maintenance = "Entretiens & Réparations"
        case administration = "Administration"
        case fuel = "Carburant"

        var icon: String {
            switch self {
            case .overview: return "rectangle.stack"
            case .statistics: return "chart.bar"
            case .maintenance: return "wrench.and.screwdriver"
            case .administration: return "building.columns"
            case .fuel: return "fuelpump"
            }
        }
    }

    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .overview
    }

    enum Action: Equatable {
        case tabSelected(Tab)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            }
        }
    }
}
