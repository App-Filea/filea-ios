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
                        await send(.saveFailed(error.localizedDescription))
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
}
