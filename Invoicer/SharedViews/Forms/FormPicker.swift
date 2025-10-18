//
//  FormPicker.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Reusable form picker component
//

import SwiftUI

/// Reusable picker component for forms
struct FormPicker<Item: Identifiable & Hashable>: View where Item: CustomStringConvertible {
    let title: String
    @Binding var selection: Item
    let items: [Item]
    var errorMessage: String?
    var showError: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Label
            Text(title)
                .font(Typography.formLabel)
                .foregroundColor(ColorTokens.textSecondary)

            // Picker
            Menu {
                ForEach(items) { item in
                    Button {
                        selection = item
                    } label: {
                        HStack {
                            Text(item.description)
                            if selection == item {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selection.description)
                        .font(Typography.body)
                        .foregroundColor(ColorTokens.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(ColorTokens.textSecondary)
                }
                .padding(Spacing.md)
                .background(ColorTokens.surface)
                .cornerRadius(Radius.textField)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.textField)
                        .stroke(
                            showError ? ColorTokens.error : ColorTokens.outline,
                            lineWidth: showError ? 2 : 1
                        )
                )
            }

            // Error Message
            if showError, let errorMessage = errorMessage {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text(errorMessage)
                        .font(Typography.caption1)
                }
                .foregroundColor(ColorTokens.error)
            }
        }
    }
}

// MARK: - Example Usage

#Preview {
    struct PreviewItem: Identifiable, Hashable, CustomStringConvertible {
        let id: UUID = UUID()
        let name: String

        var description: String { name }
    }

    struct PreviewContainer: View {
        @State private var selectedItem = PreviewItem(name: "Option 1")
        let items = [
            PreviewItem(name: "Option 1"),
            PreviewItem(name: "Option 2"),
            PreviewItem(name: "Option 3")
        ]

        var body: some View {
            VStack(spacing: Spacing.lg) {
                FormPicker(
                    title: "Choisir une option",
                    selection: $selectedItem,
                    items: items
                )

                FormPicker(
                    title: "Type de véhicule",
                    selection: $selectedItem,
                    items: items,
                    errorMessage: "Veuillez sélectionner un type",
                    showError: true
                )
            }
            .padding()
        }
    }

    return PreviewContainer()
}
