//
//  FileMetadataMappers.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 18/10/2025.
//

import Foundation

// MARK: - Document → FileMetadataRecord

extension Document {
    /// Convertit un Document (domain) vers un FileMetadataRecord (database)
    func toRecord(vehicleId: UUID) -> FileMetadataRecord {
        let url = URL(fileURLWithPath: fileURL)
        let fileName = url.lastPathComponent
        let relativePath = fileName // Pour l'instant, relatif au dossier véhicule

        return FileMetadataRecord(
            id: id,
            vehicleId: vehicleId,
            fileName: fileName,
            relativePath: relativePath,
            documentType: type.rawValue,
            documentName: name,
            date: date,
            mileage: mileage,
            amount: amount,
            fileSize: 0, // À calculer si nécessaire
            mimeType: inferMimeType(from: fileName),
            createdAt: Date(),
            modifiedAt: Date()
        )
    }

    /// Infère le type MIME à partir de l'extension du fichier
    private func inferMimeType(from fileName: String) -> String {
        let url = URL(fileURLWithPath: fileName)
        let pathExtension = url.pathExtension.lowercased()

        switch pathExtension {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "pdf":
            return "application/pdf"
        case "heic":
            return "image/heic"
        case "heif":
            return "image/heif"
        default:
            return "application/octet-stream"
        }
    }
}

// MARK: - FileMetadataRecord → Document

extension FileMetadataRecord {
    /// Convertit un FileMetadataRecord (database) vers un Document (domain)
    func toDomain(vehicleFolderPath: String) -> Document {
        let fullPath = URL(fileURLWithPath: vehicleFolderPath)
            .appendingPathComponent(relativePath)
            .path

        return Document(
            fileURL: fullPath,
            name: documentName,
            date: date,
            mileage: mileage,
            type: DocumentType(rawValue: documentType) ?? .autre,
            amount: amount
        )
    }
}

// MARK: - Document → FileMetadataDTO

extension Document {
    /// Convertit un Document (domain) vers un FileMetadataDTO (transfer)
    func toDTO() -> FileMetadataDTO {
        let url = URL(fileURLWithPath: fileURL)
        let fileName = url.lastPathComponent
        let relativePath = fileName

        return FileMetadataDTO(
            id: id,
            fileName: fileName,
            relativePath: relativePath,
            documentType: type.rawValue,
            documentName: name,
            date: date,
            mileage: mileage,
            amount: amount,
            fileSize: 0,
            mimeType: inferMimeType(from: fileName),
            createdAt: Date(),
            modifiedAt: Date()
        )
    }
}

// MARK: - FileMetadataDTO → Document

extension FileMetadataDTO {
    /// Convertit un FileMetadataDTO (transfer) vers un Document (domain)
    func toDomain(vehicleFolderPath: String) -> Document {
        let fullPath = URL(fileURLWithPath: vehicleFolderPath)
            .appendingPathComponent(relativePath)
            .path

        return Document(
            fileURL: fullPath,
            name: documentName,
            date: date,
            mileage: mileage,
            type: DocumentType(rawValue: documentType) ?? .autre,
            amount: amount
        )
    }
}

// MARK: - FileMetadataRecord → FileMetadataDTO

extension FileMetadataRecord {
    /// Convertit un FileMetadataRecord (database) vers un FileMetadataDTO (transfer)
    func toDTO() -> FileMetadataDTO {
        return FileMetadataDTO(
            id: id,
            fileName: fileName,
            relativePath: relativePath,
            documentType: documentType,
            documentName: documentName,
            date: date,
            mileage: mileage,
            amount: amount,
            fileSize: fileSize,
            mimeType: mimeType,
            createdAt: createdAt,
            modifiedAt: modifiedAt
        )
    }
}

// MARK: - FileMetadataDTO → FileMetadataRecord

extension FileMetadataDTO {
    /// Convertit un FileMetadataDTO (transfer) vers un FileMetadataRecord (database)
    func toRecord(vehicleId: UUID) -> FileMetadataRecord {
        return FileMetadataRecord(
            id: id,
            vehicleId: vehicleId,
            fileName: fileName,
            relativePath: relativePath,
            documentType: documentType,
            documentName: documentName,
            date: date,
            mileage: mileage,
            amount: amount,
            fileSize: fileSize,
            mimeType: mimeType,
            createdAt: createdAt,
            modifiedAt: modifiedAt
        )
    }
}
