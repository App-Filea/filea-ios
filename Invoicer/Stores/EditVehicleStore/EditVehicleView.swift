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
    @State private var date: Date = .now
    @FocusState private var focusedField: EditVehicleField?

    private let horizontalPadding: CGFloat = 20

    enum EditVehicleField: Hashable {
        case brand, model, plate, mileage
    }
    
    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            GeometryReader { reader in
                VStack(spacing: 0) {
                    Text("Modifier mon véhicule")
                        .titleLarge()
                        .foregroundStyle(Color("onBackground"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, 20)
                        .padding(.bottom, 8)

                    ScrollView {
                        VStack(spacing: 24) {
                            OutlinedTextField(
                                focusedField: $focusedField,
                                field: EditVehicleField.brand,
                                placeholder: "TOYOTA, BMW, MERCEDES...",
                                text: $store.brand
                            )
                            .autocapitalization(.allCharacters)
                            .focused($focusedField, equals: .brand)

                            OutlinedTextField(
                                focusedField: $focusedField,
                                field: EditVehicleField.model,
                                placeholder: "COROLLA, X3, CLASSE A...",
                                text: $store.model
                            )
                            .autocapitalization(.allCharacters)
                            .focused($focusedField, equals: .model)

                            OutlinedTextField(
                                focusedField: $focusedField,
                                field: EditVehicleField.plate,
                                placeholder: "AB-123-CD",
                                text: $store.plate
                            )
                            .autocapitalization(.allCharacters)
                            .focused($focusedField, equals: .plate)

                            OutlinedTextField(
                                focusedField: $focusedField,
                                field: EditVehicleField.mileage,
                                placeholder: "120000",
                                text: $store.mileage,
                                suffix: "KM"
                            )
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .mileage)

                            Button(action: {
                                date = store.registrationDate
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
                                        .stroke(Color("outline"), lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, 24)

                        VStack(spacing: 12) {
                            Button(action: { store.send(.updateVehicle) }) {
                                Text("Sauvegarder")
                                    .bodyDefaultSemibold()
                                    .foregroundStyle(Color("onPrimary"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color("primary"))
                                    )
                            }

                            Button(action: { store.send(.goBack) }) {
                                Text("Annuler")
                                    .bodyDefaultRegular()
                                    .foregroundStyle(Color("onBackground"))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.bottom, reader.safeAreaInsets.bottom + horizontalPadding)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $openDateSheet) {
            DatePickerSheet(
                date: $date,
                onSave: {
                    store.registrationDate = date
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}



#Preview {
    EditVehicleView(store: Store(initialState: EditVehicleStore.State(
        vehicle: Vehicle(brand: "Test Car", model: "", mileage: "50000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "ABC-123")
    )) {
        EditVehicleStore()
    })
}
