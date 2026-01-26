# Story 2.1: Section Mini-Stats

Status: ready-for-dev

## Story

En tant qu'**utilisateur consultant la vue d'ensemble de mon véhicule**,
Je veux **voir deux cartes statistiques affichant "Coût cette année" et "Dernier entretien"**,
Afin de **avoir un aperçu rapide de la situation financière et de maintenance de mon véhicule**.

## Critères d'Acceptation

### CA1: Affichage des Deux Cartes Statistiques
**Étant donné** que l'utilisateur ouvre l'onglet Vue d'Ensemble d'un véhicule
**Quand** la vue se charge
**Alors** deux cartes côte à côte doivent s'afficher :
- **Carte gauche** : "Coût cette année"
- **Carte droite** : "Dernier entretien"

### CA2: Carte Gauche - Coût Cette Année
**Étant donné** que le véhicule a des documents avec des coûts
**Quand** la section Mini-Stats s'affiche
**Alors** la carte gauche doit montrer :
- **Titre** : "Coût cette année"
- **Valeur** : Somme des coûts de tous les documents de l'année en cours (format devise, ex: "1 847 €")
- **Sous-titre** : Nombre d'opérations (ex: "8 opérations")

### CA3: Carte Droite - Dernier Entretien
**Étant donné** que le véhicule a des documents d'entretien
**Quand** la section Mini-Stats s'affiche
**Alors** la carte droite doit montrer :
- **Titre** : "Dernier entretien"
- **Valeur** : Coût du dernier document d'entretien (format devise, ex: "156 €")
- **Sous-titre** : Date du dernier entretien (ex: "15 jan 2026")

### CA4: Header de Section avec Navigation
**Étant donné** que la section Mini-Stats est affichée
**Quand** l'utilisateur regarde le header
**Alors** :
- Le header doit afficher "Statistiques" comme titre
- Un bouton "Voir tout" doit être visible à droite
- Appuyer sur "Voir tout" doit naviguer vers l'onglet Statistiques

### CA5: État Vide / Zéro
**Étant donné** que le véhicule n'a pas de documents ou de coûts
**Quand** la section Mini-Stats s'affiche
**Alors** :
- La carte gauche doit afficher "0 €" comme valeur et "0 opération" comme sous-titre
- La carte droite doit afficher "-- €" comme valeur et "--" comme sous-titre
- La section doit rester visible (pas masquée)

### CA6: Symétrie Visuelle des Cartes
**Étant donné** que les deux cartes sont affichées
**Quand** l'utilisateur les regarde
**Alors** :
- Les deux cartes doivent avoir la même largeur (layout jumeaux)
- Les deux cartes doivent avoir la même hauteur (grâce aux sous-titres)
- Le layout doit suivre le style des cartes du Design System

## Tâches / Sous-tâches

- [ ] **Tâche 1** : Créer le composant SwiftUI MiniStatsCard (CA: #1, #2, #3, #6)
  - [ ] Sous-tâche 1.1 : Créer `MiniStatsCard.swift` dans `SharedViews/Cards/`
  - [ ] Sous-tâche 1.2 : Implémenter la structure de la carte (titre, valeur, sous-titre)
  - [ ] Sous-tâche 1.3 : Appliquer les tokens du Design System (ColorTokens, SpacingTokens, RadiusTokens)
  - [ ] Sous-tâche 1.4 : Supporter le contenu flexible pour les deux types de cartes

- [ ] **Tâche 2** : Créer le composant SwiftUI MiniStatsSection (CA: #1, #4, #6)
  - [ ] Sous-tâche 2.1 : Créer `MiniStatsSectionView.swift` dans `Holfy/Stores/OverviewStore/`
  - [ ] Sous-tâche 2.2 : Implémenter le header avec titre "Statistiques" et bouton "Voir tout"
  - [ ] Sous-tâche 2.3 : Implémenter le layout HStack pour les cartes jumelles
  - [ ] Sous-tâche 2.4 : Connecter "Voir tout" à l'action de navigation vers l'onglet Stats

- [ ] **Tâche 3** : Créer le Store TCA OverviewStore (CA: #2, #3, #5)
  - [ ] Sous-tâche 3.1 : Créer `OverviewStore.swift` dans `Stores/OverviewStore/`
  - [ ] Sous-tâche 3.2 : Définir le State avec les stats calculées (costThisYear, lastMaintenance)
  - [ ] Sous-tâche 3.3 : Définir les Actions pour la navigation (`seeAllStatsTapped`)
  - [ ] Sous-tâche 3.4 : Implémenter la logique de calcul des stats dans le reducer
  - [ ] Sous-tâche 3.5 : Gérer l'état vide (pas de documents)

- [ ] **Tâche 4** : Intégrer le Calcul des Statistiques (CA: #2, #3)
  - [ ] Sous-tâche 4.1 : Créer ou réutiliser la dépendance `VehicleStatisticsCalculator`
  - [ ] Sous-tâche 4.2 : Calculer le coût total pour l'année en cours depuis les documents
  - [ ] Sous-tâche 4.3 : Trouver le dernier document d'entretien (type: maintenance ou repair)
  - [ ] Sous-tâche 4.4 : Compter le nombre total d'opérations pour l'année en cours

- [ ] **Tâche 5** : Intégrer dans l'Onglet Vue d'Ensemble (CA: #1, #4)
  - [ ] Sous-tâche 5.1 : Ajouter MiniStatsSection à OverviewView
  - [ ] Sous-tâche 5.2 : Connecter au VehicleDetailTabStore pour la navigation
  - [ ] Sous-tâche 5.3 : Passer les données du véhicule actuel au calcul des stats

- [ ] **Tâche 6** : Tests Unitaires pour OverviewStore (CA: #2, #3, #5)
  - [ ] Sous-tâche 6.1 : Tester le calcul du coût avec plusieurs documents
  - [ ] Sous-tâche 6.2 : Tester l'extraction du dernier entretien
  - [ ] Sous-tâche 6.3 : Tester l'état vide (pas de documents)
  - [ ] Sous-tâche 6.4 : Tester l'action de navigation

## Notes de Développement

### Contexte Architectural

**État Actuel :**
- L'onglet Vue d'Ensemble existe mais a un contenu minimal
- Les calculs de statistiques existent dans le modèle `VehicleStatistics`
- Pas de section dédiée pour l'aperçu rapide des stats

**État Cible :**
- Section Mini-Stats en haut de l'onglet Vue d'Ensemble
- Deux cartes jumelles avec infos financières/maintenance clés
- Navigation vers l'onglet Statistiques pour les détails complets

### Intégration Design System

**Décision du Brainstorming :**
```
┌───────────────┐    ┌───────────────┐
│ Coût cette    │    │ Dernier       │
│ année         │    │ entretien     │
│               │    │               │
│   1 847 €     │    │    156 €      │
│               │    │               │
│ 8 opérations  │    │ 15 jan 2026   │
└───────────────┘    └───────────────┘
```

**Règles de Design (Brainstorming) :**
- **Cards jumelles** : Éléments côte à côte de même importance = 2 cards séparées
- Les deux cartes ont des sous-titres pour la symétrie visuelle (même hauteur)

**Tokens à Utiliser :**
- **ColorTokens** : Fond de carte, couleurs de texte
- **SpacingTokens** : Padding interne, espace entre les cartes
- **TypographyTokens** : Titre (caption), Valeur (large/bold), Sous-titre (caption)
- **RadiusTokens** : Rayon des coins de la carte

### Logique de Calcul des Statistiques

**Coût Cette Année :**
```swift
let currentYear = Calendar.current.component(.year, from: Date())
let costThisYear = documents
    .filter { Calendar.current.component(.year, from: $0.date) == currentYear }
    .compactMap { $0.amount }
    .reduce(0, +)

let operationsCount = documents
    .filter { Calendar.current.component(.year, from: $0.date) == currentYear }
    .count
```

**Dernier Entretien :**
```swift
let lastMaintenance = documents
    .filter { $0.type == .maintenance || $0.type == .repair }
    .sorted { $0.date > $1.date }
    .first
```

### Structure des Composants SwiftUI

**MiniStatsCard.swift :**
```swift
struct MiniStatsCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            Text(title)
                .font(TypographyTokens.caption)
                .foregroundColor(ColorTokens.secondary)

            Text(value)
                .font(TypographyTokens.title)
                .fontWeight(.bold)
                .foregroundColor(ColorTokens.primary)

            Text(subtitle)
                .font(TypographyTokens.caption)
                .foregroundColor(ColorTokens.tertiary)
        }
        .padding(SpacingTokens.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorTokens.cardBackground)
        .cornerRadius(RadiusTokens.md)
    }
}
```

**MiniStatsSectionView.swift :**
```swift
struct MiniStatsSectionView: View {
    let costThisYear: Double
    let operationsCount: Int
    let lastMaintenanceCost: Double?
    let lastMaintenanceDate: Date?
    let onSeeAllTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.md) {
            // Header
            HStack {
                Text("Statistiques")
                    .font(TypographyTokens.headline)
                Spacer()
                Button("Voir tout") {
                    onSeeAllTapped()
                }
                .font(TypographyTokens.body)
                .foregroundColor(ColorTokens.accent)
            }

            // Cartes Jumelles
            HStack(spacing: SpacingTokens.md) {
                MiniStatsCard(
                    title: "Coût cette année",
                    value: costThisYear.formatted(.currency(code: "EUR")),
                    subtitle: "\(operationsCount) opération\(operationsCount > 1 ? "s" : "")"
                )

                MiniStatsCard(
                    title: "Dernier entretien",
                    value: lastMaintenanceCost?.formatted(.currency(code: "EUR")) ?? "-- €",
                    subtitle: lastMaintenanceDate?.formatted(.dateTime.day().month()) ?? "--"
                )
            }
        }
    }
}
```

### Contraintes Critiques de CLAUDE.md

**À RESPECTER :**
1. Syntaxe Swift 6 et strict concurrency
2. Pas de `try!` dans le code de l'app
3. Tokens du Design System pour tout le styling
4. Pattern TCA avec State/Action/Reducer
5. Logging avec conventions d'emojis

### Références

**Source Brainstorming :**
- [Source: _bmad-output/analysis/brainstorming-session-2026-01-26.md#Section 1 : Mini-Stats]
- [Source: _bmad-output/analysis/brainstorming-session-2026-01-26.md#Design Détaillé par Section]

**Décision de Design :**
- Option B sélectionnée : "Coût cette année" + "Dernier entretien" (court terme, actionnable)

## Historique Agent Dev

### Modèle Agent Utilisé

_À remplir lors de l'implémentation_

### Notes de Complétion

_À remplir lors de l'implémentation_

### Liste des Fichiers

_À remplir lors de l'implémentation_
