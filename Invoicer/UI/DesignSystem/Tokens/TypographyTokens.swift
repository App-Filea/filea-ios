//
//  TypographyTokens.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Typography tokens following Apple Human Interface Guidelines
//

import SwiftUI

/// Typography tokens following Apple HIG text styles
/// These styles automatically support Dynamic Type and scale appropriately
enum Typography {
    // MARK: - Display Styles

    /// Large title - 34pt (iOS default)
    /// Use for main screen titles
    static let largeTitle: Font = .largeTitle

    /// Title 1 - 28pt
    /// Use for primary section headers
    static let title1: Font = .title

    /// Title 2 - 22pt
    /// Use for secondary section headers
    static let title2: Font = .title2

    /// Title 3 - 20pt
    /// Use for tertiary section headers
    static let title3: Font = .title3

    // MARK: - Body Styles

    /// Headline - 17pt (Semibold)
    /// Use for emphasized body text
    static let headline: Font = .headline

    /// Body - 17pt
    /// Use for main body text
    static let body: Font = .body

    /// Callout - 16pt
    /// Use for secondary body text
    static let callout: Font = .callout

    /// Subheadline - 15pt
    /// Use for additional information
    static let subheadline: Font = .subheadline

    /// Footnote - 13pt
    /// Use for tertiary information
    static let footnote: Font = .footnote

    /// Caption 1 - 12pt
    /// Use for labels and small details
    static let caption1: Font = .caption

    /// Caption 2 - 11pt
    /// Use for very small details
    static let caption2: Font = .caption2
}

// MARK: - Font Weight Extensions

extension Typography {
    /// Bold weight variants
    enum Bold {
        static let largeTitle: Font = .largeTitle.bold()
        static let title1: Font = .title.bold()
        static let title2: Font = .title2.bold()
        static let title3: Font = .title3.bold()
        static let headline: Font = .headline.bold()
        static let body: Font = .body.bold()
        static let callout: Font = .callout.bold()
        static let subheadline: Font = .subheadline.bold()
        static let footnote: Font = .footnote.bold()
        static let caption1: Font = .caption.bold()
        static let caption2: Font = .caption2.bold()
    }

    /// Semibold weight variants
    enum Semibold {
        static let largeTitle: Font = .largeTitle.weight(.semibold)
        static let title1: Font = .title.weight(.semibold)
        static let title2: Font = .title2.weight(.semibold)
        static let title3: Font = .title3.weight(.semibold)
        static let body: Font = .body.weight(.semibold)
        static let callout: Font = .callout.weight(.semibold)
        static let subheadline: Font = .subheadline.weight(.semibold)
        static let footnote: Font = .footnote.weight(.semibold)
        static let caption1: Font = .caption.weight(.semibold)
        static let caption2: Font = .caption2.weight(.semibold)
    }

    /// Medium weight variants
    enum Medium {
        static let body: Font = .body.weight(.medium)
        static let callout: Font = .callout.weight(.medium)
        static let subheadline: Font = .subheadline.weight(.medium)
        static let footnote: Font = .footnote.weight(.medium)
        static let caption1: Font = .caption.weight(.medium)
        static let caption2: Font = .caption2.weight(.medium)
    }
}

// MARK: - Specific Use Cases

extension Typography {
    /// For navigation titles
    static let navigationTitle: Font = headline

    /// For card titles
    static let cardTitle: Font = headline

    /// For card subtitles
    static let cardSubtitle: Font = subheadline

    /// For button labels
    static let button: Font = body

    /// For form labels
    static let formLabel: Font = subheadline

    /// For placeholder text
    static let placeholder: Font = body

    /// For currency amounts
    static let currency: Font = title2

    /// For large currency amounts
    static let currencyLarge: Font = title1

    /// For stat values
    static let statValue: Font = title2

    /// For stat labels
    static let statLabel: Font = caption1
}
