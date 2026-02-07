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
        
        NavigationStack {
            VehicleFormView(type: $store.type,
                            isPrimary: $store.isPrimary,
                            brand: $store.brand,
                            model: $store.model,
                            plate: $store.plate,
                            mileage: $store.mileage,
                            registrationDate: $store.registrationDate,
                            primaryAction: { store.send(.view(.saveButtonTapped)) },
                            secondaryAction: { store.send(.view(.cancelButtonTapped)) })
            .navigationTitle("add_vehicle_title")
            .navigationBarTitleDisplayMode(.inline)
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
