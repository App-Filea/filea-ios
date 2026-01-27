---
stepsCompleted: [1, 2, 3]
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/architecture.md'
  - '_bmad-output/planning-artifacts/ux-design-specification.md'
  - '_bmad-output/analysis/brainstorming-session-2026-01-26.md'
storiesExist: true
storiesLocation: '_bmad-output/implementation-artifacts/'
lastUpdated: '2026-01-26'
---

# Holfy - Epic Breakdown

## Vue d'Ensemble

Ce document fournit la décomposition complète des epics et stories pour Holfy, transformant les exigences du PRD, du Design UX et de l'Architecture en stories implémentables.

**Note :** Les stories sont disponibles dans `implementation-artifacts/`.

---

## Inventaire des Exigences

### Exigences Fonctionnelles

**Navigation & Gestion des Onglets**
- FR1: L'utilisateur peut voir 5 onglets thématiques (Vue d'Ensemble, Statistiques, Entretiens & Réparations, Administration, Carburant) dans le dashboard principal pour le véhicule courant
- FR2: L'utilisateur peut basculer entre les onglets en appuyant sur les labels
- FR3: Le système affiche l'onglet actif avec un style visuel distinct
- FR4: Le système préserve la position de scroll indépendamment pour chaque onglet
- FR5: L'onglet Vue d'Ensemble est affiché par défaut à l'ouverture du dashboard

**Vue d'Ensemble - Contenu (NOUVEAU)**
- FR32: L'onglet Vue d'Ensemble affiche une section Mini-Stats avec 2 cartes (Coût cette année + Dernier entretien)
- FR33: L'onglet Vue d'Ensemble affiche une section Alertes avec les échéances urgentes (max 3)
- FR34: L'onglet Vue d'Ensemble affiche une section À Compléter avec le compteur de documents incomplets
- FR35: L'onglet Vue d'Ensemble affiche une section Activités Récentes avec les 3 derniers documents
- FR36: Les sections Alertes, À Compléter et Activités sont masquées si vides
- FR37: Un message de bienvenue s'affiche pour les nouveaux véhicules sans documents

**Filtrage & Affichage des Documents**
- FR6: Le système filtre automatiquement et affiche uniquement les documents du véhicule courant correspondant au type de l'onglet actif
- FR7: L'onglet Entretiens & Réparations affiche les documents de type `maintenance` et `repair`
- FR8: L'onglet Administration affiche les documents de type `administrative`
- FR9: L'onglet Carburant affiche les documents de type `fuel`
- FR10: L'onglet Vue d'Ensemble affiche les documents récents de tous types
- FR11: Les documents de chaque onglet sont affichés en ordre chronologique (plus récent en premier)

**Actions Contextuelles**
- FR12: L'utilisateur peut ajouter un document d'entretien directement depuis l'onglet Entretiens avec le type pré-sélectionné
- FR13: L'utilisateur peut ajouter un document administratif directement depuis l'onglet Administration avec le type pré-sélectionné
- FR14: L'utilisateur peut ajouter un enregistrement carburant directement depuis l'onglet Carburant avec le type pré-sélectionné
- FR15: Le système n'affiche pas d'actions d'ajout dans les onglets Vue d'Ensemble et Statistiques (onglets lecture seule)

**Statistiques & Vue d'Ensemble**
- FR22: L'onglet Statistiques affiche 4-5 cartes statistiques essentielles pour le véhicule courant
- FR23: L'onglet Vue d'Ensemble affiche les informations snapshot du véhicule (marque, modèle, kilométrage)
- FR24: L'onglet Vue d'Ensemble affiche la timeline des documents récents tous types confondus
- FR25: Le système réutilise la logique de calcul statistique existante pour l'affichage de l'onglet Statistiques

**Intégrité des Données**
- FR26: Le système s'assure que les documents sont stockés une seule fois en base (GRDB) indépendamment du filtrage par onglet
- FR27: Le système maintient la précision du type de document lors de l'ajout via Quick Actions
- FR28: Les modifications de documents (édition, suppression) sont reflétées immédiatement dans tous les onglets concernés

**Gestion du Contexte Véhicule**
- FR29: Le dashboard principal affiche le Custom Segmented Control pour le véhicule actuellement sélectionné
- FR30: Quand l'utilisateur change de véhicule via VehiclesList, le dashboard met à jour les données du nouveau véhicule dans tous les onglets
- FR31: Le système conserve la sélection du dernier onglet actif lors du changement de véhicule

### Exigences Non-Fonctionnelles

**Performance**
- NFR1: Le changement d'onglet s'effectue en moins de 100 millisecondes sur les appareils cibles (iPhone iOS 18.5+)
- NFR2: Le scroll de la liste de documents maintient 60 FPS avec jusqu'à 100 documents par onglet
- NFR3: Le chargement initial de l'onglet (à l'ouverture du dashboard) s'effectue en moins de 200 millisecondes
- NFR4: L'utilisation mémoire reste stable pendant les sessions prolongées de changement d'onglet

**Accessibilité**
- NFR5: Le Custom Segmented Control supporte VoiceOver avec annonces claires des noms et états des onglets
- NFR6: Les labels et contrôles d'onglet supportent Dynamic Type pour l'ajustement de la taille du texte
- NFR7: Le changement d'onglet est opérable via les gestes d'accessibilité iOS
- NFR8: Les empty states maintiennent des ratios de contraste suffisants (WCAG AA minimum: 4.5:1)
- NFR9: Les boutons Quick Action ont une taille de zone tactile minimum de 44×44 points selon Apple HIG

**Fiabilité**
- NFR10: Zéro crash lié au changement d'onglet ou à la logique de filtrage en fonctionnement normal
- NFR11: La position de scroll est préservée précisément lors du changement d'onglet
- NFR12: La précision du comptage de documents est maintenue dans tous les onglets
- NFR13: L'état des onglets survit au backgrounding et à la restauration de l'app sans perte de données

**Maintenabilité**
- NFR14: Tous les nouveaux stores TCA suivent les patterns existants du projet
- NFR15: Le code adhère aux exigences Swift 6 strict concurrency
- NFR16: Couverture de tests unitaires d'au moins 80% pour les nouveaux stores et logique de filtrage
- NFR17: Tous les tests suivent le pattern BDD (Given-When-Then)
- NFR18: Les nouveaux composants SwiftUI réutilisent les tokens du Design System existant

### Exigences Additionnelles

**Architecture Technique**
- Stack technique : SwiftUI + TCA 1.22.2+ + SQLite Data (GRDB) 1.4.3+
- Pattern TCA : Nouveau store avec composition de reducers
- State Management : @Shared pour state partagé entre stores
- Dependencies : `@Dependency(\.vehicleGRDBClient)`, `@Dependency(\.database)`
- Design System : Tokens existants (ColorTokens, SpacingTokens, TypographyTokens, RadiusTokens)
- Composants : Réutilisation des composants existants (StatCard, DocumentCard, etc.)
- Tests : Pattern BDD avec base de données en mémoire (`:memory:`)

**UX Design**
- Navigation mentale claire : 5 onglets avec état visuel distinct (AccentLabel)
- Scroll indépendant : Préservation position par onglet
- Quick Actions contextuelles : Type pré-sélectionné selon onglet
- Performance perçue : Changement onglet < 100ms, scroll 60 FPS
- Haptic Feedback : Confirmation tactile des actions critiques
- Dark Mode : Support complet via ColorTokens

---

## Carte de Couverture des Exigences

| FR | Epic | Description |
|----|------|-------------|
| FR1 | Epic 1 | Affichage des 5 onglets thématiques |
| FR2 | Epic 1 | Changement d'onglet par tap |
| FR3 | Epic 1 | Style visuel onglet actif |
| FR4 | Epic 1 | Préservation scroll par onglet |
| FR5 | Epic 1 | Vue d'Ensemble par défaut |
| FR6 | Epic 1 | Filtrage auto documents par type |
| FR7 | Epic 1 | Onglet Entretiens : maintenance + repair |
| FR8 | Epic 1 | Onglet Admin : administrative |
| FR9 | Epic 1 | Onglet Carburant : fuel |
| FR10 | Epic 2 | Vue d'Ensemble : tous types récents |
| FR11 | Epic 1 | Tri chronologique |
| FR12 | Epic 3 | Quick Action Entretien |
| FR13 | Epic 3 | Quick Action Admin |
| FR14 | Epic 3 | Quick Action Carburant |
| FR15 | Epic 3 | Pas d'actions dans Overview/Stats |
| FR22 | Epic 3 | Cards statistiques |
| FR23 | Epic 2 | Snapshot véhicule (stats) |
| FR24 | Epic 2 | Timeline documents récents |
| FR25 | Epic 3 | Réutilisation logique stats |
| FR26 | Epic 1 | Source unique GRDB |
| FR27 | Epic 3 | Précision type Quick Actions |
| FR28 | Epic 1 | Mise à jour cross-onglets |
| FR29 | Epic 1 | Segmented Control véhicule actuel |
| FR30 | Epic 1 | Mise à jour changement véhicule |
| FR31 | Epic 1 | Conservation onglet actif |
| FR32 | Epic 2 | Section Mini-Stats |
| FR33 | Epic 2 | Section Alertes |
| FR34 | Epic 2 | Section À Compléter |
| FR35 | Epic 2 | Section Activités Récentes |
| FR36 | Epic 2 | Sections masquées si vides |
| FR37 | Epic 2 | Empty State bienvenue |

---

## Liste des Epics

### Epic 1 : Navigation par Onglets et Affichage des Documents ✅ TERMINÉE

L'utilisateur peut naviguer entre les 5 onglets thématiques et voir ses documents filtrés automatiquement par type. C'est le coeur du Custom Segmented Control - l'utilisateur passe d'une liste unique confuse à une navigation mentale claire.

**FRs couverts:** FR1, FR2, FR3, FR4, FR5, FR6, FR7, FR8, FR9, FR11, FR26, FR28, FR29, FR30, FR31

**Stories:**
| ID | Titre | Statut |
|----|-------|--------|
| 1-1 | Custom Segmented Control Component | ✅ completed |
| 1-2 | Document Filtering by Tab | ✅ completed |

---

### Epic 2 : Vue d'Ensemble du Dashboard Véhicule 🚧 EN COURS

L'utilisateur peut voir un snapshot complet de son véhicule dans l'onglet Vue d'Ensemble : statistiques rapides, alertes importantes, documents incomplets et activités récentes. Cette vue offre une vision globale sans avoir à naviguer entre les onglets.

**FRs couverts:** FR10, FR23, FR24, FR32, FR33, FR34, FR35, FR36, FR37

**Source:** Session de brainstorming du 2026-01-26

**Architecture validée :**
- Section Mini-Stats : 2 cartes (Coût cette année + Dernier entretien)
- Section Alertes : Échéances légales + révisions (max 3, masquée si vide)
- Section À Compléter : Compteur documents incomplets (masquée si vide)
- Section Activités Récentes : 3 derniers documents (masquée si vide)
- Empty State : Message de bienvenue pour nouveaux véhicules

**Stories:**
| ID | Titre | Statut |
|----|-------|--------|
| 2-1 | Section Mini-Stats | ✅ completed |
| 2-2 | Section Alertes | ✅ completed |
| 2-3 | Section À Compléter | ✅ completed |
| 2-4 | Section Activités Récentes | ready-for-dev |
| 2-5 | Empty State Vue d'Ensemble | ready-for-dev |

---

### Epic 3 : Actions Contextuelles et Statistiques

L'utilisateur peut ajouter un document directement depuis l'onglet actif avec le type déjà pré-sélectionné, et consulter les statistiques détaillées de son véhicule. Élimine la friction cognitive du "quel type dois-je sélectionner ?".

**FRs couverts:** FR12, FR13, FR14, FR15, FR22, FR25, FR27

**Stories:**
| ID | Titre | Statut |
|----|-------|--------|
| 1-3 | Contextual Quick Actions | ready-for-dev |

---

## Epics Futures (Reportées)

### Epic Future : Guidage par Empty States

L'utilisateur novice est guidé naturellement via des empty states explicatifs avec exemples concrets et CTA clairs. Pattern "Learn by Doing".

**FRs couverts:** FR16, FR17, FR18, FR19, FR20, FR21

**Stories:**
| ID | Titre | Statut |
|----|-------|--------|
| 1-4 | Empty States with Guidance | reportée |

---

## Référence des Stories

| Fichier | Epic | Statut |
|---------|------|--------|
| `1-1-custom-segmented-control-component.md` | Epic 1 | ✅ completed |
| `1-2-document-filtering-by-tab.md` | Epic 1 | ✅ completed |
| `1-3-contextual-quick-actions.md` | Epic 3 | ready-for-dev |
| `1-4-empty-states-with-guidance.md` | Future | reportée |
| `2-1-section-mini-stats.md` | Epic 2 | ✅ completed |
| `2-2-section-alertes.md` | Epic 2 | ✅ completed |
| `2-3-section-a-completer.md` | Epic 2 | ✅ completed |
| `2-4-section-activites-recentes.md` | Epic 2 | ready-for-dev |
| `2-5-empty-state-vue-ensemble.md` | Epic 2 | ready-for-dev |

---

## Wireframe de Référence (Epic 2)

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
│   Bienvenue !                           │
│                                         │
│   Ajoutez votre premier document        │
│   pour commencer à suivre               │
│   votre véhicule.                       │
│                                         │
└─────────────────────────────────────────┘
```

---

**Dernière mise à jour :** 2026-01-26
**Version :** 2.0
