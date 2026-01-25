//
//  VehicleFuelView.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct VehicleFuelView: View {
    @Bindable var store: StoreOf<VehicleFuelStore>

    var body: some View {
        VStack(spacing: 0) {
            DocumentListView(
                documents: store.filteredDocuments,
                emptyStateMessage: "Aucun Plein",
                onDocumentTap: { document in
                    store.send(.documentTapped(document))
                }
            )
            .padding(.horizontal, Spacing.md)
        }
    }
}
