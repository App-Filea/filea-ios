//
//  RecentActivitiesSectionView.swift
//  Holfy
//
//  Created by Claude on 2026-01-27.
//

import SwiftUI
import ComposableArchitecture

struct RecentActivitiesView: View {
    let store: StoreOf<RecentActivitiesStore>

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(Array(store.recentActivities.enumerated()), id: \.element.id) { index, document in
                DocumentCard(document: document, action: {})
            }
        }
    }
}

#Preview("With activities") {
    RecentActivitiesView(
        store: Store(
            initialState: RecentActivitiesStore.State(
                selectedVehicle: Shared(value: .init(
                    id: "test",
                    brand: "Lexus",
                    model: "CT200H",
                    mileage: "120000",
                    registrationDate: Date.now,
                    plate: "BZ-029-YV",
                    documents: [
                        Document(fileURL: "", name: "Vidange", date: Date.now, mileage: "100000", type: .maintenance, amount: 156),
                        Document(fileURL: "", name: "Plein essence", date: Date.now.addingTimeInterval(-86400 * 3), mileage: "100500", type: .other, amount: 52),
                        Document(fileURL: "", name: "Assurance", date: Date.now.addingTimeInterval(-86400 * 24), mileage: "100500", type: .other, amount: 420),
                        Document(fileURL: "", name: "Old doc", date: Date.now.addingTimeInterval(-86400 * 100), mileage: "90000", type: .maintenance, amount: 200)
                    ]
                ))
            ),
            reducer: { RecentActivitiesStore() }
        )
    )
    .padding()
}

#Preview("No activities") {
    RecentActivitiesView(
        store: Store(
            initialState: RecentActivitiesStore.State(
                selectedVehicle: Shared(value: .init(
                    id: "test",
                    brand: "Lexus",
                    model: "CT200H",
                    mileage: "120000",
                    registrationDate: Date.now,
                    plate: "BZ-029-YV",
                    documents: []
                ))
            ),
            reducer: { RecentActivitiesStore() }
        )
    )
    .padding()
}
