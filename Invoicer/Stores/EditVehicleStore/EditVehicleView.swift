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
        NavigationView {
            Form {
                Section(header: Text("Vehicle Information")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.headline)
                        TextField("Enter vehicle name", text: $store.name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Mileage")
                            .font(.headline)
                        TextField("Enter current mileage", text: $store.currentMileage)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Registration Date")
                            .font(.headline)
                        TextField("Enter registration date", text: $store.registrationDate)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("License Plate")
                            .font(.headline)
                        TextField("Enter license plate", text: $store.licensePlate)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
            .navigationTitle("Edit Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        store.send(.goBack)
                    }
                    .disabled(store.isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if store.isLoading {
                        ProgressView()
                            .controlSize(.mini)
                    } else {
                        Button("Save") {
                            store.send(.updateVehicle)
                        }
                        .disabled(store.name.isEmpty || 
                                 store.currentMileage.isEmpty || 
                                 store.registrationDate.isEmpty || 
                                 store.licensePlate.isEmpty)
                    }
                }
            }
        }
    }
}

#Preview {
    EditVehicleView(store: Store(initialState: EditVehicleStore.State(
        vehicle: Vehicle(name: "Test Car", currentMileage: "50000", registrationDate: "2020-01-01", licensePlate: "ABC-123")
    )) {
        EditVehicleStore()
    })
}