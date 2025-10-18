//
//  StorageOnboardingStore.swift
//  Invoicer
//
//  Created by Claude on 2025-01-18.
//  TCA Store for storage folder selection onboarding
//

import ComposableArchitecture
import Foundation

@Reducer
struct StorageOnboardingStore {

    // MARK: - State

    @ObservableState
    struct State: Equatable {
        var isSelectingFolder = false
        var errorMessage: String?
        var isLoading = false
    }

    // MARK: - Action

    enum Action: Equatable {
        case selectFolderTapped
        case documentPickerPresented
        case folderSelected(URL)
        case folderSelectionCancelled
        case folderSaved
        case saveFailed(String)
        case dismissError
    }

    // MARK: - Dependencies

    @Dependency(\.storageManager) var storageManager

    // MARK: - Reducer

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .selectFolderTapped:
                state.errorMessage = nil
                state.isSelectingFolder = true
                return .none

            case .documentPickerPresented:
                // Document picker is now visible
                return .none

            case .folderSelected(let url):
                state.isSelectingFolder = false
                state.isLoading = true
                state.errorMessage = nil

                return .run { send in
                    do {
                        // Save the selected folder to storage manager
                        try await storageManager.saveStorageFolder(url)
                        await send(.folderSaved)
                    } catch {
                        // Provide user-friendly error messages
                        let friendlyMessage = Self.getFriendlyErrorMessage(from: error, url: url)
                        await send(.saveFailed(friendlyMessage))
                    }
                }

            case .folderSelectionCancelled:
                state.isSelectingFolder = false
                state.errorMessage = nil
                return .none

            case .folderSaved:
                state.isLoading = false
                // Storage is now configured, the parent store will handle navigation
                return .none

            case .saveFailed(let errorMessage):
                state.isLoading = false
                state.errorMessage = errorMessage
                return .none

            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
    }

    // MARK: - Helper Methods

    /// Converts technical errors into user-friendly messages with helpful guidance
    private static func getFriendlyErrorMessage(from error: Error, url: URL) -> String {
        let errorDescription = error.localizedDescription.lowercased()
        let urlPath = url.path.lowercased()

        // Permission denied errors
        if errorDescription.contains("permission") || errorDescription.contains("denied") {
            if urlPath.contains("file provider storage") || urlPath.contains("sur mon iphone") {
                return "❌ Impossible de créer un dossier ici.\n\n💡 Conseil : Choisissez plutôt iCloud Drive ou créez d'abord un sous-dossier dans un emplacement existant."
            } else {
                return "❌ Impossible d'accéder à ce dossier.\n\nVérifiez que vous avez les permissions nécessaires."
            }
        }

        // Bookmark creation errors
        if errorDescription.contains("bookmark") {
            return "❌ Impossible de sauvegarder l'emplacement.\n\n💡 Essayez de choisir un autre dossier ou redémarrez l'application."
        }

        // Access errors
        if errorDescription.contains("access") {
            return "❌ Impossible d'accéder au dossier sélectionné.\n\n💡 Assurez-vous que le dossier existe toujours et qu'il est accessible."
        }

        // Generic fallback with the original error
        return "❌ Une erreur s'est produite.\n\n💡 Essayez de sélectionner un autre emplacement (iCloud Drive recommandé).\n\nDétails : \(error.localizedDescription)"
    }
}
