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
            try db.create(table: "vehicleRecords") { table in
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
            try db.create(index: "idx_vehicle_plate", on: "vehicleRecords", columns: ["plate"])
            try db.create(index: "idx_vehicle_isPrimary", on: "vehicleRecords", columns: ["isPrimary"])
        }

        migrator.registerMigration("v1.0_create_file_metadata_table") { db in
            try db.create(table: "fileMetadataRecords") { table in
                table.primaryKey("id", .blob).notNull()
                table.column("vehicleId", .blob).notNull()
                    .references("vehicleRecords", column: "id", onDelete: .cascade)
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
            try db.create(index: "idx_file_vehicleId", on: "fileMetadataRecords", columns: ["vehicleId"])
            try db.create(index: "idx_file_date", on: "fileMetadataRecords", columns: ["date"])
            try db.create(index: "idx_file_documentType", on: "fileMetadataRecords", columns: ["documentType"])
        }

        // MARK: - Migration v1.1: Ajout de la date d'expiration

        migrator.registerMigration("v1.1_add_expiration_date_to_file_metadata") { db in
            try db.alter(table: "fileMetadataRecords") { table in
                table.add(column: "expirationDate", .datetime)
            }
        }

        // MARK: - Migration v1.2: Table des alertes

        migrator.registerMigration("v1.2_create_alerts_table") { db in
            try db.create(table: "alertRecords") { table in
                table.primaryKey("id", .blob).notNull()
                table.column("title", .text).notNull()
                table.column("message", .text).notNull()
                table.column("date", .datetime).notNull()
                table.column("isRead", .boolean).notNull().defaults(to: false)
                table.column("isDismissed", .boolean).notNull().defaults(to: false)
                table.column("vehicleId", .blob).notNull()
                    .references("vehicleRecords", column: "id", onDelete: .cascade)
                table.column("deadline", .datetime)
                table.column("category", .text).notNull()
                table.column("priority", .text).notNull()
                table.column("isDismissable", .boolean).notNull().defaults(to: true)
                table.column("relatedDocumentId", .blob)
                    .references("fileMetadataRecords", column: "id", onDelete: .setNull)
                table.column("createdAt", .datetime).notNull()
                table.column("updatedAt", .datetime).notNull()
            }

            // Index pour performance
            try db.create(index: "idx_alert_vehicleId", on: "alertRecords", columns: ["vehicleId"])
            try db.create(index: "idx_alert_isRead", on: "alertRecords", columns: ["isRead"])
            try db.create(index: "idx_alert_isDismissed", on: "alertRecords", columns: ["isDismissed"])
            try db.create(index: "idx_alert_priority", on: "alertRecords", columns: ["priority"])
        }

        // MARK: - Futures migrations
        // Ajouter ici les prochaines migrations avec des versions incrémentales

        return migrator
    }
}
