//
//  SettingsView.swift
//  Invoicer
//
//  Created by Claude on 2025-01-18.
//  Settings view for app configuration
//

import SwiftUI
import ComposableArchitecture

struct StorageSettingsView: View {

    @Bindable var store: StoreOf<StorageSettingsStore>

    var body: some View {
        List {
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
                Text("💡 Vos données sont stockées dans ce dossier. Si vous changez de dossier, toutes vos données seront automatiquement déplacées vers le nouvel emplacement.")
            }
        }
        .navigationTitle("Réglages")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            store.send(.onAppear)
        }
        .alert(
            "Changer d'emplacement de stockage",
            isPresented: Binding(
                get: { store.showChangeStorageConfirmation },
                set: { if !$0 { store.send(.cancelChangeStorage) } }
            )
        ) {
            Button("Annuler", role: .cancel) {
                store.send(.cancelChangeStorage)
            }
            Button("Continuer") {
                store.send(.confirmChangeStorage)
            }
        } message: {
            Text("Vous allez changer de dossier de stockage.\n\n📦 Toutes vos données seront automatiquement déplacées vers le nouveau dossier.\n\n🗑️ L'ancien dossier sera supprimé une fois le déplacement terminé.")
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
        .sheet(isPresented: Binding(
            get: { store.isSelectingNewFolder },
            set: { if !$0 { store.send(.folderSelectionCancelled) } }
        )) {
            FolderPickerView(
                isPresented: Binding(
                    get: { store.isSelectingNewFolder },
                    set: { if !$0 { store.send(.folderSelectionCancelled) } }
                ),
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

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            StorageSettingsView(
                store: Store(
                    initialState: StorageSettingsStore.State(
                        currentStoragePath: "/Users/test/iCloud Drive/Invoicer"
                    )
                ) {
                    StorageSettingsStore()
                }
            )
        }
        .previewDisplayName("Normal")

        NavigationStack {
            StorageSettingsView(
                store: Store(
                    initialState: StorageSettingsStore.State(
                        currentStoragePath: nil
                    )
                ) {
                    StorageSettingsStore()
                }
            )
        }
        .previewDisplayName("Not Configured")
    }
}
#endif
