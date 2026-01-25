//
//  WarningListView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 25/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct WarningListView: View {
    @Bindable var store: StoreOf<WarningListStore>

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            if store.incompleteDocuments.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(store.incompleteDocuments) { document in
                            DocumentCard(document: document) {
                                store.send(.view(.incompleteDocumentTapped(document)))
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            VStack(spacing: Spacing.sm) {
                Text("warning_list_empty_title")
                    .largeTitle()

                Text("warning_list_empty_subtitle")
//                    .body()
//                    .multilineTextAlignment(.center)
            }

            Spacer()

            PrimaryButton("warning_list_back_to_dashboard") {
                store.send(.view(.dismissButtonTapped))
            }
            .padding(.horizontal, Spacing.screenMargin)
        }
        .padding(Spacing.screenMargin)
    }
}

#Preview("With incomplete documents") {
    @Shared(.selectedVehicle) var selectedVehicle: Vehicle = .init(id: "1", documents: [
        .init(fileURL: "", name: "Document 1", date: .now, mileage: "", type: .technicalInspection),
        .init(fileURL: "", name: "Document 2", date: .now, mileage: "", type: .maintenance),
        .init(fileURL: "", name: "Document 3", date: .now, mileage: "", type: .repair),
    ])

    return WarningListView(store: Store(initialState: WarningListStore.State()) {
        WarningListStore()
    })
}

#Preview("Empty - All good") {
    @Shared(.selectedVehicle) var selectedVehicle: Vehicle = .init(id: "1", documents: [
        .init(fileURL: "", name: "Document complet", date: .now, mileage: "", type: .maintenance, amount: 150.0),
    ])

    return WarningListView(store: Store(initialState: WarningListStore.State()) {
        WarningListStore()
    })
}
