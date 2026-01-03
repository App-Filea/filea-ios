//
//  View+Extensions.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  SwiftUI View extensions and custom modifiers
//

import SwiftUI

struct FieldCardModifier: ViewModifier {
    let isError: Bool

    func body(content: Content) -> some View {
        content
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isError ? Color.red : Color(.separator), lineWidth: 1)
            )
    }
}

extension View {
    func fieldCard(isError: Bool = false) -> some View {
        modifier(FieldCardModifier(isError: isError))
    }
}
