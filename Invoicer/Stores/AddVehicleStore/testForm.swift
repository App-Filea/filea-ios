//
//  testForm.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 22/10/2025.
//

import SwiftUI

struct TestForm: View {
    // MARK: - State
    @State private var vehicleType: VehicleType = .car
    @State private var brand: String = ""
    @State private var model: String = ""
    @State private var plate: String = ""
    @State private var mileage: String = ""
    @State private var registrationDate: Date = .now
    @State private var isPrimary: Bool = false

    // MARK: - Animation & Focus
    @Namespace private var animation
    @FocusState private var focusedField: Field?

    // MARK: - Button State
    @State private var isFormValid: Bool = false
    @State private var isSubmitting: Bool = false
    @State private var submitSuccess: Bool = false

    // MARK: - Field Enum
    enum Field: Hashable {
        case brand, model, plate, mileage
    }

    // MARK: - Computed Properties for Validation
    private var isBrandValid: Bool { !brand.isEmpty && brand.count >= 2 }
    private var isModelValid: Bool { !model.isEmpty && model.count >= 2 }
    private var isPlateValid: Bool { !plate.isEmpty && plate.count >= 2 }

    private var formProgress: Double {
        let fields = [isBrandValid, isModelValid, isPlateValid]
        return Double(fields.filter { $0 }.count) / Double(fields.count)
    }

    // MARK: - Contextual Labels (Amélioration 5)
    private var mileageLabel: String {
        switch vehicleType {
        case .car, .motorcycle, .truck:
            return "Kilométrage"
        case .bicycle:
            return "Distance parcourue"
        case .other:
            return "Compteur"
        }
    }

    private var mileageUnit: String {
        switch vehicleType {
        case .car, .motorcycle, .truck, .bicycle:
            return "km"
        case .other:
            return "unités"
        }
    }

    private var platePlaceholder: String {
        switch vehicleType {
        case .car, .motorcycle, .truck:
            return "AB-123-CD"
        case .bicycle, .other:
            return "Numéro de série"
        }
    }

    // MARK: - Functions
    private func updateFormValidity() {
        withAnimation(.spring(response: 0.3)) {
            isFormValid = isBrandValid && isModelValid && isPlateValid
        }
    }

    private func submitForm() {
        isSubmitting = true

        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.3)) {
                isSubmitting = false
                submitSuccess = true
            }

            // Reset success state after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                submitSuccess = false
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Type Section (Amélioration 1)
                Section {
                    Picker("Type de véhicule", selection: $vehicleType) {
                        ForEach(VehicleType.allCases) { type in
                            HStack {
                                    Image(systemName: type.iconName)
                                        .foregroundStyle(ColorTokens.actionPrimary)
                                Text(type.displayName)
                                    .foregroundStyle(ColorTokens.textPrimary)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: vehicleType) { _, _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {}
                    }

                    // Visual feedback card
                    HStack(spacing: Spacing.md) {
                            Image(systemName: vehicleType.iconName)
                                .font(.system(size: 32))
                                .foregroundStyle(ColorTokens.actionPrimary)
                                .symbolEffect(.bounce, value: vehicleType)
                                .matchedGeometryEffect(id: "vehicleIcon", in: animation)

                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text(vehicleType.displayName)
                                .font(Typography.headline)
                                .foregroundStyle(ColorTokens.textPrimary)

                            Text("Type sélectionné")
                                .font(Typography.caption1)
                                .foregroundStyle(ColorTokens.textSecondary)
                        }
                    }
                    .padding(Spacing.md)
                    .background(ColorTokens.actionPrimary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
                } header: {
                    Text("Type")
                        .foregroundStyle(ColorTokens.textSecondary)
                }

                // MARK: - Information Section (Amélioration 2 & 3 & 5)
                Section {
                    // Marque field with validation
                    HStack {
                        TextField("Marque", text: $brand)
                            .foregroundStyle(ColorTokens.textPrimary)
                            .focused($focusedField, equals: .brand)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .model }

                        if !brand.isEmpty {
                            Image(systemName: isBrandValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundStyle(isBrandValid ? ColorTokens.success : ColorTokens.warning)
                                .symbolEffect(.bounce, value: isBrandValid)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.3), value: brand)

                    // Modèle field with validation
                    HStack {
                        TextField("Modèle", text: $model)
                            .foregroundStyle(ColorTokens.textPrimary)
                            .focused($focusedField, equals: .model)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .plate }

                        if !model.isEmpty {
                            Image(systemName: isModelValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundStyle(isModelValid ? ColorTokens.success : ColorTokens.warning)
                                .symbolEffect(.bounce, value: isModelValid)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.3), value: model)

                    // Plaque field with validation and contextual placeholder
                    HStack {
                        TextField(platePlaceholder, text: $plate)
                            .foregroundStyle(ColorTokens.textPrimary)
                            .textInputAutocapitalization(vehicleType == .car || vehicleType == .motorcycle || vehicleType == .truck ? .characters : .none)
                            .focused($focusedField, equals: .plate)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .mileage }
                            .id("plate-\(vehicleType.rawValue)")

                        if !plate.isEmpty {
                            Image(systemName: isPlateValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundStyle(isPlateValid ? ColorTokens.success : ColorTokens.warning)
                                .symbolEffect(.bounce, value: isPlateValid)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.3), value: plate)

                    DatePicker(
                        "Date d'immatriculation",
                        selection: $registrationDate,
                        displayedComponents: .date
                    )
                    .foregroundStyle(ColorTokens.textPrimary)
                } header: {
                    HStack {
                        Text("Informations")
                            .foregroundStyle(ColorTokens.textSecondary)
                        Spacer()
                        Text("\(Int(formProgress * 100))%")
                            .font(Typography.caption2)
                            .foregroundStyle(ColorTokens.textTertiary)
                            .contentTransition(.numericText())
                    }
                }

                // MARK: - Details Section (Amélioration 3 & 5)
                Section {
                    // Mileage field with contextual label
                    HStack {
                        TextField(mileageLabel, text: $mileage)
                            .foregroundStyle(ColorTokens.textPrimary)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .mileage)
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }

                        Text(mileageUnit)
                            .font(Typography.caption1)
                            .foregroundStyle(ColorTokens.textSecondary)
                            .contentTransition(.interpolate)
                    }
                    .animation(.smooth(duration: 0.3), value: vehicleType)

                    Toggle("Véhicule principal", isOn: $isPrimary)
                        .foregroundStyle(ColorTokens.textPrimary)
                        .tint(ColorTokens.actionPrimary)
                } header: {
                    Text("Détails")
                        .foregroundStyle(ColorTokens.textSecondary)
                } footer: {
                    Text("Le véhicule principal sera affiché en premier dans la liste")
                        .foregroundStyle(ColorTokens.textTertiary)
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(ColorTokens.background)
            .navigationTitle("Nouveau véhicule")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: brand) { _, _ in updateFormValidity() }
            .onChange(of: model) { _, _ in updateFormValidity() }
            .onChange(of: plate) { _, _ in updateFormValidity() }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        // Cancel action
                    }
                    .foregroundStyle(ColorTokens.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        submitForm()
                    } label: {
                        HStack(spacing: Spacing.xxs) {
                            if isSubmitting {
                                ProgressView()
                                    .tint(ColorTokens.actionPrimary)
                                    .transition(.scale.combined(with: .opacity))
                            } else if submitSuccess {
                                Image(systemName: "checkmark")
                                    .symbolEffect(.bounce)
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Text("Ajouter")
                                    .transition(.opacity)
                            }
                        }
                        .animation(.spring(response: 0.3), value: isSubmitting)
                        .animation(.spring(response: 0.3), value: submitSuccess)
                    }
                    .foregroundStyle(isFormValid ? ColorTokens.actionPrimary : ColorTokens.textTertiary)
                    .fontWeight(.semibold)
                    .disabled(!isFormValid || isSubmitting)
                    .scaleEffect(isFormValid ? 1.0 : 0.95)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFormValid)
                    .sensoryFeedback(.success, trigger: submitSuccess)
                }
            }
        }
    }
}

#Preview {
    TestForm()
}
