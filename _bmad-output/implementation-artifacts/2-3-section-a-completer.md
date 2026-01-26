# Story 2.3: Section À Compléter

Status: ready-for-dev

## Story

En tant qu'**utilisateur consultant la vue d'ensemble de mon véhicule**,
Je veux **voir un compteur indiquant le nombre de documents incomplets**,
Afin de **savoir rapidement si des informations manquent dans mes documents**.

## Critères d'Acceptation

### CA1: Affichage de la Section À Compléter
**Étant donné** que le véhicule a des documents incomplets
**Quand** la vue d'ensemble se charge
**Alors** une section "À compléter" doit s'afficher avec :
- Header "À compléter" avec un chevron de navigation
- Compteur de documents incomplets (ex: "2 documents incomplets")

### CA2: Affichage du Compteur Uniquement
**Étant donné** que la section À Compléter est affichée
**Quand** l'utilisateur regarde le contenu
**Alors** seul un compteur doit être affiché (pas de liste détaillée des documents)

### CA3: Navigation vers Page Dédiée
**Étant donné** que la section À Compléter est affichée
**Quand** l'utilisateur appuie sur le header ou le chevron
**Alors** il doit être redirigé vers la page dédiée Alertes (section basse)

### CA4: Comportement Conditionnel - Masquée si Vide
**Étant donné** que tous les documents du véhicule sont complets
**Quand** la vue d'ensemble se charge
**Alors** la section À Compléter ne doit pas s'afficher du tout

### CA5: Définition d'un Document Incomplet
**Étant donné** qu'un document existe dans le véhicule
**Quand** le système évalue sa complétude
**Alors** un document est considéré incomplet si :
- Montant manquant (pour les types qui le requièrent)
- Date manquante
- Titre vide ou générique

### CA6: Ligne Non Cliquable
**Étant donné** que la section À Compléter est affichée
**Quand** l'utilisateur appuie sur le compteur
**Alors** rien ne doit se passer (informatif uniquement, navigation via header)

## Tâches / Sous-tâches

- [ ] **Tâche 1** : Créer le composant SwiftUI ToCompleteSectionView (CA: #1, #2, #3, #6)
  - [ ] Sous-tâche 1.1 : Créer `ToCompleteSectionView.swift` dans `Holfy/Stores/OverviewStore/`
  - [ ] Sous-tâche 1.2 : Implémenter le header avec "À compléter" et chevron
  - [ ] Sous-tâche 1.3 : Implémenter l'affichage du compteur
  - [ ] Sous-tâche 1.4 : Connecter le tap header à la navigation
  - [ ] Sous-tâche 1.5 : Appliquer les tokens du Design System

- [ ] **Tâche 2** : Créer le service DocumentCompletenessChecker (CA: #5)
  - [ ] Sous-tâche 2.1 : Créer `DocumentCompletenessClient` comme dépendance TCA
  - [ ] Sous-tâche 2.2 : Définir les règles de complétude par type de document
  - [ ] Sous-tâche 2.3 : Implémenter `isComplete(document:) -> Bool`
  - [ ] Sous-tâche 2.4 : Implémenter `incompleteDocuments(for vehicle:) -> [Document]`

- [ ] **Tâche 3** : Intégrer dans OverviewStore (CA: #1, #4)
  - [ ] Sous-tâche 3.1 : Ajouter `incompleteDocumentsCount: Int` au State
  - [ ] Sous-tâche 3.2 : Ajouter action `toCompleteHeaderTapped`
  - [ ] Sous-tâche 3.3 : Calculer le nombre de documents incomplets au chargement

- [ ] **Tâche 4** : Intégrer dans OverviewView (CA: #1, #4)
  - [ ] Sous-tâche 4.1 : Ajouter ToCompleteSectionView conditionnel
  - [ ] Sous-tâche 4.2 : Masquer si `incompleteDocumentsCount == 0`

- [ ] **Tâche 5** : Tests Unitaires (CA: #4, #5)
  - [ ] Sous-tâche 5.1 : Tester la détection de document incomplet (montant manquant)
  - [ ] Sous-tâche 5.2 : Tester la détection de document complet
  - [ ] Sous-tâche 5.3 : Tester le comptage correct
  - [ ] Sous-tâche 5.4 : Tester l'absence de section si tous complets

## Notes de Développement

### Contexte Architectural

**État Actuel :**
- Pas de notion de "document incomplet" dans l'app
- Les documents peuvent avoir des champs optionnels non remplis
- Pas de guidage pour compléter les informations

**État Cible :**
- Section "À compléter" dans Vue d'Ensemble
- Compteur simple sans liste détaillée
- Navigation vers page dédiée pour voir/compléter

### Design du Brainstorming

**Structure Validée :**
```
┌─────────────────────────────────┐
│ À compléter                  >  │  ← Header : Titre + Chevron
│ 2 documents incomplets          │  ← Juste compteur
└─────────────────────────────────┘
```

**Décisions Clés :**
| Aspect | Décision |
|--------|----------|
| Header | "À compléter" + chevron (pas d'icône) |
| Chevron mène vers | Page dédiée Alertes (section basse) — même écran que Alertes |
| Contenu | Compteur uniquement (pas de liste) |
| Cliquable | Non — juste informatif |
| Masquée si vide | Oui |

**Note Importante :** Les sections Alertes et À compléter partagent la même page de destination avec deux sections distinctes.

### Règles de Complétude des Documents

**Par Type de Document :**

| Type | Champs Requis pour Complétude |
|------|------------------------------|
| `maintenance` | titre, date, montant |
| `repair` | titre, date, montant |
| `fuel` | date, montant |
| `administrative` | titre, date |
| `other` | titre, date |

**Logique de Vérification :**
```swift
struct DocumentCompletenessClient: Sendable {
    var isComplete: @Sendable (Document) -> Bool
    var incompleteCount: @Sendable ([Document]) -> Int
}

extension DocumentCompletenessClient: DependencyKey {
    static var liveValue: DocumentCompletenessClient {
        DocumentCompletenessClient(
            isComplete: { document in
                // Titre non vide
                guard !document.title.trimmingCharacters(in: .whitespaces).isEmpty else {
                    return false
                }

                // Montant requis pour certains types
                switch document.type {
                case .maintenance, .repair, .fuel:
                    guard document.amount != nil && document.amount! > 0 else {
                        return false
                    }
                case .administrative, .other:
                    break
                }

                return true
            },
            incompleteCount: { documents in
                documents.filter { !Self.liveValue.isComplete($0) }.count
            }
        )
    }
}
```

### Composants SwiftUI

**ToCompleteSectionView.swift :**
```swift
struct ToCompleteSectionView: View {
    let incompleteCount: Int
    let onHeaderTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            // Header
            Button(action: onHeaderTapped) {
                HStack {
                    Text("À compléter")
                        .font(TypographyTokens.headline)
                        .foregroundColor(ColorTokens.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(ColorTokens.secondary)
                }
            }

            // Compteur
            Text("\(incompleteCount) document\(incompleteCount > 1 ? "s" : "") incomplet\(incompleteCount > 1 ? "s" : "")")
                .font(TypographyTokens.body)
                .foregroundColor(ColorTokens.secondary)
        }
        .padding(SpacingTokens.md)
        .background(ColorTokens.cardBackground)
        .cornerRadius(RadiusTokens.md)
    }
}
```

### Intégration dans OverviewView

```swift
// Dans OverviewView
if viewStore.incompleteDocumentsCount > 0 {
    ToCompleteSectionView(
        incompleteCount: viewStore.incompleteDocumentsCount,
        onHeaderTapped: {
            viewStore.send(.toCompleteHeaderTapped)
        }
    )
}
```

### Distinction Importante : Alertes vs À Compléter

**Analyse du Brainstorming :**

| Type | Nature | Urgence | Actionnable ? |
|------|--------|---------|---------------|
| CT expire dans 15j | Échéance légale | Haute | Oui → Prendre RDV |
| Assurance expire | Échéance légale | Haute | Oui → Renouveler |
| Document incomplet | Qualité données | Basse | Optionnel → Compléter infos |

**Constat clé :** "Documents incomplets" n'est pas une alerte au même sens que "CT expire". C'est une **tâche de complétion** optionnelle. D'où la séparation en deux sections distinctes.

### Références

**Source Brainstorming :**
- [Source: _bmad-output/analysis/brainstorming-session-2026-01-26.md#Section À Compléter]
- [Source: _bmad-output/analysis/brainstorming-session-2026-01-26.md#Analyse du Problème Initial]

## Historique Agent Dev

### Modèle Agent Utilisé

_À remplir lors de l'implémentation_

### Notes de Complétion

_À remplir lors de l'implémentation_

### Liste des Fichiers

_À remplir lors de l'implémentation_
