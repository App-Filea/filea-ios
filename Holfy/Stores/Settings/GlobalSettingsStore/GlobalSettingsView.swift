//
//  GlobalSettingsView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 03/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct GlobalSettingsView: View {
    @Bindable var store: StoreOf<GlobalSettingsStore>
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                ForEach(store.settings) { setting in
                    globalSettingsRow(for: setting)
                }
            }
        }
        .navigationTitle("settings_global_title")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func globalSettingsRow(for setting: Setting) -> some View {
        VStack(spacing: 0) {
            Button(
                action: { store.send(.view(.settingButtonTapped(setting.setting) ))},
                label: {
                HStack(spacing: 16) {
                    Text(setting.label)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .title3()
                .padding(.leading, 16)
                .padding(.trailing, 12)
                .padding(.vertical, 20)
            })
        }
    }
}

#Preview {
    NavigationView {
        GlobalSettingsView(store: .init(initialState: GlobalSettingsStore.State(), reducer: { GlobalSettingsStore() }))
    }
}
