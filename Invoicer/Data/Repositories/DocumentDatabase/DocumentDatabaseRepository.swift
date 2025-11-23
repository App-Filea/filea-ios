//
//  DocumentDatabaseRepository.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 23/01/2025.
//

import Foundation
import GRDB

/// Repository GRDB pour la gestion des FileMetadataRecord
/// Gère UNIQUEMENT les opérations CRUD sur la table FileMetadataRecord
actor DocumentDatabaseRepository {
    private let database: DatabaseManager

    init(database: DatabaseManager) {
        self.database = database
    }

    // MARK: - Create

    /// Ajoute un nouveau document en base de données
    /// - Parameters:
    ///   - document: Le document à sauvegarder
    ///   - vehicleId: L'identifiant du véhicule associé
    func create(document: Document, vehicleId: UUID) async throws {
        print("➕ [DocumentDatabaseRepository] Création d'un document en BDD")
        print("   ├─ Document ID : \(document.id)")
        print("   ├─ Nom : \(document.name)")
        print("   └─ Véhicule ID : \(vehicleId)")

        let record = document.toRecord(vehicleId: vehicleId)

        try await database.write { db in
            try FileMetadataRecord.insert { record }.execute(db)
        }

        print("✅ [DocumentDatabaseRepository] Document créé en BDD\n")
    }

    /// Ajoute plusieurs documents en une seule transaction (bulk insert)
    /// - Parameters:
    ///   - documents: Les documents à sauvegarder
    ///   - vehicleId: L'identifiant du véhicule associé
    func createBatch(documents: [Document], vehicleId: UUID) async throws {
        print("➕ [DocumentDatabaseRepository] Création de \(documents.count) documents en BDD")
        print("   └─ Véhicule ID : \(vehicleId)")

        let records = documents.map { $0.toRecord(vehicleId: vehicleId) }

        try await database.write { db in
            for record in records {
                try FileMetadataRecord.insert { record }.execute(db)
            }
        }

        print("✅ [DocumentDatabaseRepository] \(documents.count) documents créés en BDD\n")
    }

    // MARK: - Read

    /// Récupère tous les documents d'un véhicule
    /// - Parameters:
    ///   - vehicleId: L'identifiant du véhicule
    ///   - vehicleFolderPath: Le chemin du dossier du véhicule (pour reconstruire les paths complets)
    /// - Returns: Liste des documents triés par date décroissante
    func fetchAll(vehicleId: UUID, vehicleFolderPath: String) async throws -> [Document] {
        print("📖 [DocumentDatabaseRepository] Récupération des documents")
        print("   └─ Véhicule ID : \(vehicleId)")

        let documents = try await database.read { db in
            let records = try FileMetadataRecord
                .where { $0.vehicleId.in([vehicleId]) }
                .order { $0.date.desc() }
                .fetchAll(db)

            return records.map { $0.toDomain(vehicleFolderPath: vehicleFolderPath) }
        }

        print("✅ [DocumentDatabaseRepository] \(documents.count) documents récupérés\n")
        return documents
    }

    /// Récupère un document spécifique
    /// - Parameters:
    ///   - id: L'identifiant du document
    ///   - vehicleFolderPath: Le chemin du dossier du véhicule
    /// - Returns: Le document ou nil s'il n'existe pas
    func fetch(id: UUID, vehicleFolderPath: String) async throws -> Document? {
        print("📖 [DocumentDatabaseRepository] Récupération d'un document")
        print("   └─ Document ID : \(id)")

        let document = try await database.read { db in
            let record = try FileMetadataRecord
                .where { $0.id.in([id]) }
                .fetchOne(db)

            return record?.toDomain(vehicleFolderPath: vehicleFolderPath)
        }

        if document != nil {
            print("✅ [DocumentDatabaseRepository] Document trouvé\n")
        } else {
            print("⚠️ [DocumentDatabaseRepository] Document non trouvé\n")
        }

        return document
    }

    /// Compte le nombre de documents d'un véhicule
    /// - Parameter vehicleId: L'identifiant du véhicule
    /// - Returns: Le nombre de documents
    func count(vehicleId: UUID) async throws -> Int {
        try await database.read { db in
            try FileMetadataRecord
                .where { $0.vehicleId.in([vehicleId]) }
                .fetchCount(db)
        }
    }

    // MARK: - Update

    /// Met à jour un document existant
    /// - Parameters:
    ///   - document: Le document avec les nouvelles valeurs
    ///   - vehicleId: L'identifiant du véhicule associé
    func update(document: Document, vehicleId: UUID) async throws {
        print("✏️ [DocumentDatabaseRepository] Mise à jour d'un document")
        print("   ├─ Document ID : \(document.id)")
        print("   └─ Nom : \(document.name)")

        var record = document.toRecord(vehicleId: vehicleId)
        record.modifiedAt = Date()

        try await database.write { db in
            try FileMetadataRecord.upsert { record }.execute(db)
        }

        print("✅ [DocumentDatabaseRepository] Document mis à jour\n")
    }

    // MARK: - Delete

    /// Supprime un document spécifique
    /// - Parameter id: L'identifiant du document à supprimer
    func delete(id: UUID) async throws {
        print("🗑️ [DocumentDatabaseRepository] Suppression d'un document")
        print("   └─ Document ID : \(id)")

        try await database.write { db in
            try FileMetadataRecord.where { $0.id.in([id]) }.delete().execute(db)
        }

        print("✅ [DocumentDatabaseRepository] Document supprimé\n")
    }

    /// Supprime tous les documents d'un véhicule (cascade delete)
    /// - Parameter vehicleId: L'identifiant du véhicule
    func deleteAll(vehicleId: UUID) async throws {
        print("🗑️ [DocumentDatabaseRepository] Suppression de tous les documents d'un véhicule")
        print("   └─ Véhicule ID : \(vehicleId)")

        try await database.write { db in
            try FileMetadataRecord
                .where { $0.vehicleId.in([vehicleId]) }
                .delete()
                .execute(db)
        }

        print("✅ [DocumentDatabaseRepository] Tous les documents supprimés\n")
    }
}
