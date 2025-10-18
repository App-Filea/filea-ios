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

    // MARK: - Properties

    @Bindable var store: StoreOf<StorageOnboardingStore>

    // MARK: - Body

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
                .symbolEffect(.bounce, value: store.isSelectingFolder)

            // Title
            VStack(spacing: 12) {
                Text("Choisissez votre dossier de stockage")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Sélectionnez un emplacement pour stocker vos véhicules et documents. Vous pouvez choisir iCloud Drive, Google Drive, Dropbox ou un dossier local.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // Features List
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "checkmark.icloud",
                    title: "Synchronisation cloud",
                    description: "Vos données seront accessibles sur tous vos appareils"
                )

                FeatureRow(
                    icon: "lock.shield",
                    title: "Sécurité",
                    description: "Contrôle total sur l'emplacement de vos données"
                )

                FeatureRow(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Flexibilité",
                    description: "Changez d'emplacement quand vous voulez"
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            // Error Message
            if let errorMessage = store.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 24)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Primary Button
            Button {
                store.send(.selectFolderTapped)
            } label: {
                HStack {
                    if store.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "folder.badge.plus")
                        Text("Choisir un dossier")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.gradient)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
            }
            .disabled(store.isLoading)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .animation(.spring(), value: store.errorMessage)
        .animation(.spring(), value: store.isLoading)
        .sheet(isPresented: $store.isSelectingFolder) {
            DocumentPickerView(
                isPresented: $store.isSelectingFolder,
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

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct StorageOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Normal state
            StorageOnboardingView(
                store: Store(initialState: StorageOnboardingStore.State()) {
                    StorageOnboardingStore()
                }
            )
            .previewDisplayName("Normal")

            // Error state
            StorageOnboardingView(
                store: Store(
                    initialState: StorageOnboardingStore.State(
                        errorMessage: "Impossible de créer le bookmark de sécurité."
                    )
                ) {
                    StorageOnboardingStore()
                }
            )
            .previewDisplayName("Error")

            // Loading state
            StorageOnboardingView(
                store: Store(
                    initialState: StorageOnboardingStore.State(isLoading: true)
                ) {
                    StorageOnboardingStore()
                }
            )
            .previewDisplayName("Loading")
        }
    }
}
#endif
