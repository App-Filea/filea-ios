# Story 2.4: Section Activités Récentes

Status: ready-for-dev

## Story

En tant qu'**utilisateur consultant la vue d'ensemble de mon véhicule**,
Je veux **voir les 3 dernières activités (documents) de mon véhicule**,
Afin de **avoir un aperçu rapide de l'historique récent sans naviguer vers un autre onglet**.

## Critères d'Acceptation

### CA1: Affichage de la Section Activités Récentes
**Étant donné** que le véhicule a des documents
**Quand** la vue d'ensemble se charge
**Alors** une section "Activités récentes" doit s'afficher avec :
- Header "Activités récentes" avec un chevron de navigation
- Liste des 3 derniers documents

### CA2: Format d'Affichage des Activités
**Étant donné** que des activités sont affichées
**Quand** l'utilisateur regarde la liste
**Alors** chaque ligne doit afficher 3 colonnes :
- **Gauche** : Nom/titre du document
- **Centre** : Date (format court, ex: "15 jan")
- **Droite** : Montant (ex: "156 €")

### CA3: Limite de 3 Activités Maximum
**Étant donné** que le véhicule a plus de 3 documents
**Quand** la section s'affiche
**Alors** seules les 3 activités les plus récentes doivent être affichées

### CA4: Tri Chronologique
**Étant donné** que des activités existent
**Quand** la liste s'affiche
**Alors** les activités doivent être triées par date décroissante (plus récent en premier)

### CA5: Navigation vers Onglet Entretiens
**Étant donné** que la section Activités récentes est affichée
**Quand** l'utilisateur appuie sur le header ou le chevron
**Alors** il doit être redirigé vers l'onglet "Entretiens & Maintenance"

### CA6: Comportement Conditionnel - Masquée si Vide
**Étant donné** que le véhicule n'a aucun document
**Quand** la vue d'ensemble se charge
**Alors** la section Activités récentes ne doit pas s'afficher

### CA7: Lignes Non Cliquables
**Étant donné** que la liste des activités est affichée
**Quand** l'utilisateur appuie sur une ligne d'activité individuelle
**Alors** rien ne doit se passer (les lignes sont informatives uniquement)

### CA8: Gestion du Montant Absent
**Étant donné** qu'un document n'a pas de montant
**Quand** la ligne s'affiche
**Alors** la colonne montant doit afficher "-- €" ou être vide

## Tâches / Sous-tâches

- [ ] **Tâche 1** : Créer le composant SwiftUI ActivityRow (CA: #2, #7, #8)
  - [ ] Sous-tâche 1.1 : Créer `ActivityRow.swift` dans `SharedViews/`
  - [ ] Sous-tâche 1.2 : Implémenter le layout 3 colonnes (nom, date, montant)
  - [ ] Sous-tâche 1.3 : Gérer l'absence de montant
  - [ ] Sous-tâche 1.4 : Appliquer les tokens du Design System

- [ ] **Tâche 2** : Créer le composant SwiftUI RecentActivitiesSectionView (CA: #1, #3, #5)
  - [ ] Sous-tâche 2.1 : Créer `RecentActivitiesSectionView.swift` dans `Holfy/Stores/OverviewStore/`
  - [ ] Sous-tâche 2.2 : Implémenter le header avec "Activités récentes" et chevron
  - [ ] Sous-tâche 2.3 : Implémenter la liste limitée à 3 éléments
  - [ ] Sous-tâche 2.4 : Connecter le tap header à la navigation vers onglet Entretiens

- [ ] **Tâche 3** : Intégrer dans OverviewStore (CA: #3, #4, #6)
  - [ ] Sous-tâche 3.1 : Ajouter `recentActivities: [Document]` au State (limité à 3)
  - [ ] Sous-tâche 3.2 : Ajouter action `recentActivitiesHeaderTapped`
  - [ ] Sous-tâche 3.3 : Implémenter le tri par date décroissante
  - [ ] Sous-tâche 3.4 : Limiter à 3 documents maximum

- [ ] **Tâche 4** : Intégrer dans OverviewView (CA: #1, #6)
  - [ ] Sous-tâche 4.1 : Ajouter RecentActivitiesSectionView conditionnel
  - [ ] Sous-tâche 4.2 : Masquer si `recentActivities.isEmpty`

- [ ] **Tâche 5** : Connecter Navigation vers Onglet Entretiens (CA: #5)
  - [ ] Sous-tâche 5.1 : Implémenter l'action de changement d'onglet
  - [ ] Sous-tâche 5.2 : Envoyer action au VehicleDetailTabStore

- [ ] **Tâche 6** : Tests Unitaires (CA: #3, #4, #6)
  - [ ] Sous-tâche 6.1 : Tester le tri chronologique
  - [ ] Sous-tâche 6.2 : Tester la limite de 3 activités
  - [ ] Sous-tâche 6.3 : Tester l'absence de section si pas de documents
  - [ ] Sous-tâche 6.4 : Tester la navigation vers onglet Entretiens

## Notes de Développement

### Contexte Architectural

**État Actuel :**
- Les documents sont affichés dans l'onglet Entretiens & Maintenance
- Pas d'aperçu rapide dans la Vue d'Ensemble
- DocumentCard existe déjà mais avec un format différent

**État Cible :**
- Section "Activités récentes" dans Vue d'Ensemble
- Format simplifié (3 colonnes) pour aperçu rapide
- Navigation vers onglet Entretiens pour liste complète

### Design du Brainstorming

**Structure Validée :**
```
┌─────────────────────────────────────────┐
│ Activités récentes                   >  │  ← Header : Titre + Chevron
├─────────────────────────────────────────┤
│ Vidange           15 jan         156 €  │  ← Non cliquable
│ Plein essence     12 jan          52 €  │  ← Non cliquable
│ Assurance          3 jan         420 €  │  ← Non cliquable
└─────────────────────────────────────────┘
```

**Décisions Clés :**
| Aspect | Décision |
|--------|----------|
| Header | "Activités récentes" + chevron |
| Chevron mène vers | Onglet Entretiens & Maintenance |
| Contenu ligne | Nom + Date + Montant (3 colonnes) |
| Lignes cliquables | Non — juste informatif |
| Limite | 3 activités maximum |
| Masquée si vide | Oui |

### Logique de Récupération des Activités

```swift
// Dans OverviewStore
func getRecentActivities(from documents: [Document]) -> [Document] {
    documents
        .sorted { $0.date > $1.date }  // Plus récent d'abord
        .prefix(3)
        .map { $0 }
}
```

### Composants SwiftUI

**ActivityRow.swift :**
```swift
struct ActivityRow: View {
    let document: Document

    var body: some View {
        HStack {
            // Nom
            Text(document.title)
                .font(TypographyTokens.body)
                .foregroundColor(ColorTokens.primary)
                .lineLimit(1)

            Spacer()

            // Date
            Text(document.date.formatted(.dateTime.day().month()))
                .font(TypographyTokens.body)
                .foregroundColor(ColorTokens.secondary)

            // Montant
            Text(document.amount?.formatted(.currency(code: "EUR")) ?? "-- €")
                .font(TypographyTokens.body)
                .foregroundColor(ColorTokens.primary)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.vertical, SpacingTokens.xs)
    }
}
```

**RecentActivitiesSectionView.swift :**
```swift
struct RecentActivitiesSectionView: View {
    let activities: [Document]
    let onHeaderTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            // Header
            Button(action: onHeaderTapped) {
                HStack {
                    Text("Activités récentes")
                        .font(TypographyTokens.headline)
                        .foregroundColor(ColorTokens.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(ColorTokens.secondary)
                }
            }

            // Séparateur
            Divider()

            // Liste des activités
            ForEach(activities.prefix(3)) { document in
                ActivityRow(document: document)
            }
        }
        .padding(SpacingTokens.md)
        .background(ColorTokens.cardBackground)
        .cornerRadius(RadiusTokens.md)
    }
}
```

### Navigation vers Onglet Entretiens

```swift
// Dans OverviewStore
case .recentActivitiesHeaderTapped:
    // Déléguer au parent pour changer d'onglet
    return .send(.delegate(.switchToTab(.maintenance)))

// Ou via VehicleDetailTabStore
@Dependency(\.dismiss) var dismiss

case .recentActivitiesHeaderTapped:
    return .run { send in
        await send(.delegate(.navigateToMaintenanceTab))
    }
```

### Format de Date

**Décision :** Utiliser le format court "15 jan" pour économiser l'espace.

```swift
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM"
    formatter.locale = Locale(identifier: "fr_FR")
    return formatter
}()

// Ou avec le nouveau FormattedDate
document.date.formatted(.dateTime.day().month(.abbreviated))
// Résultat: "15 janv."
```

### Références

**Source Brainstorming :**
- [Source: _bmad-output/analysis/brainstorming-session-2026-01-26.md#Section 3 : Activités Récentes]
- [Source: _bmad-output/analysis/brainstorming-session-2026-01-26.md#Section Activités Récentes - Design Détaillé]

**Décision de Design :**
- Option A sélectionnée : Liste chronologique simple (pas de couleurs par type de document)

## Historique Agent Dev

### Modèle Agent Utilisé

_À remplir lors de l'implémentation_

### Notes de Complétion

_À remplir lors de l'implémentation_

### Liste des Fichiers

_À remplir lors de l'implémentation_
