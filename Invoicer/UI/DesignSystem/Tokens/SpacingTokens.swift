//
//  SpacingTokens.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Design tokens for spacing following Apple Human Interface Guidelines (8pt grid system)
//

import SwiftUI

/// Spacing tokens following Apple HIG 8-point grid system
/// Use these constants for consistent spacing throughout the app
enum Spacing {
    /// 2pt - Minimal spacing for very tight layouts
    static let xxxs: CGFloat = 2

    /// 4pt - Extra extra small spacing
    static let xxs: CGFloat = 4

    /// 8pt - Extra small spacing (base unit)
    static let xs: CGFloat = 8

    /// 12pt - Small spacing
    static let sm: CGFloat = 12

    /// 16pt - Medium spacing (standard for most UI elements)
    static let md: CGFloat = 16

    /// 24pt - Large spacing
    static let lg: CGFloat = 24

    /// 32pt - Extra large spacing
    static let xl: CGFloat = 32

    /// 48pt - Extra extra large spacing
    static let xxl: CGFloat = 48

    /// 64pt - Maximum spacing for major sections
    static let xxxl: CGFloat = 64
}

// MARK: - Specific Use Cases

extension Spacing {
    /// Standard padding for cards and containers
    static let cardPadding: CGFloat = md

    /// Padding between sections
    static let sectionSpacing: CGFloat = lg

    /// Spacing between list items
    static let listItemSpacing: CGFloat = xs

    /// Horizontal screen margins
    static let screenMargin: CGFloat = md

    /// Spacing between form fields
    static let formFieldSpacing: CGFloat = md

    /// Spacing for buttons in button groups
    static let buttonGroupSpacing: CGFloat = sm
}
