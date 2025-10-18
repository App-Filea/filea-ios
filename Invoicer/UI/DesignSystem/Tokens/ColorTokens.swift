//
//  ColorTokens.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Semantic color tokens following Apple Human Interface Guidelines
//

import SwiftUI

/// Semantic color tokens that adapt to light/dark mode
/// Maps Material Design colors to semantic iOS naming
enum ColorTokens {
    // MARK: - Primary Actions

    /// Main action color (buttons, links, etc.)
    static let actionPrimary = Color.accentColor

    /// Container background for primary actions
    static let actionPrimaryContainer = Color(uiColor: .secondarySystemGroupedBackground)

    /// Text/icon color on primary action backgrounds
    static let onActionPrimary = Color(uiColor: .systemBackground)

    /// Text/icon color on primary container backgrounds
    static let onActionPrimaryContainer = Color.primary

    // MARK: - Secondary Actions

    /// Secondary action color
    static let actionSecondary = Color(uiColor: .systemGray)

    /// Container background for secondary actions
    static let actionSecondaryContainer = Color(uiColor: .tertiarySystemGroupedBackground)

    /// Text/icon color on secondary action backgrounds
    static let onActionSecondary = Color(uiColor: .systemBackground)

    /// Text/icon color on secondary container backgrounds
    static let onActionSecondaryContainer = Color.primary

    // MARK: - Accent Actions

    /// Accent color for highlighted elements
    static let accent = Color.accentColor

    /// Container background for accent elements
    static let accentContainer = Color.accentColor.opacity(0.2)

    /// Text/icon color on accent backgrounds
    static let onAccent = Color(uiColor: .systemBackground)

    /// Text/icon color on accent container backgrounds
    static let onAccentContainer = Color.accentColor

    // MARK: - Semantic Status Colors

    /// Success state (positive actions, confirmations)
    static let success = Color.green
    static let successContainer = Color.green.opacity(0.2)
    static let onSuccess = Color(uiColor: .systemBackground)
    static let onSuccessContainer = Color.green

    /// Warning state (caution, non-critical alerts)
    static let warning = Color.orange
    static let warningContainer = Color.orange.opacity(0.2)
    static let onWarning = Color(uiColor: .systemBackground)
    static let onWarningContainer = Color.orange

    /// Error state (errors, destructive actions)
    static let error = Color.red
    static let errorContainer = Color.red.opacity(0.2)
    static let onError = Color(uiColor: .systemBackground)
    static let onErrorContainer = Color.red

    /// Info state (informational messages)
    static let info = Color.blue
    static let infoContainer = Color.blue.opacity(0.2)
    static let onInfo = Color(uiColor: .systemBackground)
    static let onInfoContainer = Color.blue

    // MARK: - Surface & Background

    /// Main surface color (cards, sheets)
    static let surface = Color(uiColor: .systemBackground)

    /// Elevated surface color (elevated cards)
    static let surfaceElevated = Color(uiColor: .tertiarySystemBackground)

    /// Bright surface variant
    static let surfaceBright = Color(uiColor: .systemBackground)

    /// Dim surface variant
    static let surfaceDim = Color(uiColor: .secondarySystemBackground)

    /// Main background color
    static let background = Color(uiColor: .secondarySystemBackground)

    /// Text/icon color on surface backgrounds
    static let onSurface = Color.primary

    /// Text/icon color on main background
    static let onBackground = Color.primary

    // MARK: - Text Colors

    /// Primary text color
    static let textPrimary = Color.primary

    /// Secondary text color
    static let textSecondary = Color.secondary

    /// Tertiary text color (disabled, placeholders)
    static let textTertiary = Color(uiColor: .tertiaryLabel)

    /// Inverse text color (for dark backgrounds)
    static let textInverse = Color(uiColor: .systemBackground)

    // MARK: - Borders & Dividers

    /// Border and outline color
    static let outline = Color(uiColor: .separator)

    /// Variant border color (subtle borders)
    static let outlineVariant = Color(uiColor: .separator).opacity(0.5)

    /// Divider line color
    static let divider = Color(uiColor: .separator)

    // MARK: - iOS System Colors (for reference)

    /// System label color (auto-adapts to dark mode)
    static let label = Color.primary

    /// System secondary label
    static let secondaryLabel = Color.secondary

    /// System background
    static let systemBackground = Color(uiColor: .systemBackground)

    /// System grouped background
    static let systemGroupedBackground = Color(uiColor: .systemGroupedBackground)
}

// MARK: - Specific Use Cases

extension ColorTokens {
    /// Card background color
    static let cardBackground = surface

    /// Card border color
    static let cardBorder = outlineVariant

    /// Button text color
    static let buttonText = onActionPrimary

    /// Destructive button color
    static let destructive = error

    /// Positive button color
    static let positive = success

    /// Shadow color for elevated elements
    static let shadow = Color.black.opacity(0.1)

    /// Overlay color for modals
    static let overlay = Color.black.opacity(0.4)

    /// Selected item background
    static let selection = actionPrimary.opacity(0.1)

    /// Hover state background
    static let hover = Color.gray.opacity(0.1)

    /// Border color (alias for outline)
    static let border = outline

    /// Primary surface color (alias for background)
    static let surfacePrimary = systemBackground

    /// Secondary surface color (alias for surface)
    static let surfaceSecondary = surface
}
