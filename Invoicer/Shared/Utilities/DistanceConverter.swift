//
//  DistanceConverter.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Utility for converting and formatting distances
//

import Foundation

/// Utility for converting distances between kilometers and miles
struct DistanceConverter {
    // MARK: - Constants

    static let kmToMilesRatio: Double = 0.621371

    // MARK: - Conversion Methods

    /// Converts a distance from kilometers to the specified unit
    static func convert(_ distance: Double, to unit: DistanceUnit) -> Double {
        switch unit {
        case .kilometers:
            return distance // Stockage natif en km
        case .miles:
            return distance * kmToMilesRatio
        }
    }

    /// Formats a distance with the specified unit
    static func format(_ distance: Double, unit: DistanceUnit) -> String {
        let converted = convert(distance, to: unit)
        let rounded = Int(converted.rounded())

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        // Utiliser locale fr_FR pour formatage cohérent
        formatter.locale = Locale(identifier: "fr_FR")

        let formattedNumber = formatter.string(from: NSNumber(value: rounded)) ?? "\(rounded)"
        return "\(formattedNumber) \(unit.symbol)"
    }
}
