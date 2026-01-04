//
//  CurrencyFormatter.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Utility for formatting currency amounts
//

import Foundation

/// Utility for formatting currency values with dynamic currency symbol
struct CurrencyFormatter {
    // MARK: - Properties

    let currency: Currency
    private let locale = Locale(identifier: "fr_FR") // Locale fixe pour formatage cohérent

    // MARK: - Initialization

    init(currency: Currency) {
        self.currency = currency
    }

    // MARK: - Formatting Methods

    /// Formats a double as a currency string (e.g., "1 234,56 €" or "1 234,56 $")
    func format(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        guard let formatted = formatter.string(from: NSNumber(value: value)) else {
            return "\(currency.symbol)0,00"
        }
        return "\(formatted) \(currency.symbol)"
    }

    /// Formats a double without decimals (e.g., "1 234 €" or "1 234 $")
    func formatNoDecimals(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0

        guard let formatted = formatter.string(from: NSNumber(value: value)) else {
            return "\(currency.symbol)0"
        }
        return "\(formatted) \(currency.symbol)"
    }

    /// Formats a double as a compact currency string (e.g., "1,2K €" for 1234)
    func formatAdaptive(_ value: Double) -> String {
        let absValue = abs(value)
        let sign = value < 0 ? "-" : ""

        if absValue >= 1_000_000 {
            let millions = absValue / 1_000_000
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = locale
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
            let formatted = formatter.string(from: NSNumber(value: millions)) ?? "\(millions)"
            return "\(sign)\(formatted)M \(currency.symbol)"
        } else if absValue >= 1_000 {
            let thousands = absValue / 1_000
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = locale
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
            let formatted = formatter.string(from: NSNumber(value: thousands)) ?? "\(thousands)"
            return "\(sign)\(formatted)K \(currency.symbol)"
        } else {
            return format(value)
        }
    }

    /// Formats an optional double as a currency string
    func formatOptional(_ value: Double?) -> String {
        guard let value = value else { return "-- \(currency.symbol)" }
        return format(value)
    }

    /// Formats a double with specific decimal places
    func format(_ value: Double, decimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals

        guard let formatted = formatter.string(from: NSNumber(value: value)) else {
            return "\(currency.symbol)0"
        }
        return "\(formatted) \(currency.symbol)"
    }

    /// Formats a currency range
    func formatRange(from minValue: Double, to maxValue: Double) -> String {
        "\(formatNoDecimals(minValue)) - \(formatNoDecimals(maxValue))"
    }
}

