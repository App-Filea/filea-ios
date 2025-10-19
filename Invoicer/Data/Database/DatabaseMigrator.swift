//
//  DatabaseMigrator.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 18/10/2025.
//

import Foundation
import GRDB

/// Gestionnaire de migrations pour la base de données
enum DatabaseMigrator {
    /// Configure toutes les migrations de la base de données
    static func setupMigrations() -> GRDB.DatabaseMigrator {
        var migrator = GRDB.DatabaseMigrator()

        // MARK: - Migration v1.0: Tables initiales

        migrator.registerMigration("v1.0_create_vehicles_table") { db in
            try db.create(table: "vehicleRecord") { table in
                table.primaryKey("id", .blob).notNull()
                table.column("type", .text).notNull()
                table.column("brand", .text).notNull()
                table.column("model", .text).notNull()
                table.column("mileage", .text)
                table.column("registrationDate", .datetime).notNull()
                table.column("plate", .text).notNull()
                table.column("isPrimary", .boolean).notNull().defaults(to: false)
                table.column("folderPath", .text).notNull()
                table.column("createdAt", .datetime).notNull()
                table.column("updatedAt", .datetime).notNull()
            }

            // Index pour recherche rapide
            try db.create(index: "idx_vehicle_plate", on: "vehicleRecord", columns: ["plate"])
            try db.create(index: "idx_vehicle_isPrimary", on: "vehicleRecord", columns: ["isPrimary"])
        }

        migrator.registerMigration("v1.0_create_file_metadata_table") { db in
            try db.create(table: "fileMetadataRecord") { table in
                table.primaryKey("id", .blob).notNull()
                table.column("vehicleId", .blob).notNull()
                    .references("vehicleRecord", column: "id", onDelete: .cascade)
                table.column("fileName", .text).notNull()
                table.column("relativePath", .text).notNull()
                table.column("documentType", .text).notNull()
                table.column("documentName", .text).notNull()
                table.column("date", .datetime).notNull()
                table.column("mileage", .text).notNull()
                table.column("amount", .double)
                table.column("fileSize", .integer).notNull().defaults(to: 0)
                table.column("mimeType", .text).notNull()
                table.column("createdAt", .datetime).notNull()
                table.column("modifiedAt", .datetime).notNull()
            }

            // Index pour recherche et tri
            try db.create(index: "idx_file_vehicleId", on: "fileMetadataRecord", columns: ["vehicleId"])
            try db.create(index: "idx_file_date", on: "fileMetadataRecord", columns: ["date"])
            try db.create(index: "idx_file_documentType", on: "fileMetadataRecord", columns: ["documentType"])
        }

        // MARK: - Futures migrations
        // Ajouter ici les prochaines migrations avec des versions incrémentales

        return migrator
    }
}
