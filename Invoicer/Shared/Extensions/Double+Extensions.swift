//
//  Double+Extensions.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Double formatting extensions for currency and numbers
//

import Foundation

extension Double {
    // MARK: - Currency Formatting (with currency parameter)

    /// Formats the double as a currency string (e.g., "1 234,56 €" or "1 234,56 $")
    func asCurrencyString(currency: Currency) -> String {
        CurrencyFormatter(currency: currency).format(self)
    }

    /// Formats the double as a currency string without decimals (e.g., "1 235 €" or "1 235 $")
    func asCurrencyStringNoDecimals(currency: Currency) -> String {
        CurrencyFormatter(currency: currency).formatNoDecimals(self)
    }

    /// Formats the double adaptively with compact format for large values
    /// Examples: 1645000000 → "1645M €", 1500000 → "1,5M €", 5000 → "5 000 €"
    func asCurrencyStringAdaptive(currency: Currency) -> String {
        CurrencyFormatter(currency: currency).formatAdaptive(self)
    }

    // MARK: - Number Formatting

    /// Formats the double with French decimal separator (e.g., "1 234,56")
    var asDecimalString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }

    /// Formats the double with a specific number of decimal places
    func asString(decimals: Int) -> String {
        String(format: "%.\(decimals)f", self)
    }

    // MARK: - Rounding

    /// Rounds the double to a specific number of decimal places
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    /// Rounds to 2 decimal places (standard for currency)
    var roundedToCurrency: Double {
        rounded(toPlaces: 2)
    }
}
