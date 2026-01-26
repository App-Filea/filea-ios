# Story 2.5: Empty State Vue d'Ensemble

Status: ready-for-dev

## Story

En tant qu'**utilisateur avec un nouveau véhicule sans documents**,
Je veux **voir un message de bienvenue accueillant avec les stats à zéro**,
Afin de **comprendre que mon véhicule est prêt à être utilisé et ne pas me sentir perdu**.

## Critères d'Acceptation

### CA1: Affichage des Stats à Zéro
**Étant donné** que le véhicule n'a aucun document
**Quand** la vue d'ensemble se charge
**Alors** la section Mini-Stats doit rester visible avec :
- Carte gauche : "0 €" et "0 opération"
- Carte droite : "-- €" et "--"

### CA2: Message de Bienvenue
**Étant donné** que le véhicule n'a aucune activité
**Quand** la vue d'ensemble se charge
**Alors** un message de bienvenue doit s'afficher :
- Emoji accueillant (ex: "Bienvenue !")
- Texte explicatif : "Ajoutez votre premier document pour commencer à suivre votre véhicule."

### CA3: Sections Alertes et À Compléter Masquées
**Étant donné** que le véhicule n'a pas de documents incomplets ni d'alertes
**Quand** la vue d'ensemble se charge
**Alors** les sections Alertes et À Compléter ne doivent pas s'afficher

### CA4: Section Activités Récentes Masquée
**Étant donné** que le véhicule n'a aucun document
**Quand** la vue d'ensemble se charge
**Alors** la section Activités récentes ne doit pas s'afficher

### CA5: Layout Complet Empty State
**Étant donné** que le véhicule est nouveau (pas de documents)
**Quand** la vue d'ensemble s'affiche
**Alors** le layout doit être :
1. Section Mini-Stats (visible avec valeurs zéro)
2. Message de bienvenue (centré, sous les stats)

### CA6: Pas de CTA Direct
**Étant donné** que l'empty state s'affiche
**Quand** l'utilisateur le voit
**Alors** il ne doit pas y avoir de bouton d'action direct (le message est informatif)

## Tâches / Sous-tâches

- [ ] **Tâche 1** : Créer le composant SwiftUI WelcomeMessageView (CA: #2, #6)
  - [ ] Sous-tâche 1.1 : Créer `WelcomeMessageView.swift` dans `Holfy/Stores/OverviewStore/`
  - [ ] Sous-tâche 1.2 : Implémenter l'emoji et le texte de bienvenue
  - [ ] Sous-tâche 1.3 : Appliquer les tokens du Design System
  - [ ] Sous-tâche 1.4 : Centrer le contenu verticalement

- [ ] **Tâche 2** : Gérer l'État Vide dans OverviewStore (CA: #1, #3, #4)
  - [ ] Sous-tâche 2.1 : Ajouter computed property `isEmptyState: Bool`
  - [ ] Sous-tâche 2.2 : Vérifier si aucun document n'existe
  - [ ] Sous-tâche 2.3 : S'assurer que les stats affichent les valeurs zéro

- [ ] **Tâche 3** : Intégrer dans OverviewView (CA: #5)
  - [ ] Sous-tâche 3.1 : Afficher WelcomeMessageView si `isEmptyState`
  - [ ] Sous-tâche 3.2 : Masquer les sections conditionnelles (Alertes, À compléter, Activités)
  - [ ] Sous-tâche 3.3 : Garder Mini-Stats visible

- [ ] **Tâche 4** : Tests Unitaires (CA: #1, #3, #4)
  - [ ] Sous-tâche 4.1 : Tester la détection de l'état vide
  - [ ] Sous-tâche 4.2 : Tester les valeurs zéro des stats
  - [ ] Sous-tâche 4.3 : Tester la visibilité conditionnelle des sections

## Notes de Développement

### Contexte Architectural

**État Actuel :**
- Pas d'empty state spécifique pour la Vue d'Ensemble
- Nouveau véhicule affiche probablement une liste vide

**État Cible :**
- Message de bienvenue accueillant pour nouveaux véhicules
- Stats visibles mais à zéro
- Aucune section conditionnelle affichée

### Design du Brainstorming

**Wireframe Validé :**
```
┌─────────────────────────────────────────┐
│  Statistiques                [Voir tout]│
├─────────────────────────────────────────┤
│  ┌─────────────────┐ ┌─────────────────┐│
│  │ Coût cette      │ │ Dernier         ││
│  │ année           │ │ entretien       ││
│  │                 │ │                 ││
│  │      0 €        │ │      -- €       ││
│  │                 │ │                 ││
│  │ 0 opération     │ │       --        ││
│  └─────────────────┘ └─────────────────┘│
├─────────────────────────────────────────┤
│                                         │
│   Bienvenue !                           │
│                                         │
│   Ajoutez votre premier document        │
│   pour commencer à suivre               │
│   votre véhicule.                       │
│                                         │
└─────────────────────────────────────────┘
```

**Décisions Clés :**
| Aspect | Décision |
|--------|----------|
| Stats | Toujours visibles (0€ / -- si vide) |
| Message | Simple et accueillant |
| CTA | Pas de bouton direct (optionnel) |
| Sections | Masquées si vides |

### Options Explorées dans le Brainstorming

| Option | Description | Avantages | Inconvénients |
|--------|-------------|-----------|---------------|
| **A** | Stats à zéro + Message accueil | Simple, accueillant | Pas de direction claire |
| B | Stats à zéro + Guidance onglets | Guide l'utilisateur | Peut sembler tutoriel |
| C | Stats uniquement | Ultra-minimaliste | Peut sembler cassé |
| D | Message contextuel léger | Explique pourquoi vide | Pas d'incitation action |

**Décision : Option A** - Simple et accueillant, sans surcharge d'information.

### Composants SwiftUI

**WelcomeMessageView.swift :**
```swift
struct WelcomeMessageView: View {
    var body: some View {
        VStack(spacing: SpacingTokens.md) {
            Text("Bienvenue !")
                .font(TypographyTokens.title2)
                .fontWeight(.semibold)
                .foregroundColor(ColorTokens.primary)

            Text("Ajoutez votre premier document pour commencer à suivre votre véhicule.")
                .font(TypographyTokens.body)
                .foregroundColor(ColorTokens.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(SpacingTokens.xl)
        .frame(maxWidth: .infinity)
    }
}
```

### Intégration dans OverviewView

```swift
struct OverviewView: View {
    let store: StoreOf<OverviewStore>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(spacing: SpacingTokens.md) {
                    // 1. Mini-Stats (TOUJOURS visible)
                    MiniStatsSectionView(
                        costThisYear: viewStore.costThisYear,
                        operationsCount: viewStore.operationsCount,
                        lastMaintenanceCost: viewStore.lastMaintenanceCost,
                        lastMaintenanceDate: viewStore.lastMaintenanceDate,
                        onSeeAllTapped: { viewStore.send(.seeAllStatsTapped) }
                    )

                    if viewStore.isEmptyState {
                        // 2. Message de bienvenue (si vide)
                        WelcomeMessageView()
                    } else {
                        // Sections conditionnelles (si pas vide)
                        if !viewStore.alerts.isEmpty {
                            AlertsSectionView(
                                alerts: viewStore.alerts,
                                onHeaderTapped: { viewStore.send(.alertsHeaderTapped) }
                            )
                        }

                        if viewStore.incompleteDocumentsCount > 0 {
                            ToCompleteSectionView(
                                incompleteCount: viewStore.incompleteDocumentsCount,
                                onHeaderTapped: { viewStore.send(.toCompleteHeaderTapped) }
                            )
                        }

                        if !viewStore.recentActivities.isEmpty {
                            RecentActivitiesSectionView(
                                activities: viewStore.recentActivities,
                                onHeaderTapped: { viewStore.send(.recentActivitiesHeaderTapped) }
                            )
                        }
                    }
                }
                .padding(SpacingTokens.md)
            }
        }
    }
}
```

### State dans OverviewStore

```swift
struct State: Equatable {
    // ... autres propriétés

    var isEmptyState: Bool {
        recentActivities.isEmpty && alerts.isEmpty && incompleteDocumentsCount == 0
    }
}
```

### Contraintes UX

**Principes du Brainstorming :**
1. **Accueillant, pas tutoriel** : Le message ne doit pas être condescendant
2. **Pas de bruit inutile** : Pas de "Aucune alerte" ou "Tout est complet"
3. **Stats toujours visibles** : Même à zéro, elles donnent une structure

### Références

**Source Brainstorming :**
- [Source: _bmad-output/analysis/brainstorming-session-2026-01-26.md#Empty State]
- [Source: _bmad-output/analysis/brainstorming-session-2026-01-26.md#État Nouveau Véhicule]

## Historique Agent Dev

### Modèle Agent Utilisé

_À remplir lors de l'implémentation_

### Notes de Complétion

_À remplir lors de l'implémentation_

### Liste des Fichiers

_À remplir lors de l'implémentation_
