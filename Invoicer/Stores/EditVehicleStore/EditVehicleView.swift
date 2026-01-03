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
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    FormField(titleLabel: "Type de véhicule") {
                        HStack {
                            Text("Type")
                                .formFieldLeadingTitle()
                            
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
                                .formFieldLeadingTitle()
                            
                            Spacer()
                            
                            Picker("Statut", selection: $store.isPrimary) {
                                Text("Principal").tag(true)
                                Text("Secondaire").tag(false)
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                    }
                    
                    FormField(titleLabel: "Marque",
                              infoLabel: "Champ D.1 de la carte grise",
                              isError: store.validationErrors.contains(.brandEmpty)) {
                        TextField("TOYOTA, BMW, MERCEDES...", text: $store.brand)
                            .formFieldLeadingTitle()
                            .multilineTextAlignment(.leading)
                            .autocapitalization(.allCharacters)
                            .submitLabel(.done)
                    }
                    
                    FormField(titleLabel: "Modèle",
                              infoLabel: "Champ D.2 de la carte grise",
                              isError: store.validationErrors.contains(.modelEmpty)) {
                        TextField("COROLLA, X3, CLASSE A...", text: $store.model)
                            .formFieldLeadingTitle()
                            .multilineTextAlignment(.leading)
                            .autocapitalization(.allCharacters)
                            .submitLabel(.done)
                    }
                    
                    FormField(titleLabel: "Immatriculation",
                              infoLabel: "Champ A de la carte grise",
                              isError: store.validationErrors.contains(.plateEmpty)) {
                        TextField("AB-123-CD", text: $store.plate)
                            .formFieldLeadingTitle()
                            .multilineTextAlignment(.leading)
                            .autocapitalization(.allCharacters)
                            .submitLabel(.done)
                    }
                    
                    FormField(titleLabel: "Kilométrage", infoLabel: "Consultez votre compteur") {
                        HStack(spacing: 12) {
                            Text("Kilométrage")
                                .formFieldLeadingTitle()
                            
                            Spacer()
                            
                            TextField("0", text: $store.mileage)
                                .formFieldLeadingTitle()
                                .keyboardType(.numbersAndPunctuation)
                                .multilineTextAlignment(.trailing)
                                .submitLabel(.done)
                            
                            Text("KM")
                                .formFieldLeadingTitle()
                        }
                    }
                    
                    FormField(titleLabel: "Mise en circulation",
                              infoLabel: "Champ B de la carte grise") {
                        HStack {
                            Text("Date")
                                .formFieldLeadingTitle()
                            
                            Spacer()
                            
                            DatePicker("", selection: $store.registrationDate, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        }
                    }
                }
                .padding(Spacing.screenMargin)
            }
            .scrollBounceBehavior(.basedOnSize)
            .safeAreaInset(edge: .bottom, spacing: 80) {
                VStack(spacing: 0) {
                    Divider()
                    
                    VStack(spacing: Spacing.md) {
                        PrimaryButton("Enregistrer", action: {
                            store.send(.view(.saveButtonTapped))
                        })
                        
                        TertiaryButton("Annuler") {
                            store.send(.view(.cancelButtonTapped))
                        }
                    }
                    .padding(16)
                }
                .background(Color(.tertiarySystemBackground))
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
