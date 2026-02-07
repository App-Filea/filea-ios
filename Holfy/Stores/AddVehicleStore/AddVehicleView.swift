//
//  AddVehicleView2.swift
//  Invoicer
//
//  Created by Claude Code on 04/02/2026.
//

import SwiftUI
import ComposableArchitecture

struct AddVehicleView: View {
    @Bindable var store: StoreOf<AddVehicleStore>
    
    var body: some View {
        NavigationStack {
            VehicleFormView(type: $store.type,
                            isPrimary: $store.isPrimary,
                            brand: $store.brand,
                            model: $store.model,
                            plate: $store.plate,
                            mileage: $store.mileage,
                            registrationDate: $store.registrationDate,
                            primaryAction: { store.send(.view(.saveButtonTapped)) },
                            secondaryAction: { store.send(.view(.cancelButtonTapped)) })
            .navigationTitle("add_vehicle_title")
            .navigationBarTitleDisplayMode(.inline)
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

#Preview {
    AddVehicleView(store: Store(initialState: AddVehicleStore.State()) {
        AddVehicleStore()
    })
}

struct VehicleFormView: View {
    init(type: Binding<VehicleType>,
         isPrimary: Binding<Bool>,
         brand: Binding<String>,
         model: Binding<String>,
         plate: Binding<String>,
         mileage: Binding<String>,
         registrationDate: Binding<Date>,
         primaryAction: @escaping () -> Void,
         secondaryAction: @escaping () -> Void) {
        self._type = type
        self._isPrimary = isPrimary
        self._brand = brand
        self._model = model
        self._plate = plate
        self._mileage = mileage
        self._registrationDate = registrationDate
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
    
    @Binding var type: VehicleType
    @Binding var isPrimary: Bool
    @Binding var brand: String
    @Binding var model: String
    @Binding var plate: String
    @Binding var mileage: String
    @Binding var registrationDate: Date
    var primaryAction: () -> Void
    var secondaryAction: () -> Void
    
    enum FocusedField: Hashable {
        case brand, model, plate, mileage
    }
    
    @FocusState private var focusedField: FocusedField?
    @Shared(.selectedDistanceUnit) var distanceUnit: DistanceUnit
    @State private var validationErrors: VehicleFieldsValidationErrors = []
    
    var body: some View {
        Form {
            Section {
                Picker("vehicle_form_type_label", selection: $type) {
                    ForEach(VehicleType.allCases) { type in
                        Text(type.displayName)
                            .tag(type)
                    }
                }
                .pickerStyle(.menu)
                
                Picker("vehicle_form_usage_label", selection: $isPrimary) {
                    Text("vehicle_form_usage_primary").tag(true)
                    Text("vehicle_form_usage_secondary").tag(false)
                }
                .pickerStyle(.menu)
            } header: {
                Text("vehicle_form_general_title")
            }
            .listRowBackground(Color(.secondarySystemBackground))

            Section {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    TextField("vehicle_form_brand_placeholder", text: $brand)
                        .autocapitalization(.allCharacters)
                        .focused($focusedField, equals: .brand)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .model }
                        .overlay(alignment: .trailing) {
                            validationIcon(hasError: validationErrors.contains(.brandEmpty),
                                           value: brand)
                        }
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "info.circle")
                        Text("vehicle_form_brand_hint")
                    }
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                }
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    TextField("vehicle_form_model_placeholder", text: $model)
                        .autocapitalization(.allCharacters)
                        .focused($focusedField, equals: .model)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .plate }
                        .overlay(alignment: .trailing) {
                            validationIcon(hasError: validationErrors.contains(.modelEmpty),
                                           value: model)
                        }
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "info.circle")
                        Text("vehicle_form_model_hint")
                    }
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                }
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    TextField("vehicle_form_plate_placeholder", text: $plate)
                        .autocapitalization(.allCharacters)
                        .focused($focusedField, equals: .plate)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .mileage }
                        .overlay(alignment: .trailing) {
                            validationIcon(hasError: validationErrors.contains(.plateEmpty),
                                           value: plate)
                        }
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "info.circle")
                        Text("vehicle_form_plate_hint")
                    }
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                }
            } header: {
                Text("vehicle_form_brand_title")
            } footer: {
                if hasValidationErrors {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        if validationErrors.contains(.brandEmpty) && brand.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text("La marque ne peut pas être vide.")
                        }
                        if validationErrors.contains(.modelEmpty) && model.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text("Le modèle ne peut pas être vide.")
                        }
                        if validationErrors.contains(.plateEmpty) && plate.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text("L'immatriculation ne peut pas être vide.")
                        }
                    }
                    .foregroundStyle(.red)
                }
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            .listRowBackground(Color(.secondarySystemBackground))
            
            Section {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    LabeledContent("vehicle_form_mileage_label") {
                        HStack {
                            TextField("vehicle_form_mileage_placeholder", text: $mileage)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .mileage)
                                .multilineTextAlignment(.trailing)
                            
                            Text(distanceUnit.symbol)
                                .foregroundStyle(.secondary)
                        }
                    }
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "info.circle")
                        Text("vehicle_form_mileage_hint")
                    }
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                }
                
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    DatePicker(
                        "vehicle_form_date_label",
                        selection: $registrationDate,
                        displayedComponents: .date
                    )
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "info.circle")
                        Text("vehicle_form_date_hint")
                    }
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                }
            } header: {
                Text("vehicle_form_state_title")
            }
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
    }
    
    private var hasValidationErrors: Bool {
        (validationErrors.contains(.brandEmpty) && brand.trimmingCharacters(in: .whitespaces).isEmpty) ||
        (validationErrors.contains(.modelEmpty) && model.trimmingCharacters(in: .whitespaces).isEmpty) ||
        (validationErrors.contains(.plateEmpty) && plate.trimmingCharacters(in: .whitespaces).isEmpty)
    }
    
    private func validateFields() {
        withAnimation {
            if brand.trimmingCharacters(in: .whitespaces).isEmpty {
                validationErrors.insert(.brandEmpty)
            } else {
                validationErrors.remove(.brandEmpty)
            }
            if model.trimmingCharacters(in: .whitespaces).isEmpty {
                validationErrors.insert(.modelEmpty)
            } else {
                validationErrors.remove(.modelEmpty)
            }
            if plate.trimmingCharacters(in: .whitespaces).isEmpty {
                validationErrors.insert(.plateEmpty)
            } else {
                validationErrors.remove(.plateEmpty)
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

struct VehicleFieldsValidationErrors: OptionSet, Sendable, Equatable {
    let rawValue: Int
    
    static let brandEmpty = VehicleFieldsValidationErrors(rawValue: 1 << 0)
    static let modelEmpty = VehicleFieldsValidationErrors(rawValue: 1 << 1)
    static let plateEmpty = VehicleFieldsValidationErrors(rawValue: 1 << 2)
}
