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
        Text("hello World")
//        StatCard(
//            title: "Coût total",
//            value: store.currentVehicleTotalCost.asCurrencyStringAdaptive,
//            subtitle: "Sur l'année en cours",
//            icon: nil,
//            accentColor: ColorTokens.actionPrimary,
//            action: nil
//        )
    }
}

#Preview {
    TotalCostVehicleView(store: .init(initialState: TotalCostVehicleStore.State(), reducer: { TotalCostVehicleStore() }))
}
