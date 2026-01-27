//
//  VehicleAlert.swift
//  Holfy
//
//  Created by Claude on 2026-01-26.
//

import Foundation
import SwiftUI

struct VehicleAlert: Equatable, Identifiable {

    init(
        id: String = UUID().uuidString,
        type: AlertType,
        message: String,
        daysRemaining: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.message = message
        self.daysRemaining = daysRemaining
    }

    let id: String
    let type: AlertType
    let message: String
    let daysRemaining: Int?

    var alertPriority: AlertPriority {
        switch type {
        case .technicalInspection:
            guard let days = daysRemaining else { return .medium }
            return days < 30 ? .high : .medium
        case .incompleteDocuments:
            return .low
        }
    }

    enum AlertType: String, Equatable, Sendable {
        case technicalInspection
        case incompleteDocuments
    }

    enum AlertPriority: Int, Equatable, Comparable, Sendable {
        case high = 1
        case medium = 2
        case low = 3

        static func < (lhs: AlertPriority, rhs: AlertPriority) -> Bool {
            lhs.rawValue > rhs.rawValue
        }

        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .yellow
            case .low: return .blue
            }
        }
    }
}
