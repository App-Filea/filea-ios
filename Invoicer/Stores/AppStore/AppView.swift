//
//  AppView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<AppStore>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Color.clear
                .onAppear {
                    store.send(.initiate)
                }
        } destination: { store in
            switch store.state {
            case .storageOnboarding:
                if let store = store.scope(state: \.storageOnboarding, action: \.storageOnboarding) {
                    StorageOnboardingView(store: store)
                }
            case .main:
                if let store = store.scope(state: \.main, action: \.main) {
                    MainView(store: store)
                }
            case .vehicleDetails:
                if let store = store.scope(state: \.vehicleDetails, action: \.vehicleDetails) {
                    VehicleDetailsView(store: store)
                }
            case .editVehicle:
                if let store = store.scope(state: \.editVehicle, action: \.editVehicle) {
                    EditVehicleView(store: store)
                }
            case .documentDetail:
                if let store = store.scope(state: \.documentDetail, action: \.documentDetail) {
                    DocumentDetailView(store: store)
                }
            case .editDocument:
                if let store = store.scope(state: \.editDocument, action: \.editDocument) {
                    EditDocumentView(store: store)
                }
            case .settings:
                if let store = store.scope(state: \.settings, action: \.settings) {
                    SettingsView(store: store)
                }
            }
        }
        .navigationViewStyle(.stack)
        .sheet(item: $store.scope(state: \.onboarding, action: \.onboarding)) { store in
            OnboardingView(store: store)
                .interactiveDismissDisabled(true)
        }
        .sheet(item: $store.scope(state: \.storageOnboarding, action: \.storageOnboarding)) { store in
            StorageOnboardingView(store: store)
                .interactiveDismissDisabled(true)
        }
    }
}

#Preview {
    AppView(store: Store(initialState: AppStore.State()) {
        AppStore()
    })
}
