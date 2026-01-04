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
        var isLoading = false

        @Presents var confirmationAlert: AlertState<Action.ConfirmationAlert>?
        @Presents var errorAlert: AlertState<Action.ErrorAlert>?
    }

    enum Action: Equatable {
        case onAppear
        case loadCurrentStoragePath
        case storagePathLoaded(String?)
        case changeStorageTapped
        case selectNewFolder
        case folderSelected(URL)
        case folderSelectionCancelled
        case storageFolderChanged
        case changeStorageFailed

        case confirmationAlert(PresentationAction<ConfirmationAlert>)
        case errorAlert(PresentationAction<ErrorAlert>)

        enum ConfirmationAlert: Equatable {
            case confirm
            case cancel
        }

        enum ErrorAlert: Equatable {
            case dismiss
        }
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
                state.confirmationAlert = .changeStorageLocationAlert()
                return .none

            case .confirmationAlert(.presented(.confirm)):
                state.confirmationAlert = nil
                return .send(.selectNewFolder)

            case .confirmationAlert(.presented(.cancel)):
                state.confirmationAlert = nil
                return .none

            case .selectNewFolder:
                state.isSelectingNewFolder = true
                return .none

            case .folderSelected(let url):
                state.isSelectingNewFolder = false
                state.isLoading = true

                return .run { send in
                    let startTime = Date()
                    var oldAccessURL: URL? = nil

                    do {
                        let oldURL = await storageManager.getRootURL()
                        oldAccessURL = oldURL

                        try await storageManager.saveStorageFolder(url)

                        if let oldURL = oldURL, oldURL.path != url.path {
                            try await storageManager.migrateContent(oldURL, url)

                            try await storageManager.deleteOldVehiclesDirectory(oldURL)

                            oldURL.stopAccessingSecurityScopedResource()
                        }

                        let elapsed = Date().timeIntervalSince(startTime)
                        let remaining = max(0, 3.0 - elapsed)
                        if remaining > 0 {
                            try await Task.sleep(for: .seconds(remaining))
                        }

                        await send(.storageFolderChanged)
                    } catch {
                        if let oldAccessURL = oldAccessURL {
                            try? await storageManager.saveStorageFolder(oldAccessURL)
                        }

                        await send(.changeStorageFailed)
                    }
                }

            case .folderSelectionCancelled:
                state.isSelectingNewFolder = false
                return .none

            case .storageFolderChanged:
                state.isLoading = false
                return .send(.loadCurrentStoragePath)

            case .changeStorageFailed:
                state.isLoading = false
                state.errorAlert = .storageErrorAlert()
                return .none

            case .errorAlert(.presented(.dismiss)):
                state.errorAlert = nil
                return .none

            case .confirmationAlert:
                return .none

            case .errorAlert:
                return .none
            }
        }
    }
}
