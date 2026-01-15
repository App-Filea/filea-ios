---
stepsCompleted: [1, 2, 3, 4, 9, 10, 11]
inputDocuments:
  - 'docs/index.md'
  - 'docs/project-overview.md'
  - 'docs/architecture.md'
  - 'docs/deployment-guide.md'
  - 'docs/development-guide.md'
  - 'docs/source-tree-analysis.md'
  - 'CLAUDE.md'
  - '_bmad-output/analysis/brainstorming-session-2026-01-08.md'
workflowType: 'prd'
lastStep: 11
completed: true
completionDate: '2026-01-12'
documentCounts:
  briefCount: 0
  researchCount: 0
  brainstormingCount: 1
  projectDocsCount: 6
  projectContextCount: 1
---

# Product Requirements Document - Holfy

**Author:** Nicolas
**Date:** 2026-01-11

## Executive Summary

**Holfy** est une application iOS native de gestion de documents automobiles construite avec SwiftUI et Composable Architecture (TCA). L'application permet aux utilisateurs de gérer plusieurs véhicules et de suivre leurs documents (administratifs, entretien, réparations, carburant) avec un système de stockage local-first hybride GRDB + JSON.

Ce PRD définit l'ajout du **Custom Segmented Control** à la vue de détails d'un véhicule, transformant l'expérience de navigation actuelle d'une page unique scrollable vers une architecture thématique organisée en 5 onglets distincts.

**Vision de cette évolution :**

L'actuelle page de détails véhicule présente une liste unique mélangeant tous les types de documents, créant une friction cognitive pour les utilisateurs qui doivent scanner visuellement l'ensemble pour trouver ce qu'ils cherchent. Le Custom Segmented Control résout ce problème en introduisant une navigation thématique claire où chaque catégorie de document a son propre espace dédié.

**Objectif principal :**
- Permettre aux utilisateurs de trouver rapidement l'information recherchée en éliminant le scroll et le scan visuel
- Fournir des actions contextuelles intelligentes (Quick Actions) adaptées à chaque section
- Préparer l'architecture pour de futures extensions de fonctionnalités

**Utilisateurs cibles :**
- **Propriétaires d'un véhicule unique** (Marc) : Gain de temps après apprentissage initial
- **Gestionnaires de flottes familiales** (Sophie) : Navigation efficace entre véhicules et sections
- **Novices** (Thomas) : Guidage naturel via empty states explicatifs
- **Analystes passionnés** (Jean) : Organisation claire pour analyses approfondies

### What Makes This Special

Le Custom Segmented Control transforme une page unique confuse en une expérience de navigation thématique intuitive qui **grandit en valeur** avec le volume de documents. Contrairement à une simple amélioration visuelle, cette feature crée une architecture scalable qui :

1. **Élimine la friction cognitive** : L'utilisateur n'a plus à se demander "où dois-je chercher ?" ou "quel type de document dois-je ajouter ?"

2. **Apporte des actions contextuelles intelligentes** : Chaque onglet propose une Quick Action pré-configurée pour son contexte (ex: "Ajouter Entretien" dans l'onglet Entretiens, avec le type déjà sélectionné)

3. **Guide les novices naturellement** : Les empty states avec exemples concrets transforment chaque onglet vide en mini-tutoriel ("Voici ce qui va ici, voici pourquoi, voici comment l'ajouter")

4. **Scale avec l'usage** : Plus un utilisateur accumule de documents (après 1 an, 2 ans, 5 ans d'utilisation), plus le gain de temps devient significatif comparé à une longue liste scrollable

**Moment clé utilisateur :**
> "Ah ! Je n'ai plus besoin de chercher dans toute la liste pour voir mes entretiens ou mes pleins d'essence. Tout est organisé exactement comme je le pense."

## Project Classification

**Technical Type:** mobile_app
**Domain:** general
**Complexity:** low
**Project Context:** Brownfield - extending existing system

**Architecture existante :**
- **Plateforme** : iOS 18.5+ native (SwiftUI)
- **Pattern** : Composable Architecture (TCA) unidirectionnel
- **State Management** : 19 TCA Stores avec @Shared state
- **Data Layer** : Architecture Hybride GRDB + JSON (local-first)
- **Design System** : Tokens personnalisés (Color, Spacing, Typography, Radius)

**Intégration technique :**

Cette feature s'intègre dans l'architecture TCA existante en :
- Créant un nouveau `VehicleDetailTabStore` avec composition de reducers pour chaque onglet
- Réutilisant les stores existants (`DocumentsListStore`, `StatisticsStore`) comme child reducers
- Étendant le Design System avec les nouveaux composants (Segmented Control, Empty States)
- Préservant la logique métier existante (VehicleGRDBClient, DocumentRepository)

L'architecture modulaire TCA permet d'ajouter cette navigation sans refonte majeure, en composant les fonctionnalités existantes dans une nouvelle structure de présentation.

## Success Criteria

### User Success

Le succès utilisateur du Custom Segmented Control se mesure par la capacité de l'utilisateur à **retrouver rapidement un document parmi ceux qu'il a ajoutés**. La séparation thématique élimine le besoin de scanner visuellement une longue liste unique en offrant une organisation mentale claire.

**Moment clé de succès :**
> "Quand je dois retrouver un document parmi ceux que j'ai ajoutés, la séparation thématique me permet de savoir instantanément où chercher (Entretiens vs Admin vs Carburant) au lieu de scroller toute la liste."

**Indicateurs mesurables :**

1. **Temps de recherche d'information**
   - Utilisateur trouve un document spécifique en < 15 secondes (vs ~45 secondes avec scroll actuel)
   - Mesure : Analytics de navigation temps entre ouverture véhicule et ouverture document

2. **Adoption de la navigation par onglets**
   - > 80% des utilisateurs actifs utilisent au moins 3 onglets différents par semaine
   - Indique que l'apprentissage de la navigation thématique a réussi

3. **Réduction de la friction cognitive**
   - Temps moyen pour ajouter un document réduit de 30% grâce aux Quick Actions contextuelles
   - L'utilisateur ne se demande plus "quel type dois-je sélectionner ?"

**Échelle de valeur temporelle :**
Plus l'utilisateur accumule de documents (1 an, 2 ans, 5 ans d'utilisation), plus le gain de temps devient significatif. Un utilisateur avec 50+ documents dans une liste unique perdait ~2 minutes par recherche. Avec la séparation thématique, il retrouve le document en quelques secondes.

### Business Success

**À 3 mois - Adoption :**
- **Métrique principale** : > 80% des utilisateurs actifs utilisent au moins 3 onglets différents par semaine
- **Indicateur secondaire** : Chaque onglet reçoit au moins 1 visite par session utilisateur en moyenne
- **Validation** : L'analytics montre que les utilisateurs ont compris et adopté la navigation thématique

**À 12 mois - Satisfaction :**
- **Métrique principale** : Note moyenne ≥ 4.5/5 sur l'App Store
- **Indicateur qualitatif** : Mentions positives de la navigation dans les reviews utilisateurs
- **Validation** : Les utilisateurs recommandent l'app pour son organisation claire

**Hypothèse de succès :**
Si les utilisateurs adoptent la navigation par onglets (3 mois) et que cela se traduit par une satisfaction mesurable (12 mois), alors le Custom Segmented Control aura prouvé sa valeur comme amélioration UX majeure.

### Technical Success

**1. Performance**
- Changement d'onglet instantané (< 100ms de latence)
- Pas de lag lors du scroll dans les listes de documents
- Mémoire stable sans memory leaks (profiling Instruments)

**2. Qualité du Code**
- Architecture TCA propre avec composition de reducers
- Tests unitaires des stores suivant le pattern BDD (Given-When-Then)
- Réutilisation des stores existants (`DocumentsListStore`, `StatisticsStore`) comme child reducers
- Pas de duplication de logique métier

**3. Intégration**
- Pas de régression sur les features existantes (suite de tests complète)
- Compatible avec le Design System actuel (ColorTokens, SpacingTokens, TypographyTokens, RadiusTokens)
- Migration transparente pour les utilisateurs existants (aucune perte de données, navigation préservée)

**4. Maintenabilité**
- Code Swift 6 idiomatique (strict concurrency, sendable conformance)
- Documentation inline des nouveaux composants (SwiftUI views, TCA stores)
- Respect strict des conventions du fichier `CLAUDE.md`
- Pattern de nommage cohérent avec l'architecture existante

### Measurable Outcomes

**Semaine 1 Post-Déploiement :**
- Tests de performance validés (changement onglet < 100ms)
- Aucun crash reporté lié à la nouvelle navigation
- Analytics de navigation configurés et fonctionnels

**Mois 1 Post-Déploiement :**
- > 70% des utilisateurs actifs ont exploré au moins 3 onglets
- Taux de complétion onboarding > 85%
- Feedback qualitatif initial collecté

**Mois 3 Post-Déploiement :**
- **Objectif principal atteint** : > 80% utilisateurs actifs utilisent 3+ onglets/semaine
- Temps moyen de recherche document < 15 secondes validé par analytics
- Aucune régression de performance sur les autres features

**Mois 12 Post-Déploiement :**
- **Objectif principal atteint** : Note App Store ≥ 4.5/5
- Reviews mentionnent positivement la navigation organisée
- Rétention utilisateur stable ou en croissance

## Product Scope

### MVP - Minimum Viable Product

**Ce qui doit absolument fonctionner pour que ce soit utile :**

#### 1. Les 5 Onglets Fonctionnels

- **📋 Vue d'Ensemble** (onglet par défaut)
  - Page read-only avec snapshot du véhicule
  - Informations globales (marque, modèle, kilométrage)
  - Liste des documents récents (tous types confondus)
  - Aucune action d'ajout (orientation informative pure)

- **📊 Statistiques**
  - 4-5 cards de statistiques essentielles existantes
  - Réorganisation des stats actuelles dans un espace dédié
  - Graphiques et métriques déjà disponibles

- **🔧 Entretiens & Réparations**
  - Liste filtrée : `DocumentType.maintenance` + `DocumentType.repair`
  - Fusion logique (réparations moins fréquentes que entretiens)
  - Affichage chronologique des documents

- **🏛️ Administration**
  - Liste filtrée : `DocumentType.administrative`
  - Carte grise, assurance, contrôle technique
  - Affichage chronologique des documents

- **⛽ Carburant**
  - Liste filtrée : `DocumentType.fuel`
  - Historique des pleins d'essence
  - Affichage chronologique des documents

#### 2. Navigation de Base

- Tap sur un onglet → Affiche le contenu correspondant
- État de l'onglet actif visuellement distinct (Design System : AccentLabel ou équivalent)
- Scroll indépendant par onglet (préservation de la position)
- Changement d'onglet fluide et instantané

#### 3. Quick Actions Contextuelles

- Bouton "➕ Ajouter Entretien" dans l'onglet Entretiens & Réparations
- Bouton "➕ Ajouter Document Admin" dans l'onglet Administration
- Bouton "➕ Ajouter Plein" dans l'onglet Carburant
- Type de document pré-sélectionné selon l'onglet actif
- Pas de Quick Action dans Vue d'Ensemble et Statistiques (read-only)

#### 4. Empty States Explicatifs

- Message accueillant quand onglet vide
- Exemples concrets de ce qui va dans cet onglet
  - Entretiens : "Vidange moteur, Changement pneus, Révision"
  - Administration : "Carte grise, Assurance, Contrôle technique"
  - Carburant : "Pleins d'essence, Recharges électriques"
- CTA clair : "➕ Ajouter Votre Premier [Type]"
- Design cohérent avec le Design System existant

#### 5. Filtrage des Documents

- Documents affichés uniquement dans l'onglet correspondant à leur `DocumentType`
- Vue d'Ensemble montre tous les documents récents (pas de filtre)
- Logique de filtrage réutilise les repositories existants
- Aucune duplication de données (source unique : GRDB)

**Critère de validation MVP :**
Sans ces 5 éléments, la navigation thématique ne serait pas fonctionnelle ni utile pour l'utilisateur.

### Growth Features (Post-MVP)

**Ce qui enrichit l'expérience après validation du MVP :**

#### 1. Tooltips Progressifs
- Apparaissent après plusieurs utilisations si une fonctionnalité n'a pas été découverte
- Jamais intrusifs (dismissible facilement)
- Contextuels et pertinents au parcours utilisateur
- Exemple : "Vous pouvez ajouter un document directement depuis cet onglet avec le bouton ➕"

#### 2. Alertes CT Enrichies (Dates Doubles)
- Affichage dans la Vue d'Ensemble de deux dates pour le Contrôle Technique :
  - "Dernier effectué : 15/02/2025"
  - "Expire le : 15/02/2027"
- Indicateur visuel de statut :
  - ✅ À jour (> 60 jours avant expiration)
  - 🔴 Bientôt (< 60 jours avant expiration)
- Résout la confusion identifiée dans le brainstorming (persona Marc)

**Timeline Growth :**
Ces features peuvent être ajoutées 2-4 semaines après le déploiement MVP, une fois l'adoption validée.

### Vision (Future)

**Version de rêve à long terme (V2, V3+) :**

#### Recherche Cross-Onglets
- Barre de recherche globale accessible depuis n'importe quel onglet
- Recherche fulltext dans tous les documents (titre, notes, montant)
- Résultats groupés visuellement par onglet/type
- Tap sur résultat → Ouvre l'onglet correspondant avec le document mis en surbrillance
- Utile pour utilisateurs avec 100+ documents accumulés sur plusieurs années

**Priorité Future :**
Cette feature n'est pas critique pour le succès initial mais devient précieuse à mesure que le volume de documents augmente. À considérer pour V2 après validation de l'adoption et satisfaction du MVP.

## User Journeys

### Journey 1 : Marc - Retrouver Rapidement Son Dernier Contrôle Technique

**Opening Scene :**
Marc vient de recevoir un SMS de son assurance qui demande une preuve de contrôle technique valide pour renouveler sa police. Il ouvre Holfy en mode pressé pendant sa pause déjeuner au bureau. Avec l'ancienne interface, il devait scroller une longue liste mélangeant ses 15 pleins d'essence, 8 factures de vidange, et 3 documents administratifs pour retrouver son CT. "J'ai 5 minutes, pas 2 heures..."

**Rising Action :**
Avec le nouveau Custom Segmented Control, Marc tape sur son véhicule et découvre immédiatement les 5 onglets thématiques. Son regard se pose instantanément sur l'onglet "🏛️ Administration". Un tap. Là, seulement 3 documents : carte grise, assurance, contrôle technique. 3 secondes chrono.

**Climax :**
Il tape sur son contrôle technique, partage le document à son assureur par email directement depuis l'app. "Ah ! Je n'ai plus besoin de chercher dans toute la liste. Tout est organisé exactement comme je le pense."

**Resolution :**
Marc a résolu son problème en moins de 30 secondes au lieu des 2 minutes habituelles de scroll et scan visuel. Dès la semaine suivante, quand il doit ajouter un nouveau plein d'essence, il tape directement sur l'onglet "⛽ Carburant" et utilise le bouton "➕ Ajouter Plein" qui pré-sélectionne le bon type. Plus de friction cognitive.

---

### Journey 2 : Sophie - Naviguer Efficacement Entre 4 Véhicules

**Opening Scene :**
Sophie gère les documents automobiles de toute sa famille : 2 voitures, 1 moto, 1 scooter. Son fils lui demande "Maman, l'assurance de la moto expire quand ?". Avant, Sophie devait : ouvrir la moto → scroller 20+ documents pour trouver l'assurance parmi les pleins et entretiens → vérifier. Puis son mari l'appelle : "Chérie, on a fait la vidange de quelle voiture ce mois-ci ?" Elle devait recommencer le processus pour chaque véhicule.

**Rising Action :**
Avec le Custom Segmented Control, Sophie ouvre la moto et tape directement sur "🏛️ Administration". L'assurance apparaît immédiatement avec 2 autres documents admin. Elle note la date d'expiration. Pour la question de son mari, elle ouvre la première voiture, tape "🔧 Entretiens", voit la vidange du 15 janvier. Passe à la deuxième voiture, même onglet : pas de vidange récente. "C'était la Clio !"

**Climax :**
Sophie réalise qu'elle navigue maintenant par **contexte thématique** plutôt que par **véhicule complet**. "Je cherche une info admin ? J'ouvre l'onglet Admin de chaque véhicule. Je cherche un entretien ? J'ouvre l'onglet Entretiens." La navigation mentale devient claire et prédictible.

**Resolution :**
Ce qui prenait 5 minutes et beaucoup de scroll prend maintenant 45 secondes. Sophie découvre aussi les Quick Actions : quand elle doit ajouter un plein pour le scooter, elle va directement dans l'onglet Carburant et tape "➕ Ajouter Plein" - le type est déjà sélectionné. Elle gagne 1min45s par session de gestion, ce qui représente ~45 minutes économisées par mois.

---

### Journey 3 : Thomas - Premiers Pas Guidés Naturellement

**Opening Scene :**
Thomas vient d'acheter sa première voiture d'occasion, une Peugeot 208. Il télécharge Holfy sur recommandation d'un ami mais ne sait pas vraiment par où commencer. Il crée son véhicule et arrive sur la vue de détails. Les 5 onglets apparaissent : Vue d'Ensemble, Statistiques, Entretiens & Réparations, Administration, Carburant. "Ok... c'est quoi tout ça ?"

**Rising Action :**
Thomas tape sur "🏛️ Administration" par curiosité. Au lieu d'une liste vide déroutante, il découvre un message accueillant : "Aucun Document Administratif" avec des exemples concrets : "Carte grise, Assurance, Contrôle technique". Un gros bouton : "➕ Ajouter Votre Premier Document Admin". "Ah ! C'est ici que va ma carte grise !"

**Climax :**
Thomas explore les autres onglets, chacun avec son empty state explicatif. L'onglet "🔧 Entretiens" lui montre : "Vidange moteur, Changement pneus, Révision". Il comprend instantanément l'organisation sans avoir besoin d'un tutoriel lourd. Le texte clair (sans icônes complexes) correspond à son expérience Spotify/Instagram - moderne et épuré.

**Resolution :**
En 10 minutes, Thomas a ajouté sa carte grise, son assurance et son premier plein d'essence. Chaque onglet l'a guidé naturellement vers ce qu'il fallait y mettre. Deux semaines plus tard, quand il fait sa première vidange, il sait exactement où l'ajouter : onglet Entretiens, bouton "➕ Ajouter Entretien". Le pattern "Learn by Doing" a fonctionné - il a appris en utilisant, pas en lisant.

---

### Journey 4 : Jean - Organisation Claire Pour Analyses Approfondies

**Opening Scene :**
Jean est ingénieur et adore analyser les coûts de ses 3 véhicules : sa Tesla Model 3 (électrique), sa BMW Série 3 (essence), et sa Kawasaki Ninja (moto). Chaque dimanche matin, il passe 30 minutes à examiner ses dépenses, comparer les coûts par kilomètre, identifier les tendances. Avec l'ancienne interface liste unique, il devait mentalement filtrer "Ok, ça c'est un plein, ça c'est une vidange, ça c'est du carburant...".

**Rising Action :**
Avec le Custom Segmented Control, Jean ouvre sa Tesla et tape sur "⛽ Carburant". Il voit instantanément ses 12 recharges électriques du mois. Pas de bruit mental, pas de documents d'entretien mélangés. Il tape sur "📊 Statistiques" : ses 4-5 cards essentielles apparaissent avec les métriques qu'il aime analyser. Pour comparer avec sa BMW essence, même process : onglet Carburant, il voit uniquement les 8 pleins d'essence.

**Climax :**
Jean réalise que la séparation thématique ne lui fait pas juste gagner du temps - elle **améliore la qualité de ses analyses**. Il peut maintenant isoler parfaitement chaque catégorie de dépenses sans bruit visuel. Quand il veut voir l'historique complet d'entretien de sa moto, l'onglet Entretiens lui donne une vue chrono-logique pure de ses 15 maintenances sur 3 ans.

**Resolution :**
L'organisation claire permet à Jean d'aller plus loin dans ses analyses. Il peut rapidement extraire des insights par catégorie : "Ma Tesla coûte 0.15€/km en électricité contre 0.45€/km pour la BMW en essence". L'onglet Statistiques devient son point d'entrée favori pour ses sessions d'analyse hebdomadaires. La navigation thématique a transformé sa routine d'analyse chaotique en process structuré et efficace.

---

### Journey Requirements Summary

Ces 4 parcours utilisateurs révèlent les exigences suivantes pour le Custom Segmented Control :

**1. Navigation & Organisation**
- 5 onglets thématiques distincts (Vue d'Ensemble, Stats, Entretiens, Admin, Carburant)
- Filtrage automatique des documents par type selon l'onglet
- État visuel clair de l'onglet actif
- Changement d'onglet instantané et fluide

**2. Empty States & Onboarding**
- Messages accueillants avec exemples concrets par onglet
- CTA clairs ("➕ Ajouter Votre Premier [Type]")
- Guidage naturel sans tutoriel lourd (Learn by Doing)
- Design moderne et épuré (texte prioritaire sur icônes)

**3. Quick Actions Contextuelles**
- Boutons d'ajout par onglet avec type pré-sélectionné
- "➕ Ajouter Entretien" dans Entretiens
- "➕ Ajouter Document Admin" dans Administration
- "➕ Ajouter Plein" dans Carburant

**4. Performance & Comportement**
- Scroll indépendant par onglet (préservation position)
- Temps de recherche < 15 secondes pour Marc
- Navigation mentale prévisible pour Sophie
- Organisation claire pour analyses de Jean

**5. Affichage des Données**
- Liste chronologique des documents par onglet
- Vue d'Ensemble montre tous les documents récents
- Onglet Statistiques regroupe les métriques existantes
- Pas de duplication de données (source GRDB unique)

## Functional Requirements

### Navigation & Tab Management

- **FR1**: Users can view 5 themed tabs (Overview, Statistics, Maintenance & Repairs, Administration, Fuel) in main dashboard for current vehicle
- **FR2**: Users can switch between tabs by tapping on tab labels
- **FR3**: System displays currently active tab with distinct visual styling
- **FR4**: System preserves scroll position independently for each tab when switching
- **FR5**: Overview tab is displayed by default when opening main dashboard

### Document Filtering & Display

- **FR6**: System automatically filters and displays only documents of current vehicle matching the active tab's type
- **FR7**: Maintenance & Repairs tab displays documents of type `maintenance` and `repair` for current vehicle
- **FR8**: Administration tab displays documents of type `administrative` for current vehicle
- **FR9**: Fuel tab displays documents of type `fuel` for current vehicle
- **FR10**: Overview tab displays recent documents of all types for current vehicle
- **FR11**: Documents within each tab are displayed in chronological order (most recent first)

### Contextual Actions

- **FR12**: Users can add a new maintenance document directly from Maintenance & Repairs tab with type pre-selected for current vehicle
- **FR13**: Users can add a new administrative document directly from Administration tab with type pre-selected for current vehicle
- **FR14**: Users can add a new fuel record directly from Fuel tab with type pre-selected for current vehicle
- **FR15**: System does not display add actions in Overview and Statistics tabs (read-only tabs)

### Empty States & Guidance

- **FR16**: System displays welcoming message when a tab contains no documents for current vehicle
- **FR17**: Empty state shows concrete examples of document types that belong in that tab
- **FR18**: Empty state displays clear call-to-action button to add first document of that type
- **FR19**: Empty state examples for Maintenance: "Oil change, Tire replacement, Service"
- **FR20**: Empty state examples for Administration: "Registration, Insurance, Technical inspection"
- **FR21**: Empty state examples for Fuel: "Gas fill-ups, Electric charges"

### Statistics & Overview Display

- **FR22**: Statistics tab displays 4-5 existing essential statistics cards for current vehicle
- **FR23**: Overview tab displays current vehicle snapshot information (brand, model, mileage)
- **FR24**: Overview tab displays recent document timeline across all types for current vehicle
- **FR25**: System reuses existing statistics calculation logic for Statistics tab display

### Data Integrity

- **FR26**: System ensures documents are stored once in database (GRDB) regardless of tab filtering
- **FR27**: System maintains document type accuracy when adding via Quick Actions
- **FR28**: Changes to documents (edit, delete) are reflected immediately across all relevant tabs

### Vehicle Context Management

- **FR29**: Main dashboard displays Custom Segmented Control for currently selected vehicle
- **FR30**: When user switches vehicles via VehiclesList, main dashboard updates to show new vehicle's data in all tabs
- **FR31**: System maintains last active tab selection when switching between vehicles

## Non-Functional Requirements

### Performance

- **NFR1**: Tab switching completes in under 100 milliseconds on target devices (iPhone running iOS 18.5+)
- **NFR2**: Document list scrolling maintains 60 FPS (frames per second) with up to 100 documents per tab
- **NFR3**: Initial tab load (when opening main dashboard) completes in under 200 milliseconds
- **NFR4**: Memory usage remains stable during extended tab switching sessions (no memory leaks detected via Instruments)

### Accessibility

- **NFR5**: Custom Segmented Control supports VoiceOver with clear announcements of tab names and selection state
- **NFR6**: Tab labels and controls support Dynamic Type for text size adjustments
- **NFR7**: Tab switching is operable via iOS accessibility gestures (swipe navigation)
- **NFR8**: Empty states maintain sufficient color contrast ratios (WCAG AA minimum: 4.5:1 for text)
- **NFR9**: Quick Action buttons have minimum touch target size of 44×44 points per Apple HIG

### Reliability

- **NFR10**: Zero crashes related to tab switching or filtering logic during normal operation
- **NFR11**: Scroll position is preserved accurately when switching between tabs (within 5 points of original position)
- **NFR12**: Document count accuracy maintained across all tabs (no duplicate or missing documents)
- **NFR13**: Tab state survives app backgrounding and restoration without data loss

### Maintainability

- **NFR14**: All new TCA stores follow existing project patterns (composition of reducers, @Shared state usage)
- **NFR15**: Code adheres to Swift 6 strict concurrency requirements (no data races, proper Sendable conformance)
- **NFR16**: Unit test coverage of at least 80% for new tab-related stores and filtering logic
- **NFR17**: All tests follow BDD pattern (Given-When-Then) as defined in CLAUDE.md conventions
- **NFR18**: New SwiftUI components reuse existing Design System tokens (ColorTokens, SpacingTokens, TypographyTokens, RadiusTokens)
- **NFR19**: Inline documentation provided for all new public APIs and complex logic

