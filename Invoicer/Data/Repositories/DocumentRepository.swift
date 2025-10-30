//
//  DocumentRepository.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Repository for document CRUD operations
//

import Foundation
import UIKit
import Dependencies
import os.log

// MARK: - Protocol

protocol DocumentRepositoryProtocol: Sendable {
    func save(image: UIImage, for vehicleId: UUID, metadata: DocumentMetadata) async throws -> Document
    func save(fileURL: URL, for vehicleId: UUID, metadata: DocumentMetadata) async throws -> Document
    func update(_ document: Document, for vehicleId: UUID) async throws
    func delete(_ documentId: UUID, for vehicleId: UUID) async throws
    func replacePhoto(_ documentId: UUID, for vehicleId: UUID, with newImage: UIImage) async throws
}

// MARK: - Document Metadata

struct DocumentMetadata: Sendable {
    let name: String
    let date: Date
    let mileage: String
    let type: DocumentType
    let amount: Double?
}

// MARK: - Dependency Registration

extension DependencyValues {
    var documentRepository: DocumentRepositoryProtocol {
        get { self[DocumentRepositoryKey.self] }
        set { self[DocumentRepositoryKey.self] = newValue }
    }
}

private enum DocumentRepositoryKey: DependencyKey {
    static let liveValue: DocumentRepositoryProtocol = DocumentRepository()
}

// MARK: - Implementation

final class DocumentRepository: DocumentRepositoryProtocol, @unchecked Sendable {
    private let logger = Logger(subsystem: AppConstants.bundleIdentifier, category: "DocumentRepository")
    private let fileManager = FileManager.default

    @Dependency(\.vehicleRepository) var vehicleRepository
    @Dependency(\.storageManager) var storageManager

    // MARK: - Paths

    private var vehiclesDirectory: URL {
        get async throws {
            try await storageManager.getVehiclesDirectory()
        }
    }

    // MARK: - Public Methods

    func save(image: UIImage, for vehicleId: UUID, metadata: DocumentMetadata) async throws -> Document {
        logger.info("💾 Sauvegarde d'un document image pour le véhicule: \(vehicleId)")

        guard let vehicle = try await vehicleRepository.getVehicle(vehicleId) else {
            throw RepositoryError.notFound("Véhicule \(vehicleId) introuvable")
        }

        // Generate unique filename
        let filename = generateFilename(extension: "jpg")
        let vehicleDirectoryURL = try await vehicleDirectory(for: vehicle)
        let imageFileURL = vehicleDirectoryURL.appendingPathComponent(filename)

        // Save image to disk
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw RepositoryError.invalidData("Impossible de convertir l'image en JPEG")
        }

        try imageData.write(to: imageFileURL)
        logger.info("📄 Image sauvegardée: \(imageFileURL.lastPathComponent)")

        // Create document object
        let document = Document(
            fileURL: imageFileURL.path,
            name: metadata.name,
            date: metadata.date,
            mileage: metadata.mileage,
            type: metadata.type,
            amount: metadata.amount
        )

        // Add document to vehicle
        var updatedVehicle = vehicle
        updatedVehicle.documents.append(document)
        try await vehicleRepository.updateVehicle(updatedVehicle)

        logger.info("✅ Document image sauvegardé avec succès")
        return document
    }

    func save(fileURL: URL, for vehicleId: UUID, metadata: DocumentMetadata) async throws -> Document {
        logger.info("💾 Sauvegarde d'un fichier document pour le véhicule: \(vehicleId)")
        logger.info("📄 Fichier source: \(fileURL.lastPathComponent)")

        guard let vehicle = try await vehicleRepository.getVehicle(vehicleId) else {
            throw RepositoryError.notFound("Véhicule \(vehicleId) introuvable")
        }

        // Generate unique filename with original extension
        let fileExtension = fileURL.pathExtension
        let filename = generateFilename(extension: fileExtension)
        let vehicleDirectoryURL = try await vehicleDirectory(for: vehicle)
        let destinationFileURL = vehicleDirectoryURL.appendingPathComponent(filename)

        // Copy file with security-scoped access
        let hasAccess = fileURL.startAccessingSecurityScopedResource()
        defer {
            if hasAccess {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        try fileManager.copyItem(at: fileURL, to: destinationFileURL)
        logger.info("📄 Fichier copié: \(destinationFileURL.lastPathComponent)")

        // Create document object
        let document = Document(
            fileURL: destinationFileURL.path,
            name: metadata.name,
            date: metadata.date,
            mileage: metadata.mileage,
            type: metadata.type,
            amount: metadata.amount
        )

        // Add document to vehicle
        var updatedVehicle = vehicle
        updatedVehicle.documents.append(document)
        try await vehicleRepository.updateVehicle(updatedVehicle)

        logger.info("✅ Document fichier sauvegardé avec succès")
        return document
    }

    func update(_ document: Document, for vehicleId: UUID) async throws {
        logger.info("📝 Mise à jour du document \(document.id)")

        guard var vehicle = try await vehicleRepository.getVehicle(vehicleId) else {
            throw RepositoryError.notFound("Véhicule \(vehicleId) introuvable")
        }

        guard let documentIndex = vehicle.documents.firstIndex(where: { $0.id == document.id }) else {
            throw RepositoryError.notFound("Document \(document.id) introuvable")
        }

        vehicle.documents[documentIndex] = document
        try await vehicleRepository.updateVehicle(vehicle)

        logger.info("✅ Document mis à jour avec succès")
    }

    func delete(_ documentId: UUID, for vehicleId: UUID) async throws {
        logger.info("🗑️ Suppression du document: \(documentId)")

        guard var vehicle = try await vehicleRepository.getVehicle(vehicleId) else {
            throw RepositoryError.notFound("Véhicule \(vehicleId) introuvable")
        }

        guard let documentIndex = vehicle.documents.firstIndex(where: { $0.id == documentId }) else {
            throw RepositoryError.notFound("Document \(documentId) introuvable")
        }

        let document = vehicle.documents[documentIndex]

        // Delete physical file
        let fileURL = URL(fileURLWithPath: document.fileURL)
        try fileManager.safelyDelete(at: fileURL)
        logger.info("📄 Fichier supprimé: \(document.fileURL)")

        // Remove document from vehicle
        vehicle.documents.remove(at: documentIndex)
        try await vehicleRepository.updateVehicle(vehicle)

        logger.info("✅ Document supprimé avec succès")
    }

    func replacePhoto(_ documentId: UUID, for vehicleId: UUID, with newImage: UIImage) async throws {
        logger.info("📸 Remplacement de la photo du document: \(documentId)")

        guard var vehicle = try await vehicleRepository.getVehicle(vehicleId) else {
            throw RepositoryError.notFound("Véhicule \(vehicleId) introuvable")
        }

        guard let documentIndex = vehicle.documents.firstIndex(where: { $0.id == documentId }) else {
            throw RepositoryError.notFound("Document \(documentId) introuvable")
        }

        let document = vehicle.documents[documentIndex]
        let oldFileURL = URL(fileURLWithPath: document.fileURL)

        // Generate new unique filename
        let filename = generateFilename(extension: "jpg")
        let vehicleDirectoryURL = try await vehicleDirectory(for: vehicle)
        let newFileURL = vehicleDirectoryURL.appendingPathComponent(filename)

        // Ensure filenames are different
        guard oldFileURL.path != newFileURL.path else {
            throw RepositoryError.invalidData("Nouveau nom de fichier identique à l'ancien")
        }

        // Save new image
        guard let imageData = newImage.jpegData(compressionQuality: 0.8) else {
            throw RepositoryError.invalidData("Impossible de convertir l'image en JPEG")
        }

        try imageData.write(to: newFileURL)
        logger.info("💾 Nouvelle image sauvegardée: \(newFileURL.lastPathComponent)")

        // Delete old file
        try fileManager.safelyDelete(at: oldFileURL)
        logger.info("🗑️ Ancienne image supprimée: \(oldFileURL.lastPathComponent)")

        // Update document with new file path
        vehicle.documents[documentIndex].fileURL = newFileURL.path
        try await vehicleRepository.updateVehicle(vehicle)

        logger.info("✅ Photo remplacée avec succès")
    }

    // MARK: - Private Helpers

    private func vehicleDirectory(for vehicle: Vehicle) async throws -> URL {
        let vehiclesDir = try await vehiclesDirectory
        return vehiclesDir.appendingPathComponent("\(vehicle.brand)\(vehicle.model)")
    }

    private func generateFilename(extension fileExtension: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss-SSS"
        let timestamp = dateFormatter.string(from: Date())
        let uniqueId = UUID().uuidString.prefix(8)

        if fileExtension.isEmpty {
            return "document_\(timestamp)_\(uniqueId)"
        } else {
            return "document_\(timestamp)_\(uniqueId).\(fileExtension)"
        }
    }
}
