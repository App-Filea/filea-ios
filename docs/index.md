# Documentation du Projet Holfy

**Projet :** Holfy (Filea)
**Version :** 1.0 (Build 5)
**Type :** Application iOS
**Date de génération :** 2026-01-11
**Mode de scan :** Quick Scan (basé sur patterns)

---

## 🎯 Point d'Entrée Principal

Bienvenue dans la documentation du projet **Holfy** ! Ce document sert de **guide central** pour naviguer dans toute la documentation générée et existante.

> 📝 **Note** : Cette documentation a été générée avec un **Quick Scan** (analyse basée sur les patterns de fichiers). Pour des détails plus approfondis sur le contenu du code, un Deep ou Exhaustive Scan est recommandé.

---

## 📋 Aperçu du Projet

**Holfy** est une application iOS native de gestion de documents automobiles qui permet aux utilisateurs de :

- 📁 Gérer plusieurs véhicules (voitures, motos, camions, vélos, autres)
- 📄 Stocker et organiser des documents (administratifs, entretien, réparations, carburant)
- 📊 Suivre les dépenses avec statistiques et graphiques
- 💾 Conserver toutes les données localement avec backup JSON automatique
- 📸 Scanner les cartes grises avec OCR

### Caractéristiques Techniques

| Attribut | Valeur |
|----------|--------|
| **Type de projet** | Monolithe (1 partie) |
| **Langage** | Swift 6.0 |
| **Framework UI** | SwiftUI |
| **Architecture** | Composable Architecture (TCA) |
| **Base de données** | GRDB (SQLite Data 1.4.3+) |
| **Plateforme** | iOS 18.5+ |
| **Fichiers Swift** | 105 |
| **TCA Stores** | 19 |

---

## 🗂️ Quick Reference

### Stack Technologique

- **Langage** : Swift 6.0
- **UI** : SwiftUI
- **Architecture** : Composable Architecture (TCA) 1.22.2+
- **Base de données** : SQLite Data (GRDB) 1.4.3+
- **Réactivité** : Combine
- **Déploiement** : Fastlane
- **IDE** : Xcode 16.4

### Point d'Entrée

- **Fichier principal** : `Holfy/HolfyApp.swift`
- **Bundle ID** : `com.nicolasbarb.filea`
- **Deployment Target** : iOS 18.5+

### Pattern d'Architecture

**TCA (Unidirectionnel)** :
```
Vue → Action → Reducer → Effect → Nouveau State → Vue
```

**Couches** :
1. Presentation (Stores + Views)
2. Domain (Models)
3. Data (Repositories + GRDB)
4. Infrastructure (Services + Storage)

---

## 📚 Documentation Générée

### Documentation Principale

- [**Aperçu du Projet**](./project-overview.md)
  Vue d'ensemble complète du projet, fonctionnalités, et contexte

- [**Architecture**](./architecture.md)
  Documentation technique complète de l'architecture, patterns, et décisions techniques

- [**Analyse de l'Arbre des Sources**](./source-tree-analysis.md)
  Structure détaillée du projet avec annotations et organisation des fichiers

- [**Guide de Développement**](./development-guide.md)
  Instructions pour configurer l'environnement, développer, et tester

- [**Guide de Déploiement**](./deployment-guide.md)
  Processus de build, certificats, et déploiement TestFlight/App Store

### Documentation Complémentaire (Quick Scan)

Les documents suivants n'ont pas été générés car le Quick Scan ne lit pas le contenu des fichiers source. Pour les générer, exécutez un Deep ou Exhaustive Scan.

- [**Inventaire des Composants UI**](./component-inventory.md) _(To be generated)_
  Liste complète des composants SwiftUI réutilisables

- [**Modèles de Données Détaillés**](./data-models.md) _(To be generated)_
  Schémas de base de données GRDB, relations, et migrations

- [**Contrats de Services**](./api-contracts.md) _(To be generated)_
  Documentation des repositories, clients, et services internes

---

## 📖 Documentation Existante

Documentation déjà présente dans le projet :

- [**CLAUDE.md**](../CLAUDE.md)
  Guide complet pour le développement AI-assisté avec Claude Code. Contient :
  - Conventions de code Swift 6
  - Architecture TCA détaillée
  - Pattern Repository et Dependencies
  - Conventions de tests (BDD)
  - Configuration MCP

- [**setup_match.md**](../setup_match.md)
  Guide de configuration Fastlane Match pour la gestion des certificats Apple

- [**fastlane/README.md**](../fastlane/README.md)
  Documentation des actions Fastlane disponibles (beta, build, screenshots, match)

- [**.claude/commands/ios-senior.md**](../.claude/commands/ios-senior.md)
  Commande custom Claude pour agent iOS senior

---

## 🚀 Getting Started

### Pour les Nouveaux Développeurs

1. **Lire l'aperçu** : [project-overview.md](./project-overview.md)
2. **Comprendre l'architecture** : [architecture.md](./architecture.md)
3. **Configuration** : [development-guide.md](./development-guide.md)
4. **Explorer le code** : [source-tree-analysis.md](./source-tree-analysis.md)
5. **Consulter CLAUDE.md** : [../CLAUDE.md](../CLAUDE.md)

### Pour le Déploiement

1. **Certificats** : [../setup_match.md](../setup_match.md)
2. **Déploiement** : [deployment-guide.md](./deployment-guide.md)
3. **Fastlane** : [../fastlane/README.md](../fastlane/README.md)

### Pour les Nouvelles Fonctionnalités (Brownfield PRD)

Lors de la planification de nouvelles fonctionnalités :

1. **Référencer cette documentation** : Pointer vers `docs/index.md` dans le workflow PRD
2. **Architecture** : Consulter [architecture.md](./architecture.md) pour les patterns existants
3. **Composants réutilisables** : Voir UI/DesignSystem et SharedViews
4. **Modèles de données** : Vérifier Data/Models pour extension
5. **Stores TCA** : S'inspirer des 19 stores existants

**Recommandations pour nouvelles features** :
- Suivre le pattern TCA existant
- Réutiliser les composants du Design System
- Étendre les modèles Domain existants
- Utiliser VehicleGRDBClient comme référence pour nouveaux clients
- Ajouter tests avec pattern BDD (Given-When-Then)

---

## 🎨 Design System

Le projet utilise un **Design System** complet :

### Tokens

- **ColorTokens** : Couleurs sémantiques avec Dark Mode
- **SpacingTokens** : Espacements standardisés (xs, sm, md, lg, xl)
- **RadiusTokens** : Rayons de coins (sm, md, lg)
- **TypographyTokens** : Styles de texte

### Composants

**Hiérarchie** : Primary, Secondary, Tertiary, Accent

**Types** :
- Buttons (avec états Default, Positive, Negative)
- Labels (même hiérarchie)
- Cards (StatCard, DocumentCard, DetailCard)
- Forms (FormField)
- Charts (MonthlyExpenseChart)
- Media (ThumbnailView, CameraView, DocumentScannerView)

---

## 💾 Architecture de Données

### Architecture Hybride GRDB + JSON

**3 Couches** :
1. **Record Layer** : VehicleRecord, FileMetadataRecord (SQLite)
2. **Domain Layer** : Vehicle, Document (Business Logic)
3. **DTO Layer** : VehicleDTO, FileMetadataDTO (JSON Export)

**Flux** :
```
User Action → Store → VehicleGRDBClient
    ↓
GRDB Insert/Update (Record)
    ↓
SyncManager.syncAfterChange() [debouncing 500ms]
    ↓
Export automatique vers .vehicle_metadata.json
```

**Avantages** :
- ✅ Performance (GRDB rapide)
- ✅ Portabilité (JSON pour backup)
- ✅ Reconstruction (BDD depuis JSON)

---

## 🧪 Tests

### Stratégie

**Pattern BDD (Given-When-Then)** strictement suivi :

```swift
func test_create_vehicleExistsInDatabase() async throws {
    // GIVEN
    let vehicle = Vehicle.make(brand: "Tesla")
    try await givenVehicleCreated(vehicle)

    // WHEN
    try await whenFetchingVehicle(id: vehicle.id)

    // THEN
    thenVehicleShouldExist(vehicle)
}
```

**Conventions** :
- Helpers : `givenX()`, `whenX()`, `thenX()`
- Base de données en mémoire (`:memory:`)
- Pas de `try!` dans le code de production

**Couverture** :
- ✅ Stores TCA (avec TestStore)
- ✅ Repositories
- ✅ Database (GRDB)
- ✅ Mappers
- ❌ Tests UI (non exécutés)

---

## 🔐 Sécurité et Confidentialité

### Données Locales

- **100% local** : Aucune donnée envoyée au cloud
- **App Sandbox** : Accès uniquement au dossier choisi par l'utilisateur
- **Pas de telemetry** : Firebase présent mais non utilisé
- **Portabilité** : Dossier entièrement transférable

### Permissions

- **Camera** : Scanner documents et cartes grises
- **Photos** : Importer depuis bibliothèque
- **User Selected File Access** : Lecture/écriture sur dossier choisi

---

## 🛠️ Développement avec Claude Code

### Utiliser ce Projet avec Claude Code

Ce projet est optimisé pour le développement AI-assisté :

1. **CLAUDE.md** contient toutes les instructions pour Claude
2. **MCP Servers** configurés :
   - Context7 (documentation officielle)
   - Swift MCP
   - SwiftUI MCP
   - Composable Architecture MCP
   - Swift Dependencies MCP
   - Swift Sharing MCP
   - Sharing-GRDB MCP

3. **Conventions strictes** :
   - Code en anglais
   - Réponses en français
   - Pas de `try!` dans l'app
   - Pattern BDD pour les tests
   - Dependencies pour injection

### Commandes Utiles

```bash
# Build
xcodebuild -project Holfy.xcodeproj -scheme Holfy build

# Tests
xcodebuild -project Holfy.xcodeproj -scheme Holfy test

# Déployer TestFlight
fastlane ios beta
```

---

## 📊 Statistiques du Projet

| Métrique | Valeur |
|----------|--------|
| Fichiers Swift | 105 |
| TCA Stores | 19 |
| Modèles de données | 13 (Domain + Records + DTOs) |
| Repositories/Clients/Services | 11 |
| Composants UI partagés | 15+ |
| Tokens Design System | 4 (Color, Spacing, Radius, Typography) |
| Tests unitaires | Stores, Repositories, Database |
| Dépendances SPM | 3 (TCA, SQLite Data, Supabase) |

---

## ℹ️ À Propos de cette Documentation

### Méthode de Génération

- **Workflow** : `document-project` (BMM)
- **Mode** : `initial_scan`
- **Niveau de scan** : `quick` (basé sur patterns)
- **Date** : 2026-01-11

### Limites du Quick Scan

Le Quick Scan identifie les fichiers et structures via les patterns, mais **ne lit pas le contenu des fichiers source**. Cela signifie :

- ✅ Structure du projet documentée
- ✅ Technologies identifiées
- ✅ Organisation des fichiers
- ❌ Détails d'implémentation non extraits
- ❌ Signatures de fonctions non listées
- ❌ Dépendances entre fichiers non analysées

### Pour Aller Plus Loin

Pour une documentation plus détaillée :

1. **Deep Scan** : Lit les fichiers dans les répertoires critiques
2. **Exhaustive Scan** : Lit TOUS les fichiers source
3. **Deep Dive** : Analyse exhaustive d'un dossier/module spécifique

Exécuter : `/bmad:bmm:workflows:document-project` et choisir le niveau de scan approprié.

---

## 📞 Ressources et Support

### Documentation Officielle

- [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [SQLite Data](https://github.com/pointfreeco/sqlite-data)
- [Fastlane](https://docs.fastlane.tools/)
- [Swift 6](https://docs.swift.org/swift-book/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Documentation Interne

Toute la documentation est dans `docs/` et à la racine du projet (`CLAUDE.md`, `setup_match.md`).

---

**Dernière mise à jour** : 2026-01-11
**Généré par** : BMM document-project workflow (Quick Scan)
**Pour** : Nicolas (user_skill_level: intermediate)
