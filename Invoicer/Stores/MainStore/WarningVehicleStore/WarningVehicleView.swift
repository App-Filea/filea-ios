//
//  WarningVehicleView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 31/10/2025.
//

import SwiftUI
import ComposableArchitecture

struct WarningVehicleView: View {
    @Bindable var store: StoreOf<WarningVehicleStore>
    
    var body: some View {
        StatCard(
            title: "Alertes",
            value: "\(store.currentVehicleIncompleteDocumentsCount)",
            subtitle: store.currentVehicleIncompleteDocumentsCount == 0
                ? "Tout est en ordre"
                : "Nécessite votre attention",
            icon: store.currentVehicleIncompleteDocumentsCount == 0
                ? "checkmark.circle.fill"
                : "exclamationmark.triangle.fill",
            iconColor: store.currentVehicleIncompleteDocumentsCount == 0
            ? Color.green
            : Color.orange,
            action: nil
        )
        .onAppear {
            store.send(.view(.initiate))
        }
    }
}

#Preview {
    WarningVehicleView(store: .init(initialState: WarningVehicleStore.State(), reducer: { WarningVehicleStore() }))
}
