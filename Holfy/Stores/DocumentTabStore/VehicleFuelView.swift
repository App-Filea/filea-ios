//
//  VehicleFuelView.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct VehicleFuelView: View {
    @Bindable var store: StoreOf<DocumentTabStore>

    var body: some View {
        VStack(spacing: 0) {
            DocumentListView(
                documents: store.filteredDocuments,
                tab: .fuel,
                onDocumentTap: { document in
                    store.send(.documentTapped(document))
                },
                onAddDocument: {
                    store.send(.addDocumentTapped)
                }
            )
            .padding(.horizontal, Spacing.md)
        }
    }
}
