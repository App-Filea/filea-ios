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
    /// Small - 8pt
    /// Use for small cards, containers
    static let sm: CGFloat = 8

    /// Large - 16pt
    /// Use for large cards, containers
    static let lg: CGFloat = 16

    /// Full rounding (pill shape)
    /// Use for circular buttons, badges
    static let full: CGFloat = 9999

    // MARK: - Specific Use Cases

    /// Standard card corner radius (12pt)
    static let card: CGFloat = 12

    /// Text field corner radius (8pt)
    static let textField: CGFloat = 8

    /// Thumbnail image radius (4pt)
    static let thumbnail: CGFloat = 4

    /// Badge corner radius (circular)
    static let badge: CGFloat = full
}
