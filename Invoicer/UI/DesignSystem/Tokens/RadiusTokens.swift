//
//  RadiusTokens.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Corner radius tokens following Apple Human Interface Guidelines
//

import SwiftUI

/// Corner radius tokens for consistent rounded corners
/// Following Apple HIG recommendations for iOS components
enum Radius {
    /// No rounding - 0pt
    static let none: CGFloat = 0

    /// Extra small - 4pt
    /// Use for small buttons, tags
    static let xs: CGFloat = 4

    /// Small - 8pt
    /// Use for buttons, small cards
    static let sm: CGFloat = 8

    /// Medium - 12pt
    /// Use for cards, sheets
    static let md: CGFloat = 12

    /// Large - 16pt
    /// Use for large cards, containers
    static let lg: CGFloat = 16

    /// Extra large - 20pt
    /// Use for prominent containers
    static let xl: CGFloat = 20

    /// Extra extra large - 24pt
    /// Use for full-screen modals
    static let xxl: CGFloat = 24

    /// Full rounding (pill shape)
    /// Use for circular buttons, avatars
    static let full: CGFloat = 9999
}

// MARK: - Specific Use Cases

extension Radius {
    /// Standard card corner radius
    static let card: CGFloat = md

    /// Button corner radius
    static let button: CGFloat = sm

    /// Text field corner radius
    static let textField: CGFloat = sm

    /// Sheet/Modal corner radius
    static let sheet: CGFloat = lg

    /// Floating Action Button radius
    static let fab: CGFloat = full

    /// Badge corner radius
    static let badge: CGFloat = full

    /// Tag corner radius
    static let tag: CGFloat = xs

    /// Thumbnail image radius
    static let thumbnail: CGFloat = xs

    /// Avatar radius (circular)
    static let avatar: CGFloat = full

    /// Section container radius
    static let section: CGFloat = lg
}

// MARK: - SwiftUI Shape Extensions

extension Radius {
    /// Creates a RoundedRectangle shape with the specified radius
    static func shape(_ radius: CGFloat) -> RoundedRectangle {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
    }

    /// Creates a RoundedRectangle with card radius
    static var cardShape: RoundedRectangle {
        shape(card)
    }

    /// Creates a RoundedRectangle with button radius
    static var buttonShape: RoundedRectangle {
        shape(button)
    }

    /// Creates a RoundedRectangle with sheet radius
    static var sheetShape: RoundedRectangle {
        shape(sheet)
    }
}
