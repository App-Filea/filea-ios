//
//  TechnicalInspectionStore.swift
//  Holfy
//
//  Created by Nicolas Barbosa on 25/01/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct TechnicalInspectionStore {

    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle

        var latestTechnicalInspection: Document? {
            selectedVehicle.documents
                .filter { $0.type == .technicalInspection }
                .sorted { $0.date > $1.date }
                .first
        }
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}
