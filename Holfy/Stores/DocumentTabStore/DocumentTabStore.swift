//
//  DocumentTabStore.swift
//  Holfy
//
//  Created by Claude Code on 19/01/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct DocumentTabStore {
    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        let tab: VehicleDetailTabStore.Tab

        // Computed property pour documents filtrés
        var filteredDocuments: [Document] {
            VehicleDetailTabStore.State(selectedTab: tab)
                .filteredDocuments(from: selectedVehicle.documents)
        }
    }

    enum Action: Equatable {
        case documentTapped(Document)
        case addDocumentTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .documentTapped:
                // Action déléguée au parent (MainStore)
                return .none

            case .addDocumentTapped:
                // Action déléguée au parent (MainStore)
                return .none
            }
        }
    }
}
