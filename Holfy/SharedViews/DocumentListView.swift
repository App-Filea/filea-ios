//
//  DocumentListView.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI

struct DocumentListView: View {
    let documents: [Document]
    let emptyStateMessage: String
    let onDocumentTap: (Document) -> Void

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
        VStack(spacing: Spacing.md) {
            Image(systemName: "doc.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.secondary)

            Text(emptyStateMessage)
                .font(.headline)
                .foregroundStyle(Color.primary)

            Text("Les documents de cette catégorie apparaîtront ici")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xxl)
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
