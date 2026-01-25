//
//  VehicleAdministrationView.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct VehicleAdministrationView: View {
    @Bindable var store: StoreOf<VehicleAdministrationStore>

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    TechnicalInspectionView(store: store.scope(state: \.technicalInspection, action: \.technicalInspection))
                    LazyVStack(spacing: 0) {
                        DocumentListView(
                            documents: store.filteredDocuments,
                            emptyStateMessage: "Aucun Entretien",
                            onDocumentTap: { document in
                                store.send(.documentTapped(document))
                            }
                        )
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
            .safeAreaInset(edge: .bottom) {
                QuickActionButton(label: "vehicle_administrative_document_add_document") {
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
    VehicleAdministrationView(store: .init(initialState: VehicleAdministrationStore.State(), reducer: { VehicleAdministrationStore() }))
}
