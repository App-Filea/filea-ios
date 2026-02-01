//
//  Alert.swift
//  Holfy
//
//  Created by Claude on 2026-02-01.
//  Domain model for vehicle alerts with persistence support
//

import Foundation
import SwiftUI

// MARK: - Alert Category

enum AlertCategory: String, Codable, CaseIterable, Sendable {
    /// Document-related alerts (CT expiration, missing documents)
    case document
    /// Maintenance-related alerts (scheduled service, oil change due)
    case maintenance
    /// General reminders
    case reminder
}

// MARK: - Alert Priority

enum AlertPriority: String, Codable, CaseIterable, Sendable, Comparable {
    case low
    case medium
    case high

    static func < (lhs: AlertPriority, rhs: AlertPriority) -> Bool {
        let order: [AlertPriority] = [.low, .medium, .high]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }

    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .yellow
        case .low: return .blue
        }
    }
}

// MARK: - Alert

struct Alert: Codable, Equatable, Identifiable, Sendable {
    let id: String
    var title: String
    var message: String
    var date: Date
    var isRead: Bool
    var isDismissed: Bool
    var vehicleId: String
    var deadline: Date?
    var category: AlertCategory
    var priority: AlertPriority
    var isDismissable: Bool
    var relatedDocumentId: String?

    init(
        id: String = UUID().uuidString,
        title: String,
        message: String,
        date: Date = Date(),
        isRead: Bool = false,
        isDismissed: Bool = false,
        vehicleId: String,
        deadline: Date? = nil,
        category: AlertCategory,
        priority: AlertPriority,
        isDismissable: Bool = true,
        relatedDocumentId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.date = date
        self.isRead = isRead
        self.isDismissed = isDismissed
        self.vehicleId = vehicleId
        self.deadline = deadline
        self.category = category
        self.priority = priority
        self.isDismissable = isDismissable
        self.relatedDocumentId = relatedDocumentId
    }
}

// MARK: - Computed Properties

extension Alert {
    /// Days remaining until deadline (nil if no deadline)
    var daysRemaining: Int? {
        guard let deadline else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: deadline).day
    }

    /// Whether the alert is overdue (past deadline)
    var isOverdue: Bool {
        guard let deadline else { return false }
        return deadline < Date()
    }
}
