//
//  VehicleStorageManager.swift
//  Invoicer
//
//  Created by Claude on 2025-01-18.
//  Manages user-selected storage folder with security-scoped bookmarks
//

import Foundation
import os.log

/// Actor responsible for managing the storage location of vehicle data
/// Uses security-scoped bookmarks to persist access to user-selected folders
actor VehicleStorageManager {

    // MARK: - Properties

    private let logger = Logger(subsystem: AppConstants.bundleIdentifier, category: "VehicleStorageManager")
    private let fileManager = FileManager.default
    private let userDefaults = UserDefaults.standard

    /// Current storage root URL (nil if not configured)
    private var rootURL: URL?

    /// Indicates whether we're currently accessing a security-scoped resource
    private var isAccessingSecurityScopedResource = false

    // MARK: - Storage State

    /// Represents the current state of storage configuration
    enum StorageState: Equatable {
        case notConfigured
        case configured(URL)
        case invalidAccess
    }

    // MARK: - Initialization

    init() {
        logger.info("🏗️ VehicleStorageManager initialized")
    }

    // MARK: - Public API

    /// Saves the URL of the user-selected folder and creates a security-scoped bookmark
    /// - Parameter url: The URL returned by UIDocumentPickerViewController
    /// - Throws: StorageError if bookmark creation fails
    func saveStorageFolder(_ url: URL) async throws {
        logger.info("💾 Saving storage folder: \(url.path)")

        // Start accessing the security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            logger.error("❌ Failed to start accessing security-scoped resource")
            throw StorageError.securityScopedResourceAccessFailed
        }

        // Create the security-scoped bookmark
        // Note: On iOS, bookmarks from UIDocumentPicker are automatically security-scoped
        do {
            let bookmarkData = try url.bookmarkData(
                options: [],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )

            // Save the bookmark data to UserDefaults
            userDefaults.set(bookmarkData, forKey: AppConstants.UserDefaultsKeys.storageBookmark)
            userDefaults.synchronize()

            logger.info("✅ Security-scoped bookmark created and saved")

            // Set the root URL and mark that we're accessing the resource
            self.rootURL = url
            self.isAccessingSecurityScopedResource = true

            logger.info("🔓 Security-scoped resource access is now active")

            // Create the Vehicles directory immediately while security-scoped access is active
            // Use NSFileCoordinator for File Provider compatibility (iCloud, Google Drive, etc.)
            let vehiclesURL = url.appendingPathComponent(AppConstants.vehiclesDirectoryName)
            try fileManager.createDirectoryCoordinated(at: vehiclesURL)
            logger.info("📁 Vehicles directory created successfully")
        } catch {
            // If bookmark creation failed, stop accessing the resource
            url.stopAccessingSecurityScopedResource()
            logger.error("❌ Failed to create bookmark: \(error.localizedDescription)")
            throw StorageError.bookmarkCreationFailed
        }
    }

    /// Restores access to the previously saved storage folder using the bookmark
    /// - Returns: The current storage state
    func restorePersistentFolder() async -> StorageState {
        logger.info("🔄 Attempting to restore persistent folder...")

        // Check if a bookmark exists
        guard let bookmarkData = userDefaults.data(forKey: AppConstants.UserDefaultsKeys.storageBookmark) else {
            logger.warning("⚠️ No bookmark found - storage not configured")
            return .notConfigured
        }

        // Resolve the bookmark to get the URL
        // Note: On iOS, use empty options to resolve security-scoped bookmarks
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            if isStale {
                logger.warning("⚠️ Bookmark is stale, recreating...")
                // Try to recreate the bookmark
                do {
                    try await saveStorageFolder(url)
                } catch {
                    logger.error("❌ Failed to recreate stale bookmark")
                    return .invalidAccess
                }
            }

            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                logger.error("❌ Failed to start accessing security-scoped resource")
                return .invalidAccess
            }

            // Verify the folder still exists
            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory),
                  isDirectory.boolValue else {
                logger.error("❌ Storage folder no longer exists")
                url.stopAccessingSecurityScopedResource()
                return .invalidAccess
            }

            // Successfully restored access
            self.rootURL = url
            self.isAccessingSecurityScopedResource = true
            logger.info("✅ Persistent folder restored: \(url.path)")

            // Ensure the Vehicles directory exists
            // Use NSFileCoordinator for File Provider compatibility
            let vehiclesURL = url.appendingPathComponent(AppConstants.vehiclesDirectoryName)
            do {
                try fileManager.createDirectoryCoordinated(at: vehiclesURL)
                logger.info("📁 Vehicles directory verified/created")
            } catch {
                logger.error("❌ Failed to create vehicles directory during restore: \(error.localizedDescription)")
                return .invalidAccess
                // Continue anyway - it will be retried later if needed
            }

            return .configured(url)
        } catch {
            logger.error("❌ Failed to resolve bookmark: \(error.localizedDescription)")
            return .invalidAccess
        }
    }

    /// Returns the current root URL if configured
    /// - Returns: The root URL or nil if not configured
    func getRootURL() async -> URL? {
        return rootURL
    }

    /// Creates a subfolder for a vehicle
    /// - Parameter name: The name of the vehicle folder (e.g., "Peugeot3008")
    /// - Returns: The URL of the created folder
    /// - Throws: StorageError if the folder cannot be created
    func createVehicleFolder(named name: String) async throws -> URL {
        guard let rootURL = rootURL else {
            logger.error("❌ Cannot create folder - storage not configured")
            throw StorageError.notConfigured
        }

        let folderURL = rootURL
            .appendingPathComponent(AppConstants.vehiclesDirectoryName)
            .appendingPathComponent(name)

        do {
            try fileManager.createDirectoryCoordinated(at: folderURL)
            logger.info("📁 Vehicle folder created: \(name)")
            return folderURL
        } catch {
            logger.error("❌ Failed to create vehicle folder: \(error.localizedDescription)")
            throw StorageError.folderCreationFailed(name)
        }
    }

    /// Saves a file to a specific vehicle's folder
    /// - Parameters:
    ///   - vehicleName: The name of the vehicle folder
    ///   - filename: The name of the file to save
    ///   - data: The data to write
    /// - Returns: The URL of the saved file
    /// - Throws: StorageError if the file cannot be saved
    func saveFile(forVehicle vehicleName: String, filename: String, data: Data) async throws -> URL {
        guard let rootURL = rootURL else {
            logger.error("❌ Cannot save file - storage not configured")
            throw StorageError.notConfigured
        }

        let vehicleFolderURL = rootURL
            .appendingPathComponent(AppConstants.vehiclesDirectoryName)
            .appendingPathComponent(vehicleName)

        // Ensure the vehicle folder exists
        try fileManager.createDirectoryCoordinated(at: vehicleFolderURL)

        let fileURL = vehicleFolderURL.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            logger.info("💾 File saved: \(filename) for vehicle: \(vehicleName)")
            return fileURL
        } catch {
            logger.error("❌ Failed to save file: \(error.localizedDescription)")
            throw StorageError.fileSaveFailed(filename)
        }
    }

    /// Saves a JSON file to a vehicle folder using the vehicle's folder path
    /// - Parameters:
    ///   - folderPath: The full path to the vehicle folder
    ///   - filename: The name of the JSON file to save
    ///   - data: The JSON data to write
    /// - Throws: StorageError if the file cannot be saved
    func saveJSONFile(toFolderPath folderPath: String, filename: String, data: Data) async throws {
        let folderURL = URL(fileURLWithPath: folderPath)

        // Ensure the vehicle folder exists (it should already exist)
        if !fileManager.fileExists(atPath: folderPath) {
            logger.warning("⚠️ Vehicle folder doesn't exist, creating: \(folderPath)")
            try fileManager.createDirectoryCoordinated(at: folderURL)
        }

        let fileURL = folderURL.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            logger.info("💾 JSON file saved: \(fileURL.path)")
        } catch {
            logger.error("❌ Failed to save JSON file: \(error.localizedDescription)")
            throw StorageError.fileSaveFailed(filename)
        }
    }

    /// Migrates all content from the old storage location to the new one by moving (not copying)
    /// - Parameters:
    ///   - oldURL: The current root URL (must be accessed with security-scoped resource)
    ///   - newURL: The new root URL to migrate content to
    /// - Throws: StorageError if migration fails
    func migrateContent(from oldURL: URL, to newURL: URL) async throws {
        logger.info("🚚 Starting content migration (MOVE mode)...")
        logger.info("   ├─ From: \(oldURL.path)")
        logger.info("   └─ To: \(newURL.path)")

        let oldVehiclesURL = oldURL.appendingPathComponent(AppConstants.vehiclesDirectoryName)
        let newVehiclesURL = newURL.appendingPathComponent(AppConstants.vehiclesDirectoryName)

        // Check if old vehicles directory exists
        guard fileManager.fileExists(atPath: oldVehiclesURL.path) else {
            logger.warning("⚠️ Old vehicles directory doesn't exist, skipping migration")
            return
        }

        // Get all vehicle folders from old location
        let vehicleFolders = try fileManager.contentsOfDirectory(
            at: oldVehiclesURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        guard !vehicleFolders.isEmpty else {
            logger.info("📭 No vehicles to migrate (empty folder)")
            return
        }

        logger.info("📦 Found \(vehicleFolders.count) vehicle folder(s) to migrate")

        var errors: [String] = []

        // Move each vehicle folder
        for (index, oldVehicleFolder) in vehicleFolders.enumerated() {
            let vehicleName = oldVehicleFolder.lastPathComponent
            let newVehicleFolder = newVehiclesURL.appendingPathComponent(vehicleName)

            logger.info("📁 [\(index + 1)/\(vehicleFolders.count)] Moving: \(vehicleName)")

            do {
                // Move the entire vehicle folder (atomic operation)
                try fileManager.moveItem(at: oldVehicleFolder, to: newVehicleFolder)
                logger.info("   ✅ Moved successfully")
            } catch {
                let errorMsg = "Failed to move \(vehicleName): \(error.localizedDescription)"
                logger.error("   ❌ \(errorMsg)")
                errors.append(errorMsg)
            }
        }

        // If ANY error occurred, throw
        if !errors.isEmpty {
            let errorMessage = errors.joined(separator: "\n")
            logger.error("❌ Migration failed with errors:\n\(errorMessage)")
            throw StorageError.migrationFailed(errorMessage)
        }

        logger.info("✅ Content migration completed successfully")
    }

    /// Deletes the old Vehicles directory after successful migration
    /// - Parameter url: The root URL of the old storage location
    func deleteOldVehiclesDirectory(at url: URL) async throws {
        let vehiclesURL = url.appendingPathComponent(AppConstants.vehiclesDirectoryName)

        guard fileManager.fileExists(atPath: vehiclesURL.path) else {
            logger.info("📭 Old vehicles directory already deleted or doesn't exist")
            return
        }

        do {
            try fileManager.removeItem(at: vehiclesURL)
            logger.info("🗑️ Old vehicles directory deleted successfully")
        } catch {
            logger.error("❌ Failed to delete old vehicles directory: \(error.localizedDescription)")
            throw StorageError.deletionFailed(error.localizedDescription)
        }
    }

    /// Stops accessing the current security-scoped resource without clearing the bookmark
    /// This is useful when migrating to a new storage location
    func stopCurrentSecurityScopedAccess() async {
        if isAccessingSecurityScopedResource, let url = rootURL {
            url.stopAccessingSecurityScopedResource()
            isAccessingSecurityScopedResource = false
            logger.info("🔓 Stopped accessing security-scoped resource for migration")
        }
    }

    /// Resets the storage configuration (removes the bookmark)
    func resetStorage() async {
        logger.info("🔄 Resetting storage configuration...")

        // Stop accessing the security-scoped resource if we're currently accessing it
        if isAccessingSecurityScopedResource, let url = rootURL {
            url.stopAccessingSecurityScopedResource()
            isAccessingSecurityScopedResource = false
            logger.debug("✅ Stopped accessing security-scoped resource")
        }

        // Remove the bookmark from UserDefaults
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.storageBookmark)
        userDefaults.synchronize()

        // Clear the root URL
        self.rootURL = nil

        logger.info("✅ Storage configuration reset")
    }

    /// Returns the vehicles directory URL
    /// Note: The directory is created when storage is first configured or restored
    /// - Returns: The vehicles directory URL
    /// - Throws: StorageError if not configured
    func getVehiclesDirectory() async throws -> URL {
        guard let rootURL = rootURL else {
            logger.error("❌ Cannot get vehicles directory - storage not configured")
            throw StorageError.notConfigured
        }

        return rootURL.appendingPathComponent(AppConstants.vehiclesDirectoryName)
    }

    // MARK: - Cleanup

    deinit {
        // If we're still accessing a security-scoped resource, stop it
        if isAccessingSecurityScopedResource, let url = rootURL {
            url.stopAccessingSecurityScopedResource()
            logger.debug("🧹 Cleanup: Stopped accessing security-scoped resource in deinit")
        }
    }
}
