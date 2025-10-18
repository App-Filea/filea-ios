//
//  SettingsView.swift
//  Invoicer
//
//  Created by Claude on 2025-01-18.
//  Settings view for app configuration
//

import SwiftUI
import ComposableArchitecture

struct SettingsView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<SettingsStore>

    // MARK: - Body

    var body: some View {
        List {
            // Storage Section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Emplacement actuel")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let path = store.currentStoragePath {
                        Text(path)
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Text("Non configuré")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                .padding(.vertical, 4)

                Button(role: .destructive) {
                    store.send(.changeStorageTapped)
                } label: {
                    HStack {
                        Image(systemName: "folder.badge.gear")
                        Text("Changer d'emplacement de stockage")
                    }
                }
                .disabled(store.isLoading)

            } header: {
                Label("Stockage", systemImage: "externaldrive")
            } footer: {
                Text("Tous vos véhicules et documents sont stockés dans ce dossier. Changer d'emplacement effacera les données actuelles.")
            }

            // App Info Section
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(AppConstants.appVersion)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Build")
                    Spacer()
                    Text(AppConstants.buildNumber)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Label("À propos", systemImage: "info.circle")
            }
        }
        .navigationTitle("Réglages")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            store.send(.onAppear)
        }
        .alert(
            "Changer d'emplacement de stockage",
            isPresented: $store.showChangeStorageConfirmation
        ) {
            Button("Annuler", role: .cancel) {
                store.send(.cancelChangeStorage)
            }
            Button("Continuer", role: .destructive) {
                store.send(.confirmChangeStorage)
            }
        } message: {
            Text("Attention : Changer d'emplacement de stockage effacera toutes vos données actuelles. Cette action est irréversible.")
        }
        .alert(
            "Erreur",
            isPresented: Binding(
                get: { store.errorMessage != nil },
                set: { if !$0 { store.send(.dismissError) } }
            )
        ) {
            Button("OK") {
                store.send(.dismissError)
            }
        } message: {
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
            }
        }
        .sheet(isPresented: $store.isSelectingNewFolder) {
            DocumentPickerView(
                isPresented: $store.isSelectingNewFolder,
                onFolderSelected: { url in
                    store.send(.folderSelected(url))
                },
                onCancel: {
                    store.send(.folderSelectionCancelled)
                }
            )
        }
        .overlay {
            if store.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)

                        Text("Configuration en cours...")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .padding(32)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(
                store: Store(
                    initialState: SettingsStore.State(
                        currentStoragePath: "/Users/test/iCloud Drive/Invoicer"
                    )
                ) {
                    SettingsStore()
                }
            )
        }
        .previewDisplayName("Normal")

        NavigationStack {
            SettingsView(
                store: Store(
                    initialState: SettingsStore.State(
                        currentStoragePath: nil
                    )
                ) {
                    SettingsStore()
                }
            )
        }
        .previewDisplayName("Not Configured")
    }
}
#endif
