//
//  VehicleMonthlyExpensesView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 31/10/2025.
//

import SwiftUI
import ComposableArchitecture

struct VehicleMonthlyExpensesView: View {
    @Bindable var store: StoreOf<VehicleMonthlyExpensesStore>
    
    var body: some View {
        Text("hello World")
//        MonthlyExpenseChart(
//            expenses: store.currentVehicleMonthlyExpenses,
//            year: Calendar.current.component(.year, from: Date()),
//            accentColor: ColorTokens.actionPrimary
//        )
    }
}

#Preview {
    VehicleMonthlyExpensesView(store: .init(initialState: VehicleMonthlyExpensesStore.State(), reducer: { VehicleMonthlyExpensesStore() }))
}
