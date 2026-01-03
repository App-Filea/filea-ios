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
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    FormField(titleLabel: "Type de document") {
                        HStack {
                            Text("Type")
                                .formFieldLeadingTitle()
                            
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
                            .formFieldLeadingTitle()
                    }
                    FormField(titleLabel: "Date du document", infoLabel: "Date d'émission du document") {
                        HStack {
                            Text("Date")
                                .formFieldLeadingTitle()
                            
                            Spacer()
                            
                            DatePicker("", selection: $store.date, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        }
                    }
                    FormField(titleLabel: "Informations complémentaires", infoLabel: "Kilométrage au moment du document") {
                        HStack(spacing: 12) {
                            Text("Kilométrage")
                                .formFieldLeadingTitle()
                            
                            Spacer()
                            
                            TextField("0.00", text: $store.mileage)
                                .formFieldLeadingTitle()
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                            
                            Text("KM")
                                .formFieldLeadingTitle()
                        }
                    }
                    FormField(infoLabel: "Montant TTC du document") {
                        HStack(spacing: 12) {
                            Text("Montant")
                                .formFieldLeadingTitle()
                            
                            Spacer()
                            
                            TextField("0.00", text: $store.amount)
                                .formFieldLeadingTitle()
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                            
                            Text("€")
                                .formFieldLeadingTitle()
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
                    
                    VStack(spacing: Spacing.md) {
                        
                        PrimaryButton("Enregistrer", action: {
                            store.send(.save)
                        })
                        
                        TertiaryButton("Annuler", action: {
                            store.send(.cancel)
                        })
                    }
                    .padding(16)
                }
                .background(Color(.tertiarySystemBackground))
            }
        }
        .navigationTitle("Modifier le document")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        EditDocumentView(store: Store(initialState: EditDocumentStore.State(
            vehicleId: String(),
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
