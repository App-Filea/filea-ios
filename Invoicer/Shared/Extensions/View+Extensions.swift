//
//  View+Extensions.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  SwiftUI View extensions and custom modifiers
//

import SwiftUI

// MARK: - Card Style

extension View {
    /// Applies a standard card style with background, corner radius, and shadow
    func cardStyle(
        backgroundColor: Color = ColorTokens.surface,
        cornerRadius: CGFloat = Radius.card,
        shadowColor: Color = ColorTokens.shadow,
        shadowRadius: CGFloat = 8
    ) -> some View {
        self
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 2)
    }

    /// Applies an elevated card style with larger shadow
    func elevatedCardStyle(
        backgroundColor: Color = ColorTokens.surfaceElevated,
        cornerRadius: CGFloat = Radius.card
    ) -> some View {
        self
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: ColorTokens.shadow, radius: 12, x: 0, y: 4)
    }
}

// MARK: - Section Header Style

extension View {
    /// Applies a standard section header style
    func sectionHeaderStyle() -> some View {
        self
            .font(Typography.headline)
            .foregroundColor(ColorTokens.textPrimary)
            .padding(.horizontal, Spacing.screenMargin)
            .padding(.top, Spacing.sectionSpacing)
            .padding(.bottom, Spacing.xs)
    }
}

// MARK: - List Row Style

extension View {
    /// Applies a standard list row style
    func listRowStyle(
        backgroundColor: Color = ColorTokens.surface,
        cornerRadius: CGFloat = Radius.sm
    ) -> some View {
        self
            .padding(.vertical, Spacing.xs)
            .padding(.horizontal, Spacing.md)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}

// MARK: - Conditional Modifiers

extension View {
    /// Applies a modifier conditionally
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies one of two modifiers based on a condition
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        ifTrue: (Self) -> TrueContent,
        ifFalse: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTrue(self)
        } else {
            ifFalse(self)
        }
    }

    /// Applies a modifier if an optional value is not nil
    @ViewBuilder
    func ifLet<Value, Transform: View>(
        _ value: Value?,
        transform: (Self, Value) -> Transform
    ) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

// MARK: - Loading State

extension View {
    /// Overlays a loading indicator when loading is true
    func loading(_ isLoading: Bool) -> some View {
        ZStack {
            self
                .disabled(isLoading)
                .blur(radius: isLoading ? 2 : 0)

            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ColorTokens.overlay)
            }
        }
    }
}

// MARK: - Placeholder

extension View {
    /// Applies a placeholder overlay when content is empty
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Corner Radius

extension View {
    /// Applies corner radius to specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

/// Custom shape for applying corner radius to specific corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Keyboard Dismissal

extension View {
    /// Adds a tap gesture to dismiss the keyboard
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

// MARK: - Hidden

extension View {
    /// Hides the view if the condition is true
    @ViewBuilder
    func hidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        } else {
            self
        }
    }
}

// MARK: - Frame Modifiers

extension View {
    /// Sets a square frame with the specified size
    func frame(size: CGFloat, alignment: Alignment = .center) -> some View {
        self.frame(width: size, height: size, alignment: alignment)
    }

    /// Expands the view to fill available space
    func expandToFill(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }

    /// Expands the view horizontally
    func expandHorizontally(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }

    /// Expands the view vertically
    func expandVertically(alignment: Alignment = .center) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
}

// MARK: - Separator

extension View {
    /// Adds a separator line below the view
    func withSeparator(
        color: Color = ColorTokens.divider,
        thickness: CGFloat = 1,
        padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    ) -> some View {
        VStack(spacing: 0) {
            self
            Rectangle()
                .fill(color)
                .frame(height: thickness)
                .padding(padding)
        }
    }
}

extension View {
    func fieldCard() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.separator), lineWidth: 1)
            )
    }
}
