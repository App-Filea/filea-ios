# Story 2.2: Section Alertes

Status: ready-for-dev

## Story

En tant qu'**utilisateur consultant la vue d'ensemble de mon véhicule**,
Je veux **voir une section affichant les alertes importantes (échéances légales et révisions recommandées)**,
Afin de **ne jamais manquer une échéance critique comme le contrôle technique ou l'assurance**.

## Critères d'Acceptation

### CA1: Affichage de la Section Alertes
**Étant donné** que le véhicule a des alertes actives
**Quand** la vue d'ensemble se charge
**Alors** une section "Alertes" doit s'afficher avec :
- Header "Alertes" avec un chevron de navigation
- Liste des alertes avec indicateurs de priorité

### CA2: Indicateurs de Priorité
**Étant donné** que des alertes sont affichées
**Quand** l'utilisateur regarde la liste
**Alors** chaque alerte doit avoir un indicateur de priorité :
- **Rouge** : Échéances urgentes (< 15 jours) - ex: "CT expire dans 12 jours"
- **Jaune** : Échéances modérées ou recommandations - ex: "Vidange recommandée"

### CA3: Types d'Alertes Supportés
**Étant donné** que le système analyse les documents du véhicule
**Quand** des échéances ou recommandations sont détectées
**Alors** les alertes suivantes doivent être générées :
- **Contrôle Technique** : Si expire dans < 60 jours
- **Assurance** : Si expire dans < 60 jours
- **Vidange/Révision** : Si kilométrage dépasse le seuil recommandé

### CA4: Limite de 3 Alertes Maximum
**Étant donné** que plus de 3 alertes existent
**Quand** la section s'affiche
**Alors** seules les 3 alertes les plus urgentes doivent être affichées

### CA5: Navigation vers Page Dédiée
**Étant donné** que la section Alertes est affichée
**Quand** l'utilisateur appuie sur le header ou le chevron
**Alors** il doit être redirigé vers la page dédiée Alertes (section haute)

### CA6: Comportement Conditionnel - Masquée si Vide
**Étant donné** que le véhicule n'a aucune alerte active
**Quand** la vue d'ensemble se charge
**Alors** la section Alertes ne doit pas s'afficher du tout (pas de message "Aucune alerte")

### CA7: Lignes Non Cliquables
**Étant donné** que la liste des alertes est affichée
**Quand** l'utilisateur appuie sur une ligne d'alerte individuelle
**Alors** rien ne doit se passer (les lignes sont informatives uniquement)

## Tâches / Sous-tâches

- [ ] **Tâche 1** : Créer le composant SwiftUI AlertRow (CA: #2, #7)
  - [ ] Sous-tâche 1.1 : Créer `AlertRow.swift` dans `SharedViews/`
  - [ ] Sous-tâche 1.2 : Implémenter l'indicateur de priorité (cercle rouge/jaune)
  - [ ] Sous-tâche 1.3 : Implémenter le texte de l'alerte
  - [ ] Sous-tâche 1.4 : Appliquer les tokens du Design System

- [ ] **Tâche 2** : Créer le composant SwiftUI AlertsSectionView (CA: #1, #4, #5)
  - [ ] Sous-tâche 2.1 : Créer `AlertsSectionView.swift` dans `Holfy/Stores/OverviewStore/`
  - [ ] Sous-tâche 2.2 : Implémenter le header avec "Alertes" et chevron
  - [ ] Sous-tâche 2.3 : Implémenter la liste limitée à 3 éléments
  - [ ] Sous-tâche 2.4 : Connecter le tap header à la navigation

- [ ] **Tâche 3** : Créer le modèle Alert (CA: #2, #3)
  - [ ] Sous-tâche 3.1 : Créer `VehicleAlert.swift` dans `Data/Models/`
  - [ ] Sous-tâche 3.2 : Définir l'enum `AlertPriority` (high, medium)
  - [ ] Sous-tâche 3.3 : Définir l'enum `AlertType` (technicalInspection, insurance, maintenance)
  - [ ] Sous-tâche 3.4 : Implémenter le message formaté (ex: "CT expire dans X jours")

- [ ] **Tâche 4** : Créer le service AlertsCalculator (CA: #3)
  - [ ] Sous-tâche 4.1 : Créer `AlertsCalculatorClient` comme dépendance TCA
  - [ ] Sous-tâche 4.2 : Implémenter la détection d'expiration CT (< 60 jours)
  - [ ] Sous-tâche 4.3 : Implémenter la détection d'expiration assurance (< 60 jours)
  - [ ] Sous-tâche 4.4 : Implémenter la détection de révision recommandée (kilométrage)
  - [ ] Sous-tâche 4.5 : Trier les alertes par priorité (urgent d'abord)

- [ ] **Tâche 5** : Intégrer dans OverviewStore (CA: #1, #4, #6)
  - [ ] Sous-tâche 5.1 : Ajouter `alerts: [VehicleAlert]` au State
  - [ ] Sous-tâche 5.2 : Ajouter action `alertsHeaderTapped`
  - [ ] Sous-tâche 5.3 : Calculer les alertes lors du chargement
  - [ ] Sous-tâche 5.4 : Limiter à 3 alertes maximum dans le State

- [ ] **Tâche 6** : Intégrer dans OverviewView (CA: #1, #6)
  - [ ] Sous-tâche 6.1 : Ajouter AlertsSectionView conditionnel
  - [ ] Sous-tâche 6.2 : Masquer si `alerts.isEmpty`

- [ ] **Tâche 7** : Tests Unitaires (CA: #3, #4, #6)
  - [ ] Sous-tâche 7.1 : Tester la génération d'alerte CT expirant
  - [ ] Sous-tâche 7.2 : Tester la génération d'alerte assurance expirant
  - [ ] Sous-tâche 7.3 : Tester la limite de 3 alertes
  - [ ] Sous-tâche 7.4 : Tester l'absence d'alertes (pas de section)

## Notes de Développement

### Contexte Architectural

**État Actuel :**
- Pas de système d'alertes dans l'app
- Les dates d'expiration existent dans les documents (CT, assurance)
- Pas de calcul automatique des échéances

**État Cible :**
- Section Alertes dans Vue d'Ensemble
- Calcul automatique basé sur les documents
- Navigation vers page dédiée pour détails

### Design du Brainstorming

**Structure Validée :**
```
┌─────────────────────────────────┐
│ Alertes                      >  │  ← Header : Titre + Chevron
├─────────────────────────────────┤
│ 🔴 CT expire dans 12 jours      │  ← Ligne non cliquable
│ 🟡 Vidange recommandée          │  ← Ligne non cliquable
│ 🟡 Assurance expire dans 45j    │  ← Ligne non cliquable
└─────────────────────────────────┘
```

**Décisions Clés :**
| Aspect | Décision |
|--------|----------|
| Header | "Alertes" + chevron (pas d'icône) |
| Icône header | Non — doublon avec indicateurs |
| Chevron mène vers | Page dédiée Alertes (section haute) |
| Contenu ligne | Indicateur priorité (🔴🟡) + texte principal |
| Lignes cliquables | Non — juste informatif |
| Limite | 3 alertes maximum |
| Masquée si vide | Oui |

### Modèle d'Alerte

```swift
struct VehicleAlert: Equatable, Identifiable {
    let id: UUID
    let type: AlertType
    let priority: AlertPriority
    let message: String
    let daysRemaining: Int?

    enum AlertType: Equatable {
        case technicalInspection
        case insurance
        case maintenanceRecommended
    }

    enum AlertPriority: Equatable, Comparable {
        case high    // 🔴 < 15 jours
        case medium  // 🟡 15-60 jours ou recommandation
    }
}
```

### Logique de Calcul des Alertes

```swift
func calculateAlerts(for vehicle: Vehicle) -> [VehicleAlert] {
    var alerts: [VehicleAlert] = []

    // Contrôle Technique
    if let ctDoc = vehicle.documents.first(where: { $0.subtype == "technical_inspection" }),
       let expirationDate = ctDoc.expirationDate {
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        if daysRemaining < 60 {
            let priority: AlertPriority = daysRemaining < 15 ? .high : .medium
            alerts.append(VehicleAlert(
                id: UUID(),
                type: .technicalInspection,
                priority: priority,
                message: "CT expire dans \(daysRemaining) jours",
                daysRemaining: daysRemaining
            ))
        }
    }

    // Assurance
    if let insuranceDoc = vehicle.documents.first(where: { $0.subtype == "insurance" }),
       let expirationDate = insuranceDoc.expirationDate {
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        if daysRemaining < 60 {
            let priority: AlertPriority = daysRemaining < 15 ? .high : .medium
            alerts.append(VehicleAlert(
                id: UUID(),
                type: .insurance,
                priority: priority,
                message: "Assurance expire dans \(daysRemaining) jours",
                daysRemaining: daysRemaining
            ))
        }
    }

    // Trier par priorité et limiter à 3
    return alerts.sorted { $0.priority > $1.priority }.prefix(3).map { $0 }
}
```

### Composants SwiftUI

**AlertRow.swift :**
```swift
struct AlertRow: View {
    let alert: VehicleAlert

    var body: some View {
        HStack(spacing: SpacingTokens.sm) {
            Circle()
                .fill(alert.priority == .high ? Color.red : Color.yellow)
                .frame(width: 8, height: 8)

            Text(alert.message)
                .font(TypographyTokens.body)
                .foregroundColor(ColorTokens.primary)

            Spacer()
        }
        .padding(.vertical, SpacingTokens.xs)
    }
}
```

**AlertsSectionView.swift :**
```swift
struct AlertsSectionView: View {
    let alerts: [VehicleAlert]
    let onHeaderTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            // Header
            Button(action: onHeaderTapped) {
                HStack {
                    Text("Alertes")
                        .font(TypographyTokens.headline)
                        .foregroundColor(ColorTokens.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(ColorTokens.secondary)
                }
            }

            // Liste des alertes
            ForEach(alerts.prefix(3)) { alert in
                AlertRow(alert: alert)
            }
        }
        .padding(SpacingTokens.md)
        .background(ColorTokens.cardBackground)
        .cornerRadius(RadiusTokens.md)
    }
}
```

### Références

**Source Brainstorming :**
- [Source: _bmad-output/analysis/brainstorming-session-2026-01-26.md#Section 2 : Alertes]
- [Source: _bmad-output/analysis/brainstorming-session-2026-01-26.md#Section Alertes - Design Détaillé]

## Historique Agent Dev

### Modèle Agent Utilisé

_À remplir lors de l'implémentation_

### Notes de Complétion

_À remplir lors de l'implémentation_

### Liste des Fichiers

_À remplir lors de l'implémentation_
