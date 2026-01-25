//
//  VehicleMaintenanceView.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct VehicleMaintenanceView: View {
    @Bindable var store: StoreOf<VehicleMaintenanceStore>

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    DocumentListView(
                        documents: store.filteredDocuments,
                        emptyStateMessage: "Aucun Entretien",
                        onDocumentTap: { document in
                            store.send(.documentTapped(document))
                        }
                    )
                    .padding(.horizontal, Spacing.md)
                }
            }
            .safeAreaInset(edge: .bottom) {
                QuickActionButton(label: "vehicle_maintenance_document_add_document") {
                    store.send(.view(.addDocumentTapped))
                }
                .padding(Spacing.md)
            }
        }
        .fullScreenCover(item: $store.scope(state: \.addDocument, action: \.addDocument)) { store in
            AddDocumentView(store: store)
                .presentationDetents([.large])
        }
    }
}

#Preview {
    @Shared(.selectedVehicle) var selectedVehicle: Vehicle = .init(id: "1", documents: [.init(fileURL: "", name: "", date: .now, mileage: "", type: .technicalInspection)])
    VehicleMaintenanceView(store: .init(initialState: VehicleMaintenanceStore.State(), reducer: { VehicleMaintenanceStore() }))
}
