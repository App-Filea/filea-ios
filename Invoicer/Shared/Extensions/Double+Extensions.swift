//
//  Double+Extensions.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Double formatting extensions for currency and numbers
//

import Foundation

extension Double {
    // MARK: - Currency Formatting

    /// Formats the double as a currency string in euros (e.g., "1 234,56 €")
    var asCurrencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.currencySymbol = "€"
        formatter.currencyDecimalSeparator = ","
        formatter.currencyGroupingSeparator = " "
        return formatter.string(from: NSNumber(value: self)) ?? "0,00 €"
    }

    /// Formats the double as a compact string without decimals (e.g., "1234K", "2M")
    /// Can be used for any unit (currency, distance, etc.)
    var asCompactString: String {
        let absValue = Swift.abs(self)
        let sign = self < 0 ? "-" : ""

        if absValue >= 1_000_000 {
            let millions = Int(absValue / 1_000_000)
            return "\(sign)\(millions)M"
        } else if absValue >= 1_000 {
            let thousands = Int(absValue / 1_000)
            return "\(sign)\(thousands)K"
        } else {
            return "\(sign)\(Int(absValue))"
        }
    }

    /// Formats the double as a compact currency string (e.g., "1,2K €" for 1234.56)
    var asCompactCurrencyString: String {
        let absValue = Swift.abs(self)
        let sign = self < 0 ? "-" : ""

        if absValue >= 1_000_000 {
            let millions = absValue / 1_000_000
            return String(format: "\(sign)%.1fM €", millions)
        } else if absValue >= 1_000 {
            let thousands = absValue / 1_000
            return String(format: "\(sign)%.1fK €", thousands)
        } else {
            return asCurrencyString
        }
    }

    /// Formats the double as a currency string without decimals (e.g., "1 235 €")
    var asCurrencyStringNoDecimals: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.currencySymbol = "€"
        formatter.maximumFractionDigits = 0
        formatter.currencyGroupingSeparator = " "
        return formatter.string(from: NSNumber(value: self)) ?? "0 €"
    }

    /// Formats the double adaptively: compact format with smart decimals for large values (≥10K), full format for smaller values
    /// Examples: 1645000000 → "1645M €", 1500000 → "1,5M €", 5000 → "5 000,00 €", 850 → "850,00 €"
    var asCurrencyStringAdaptive: String {
        let absValue = Swift.abs(self)
        let sign = self < 0 ? "-" : ""

        if absValue >= 1_000_000 {
            let millions = absValue / 1_000_000
            // Check if it's a round number (no decimals)
            if millions.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(sign)\(Int(millions))M €"
            } else {
                return String(format: "\(sign)%.1fM €", millions)
            }
        } else if absValue >= 10_000 {
            let thousands = absValue / 1_000
            // Check if it's a round number (no decimals)
            if thousands.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(sign)\(Int(thousands))K €"
            } else {
                return String(format: "\(sign)%.1fK €", thousands)
            }
        } else {
            return asCurrencyStringNoDecimals
        }
    }

    /// Formats the double as kilometers with adaptive compact format and smart decimals for large values (≥10K)
    /// Examples: 125000 → "125K km", 12500 → "12,5K km", 5000 → "5 000 km", 850 → "850 km"
    var asKilometersAdaptive: String {
        let absValue = Swift.abs(self)
        let sign = self < 0 ? "-" : ""

        if absValue >= 1_000_000 {
            let millions = absValue / 1_000_000
            // Check if it's a round number (no decimals)
            if millions.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(sign)\(Int(millions))M km"
            } else {
                return String(format: "\(sign)%.1fM km", millions)
            }
        } else if absValue >= 10_000 {
            let thousands = absValue / 1_000
            // Check if it's a round number (no decimals)
            if thousands.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(sign)\(Int(thousands))K km"
            } else {
                return String(format: "\(sign)%.1fK km", thousands)
            }
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.groupingSeparator = " "
            formatter.maximumFractionDigits = 0
            return (formatter.string(from: NSNumber(value: self)) ?? "\(Int(self))") + " km"
        }
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

// MARK: - Optional Double Extensions

extension Optional where Wrapped == Double {
    /// Returns the currency string or a default value if nil
    var asCurrencyString: String {
        self?.asCurrencyString ?? "0,00 €"
    }

    /// Returns the currency string without decimals or a default value if nil
    var asCurrencyStringNoDecimals: String {
        self?.asCurrencyStringNoDecimals ?? "0 €"
    }

    /// Returns true if the value is nil or zero
    var isNilOrZero: Bool {
        guard let value = self else { return true }
        return value == 0
    }
}
