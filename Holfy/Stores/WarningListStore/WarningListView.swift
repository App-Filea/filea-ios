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

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        
                    }
                    .padding(Spacing.md)
                }
        }
        .navigationTitle("stat_card_warnings_title")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
//            store.send(.view(.initiate))
        }
    }
}

#Preview("With alerts") {
    let ctDocument = Document(fileURL: "", name: "CT 2024", date: .now, mileage: "", type: .technicalInspection)
    let incompleteDoc = Document(fileURL: "", name: "Vidange", date: .now, mileage: "", type: .maintenance)

    let alerts: [VehicleAlert] = [
        .init(type: .technicalInspection, message: "CT expire dans 15 jours", daysRemaining: 15, relatedDocument: ctDocument),
        .init(type: .incompleteDocument, message: "Vidange - montant manquant", relatedDocument: incompleteDoc),
    ]

    NavigationView {
        WarningListView(store: Store(initialState: WarningListStore.State(alerts: alerts)) {
            WarningListStore()
        })
    }
}
