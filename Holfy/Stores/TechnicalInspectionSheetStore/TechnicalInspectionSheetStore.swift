//
//  TechnicalInspectionSheetStore.swift
//  Holfy
//
//  Created by Nicolas Barbosa on 31/01/2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct TechnicalInspectionSheetStore {

    enum TechnicalInspectionState: Equatable {
        case moreThanAMonth
        case lessThanAMonth
        case outOfDate
    }

    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle

        var isTechnicalInspectionShow: Bool = false
        var technicalInspectionState: TechnicalInspectionState?
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case checkExpirationStatus
        case dismissAlert
    }

    @Dependency(\.date) var date

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .checkExpirationStatus:
                let latestTechnicalInspection = state.selectedVehicle.documents
                    .filter { $0.type == .technicalInspection }
                    .sorted { $0.date > $1.date }
                    .first

                guard let expirationDate = latestTechnicalInspection?.expirationDate else {
                    state.isTechnicalInspectionShow = false
                    state.technicalInspectionState = nil
                    return .none
                }

                let days = Calendar.current.dateComponents(
                    [.day],
                    from: date.now,
                    to: expirationDate
                ).day ?? 0

                if days < 0 {
                    state.isTechnicalInspectionShow = true
                    state.technicalInspectionState = .outOfDate
                } else if days < 31 {
                    state.isTechnicalInspectionShow = true
                    state.technicalInspectionState = .lessThanAMonth
                } else {
                    state.isTechnicalInspectionShow = false
                    state.technicalInspectionState = .moreThanAMonth
                }

                return .none

            case .dismissAlert:
                state.isTechnicalInspectionShow = false
                return .none

            case .binding:
                return .none
            }
        }
    }
}
