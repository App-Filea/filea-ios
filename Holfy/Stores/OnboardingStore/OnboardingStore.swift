//
//  OnboardingStore.swift
//  Invoicer
//
//  Created by Claude on 2025-01-18.
//  TCA Store for welcome onboarding screen
//

import ComposableArchitecture
import Foundation

@Reducer
struct OnboardingStore {

    @ObservableState
    struct State: Equatable {}

    enum Action: Equatable {
        case continueTapped
        case completeOnboarding
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .continueTapped:
                return .send(.completeOnboarding)

            case .completeOnboarding:
                return .none
            }
        }
    }
}
