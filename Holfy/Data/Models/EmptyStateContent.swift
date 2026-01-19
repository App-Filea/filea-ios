//
//  EmptyStateContent.swift
//  Holfy
//
//  Created by Claude Code on 19/01/2026.
//

import Foundation

struct EmptyStateContent: Equatable {
    let icon: String
    let title: String
    let description: String
    let examples: [String]
    let ctaLabel: String

    static func content(for tab: VehicleDetailTabStore.Tab) -> EmptyStateContent? {
        switch tab {
        case .overview:
            return EmptyStateContent(
                icon: "doc.text",
                title: "Aucun Document",
                description: "Commencez par ajouter vos documents automobiles pour suivre l'historique de votre véhicule.",
                examples: [
                    "Explorez les onglets pour découvrir où ranger vos documents",
                    "Entretiens pour les vidanges et révisions",
                    "Administration pour carte grise et assurance",
                    "Carburant pour vos pleins d'essence"
                ],
                ctaLabel: "Ajouter un Document"
            )

        case .statistics:
            // Statistics tab doesn't have empty state (always shows stats cards)
            return nil

        case .maintenance:
            return EmptyStateContent(
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
            )

        case .administration:
            return EmptyStateContent(
                icon: "doc.text.fill",
                title: "Aucun Document Administratif",
                description: "Gardez vos documents officiels accessibles et à jour pour éviter les mauvaises surprises.",
                examples: [
                    "Carte grise",
                    "Assurance auto",
                    "Contrôle technique",
                    "Certificat de cession"
                ],
                ctaLabel: "➕ Ajouter Votre Premier Document Admin"
            )

        case .fuel:
            return EmptyStateContent(
                icon: "fuelpump.fill",
                title: "Aucun Plein d'Essence",
                description: "Suivez vos dépenses de carburant pour mieux gérer votre budget automobile.",
                examples: [
                    "Pleins d'essence",
                    "Recharges électriques",
                    "Recharges hybrides",
                    "Suivi de consommation"
                ],
                ctaLabel: "➕ Ajouter Votre Premier Plein"
            )
        }
    }
}
