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
struct SettingsStore {

    // MARK: - State

    @ObservableState
    struct State: Equatable {
        var currentStoragePath: String?
        var isSelectingNewFolder = false
        var showChangeStorageConfirmation = false
        var errorMessage: String?
        var isLoading = false
    }

    // MARK: - Action

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

    // MARK: - Dependencies

    @Dependency(\.storageManager) var storageManager

    // MARK: - Reducer

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
                        // Reset current storage
                        await storageManager.resetStorage()

                        // Save new storage folder
                        try await storageManager.saveStorageFolder(url)

                        await send(.storageFolderChanged)
                    } catch {
                        await send(.changeStorageFailed(error.localizedDescription))
                    }
                }

            case .folderSelectionCancelled:
                state.isSelectingNewFolder = false
                return .none

            case .storageFolderChanged:
                state.isLoading = false
                // Reload the storage path
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
}
