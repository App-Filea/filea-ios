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
    @State var openDateSheet: Bool = false
    @State var date: Date = .now
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        textField("Marque", text: $store.brand)
                        textField("Modèle", text: $store.model)
                        textField("Plaque d'immatriculation", text: $store.plate)
                        
                        HStack(alignment: .bottom) {
                            textField("Kilométrage actuel", text: $store.mileage)
                                .keyboardType(.numberPad)
                            
                            Text("KM")
                                .font(.body.bold())
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date de mise en circulation")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text($store.registrationDate.wrappedValue)
                                .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
                                .font(.body.bold()) // texte en gras
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.1))
                                )
                                .onTapGesture {
                                    openDateSheet = true
                                }
                        }
                        Spacer()
                    }
                    .padding()
                    VStack {
                        Button(action: { store.send(.updateVehicle) }) {
                            Text("Sauvegarder")
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .foregroundStyle(Color.black)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(12)
                                .shadow( color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                        
                        Button(action: { store.send(.goBack) }) {
                            Text("Annuler")
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .foregroundStyle(Color.red)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(12)
                                .shadow( color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Modifier mon véhicule")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $openDateSheet) {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        openDateSheet = false
                    }) {
                        Text("Annuler")
                    }
                    Spacer()
                    Button(action: {
                        store.registrationDate = date.ISO8601Format()
                        openDateSheet = false
                    }) {
                        Text("Sauvegarder")
                    }
                }
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .presentationDetents([.medium])
                    .interactiveDismissDisabled(true)
            }
            .padding(.horizontal)
        }
    }
    
    private func textField(_ marker: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(marker)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            
            TextField("", text: text)
                .font(.body.bold()) // texte en gras
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                )
        }
    }
}

#Preview {
    EditVehicleView(store: Store(initialState: EditVehicleStore.State(
        vehicle: Vehicle(brand: "Test Car", model: "", mileage: "50000", registrationDate: "2020-01-01", plate: "ABC-123")
    )) {
        EditVehicleStore()
    })
}
