//
//  VehicleMaintenanceStore.swift
//  Holfy
//
//  Created by Claude Code on 20/01/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct VehicleMaintenanceStore {
    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle

        var filteredDocuments: [Document] {
            selectedVehicle.documents
                .filter { $0.type == .maintenance || $0.type == .repair || $0.type == .technicalInspection }
                .sorted { $0.date > $1.date }
        }

        var documentCount: Int { filteredDocuments.count }
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
