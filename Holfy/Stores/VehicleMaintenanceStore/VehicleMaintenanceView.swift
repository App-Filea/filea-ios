//
//  VehicleDocumentView.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct VehicleDocumentView: View {
    @Bindable var store: StoreOf<VehicleDocumentStore>

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: Spacing.sm) {
                        if store.filteredDocuments.isEmpty {
                            VStack(spacing: Spacing.md) {
                                Spacer()
                                Text("vehicle_maintenance_empty_title")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                Text("vehicle_maintenance_empty_subtitle")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)

                                QuickActionButton(label: "all_add_document") {
                                    store.send(.view(.addDocumentTapped))
                                }
                                Spacer()
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        } else {
                            ForEach(store.filteredDocuments.groupedByMonth(), id: \.title) { section in
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    Text(section.title)
                                        .secondarySubheadline()

                                    ForEach(section.items) { document in
                                        DocumentCard(document: document) {
                                            store.send(.documentTapped(document))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
                .safeAreaInset(edge: .bottom) {
                    if !store.filteredDocuments.isEmpty {
                        QuickActionButton(label: "vehicle_maintenance_document_add_document") {
                            store.send(.view(.addDocumentTapped))
                        }
                        .padding(Spacing.md)
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .fullScreenCover(item: $store.scope(state: \.addDocument, action: \.addDocument)) { store in
                AddDocumentView(store: store)
                    .presentationDetents([.large])
            }
        }
    }
}

#Preview("With documents") {
    @Shared(.selectedVehicle) var selectedVehicle: Vehicle = .init(id: "1", documents: [.init(fileURL: "", name: "Document", date: .now, mileage: "", type: .technicalInspection)])
    VehicleDocumentView(store: .init(initialState: VehicleDocumentStore.State(), reducer: { VehicleDocumentStore() }))
}

#Preview("Without documents") {
    @Shared(.selectedVehicle) var selectedVehicle: Vehicle = .init(id: "1", documents: [])
    VehicleDocumentView(store: .init(initialState: VehicleDocumentStore.State(), reducer: { VehicleDocumentStore() }))
}
