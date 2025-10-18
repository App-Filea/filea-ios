//
//  FileManager+Extensions.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  FileManager utility extensions
//

import Foundation

extension FileManager {
    // MARK: - Directory Helpers

    /// Returns the documents directory URL
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Returns the caches directory URL
    static var cachesDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    /// Returns the temporary directory URL
    static var tempDirectory: URL {
        FileManager.default.temporaryDirectory
    }

    // MARK: - File Operations

    /// Checks if a file exists at the given path
    func fileExists(at path: String) -> Bool {
        fileExists(atPath: path)
    }

    /// Checks if a file exists at the given URL
    func fileExists(at url: URL) -> Bool {
        fileExists(atPath: url.path)
    }

    /// Creates a directory if it doesn't exist
    /// - Parameters:
    ///   - url: The URL where the directory should be created
    ///   - createIntermediates: Whether to create intermediate directories
    /// - Throws: An error if directory creation fails
    func createDirectoryIfNeeded(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool = true
    ) throws {
        var isDirectory: ObjCBool = false
        let exists = fileExists(atPath: url.path, isDirectory: &isDirectory)

        if !exists {
            try createDirectory(
                at: url,
                withIntermediateDirectories: createIntermediates,
                attributes: nil
            )
        } else if !isDirectory.boolValue {
            throw FileManagerError.notADirectory(url)
        }
    }

    /// Creates a directory using NSFileCoordinator for File Provider compatibility
    /// Use this method when working with iCloud Drive, Google Drive, or other File Providers
    /// - Parameters:
    ///   - url: The URL where the directory should be created
    ///   - createIntermediates: Whether to create intermediate directories
    /// - Throws: An error if directory creation fails
    func createDirectoryCoordinated(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool = true
    ) throws {
        var isDirectory: ObjCBool = false
        let exists = fileExists(atPath: url.path, isDirectory: &isDirectory)

        if exists && isDirectory.boolValue {
            // Directory already exists
            return
        }

        if exists && !isDirectory.boolValue {
            throw FileManagerError.notADirectory(url)
        }

        // Use NSFileCoordinator for File Provider compatibility
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordinationError: NSError?
        var creationError: Error?

        coordinator.coordinate(
            writingItemAt: url,
            options: .forDeleting, // This tells the system we want write access
            error: &coordinationError
        ) { coordinatedURL in
            do {
                try createDirectory(
                    at: coordinatedURL,
                    withIntermediateDirectories: createIntermediates,
                    attributes: nil
                )
            } catch {
                creationError = error
            }
        }

        if let error = coordinationError {
            throw error
        }

        if let error = creationError {
            throw error
        }
    }

    /// Safely deletes a file or directory at the given URL
    /// - Parameter url: The URL of the file or directory to delete
    /// - Throws: An error if deletion fails
    func safelyDelete(at url: URL) throws {
        guard fileExists(at: url) else { return }
        try removeItem(at: url)
    }

    /// Copies a file to a destination, replacing if it exists
    /// - Parameters:
    ///   - sourceURL: The source file URL
    ///   - destinationURL: The destination URL
    /// - Throws: An error if the copy operation fails
    func copyFileReplacing(from sourceURL: URL, to destinationURL: URL) throws {
        // Delete destination if it exists
        try? safelyDelete(at: destinationURL)

        // Copy the file
        try copyItem(at: sourceURL, to: destinationURL)
    }

    /// Moves a file to a destination, replacing if it exists
    /// - Parameters:
    ///   - sourceURL: The source file URL
    ///   - destinationURL: The destination URL
    /// - Throws: An error if the move operation fails
    func moveFileReplacing(from sourceURL: URL, to destinationURL: URL) throws {
        // Delete destination if it exists
        try? safelyDelete(at: destinationURL)

        // Move the file
        try moveItem(at: sourceURL, to: destinationURL)
    }

    // MARK: - File Size

    /// Returns the size of a file in bytes
    /// - Parameter url: The file URL
    /// - Returns: The file size in bytes, or nil if it cannot be determined
    func fileSize(at url: URL) -> Int64? {
        guard let attributes = try? attributesOfItem(atPath: url.path) else {
            return nil
        }
        return attributes[.size] as? Int64
    }

    /// Returns a human-readable file size string
    /// - Parameter url: The file URL
    /// - Returns: A formatted file size string (e.g., "1.2 MB")
    func fileSizeString(at url: URL) -> String {
        guard let size = fileSize(at: url) else {
            return "Unknown"
        }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    // MARK: - Directory Contents

    /// Returns all file URLs in a directory
    /// - Parameters:
    ///   - url: The directory URL
    ///   - includingSubfolders: Whether to include files in subfolders
    /// - Returns: An array of file URLs
    func filesInDirectory(
        at url: URL,
        includingSubfolders: Bool = false
    ) throws -> [URL] {
        if includingSubfolders {
            guard let enumerator = enumerator(at: url, includingPropertiesForKeys: nil) else {
                return []
            }
            return enumerator.compactMap { $0 as? URL }
        } else {
            return try contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
        }
    }

    /// Returns the total size of a directory in bytes
    /// - Parameter url: The directory URL
    /// - Returns: The total size in bytes
    func directorySize(at url: URL) throws -> Int64 {
        let files = try filesInDirectory(at: url, includingSubfolders: true)
        return files.compactMap { fileSize(at: $0) }.reduce(0, +)
    }

    /// Returns a human-readable directory size string
    /// - Parameter url: The directory URL
    /// - Returns: A formatted size string (e.g., "12.5 MB")
    func directorySizeString(at url: URL) -> String {
        guard let size = try? directorySize(at: url) else {
            return "Unknown"
        }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    // MARK: - File Dates

    /// Returns the creation date of a file
    /// - Parameter url: The file URL
    /// - Returns: The creation date, or nil if it cannot be determined
    func creationDate(of url: URL) -> Date? {
        guard let attributes = try? attributesOfItem(atPath: url.path) else {
            return nil
        }
        return attributes[.creationDate] as? Date
    }

    /// Returns the modification date of a file
    /// - Parameter url: The file URL
    /// - Returns: The modification date, or nil if it cannot be determined
    func modificationDate(of url: URL) -> Date? {
        guard let attributes = try? attributesOfItem(atPath: url.path) else {
            return nil
        }
        return attributes[.modificationDate] as? Date
    }
}

// MARK: - FileManager Errors

enum FileManagerError: LocalizedError {
    case notADirectory(URL)
    case fileNotFound(URL)
    case copyFailed(source: URL, destination: URL, underlying: Error)
    case moveFailed(source: URL, destination: URL, underlying: Error)

    var errorDescription: String? {
        switch self {
        case .notADirectory(let url):
            return "Le chemin '\(url.lastPathComponent)' n'est pas un répertoire"
        case .fileNotFound(let url):
            return "Fichier introuvable: '\(url.lastPathComponent)'"
        case .copyFailed(let source, let destination, let error):
            return "Échec de la copie de '\(source.lastPathComponent)' vers '\(destination.lastPathComponent)': \(error.localizedDescription)"
        case .moveFailed(let source, let destination, let error):
            return "Échec du déplacement de '\(source.lastPathComponent)' vers '\(destination.lastPathComponent)': \(error.localizedDescription)"
        }
    }
}
