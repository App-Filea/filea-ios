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

        // Computed property for filtering documents based on selected tab
        func filteredDocuments(from allDocuments: [Document]) -> [Document] {
            switch selectedTab {
            case .overview:
                // Return all documents, sorted by date (most recent first)
                return allDocuments.sorted { $0.date > $1.date }

            case .statistics:
                // No documents for statistics tab (stats only)
                return []

            case .maintenance:
                // Filter maintenance + repair + technicalInspection types
                return allDocuments
                    .filter { $0.type == .maintenance || $0.type == .repair || $0.type == .technicalInspection }
                    .sorted { $0.date > $1.date }

            case .administration:
                // Placeholder - no specific documents yet (for future use)
                return []

            case .fuel:
                // Placeholder - no specific documents yet (for future use)
                return []
            }
        }

        // Computed property for document count per tab
        func documentCount(for tab: Tab, from allDocuments: [Document]) -> Int {
            switch tab {
            case .overview:
                return allDocuments.count
            case .statistics:
                return 0  // No badge for statistics
            case .maintenance:
                return allDocuments.filter { $0.type == .maintenance || $0.type == .repair || $0.type == .technicalInspection }.count
            case .administration:
                return 0  // Placeholder for future
            case .fuel:
                return 0  // Placeholder for future
            }
        }
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
