//
//  SettingsStore.swift
//  Invoicer
//
//  Created by Claude on 2025-01-18.
//  TCA Store for app settings including storage management
//

import ComposableArchitecture
import Foundation

@Reducer
struct StorageSettingsStore {

    @ObservableState
    struct State: Equatable {
        var currentStoragePath: String?
        var isSelectingNewFolder = false
        var showChangeStorageConfirmation = false
        var errorMessage: String?
        var isLoading = false
    }

    enum Action: Equatable {
        case onAppear
        case loadCurrentStoragePath
        case storagePathLoaded(String?)
        case changeStorageTapped
        case confirmChangeStorage
        case cancelChangeStorage
        case selectNewFolder
        case folderSelected(URL)
        case folderSelectionCancelled
        case storageFolderChanged
        case changeStorageFailed(String)
        case dismissError
    }

    @Dependency(\.storageManager) var storageManager

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadCurrentStoragePath)

            case .loadCurrentStoragePath:
                return .run { send in
                    let url = await storageManager.getRootURL()
                    await send(.storagePathLoaded(url?.path))
                }

            case .storagePathLoaded(let path):
                state.currentStoragePath = path
                return .none

            case .changeStorageTapped:
                state.showChangeStorageConfirmation = true
                return .none

            case .confirmChangeStorage:
                state.showChangeStorageConfirmation = false
                return .send(.selectNewFolder)

            case .cancelChangeStorage:
                state.showChangeStorageConfirmation = false
                return .none

            case .selectNewFolder:
                state.isSelectingNewFolder = true
                state.errorMessage = nil
                return .none

            case .folderSelected(let url):
                state.isSelectingNewFolder = false
                state.isLoading = true

                return .run { send in
                    do {
                        await storageManager.resetStorage()

                        try await storageManager.saveStorageFolder(url)

                        await send(.storageFolderChanged)
                    } catch {
                        let friendlyMessage = Self.getFriendlyErrorMessage(from: error, url: url)
                        await send(.changeStorageFailed(friendlyMessage))
                    }
                }

            case .folderSelectionCancelled:
                state.isSelectingNewFolder = false
                return .none

            case .storageFolderChanged:
                state.isLoading = false
                return .send(.loadCurrentStoragePath)

            case .changeStorageFailed(let errorMessage):
                state.isLoading = false
                state.errorMessage = errorMessage
                return .none

            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
    }

    private static func getFriendlyErrorMessage(from error: Error, url: URL) -> String {
        let errorDescription = error.localizedDescription.lowercased()
        let urlPath = url.path.lowercased()

        if errorDescription.contains("permission") || errorDescription.contains("denied") {
            if urlPath.contains("file provider storage") || urlPath.contains("sur mon iphone") {
                return "❌ Impossible de créer un dossier ici.\n\n💡 Conseil : Choisissez plutôt iCloud Drive ou créez d'abord un sous-dossier dans un emplacement existant."
            } else {
                return "❌ Impossible d'accéder à ce dossier.\n\nVérifiez que vous avez les permissions nécessaires."
            }
        }

        if errorDescription.contains("bookmark") {
            return "❌ Impossible de sauvegarder l'emplacement.\n\n💡 Essayez de choisir un autre dossier ou redémarrez l'application."
        }

        if errorDescription.contains("access") {
            return "❌ Impossible d'accéder au dossier sélectionné.\n\n💡 Assurez-vous que le dossier existe toujours et qu'il est accessible."
        }

        return "❌ Une erreur s'est produite.\n\n💡 Essayez de sélectionner un autre emplacement (iCloud Drive recommandé).\n\nDétails : \(error.localizedDescription)"
    }
}
