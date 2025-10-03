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
    
    private let horizontalPadding: CGFloat = 20
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .ignoresSafeArea()
            
            GeometryReader { reader in
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            StepTextField(
                                placeholder: "TOYOTA, BMW, MERCEDES...",
                                text: $store.brand
                            )
                            .autocapitalization(.allCharacters)
                            
                            StepTextField(
                                placeholder: "COROLLA, X3, CLASSE A...",
                                text: $store.model
                            )
                            .autocapitalization(.allCharacters)
                            
                            StepTextField(
                                placeholder: "AB-123-CD",
                                text: $store.plate
                            )
                            .autocapitalization(.allCharacters)
                            
                            StepTextFieldWithSuffix(
                                placeholder: "120000",
                                text: $store.mileage,
                                suffix: "KM"
                            )
                            .keyboardType(.numberPad)
                            
                            Button(action: { 
                                openDateSheet = true 
                            }) {
                                HStack {
                                    Text(store.registrationDate.isEmpty ? "Sélectionner une date" : store.registrationDate)
                                        .bodyDefaultRegular()
                                        .foregroundStyle(store.registrationDate.isEmpty ? .tertiary : .primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "calendar")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .stroke(Color(.systemGray4), lineWidth: 1)
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
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.accentColor)
                                    )
                            }
                            
                            Button(action: { store.send(.goBack) }) {
                                Text("Annuler")
                                    .bodyDefaultRegular()
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.bottom, reader.safeAreaInsets.bottom + horizontalPadding)
                    }
                }
            }
        }
        .navigationTitle("Modifier mon véhicule")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $openDateSheet) {
            DatePickerSheet(
                date: $date,
                onSave: {
                    store.registrationDate = formatDate(date)
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
        vehicle: Vehicle(brand: "Test Car", model: "", mileage: "50000", registrationDate: "2020-01-01", plate: "ABC-123")
    )) {
        EditVehicleStore()
    })
}
