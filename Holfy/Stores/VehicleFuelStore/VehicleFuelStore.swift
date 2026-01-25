//
//  VehicleFuelStore.swift
//  Holfy
//
//  Created by Claude Code on 20/01/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct VehicleFuelStore {
    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle

        // Placeholder - no fuel document type currently
        var filteredDocuments: [Document] { [] }
        var documentCount: Int { 0 }
    }

    enum Action: Equatable {
        case documentTapped(Document)
        case addDocumentTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .documentTapped, .addDocumentTapped:
                return .none // Delegated to parent
            }
        }
    }
}
