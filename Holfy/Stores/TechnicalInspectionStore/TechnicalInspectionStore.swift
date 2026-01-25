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

        var nextExpirationDate: Date? {
            latestTechnicalInspection?.expirationDate
        }

        var daysUntilExpiration: Int? {
            guard let nextDate = nextExpirationDate else { return nil }
            return Calendar.current.dateComponents([.day], from: Date(), to: nextDate).day
        }

        var isExpired: Bool {
            guard let days = daysUntilExpiration else { return false }
            return days < 0
        }

        var isExpiringSoon: Bool {
            guard let days = daysUntilExpiration else { return false }
            return days >= 0 && days <= 30
        }
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}
