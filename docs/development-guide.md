# Guide de Développement - Holfy

**Projet :** Holfy (Filea)
**Version :** 1.0 (Build 5)
**Plateforme :** iOS 18.5+
**Date :** 2026-01-11

## Table des Matières

1. [Prérequis](#prérequis)
2. [Installation](#installation)
3. [Configuration de l'Environnement](#configuration-de-lenvironnement)
4. [Développement Local](#développement-local)
5. [Build](#build)
6. [Tests](#tests)
7. [Déploiement](#déploiement)
8. [Tâches Courantes](#tâches-courantes)

## Prérequis

### Logiciels Requis

- **macOS** : macOS 15.0+ (pour Xcode 16.4)
- **Xcode** : 16.4 ou ultérieur
- **Swift** : 6.0 (inclus avec Xcode 16.4)
- **iOS Simulator** : iOS 18.5+
- **Fastlane** : Pour le déploiement (optionnel)
  ```bash
  gem install fastlane
  ```
- **Git** : Pour la gestion de version

### Compte Développeur

- **Apple Developer Account** : Requis pour le déploiement sur appareil réel
  - Team ID : À configurer
  - Bundle ID : `com.nicolasbarb.filea`

## Installation

### 1. Cloner le Projet

```bash
git clone <repository-url>
cd Holfy
```

### 2. Ouvrir le Projet dans Xcode

```bash
open Holfy.xcodeproj
```

### 3. Résolution des Dépendances

Les dépendances Swift Package Manager sont automatiquement résolues à l'ouverture du projet :

- **Composable Architecture** (1.22.2+)
- **SQLite Data** (1.4.3+)
- **Supabase Swift** (2.5.1+) - non utilisé actuellement

Si nécessaire, forcer la résolution :
- Dans Xcode : `File → Packages → Resolve Package Versions`

## Configuration de l'Environnement

### Configuration Xcode

1. **Sélectionner l'équipe de développement** :
   - Ouvrir `Holfy.xcodeproj`
   - Sélectionner le target `Holfy`
   - Onglet `Signing & Capabilities`
   - Choisir votre équipe de développement

2. **Bundle Identifier** :
   - Vérifier que le Bundle ID est : `com.nicolasbarb.filea`

3. **Deployment Target** :
   - iOS : 18.5+

### Entitlements

Le projet utilise les capabilities suivantes (configurées dans `Holfy.entitlements`) :

- **App Sandbox** : Activé
- **User Selected File (Read/Write)** : Activé
  - Permet l'accès aux fichiers sélectionnés par l'utilisateur

### Configuration Firebase (Optionnel)

Le fichier `GoogleService-Info.plist` est présent mais Firebase n'est pas utilisé actuellement. Configuration pour usage futur si nécessaire.

## Développement Local

### Lancer l'Application

#### Via Xcode (Recommandé)

1. Sélectionner le scheme `Holfy`
2. Choisir un simulateur iOS 18.5+ (ex: iPhone 15)
3. Cliquer sur `Run` (⌘R) ou le bouton Play

#### Via Ligne de Commande

```bash
# Lancer sur simulateur
xcodebuild -project Holfy.xcodeproj \
  -scheme Holfy \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  clean build
```

### Structure de Développement

Le projet suit l'architecture **Composable Architecture (TCA)** :

```
État → Action → Reducer → Effet → Nouvel État
```

**Workflow typique** :
1. Définir le `State` dans un Store
2. Créer les `Actions` possibles
3. Implémenter la logique dans le `Reducer`
4. Gérer les effets asynchrones (DB, API)
5. Créer la Vue SwiftUI qui observe le Store

### Hot Reload

SwiftUI supporte le **hot reload** :
- Les modifications de vue sont visibles immédiatement
- Utiliser `⌘⌥P` pour rafraîchir le Canvas Xcode

## Build

### Build de Développement

```bash
# Build Debug
xcodebuild -project Holfy.xcodeproj \
  -scheme Holfy \
  -configuration Debug \
  build
```

### Build de Release

```bash
# Build Release
xcodebuild -project Holfy.xcodeproj \
  -scheme Holfy \
  -configuration Release \
  build
```

### Clean Build

```bash
# Nettoyer le dossier build
xcodebuild -project Holfy.xcodeproj \
  -scheme Holfy \
  clean
```

Ou dans Xcode : `Product → Clean Build Folder` (⇧⌘K)

## Tests

### Tests Unitaires

Le projet suit le pattern **BDD (Given-When-Then)** avec des conventions strictes :

```swift
func test_create_vehicleExistsInDatabase() async throws {
    // GIVEN
    let vehicle = Vehicle.make(brand: "Tesla", model: "Model 3")
    try await givenVehicleCreated(vehicle)

    // WHEN
    try await whenFetchingVehicle(id: vehicle.id)

    // THEN
    thenVehicleShouldExist(vehicle)
}
```

#### Lancer les Tests

**Via Xcode** :
- `Product → Test` (⌘U)
- Ou cliquer sur le losange à côté d'un test

**Via Ligne de Commande** :

```bash
# Tous les tests
xcodebuild -project Holfy.xcodeproj \
  -scheme Holfy \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  test

# Tests spécifiques
xcodebuild -project Holfy.xcodeproj \
  -scheme Holfy \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -only-testing:HolfyTests/VehicleDatabaseRepository_Spec \
  test
```

### Conventions de Tests

- **Nommage** : `test_Action_ce_que_je_vais_vérifier()`
- **Helpers** :
  - `givenX()` : Setup/Configuration
  - `whenX()` : Exécution de l'action
  - `thenX()` : Assertions
- **Base de données** : Toujours utiliser `:memory:` pour les tests
- **Pas de `try!`** : Utiliser `do-catch` ou propagation

Voir `CLAUDE.md` pour les conventions complètes.

### Tests UI

⚠️ **Les tests UI ne doivent PAS être exécutés** (marqués comme tels dans le projet).

## Déploiement

### Fastlane

Le projet utilise **Fastlane** pour automatiser le déploiement.

#### Configuration Initiale

1. Installer Fastlane :
   ```bash
   gem install fastlane
   ```

2. Configurer Match (gestion des certificats) :
   - Voir `setup_match.md` pour les instructions détaillées
   - Créer un repository privé pour les certificats
   - Configurer le `Matchfile` avec votre Team ID

#### Actions Disponibles

```bash
# Setup certificats (première fois)
fastlane ios setup_match

# Regénérer les certificats
fastlane ios regenerate_certificates

# Build pour release
fastlane ios build

# Déployer sur TestFlight
fastlane ios beta

# Générer screenshots
fastlane ios screenshots
```

### TestFlight

```bash
# Déployer une nouvelle version beta
fastlane ios beta
```

Cette action :
1. Incrémente le build number
2. Build l'app en Release
3. Upload sur TestFlight
4. Met à jour les metadatas

### App Store

Le processus App Store est géré via **Fastlane** et **App Store Connect**.

Configuration requise :
- App créée dans App Store Connect
- Métadonnées remplies
- Screenshots ajoutés
- Version ready for review

## Tâches Courantes

### Ajouter une Nouvelle Fonctionnalité

1. **Créer le Store TCA** :
   ```swift
   // Stores/NewFeatureStore/NewFeatureStore.swift
   @Reducer
   struct NewFeatureStore {
       @ObservableState
       struct State { ... }

       enum Action { ... }

       var body: some ReducerOf<Self> { ... }
   }
   ```

2. **Créer la Vue** :
   ```swift
   struct NewFeatureView: View {
       @Bindable var store: StoreOf<NewFeatureStore>

       var body: some View { ... }
   }
   ```

3. **Intégrer dans la Navigation** :
   - Ajouter dans `AppStore` si nouvelle route
   - Ou dans un Store parent existant

4. **Ajouter les Tests** :
   ```swift
   final class NewFeatureStore_Spec: XCTestCase {
       func test_action_expectedBehavior() async throws { ... }
   }
   ```

### Modifier un Modèle de Données

1. **Mettre à jour le Record** :
   ```swift
   // Data/Database/Records/EntityRecord.swift
   @Table struct EntityRecord { ... }
   ```

2. **Créer une Migration** :
   ```swift
   // Data/Database/DatabaseMigrator.swift
   migrator.registerMigration("v2") { db in
       try db.alter(table: "entity") { t in
           t.add(column: "newColumn", .text)
       }
   }
   ```

3. **Mettre à jour le Mapper** :
   ```swift
   // Data/Database/Mappers/EntityMappers.swift
   extension EntityRecord {
       func toDomain() -> Entity { ... }
   }
   ```

4. **Mettre à jour le DTO** (si export JSON) :
   ```swift
   // Data/Database/DTOs/EntityDTO.swift
   struct EntityDTO: Codable { ... }
   ```

### Debug

#### Logs GRDB

Les opérations GRDB sont loggées avec emojis :
- 🚀 Initialisation
- ➕ Création
- 📖 Lecture
- ✏️ Mise à jour
- 🗑️ Suppression
- 💾 Synchronisation
- ✅ Succès
- ❌ Erreur

#### Breakpoints

Utiliser les breakpoints Xcode sur :
- Les reducers TCA pour suivre les actions
- Les repositories pour voir les opérations DB
- Les mappers pour vérifier les conversions

#### Instruments

Pour profiler l'app :
- `Product → Profile` (⌘I)
- Choisir `Time Profiler` ou `Leaks`

### Conventions de Code

Voir `CLAUDE.md` pour :
- Conventions Swift 6
- Pattern TCA
- Pattern Repository
- Gestion des erreurs
- Logging
- Tests

## Ressources

### Documentation Interne

- `CLAUDE.md` : Guide complet du projet
- `setup_match.md` : Configuration certificats
- `fastlane/README.md` : Actions Fastlane
- `docs/source-tree-analysis.md` : Structure du projet
- `docs/architecture.md` : Documentation architecture

### Documentation Externe

- [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [SQLite Data](https://github.com/pointfreeco/sqlite-data)
- [Fastlane](https://docs.fastlane.tools/)
- [Swift 6 Documentation](https://docs.swift.org/swift-book/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

## Support

Pour toute question sur le développement :
1. Consulter `CLAUDE.md`
2. Vérifier la documentation générée dans `docs/`
3. Lire les commentaires dans le code
4. Utiliser Claude Code avec les instructions du projet

---

**Note** : Ce guide a été généré automatiquement. Pour des informations plus détaillées, consultez `CLAUDE.md` et la documentation dans `docs/`.
