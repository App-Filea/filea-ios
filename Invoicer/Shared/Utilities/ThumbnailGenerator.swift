//
//  ThumbnailGenerator.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Utility for generating thumbnails from file URLs
//

import UIKit
@preconcurrency import QuickLook

/// Utility for generating thumbnails from files using QuickLook
@MainActor
final class ThumbnailGenerator {
    // MARK: - Singleton

    static let shared = ThumbnailGenerator()

    private init() {}

    // MARK: - Public Methods

    /// Generates a thumbnail for the file at the given URL
    /// - Parameters:
    ///   - fileURL: The URL of the file
    ///   - size: The desired thumbnail size
    ///   - scale: The scale factor (defaults to screen scale)
    /// - Returns: The generated thumbnail image, or nil if generation fails
    func generateThumbnail(
        for fileURL: String,
        size: CGSize,
        scale: CGFloat? = nil
    ) async -> UIImage? {
        let url = URL(fileURLWithPath: fileURL)
        let screenScale = await UIScreen.main.scale
        let actualScale = scale ?? screenScale

        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: size,
            scale: actualScale,
            representationTypes: .thumbnail
        )

        let generator = QLThumbnailGenerator.shared

        do {
            let representation = try await generator.generateBestRepresentation(for: request)
            return representation.uiImage
        } catch {
            print("❌ Failed to generate thumbnail for \(fileURL): \(error.localizedDescription)")
            return nil
        }
    }

    /// Generates a thumbnail with standard size for document previews (60x80)
    /// - Parameter fileURL: The URL of the file
    /// - Returns: The generated thumbnail image, or nil if generation fails
    func generateDocumentThumbnail(for fileURL: String) async -> UIImage? {
        await generateThumbnail(
            for: fileURL,
            size: CGSize(width: 60, height: 80)
        )
    }

    /// Generates a thumbnail with large size for detail views (200x267)
    /// - Parameter fileURL: The URL of the file
    /// - Returns: The generated thumbnail image, or nil if generation fails
    func generateLargeThumbnail(for fileURL: String) async -> UIImage? {
        await generateThumbnail(
            for: fileURL,
            size: CGSize(width: 200, height: 267)
        )
    }

    /// Generates a square thumbnail for grid views
    /// - Parameters:
    ///   - fileURL: The URL of the file
    ///   - size: The side length of the square thumbnail
    /// - Returns: The generated thumbnail image, or nil if generation fails
    func generateSquareThumbnail(
        for fileURL: String,
        size: CGFloat = 100
    ) async -> UIImage? {
        await generateThumbnail(
            for: fileURL,
            size: CGSize(width: size, height: size)
        )
    }
}

// MARK: - Thumbnail Sizes

extension ThumbnailGenerator {
    /// Standard thumbnail sizes
    enum Size {
        /// Small thumbnail (60x80) - for list items
        static let small = CGSize(width: 60, height: 80)

        /// Medium thumbnail (120x160) - for cards
        static let medium = CGSize(width: 120, height: 160)

        /// Large thumbnail (200x267) - for detail views
        static let large = CGSize(width: 200, height: 267)

        /// Square small (100x100) - for grid items
        static let squareSmall = CGSize(width: 100, height: 100)

        /// Square medium (150x150) - for grid items
        static let squareMedium = CGSize(width: 150, height: 150)

        /// Square large (200x200) - for detail views
        static let squareLarge = CGSize(width: 200, height: 200)
    }
}
