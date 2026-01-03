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
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {

                ScrollView {
                    VStack(spacing: 0) {
                        StorageIconView()
                            .padding(.top, 60)
                            .padding(.bottom, 28)

                        Text("Choisissez votre emplacement")
                            .largeTitle()
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
                        .padding(.bottom, 32)

                        if let errorMessage = store.errorMessage {
                            ErrorMessageView(message: errorMessage)
                                .padding(.bottom, 16)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.horizontal, Spacing.screenMargin)
                }
                .scrollBounceBehavior(.basedOnSize)
                
                PrimaryButton("Sélectionner un dossier",
                              systemImage: "folder.badge.plus",
                              isLoading: store.isLoading,
                              action: { store.send(.selectFolderTapped) })
                .padding([.horizontal, .bottom], Spacing.screenMargin)
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

struct StorageIconView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.tertiary)
                .frame(width: 100, height: 100)

            Image(systemName: "folder.badge.plus")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(.blue)
        }
    }
}

struct StorageFeatureRow<style: ShapeStyle>: View {
    let icon: String
    let iconColor: style
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.tertiary)
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
                    .foregroundStyle(Color.red)

                Text("Dossier inaccessible")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }

            Text("Choisissez un dossier dans iCloud Drive ou un autre emplacement accessible.")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.quinary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.secondary, lineWidth: 1)
        )
    }
}

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
