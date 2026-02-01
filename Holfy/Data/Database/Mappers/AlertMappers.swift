//
//  AlertMappers.swift
//  Holfy
//
//  Created by Claude on 2026-02-01.
//  Mappers for converting between Alert domain model and AlertRecord
//

import Foundation

// MARK: - Alert → AlertRecord

extension Alert {
    /// Converts domain Alert to AlertRecord for database persistence
    func toRecord() -> AlertRecord {
        AlertRecord(
            id: id,
            title: title,
            message: message,
            date: date,
            isRead: isRead,
            isDismissed: isDismissed,
            vehicleId: vehicleId,
            deadline: deadline,
            category: category.rawValue,
            priority: priority.rawValue,
            isDismissable: isDismissable,
            relatedDocumentId: relatedDocumentId,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - AlertRecord → Alert

extension AlertRecord {
    /// Converts AlertRecord to domain Alert
    func toDomain() -> Alert {
        Alert(
            id: id,
            title: title,
            message: message,
            date: date,
            isRead: isRead,
            isDismissed: isDismissed,
            vehicleId: vehicleId,
            deadline: deadline,
            category: AlertCategory(rawValue: category) ?? .document,
            priority: AlertPriority(rawValue: priority) ?? .medium,
            isDismissable: isDismissable,
            relatedDocumentId: relatedDocumentId
        )
    }
}
