//
//  LastDocumentView.swift
//  Holfy
//
//  Created by Claude on 2026-01-26.
//

import SwiftUI
import ComposableArchitecture

struct LastDocumentView: View {
    @Bindable var store: StoreOf<LastDocumentStore>

    @Shared(.selectedCurrency) var currency: Currency

    private var subtitleText: LocalizedStringKey {
        if let date = store.lastDocument?.date {
            return LocalizedStringKey(date.formatted(.dateTime.day().month(.abbreviated)))
        }
        return "--"
    }

    var body: some View {
        StatCard(
            title: "stat_card_last_document_title",
            value: store.lastDocument?.amount?.asCurrencyStringAdaptive(currency: currency) ?? "-- \(currency.symbol)",
            subtitle: subtitleText,
            icon: nil,
            action: nil
        )
        .onAppear {
            store.send(.view(.initiate))
        }
    }
}

#Preview {
    LastDocumentView(
        store: .init(
            initialState: LastDocumentStore.State(
                lastDocument: .init(
                    fileURL: "",
                    name: "Vidange",
                    date: .now,
                    mileage: "100000",
                    type: .maintenance,
                    amount: 156
                )
            ),
            reducer: { LastDocumentStore() }
        )
    )
}
