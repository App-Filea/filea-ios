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

                    Text(String(format: String(localized: "main_documents_count"), store.selectedVehicle.documents.count))
                        .title()

                    Spacer()

                    PrimaryCircleButton(systemImage: "plus") {
                        store.send(.showAddDocument)
                    }
                }

                if store.selectedVehicle.documents.isEmpty {
                    emptyDocumentsView
                } else {
                    documentsListView
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var emptyDocumentsView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "doc.fill")
                .imageScale(.large)
                .foregroundStyle(Color.secondary)
            Text("main_empty_documents_title")
                .font(.headline)
                .foregroundStyle(Color.primary)
            Text("main_empty_documents_subtitle")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }

    private var documentsListView: some View {
        LazyVStack(spacing: Spacing.sm) {
            ForEach(store.selectedVehicle.documents.groupedByMonth(), id: \.title) { section in
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(section.title)
                        .secondarySubheadline()

                    ForEach(section.items) { document in
                        eventElement(of: document)
                    }
                }
            }
        }
    }

    private func eventElement(of document: Document) -> some View {
        DocumentCard(document: document) {
            store.send(.showDocumentDetail(document))
        }
    }
}
