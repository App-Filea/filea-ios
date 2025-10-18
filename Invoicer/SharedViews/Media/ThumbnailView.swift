//
//  ThumbnailView.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Reusable thumbnail view component
//

import SwiftUI

/// Reusable thumbnail view that displays a document preview
struct ThumbnailView: View {
    let fileURL: String
    let size: CGSize
    var cornerRadius: CGFloat = Radius.thumbnail

    @State private var thumbnail: UIImage?
    @State private var isLoading = true

    init(fileURL: String, width: CGFloat, height: CGFloat, cornerRadius: CGFloat = Radius.thumbnail) {
        self.fileURL = fileURL
        self.size = CGSize(width: width, height: height)
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ZStack {
                    Rectangle()
                        .fill(ColorTokens.surface)
                    ProgressView()
                        .scaleEffect(0.8)
                }
            } else {
                placeholderView
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .task {
            await loadThumbnail()
        }
    }

    private var placeholderView: some View {
        Rectangle()
            .fill(ColorTokens.surface.opacity(0.5))
            .overlay(
                Image(systemName: "doc.fill")
                    .font(.title2)
                    .foregroundStyle(ColorTokens.textTertiary)
            )
    }

    private func loadThumbnail() async {
        defer { isLoading = false }

        thumbnail = await ThumbnailGenerator.shared.generateThumbnail(
            for: fileURL,
            size: size
        )
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        ThumbnailView(fileURL: "/path/to/document.jpg", width: 60, height: 80)
        ThumbnailView(fileURL: "/path/to/document.pdf", width: 120, height: 160)
    }
    .padding()
}
