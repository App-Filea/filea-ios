//
//  AppConstants.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Application-wide constants and configuration values
//

import Foundation

/// Application-wide constants
enum AppConstants {
    // MARK: - App Information

    /// The app's display name
    static let appName = "Holfy"

    /// The app's bundle identifier
    static let bundleIdentifier = "com.nicolasbarb.filea"

    /// The current app version
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    /// The current build number
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - File Storage

    /// Base directory name for vehicle storage
    static let vehiclesDirectoryName = "Holfy"

    /// JSON file name for vehicles list
    static let vehiclesFileName = "vehicles.json"

    /// Documents subdirectory name within each vehicle folder
    static let documentsDirectoryName = "Documents"

    // MARK: - Default Values

    /// Default currency symbol
    static let currencySymbol = "€"

    /// Default locale identifier
    static let localeIdentifier = "fr_FR"

    /// Default date format
    static let defaultDateFormat = "dd/MM/yyyy"

    /// Default date-time format
    static let defaultDateTimeFormat = "dd/MM/yyyy HH:mm"

    // MARK: - Limits

    /// Maximum file size for document uploads (in bytes) - 50 MB
    static let maxDocumentFileSize: Int64 = 50 * 1024 * 1024

    /// Maximum number of documents per vehicle
    static let maxDocumentsPerVehicle = 1000

    /// Maximum vehicle name length
    static let maxVehicleNameLength = 50

    /// Maximum document name length
    static let maxDocumentNameLength = 100

    // MARK: - Animation Durations

    /// Standard animation duration
    static let standardAnimationDuration: Double = 0.3

    /// Fast animation duration
    static let fastAnimationDuration: Double = 0.15

    /// Slow animation duration
    static let slowAnimationDuration: Double = 0.5

    // MARK: - User Defaults Keys

    enum UserDefaultsKeys {
        /// Key for storing the last selected vehicle ID
        static let lastSelectedVehicleID = "lastSelectedVehicleID"

        /// Key for storing user preferences
        static let userPreferences = "userPreferences"

        /// Key for storing app launch count
        static let appLaunchCount = "appLaunchCount"

        /// Key for storing last app version
        static let lastAppVersion = "lastAppVersion"

        /// Key for tracking if onboarding was completed
        static let hasCompletedOnboarding = "hasCompletedOnboarding"

        /// Key for storing sort preference
        static let sortPreference = "sortPreference"

        /// Key for storing filter preferences
        static let filterPreferences = "filterPreferences"

        /// Key for storing the security-scoped bookmark data
        static let storageBookmark = "storageBookmark"
    }

    // MARK: - Notification Names

    enum Notifications {
        /// Posted when a vehicle is added
        static let vehicleAdded = Notification.Name("vehicleAdded")

        /// Posted when a vehicle is updated
        static let vehicleUpdated = Notification.Name("vehicleUpdated")

        /// Posted when a vehicle is deleted
        static let vehicleDeleted = Notification.Name("vehicleDeleted")

        /// Posted when a document is added
        static let documentAdded = Notification.Name("documentAdded")

        /// Posted when a document is updated
        static let documentUpdated = Notification.Name("documentUpdated")

        /// Posted when a document is deleted
        static let documentDeleted = Notification.Name("documentDeleted")
    }

    // MARK: - Error Messages

    enum ErrorMessages {
        static let fileNotFound = "Le fichier demandé est introuvable."
        static let saveFailed = "Impossible de sauvegarder les modifications."
        static let loadFailed = "Impossible de charger les données."
        static let deleteFailed = "Impossible de supprimer l'élément."
        static let invalidData = "Les données fournies sont invalides."
        static let networkError = "Erreur de connexion réseau."
        static let permissionDenied = "Permission refusée."
        static let fileSizeExceeded = "La taille du fichier dépasse la limite autorisée."
        static let unknownError = "Une erreur inconnue s'est produite."
    }

    // MARK: - Success Messages

    enum SuccessMessages {
        static let saved = "Enregistré avec succès."
        static let deleted = "Supprimé avec succès."
        static let updated = "Mis à jour avec succès."
        static let added = "Ajouté avec succès."
    }

    // MARK: - URLs

    enum URLs {
        /// Support email address
        static let supportEmail = "support@invoicer.com"

        /// Privacy policy URL
        static let privacyPolicy = "https://invoicer.com/privacy"

        /// Terms of service URL
        static let termsOfService = "https://invoicer.com/terms"

        /// App Store URL for reviews
        static let appStoreReview = "https://apps.apple.com/app/id\(AppConstants.bundleIdentifier)"
    }

    // MARK: - Feature Flags

    enum FeatureFlags {
        /// Enable cloud sync feature
        static let enableCloudSync = false

        /// Enable export to PDF feature
        static let enablePDFExport = true

        /// Enable statistics dashboard
        static let enableStatistics = true

        /// Enable notifications
        static let enableNotifications = true

        /// Enable dark mode
        static let enableDarkMode = true

        /// Enable biometric authentication
        static let enableBiometricAuth = false
    }

    // MARK: - Accessibility

    enum Accessibility {
        /// Minimum touch target size (44x44 as per Apple HIG)
        static let minimumTouchTarget: CGFloat = 44

        /// Recommended touch target size
        static let recommendedTouchTarget: CGFloat = 48
    }
}

// MARK: - Helper Methods

extension AppConstants {
    /// Checks if this is the first app launch
    static var isFirstLaunch: Bool {
        UserDefaults.standard.integer(forKey: UserDefaultsKeys.appLaunchCount) == 0
    }

    /// Increments the app launch count
    static func incrementLaunchCount() {
        let currentCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.appLaunchCount)
        UserDefaults.standard.set(currentCount + 1, forKey: UserDefaultsKeys.appLaunchCount)
    }

    /// Checks if the app was updated since last launch
    static var wasAppUpdated: Bool {
        let lastVersion = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastAppVersion)
        let currentVersion = appVersion

        if lastVersion != currentVersion {
            UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastAppVersion)
            return lastVersion != nil
        }

        return false
    }
}
