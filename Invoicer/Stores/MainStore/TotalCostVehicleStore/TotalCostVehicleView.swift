//
//  TotalCostVehicleView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 31/10/2025.
//

import SwiftUI
import ComposableArchitecture

struct TotalCostVehicleView: View {
    @Bindable var store: StoreOf<TotalCostVehicleStore>
    
    var body: some View {
        StatCard(
            title: "stat_card_total_cost_title",
            value: store.currentVehicleTotalCost.asCurrencyStringAdaptive,
            subtitle: "stat_card_total_cost_subtitle",
            icon: nil,
            action: nil
        )
        .onAppear {
            store.send(.view(.initiate))
        }
    }
}

#Preview {
    TotalCostVehicleView(store: .init(initialState: TotalCostVehicleStore.State(currentVehicleTotalCost: 1234),
                                      reducer: { TotalCostVehicleStore() }))
}
