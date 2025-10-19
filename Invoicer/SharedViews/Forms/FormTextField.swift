//
//  FormTextField.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Reusable form text field component
//

import SwiftUI

/// Reusable text field component for forms
struct FormTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var errorMessage: String?
    var showError: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Label
            Text(title)
                .font(Typography.formLabel)
                .foregroundColor(ColorTokens.textSecondary)

            // Text Field
            TextField(placeholder, text: $text)
                .font(Typography.body)
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
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)

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

#Preview {
    VStack(spacing: Spacing.lg) {
        FormTextField(
            title: "Nom",
            text: .constant("Tesla"),
            placeholder: "Entrez le nom"
        )

        FormTextField(
            title: "Modèle",
            text: .constant(""),
            placeholder: "Entrez le modèle",
            errorMessage: "Ce champ est obligatoire",
            showError: true
        )
    }
    .padding()
}
