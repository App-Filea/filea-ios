//
//  AddVehicleView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct AddVehicleView: View {
    @Bindable var store: StoreOf<AddVehicleStore>
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations du véhicule")) {
                    TextField("Nom du véhicule", text: $store.vehicle.name)
                    TextField("Kilométrage actuel", text: $store.vehicle.currentMileage)
                        .keyboardType(.numberPad)
                    TextField("Date de mise en circulation", text: $store.vehicle.registrationDate)
                    TextField("Plaque d'immatriculation", text: $store.vehicle.licensePlate)
                        .textCase(.uppercase)
                }
            }
            .navigationTitle("Ajouter un véhicule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        store.send(.goBack)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        store.send(.saveVehicle)
                    }
                    .disabled(store.vehicle.name.isEmpty || store.isLoading)
                }
            }
        }
    }
}

#Preview {
    AddVehicleView(store: Store(initialState: AddVehicleStore.State()) {
        AddVehicleStore()
    })
}