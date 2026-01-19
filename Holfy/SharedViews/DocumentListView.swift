//
//  DocumentListView.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI

struct DocumentListView: View {
    let documents: [Document]
    let tab: VehicleDetailTabStore.Tab
    let onDocumentTap: (Document) -> Void
    let onAddDocument: () -> Void

    var body: some View {
        Group {
            if documents.isEmpty {
                emptyStateView
            } else {
                documentsListView
            }
        }
    }

    private var emptyStateView: some View {
        Group {
            if let emptyContent = EmptyStateContent.content(for: tab) {
                EmptyStateView(
                    content: emptyContent,
                    onCTATapped: onAddDocument
                )
            } else {
                // Fallback for tabs without empty state (e.g., Statistics)
                EmptyView()
            }
        }
    }

    private var documentsListView: some View {
        LazyVStack(spacing: Spacing.sm) {
            ForEach(documents.groupedByMonth(), id: \.title) { section in
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(section.title)
                        .secondarySubheadline()

                    ForEach(section.items) { document in
                        DocumentCard(document: document) {
                            onDocumentTap(document)
                        }
                    }
                }
            }
        }
    }
}
