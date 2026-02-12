//
//  TechnicalInspectionSheetView.swift
//  Holfy
//
//  Created by Nicolas Barbosa on 31/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct TechnicalInspectionSheetView: View {
    @Bindable var store: StoreOf<TechnicalInspectionSheetStore>

    @State private var animationStartTime: Date?
    @State private var hasCompleted: Bool = false

    private let animationDuration: Double = 5.0
    private let startDelay: Double = 0.5

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: hasCompleted)) { timeline in
            let progress = calculateProgress(at: timeline.date)

            VStack(spacing: 0) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(Color.yellow)
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text("technical_inspection_alert_title")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.primary)
                        Text("technical_inspection_alert_message")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.secondary)
                    }
                    Spacer()
                }
                .padding(Spacing.screenMargin)

                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(.orange)
            }
            .onChange(of: progress) { _, newValue in
                if newValue >= 1.0 && !hasCompleted {
                    hasCompleted = true
                    store.send(.dismissAlert)
                }
            }
        }
        .background(Color.white.overlay(Color.orange.opacity(0.1)))
        .task {
            try? await Task.sleep(for: .milliseconds(Int(startDelay * 1000)))
            animationStartTime = Date()
        }
    }

    private func calculateProgress(at currentDate: Date) -> Double {
        guard let startTime = animationStartTime else {
            return 0.0
        }

        let elapsed = currentDate.timeIntervalSince(startTime)
        let progress = min(max(elapsed / animationDuration, 0.0), 1.0)

        return progress
    }
}

#Preview("TechnicalInspectionSheet", traits: .sizeThatFitsLayout) {
    TechnicalInspectionSheetView(
        store: .init(
            initialState: TechnicalInspectionSheetStore.State(),
            reducer: { TechnicalInspectionSheetStore() }
        )
    )
}
