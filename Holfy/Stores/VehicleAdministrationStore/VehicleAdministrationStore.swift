//
//  VehicleAdministrationStore.swift
//  Holfy
//
//  Created by Claude Code on 20/01/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct VehicleAdministrationStore {
    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        var technicalInspection: TechnicalInspectionStore.State = .init()

        var filteredDocuments: [Document] {
            selectedVehicle.documents
                .filter { $0.type == .technicalInspection }
                .sorted { $0.date > $1.date }
        }
        var documentCount: Int { filteredDocuments.count }
    }

    enum Action: Equatable {
        case documentTapped(Document)
        case addDocumentTapped
        case technicalInspection(TechnicalInspectionStore.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.technicalInspection, action: \.technicalInspection) { TechnicalInspectionStore() }
        Reduce { _, action in
            switch action {
            case .documentTapped, .addDocumentTapped:
                return .none // Delegated to parent
            }
        }
    }
}
