//
//  OnboardingView.swift
//  Invoicer
//
//  Created by Claude on 2025-01-18.
//  Welcome onboarding view
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<OnboardingStore>

    // MARK: - Body

    var body: some View {
        WelcomeView {
            store.send(.continueTapped)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(
        store: Store(initialState: OnboardingStore.State()) {
            OnboardingStore()
        }
    )
}
