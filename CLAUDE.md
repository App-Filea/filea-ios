# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Règles Spécifiques au Projet

- **Toujours répondre en français** - Toutes les interactions doivent être en français
- **Le code est toujours en anglais** - Variables, fonctions, classes et commentaires de code en anglais
- **Utiliser les MCP Swift, SwiftUI, Composable Architecture, Sharing-GRDB** - Privilégier ces frameworks et architectures
- **Le code doit être en Swift 6** - Utiliser les dernières fonctionnalités et syntaxe de Swift 6
- **⚠️ JAMAIS de `try!` dans l'app en dehors des tests** - Toujours gérer les erreurs proprement avec `do-catch` ou propagation

## Configuration MCP (Model Context Protocol)

### Serveurs MCP Disponibles
Les serveurs MCP suivants sont configurés et doivent être utilisés systématiquement :
- **Context7** : Documentation officielle à jour pour toutes les bibliothèques
- **Swift MCP** : Documentation Swift 6
- **SwiftUI MCP** : Composants et APIs SwiftUI
- **Composable Architecture MCP** : Patterns TCA
- **Sharing-GRDB MCP** : Persistence et base de données

### Règle d'Utilisation Obligatoire
**TOUJOURS utiliser Context7 et les MCP appropriés** pour toute tâche impliquant :
- Implémentation de fonctionnalités avec SwiftUI
- Utilisation de Composable Architecture
- Intégration de GRDB
- Questions sur les APIs Swift 6
- Génération de code avec des dépendances externes
- **Design et interface utilisateur** : Utiliser Context7 pour consulter les Apple Human Interface Guidelines

### Workflow Recommandé
Avant d'implémenter une fonctionnalité :
1. Utiliser Context7 pour récupérer la documentation officielle à jour
2. Vérifier la version spécifique des frameworks utilisés dans le projet
3. S'assurer que le code généré respecte Swift 6 et les conventions du projet
4. Ne jamais se baser uniquement sur la connaissance interne sans vérifier via MCP
5. **Pour le design** : Consulter systématiquement les Apple Human Interface Guidelines via Context7

### Exemples d'Utilisation
- Pour SwiftUI : "use context7 implémente une vue de liste avec navigation"
- Pour TCA : "use context7 crée un reducer pour la gestion de formulaire"
- Pour le Design : "use context7 consulte les HIG pour les spacing et padding recommandés"

## Conventions de Design

### Apple Human Interface Guidelines (HIG)
**OBLIGATOIRE** : Utiliser Context7 pour consulter les Apple Human Interface Guidelines avant toute tâche de design.

**Quand consulter les HIG via Context7 :**
- Création ou modification d'interfaces utilisateur
- Choix de composants SwiftUI (Button, List, Card, etc.)
- Définition des espacements, paddings, et marges
- Sélection des couleurs, typographie, et icônes
- Implémentation de patterns d'interaction (navigation, gestures, etc.)
- Accessibilité et adaptativité (Dark Mode, Dynamic Type, etc.)

**Commande recommandée :**
```
use context7 /apple/human-interface-guidelines consulte [topic]
```

**Exemples :**
- Espacements : "use context7 /apple/human-interface-guidelines spacing standards"
- Navigation : "use context7 /apple/human-interface-guidelines navigation patterns"
- Couleurs : "use context7 /apple/human-interface-guidelines color system"

## Aperçu du Projet

**Filea** (nom commercial) / **Invoicer** (nom technique) est une application iOS de gestion de documents automobiles construite avec SwiftUI et Xcode 16.4.

### Fonctionnalités Principales
- 📁 **Gestion multi-véhicules** : Voitures, motos, camions, vélos et autres
- 📄 **Suivi de documents** : Administratifs (carte grise, assurance, contrôle technique), Entretien (vidange, révision), Réparations (pannes, accidents), Carburant et autres dépenses
- 📊 **Statistiques et graphiques** : Coûts totaux, dépenses mensuelles, graphiques par catégorie
- 💾 **Architecture hybride GRDB + JSON** : Base de données locale performante avec backup JSON portable
- 🎨 **Design System personnalisé** : Tokens de couleurs, typographie, spacing, radius avec composants réutilisables
- 📸 **Import de documents** : Caméra, bibliothèque photos, fichiers PDF

### Plateformes Supportées
- iOS 18.5+
- macOS 15.4+ (support partiel)
- ❌ visionOS désactivé

## Commandes de Build
```bash
# Build de l'app 
xcodebuild -project Invoicer.xcodeproj -scheme Invoicer -configuration Debug build

# Build pour release 
xcodebuild -project Invoicer.xcodeproj -scheme Invoicer -configuration Release build

# Clean build 
xcodebuild -project Invoicer.xcodeproj -scheme Invoicer clean

# Tests unitaires 
xcodebuild -project Invoicer.xcodeproj -scheme Invoicer -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' test

# Tests UI (NE PAS EXÉCUTER)
xcodebuild -project Invoicer.xcodeproj -scheme Invoicer -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' -only-testing:InvoicerUITests test
```

## Structure du Projet

```
Invoicer/
├── Data/                                  # 💾 Couche de données
│   ├── Database/                          # Base de données GRDB
│   │   ├── Records/                       # Tables SQLite avec @Table macro
│   │   │   ├── VehicleRecord.swift
│   │   │   └── FileMetadataRecord.swift
│   │   ├── DTOs/                          # Transfer Objects pour JSON
│   │   │   ├── VehicleDTO.swift
│   │   │   ├── FileMetadataDTO.swift
│   │   │   └── VehicleMetadataFile.swift
│   │   ├── Mappers/                       # Conversions Record ↔ Domain ↔ DTO
│   │   │   ├── VehicleMappers.swift
│   │   │   └── FileMetadataMappers.swift
│   │   ├── DatabaseManager.swift          # Gestionnaire principal GRDB
│   │   ├── DatabaseMigrator.swift         # Migrations SQL
│   │   └── VehicleMetadataSyncManager.swift # Sync GRDB ↔ JSON
│   ├── Models/                            # 🎯 Modèles métier (Domain)
│   │   ├── Vehicle.swift
│   │   ├── Document.swift
│   │   └── VehicleStatistics.swift
│   ├── Repositories/                      # 📦 Repositories (CRUD)
│   │   ├── VehicleRepository.swift        # Ancien système (fichiers)
│   │   ├── VehicleDatabaseRepository.swift # Nouveau système (GRDB)
│   │   ├── DocumentRepository.swift
│   │   ├── StatisticsRepository.swift
│   │   └── RepositoryDependencies.swift
│   ├── Services/                          # 🔧 Services métier
│   │   ├── FileStorageService.swift
│   │   └── VehicleCostCalculator.swift
│   └── Storage/                           # 📁 Gestion du système de fichiers
│       ├── VehicleStorageManager.swift
│       └── StorageError.swift
│
├── Stores/                                # 🏪 Composable Architecture Stores
│   ├── AppStore/                          # Store principal de navigation
│   │   └── AppStore.swift
│   ├── MainStore/                         # Dashboard principal
│   │   ├── MainStore.swift
│   │   └── MainView.swift
│   ├── VehiclesListStore/                 # Liste des véhicules
│   ├── VehicleDetailsStore/               # Détails d'un véhicule
│   ├── AddVehicleStore/                   # Ajout de véhicule
│   ├── EditVehicleStore/                  # Édition de véhicule
│   ├── AddDocumentStore/                  # Ajout de document
│   ├── EditDocumentStore/                 # Édition de document
│   ├── DocumentDetailStore/               # Détail d'un document
│   ├── SettingsStore/                     # Paramètres
│   └── StorageOnboardingStore/            # Onboarding choix dossier
│
├── UI/                                    # 🎨 Interface utilisateur
│   ├── DesignSystem/                      # Design System
│   │   ├── Tokens/                        # Design Tokens
│   │   │   ├── ColorTokens.swift
│   │   │   ├── SpacingTokens.swift
│   │   │   ├── TypographyTokens.swift
│   │   │   └── RadiusTokens.swift
│   │   ├── Buttons/                       # Styles de boutons
│   │   │   ├── Primary/
│   │   │   ├── Secondary/
│   │   │   ├── Tertiary/
│   │   │   └── Accent/
│   │   ├── Labels/                        # Styles de labels
│   │   │   ├── Primary/
│   │   │   ├── Secondary/
│   │   │   ├── Tertiary/
│   │   │   └── Accent/
│   │   └── Spacing.swift
│   └── Components/                        # Composants réutilisables
│       ├── DashboardView.swift
│       ├── DatePickerSheet.swift
│       └── TextFieldStyle.swift
│
├── SharedViews/                           # 🔄 Vues partagées
│   ├── Forms/
│   │   ├── FormTextField.swift
│   │   ├── FormDatePicker.swift
│   │   └── FormPicker.swift
│   ├── Cards/
│   │   ├── VehicleCard.swift
│   │   ├── DocumentCard.swift
│   │   └── StatCard.swift
│   ├── Charts/
│   │   └── MonthlyExpenseChart.swift
│   ├── Media/
│   │   ├── ThumbnailView.swift
│   │   └── MediaPickerView.swift
│   └── CameraView.swift
│
├── Shared/                                # 🛠️ Utilitaires
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── String+Extensions.swift
│   │   ├── View+Extensions.swift
│   │   ├── Color+Extensions.swift
│   │   └── Double+Extensions.swift
│   ├── Utilities/
│   │   ├── CurrencyFormatter.swift
│   │   ├── DocumentTypeMapper.swift
│   │   └── ThumbnailGenerator.swift
│   ├── Constants/
│   │   └── AppConstants.swift
│   └── SharedKeys.swift
│
├── InvoicerApp.swift                      # 🚀 Point d'entrée
├── Assets.xcassets/                       # 🎨 Assets
└── Invoicer.entitlements                  # 🔐 Droits sandbox

InvoicerTests/                             # ✅ Tests unitaires
InvoicerUITests/                           # 🎭 Tests UI

Documentation/
├── ARCHITECTURE_HYBRIDE_GRDB.md           # Architecture complète
├── QUICKSTART_GRDB.md                     # Guide de démarrage
└── FICHIERS_CREES.md                      # Liste des fichiers
```

## Configuration de Développement

- **Version Swift**: 6.0
- **Targets de Déploiement**: iOS 18.5+, macOS 15.4+
- **Bundle Identifier**: `com.nicolasbarb.filea`
- **Nom Commercial**: Filea
- **Version**: 1.0 (Build 3)
- **Équipe de Développement**: GFYJNR5373 (iOS), 5DDBZ7D32L (macOS)
- **App Sandbox**: Activé avec accès en lecture/écriture aux fichiers sélectionnés par l'utilisateur
- **Catalyst**: Désactivé (SUPPORTS_MACCATALYST = NO)
- **Permissions**: Caméra (NSCameraUsageDescription)

## Notes d'Architecture

### Pattern Principal : **Composable Architecture (TCA)**
- Architecture unidirectionnelle avec States, Actions, Reducers
- Gestion centralisée de l'état avec `@Shared` pour le state partagé
- Navigation par `NavigationStack` avec `Path` reducer
- Tests facilitéspar l'isolation des effets

### Architecture de Données : **Hybride GRDB + JSON**

#### Les 3 Couches de Données
1. **Record Layer** (Persistence) - Base de données SQLite via Sharing-GRDB
   - `VehicleRecord` et `FileMetadataRecord` avec macro `@Table`
   - Types primitifs optimisés pour SQL
   - Relations via foreign keys (pas de `hasMany`/`belongsTo` dans Sharing-GRDB)

2. **Domain Layer** (Business Logic) - Modèles métier
   - `Vehicle` et `Document` avec logique métier
   - Enums riches (`VehicleType`, `DocumentType`)
   - Computed properties et méthodes métier
   - Utilisés dans SwiftUI et TCA

3. **DTO Layer** (Transfer Objects) - Export/Import JSON
   - `VehicleDTO`, `FileMetadataDTO`, `VehicleMetadataFile`
   - Structures `Codable` plates
   - Fichiers `.vehicle_metadata.json` dans chaque dossier véhicule
   - Versionnés pour migrations futures

#### Flux de Synchronisation
```
User Action → Domain Model → Repository
     ↓
  GRDB Insert/Update (Record)
     ↓
  SyncManager.syncAfterChange()
     ↓
  Export automatique vers .vehicle_metadata.json
```

#### Stratégie Local-First
- ✅ Toutes les données stockées localement (GRDB + JSON)
- ✅ Pas de dépendance cloud (Supabase présent mais non utilisé)
- ✅ Portabilité via fichiers JSON dans chaque dossier
- ✅ Reconstruction complète de la BDD depuis les JSON
- ✅ Backup automatique via iCloud Drive / Dropbox du dossier racine

### Design System
- **Design Tokens** : ColorTokens, SpacingTokens, TypographyTokens, RadiusTokens
- **Composants** : Buttons (Primary, Secondary, Tertiary, Accent), Labels (mêmes variantes)
- **Hierarchie** : Chaque variante avec états Default, Positive, Negative

### Dependencies Framework
- Point-Free's Dependencies pour l'injection de dépendances
- `@Dependency(\.vehicleRepository)`, `@Dependency(\.database)`, etc.
- `DependencyKey` pour la configuration centralisée

## Dépendances et Frameworks

### Dépendances Swift Package Manager

1. **Composable Architecture** (`pointfreeco/swift-composable-architecture`)
   - Version : 1.22.2+
   - Usage : Architecture unidirectionnelle, state management, navigation
   - Documentation : https://github.com/pointfreeco/swift-composable-architecture

2. **Sharing-GRDB** (`pointfreeco/sharing-grdb`)
   - Version : 0.7.0+
   - Usage : Base de données locale SQLite avec réactivité SwiftUI
   - Utilise GRDB.swift sous le capot
   - Macro `@Table` pour définir les tables
   - StructuredQueries pour les requêtes type-safe
   - Documentation : https://github.com/pointfreeco/sharing-grdb

3. **Supabase Swift** (`supabase/supabase-swift`)
   - Version : 2.5.1+
   - **Statut** : Référencé mais non utilisé actuellement
   - **Raison** : Architecture local-first privilégiée
   - Potentiel usage futur : sync cloud optionnel
   - Documentation : https://supabase.com/docs/reference/swift/auth-api

### Frameworks Apple
- **SwiftUI** : Interface utilisateur déclarative
- **Combine** : Utilisé par TCA pour les effets asynchrones
- **Foundation** : Utilitaires de base
- **UIKit** : Interop pour caméra et pickers (via UIViewControllerRepresentable)
- **PhotosUI** : Sélection d'images
- **PDFKit** : Affichage de PDF
- **Charts** : Graphiques de dépenses mensuelles

## Conventions de Code

### Syntaxe Sharing-GRDB (OBLIGATOIRE)

**⚠️ NE PAS utiliser la syntaxe GRDB standard !** Sharing-GRDB utilise une syntaxe différente.

#### ✅ Syntaxe Correcte (Sharing-GRDB)

```swift
// INSERTION
try VehicleRecord.insert { record }.execute(db)

// MISE À JOUR (Upsert)
try VehicleRecord.upsert { record }.execute(db)

// FETCH ALL
let records = try VehicleRecord.all.fetchAll(db)

// FETCH ONE avec filtre
let record = try VehicleRecord.where { $0.id.in([vehicleId]) }.fetchOne(db)

// FETCH avec KeyPath
let primary = try VehicleRecord.where(\.isPrimary).fetchOne(db)

// ORDERING
let sorted = try VehicleRecord.all.order { $0.brand.asc() }.fetchAll(db)

// DELETE
try VehicleRecord.where { $0.id.in([id]) }.delete().execute(db)

// COUNT
let count = try VehicleRecord.all.fetchCount(db)
```

#### ❌ Syntaxe Incorrecte (GRDB standard - NE PAS UTILISER)

```swift
// ❌ Ne fonctionne PAS
try record.insert(db)           // Utiliser .insert { }.execute()
try record.save(db)             // Utiliser .upsert { }.execute()
record.hasMany(FileRecord.self) // Pas de hasMany/belongsTo dans Sharing-GRDB
```

### Conventions de Logging

**Utiliser des emojis pour identifier rapidement le type d'événement :**

- 🚀 **Initialisation** : Démarrage de composants
- ➕ **Création** : Ajout de données
- 📖 **Lecture** : Récupération de données
- ✏️ **Mise à jour** : Modification de données
- 🗑️ **Suppression** : Deletion de données
- 💾 **Synchronisation** : Export/Import JSON
- 📁 **Système de fichiers** : Opérations sur fichiers
- ✅ **Succès** : Opération réussie
- ❌ **Erreur** : Échec d'opération
- ⚠️ **Attention** : Avertissement

**Format standard :**
```swift
print("🚀 [ComponentName] Action description")
print("   ├─ Détail 1")
print("   ├─ Détail 2")
print("   └─ Détail 3")
print("✅ [ComponentName] Operation succeeded\n")
```

**Exemple :**
```swift
func create(vehicle: Vehicle) async throws {
    print("➕ [VehicleRepository] Création d'un véhicule")
    print("   ├─ ID : \(vehicle.id)")
    print("   ├─ Véhicule : \(vehicle.brand) \(vehicle.model)")
    print("   └─ Dossier : \(folderPath)")

    // ... opérations ...

    print("✅ [VehicleRepository] Véhicule créé en BDD")
    print("💾 [VehicleRepository] JSON synchronisé\n")
}
```

### Gestion des Erreurs

**JAMAIS de `try!` en dehors des tests.** Toujours utiliser `do-catch` ou propagation :

```swift
// ✅ Correct
static let liveValue: DatabaseManager = {
    do {
        return try DatabaseManager()
    } catch {
        fatalError("❌ [DatabaseManager] Init failed: \(error.localizedDescription)")
    }
}()

// ❌ Incorrect
static let liveValue: DatabaseManager = try! DatabaseManager()
```

### Configuration GRDB - PRAGMA

**⚠️ Important** : Les PRAGMAs SQLite ne peuvent pas être exécutés dans une transaction.

```swift
// ✅ Correct - Configuration avant création de DatabaseQueue
var configuration = Configuration()
configuration.prepareDatabase { db in
    try db.execute(sql: "PRAGMA foreign_keys = ON")
    try db.execute(sql: "PRAGMA journal_mode = WAL")
    try db.execute(sql: "PRAGMA synchronous = NORMAL")
}
let dbQueue = try DatabaseQueue(path: databasePath, configuration: configuration)

// ❌ Incorrect - Dans une transaction
try dbQueue.write { db in
    try db.execute(sql: "PRAGMA synchronous = NORMAL") // CRASH
}
```

## Conventions de Tests Unitaires

### Règles Générales

**⚠️ OBLIGATOIRE** : Tous les tests doivent suivre strictement ces conventions pour garantir la cohérence et la maintenabilité du projet.

### 1. Convention de Nommage des Tests

**Pattern obligatoire** : `test_Action_ce_que_je_vais_vérifier()`

**Structure** :
- `test_` : Préfixe obligatoire pour XCTest
- `Action` : L'action ou la méthode testée (ex: `create`, `update`, `delete`, `fetch`)
- `ce_que_je_vais_vérifier` : Description claire de ce qui est vérifié (en camelCase)

**Exemples** :
```swift
✅ func test_create_vehicleExistsInDatabase() async throws
✅ func test_create_allPropertiesAreCorrectlySaved() async throws
✅ func test_update_vehicleIsModified() async throws
✅ func test_delete_vehicleIsRemoved() async throws
✅ func test_fetch_vehicleWithDocumentsIsRetrieved() async throws

❌ func test_create_savesVehicle() // Trop vague
❌ func testCreateVehicle() // Pas de description de vérification
❌ func test_vehicleCreation() // Action pas claire
```

### 2. Pattern Given-When-Then

**Tous les tests doivent suivre le pattern BDD (Behavior Driven Development)** :

```swift
func test_create_vehicleExistsInDatabase() async throws {
    // Setup des données de test
    let vehicle = Vehicle.make(brand: "Tesla", model: "Model 3")

    // Exécution de l'action à tester
    try await givenVehicleCreated(vehicle)
    try await whenFetchingVehicle(id: vehicle.id)

    // Vérifications des résultats
    thenVehicleShouldExist(vehicle)
}
```

### 3. Nommage des Helpers

**Convention stricte pour les noms de helpers** :

#### Helpers `given` (Setup/Configuration)
- Préfixe : `given`
- Format : `givenXXXCreated()`, `givenXXXConfigured()`
- Responsabilité : Créer et configurer les données de test
- **Ne retournent RIEN** (utilisent `async throws` si nécessaire)

```swift
private func givenVehicleCreated(
    _ vehicle: Vehicle,
    at folderPath: String? = nil
) async throws {
    let path = folderPath ?? "/test/vehicles/\(vehicle.id.uuidString)"
    try await repository.create(vehicle: vehicle, folderPath: path)
}
```

#### Helpers `when` (Actions)
- Préfixe : `when`
- Format : `whenFetchingXXX()`, `whenCreatingXXX()`, `whenUpdatingXXX()`
- Responsabilité : Exécuter l'action et **stocker le résultat dans une variable globale**
- **Ne retournent RIEN** - Peuplent les variables de la classe

```swift
private func whenFetchingVehicle(id: UUID) async throws {
    fetchedVehicle = try await repository.fetch(id: id)
}

private func whenFetchingAllVehicles() async throws {
    fetchedVehicles = try await repository.fetchAll()
}
```

#### Helpers `then` (Assertions)
- Préfixe : `then`
- Format : `thenXXXShouldBe()`, `thenXXXShouldExist()`, `thenXXXShouldMatch()`
- Responsabilité : Vérifier les résultats **en utilisant les variables globales**
- **Ne retournent RIEN** - Exécutent des assertions XCTest
- Prennent uniquement les valeurs attendues en paramètres

```swift
private func thenVehicleShouldExist(_ expected: Vehicle) {
    XCTAssertNotNil(fetchedVehicle, "Vehicle should exist in database")
    XCTAssertEqual(fetchedVehicle?.id, expected.id, "Vehicle ID should match")
}

private func thenVehicleTypeShouldBe(_ expected: VehicleType) {
    XCTAssertEqual(fetchedVehicle?.type, expected, "Should save \(expected) type")
}

private func thenVehicleMileageShouldBeNil() {
    XCTAssertNil(fetchedVehicle?.mileage, "Should save nil mileage when not provided")
}
```

### 4. Variables Globales pour Résultats

**Déclarer des variables d'instance privées** pour stocker les résultats des actions :

```swift
final class VehicleDatabaseRepository_Spec: XCTestCase {

    // Variables placées EN BAS de la classe, après tous les helpers
    private var testDatabase: DatabaseManager!
    private var repository: VehicleDatabaseRepository!
    private var fetchedVehicle: Vehicle?
    private var fetchedVehicles: [Vehicle] = []
}
```

**Reset obligatoire** dans `setUp()` et `tearDown()` :

```swift
override func setUp() async throws {
    try await super.setUp()
    testDatabase = try DatabaseManager(databasePath: ":memory:")
    repository = VehicleDatabaseRepository(database: testDatabase)
    fetchedVehicle = nil
    fetchedVehicles = []
}

override func tearDown() async throws {
    testDatabase = nil
    repository = nil
    fetchedVehicle = nil
    fetchedVehicles = []
    try await super.tearDown()
}
```

### 5. Extensions pour Fixtures (Test Data Builders)

**Créer des extensions dans `InvoicerTests/Extensions/`** pour faciliter la création de données de test :

```swift
// InvoicerTests/Extensions/Vehicle+Testing.swift
import Foundation
@testable import Invoicer

extension Vehicle {
    static func make(
        id: UUID = UUID(),
        type: VehicleType = .car,
        brand: String = "Tesla",
        model: String = "Model 3",
        mileage: String? = "50000",
        registrationDate: Date = Date(),
        plate: String = "TEST-\(UUID().uuidString.prefix(3))",
        isPrimary: Bool = false,
        documents: [Document] = []
    ) -> Vehicle {
        Vehicle(
            id: id,
            type: type,
            brand: brand,
            model: model,
            mileage: mileage,
            registrationDate: registrationDate,
            plate: plate,
            isPrimary: isPrimary,
            documents: documents
        )
    }
}
```

**Avantages** :
- Tous les paramètres optionnels avec valeurs par défaut
- Plaques uniques générées automatiquement
- Utilisation concise : `Vehicle.make(brand: "BMW")`

### 6. Base de Données en Mémoire pour Tests

**TOUJOURS utiliser `:memory:` pour les tests GRDB** :

```swift
testDatabase = try DatabaseManager(databasePath: ":memory:")
```

**Avantages** :
- ✅ Ultra-rapide (pas d'I/O disque)
- ✅ Isolation complète entre tests
- ✅ Pas de nettoyage manuel nécessaire
- ✅ Détruite automatiquement à la fin du test

### 7. Structure d'un Fichier de Test

**Organisation obligatoire** :

```swift
import XCTest
@testable import Invoicer

final class RepositoryName_Spec: XCTestCase {

    // 1. Setup & Teardown
    override func setUp() async throws { ... }
    override func tearDown() async throws { ... }

    // 2. Tests (groupés par action)
    func test_create_vehicleExistsInDatabase() async throws { ... }
    func test_create_allPropertiesAreCorrectlySaved() async throws { ... }

    func test_update_vehicleIsModified() async throws { ... }

    func test_delete_vehicleIsRemoved() async throws { ... }

    // 3. Helpers Given
    private func givenVehicleCreated(...) async throws { ... }

    // 4. Helpers When
    private func whenFetchingVehicle(...) async throws { ... }

    // 5. Helpers Then
    private func thenVehicleShouldExist(...) { ... }

    // 6. Variables d'instance (EN BAS)
    private var testDatabase: DatabaseManager!
    private var repository: RepositoryName!
    private var fetchedVehicle: Vehicle?
    private var fetchedVehicles: [Vehicle] = []
}
```

### 8. Règles de Style

**❌ PAS de commentaires** dans les tests - le code doit être auto-documenté :
```swift
❌ // Given - Create a vehicle
❌ // When - Fetch the vehicle
❌ // Then - Check it exists

✅ Le nom des fonctions et variables doit suffire
```

**✅ Code concis et lisible** :
```swift
✅ func test_create_vehicleExistsInDatabase() async throws {
    let vehicle = Vehicle.make(brand: "Tesla")
    try await givenVehicleCreated(vehicle)
    try await whenFetchingVehicle(id: vehicle.id)
    thenVehicleShouldExist(vehicle)
}
```

### 9. Messages d'Assertion

**Toujours fournir des messages descriptifs** dans les assertions :

```swift
✅ XCTAssertNotNil(fetchedVehicle, "Vehicle should exist in database")
✅ XCTAssertEqual(fetchedVehicle?.brand, "Tesla", "Brand should match")
✅ XCTAssertEqual(all.count, 3, "Should have 3 vehicles saved")

❌ XCTAssertNotNil(fetchedVehicle)
❌ XCTAssertEqual(fetchedVehicle?.brand, "Tesla")
```

### 10. Exemple Complet

**Référence** : `InvoicerTests/Data/Repositories/VehicleDatabaseRepository_Spec.swift`

```swift
final class VehicleDatabaseRepository_Spec: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        testDatabase = try DatabaseManager(databasePath: ":memory:")
        repository = VehicleDatabaseRepository(database: testDatabase)
        fetchedVehicle = nil
        fetchedVehicles = []
    }

    override func tearDown() async throws {
        testDatabase = nil
        repository = nil
        fetchedVehicle = nil
        fetchedVehicles = []
        try await super.tearDown()
    }

    func test_create_vehicleExistsInDatabase() async throws {
        let vehicle = Vehicle.make(brand: "Tesla", model: "Model 3")
        try await givenVehicleCreated(vehicle)
        try await whenFetchingVehicle(id: vehicle.id)
        thenVehicleShouldExist(vehicle)
    }

    private func givenVehicleCreated(
        _ vehicle: Vehicle,
        at folderPath: String? = nil
    ) async throws {
        let path = folderPath ?? "/test/vehicles/\(vehicle.id.uuidString)"
        try await repository.create(vehicle: vehicle, folderPath: path)
    }

    private func whenFetchingVehicle(id: UUID) async throws {
        fetchedVehicle = try await repository.fetch(id: id)
    }

    private func thenVehicleShouldExist(_ expected: Vehicle) {
        XCTAssertNotNil(fetchedVehicle, "Vehicle should exist in database")
        XCTAssertEqual(fetchedVehicle?.id, expected.id, "Vehicle ID should match")
    }

    private var testDatabase: DatabaseManager!
    private var repository: VehicleDatabaseRepository!
    private var fetchedVehicle: Vehicle?
    private var fetchedVehicles: [Vehicle] = []
}
```

### 11. Checklist de Revue de Tests

Avant de valider un fichier de test, vérifier :

- [ ] Tous les tests suivent `test_Action_ce_que_je_vais_vérifier()`
- [ ] Pattern Given-When-Then respecté
- [ ] Helpers nommés `givenX`, `whenX`, `thenX`
- [ ] Variables globales déclarées en bas de classe
- [ ] Variables reset dans `setUp()` et `tearDown()`
- [ ] Base de données en mémoire (`:memory:`)
- [ ] Pas de commentaires dans le code
- [ ] Messages descriptifs dans toutes les assertions
- [ ] Extension `.make()` créée si nécessaire
- [ ] Tous les tests passent ✅

## Ressources Utiles

### Documentation Projet
- **ARCHITECTURE_HYBRIDE_GRDB.md** : Architecture complète avec exemples
- **QUICKSTART_GRDB.md** : Guide de démarrage rapide
- **FICHIERS_CREES.md** : Liste et description de tous les fichiers créés

### Documentation Externe
- **Composable Architecture** : https://github.com/pointfreeco/swift-composable-architecture
- **Sharing-GRDB** : https://github.com/pointfreeco/sharing-grdb
- **GRDB.swift** : https://github.com/groue/grdb.swift
- **Apple HIG** : Utiliser Context7 pour accéder aux dernières guidelines

### Fichiers Clés du Projet
- `InvoicerApp.swift:1` - Point d'entrée avec init de DatabaseManager
- `AppStore.swift:1` - Store principal et navigation
- `DatabaseManager.swift:1` - Configuration GRDB
- `VehicleDatabaseRepository.swift:1` - Repository avec CRUD
- `VehicleMetadataSyncManager.swift:1` - Sync GRDB ↔ JSON
- `VehicleRecord.swift:1` - Table SQLite véhicules
- `Vehicle.swift:1` - Modèle domain véhicule

---

**Dernière mise à jour** : 25 Octobre 2025
**Version** : 2.1 - Ajout des conventions de tests unitaires complètes
