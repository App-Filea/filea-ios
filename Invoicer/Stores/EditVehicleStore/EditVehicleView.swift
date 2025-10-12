//
//  EditVehicleView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct EditVehicleView: View {
    @Bindable var store: StoreOf<EditVehicleStore>
    @State private var openDateSheet: Bool = false
    @State private var validationErrors: [String: String] = [:]
    @FocusState private var focusedField: Field?

    private let horizontalPadding: CGFloat = 20

    enum Field: Hashable {
        case brand, model, plate, mileage
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }

    private var isFormValid: Bool {
        !store.brand.isEmpty &&
        !store.model.isEmpty &&
        !store.plate.isEmpty
    }

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text("Modifier mon véhicule")
                        .titleLarge()
                        .foregroundStyle(Color("onBackground"))

                    Text("Modifiez les informations de votre véhicule")
                        .bodyDefaultRegular()
                        .foregroundStyle(Color("onBackgroundSecondary"))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 24)

                // Form ScrollView
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Vehicle Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Type de véhicule")
                                .bodyDefaultSemibold()
                                .foregroundStyle(Color("onBackground"))

                            Menu {
                                ForEach(VehicleType.allCases) { type in
                                    Button(action: {
                                        store.type = type
                                    }) {
                                        HStack {
                                            Text(type.displayName)
                                            if store.type == type {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(store.type.displayName)
                                        .bodyDefaultRegular()
                                        .foregroundStyle(Color("onSurface"))

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(Color("onBackgroundSecondary"))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("background"))
                                        .stroke(Color("outline"), lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        // Brand
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Marque")
                                .bodyDefaultSemibold()
                                .foregroundStyle(Color("onBackground"))

                            OutlinedTextField(
                                focusedField: $focusedField,
                                field: Field.brand,
                                placeholder: "TOYOTA, BMW, MERCEDES...",
                                text: $store.brand,
                                hasError: validationErrors["brand"] != nil
                            )
                            .submitLabel(.next)
                            .autocapitalization(.allCharacters)
                            .focused($focusedField, equals: .brand)
                            .onSubmit {
                                focusedField = .model
                            }
                            .onChange(of: store.brand) { _, _ in
                                validationErrors["brand"] = nil
                            }

                            if let error = validationErrors["brand"] {
                                Text(error)
                                    .bodyXSmallRegular()
                                    .foregroundStyle(.red)
                            }
                        }

                        // Model
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Modèle")
                                .bodyDefaultSemibold()
                                .foregroundStyle(Color("onBackground"))

                            OutlinedTextField(
                                focusedField: $focusedField,
                                field: Field.model,
                                placeholder: "COROLLA, X3, CLASSE A...",
                                text: $store.model,
                                hasError: validationErrors["model"] != nil
                            )
                            .submitLabel(.next)
                            .autocapitalization(.allCharacters)
                            .focused($focusedField, equals: .model)
                            .onSubmit {
                                focusedField = .plate
                            }
                            .onChange(of: store.model) { _, _ in
                                validationErrors["model"] = nil
                            }

                            if let error = validationErrors["model"] {
                                Text(error)
                                    .bodyXSmallRegular()
                                    .foregroundStyle(.red)
                            }
                        }

                        // Plate
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Plaque d'immatriculation")
                                .bodyDefaultSemibold()
                                .foregroundStyle(Color("onBackground"))

                            OutlinedTextField(
                                focusedField: $focusedField,
                                field: Field.plate,
                                placeholder: "AB-123-CD",
                                text: $store.plate,
                                hasError: validationErrors["plate"] != nil
                            )
                            .submitLabel(.next)
                            .autocapitalization(.allCharacters)
                            .focused($focusedField, equals: .plate)
                            .onSubmit {
                                focusedField = .mileage
                            }
                            .onChange(of: store.plate) { _, _ in
                                validationErrors["plate"] = nil
                            }

                            if let error = validationErrors["plate"] {
                                Text(error)
                                    .bodyXSmallRegular()
                                    .foregroundStyle(.red)
                            }
                        }

                        // Mileage
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Kilométrage actuel")
                                .bodyDefaultSemibold()
                                .foregroundStyle(Color("onBackground"))

                            OutlinedTextField(
                                focusedField: $focusedField,
                                field: Field.mileage,
                                placeholder: "120000",
                                text: $store.mileage,
                                hasError: validationErrors["mileage"] != nil,
                                suffix: "KM"
                            )
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .mileage)
                            .onChange(of: store.mileage) { _, _ in
                                validationErrors["mileage"] = nil
                            }
                            .toolbar {
                                if focusedField == .mileage {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button {
                                            focusedField = nil
                                            openDateSheet = true
                                        } label: {
                                            Text("Suivant")
                                                .bold()
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .foregroundColor(Color("primary"))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }

                            if let error = validationErrors["mileage"] {
                                Text(error)
                                    .bodyXSmallRegular()
                                    .foregroundStyle(.red)
                            }
                        }

                        // Registration Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date de mise en circulation")
                                .bodyDefaultSemibold()
                                .foregroundStyle(Color("onBackground"))

                            Button(action: {
                                openDateSheet = true
                            }) {
                                HStack {
                                    Text(formatDate(store.registrationDate))
                                        .bodyDefaultRegular()
                                        .foregroundStyle(Color("onSurface"))

                                    Spacer()

                                    Image(systemName: "calendar")
                                        .foregroundStyle(Color("onBackgroundSecondary"))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("background"))
                                        .stroke(Color("outline"), lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                }

                Spacer()
                VStack(spacing: 12) {
                    Button(action: updateVehicle) {
                        if store.isLoading {
                            ProgressView()
                                .tint(Color("onPrimary"))
                        } else {
                            Text("Sauvegarder")
                                .bodyDefaultSemibold()
                                .foregroundStyle(Color("onPrimary"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isFormValid ? Color("primary") : Color("primary").opacity(0.5))
                    )
                    .disabled(!isFormValid || store.isLoading)

                    Button(action: {
                        store.send(.goBack)
                    }) {
                        Text("Annuler")
                            .bodyDefaultRegular()
                            .foregroundStyle(Color("onBackground"))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 16)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $openDateSheet) {
            DatePickerSheet(
                date: Binding(
                    get: { store.registrationDate },
                    set: { store.registrationDate = $0 }
                ),
                onSave: {
                    openDateSheet = false
                },
                onCancel: {
                    openDateSheet = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    private func updateVehicle() {
        // Validate all fields
        var hasErrors = false

        if store.brand.isEmpty {
            validationErrors["brand"] = "Ce champ est obligatoire"
            hasErrors = true
        }

        if store.model.isEmpty {
            validationErrors["model"] = "Ce champ est obligatoire"
            hasErrors = true
        }

        if store.plate.isEmpty {
            validationErrors["plate"] = "Ce champ est obligatoire"
            hasErrors = true
        }

        // Mileage is optional, no validation needed

        if !hasErrors {
            store.send(.updateVehicle)
        }
    }
}



#Preview {
    EditVehicleView(store: Store(initialState: EditVehicleStore.State(
        vehicle: Vehicle(brand: "Test Car", model: "", mileage: "50000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "ABC-123")
    )) {
        EditVehicleStore()
    })
}
