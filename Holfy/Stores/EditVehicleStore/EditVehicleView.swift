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
        VehicleFormView(type: $store.type,
                        isPrimary: $store.isPrimary,
                        brand: $store.brand,
                        model: $store.model,
                        plate: $store.plate,
                        mileage: $store.mileage,
                        registrationDate: $store.registrationDate,
                        primaryAction: { store.send(.view(.saveButtonTapped)) },
                        secondaryAction: { store.send(.view(.cancelButtonTapped)) })
        .navigationTitle("edit_vehicle_title")
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
