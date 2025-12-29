//
//  EditDocumentView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 16/09/2025.
//

import ComposableArchitecture
import SwiftUI

struct EditDocumentView: View {
    @Bindable var store: StoreOf<EditDocumentStore>
    
    var body: some View {
        ZStack {
            ColorTokens.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    FormField(titleLabel: "Type de document") {
                        HStack {
                            Text("Type")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Picker("Type", selection: $store.type) {
                                ForEach(DocumentType.allCases) { type in
                                    Text(type.displayName)
                                        .tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                    }
                    FormField(titleLabel: "Nom du document", infoLabel: "Nom descriptif du document") {
                        TextField("placeholder", text: $store.name)
                            .font(.system(size: 17))
                            .multilineTextAlignment(.leading)
                    }
                    FormField(titleLabel: "Date du document", infoLabel: "Date d'émission du document") {
                        HStack {
                            Text("Date")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            DatePicker("", selection: $store.date, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        }
                    }
                    FormField(titleLabel: "Informations complémentaires", infoLabel: "Kilométrage au moment du document") {
                        HStack(spacing: 12) {
                            Text("Kilométrage")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            TextField("0.00", text: $store.mileage)
                                .font(.system(size: 17))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            
                            Text("KM")
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)
                        }
                    }
                    FormField(infoLabel: "Montant TTC du document") {
                        HStack(spacing: 12) {
                            Text("Montant")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            TextField("0.00", text: $store.amount)
                                .font(.system(size: 17))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            
                            Text("€")
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)
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
                        Button(action: { store.send(.cancel) }) {
                            Text("Annuler")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .cornerRadius(14)
                        }
                        
                        Button(action: { store.send(.save) }) {
                            Text("Enregistrer")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.black)
                                .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .background(ColorTokens.background)
            }
        }
        .navigationTitle("Modifier le document")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        EditDocumentView(store: Store(initialState: EditDocumentStore.State(
            vehicleId: UUID(),
            document: Document(
                fileURL: "/path/to/document.jpg",
                name: "Test Document",
                date: Date(),
                mileage: "50000",
                type: .maintenance
            )
        )) {
            EditDocumentStore()
        })
    }
}
