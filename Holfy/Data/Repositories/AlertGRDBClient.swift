//
//  AlertGRDBClient.swift
//  Holfy
//
//  Created by Claude on 2026-02-01.
//  GRDB client for alert persistence operations
//

import Foundation
import GRDB
import Dependencies

/// Client GRDB pour les opérations sur les alertes
struct AlertGRDBClient: Sendable {
    var create: @Sendable (Alert) async throws -> Void
    var update: @Sendable (Alert) async throws -> Void
    var delete: @Sendable (String) async throws -> Void
    var getAll: @Sendable (String) async throws -> [Alert]
    var getUnread: @Sendable (String) async throws -> [Alert]
    var markAsRead: @Sendable (String) async throws -> Void
    var dismiss: @Sendable (String) async throws -> Void
    var deleteAllForVehicle: @Sendable (String) async throws -> Void
}

// MARK: - Dependency Key

extension AlertGRDBClient: DependencyKey {
    static let liveValue: AlertGRDBClient = {
        @Dependency(\.database) var database

        return AlertGRDBClient(
            // MARK: - Create Alert
            create: { alert in
                print("➕ [AlertGRDBClient] Creating alert: \(alert.title)")

                var record = alert.toRecord()
                record.createdAt = Date()
                record.updatedAt = Date()

                try await database.write { db in
                    try AlertRecord.insert { record }.execute(db)
                }

                print("   ✅ Alert saved to database\n")
            },

            // MARK: - Update Alert
            update: { alert in
                print("✏️ [AlertGRDBClient] Updating alert: \(alert.id)")

                let existingRecord = try await database.read { db in
                    try AlertRecord.where { $0.id.in([alert.id]) }.fetchOne(db)
                }

                guard let existing = existingRecord else {
                    print("   ❌ Alert not found")
                    throw AlertGRDBError.alertNotFound(alert.id)
                }

                var record = alert.toRecord()
                record.createdAt = existing.createdAt
                record.updatedAt = Date()

                try await database.write { db in
                    try AlertRecord.upsert { record }.execute(db)
                }

                print("   ✅ Alert updated\n")
            },

            // MARK: - Delete Alert
            delete: { id in
                print("🗑️ [AlertGRDBClient] Deleting alert: \(id)")

                try await database.write { db in
                    try AlertRecord.where { $0.id.in([id]) }.delete().execute(db)
                }

                print("   ✅ Alert deleted\n")
            },

            // MARK: - Get All Alerts for Vehicle
            getAll: { vehicleId in
                print("📖 [AlertGRDBClient] Fetching alerts for vehicle: \(vehicleId)")

                let alerts = try await database.read { db -> [Alert] in
                    let records = try AlertRecord
                        .where { $0.vehicleId.in([vehicleId]) }
                        .order { $0.date.desc() }
                        .fetchAll(db)

                    // Filter non-dismissed alerts in Swift
                    return records
                        .filter { !$0.isDismissed }
                        .map { $0.toDomain() }
                }

                // Sort by priority (high first) then by deadline
                let sortedAlerts = alerts.sorted { lhs, rhs in
                    if lhs.priority != rhs.priority {
                        return lhs.priority > rhs.priority
                    }
                    return (lhs.deadline ?? .distantFuture) < (rhs.deadline ?? .distantFuture)
                }

                print("   ✅ Fetched \(sortedAlerts.count) alert(s)\n")
                return sortedAlerts
            },

            // MARK: - Get Unread Alerts for Vehicle
            getUnread: { vehicleId in
                print("📖 [AlertGRDBClient] Fetching unread alerts for vehicle: \(vehicleId)")

                let alerts = try await database.read { db -> [Alert] in
                    let records = try AlertRecord
                        .where { $0.vehicleId.in([vehicleId]) }
                        .order { $0.date.desc() }
                        .fetchAll(db)

                    // Filter unread and non-dismissed alerts in Swift
                    return records
                        .filter { !$0.isRead && !$0.isDismissed }
                        .map { $0.toDomain() }
                }

                // Sort by priority (high first) then by deadline
                let sortedAlerts = alerts.sorted { lhs, rhs in
                    if lhs.priority != rhs.priority {
                        return lhs.priority > rhs.priority
                    }
                    return (lhs.deadline ?? .distantFuture) < (rhs.deadline ?? .distantFuture)
                }

                print("   ✅ Fetched \(sortedAlerts.count) unread alert(s)\n")
                return sortedAlerts
            },

            // MARK: - Mark Alert as Read
            markAsRead: { id in
                print("👁️ [AlertGRDBClient] Marking alert as read: \(id)")

                try await database.write { db in
                    guard var record = try AlertRecord.where { $0.id.in([id]) }.fetchOne(db) else {
                        throw AlertGRDBError.alertNotFound(id)
                    }

                    record.isRead = true
                    record.updatedAt = Date()

                    try AlertRecord.upsert { record }.execute(db)
                }

                print("   ✅ Alert marked as read\n")
            },

            // MARK: - Dismiss Alert
            dismiss: { id in
                print("🙈 [AlertGRDBClient] Dismissing alert: \(id)")

                try await database.write { db in
                    guard var record = try AlertRecord.where { $0.id.in([id]) }.fetchOne(db) else {
                        throw AlertGRDBError.alertNotFound(id)
                    }

                    guard record.isDismissable else {
                        throw AlertGRDBError.alertNotDismissable(id)
                    }

                    record.isDismissed = true
                    record.updatedAt = Date()

                    try AlertRecord.upsert { record }.execute(db)
                }

                print("   ✅ Alert dismissed\n")
            },

            // MARK: - Delete All Alerts for Vehicle
            deleteAllForVehicle: { vehicleId in
                print("🗑️ [AlertGRDBClient] Deleting all alerts for vehicle: \(vehicleId)")

                try await database.write { db in
                    try AlertRecord
                        .where { $0.vehicleId.in([vehicleId]) }
                        .delete()
                        .execute(db)
                }

                print("   ✅ All alerts deleted for vehicle\n")
            }
        )
    }()

    static let testValue: AlertGRDBClient = AlertGRDBClient(
        create: { _ in },
        update: { _ in },
        delete: { _ in },
        getAll: { _ in [] },
        getUnread: { _ in [] },
        markAsRead: { _ in },
        dismiss: { _ in },
        deleteAllForVehicle: { _ in }
    )
}

// MARK: - Dependency Values

extension DependencyValues {
    var alertGRDBClient: AlertGRDBClient {
        get { self[AlertGRDBClient.self] }
        set { self[AlertGRDBClient.self] = newValue }
    }
}

// MARK: - Errors

enum AlertGRDBError: Error, LocalizedError {
    case alertNotFound(String)
    case alertNotDismissable(String)

    var errorDescription: String? {
        switch self {
        case .alertNotFound(let id):
            return "Alerte non trouvée : \(id)"
        case .alertNotDismissable(let id):
            return "Cette alerte ne peut pas être masquée : \(id)"
        }
    }
}
