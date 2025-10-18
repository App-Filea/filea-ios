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
        ScrollView {
            VStack(spacing: 28) {
                Spacer()
                    .frame(height: 20)

                // Icon
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 70))
                    .foregroundStyle(.blue.gradient)
                    .symbolEffect(.bounce, value: store.isSelectingFolder)

                // Title
                VStack(spacing: 12) {
                    Text("Choisissez votre dossier de stockage")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("Vos factures et documents seront stockés dans le dossier que vous choisissez.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                // Recommended Locations
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.subheadline)
                        Text("Emplacements recommandés")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        RecommendedLocationRow(
                            icon: "icloud",
                            title: "iCloud Drive",
                            badge: "Recommandé",
                            badgeColor: .green,
                            benefits: [
                                "Synchronisé sur tous vos appareils",
                                "Sauvegarde automatique",
                                "Données conservées même si vous désinstallez l'app"
                            ]
                        )

                        RecommendedLocationRow(
                            icon: "globe",
                            title: "Google Drive / Dropbox",
                            badge: "Compatible",
                            badgeColor: .blue,
                            benefits: [
                                "Accessible depuis n'importe quel appareil",
                                "Partage facile avec d'autres personnes"
                            ]
                        )
                    }
                    .padding(.horizontal, 24)
                }

                // Warning about "Sur mon iPhone"
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.subheadline)
                        Text("Important")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }

                    Text("Vous ne pouvez pas créer de dossier directement à la racine de \"Sur mon iPhone\".\n\nSi vous souhaitez un stockage local, créez d'abord un dossier dans iCloud Drive ou dans un autre emplacement.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 24)

                // Features List
                VStack(alignment: .leading, spacing: 14) {
                    Text("Avantages de notre système")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 24)

                    VStack(spacing: 14) {
                        FeatureRow(
                            icon: "checkmark.shield.fill",
                            title: "Vos données vous appartiennent",
                            description: "Même en désinstallant l'app, vos factures restent dans le dossier choisi"
                        )

                        FeatureRow(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Changement d'emplacement",
                            description: "Vous pouvez changer de dossier à tout moment dans les réglages"
                        )

                        FeatureRow(
                            icon: "externaldrive.fill",
                            title: "Sauvegarde externe facilitée",
                            description: "Sauvegardez facilement vos données avec votre solution cloud préférée"
                        )
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()
                    .frame(height: 20)

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
        }
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

// MARK: - Recommended Location Row

private struct RecommendedLocationRow: View {
    let icon: String
    let title: String
    let badge: String
    let badgeColor: Color
    let benefits: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 28)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Text(badge)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badgeColor)
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(benefits, id: \.self) { benefit in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .frame(width: 16)

                        Text(benefit)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.leading, 28)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                    .fixedSize(horizontal: false, vertical: true)
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
