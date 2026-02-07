//
//  DocumentFormView.swift
//  Holfy
//
//  Created by Nicolas Barbosa on 07/02/2026.
//

import SwiftUI
import ComposableArchitecture

struct DocumentFormView: View {
    init(type: Binding<DocumentType>,
         isExpirationDateEnabled: Bool = false,
         date: Binding<Date>,
         expirationDate: Binding<Date>,
         mileage: Binding<String>,
         amount: Binding<String>,
         name: Binding<String>,
         primaryAction: @escaping () -> Void,
         secondaryAction: @escaping () -> Void) {
        self._type = type
        self.isExpirationDateEnabled = isExpirationDateEnabled
        self._date = date
        self._expirationDate = expirationDate
        self._mileage = mileage
        self._amount = amount
        self._name = name
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    @Binding var type: DocumentType
    var isExpirationDateEnabled: Bool
    @Binding var date: Date
    @Binding var expirationDate: Date
    @Binding var mileage: String
    @Binding var amount: String
    @Binding var name: String
    var primaryAction: () -> Void
    var secondaryAction: () -> Void

    enum FocusedField: Hashable {
        case mileage, amount, name
    }

    @FocusState private var focusedField: FocusedField?
    @Shared(.selectedCurrency) var currency: Currency
    @Shared(.selectedDistanceUnit) var distanceUnit: DistanceUnit
    @State private var validationErrors: DocumentFieldsValidationErrors = []

    var body: some View {
        Form {
            Section {
                Picker("document_form_type_label", selection: $type) {
                    ForEach(DocumentType.allCases) { docType in
                        Text(docType.displayName)
                            .tag(docType)
                    }
                }
                .pickerStyle(.menu)
            } header: {
                Text("document_form_type_title")
            }
            .listRowBackground(Color(.secondarySystemBackground))

            Section {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    DatePicker(
                        "document_form_date_label",
                        selection: $date,
                        in: Date.distantPast...Date(),
                        displayedComponents: .date
                    )
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "info.circle")
                        Text("document_form_date_hint")
                    }
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                }

                if isExpirationDateEnabled {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        DatePicker(
                            "document_form_expiration_date_label",
                            selection: $expirationDate,
                            in: date...,
                            displayedComponents: .date
                        )
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "info.circle")
                            Text("document_form_expiration_date_hint")
                        }
                        .font(.caption2)
                        .foregroundStyle(Color.secondary)
                    }
                }
            } header: {
                Text("document_form_date_title")
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            .listRowBackground(Color(.secondarySystemBackground))

            Section {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    LabeledContent("document_form_mileage_label") {
                        HStack {
                            TextField("document_form_mileage_placeholder", text: $mileage)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .mileage)
                                .multilineTextAlignment(.trailing)

                            Text(distanceUnit.symbol)
                                .foregroundStyle(.secondary)
                        }
                    }
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "info.circle")
                        Text("document_form_mileage_hint")
                    }
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    LabeledContent("document_form_amount_label") {
                        HStack {
                            TextField("document_form_amount_placeholder", text: $amount)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .amount)
                                .multilineTextAlignment(.trailing)

                            Text(currency.symbol)
                                .foregroundStyle(.secondary)
                        }
                    }
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "info.circle")
                        Text("document_form_amount_hint")
                    }
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                }
            } header: {
                Text("document_form_details_title")
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            .listRowBackground(Color(.secondarySystemBackground))

            Section {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    TextField("document_form_name_placeholder", text: $name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                        .overlay(alignment: .trailing) {
                            validationIcon(hasError: validationErrors.contains(.nameEmpty),
                                           value: name)
                        }
                }
            } header: {
                Text("document_form_name_title")
            } footer: {
                if hasValidationErrors {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        if validationErrors.contains(.nameEmpty) && name.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text("document_form_name_error")
                        }
                    }
                    .foregroundStyle(.red)
                }
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            .listRowBackground(Color(.secondarySystemBackground))

            VStack(spacing: Spacing.md) {
                PrimaryButton("all_save", action: {
                    validateFields()
                    if validationErrors.isEmpty {
                        primaryAction()
                    }
                })

                TertiaryButton("all_cancel", action: {
                    secondaryAction()
                })
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .padding(.horizontal, -16)
        }
        .background(Color(.systemBackground))
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                if focusedField == .mileage || focusedField == .amount {
                    Button("keyboard_next_button") {
                        switch focusedField {
                        case .mileage: focusedField = .amount
                        case .amount: focusedField = .name
                        default: break
                        }
                    }
                }
            }
        }
    }

    private var hasValidationErrors: Bool {
        validationErrors.contains(.nameEmpty) && name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func validateFields() {
        withAnimation {
            if name.trimmingCharacters(in: .whitespaces).isEmpty {
                validationErrors.insert(.nameEmpty)
            } else {
                validationErrors.remove(.nameEmpty)
            }
        }
    }

    @ViewBuilder
    private func validationIcon(hasError: Bool, value: String) -> some View {
        let isValid = !value.trimmingCharacters(in: .whitespaces).isEmpty
        if #available(iOS 26.0, *) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(isValid ? .green : .red)
                .symbolEffect(.drawOn.individually, options: .nonRepeating, isActive: !hasError)
                .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
        } else {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(isValid ? .green : .red)
                .symbolEffect(.appear, options: .nonRepeating, isActive: !hasError)
                .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
        }
    }
}

struct DocumentFieldsValidationErrors: OptionSet, Sendable, Equatable {
    let rawValue: Int

    static let nameEmpty = DocumentFieldsValidationErrors(rawValue: 1 << 0)
}

#Preview {
    NavigationView {
        DocumentFormView(
            type: .constant(.technicalInspection),
            isExpirationDateEnabled: true,
            date: .constant(Date()),
            expirationDate: .constant(Date().addingTimeInterval(86400 * 365 * 2)),
            mileage: .constant("85000"),
            amount: .constant("79.90"),
            name: .constant("Controle technique 2026"),
            primaryAction: { print("Save tapped") },
            secondaryAction: { print("Cancel tapped") }
        )
        .navigationTitle("Nouveau document")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Empty Form") {
    NavigationView {
        DocumentFormView(
            type: .constant(.maintenance),
            date: .constant(Date()),
            expirationDate: .constant(Date()),
            mileage: .constant(""),
            amount: .constant(""),
            name: .constant(""),
            primaryAction: { },
            secondaryAction: { }
        )
        .navigationTitle("Nouveau document")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("With Expiration Date") {
    NavigationView {
        DocumentFormView(
            type: .constant(.other),
            isExpirationDateEnabled: true,
            date: .constant(Date()),
            expirationDate: .constant(Date().addingTimeInterval(86400 * 30)),
            mileage: .constant("120000"),
            amount: .constant("85.50"),
            name: .constant("Document avec expiration"),
            primaryAction: { },
            secondaryAction: { }
        )
        .navigationTitle("Modifier document")
        .navigationBarTitleDisplayMode(.inline)
    }
}
