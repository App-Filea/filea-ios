//
//  VehicleStatisticsView.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct VehicleStatisticsView: View {
    @Bindable var store: StoreOf<VehicleStatisticsStore>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Stats cards
                HStack(spacing: Spacing.sm) {
                    TotalCostVehicleView(
                        store: store.scope(
                            state: \.totalCostVehicle,
                            action: \.totalCostVehicle
                        )
                    )
                }

                VehicleMonthlyExpensesView(
                    store: store.scope(
                        state: \.vehicleMonthlyExpenses,
                        action: \.vehicleMonthlyExpenses
                    )
                )

                Divider()
            }
            .padding(.horizontal, Spacing.md)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}
