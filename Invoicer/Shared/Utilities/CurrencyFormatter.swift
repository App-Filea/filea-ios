//
//  CurrencyFormatter.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Utility for formatting currency amounts
//

import Foundation

/// Utility for formatting currency values in euros
final class CurrencyFormatter: @unchecked Sendable {
    // MARK: - Singleton

    static let shared = CurrencyFormatter()

    private init() {}

    // MARK: - Private Properties

    private lazy var standardFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.currencySymbol = "€"
        formatter.currencyDecimalSeparator = ","
        formatter.currencyGroupingSeparator = " "
        return formatter
    }()

    private lazy var noDecimalsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.currencySymbol = "€"
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.currencyGroupingSeparator = " "
        return formatter
    }()

    private lazy var decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = " "
        return formatter
    }()

    // MARK: - Public Methods

    /// Formats a double as a currency string (e.g., "1 234,56 €")
    func format(_ value: Double, includeDecimals: Bool = true) -> String {
        let formatter = includeDecimals ? standardFormatter : noDecimalsFormatter
        return formatter.string(from: NSNumber(value: value)) ?? "0,00 €"
    }

    /// Formats a double as a currency string without currency symbol (e.g., "1 234,56")
    func formatValue(_ value: Double, includeDecimals: Bool = true) -> String {
        if includeDecimals {
            return decimalFormatter.string(from: NSNumber(value: value)) ?? "0,00"
        } else {
            decimalFormatter.maximumFractionDigits = 0
            let result = decimalFormatter.string(from: NSNumber(value: value)) ?? "0"
            decimalFormatter.maximumFractionDigits = 2
            return result
        }
    }

    /// Formats a double as a compact currency string (e.g., "1,2K €" for 1234)
    func formatCompact(_ value: Double) -> String {
        let absValue = abs(value)
        let sign = value < 0 ? "-" : ""

        if absValue >= 1_000_000 {
            let millions = absValue / 1_000_000
            return String(format: "\(sign)%.1fM €", millions)
        } else if absValue >= 1_000 {
            let thousands = absValue / 1_000
            return String(format: "\(sign)%.1fK €", thousands)
        } else {
            return format(value)
        }
    }

    /// Parses a currency string to a double value
    func parse(_ string: String) -> Double? {
        // Remove currency symbol and whitespace
        let cleaned = string
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return Double(cleaned)
    }

    /// Formats an optional double as a currency string
    func formatOptional(_ value: Double?) -> String {
        guard let value = value else { return "-- €" }
        return format(value)
    }

    /// Checks if a string is a valid currency amount
    func isValid(_ string: String) -> Bool {
        parse(string) != nil
    }
}

// MARK: - Convenience Methods

extension CurrencyFormatter {
    /// Formats a double with specific decimal places
    func format(_ value: Double, decimals: Int) -> String {
        decimalFormatter.minimumFractionDigits = decimals
        decimalFormatter.maximumFractionDigits = decimals
        let result = decimalFormatter.string(from: NSNumber(value: value)) ?? "0"
        decimalFormatter.minimumFractionDigits = 0
        decimalFormatter.maximumFractionDigits = 2
        return result + " €"
    }

    /// Formats a currency range
    func formatRange(from minValue: Double, to maxValue: Double) -> String {
        "\(format(minValue, includeDecimals: false)) - \(format(maxValue, includeDecimals: false))"
    }

    /// Formats a currency with a prefix (e.g., "Coût: 1 234,56 €")
    func formatWithPrefix(_ value: Double, prefix: String) -> String {
        "\(prefix) \(format(value))"
    }

    /// Formats a currency with a suffix (e.g., "1 234,56 € / mois")
    func formatWithSuffix(_ value: Double, suffix: String) -> String {
        "\(format(value)) \(suffix)"
    }
}
