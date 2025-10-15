//
//  AddVehicleStepView.swift
//  Invoicer
//
//  Created by Claude Code on 11/10/2025.
//

import SwiftUI
import ComposableArchitecture

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
                .padding(.horizontal, .gutterMD)

            // Validation error
            if let errorMessage = validationResult.errorMessage, store.showValidationError {
                Text(errorMessage)
                    .bodyXSmallRegular()
                    .foregroundStyle(Color.red)
                    .padding(.horizontal, .gutterMD)
                    .padding(.bottom, .stackSM)
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
        VStack(spacing: .stackMD) {
            // Sélection du type de véhicule
            ForEach(VehicleType.allCases) { type in
                Button(action: {
                    store.vehicleType = type
                }) {
                    HStack(spacing: .inlineMD) {
                        if let iconName = type.iconName {
                            Image(systemName: iconName)
                                .font(.title2)
                                .foregroundStyle(store.vehicleType == type ? Color.white : Color(.label))
                                .scaleEffect(x: type.shouldFlipIcon ? -1 : 1, y: 1)
                        }

                        Text(type.displayName)
                            .bodyDefaultSemibold()
                            .foregroundStyle(store.vehicleType == type ? Color.white : Color(.label))

                        Spacer()

                        if store.vehicleType == type {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.white)
                        }
                    }
                    .padding(.horizontal, .insetLG)
                    .padding(.vertical, .insetLG)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(store.vehicleType == type ? Color(.systemPurple) : Color(.secondarySystemBackground))
                            .stroke(store.vehicleType == type ? Color(.systemPurple) : Color(.separator), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }

            // Séparateur
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 1)
                .padding(.vertical, .stackSM)

            // Sélection Principal/Secondaire
            HStack(spacing: .inlineMD) {
                // Bouton Principal
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        store.isPrimary = true
                    }
                }) {
                    Text("Principal")
                        .bodyDefaultSemibold()
                        .foregroundStyle(store.isPrimary ? Color.white : Color(.label))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, .insetLG)
                        .padding(.vertical, .insetLG)
                        .background(
                            ZStack {
                                if store.isPrimary {
                                    // Gradient background pour l'état sélectionné
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.purple.opacity(0.9),
                                                    Color.purple
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color.purple.opacity(0.4), radius: 8, x: 0, y: 4)
                                } else {
                                    // Background non sélectionné avec effet glass
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.secondarySystemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
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
                        .foregroundStyle(!store.isPrimary ? Color.white : Color(.label))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, .insetLG)
                        .padding(.vertical, .insetLG)
                        .background(
                            ZStack {
                                if !store.isPrimary {
                                    // Gradient background pour l'état sélectionné
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.purple.opacity(0.9),
                                                    Color.purple
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color.purple.opacity(0.4), radius: 8, x: 0, y: 4)
                                } else {
                                    // Background non sélectionné avec effet glass
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.secondarySystemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
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
        VStack(alignment: .leading, spacing: 16) {
            // Brand field
            VStack(alignment: .leading, spacing: 2) {
                Text("Marque")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.secondaryLabel))

                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                        .foregroundStyle(Color(.tertiaryLabel))

                    Text("Champ D.1 de la carte grise")
                        .font(.caption)
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.bottom, 4)

                TextField("TOYOTA, BMW, MERCEDES...", text: $store.brand)
                    .bodyDefaultRegular()
                    .foregroundColor(Color(.label))
                    .accentColor(Color.purple)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(!validationResult.isValid && store.showValidationError && store.brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.red : Color(.separator), lineWidth: 2)
                            .animation(.easeInOut(duration: 0.3), value: !validationResult.isValid && store.showValidationError)
                    )
                    .submitLabel(.next)
                    .autocapitalization(.allCharacters)
            }

            // Model field
            VStack(alignment: .leading, spacing: 2) {
                Text("Modèle")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.secondaryLabel))

                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                        .foregroundStyle(Color(.tertiaryLabel))

                    Text("Champ D.2 de la carte grise")
                        .font(.caption)
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.bottom, 4)

                TextField("COROLLA, X3, CLASSE A...", text: $store.model)
                    .bodyDefaultRegular()
                    .foregroundColor(Color(.label))
                    .accentColor(Color.purple)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(!validationResult.isValid && store.showValidationError && store.model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.red : Color(.separator), lineWidth: 2)
                            .animation(.easeInOut(duration: 0.3), value: !validationResult.isValid && store.showValidationError)
                    )
                    .submitLabel(.next)
                    .autocapitalization(.allCharacters)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var detailsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Plate field
            VStack(alignment: .leading, spacing: 2) {
                Text("Immatriculation")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.secondaryLabel))

                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                        .foregroundStyle(Color(.tertiaryLabel))

                    Text("Champ A de la carte grise")
                        .font(.caption)
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.bottom, 4)

                TextField("AB-123-CD", text: $store.plate)
                    .bodyDefaultRegular()
                    .foregroundColor(Color(.label))
                    .accentColor(Color.purple)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(!validationResult.isValid && store.showValidationError && store.plate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.red : Color(.separator), lineWidth: 2)
                            .animation(.easeInOut(duration: 0.3), value: !validationResult.isValid && store.showValidationError)
                    )
                    .submitLabel(.next)
                    .autocapitalization(.allCharacters)
            }

            // Mileage field
            VStack(alignment: .leading, spacing: 2) {
                Text("Kilométrage")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.secondaryLabel))

                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                        .foregroundStyle(Color(.tertiaryLabel))

                    Text("Consultez votre compteur")
                        .font(.caption)
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.bottom, 4)

                HStack {
                    TextField("120000", text: $store.mileage)
                        .bodyDefaultRegular()
                        .foregroundColor(Color(.label))
                        .accentColor(Color.purple)
                        .textFieldStyle(.plain)

                    Text("KM")
                        .bodyDefaultRegular()
                        .foregroundColor(Color(.secondaryLabel))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator), lineWidth: 2)
                )
            }

            // Date field
            VStack(alignment: .leading, spacing: 2) {
                Text("Mise en circulation")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.secondaryLabel))

                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                        .foregroundStyle(Color(.tertiaryLabel))

                    Text("Champ B de la carte grise")
                        .font(.caption)
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.bottom, 4)

                Button(action: {
                    showDatePicker = true
                }) {
                    HStack {
                        Text(formatDate(store.registrationDate))
                            .bodyDefaultRegular()
                            .foregroundStyle(Color(.label))

                        Spacer()

                        Image(systemName: "calendar")
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .padding(.horizontal, .insetLG)
                    .padding(.vertical, .insetLG)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                            .stroke(Color(.separator), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var summaryContent: some View {
        VStack(alignment: .leading, spacing: .stackLG) {
            if let vehicleType = store.vehicleType {
                summaryRow(title: "Type", value: vehicleType.displayName, icon: vehicleType.iconName, iconFlipped: vehicleType.shouldFlipIcon)
            }
            summaryRow(title: "Marque", value: store.brand, icon: nil)
            summaryRow(title: "Modèle", value: store.model, icon: nil)
            summaryRow(title: "Plaque", value: store.plate, icon: "number")
            summaryRow(title: "Kilométrage", value: store.mileage.isEmpty ? "Non renseigné" : "\(store.mileage) KM", icon: "gauge")
            summaryRow(title: "Date de mise en circulation", value: formatDate(store.registrationDate), icon: "calendar")
        }
        .padding(.vertical, .stackMD)
    }

    private func summaryRow(title: String, value: String, icon: String?, iconFlipped: Bool = false) -> some View {
        HStack(alignment: .top, spacing: .inlineMD) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Color.purple)
                    .frame(width: 28)
                    .scaleEffect(x: iconFlipped ? -1 : 1, y: 1)
            }

            VStack(alignment: .leading, spacing: .stackXS) {
                Text(title)
                    .bodyXSmallSemibold()
                    .foregroundStyle(Color(.secondaryLabel))

                Text(value)
                    .bodyDefaultSemibold()
                    .foregroundStyle(Color(.label))
            }

            Spacer()
        }
        .padding(.horizontal, .insetLG)
        .padding(.vertical, .insetMD)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
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
