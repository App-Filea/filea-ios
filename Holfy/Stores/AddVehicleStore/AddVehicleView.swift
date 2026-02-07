//
//  AddVehicleView2.swift
//  Invoicer
//
//  Created by Claude Code on 04/02/2026.
//

import SwiftUI
import ComposableArchitecture

struct AddVehicleView: View {
    @Bindable var store: StoreOf<AddVehicleStore>
    
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
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

#Preview {
    AddVehicleView(store: Store(initialState: AddVehicleStore.State()) {
        AddVehicleStore()
    })
}
