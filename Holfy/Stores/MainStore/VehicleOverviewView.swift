//
//  VehicleOverviewView.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct VehicleOverviewView: View {
    @Bindable var store: StoreOf<MainStore>

    private var filteredDocuments: [Document] {
        store.tabStore.filteredDocuments(from: store.selectedVehicle.documents)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Stats cards
                HStack(spacing: Spacing.sm) {
                    TotalCostVehicleView(store: store.scope(state: \.totalCostVehicle, action: \.totalCostVehicle))

                    WarningVehicleView(store: store.scope(state: \.warningVehicle, action: \.warningVehicle))
                }

                VehicleMonthlyExpensesView(store: store.scope(state: \.vehicleMonthlyExpenses, action: \.vehicleMonthlyExpenses))

                Divider()

                HStack {
                    Image(systemName: "folder.fill")
                        .title()

                    Text(String(format: String(localized: "main_documents_count"), filteredDocuments.count))
                        .title()

                    Spacer()

                    PrimaryCircleButton(systemImage: "plus") {
                        store.send(.showAddDocument)
                    }
                }

                DocumentListView(
                    documents: filteredDocuments,
                    emptyStateMessage: "Aucun Document",
                    onDocumentTap: { document in
                        store.send(.showDocumentDetail(document))
                    }
                )
            }
            .padding(.horizontal, Spacing.md)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

}
