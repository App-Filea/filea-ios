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

    private let horizontalPadding: CGFloat = 16
    private let fieldSpacing: CGFloat = 12

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
            Color(.secondarySystemBackground)
                .ignoresSafeArea()

            // Form ScrollView
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Vehicle Type Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "car.fill")
                                .font(.title3)
                                .foregroundStyle(Color.purple)
                                .frame(width: 24)

                            Text("Type de véhicule")
                                .font(.headline)
                                .foregroundStyle(Color(.label))
                        }

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
                                    .foregroundStyle(Color(.label))

                                Spacer()

                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color(.secondaryLabel))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .stroke(Color(.separator), lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)

                        // Sélection Principal/Secondaire
                        HStack(spacing: 12) {
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
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(
                                        ZStack {
                                            if store.isPrimary {
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
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(
                                        ZStack {
                                            if !store.isPrimary {
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
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    )

                    // Vehicle Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color.purple)
                                .frame(width: 24)

                            Text("Informations du véhicule")
                                .font(.headline)
                                .foregroundStyle(Color(.label))
                        }

                        // Brand
                        VStack(alignment: .leading, spacing: 6) {
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
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(validationErrors["brand"] != nil ? Color.red : (focusedField == .brand ? Color.purple : Color(.separator)), lineWidth: 2)
                                        .animation(.easeInOut(duration: 0.3), value: focusedField == .brand)
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
                        VStack(alignment: .leading, spacing: 6) {
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
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(validationErrors["model"] != nil ? Color.red : (focusedField == .model ? Color.purple : Color(.separator)), lineWidth: 2)
                                        .animation(.easeInOut(duration: 0.3), value: focusedField == .model)
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
                        VStack(alignment: .leading, spacing: 6) {
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
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(validationErrors["plate"] != nil ? Color.red : (focusedField == .plate ? Color.purple : Color(.separator)), lineWidth: 2)
                                        .animation(.easeInOut(duration: 0.3), value: focusedField == .plate)
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
                        VStack(alignment: .leading, spacing: 6) {
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
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .mileage)
                                    .onChange(of: store.mileage) { _, _ in
                                        validationErrors["mileage"] = nil
                                    }

                                Text("KM")
                                    .bodyDefaultRegular()
                                    .foregroundColor(Color(.secondaryLabel))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.separator), lineWidth: 2)
                            )
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
                                                .foregroundColor(Color.purple)
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
                        VStack(alignment: .leading, spacing: 6) {
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
                                openDateSheet = true
                            }) {
                                HStack {
                                    Text(formatDate(store.registrationDate))
                                        .bodyDefaultRegular()
                                        .foregroundStyle(Color(.label))

                                    Spacer()

                                    Image(systemName: "calendar")
                                        .foregroundStyle(Color(.secondaryLabel))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .stroke(Color(.separator), lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    )
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 20)
                .padding(.bottom, 16)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationTitle("Modifier mon véhicule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", role: .cancel) {
                    store.send(.goBack)
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    updateVehicle()
                } label: {
                    if store.isLoading {
                        ProgressView()
                    } else {
                        Text("Sauvegarder")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(!isFormValid || store.isLoading)
            }
        }
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
    @Dependency(\.uuid) var uuid
    EditVehicleView(store: Store(initialState: EditVehicleStore.State(
        vehicle: Vehicle(id: uuid(), brand: "Test Car", model: "", mileage: "50000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "ABC-123")
    )) {
        EditVehicleStore()
    })
}
