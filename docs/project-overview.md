# Aperçu du Projet - Holfy

**Nom Commercial :** Filea
**Nom Technique :** Holfy
**Version :** 1.0 (Build 5)
**Plateforme :** iOS 18.5+
**Date de documentation :** 2026-01-11

## Résumé

**Holfy** (commercialisé sous le nom **Filea**) est une application iOS native de gestion de documents automobiles. Elle permet aux utilisateurs de :

- 📁 Gérer plusieurs véhicules (voitures, motos, camions, vélos, autres)
- 📄 Stocker et organiser des documents (carte grise, assurance, factures, entretien)
- 📊 Suivre les dépenses et visualiser des statistiques
- 💾 Conserver toutes les données localement avec backup JSON automatique
- 📸 Scanner la carte grise avec OCR pour extraction automatique des données

## Objectif

Offrir une solution **local-first** de gestion de documents automobiles, garantissant :
- **Confidentialité** : Aucune donnée n'est envoyée au cloud
- **Portabilité** : Dossier de stockage transférable
- **Performance** : Base de données locale rapide
- **Simplicité** : Interface intuitive SwiftUI

## Type de Projet

| Catégorie | Valeur |
|-----------|--------|
| **Type de repository** | Monolithe |
| **Architecture** | Application iOS |
| **Langage principal** | Swift 6 |
| **Framework UI** | SwiftUI |
| **Pattern d'architecture** | Composable Architecture (TCA) |
| **Base de données** | GRDB (SQLite Data) |
| **Nombre de parties** | 1 (monolith) |

## Stack Technologique

### Vue d'ensemble

```
┌─────────────────────────────────────┐
│         PRESENTATION                │
│    SwiftUI + TCA (19 Stores)        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│           DOMAIN                    │
│     Models (Vehicle, Document)      │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│            DATA                     │
│  GRDB + Repositories + Services     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       INFRASTRUCTURE                │
│    Storage + Sync + Dependencies    │
└─────────────────────────────────────┘
```

### Technologies Principales

| Technologie | Version | Rôle |
|-------------|---------|------|
| **Swift** | 6.0 | Langage de programmation |
| **SwiftUI** | iOS 18.5+ | Framework UI déclaratif |
| **TCA** | 1.22.2+ | State management unidirectionnel |
| **SQLite Data** | 1.4.3+ | Base de données locale |
| **Combine** | - | Programmation réactive |
| **Charts** | - | Visualisations statistiques |

### Dépendances SPM

1. **Composable Architecture** (`pointfreeco/swift-composable-architecture`)
2. **SQLite Data** (`pointfreeco/sqlite-data`) - Remplace sharing-grdb
3. **Supabase Swift** (`supabase/supabase-swift`) - Référencé mais non utilisé

## Structure du Projet

### Organisation Racine

```
Holfy/
├── Holfy/                  # Code source principal
│   ├── Data/               # Couche de données
│   ├── Stores/             # TCA Stores (19 stores)
│   ├── UI/                 # Design System
│   ├── SharedViews/        # Composants réutilisables
│   └── Shared/             # Utilitaires
├── HolfyTests/             # Tests unitaires
├── Holfy.xcodeproj/        # Projet Xcode
├── fastlane/               # CI/CD
├── CLAUDE.md               # Guide développement AI
└── docs/                   # Documentation générée
```

### Fichiers Source

- **105 fichiers Swift** dans le code source
- **19 TCA Stores** pour state management
- **13 modèles de données** (Domain + Records + DTOs)
- **11 repositories/clients/services**
- **15+ composants UI** réutilisables

## Fonctionnalités Principales

### Gestion Multi-Véhicules

- Support de 5 types : Voiture, Moto, Camion, Vélo, Autre
- Un véhicule peut être marqué comme **principal**
- Informations : Marque, Modèle, Immatriculation, Date d'achat, Kilométrage

### Documents

**5 Catégories** :
1. **Administratifs** : Carte grise, assurance, contrôle technique
2. **Entretien** : Vidange, révision, changement pièces
3. **Réparations** : Pannes, accidents
4. **Carburant** : Pleins d'essence
5. **Autres** : Documents personnalisés

**Import** :
- 📸 Caméra (scan direct)
- 🖼️ Bibliothèque photos
- 📁 Fichiers (PDF, images)

**Scan Carte Grise** :
- OCR automatique avec VisionKit
- Extraction : Marque, Modèle, Immatriculation, Date de mise en circulation

### Statistiques

- **Coût total** par véhicule
- **Dépenses mensuelles** avec graphiques
- **Alertes** : Contrôle technique, assurance à renouveler
- **Suivi kilométrage**

### Architecture Hybride GRDB + JSON

**Stratégie unique** :
- Base de données GRDB pour performance
- Export JSON automatique après chaque modification
- Un fichier `.vehicle_metadata.json` par véhicule
- Reconstruction complète de la BDD depuis JSON possible

**Avantages** :
- ✅ Performance locale
- ✅ Portabilité (copier/déplacer le dossier)
- ✅ Backup automatique
- ✅ Aucune dépendance cloud

## Configuration de Développement

### Prérequis

- **macOS** 15.0+
- **Xcode** 16.4
- **Swift** 6.0
- **iOS Simulator** 18.5+

### Commandes Rapides

```bash
# Ouvrir le projet
open Holfy.xcodeproj

# Build Debug
xcodebuild -project Holfy.xcodeproj -scheme Holfy -configuration Debug build

# Tests
xcodebuild -project Holfy.xcodeproj -scheme Holfy -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' test

# Déployer sur TestFlight
fastlane ios beta
```

### Configuration Requise

- **Bundle ID** : `com.nicolasbarb.filea`
- **Team ID** : À configurer dans Xcode
- **Deployment Target** : iOS 18.5+
- **Capabilities** : App Sandbox, User Selected File Access

## Architecture Highlights

### Pattern TCA

Flux unidirectionnel :
```
Vue → Action → Reducer → Effect → Nouveau State → Vue
```

### Couches

1. **Presentation** : Stores TCA + Views SwiftUI
2. **Domain** : Models métier (Vehicle, Document)
3. **Data** : Repositories + GRDB
4. **Infrastructure** : Services + Storage + Sync

### Design System

- **Tokens** : Colors, Spacing, Radius, Typography
- **Composants** : Buttons, Labels (variantes Primary, Secondary, Tertiary, Accent)
- **Shared Views** : Cards, Forms, Charts, Camera

## Déploiement

### Fastlane

**Actions** :
- `setup_match` : Configuration certificats
- `beta` : Upload TestFlight
- `build` : Build Release
- `screenshots` : Génération screenshots

### Certificats

- Gestion via **Match** (repository Git privé)
- Partage entre développeurs/CI

## Tests

### Stratégie

**Pattern BDD (Given-When-Then)** :
```swift
func test_create_vehicleExistsInDatabase() {
    // GIVEN
    let vehicle = Vehicle.make(...)

    // WHEN
    try await whenFetchingVehicle(id: vehicle.id)

    // THEN
    thenVehicleShouldExist(vehicle)
}
```

**Couverture** :
- ✅ Stores TCA
- ✅ Repositories
- ✅ Database
- ❌ Tests UI (non exécutés)

## Sécurité et Confidentialité

### Données Locales

- **100% local** : Aucune donnée envoyée au cloud
- **App Sandbox** : Accès uniquement au dossier choisi par l'utilisateur
- **Pas de telemetry** : Aucun tracking

### Permissions

- **Camera** : Scanner documents et carte grise
- **Photos** : Importer depuis bibliothèque

## Évolutions Potentielles

- ☁️ Sync cloud optionnel (Supabase déjà référencé)
- 📱 Widgets iOS
- 🔔 Rappels automatiques (contrôle technique, assurance)
- 📊 Export PDF des statistiques
- 👥 Partage de véhicules entre utilisateurs

## Documentation

### Générée

- `index.md` : Point d'entrée principal
- `architecture.md` : Documentation complète de l'architecture
- `source-tree-analysis.md` : Analyse de l'arbre des sources
- `development-guide.md` : Guide de développement
- `deployment-guide.md` : Guide de déploiement

### Existante

- `CLAUDE.md` : Guide complet pour Claude Code
- `setup_match.md` : Configuration certificats
- `fastlane/README.md` : Actions Fastlane

## Contacts et Support

### Documentation Technique

Pour toute question de développement :
1. Consulter `CLAUDE.md`
2. Lire `docs/architecture.md`
3. Vérifier `docs/development-guide.md`

### Ressources Externes

- [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [SQLite Data](https://github.com/pointfreeco/sqlite-data)
- [Apple Developer](https://developer.apple.com)
- [Fastlane](https://docs.fastlane.tools/)

---

**Note** : Cette documentation a été générée via un Quick Scan automatisé. Pour des détails d'implémentation, consulter le code source et `CLAUDE.md`.
