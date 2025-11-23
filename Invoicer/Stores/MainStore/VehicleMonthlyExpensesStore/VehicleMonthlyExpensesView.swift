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
        MonthlyExpenseChart(
            expenses: store.currentVehicleMonthlyExpenses,
            year: Calendar.current.component(.year, from: Date()),
            accentColor: ColorTokens.actionPrimary
        )
    }
}

#Preview {
    VehicleMonthlyExpensesView(store: .init(initialState: VehicleMonthlyExpensesStore.State(                    currentVehicleMonthlyExpenses: [
        MonthlyExpense(month: 1, amount: 540),   // Janvier
        MonthlyExpense(month: 2, amount: 0),     // Février (vide)
        MonthlyExpense(month: 3, amount: 80),    // Mars
        MonthlyExpense(month: 4, amount: 0),     // Avril (vide)
        MonthlyExpense(month: 5, amount: 350),   // Mai
        MonthlyExpense(month: 6, amount: 0),     // Juin (vide)
        MonthlyExpense(month: 7, amount: 180),   // Juillet
        MonthlyExpense(month: 8, amount: 95),    // Août
        MonthlyExpense(month: 9, amount: 0),     // Septembre (vide)
        MonthlyExpense(month: 10, amount: 400),  // Octobre
        MonthlyExpense(month: 11, amount: 0),    // Novembre (vide)
        MonthlyExpense(month: 12, amount: 0)     // Décembre (vide)
    ]),
                                            reducer: { VehicleMonthlyExpensesStore() }))
}
