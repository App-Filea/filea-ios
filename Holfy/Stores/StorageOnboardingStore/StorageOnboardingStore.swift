//
//  StorageOnboardingStore.swift
//  Invoicer
//
//  Created by Claude on 2025-01-18.
//  TCA Store for storage folder selection onboarding
//

import ComposableArchitecture
import Foundation

// MARK: - StorageOnboardingError

/// Errors specific to storage onboarding flow
enum StorageOnboardingError: Error, Equatable {
    case storageError(StorageError)
    case restrictedLocation(LocationType)
    case bookmarkFailure
    case accessFailure
    case unknownError(String)

    /// Types of restricted storage locations
    enum LocationType: Equatable {
        case fileProviderStorage
        case localDevice
        case unknown
    }

    // MARK: - Error Classification

    /// Creates a StorageOnboardingError from a generic Error and URL context
    static func from(_ error: Error, url: URL) -> Self {
        // First, check if it's already a StorageError
        if let storageError = error as? StorageError {
            return classify(storageError: storageError, url: url)
        }

        // Check for Cocoa errors (NSError domain)
        let nsError = error as NSError

        // Check for permission/access errors
        if nsError.domain == NSCocoaErrorDomain {
            switch nsError.code {
            case NSFileWriteNoPermissionError, NSFileReadNoPermissionError:
                return .restrictedLocation(detectLocationType(from: url))
            case NSFileWriteInvalidFileNameError:
                return .restrictedLocation(detectLocationType(from: url))
            default:
                break
            }
        }

        // Fallback to unknown error
        return .unknownError(error.localizedDescription)
    }

    private static func classify(storageError: StorageError, url: URL) -> Self {
        switch storageError {
        case .bookmarkCreationFailed, .bookmarkResolutionFailed:
            return .bookmarkFailure

        case .accessDenied, .securityScopedResourceAccessFailed:
            return .accessFailure

        case .folderCreationFailed:
            return .restrictedLocation(detectLocationType(from: url))

        case .notConfigured, .fileSaveFailed, .migrationFailed, .deletionFailed:
            return .storageError(storageError)
        }
    }

    private static func detectLocationType(from url: URL) -> LocationType {
        let path = url.path.lowercased()

        // Check for File Provider Storage (iCloud, Dropbox, etc.)
        // These paths typically contain "file provider storage"
        if path.contains("file provider storage") {
            return .fileProviderStorage
        }

        // Check for "On My iPhone/iPad" location
        // French: "sur mon iphone", "sur mon ipad"
        // English: "on my iphone", "on my ipad"
        let localDevicePatterns = [
            "sur mon iphone", "sur mon ipad",
            "on my iphone", "on my ipad",
            "on my device"
        ]

        if localDevicePatterns.contains(where: { path.contains($0) }) {
            return .localDevice
        }

        return .unknown
    }

    // MARK: - User-Friendly Messages

    /// Returns a user-friendly error message in French
    var userMessage: String {
        switch self {
        case .storageError(let storageError):
            return storageError.localizedDescription

        case .restrictedLocation(.fileProviderStorage):
            return """
            ❌ Impossible de créer un dossier ici.

            💡 Conseil : Choisissez plutôt iCloud Drive ou créez d'abord un sous-dossier dans un emplacement existant.
            """

        case .restrictedLocation(.localDevice):
            return """
            ❌ Impossible de créer un dossier dans "Sur mon iPhone".

            💡 Conseil : Utilisez iCloud Drive pour un accès fiable et sécurisé à vos données.
            """

        case .restrictedLocation(.unknown):
            return """
            ❌ Impossible d'accéder à ce dossier.

            Vérifiez que vous avez les permissions nécessaires.
            """

        case .bookmarkFailure:
            return """
            ❌ Impossible de sauvegarder l'emplacement.

            💡 Essayez de choisir un autre dossier ou redémarrez l'application.
            """

        case .accessFailure:
            return """
            ❌ Impossible d'accéder au dossier sélectionné.

            💡 Assurez-vous que le dossier existe toujours et qu'il est accessible.
            """

        case .unknownError(let description):
            return """
            ❌ Une erreur s'est produite.

            💡 Essayez de sélectionner un autre emplacement (iCloud Drive recommandé).

            Détails : \(description)
            """
        }
    }
}

// MARK: - StorageOnboardingStore

@Reducer
struct StorageOnboardingStore {

    enum ViewState: Equatable {
        case loading
        case createFolder
        case error
        case succeed
    }

    @ObservableState
    struct State: Equatable {
        var isSelectingFolder = false
        var currentError: StorageOnboardingError?
        var isLoading = false
        var viewState: ViewState = .createFolder

        var errorMessage: String? {
            currentError?.userMessage
        }
    }

    enum Action: Equatable {
        case selectFolderTapped
        case documentPickerPresented
        case folderSelected(URL)
        case folderSelectionCancelled
        case folderSaved
        case saveFailed(StorageOnboardingError)
        case dismissError
    }

    @Dependency(\.storageManager) var storageManager
    @Dependency(\.syncManagerClient) var syncManager

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .selectFolderTapped:
                print("🚀 [StorageOnboardingStore] User tapped select folder")
                state.currentError = nil
                state.isSelectingFolder = true
                return .none

            case .documentPickerPresented:
                print("📄 [StorageOnboardingStore] Document picker presented")
                return .none

            case .folderSelected(let url):
                print("📁 [StorageOnboardingStore] Folder selected")
                print("   └─ Path: \(url.path)")

                state.isSelectingFolder = false
                state.isLoading = true
                state.currentError = nil

                return .run { send in
                    do {
                        // 1. Sauvegarder le dossier (crée le bookmark + gère le renommage Vehicles→Holfy)
                        print("💾 [StorageOnboardingStore] Saving storage folder...")
                        try await storageManager.saveStorageFolder(url)
                        print("✅ [StorageOnboardingStore] Storage folder saved successfully")

                        // 2. Lancer la migration si vehicles.json existe
                        @Dependency(\.legacyMigrator) var migrator
                        let migrationResult = await migrator.migrateIfNeeded(url)

                        // Déterminer le dossier Holfy
                        let holfyDir = url.appendingPathComponent(AppConstants.vehiclesDirectoryName)

                        switch migrationResult {
                        case .success(let vehicles, let documents):
                            print("✅ [StorageOnboardingStore] Migration réussie: \(vehicles) véhicules, \(documents) documents")
                            // Scanner pour réparer les fichiers orphelins après migration
                            if FileManager.default.fileExists(atPath: holfyDir.path) {
                                _ = try await syncManager.scanAndRebuildDatabase(holfyDir.path)
                            }

                        case .partialSuccess(let vehicles, let documents, let errors):
                            print("⚠️ [StorageOnboardingStore] Migration partielle: \(vehicles) véhicules, \(documents) documents")
                            print("   Erreurs: \(errors)")
                            // Scanner pour réparer les fichiers orphelins après migration partielle
                            if FileManager.default.fileExists(atPath: holfyDir.path) {
                                _ = try await syncManager.scanAndRebuildDatabase(holfyDir.path)
                            }

                        case .noLegacyData:
                            print("ℹ️ [StorageOnboardingStore] Pas de données legacy à migrer")
                            // Vérifier s'il y a des .vehicle_metadata.json existants
                            if FileManager.default.fileExists(atPath: holfyDir.path) {
                                print("📦 [StorageOnboardingStore] Scanning for existing .vehicle_metadata.json files...")
                                let importedVehicles = try await syncManager.scanAndRebuildDatabase(holfyDir.path)
                                if !importedVehicles.isEmpty {
                                    print("✅ [StorageOnboardingStore] \(importedVehicles.count) véhicule(s) importé(s)")
                                }
                            }

                        case .alreadyMigrated:
                            print("ℹ️ [StorageOnboardingStore] Migration déjà effectuée")
                            // Scanner quand même pour réparer les fichiers orphelins
                            if FileManager.default.fileExists(atPath: holfyDir.path) {
                                _ = try await syncManager.scanAndRebuildDatabase(holfyDir.path)
                            }

                        case .failed(let errorDescription):
                            print("❌ [StorageOnboardingStore] Migration failed: \(errorDescription)")
                        }

                        // 3. Marquer comme réussi
                        await send(.folderSaved)
                    } catch {
                        print("❌ [StorageOnboardingStore] Failed to save storage folder")
                        print("   └─ Error: \(error.localizedDescription)\n")

                        // Classify the error into a typed StorageOnboardingError
                        let typedError = StorageOnboardingError.from(error, url: url)
                        await send(.saveFailed(typedError))
                    }
                }

            case .folderSelectionCancelled:
                print("⚠️ [StorageOnboardingStore] Folder selection cancelled\n")
                state.isSelectingFolder = false
                state.currentError = nil
                return .none

            case .folderSaved:
                print("✅ [StorageOnboardingStore] Folder saved action received")
                state.isLoading = false
                state.viewState = .succeed
                return .none

            case .saveFailed(let error):
                print("❌ [StorageOnboardingStore] Save failed action received")
                print("   ├─ Error type: \(error)")
                print("   └─ User message: \(error.userMessage)\n")

                state.isLoading = false
                state.currentError = error
                state.viewState = .error
                return .none

            case .dismissError:
                print("🔄 [StorageOnboardingStore] Error dismissed\n")
                state.currentError = nil
                state.viewState = .createFolder
                return .none
            }
        }
    }
}
