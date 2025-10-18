//
//  FormDatePicker.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Reusable form date picker component
//

import SwiftUI

/// Reusable date picker component for forms
struct FormDatePicker: View {
    let title: String
    @Binding var date: Date
    var displayedComponents: DatePicker.Components = [.date]
    var dateRange: ClosedRange<Date>?
    var errorMessage: String?
    var showError: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Label
            Text(title)
                .font(Typography.formLabel)
                .foregroundColor(ColorTokens.textSecondary)

            // Date Picker
            if let range = dateRange {
                DatePicker(
                    "",
                    selection: $date,
                    in: range,
                    displayedComponents: displayedComponents
                )
                .datePickerStyle(.compact)
                .labelsHidden()
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
            } else {
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: displayedComponents
                )
                .datePickerStyle(.compact)
                .labelsHidden()
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

#Preview {
    VStack(spacing: Spacing.lg) {
        FormDatePicker(
            title: "Date d'immatriculation",
            date: .constant(Date())
        )

        FormDatePicker(
            title: "Date du document",
            date: .constant(Date()),
            dateRange: Date.distantPast...Date(),
            errorMessage: "La date ne peut pas être dans le futur",
            showError: true
        )
    }
    .padding()
}
