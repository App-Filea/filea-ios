//
//  VehicleFuelView.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct VehicleFuelView: View {
    @Bindable var store: StoreOf<MainStore>

    private var filteredDocuments: [Document] {
        store.tabStore.filteredDocuments(from: store.selectedVehicle.documents)
    }

    var body: some View {
        VStack(spacing: 0) {
            DocumentListView(
                documents: filteredDocuments,
                tab: .fuel,
                onDocumentTap: { document in
                    store.send(.showDocumentDetail(document))
                },
                onAddDocument: {
                    store.send(.tabStore(.quickActionTapped))
                }
            )
            .padding(.horizontal, Spacing.md)
        }
    }
}
