//
//  Double+Distance.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Double extensions for distance formatting
//

import Foundation

extension Double {
    // MARK: - Distance Formatting

    /// Formats the double as a distance string with the specified unit (e.g., "50 000 km" or "31 069 mi")
    func asDistanceString(unit: DistanceUnit) -> String {
        DistanceConverter.format(self, unit: unit)
    }
}
