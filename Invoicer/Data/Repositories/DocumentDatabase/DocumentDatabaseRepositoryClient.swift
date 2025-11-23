//
//  DocumentDatabaseRepositoryClient.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 23/01/2025.
//

import Foundation
import Dependencies

// MARK: - Repository Client

/// Client interface for document database repository operations
/// Delegates to DocumentDatabaseRepository actor for actual implementation
struct DocumentDatabaseRepositoryClient: Sendable {
    var create: @Sendable (Document, UUID) async throws -> Void
    var createBatch: @Sendable ([Document], UUID) async throws -> Void
    var fetchAll: @Sendable (UUID, String) async throws -> [Document]
    var fetch: @Sendable (UUID, String) async throws -> Document?
    var count: @Sendable (UUID) async throws -> Int
    var update: @Sendable (Document, UUID) async throws -> Void
    var delete: @Sendable (UUID) async throws -> Void
    var deleteAll: @Sendable (UUID) async throws -> Void
}

// MARK: - Dependency Key

extension DocumentDatabaseRepositoryClient: DependencyKey {
    static var liveValue: DocumentDatabaseRepositoryClient {
        @Dependency(\.database) var database
        let repository = DocumentDatabaseRepository(database: database)

        return DocumentDatabaseRepositoryClient(
            create: { document, vehicleId in
                try await repository.create(document: document, vehicleId: vehicleId)
            },
            createBatch: { documents, vehicleId in
                try await repository.createBatch(documents: documents, vehicleId: vehicleId)
            },
            fetchAll: { vehicleId, vehicleFolderPath in
                try await repository.fetchAll(vehicleId: vehicleId, vehicleFolderPath: vehicleFolderPath)
            },
            fetch: { id, vehicleFolderPath in
                try await repository.fetch(id: id, vehicleFolderPath: vehicleFolderPath)
            },
            count: { vehicleId in
                try await repository.count(vehicleId: vehicleId)
            },
            update: { document, vehicleId in
                try await repository.update(document: document, vehicleId: vehicleId)
            },
            delete: { id in
                try await repository.delete(id: id)
            },
            deleteAll: { vehicleId in
                try await repository.deleteAll(vehicleId: vehicleId)
            }
        )
    }

    static nonisolated(unsafe) var testValue = DocumentDatabaseRepositoryClient(
        create: { _, _ in },
        createBatch: { _, _ in },
        fetchAll: { _, _ in [] },
        fetch: { _, _ in nil },
        count: { _ in 0 },
        update: { _, _ in },
        delete: { _ in },
        deleteAll: { _ in }
    )

    static nonisolated(unsafe) var previewValue = DocumentDatabaseRepositoryClient(
        create: { _, _ in },
        createBatch: { _, _ in },
        fetchAll: { _, _ in
            [
                Document(
                    fileURL: "/path/to/document.jpg",
                    name: "Vidange",
                    date: Date(),
                    mileage: "15000",
                    type: .entretien,
                    amount: 80.0
                ),
                Document(
                    fileURL: "/path/to/document2.pdf",
                    name: "Assurance",
                    date: Date(),
                    mileage: "15500",
                    type: .assurance,
                    amount: 350.0
                )
            ]
        },
        fetch: { _, _ in
            Document(
                fileURL: "/path/to/document.jpg",
                name: "Vidange",
                date: Date(),
                mileage: "15000",
                type: .entretien,
                amount: 80.0
            )
        },
        count: { _ in 2 },
        update: { _, _ in },
        delete: { _ in },
        deleteAll: { _ in }
    )
}

// MARK: - Dependency Values Extension

extension DependencyValues {
    var documentDatabaseRepository: DocumentDatabaseRepositoryClient {
        get { self[DocumentDatabaseRepositoryClient.self] }
        set { self[DocumentDatabaseRepositoryClient.self] = newValue }
    }
}
