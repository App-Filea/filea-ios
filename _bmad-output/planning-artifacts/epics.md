---
stepsCompleted: [1, 2]
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - 'docs/architecture.md'
  - '_bmad-output/planning-artifacts/ux-design-specification.md'
storiesExist: true
storiesLocation: '_bmad-output/implementation-artifacts/'
---

# Holfy - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for Holfy, decomposing the requirements from the PRD, UX Design, and Architecture requirements into implementable stories.

**Note:** Les stories ont été créées précédemment et sont disponibles dans `implementation-artifacts/`.

## Requirements Inventory

### Functional Requirements

**Navigation & Gestion des Onglets**
- FR1: Users can view 5 themed tabs (Overview, Statistics, Maintenance & Repairs, Administration, Fuel) in main dashboard for current vehicle
- FR2: Users can switch between tabs by tapping on tab labels
- FR3: System displays currently active tab with distinct visual styling
- FR4: System preserves scroll position independently for each tab when switching
- FR5: Overview tab is displayed by default when opening main dashboard

**Filtrage & Affichage des Documents**
- FR6: System automatically filters and displays only documents of current vehicle matching the active tab's type
- FR7: Maintenance & Repairs tab displays documents of type `maintenance` and `repair` for current vehicle
- FR8: Administration tab displays documents of type `administrative` for current vehicle
- FR9: Fuel tab displays documents of type `fuel` for current vehicle
- FR10: Overview tab displays recent documents of all types for current vehicle
- FR11: Documents within each tab are displayed in chronological order (most recent first)

**Actions Contextuelles**
- FR12: Users can add a new maintenance document directly from Maintenance & Repairs tab with type pre-selected for current vehicle
- FR13: Users can add a new administrative document directly from Administration tab with type pre-selected for current vehicle
- FR14: Users can add a new fuel record directly from Fuel tab with type pre-selected for current vehicle
- FR15: System does not display add actions in Overview and Statistics tabs (read-only tabs)

**Empty States & Guidage (REPORTÉ)**
- FR16: System displays welcoming message when a tab contains no documents for current vehicle
- FR17: Empty state shows concrete examples of document types that belong in that tab
- FR18: Empty state displays clear call-to-action button to add first document of that type
- FR19: Empty state examples for Maintenance: "Oil change, Tire replacement, Service"
- FR20: Empty state examples for Administration: "Registration, Insurance, Technical inspection"
- FR21: Empty state examples for Fuel: "Gas fill-ups, Electric charges"

**Statistiques & Vue d'Ensemble**
- FR22: Statistics tab displays 4-5 existing essential statistics cards for current vehicle
- FR23: Overview tab displays current vehicle snapshot information (brand, model, mileage)
- FR24: Overview tab displays recent document timeline across all types for current vehicle
- FR25: System reuses existing statistics calculation logic for Statistics tab display

**Intégrité des Données**
- FR26: System ensures documents are stored once in database (GRDB) regardless of tab filtering
- FR27: System maintains document type accuracy when adding via Quick Actions
- FR28: Changes to documents (edit, delete) are reflected immediately across all relevant tabs

**Gestion Contexte Véhicule**
- FR29: Main dashboard displays Custom Segmented Control for currently selected vehicle
- FR30: When user switches vehicles via VehiclesList, main dashboard updates to show new vehicle's data in all tabs
- FR31: System maintains last active tab selection when switching between vehicles

### NonFunctional Requirements

**Performance**
- NFR1: Tab switching completes in under 100 milliseconds on target devices (iPhone running iOS 18.5+)
- NFR2: Document list scrolling maintains 60 FPS (frames per second) with up to 100 documents per tab
- NFR3: Initial tab load (when opening main dashboard) completes in under 200 milliseconds
- NFR4: Memory usage remains stable during extended tab switching sessions (no memory leaks detected via Instruments)

**Accessibilité**
- NFR5: Custom Segmented Control supports VoiceOver with clear announcements of tab names and selection state
- NFR6: Tab labels and controls support Dynamic Type for text size adjustments
- NFR7: Tab switching is operable via iOS accessibility gestures (swipe navigation)
- NFR8: Empty states maintain sufficient color contrast ratios (WCAG AA minimum: 4.5:1 for text)
- NFR9: Quick Action buttons have minimum touch target size of 44×44 points per Apple HIG

**Fiabilité**
- NFR10: Zero crashes related to tab switching or filtering logic during normal operation
- NFR11: Scroll position is preserved accurately when switching between tabs (within 5 points of original position)
- NFR12: Document count accuracy maintained across all tabs (no duplicate or missing documents)
- NFR13: Tab state survives app backgrounding and restoration without data loss

**Maintenabilité**
- NFR14: All new TCA stores follow existing project patterns (composition of reducers, @Shared state usage)
- NFR15: Code adheres to Swift 6 strict concurrency requirements (no data races, proper Sendable conformance)
- NFR16: Unit test coverage of at least 80% for new tab-related stores and filtering logic
- NFR17: All tests follow BDD pattern (Given-When-Then) as defined in CLAUDE.md conventions
- NFR18: New SwiftUI components reuse existing Design System tokens (ColorTokens, SpacingTokens, TypographyTokens, RadiusTokens)
- NFR19: Inline documentation provided for all new public APIs and complex logic

### Additional Requirements

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

### FR Coverage Map

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
| FR10 | Epic 1 | Vue d'Ensemble : tous types récents |
| FR11 | Epic 1 | Tri chronologique |
| FR12 | Epic 2 | Quick Action Entretien |
| FR13 | Epic 2 | Quick Action Admin |
| FR14 | Epic 2 | Quick Action Carburant |
| FR15 | Epic 2 | Pas d'actions dans Overview/Stats |
| FR16-FR21 | 🔜 Future | Empty States (reporté) |
| FR22 | Epic 3 | Cards statistiques |
| FR23 | Epic 3 | Snapshot véhicule |
| FR24 | Epic 3 | Timeline documents récents |
| FR25 | Epic 3 | Réutilisation logique stats |
| FR26 | Epic 1 | Source unique GRDB |
| FR27 | Epic 2 | Précision type Quick Actions |
| FR28 | Epic 1 | Mise à jour cross-onglets |
| FR29 | Epic 1 | Segmented Control véhicule actuel |
| FR30 | Epic 1 | Mise à jour changement véhicule |
| FR31 | Epic 1 | Conservation onglet actif |

## Epic List

### Epic 1 : Navigation par Onglets et Affichage des Documents

L'utilisateur peut naviguer entre les 5 onglets thématiques et voir ses documents filtrés automatiquement par type. C'est le cœur du Custom Segmented Control - l'utilisateur passe d'une liste unique confuse à une navigation mentale claire.

**FRs couverts:** FR1, FR2, FR3, FR4, FR5, FR6, FR7, FR8, FR9, FR10, FR11, FR26, FR28, FR29, FR30, FR31

**Stories existantes:**
- 1-1: Custom Segmented Control Component
- 1-2: Document Filtering by Tab

### Epic 2 : Actions Contextuelles d'Ajout Rapide (Quick Actions)

L'utilisateur peut ajouter un document directement depuis l'onglet actif avec le type déjà pré-sélectionné. Élimine la friction cognitive du "quel type dois-je sélectionner ?".

**FRs couverts:** FR12, FR13, FR14, FR15, FR27

**Stories existantes:**
- 1-3: Contextual Quick Actions

### Epic 3 : Vue d'Ensemble et Statistiques

L'utilisateur peut voir un snapshot de son véhicule et les statistiques clés dans des onglets dédiés.

**FRs couverts:** FR22, FR23, FR24, FR25

**Stories existantes:**
- (À mapper avec les stories existantes ou à créer)

---

## Future Epics (Reportés)

### 🔜 Epic Future : Guidage par Empty States

L'utilisateur novice est guidé naturellement via des empty states explicatifs avec exemples concrets et CTA clairs. Pattern "Learn by Doing".

**FRs couverts:** FR16, FR17, FR18, FR19, FR20, FR21

**Stories existantes:**
- 1-4: Empty States with Guidance (créée mais reportée)

---

## Stories Existantes (Référence)

| Fichier | Epic | Statut |
|---------|------|--------|
| `1-1-custom-segmented-control-component.md` | Epic 1 | ✅ Existante |
| `1-2-document-filtering-by-tab.md` | Epic 1 | ✅ Existante |
| `1-3-contextual-quick-actions.md` | Epic 2 | ✅ Existante |
| `1-4-empty-states-with-guidance.md` | 🔜 Future | Reportée |
| `1-5-ocr-smart-document-scan.md` | - | Hors scope actuel |
