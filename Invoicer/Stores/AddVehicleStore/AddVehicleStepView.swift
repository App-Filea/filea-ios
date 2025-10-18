//
//  AddVehicleStepView.swift
//  Invoicer
//
//  Created by Claude Code on 11/10/2025.
//

import SwiftUI
import ComposableArchitecture

private struct IsSelectedKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isSelected: Bool {
        get { self[IsSelectedKey.self] }
        set { self[IsSelectedKey.self] = newValue }
    }
}

extension View {
    func selected(_ isSelected: Bool) -> some View {
        environment(\.isSelected, isSelected)
    }
}

struct AddVehicleStepView: View {
    let step: AddVehicleStep
    @Bindable var store: StoreOf<AddVehicleStore>
    @State private var showDatePicker: Bool = false

    private var validationResult: (isValid: Bool, errorMessage: String?) {
        step.validate(
            type: store.vehicleType,
            brand: store.brand,
            model: store.model,
            plate: store.plate,
            registrationDate: store.registrationDate,
            mileage: store.mileage
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Content
            contentForStep
                .padding(.horizontal, Spacing.md)

            // Validation error
            if let errorMessage = validationResult.errorMessage, store.showValidationError {
                Text(errorMessage)
                    .bodyXSmallRegular()
                    .foregroundStyle(ColorTokens.error)
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.sm)
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(
                date: $store.registrationDate,
                onSave: {
                    showDatePicker = false
                },
                onCancel: {
                    showDatePicker = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var contentForStep: some View {
        switch step {
        case .type:
            vehicleTypeContent
        case .brandAndModel:
            brandAndModelContent
        case .details:
            detailsContent
        case .summary:
            summaryContent
        }
    }

    // MARK: - Step Contents

    private var vehicleTypeContent: some View {
        VStack(spacing: Spacing.md) {
            // Sélection du type de véhicule
            ForEach(VehicleType.allCases) { type in
                Button(action: {
                    if store.vehicleType == type {
                        store.vehicleType = nil
                    } else {
                        store.vehicleType = type
                    }
                }) {
                    HStack {
                        Text(type.displayName)
                            .font(Typography.button)
                            .foregroundStyle(store.vehicleType == type ? ColorTokens.onActionPrimary : ColorTokens.textPrimary)
                        Spacer()
                        Circle()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(.clear) // cercle de base transparent
                            .background(
                                Circle()
                                    .stroke(ColorTokens.border.opacity(0.5), lineWidth: 1) // bordure toujours visible
                            )
                            .overlay(
                                Group {
                                    if store.vehicleType == type {
                                        Image(systemName: "checkmark.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(ColorTokens.onActionPrimary)
                                    }
                                }
                            )
                    }
                    .padding(Spacing.md)
                    .background(
                        ZStack {
                            if store.vehicleType == type {
                                // Gradient background pour l'état sélectionné
                                RoundedRectangle(cornerRadius: Radius.md)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                ColorTokens.actionPrimary.opacity(0.8),
                                                ColorTokens.actionPrimary
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: ColorTokens.shadow, radius: Spacing.xs, x: 0, y: 4)
                            } else {
                                // Background non sélectionné avec effet glass
                                RoundedRectangle(cornerRadius: Radius.md)
                                    .fill(ColorTokens.surfaceSecondary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Radius.md)
                                            .stroke(ColorTokens.border.opacity(0.5), lineWidth: 1)
                                    )
                            }
                        }
                    )
                    .cornerRadius(8)
                }
            }

            // Séparateur
            Rectangle()
                .fill(ColorTokens.border)
                .frame(height: 1)
                .padding(.vertical, Spacing.sm)

            // Sélection Principal/Secondaire
            HStack(spacing: Spacing.md) {
                // Bouton Principal
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        store.isPrimary = true
                    }
                }) {
                    Text("Principal")
                        .bodyDefaultSemibold()
                        .foregroundStyle(store.isPrimary ? ColorTokens.onActionPrimary : ColorTokens.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.lg)
                        .background(
                            ZStack {
                                if store.isPrimary {
                                    // Gradient background pour l'état sélectionné
                                    RoundedRectangle(cornerRadius: Radius.md)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    ColorTokens.actionPrimary.opacity(0.9),
                                                    ColorTokens.actionPrimary
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: ColorTokens.shadow, radius: Spacing.xs, x: 0, y: 4)
                                } else {
                                    // Background non sélectionné avec effet glass
                                    RoundedRectangle(cornerRadius: Radius.md)
                                        .fill(ColorTokens.surfaceSecondary)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Radius.md)
                                                .stroke(ColorTokens.border.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                        )
                        .scaleEffect(store.isPrimary ? 1.0 : 0.98)
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: store.isPrimary)

                // Bouton Secondaire
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        store.isPrimary = false
                    }
                }) {
                    Text("Secondaire")
                        .bodyDefaultSemibold()
                        .foregroundStyle(!store.isPrimary ? ColorTokens.onActionPrimary : ColorTokens.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.lg)
                        .background(
                            ZStack {
                                if !store.isPrimary {
                                    // Gradient background pour l'état sélectionné
                                    RoundedRectangle(cornerRadius: Radius.md)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    ColorTokens.actionPrimary.opacity(0.9),
                                                    ColorTokens.actionPrimary
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: ColorTokens.actionPrimary.opacity(0.5), radius: Spacing.xs, x: 0, y: 4)
                                } else {
                                    // Background non sélectionné avec effet glass
                                    RoundedRectangle(cornerRadius: Radius.md)
                                        .fill(ColorTokens.surfaceSecondary)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Radius.md)
                                                .stroke(ColorTokens.border.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                        )
                        .scaleEffect(!store.isPrimary ? 1.0 : 0.98)
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: store.isPrimary)
            }
        }
    }

    private var brandAndModelContent: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Brand field
            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text("Marque")
                    .font(Typography.footnote)
                    .foregroundStyle(ColorTokens.textSecondary)

                HStack(alignment: .top, spacing: Spacing.xxs) {
                    Image(systemName: "info.circle")
                        .font(Typography.caption2)
                        .foregroundStyle(ColorTokens.textTertiary)

                    Text("Champ D.1 de la carte grise")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorTokens.textTertiary)
                }
                .padding(.bottom, Spacing.xxs)

                TextField("TOYOTA, BMW, MERCEDES...", text: $store.brand)
                    .bodyDefaultRegular()
                    .foregroundColor(ColorTokens.textPrimary)
                    .accentColor(ColorTokens.actionPrimary)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .stroke(!validationResult.isValid && store.showValidationError && store.brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? ColorTokens.error : ColorTokens.border, lineWidth: 2)
                            .animation(.easeInOut(duration: 0.3), value: !validationResult.isValid && store.showValidationError)
                    )
                    .submitLabel(.next)
                    .autocapitalization(.allCharacters)
            }

            // Model field
            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text("Modèle")
                    .font(Typography.footnote)
                    .foregroundStyle(ColorTokens.textSecondary)

                HStack(alignment: .top, spacing: Spacing.xxs) {
                    Image(systemName: "info.circle")
                        .font(Typography.caption2)
                        .foregroundStyle(ColorTokens.textTertiary)

                    Text("Champ D.2 de la carte grise")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorTokens.textTertiary)
                }
                .padding(.bottom, Spacing.xxs)

                TextField("COROLLA, X3, CLASSE A...", text: $store.model)
                    .bodyDefaultRegular()
                    .foregroundColor(ColorTokens.textPrimary)
                    .accentColor(ColorTokens.actionPrimary)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .stroke(!validationResult.isValid && store.showValidationError && store.model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? ColorTokens.error : ColorTokens.border, lineWidth: 2)
                            .animation(.easeInOut(duration: 0.3), value: !validationResult.isValid && store.showValidationError)
                    )
                    .submitLabel(.next)
                    .autocapitalization(.allCharacters)
            }
        }
        .padding(Spacing.md)
        .background(ColorTokens.surfacePrimary)
        .cornerRadius(Radius.md)
    }

    private var detailsContent: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Plate field
            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text("Immatriculation")
                    .font(Typography.footnote)
                    .foregroundStyle(ColorTokens.textSecondary)

                HStack(alignment: .top, spacing: Spacing.xxs) {
                    Image(systemName: "info.circle")
                        .font(Typography.caption2)
                        .foregroundStyle(ColorTokens.textTertiary)

                    Text("Champ A de la carte grise")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorTokens.textTertiary)
                }
                .padding(.bottom, Spacing.xxs)

                TextField("AB-123-CD", text: $store.plate)
                    .bodyDefaultRegular()
                    .foregroundColor(ColorTokens.textPrimary)
                    .accentColor(ColorTokens.actionPrimary)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .stroke(!validationResult.isValid && store.showValidationError && store.plate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? ColorTokens.error : ColorTokens.border, lineWidth: 2)
                            .animation(.easeInOut(duration: 0.3), value: !validationResult.isValid && store.showValidationError)
                    )
                    .submitLabel(.next)
                    .autocapitalization(.allCharacters)
            }

            // Mileage field
            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text("Kilométrage")
                    .font(Typography.footnote)
                    .foregroundStyle(ColorTokens.textSecondary)

                HStack(alignment: .top, spacing: Spacing.xxs) {
                    Image(systemName: "info.circle")
                        .font(Typography.caption2)
                        .foregroundStyle(ColorTokens.textTertiary)

                    Text("Consultez votre compteur")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorTokens.textTertiary)
                }
                .padding(.bottom, Spacing.xxs)

                HStack {
                    TextField("120000", text: $store.mileage)
                        .bodyDefaultRegular()
                        .foregroundColor(ColorTokens.textPrimary)
                        .accentColor(ColorTokens.actionPrimary)
                        .textFieldStyle(.plain)

                    Text("KM")
                        .bodyDefaultRegular()
                        .foregroundColor(ColorTokens.textSecondary)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(ColorTokens.border, lineWidth: 2)
                )
            }

            // Date field
            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text("Mise en circulation")
                    .font(Typography.footnote)
                    .foregroundStyle(ColorTokens.textSecondary)

                HStack(alignment: .top, spacing: Spacing.xxs) {
                    Image(systemName: "info.circle")
                        .font(Typography.caption2)
                        .foregroundStyle(ColorTokens.textTertiary)

                    Text("Champ B de la carte grise")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorTokens.textTertiary)
                }
                .padding(.bottom, Spacing.xxs)

                Button(action: {
                    showDatePicker = true
                }) {
                    HStack {
                        Text(formatDate(store.registrationDate))
                            .bodyDefaultRegular()
                            .foregroundStyle(ColorTokens.textPrimary)

                        Spacer()

                        Image(systemName: "calendar")
                            .foregroundStyle(ColorTokens.textSecondary)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .fill(ColorTokens.surfaceSecondary)
                            .stroke(ColorTokens.border, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.md)
        .background(ColorTokens.surfacePrimary)
        .cornerRadius(Radius.md)
    }

    private var summaryContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            if let vehicleType = store.vehicleType {
                summaryRow(title: "Type", value: vehicleType.displayName, icon: vehicleType.iconName, iconFlipped: vehicleType.shouldFlipIcon)
            }
            summaryRow(title: "Marque", value: store.brand, icon: nil)
            summaryRow(title: "Modèle", value: store.model, icon: nil)
            summaryRow(title: "Plaque", value: store.plate, icon: "number")
            summaryRow(title: "Kilométrage", value: store.mileage.isEmpty ? "Non renseigné" : "\(store.mileage) KM", icon: "gauge")
            summaryRow(title: "Date de mise en circulation", value: formatDate(store.registrationDate), icon: "calendar")
        }
        .padding(.vertical, Spacing.md)
    }

    private func summaryRow(title: String, value: String, icon: String?, iconFlipped: Bool = false) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(Typography.title3)
                    .foregroundStyle(ColorTokens.actionPrimary)
                    .frame(width: 28)
                    .scaleEffect(x: iconFlipped ? -1 : 1, y: 1)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .bodyXSmallSemibold()
                    .foregroundStyle(ColorTokens.textSecondary)

                Text(value)
                    .bodyDefaultSemibold()
                    .foregroundStyle(ColorTokens.textPrimary)
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(ColorTokens.surfaceSecondary)
        )
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

// MARK: - Previews

#Preview("Type Step") {
    AddVehicleStepView(
        step: .type,
        store: Store(initialState: AddVehicleStore.State()) {
            AddVehicleStore()
        }
    )
    .padding(.vertical)
    .background(ColorTokens.background)
}

#Preview("Brand and Model Step") {
    AddVehicleStepView(
        step: .brandAndModel,
        store: Store(initialState: AddVehicleStore.State()) {
            AddVehicleStore()
        }
    )
}

#Preview("Details Step") {
    AddVehicleStepView(
        step: .details,
        store: Store(initialState: AddVehicleStore.State()) {
            AddVehicleStore()
        }
    )
}

#Preview("Summary Step") {
    var state = AddVehicleStore.State()
    state.vehicleType = .car
    state.brand = "TOYOTA"
    state.model = "COROLLA"
    state.mileage = "120000"
    state.registrationDate = Date(timeIntervalSince1970: 1577836800)
    state.plate = "AB-123-CD"

    return AddVehicleStepView(
        step: .summary,
        store: Store(initialState: state) {
            AddVehicleStore()
        }
    )
}

#Preview("With Validation Error") {
    var state = AddVehicleStore.State()
    state.showValidationError = true

    return AddVehicleStepView(
        step: .brandAndModel,
        store: Store(initialState: state) {
            AddVehicleStore()
        }
    )
}
