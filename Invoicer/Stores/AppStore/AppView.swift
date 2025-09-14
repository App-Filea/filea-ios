//
//  AppView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppStore>
    
    var body: some View {
        MainView(store: store.scope(state: \.mainStore, action: \.mainAction))
            .onAppear {
                store.send(.initializeStorage)
            }
    }
}

#Preview {
    AppView(store: Store(initialState: AppStore.State()) {
        AppStore()
    })
}