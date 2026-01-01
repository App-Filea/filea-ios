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

    var body: some View {
        ZStack {
            ColorTokens.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    FormField(titleLabel: "Type de véhicule") {
                        HStack {
                            Text("Type")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)

                            Spacer()

                            Picker("Type", selection: $store.type) {
                                ForEach(VehicleType.allCases) { type in
                                    Text(type.displayName)
                                        .tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                    }

                    FormField(titleLabel: "Statut du véhicule") {
                        HStack {
                            Text("Statut")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)

                            Spacer()

                            Picker("Statut", selection: $store.isPrimary) {
                                Text("Principal")
                                Text("Secondaire")
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                    }

                    FormField(titleLabel: "Marque", infoLabel: "Champ D.1 de la carte grise") {
                        TextField("TOYOTA, BMW, MERCEDES...", text: $store.brand)
                            .font(.system(size: 17))
                            .multilineTextAlignment(.leading)
                            .autocapitalization(.allCharacters)
                            .submitLabel(.next)
                    }

                    FormField(titleLabel: "Modèle", infoLabel: "Champ D.2 de la carte grise") {
                        TextField("COROLLA, X3, CLASSE A...", text: $store.model)
                            .font(.system(size: 17))
                            .multilineTextAlignment(.leading)
                            .autocapitalization(.allCharacters)
                    }

                    FormField(titleLabel: "Immatriculation", infoLabel: "Champ A de la carte grise") {
                        TextField("AB-123-CD", text: $store.plate)
                            .font(.system(size: 17))
                            .multilineTextAlignment(.leading)
                            .autocapitalization(.allCharacters)
                    }

                    FormField(titleLabel: "Kilométrage", infoLabel: "Consultez votre compteur") {
                        HStack(spacing: 12) {
                            Text("Kilométrage")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)

                            Spacer()

                            TextField("120000", text: $store.mileage)
                                .font(.system(size: 17))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)

                            Text("KM")
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)
                        }
                    }

                    FormField(titleLabel: "Mise en circulation", infoLabel: "Champ B de la carte grise") {
                        HStack {
                            Text("Date")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            DatePicker("", selection: $store.registrationDate, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        }
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, Spacing.screenMargin)
            }
            .scrollBounceBehavior(.basedOnSize)
            .safeAreaInset(edge: .bottom, spacing: 24) {
                VStack(spacing: 0) {
                    Divider()

                    VStack(spacing: 0) {
                        Button(action: { store.send(.view(.cancelButtonTapped)) }) {
                            Text("Annuler")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .cornerRadius(14)
                        }

                        Button(action: { store.send(.view(.saveButtonTapped)) }) {
//                            if store.isLoading {
//                                ProgressView()
//                                    .frame(maxWidth: .infinity)
//                                    .padding(.vertical, 16)
//                                    .background(.black)
//                                    .cornerRadius(14)
//                            } else {
                                Text("Enregistrer")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(.black)
                                    .cornerRadius(14)
//                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .background(ColorTokens.background)
            }
        }
        .navigationTitle("Modifier mon véhicule")
        .navigationBarTitleDisplayMode(.inline)
    }
}



#Preview {
    @Shared(.selectedVehicle) var selectedVehicle: Vehicle = .init(id: "uuid", type: .car, brand: "Brand", model: "Model", mileage: "10000", registrationDate: Date.now, plate: "10-100-10", isPrimary: true, documents: [])
    NavigationView {
        EditVehicleView(store: Store(initialState: EditVehicleStore.State()) {
            EditVehicleStore()
        })
    }
}
