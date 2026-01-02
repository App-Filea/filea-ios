//
//  AddFirstVehicleView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 02/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct AddFirstVehicleView: View {
    @Bindable var store: StoreOf<AddFirstVehicleStore>
    
    var body: some View {
        NavigationView {
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
                                .font(.system(size: 17))
                                .multilineTextAlignment(.leading)
                                .autocapitalization(.allCharacters)
                                .submitLabel(.done)
                        }
                        
                        FormField(titleLabel: "Modèle",
                                  infoLabel: "Champ D.2 de la carte grise",
                                  isError: store.validationErrors.contains(.modelEmpty)) {
                            TextField("COROLLA, X3, CLASSE A...", text: $store.model)
                                .font(.system(size: 17))
                                .multilineTextAlignment(.leading)
                                .autocapitalization(.allCharacters)
                                .submitLabel(.done)
                        }
                        
                        FormField(titleLabel: "Immatriculation",
                                  infoLabel: "Champ A de la carte grise",
                                  isError: store.validationErrors.contains(.plateEmpty)) {
                            TextField("AB-123-CD", text: $store.plate)
                                .font(.system(size: 17))
                                .multilineTextAlignment(.leading)
                                .autocapitalization(.allCharacters)
                                .submitLabel(.done)
                        }
                        
                        FormField(titleLabel: "Kilométrage", infoLabel: "Consultez votre compteur") {
                            HStack(spacing: 12) {
                                Text("Kilométrage")
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                TextField("0", text: $store.mileage)
                                    .font(.system(size: 17))
                                    .keyboardType(.numbersAndPunctuation)
                                    .multilineTextAlignment(.trailing)
                                    .submitLabel(.done)
                                
                                Text("KM")
                                    .font(.system(size: 17))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        FormField(titleLabel: "Mise en circulation",
                                  infoLabel: "Champ B de la carte grise") {
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
                .safeAreaInset(edge: .bottom, spacing: 80) {
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
            .navigationTitle("Ajouter un véhicule")
            .navigationBarTitleDisplayMode(.inline)
            //        .sheet(item: $store.scope(state: \.scanStore, action: \.scanStore)) { scanStore in
            //            VehicleCardDocumentScanView(store: scanStore)
            //        }
        }
    }
}

#Preview {
    NavigationStack {
        AddFirstVehicleView(store: Store(initialState: AddFirstVehicleStore.State()) {
            AddFirstVehicleStore()
        })
    }
}
