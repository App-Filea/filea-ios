//
//  Color+Extensions.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Color utility extensions
//

import SwiftUI

extension Color {
    // MARK: - Hex Initialization

    /// Creates a Color from a hex string (e.g., "#FF0000" or "FF0000")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Color Manipulation

    // Note: Semantic colors (success, warning, error, info) are available
    // via asset catalog and GeneratedAssetSymbols.swift

    /// Returns a lighter version of the color
    func lighter(by percentage: Double = 0.2) -> Color {
        adjustBrightness(by: 1 + percentage)
    }

    /// Returns a darker version of the color
    func darker(by percentage: Double = 0.2) -> Color {
        adjustBrightness(by: 1 - percentage)
    }

    /// Adjusts the brightness of the color
    private func adjustBrightness(by factor: Double) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return Color(
                hue: Double(hue),
                saturation: Double(saturation),
                brightness: Double(brightness) * factor,
                opacity: Double(alpha)
            )
        }

        return self
    }

    /// Returns the color with adjusted opacity
    func withOpacity(_ opacity: Double) -> Color {
        self.opacity(opacity)
    }
}

// MARK: - Document Type Colors

extension Color {
    /// Returns a color associated with a document category
    static func forDocumentCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "administratif":
            return .info
        case "entretien":
            return .success
        case "réparation", "reparation":
            return .warning
        case "carburant":
            return Color("accent")
        case "autres":
            return .secondary
        default:
            return .primary
        }
    }
}

// MARK: - Vehicle Type Colors

extension Color {
    /// Returns a color associated with a vehicle type
    static func forVehicleType(_ type: String) -> Color {
        switch type.lowercased() {
        case "car", "voiture":
            return Color("actionPrimary")
        case "motorcycle", "moto":
            return .warning
        case "truck", "camion":
            return Color("accent")
        case "bicycle", "vélo", "velo":
            return .success
        default:
            return .secondary
        }
    }
}
