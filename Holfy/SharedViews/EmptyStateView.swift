//
//  EmptyStateView.swift
//  Holfy
//
//  Created by Claude Code on 19/01/2026.
//

import SwiftUI

struct EmptyStateView: View {
    let content: EmptyStateContent
    let onCTATapped: () -> Void
    @State private var ctaTapped = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Spacer()

                // Icon
                Image(systemName: content.icon)
                    .font(.system(size: 56))
                    .foregroundStyle(Color.secondary)
                    .accessibilityHidden(true)

                // Title
                Text(content.title)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)

                // Description
                Text(content.description)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)

                // Examples
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ForEach(content.examples, id: \.self) { example in
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Text("•")
                                .font(.body)
                                .foregroundStyle(Color(.tertiaryLabel))
                            Text(example)
                                .font(.footnote)
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .fill(Color(.tertiarySystemGroupedBackground))
                )
                .padding(.horizontal, Spacing.xl)

                // CTA Button
                Button(action: {
                    ctaTapped.toggle()
                    onCTATapped()
                }) {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "plus.circle.fill")
                        Text(content.ctaLabel)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        Capsule()
                            .fill(Color.accentColor)
                    )
                }
                .sensoryFeedback(.impact(weight: .light), trigger: ctaTapped)
                .accessibilityLabel(content.ctaLabel)
                .accessibilityHint("Ouvrir le formulaire d'ajout de document avec le type pré-sélectionné")

                Spacer()
            }
            .padding(.vertical, Spacing.xxl)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    EmptyStateView(
        content: EmptyStateContent(
            icon: "wrench.and.screwdriver",
            title: "Aucun Document d'Entretien",
            description: "Les documents d'entretien vous aident à suivre l'historique de maintenance de votre véhicule.",
            examples: [
                "Vidange moteur",
                "Changement pneus",
                "Révision annuelle",
                "Remplacement freins",
                "Entretien climatisation"
            ],
            ctaLabel: "➕ Ajouter Votre Premier Entretien"
        ),
        onCTATapped: {
            print("CTA tapped")
        }
    )
}
