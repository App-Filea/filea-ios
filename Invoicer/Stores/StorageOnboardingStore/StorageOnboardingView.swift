//
//  StorageOnboardingView.swift
//  Invoicer
//
//  Created by Claude on 2025-01-18.
//  Onboarding view for selecting storage folder
//

import SwiftUI
import ComposableArchitecture

struct StorageOnboardingView: View {

    @Bindable var store: StoreOf<StorageOnboardingStore>

    var body: some View {
        VStack(spacing: 0) {

            ScrollView {
                StorageIconView()
                    .padding(.top, 60)
                    .padding(.bottom, 28)

                Text("Choisissez votre emplacement")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)

                VStack(alignment: .leading, spacing: 24) {
                    StorageFeatureRow(
                        icon: "externaldrive.badge.icloud",
                        iconColor: .blue,
                        title: "Stockage flexible",
                        description: "Choisissez entre votre téléphone ou iCloud Drive."
                    )

                    StorageFeatureRow(
                        icon: "checkmark.shield.fill",
                        iconColor: .orange,
                        title: "Vos données vous appartiennent",
                        description: "Même après désinstallation, vos fichiers restent accessibles."
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)

                if let errorMessage = store.errorMessage {
                    ErrorMessageView(message: errorMessage)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .scrollBounceBehavior(.basedOnSize)

            Button(action: { store.send(.selectFolderTapped) }) {
                HStack {
                    if store.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "folder.badge.plus")
                        Text("Sélectionner un dossier")
                    }
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(store.isLoading)
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
        .background(Color(uiColor: .systemBackground))
        .animation(.spring(), value: store.errorMessage)
        .animation(.spring(), value: store.isLoading)
        .sheet(isPresented: Binding(
            get: { store.isSelectingFolder },
            set: { if !$0 { store.send(.folderSelectionCancelled) } }
        )) {
            FolderPickerView(
                isPresented: Binding(
                    get: { store.isSelectingFolder },
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
    }
}

struct StorageIconView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 100, height: 100)

            Image(systemName: "folder.badge.plus")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(.blue)
        }
    }
}

struct StorageFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.primary)

                Text(description)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct ErrorMessageView: View {
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.red)

                Text("Dossier inaccessible")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            Text("Choisissez un dossier dans iCloud Drive ou un autre emplacement accessible.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("Normal") {
    StorageOnboardingView(
        store: Store(initialState: StorageOnboardingStore.State()) { StorageOnboardingStore() } )
}

#Preview("Avec erreur") {
    StorageOnboardingView(
        store: Store(initialState: StorageOnboardingStore.State(currentError: .accessFailure)) { StorageOnboardingStore() } )
}

#Preview("Chargement") {
    StorageOnboardingView(
        store: Store(initialState: StorageOnboardingStore.State(isLoading: true)) { StorageOnboardingStore() } )
}
