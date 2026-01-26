---
stepsCompleted: [1, 2, 3]
inputDocuments: []
session_topic: 'Écran Vue d''Ensemble - Dashboard Véhicule (1er onglet Custom Segmented Control)'
session_goals: 'Définir le contenu et la hiérarchie visuelle de l''écran Vue d''Ensemble'
selected_approach: 'Discussion collaborative structurée'
techniques_used: ['Analyse de structure', 'Proposition d''options', 'Validation itérative']
ideas_generated: ['Architecture 3 sections', 'Mini-Stats Option B', 'Alertes hiérarchisées', 'Empty State accueillant']
context_file: ''
---

# Brainstorming Session Results

**Facilitateur:** Claude
**Participant:** Nicolas
**Date:** 2026-01-26

## Session Overview

**Topic:** Écran Vue d'Ensemble - Dashboard Véhicule (1er onglet du Custom Segmented Control)

**Goals:**
- Définir le **contenu** de chaque section de l'écran
- Établir la **hiérarchie visuelle** appropriée

### Context Guidance

**Contexte Projet:** Cette session fait suite au brainstorming du 2026-01-08 où l'architecture Custom Segmented Control (5 onglets) a été validée. L'écran Vue d'Ensemble est le premier onglet, conçu comme une page read-only avec snapshot du véhicule.

**Lien avec session précédente:**
- Premier onglet du Segmented Control (5 onglets validés)
- Page read-only avec snapshot du véhicule
- Informations globales, alertes importantes, timeline récente
- Aucune action d'ajout (orientation informative)
- Liens directs cliquables vers les autres onglets

---

## Architecture Validée

### Structure 3 Sections

Nicolas a proposé une architecture en 3 parties distinctes :

| Position | Section | Rôle |
|----------|---------|------|
| 🔝 Haut | Mini-Stats (2 cartes) | Snapshot chiffré rapide |
| 🔔 Milieu | Alertes / À compléter | Attention requise |
| 📜 Bas | Activités Récentes | Historique contextuel |

---

## Section 1 : Mini-Stats

### Options Explorées

| Option | Stat Gauche | Stat Droite | Logique |
|--------|-------------|-------------|---------|
| A | Coût total (vie) | Dernier entretien | Vue long terme + court terme |
| **B ✅** | **Coût cette année** | **Dernier entretien** | **Tout court terme, actionnable** |
| C | Kilométrage actuel | Coût/km | Performance du véhicule |
| D | Coût cette année | Km depuis dernier entretien | Budget + suivi maintenance |
| E | Dépenses ce mois | Variation vs mois précédent | Suivi budget actif |

### Décision : Option B

**Statistiques affichées :**
- **Gauche :** Coût cette année (plus actionnable que coût total vie)
- **Droite :** Dernier entretien (montant de la dernière intervention)

**Navigation :**
- Bouton "Voir tout" → mène vers l'onglet Statistiques

**Comportement :**
- Toujours visible (même si 0€ ou --)

---

## Section 2 : Alertes

### Analyse du Problème Initial

Nicolas avait créé un "fourre-tout" mélangeant différents types d'informations. Analyse effectuée :

| Type | Nature | Urgence | Actionnable ? |
|------|--------|---------|---------------|
| CT expire dans 15j | Échéance légale | 🔴 Haute | Oui → Prendre RDV |
| Assurance expire dans 30j | Échéance légale | 🔴 Haute | Oui → Renouveler |
| Révision à faire (km) | Recommandation | 🟡 Moyenne | Oui → Prendre RDV |
| Document incomplet | Qualité données | ⚪ Basse | Optionnel → Compléter infos |

**Constat clé :** "Documents incomplets" n'est pas une alerte au même sens que "CT expire". C'est une **tâche de complétion** optionnelle.

### Décision : Deux Sous-Sections

```
┌─────────────────────────────┐
│ ⚠️ Alertes                  │
│ 🔴 CT expire dans 12 jours  │
│ 🟡 Vidange recommandée      │
├─────────────────────────────┤
│ 📝 À compléter              │
│    2 documents incomplets   │
└─────────────────────────────┘
```

**Hiérarchie :**
1. **Alertes** : Échéances légales (CT, Assurance) + Révisions recommandées
2. **À compléter** : Documents incomplets (tâches de complétion)

### Comportement Conditionnel

**Si alertes ET documents incomplets :**
```
┌─────────────────────────────┐
│ ⚠️ Alertes                  │
│ 🔴 CT expire dans 12 jours  │
│ 🟡 Vidange recommandée      │
├─────────────────────────────┤
│ 📝 À compléter              │
│    2 documents incomplets   │
└─────────────────────────────┘
```

**Si seulement alertes :**
```
┌─────────────────────────────┐
│ ⚠️ Alertes                  │
│ 🔴 CT expire dans 12 jours  │
└─────────────────────────────┘
```

**Si seulement documents incomplets :**
```
┌─────────────────────────────┐
│ 📝 À compléter              │
│    2 documents incomplets   │
└─────────────────────────────┘
```

**Si rien :** Section masquée entièrement (pas de bruit inutile)

---

## Section 3 : Activités Récentes

### Options Explorées

| Option | Description | Avantages | Inconvénients |
|--------|-------------|-----------|---------------|
| **A ✅** | **Chronologique simple** | **Simple** | Mélange genres |
| B | 2 parties séparées par type | Clarté | Prend plus de place |
| C | Vrac avec icône/couleur par type | Compact + contexte | Nécessite design couleurs |

### Décision : Option A

**Affichage :**
- Liste chronologique simple
- Pas de couleurs par type de document
- **Limite : 3 éléments maximum**

**Navigation :**
- Bouton "Voir tout" à côté du titre → mène vers l'onglet Entretiens & Maintenance

**Comportement :**
- Masquée si aucune activité

---

## Empty State

### Options Explorées

| Option | Description | Avantages | Inconvénients |
|--------|-------------|-----------|---------------|
| **A ✅** | **Stats à zéro + Message accueil** | **Simple, accueillant** | Pas de direction claire |
| B | Stats à zéro + Guidance onglets | Guide l'utilisateur | Peut sembler tutoriel |
| C | Stats uniquement | Ultra-minimaliste | Peut sembler cassé |
| D | Message contextuel léger | Explique pourquoi vide | Pas d'incitation action |

### Décision : Option A

**Affichage nouveau véhicule :**
```
┌─────────────────────────────────────┐
│  Coût cette année    Dernier entr. │
│       0 €               -- €       │
│                       [Voir tout →]│
├─────────────────────────────────────┤
│                                     │
│   👋 Bienvenue !                    │
│                                     │
│   Ajoutez votre premier document    │
│   pour commencer à suivre           │
│   votre véhicule.                   │
│                                     │
└─────────────────────────────────────┘
```

---

## Wireframes Finaux

### État Normal (avec données)

```
┌─────────────────────────────────────┐
│  Coût cette année    Dernier entr. │
│  1 847 €             156 €         │
│                       [Voir tout →]│
├─────────────────────────────────────┤
│  ⚠️ Alertes                         │
│  🔴 CT expire dans 12 jours         │
│  🟡 Vidange recommandée             │
├─────────────────────────────────────┤
│  📝 À compléter                     │
│     2 documents incomplets          │
├─────────────────────────────────────┤
│  📜 Activités récentes   [Voir tout]│
│  • Plein essence - 15 jan           │
│  • Vidange - 3 jan                  │
│  • Assurance renouvelée - 28 déc    │
└─────────────────────────────────────┘
```

### État Nouveau Véhicule

```
┌─────────────────────────────────────┐
│  Coût cette année    Dernier entr. │
│       0 €               -- €       │
│                       [Voir tout →]│
├─────────────────────────────────────┤
│                                     │
│   👋 Bienvenue !                    │
│                                     │
│   Ajoutez votre premier document    │
│   pour commencer à suivre           │
│   votre véhicule.                   │
│                                     │
└─────────────────────────────────────┘
```

---

## Tableau Récapitulatif

| Section | Contenu | Comportement | Navigation |
|---------|---------|--------------|------------|
| **Mini-Stats** | Coût cette année + Dernier entretien | Toujours visible (0€ / -- si vide) | "Voir tout" → Onglet Stats |
| **Alertes** | Échéances légales + Révisions | Masquée si vide | - |
| **À compléter** | Compteur documents incomplets | Masquée si vide | - |
| **Activités récentes** | 3 derniers documents (chrono) | Masquée si vide | "Voir tout" → Onglet Entretiens |
| **Empty State** | Message bienvenue | Si aucune activité | - |

---

## Décisions Clés

### Ce qui EST dans l'écran Vue d'Ensemble ✅

1. **Mini-Stats avec coût cette année** (pas coût total vie)
2. **Dernier entretien comme 2ème stat**
3. **Alertes = échéances légales + révisions recommandées**
4. **À compléter = documents incomplets** (séparé des alertes)
5. **Activités en liste chronologique simple** (pas de couleurs)
6. **Limite 3 éléments** pour activités
7. **Boutons "Voir tout"** pour navigation vers onglets
8. **Sections masquées si vides** (pas de message "aucune alerte")
9. **Empty state accueillant** pour nouveaux véhicules

### Ce qui N'EST PAS dans l'écran ❌

1. ❌ Coût total sur toute la vie du véhicule
2. ❌ Couleurs/icônes par type de document
3. ❌ Messages "Aucune alerte" ou "Tout est complet"
4. ❌ Guidance détaillée vers les onglets (empty state simple)
5. ❌ Plus de 3 activités récentes

---

## Design System - Règles Hybrides

### Règles Cards vs Flat

Suite à l'analyse des tendances UI 2025-2026, Nicolas a opté pour un système **hybride** avec des règles claires.

| Règle | Description |
|-------|-------------|
| **1. Cards pour les Zones** | Chaque section principale = une card englobante |
| **2. Flat pour le Contenu Interne** | Listes et textes à l'intérieur = flat, pas de cards imbriquées |
| **3. Cards Jumelles** | Éléments côte à côte de même importance = 2 cards séparées |

### Application à l'Écran

```
┌─────────────────────────────────────────┐
│  ┌─────────────────┐ ┌─────────────────┐│  ← Cards jumelles (stats)
│  │                 │ │                 ││
│  └─────────────────┘ └─────────────────┘│
│                                         │
│ ┌─────────────────────────────────────┐ │  ← Card englobante (alertes)
│ │ Contenu flat (liste)                │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │  ← Card englobante (à compléter)
│ │ Contenu flat                        │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │  ← Card englobante (activités)
│ │ Contenu flat (liste)                │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## Design Détaillé par Section

### Section Mini-Stats

**Structure Header :**
```
┌─────────────────────────────────────────┐
│  Statistiques                [Voir tout]│  ← HStack : Titre + Bouton
└─────────────────────────────────────────┘
```

**Structure Interne des Cards :**

| Élément | Position | Card Gauche | Card Droite |
|---------|----------|-------------|-------------|
| Titre | Haut | Coût cette année | Dernier entretien |
| Valeur | Milieu (gros) | 1 847 € | 156 € |
| Sous-titre | Bas | 8 opérations | 15 jan 2026 |

**Décision Sous-titres :** Les deux cards ont un sous-titre pour garantir la symétrie visuelle (même hauteur).

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

---

### Section Alertes

**Structure :**
```
┌─────────────────────────────────┐
│ Alertes                      >  │  ← Header : Titre + Chevron
├─────────────────────────────────┤
│ 🔴 CT expire dans 12 jours      │  ← Ligne non cliquable
│ 🟡 Vidange recommandée          │  ← Ligne non cliquable
│ 🟡 Assurance expire dans 45j    │  ← Ligne non cliquable
└─────────────────────────────────┘
```

| Aspect | Décision |
|--------|----------|
| Header | "Alertes" + chevron (pas d'icône ⚠️) |
| Icône header | Non — doublon avec indicateurs 🔴🟡 |
| Chevron mène vers | Page dédiée Alertes (section haute) |
| Contenu ligne | Indicateur priorité (🔴🟡) + texte principal |
| Lignes cliquables | Non — juste informatif |
| Limite | 3 alertes maximum |
| Masquée si vide | Oui |

---

### Section À Compléter

**Structure :**
```
┌─────────────────────────────────┐
│ À compléter                  >  │  ← Header : Titre + Chevron
│ 2 documents incomplets          │  ← Juste compteur
└─────────────────────────────────┘
```

| Aspect | Décision |
|--------|----------|
| Header | "À compléter" + chevron (pas d'icône) |
| Chevron mène vers | Page dédiée Alertes (section basse) — même écran que Alertes |
| Contenu | Compteur uniquement (pas de liste) |
| Cliquable | Non — juste informatif |
| Masquée si vide | Oui |

**Note :** Les sections Alertes et À compléter partagent la même page de destination avec deux sections distinctes.

---

### Section Activités Récentes

**Structure :**
```
┌─────────────────────────────────────────┐
│ Activités récentes                   >  │  ← Header : Titre + Chevron
├─────────────────────────────────────────┤
│ Vidange           15 jan         156 €  │  ← Non cliquable
│ Plein essence     12 jan          52 €  │  ← Non cliquable
│ Assurance          3 jan         420 €  │  ← Non cliquable
└─────────────────────────────────────────┘
```

| Aspect | Décision |
|--------|----------|
| Header | "Activités récentes" + chevron |
| Chevron mène vers | Onglet Entretiens & Maintenance |
| Contenu ligne | Nom + Date + Montant (3 colonnes) |
| Lignes cliquables | Non — juste informatif |
| Limite | 3 activités maximum |
| Masquée si vide | Oui |

---

## Wireframe Final Complet

### État Normal (avec données)

```
┌─────────────────────────────────────────┐
│  Statistiques                [Voir tout]│
├─────────────────────────────────────────┤
│  ┌─────────────────┐ ┌─────────────────┐│
│  │ Coût cette      │ │ Dernier         ││
│  │ année           │ │ entretien       ││
│  │                 │ │                 ││
│  │    1 847 €      │ │     156 €       ││
│  │                 │ │                 ││
│  │ 8 opérations    │ │ 15 jan 2026     ││
│  └─────────────────┘ └─────────────────┘│
├─────────────────────────────────────────┤
│ Alertes                              >  │
│ 🔴 CT expire dans 12 jours              │
│ 🟡 Vidange recommandée                  │
│ 🟡 Assurance expire dans 45j            │
├─────────────────────────────────────────┤
│ À compléter                          >  │
│ 2 documents incomplets                  │
├─────────────────────────────────────────┤
│ Activités récentes                   >  │
│ Vidange           15 jan         156 €  │
│ Plein essence     12 jan          52 €  │
│ Assurance          3 jan         420 €  │
└─────────────────────────────────────────┘
```

### État Nouveau Véhicule

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
│   👋 Bienvenue !                        │
│                                         │
│   Ajoutez votre premier document        │
│   pour commencer à suivre               │
│   votre véhicule.                       │
│                                         │
└─────────────────────────────────────────┘
```

---

## Tableau Récapitulatif Final

| Section | Header | Contenu | Navigation | Cliquable | Limite | Masquée si vide |
|---------|--------|---------|------------|-----------|--------|-----------------|
| **Mini-Stats** | "Statistiques" + [Voir tout] | 2 cards (Titre/Valeur/Sous-titre) | Onglet Stats | - | - | Non (0€/--) |
| **Alertes** | "Alertes" + chevron | 🔴🟡 + texte | Page dédiée (haut) | Non | 3 max | Oui |
| **À compléter** | "À compléter" + chevron | Compteur | Page dédiée (bas) | Non | - | Oui |
| **Activités** | "Activités récentes" + chevron | Nom + Date + Montant | Onglet Entretiens | Non | 3 max | Oui |
| **Empty State** | - | Message bienvenue | - | - | - | Si aucune activité |

---

## Prochaines Étapes

1. **Implémentation SwiftUI** : Développer les composants basés sur ce design
2. **Page Alertes Dédiée** : Designer l'écran complet Alertes + À compléter
3. **Tests** : Valider les différents états (normal, vide, partiel)

---

**Document Généré :** 2026-01-26
**Méthodologie :** Discussion collaborative structurée
**Durée Session :** ~45 minutes
