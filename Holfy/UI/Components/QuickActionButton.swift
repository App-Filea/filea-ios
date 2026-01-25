//
//  QuickActionButton.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI

struct QuickActionButton: View {
    let label: LocalizedStringKey
    let action: () -> Void
    @State private var isTapped = false

    var body: some View {
        Button(action: {
            isTapped.toggle()
            action()
        }) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    Capsule()
                        .fill(Color.accentColor)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                )
        }
        .sensoryFeedback(.impact(weight: .light), trigger: isTapped)
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()

        VStack {
            Spacer()
            HStack {
                Spacer()
                QuickActionButton(label: "➕ Ajouter Entretien") {
                    print("Quick action tapped")
                }
                .padding(Spacing.md)
            }
        }
    }
}
