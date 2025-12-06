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

    // MARK: - State

    @ObservableState
    struct State: Equatable {
        // Pas de state pour l'instant
    }

    // MARK: - Action

    enum Action: Equatable {
        case continueTapped
        case completeOnboarding
    }

    // MARK: - Reducer

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .continueTapped:
                return .send(.completeOnboarding)

            case .completeOnboarding:
                // L'AppStore gérera la fermeture et l'affichage du storage
                return .none
            }
        }
    }
}
