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
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.md) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("settings_storage_current_location")
                            .formFieldTitle()
                            .padding(.horizontal, 4)

                        VStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 4) {
                                if let path = store.currentStoragePath {
                                    Text(path)
                                        .formFieldLeadingTitle()
                                } else {
                                    Text("settings_storage_unconfigured")
                                        .formFieldLeadingTitle()
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                            HStack(spacing: 8) {
                                Image(systemName: "info.circle")
                                Text("settings_storage_info")

                                Spacer()
                            }
                            .formFieldInfoLabel()
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.gray.quinary)
                        }
                        .fieldCard(isError: false)
                    }

                    SecondaryButton("settings_storage_change_location", action: {
                        store.send(.changeStorageTapped)
                    })
                }
                .padding(Spacing.screenMargin)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .navigationTitle("settings_storage_title")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            store.send(.onAppear)
        }
        .alert($store.scope(state: \.confirmationAlert, action: \.confirmationAlert))
        .alert($store.scope(state: \.errorAlert, action: \.errorAlert))
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
                            .tint(Color.primary)
                            .scaleEffect(1.5)

                        Text("settings_storage_loading_title")
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                    }
                    .padding(32)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
    }
}

#Preview("normal") {
    NavigationView {
        StorageSettingsView(
            store: Store(
                initialState: StorageSettingsStore.State(
                    currentStoragePath: "/Users/test/iCloud Drive/Holfy"
                )
            ) {
                StorageSettingsStore()
            }
        )
    }
}

#Preview("non configuré") {
    NavigationView {
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
}
