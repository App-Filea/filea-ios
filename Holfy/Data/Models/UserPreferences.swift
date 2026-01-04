//
//  UserPreferences.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 03/01/2026.
//

import Foundation
import SwiftUI

enum Currency: String, Codable, CaseIterable, Identifiable {
    case euro = "EUR"
    case dollar = "USD"

    var id: String { rawValue }

    var displayName: LocalizedStringKey {
        switch self {
        case .euro: return "settings_currency_euro"
        case .dollar: return "settings_currency_dollar"
        }
    }

    var symbol: String {
        switch self {
        case .euro: return "€"
        case .dollar: return "$"
        }
    }

    var iconName: String {
        switch self {
        case .euro: return "eurosign"
        case .dollar: return "dollarsign"
        }
    }
}

enum DistanceUnit: String, Codable, CaseIterable, Identifiable {
    case kilometers = "KM"
    case miles = "MI"

    var id: String { rawValue }

    var displayName: LocalizedStringKey {
        switch self {
        case .kilometers: return "settings_distance_kilometers"
        case .miles: return "settings_distance_miles"
        }
    }

    var symbol: String {
        switch self {
        case .kilometers: return "km"
        case .miles: return "mi"
        }
    }
}
