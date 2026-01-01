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
    func save(image: UIImage, for vehicleId: String, metadata: DocumentMetadata) async throws -> Document
    func save(fileURL: URL, for vehicleId: String, metadata: DocumentMetadata) async throws -> Document
    func update(_ document: Document, for vehicleId: String) async throws
    func delete(_ documentId: String, for vehicleId: String) async throws
    func replacePhoto(_ documentId: String, for vehicleId: String, with newImage: UIImage) async throws
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
    @Dependency(\.documentDatabaseRepository) var documentDbRepo
    @Dependency(\.storageManager) var storageManager

    // MARK: - Paths

    private var vehiclesDirectory: URL {
        get async throws {
            try await storageManager.getVehiclesDirectory()
        }
    }

    // MARK: - Public Methods

    func save(image: UIImage, for vehicleId: String, metadata: DocumentMetadata) async throws -> Document {
        logger.info("💾 Sauvegarde d'un document image pour le véhicule: \(vehicleId)")

        guard let vehicle = try await vehicleRepository.getVehicle(vehicleId) else {
            throw RepositoryError.notFound("Véhicule \(vehicleId) introuvable")
        }

        // Generate unique filename
        let filename = generateFilename(extension: "jpg")
        let vehicleDirectoryURL = try await vehicleDirectory(for: vehicle)
        let imageFileURL = vehicleDirectoryURL.appendingPathComponent(filename)

        // Create document object AVANT la transaction
        let document = Document(
            fileURL: imageFileURL.path,
            name: metadata.name,
            date: metadata.date,
            mileage: metadata.mileage,
            type: metadata.type,
            amount: metadata.amount
        )

        // ✅ TRANSACTION ATOMIQUE : File + Database
        do {
            // 1. Save physical file
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw RepositoryError.invalidData("Impossible de convertir l'image en JPEG")
            }
            try imageData.write(to: imageFileURL)
            logger.info("📄 Image sauvegardée: \(imageFileURL.lastPathComponent)")

            // 2. Save to database
            try await documentDbRepo.create(document, vehicleId)
            logger.info("💾 Metadata sauvegardée en BDD")

        } catch {
            // Rollback : delete physical file if DB insert failed
            try? fileManager.safelyDelete(at: imageFileURL)
            logger.error("❌ Erreur lors de la sauvegarde : \(error.localizedDescription)")
            throw error
        }

        logger.info("✅ Document image sauvegardé avec succès")
        return document
    }

    func save(fileURL: URL, for vehicleId: String, metadata: DocumentMetadata) async throws -> Document {
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

        // Create document object
        let document = Document(
            fileURL: destinationFileURL.path,
            name: metadata.name,
            date: metadata.date,
            mileage: metadata.mileage,
            type: metadata.type,
            amount: metadata.amount
        )

        // ✅ TRANSACTION ATOMIQUE : File + Database
        do {
            // 1. Copy file with security-scoped access
            let hasAccess = fileURL.startAccessingSecurityScopedResource()
            defer {
                if hasAccess {
                    fileURL.stopAccessingSecurityScopedResource()
                }
            }

            try fileManager.copyItem(at: fileURL, to: destinationFileURL)
            logger.info("📄 Fichier copié: \(destinationFileURL.lastPathComponent)")

            // 2. Save to database
            try await documentDbRepo.create(document, vehicleId)
            logger.info("💾 Metadata sauvegardée en BDD")

        } catch {
            // Rollback : delete physical file if DB insert failed
            try? fileManager.safelyDelete(at: destinationFileURL)
            logger.error("❌ Erreur lors de la sauvegarde : \(error.localizedDescription)")
            throw error
        }

        logger.info("✅ Document fichier sauvegardé avec succès")
        return document
    }

    func update(_ document: Document, for vehicleId: String) async throws {
        logger.info("📝 Mise à jour du document \(document.id)")

        // ✅ Mise à jour DIRECTE en BDD (pas besoin de passer par Vehicle)
        try await documentDbRepo.update(document, vehicleId)

        logger.info("✅ Document mis à jour avec succès")
    }

    func delete(_ documentId: String, for vehicleId: String) async throws {
        logger.info("🗑️ Suppression du document: \(documentId)")

        guard let vehicle = try await vehicleRepository.getVehicle(vehicleId) else {
            throw RepositoryError.notFound("Véhicule \(vehicleId) introuvable")
        }

        // Fetch document to get file path
        let folderPath = "\(vehicle.brand)\(vehicle.model)"
        guard let document = try await documentDbRepo.fetch(documentId, folderPath) else {
            throw RepositoryError.notFound("Document \(documentId) introuvable")
        }

        // ✅ TRANSACTION ATOMIQUE : Database + File
        let fileURL = URL(fileURLWithPath: document.fileURL)

        do {
            // 1. Delete from database first (safer rollback)
            try await documentDbRepo.delete(documentId)
            logger.info("💾 Metadata supprimée de la BDD")

            // 2. Delete physical file
            try fileManager.safelyDelete(at: fileURL)
            logger.info("📄 Fichier supprimé: \(document.fileURL)")

        } catch {
            logger.error("❌ Erreur lors de la suppression : \(error.localizedDescription)")
            throw error
        }

        logger.info("✅ Document supprimé avec succès")
    }

    func replacePhoto(_ documentId: String, for vehicleId: String, with newImage: UIImage) async throws {
        logger.info("📸 Remplacement de la photo du document: \(documentId)")

        guard let vehicle = try await vehicleRepository.getVehicle(vehicleId) else {
            throw RepositoryError.notFound("Véhicule \(vehicleId) introuvable")
        }

        let folderPath = "\(vehicle.brand)\(vehicle.model)"
        guard var document = try await documentDbRepo.fetch(documentId, folderPath) else {
            throw RepositoryError.notFound("Document \(documentId) introuvable")
        }

        let oldFileURL = URL(fileURLWithPath: document.fileURL)

        // Generate new unique filename
        let filename = generateFilename(extension: "jpg")
        let vehicleDirectoryURL = try await vehicleDirectory(for: vehicle)
        let newFileURL = vehicleDirectoryURL.appendingPathComponent(filename)

        guard oldFileURL.path != newFileURL.path else {
            throw RepositoryError.invalidData("Nouveau nom de fichier identique à l'ancien")
        }

        // ✅ TRANSACTION ATOMIQUE : File + Database
        do {
            // 1. Save new image
            guard let imageData = newImage.jpegData(compressionQuality: 0.8) else {
                throw RepositoryError.invalidData("Impossible de convertir l'image en JPEG")
            }
            try imageData.write(to: newFileURL)
            logger.info("💾 Nouvelle image sauvegardée: \(newFileURL.lastPathComponent)")

            // 2. Update document in database
            document.fileURL = newFileURL.path
            try await documentDbRepo.update(document, vehicleId)
            logger.info("💾 Metadata mise à jour en BDD")

            // 3. Delete old file (after success)
            try fileManager.safelyDelete(at: oldFileURL)
            logger.info("🗑️ Ancienne image supprimée: \(oldFileURL.lastPathComponent)")

        } catch {
            // Rollback : delete new file if created
            try? fileManager.safelyDelete(at: newFileURL)
            logger.error("❌ Erreur lors du remplacement : \(error.localizedDescription)")
            throw error
        }

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
