# Architecture - Holfy

**Projet :** Holfy (Filea)
**Type :** Application iOS
**Version :** 1.0 (Build 5)
**Date :** 2026-01-11

## Résumé Exécutif

Holfy est une application iOS native de gestion de documents automobiles construite avec **SwiftUI** et **Composable Architecture (TCA)**. L'application permet aux utilisateurs de gérer plusieurs véhicules, de stocker des documents (carte grise, assurance, factures), de suivre les dépenses et de générer des statistiques.

**Caractéristiques clés** :
- Architecture **local-first** avec base de données GRDB
- Backup automatique JSON portable
- Design System personnalisé
- State management avec TCA
- Support iOS 18.5+

## Stack Technologique

### Langage et Frameworks

| Technologie | Version | Usage |
|-------------|---------|-------|
| **Swift** | 6.0 | Langage principal avec strict concurrency |
| **SwiftUI** | iOS 18.5+ | Framework UI déclaratif |
| **Composable Architecture** | 1.22.2+ | Architecture unidirectionnelle |
| **SQLite Data (GRDB)** | 1.4.3+ | Base de données locale réactive |
| **Combine** | - | Programmation réactive (effets TCA) |
| **Swift Charts** | - | Visualisation des statistiques |
| **PhotosUI / PDFKit** | - | Gestion médias et documents |

### Outils de Développement

| Outil | Version | Usage |
|-------|---------|-------|
| **Xcode** | 16.4 | IDE et build system |
| **Swift Package Manager** | - | Gestion dépendances |
| **Fastlane** | - | CI/CD et déploiement |

### Dépendances Non Utilisées

| Dépendance | Statut | Raison |
|------------|--------|--------|
| **Supabase Swift** | 2.5.1+ (référencé) | Architecture local-first privilégiée. Potentiel usage futur pour sync cloud optionnel. |

## Pattern d'Architecture

### Composable Architecture (TCA)

Holfy suit le pattern **unidirectionnel** de TCA :

```
┌─────────────────────────────────────┐
│            Vue SwiftUI              │
│  (observe le State, envoie Actions) │
└────────────┬────────────────────────┘
             │ Action
             ▼
┌─────────────────────────────────────┐
│            Reducer                  │
│   (logique métier, transforme      │
│    State selon Action)              │
└────────────┬────────────────────────┘
             │ Effect (async)
             ▼
┌─────────────────────────────────────┐
│         Dependencies                │
│   (Repositories, Services,          │
│    Database, Storage)               │
└────────────┬────────────────────────┘
             │ Result
             ▼
┌─────────────────────────────────────┐
│         Nouveau State               │
│    (mis à jour, Vue re-render)      │
└─────────────────────────────────────┘
```

**Avantages** :
- Flux de données prévisible et testable
- Isolation des effets (side effects)
- State centralisé
- Tests déterministes

### Architecture en Couches

```
┌──────────────────────────────────────┐
│      PRESENTATION LAYER              │
│   Stores (TCA) + Views (SwiftUI)    │
└──────────────┬───────────────────────┘
               │
┌──────────────▼───────────────────────┐
│        DOMAIN LAYER                  │
│  Models métier (Vehicle, Document)   │
└──────────────┬───────────────────────┘
               │
┌──────────────▼───────────────────────┐
│         DATA LAYER                   │
│  Repositories + Database (GRDB)      │
└──────────────┬───────────────────────┘
               │
┌──────────────▼───────────────────────┐
│    INFRASTRUCTURE LAYER              │
│   Services + Storage + Sync          │
└──────────────────────────────────────┘
```

### Architecture Hybride GRDB + JSON

Holfy utilise une **architecture hybride** unique :

**3 Couches de Données** :

1. **Record Layer** (Persistence SQLite)
   - `VehicleRecord`, `FileMetadataRecord`
   - Macro `@Table` de SQLite Data
   - Types primitifs optimisés pour SQL

2. **Domain Layer** (Business Logic)
   - `Vehicle`, `Document`
   - Enums riches, computed properties
   - Logique métier

3. **DTO Layer** (Transfer Objects JSON)
   - `VehicleDTO`, `FileMetadataDTO`
   - Structures `Codable` plates
   - Fichiers `.vehicle_metadata.json`

**Flux de Synchronisation** :

```
User Action → Store TCA → VehicleGRDBClient
                            ↓
                    GRDB Insert/Update (Record)
                            ↓
                    SyncManager.syncAfterChange()
                    [avec debouncing 500ms]
                            ↓
                    Export automatique vers JSON
```

**Avantages** :
- ✅ Performance (GRDB pour requêtes rapides)
- ✅ Portabilité (JSON pour backup)
- ✅ Reconstruction (BDD reconstruite depuis JSON)
- ✅ Sync automatique avec debouncing

## Architecture de Données

### Modèle de Données

#### Entités Principales

**Vehicle** (Véhicule)
```swift
struct Vehicle {
    let id: UUID
    var type: VehicleType          // car, motorcycle, truck, bike, other
    var brand: String
    var model: String
    var mileage: String?
    var registrationDate: Date
    var plate: String
    var isPrimary: Bool
    var documents: [Document]
}
```

**Document** (Document attaché à un véhicule)
```swift
struct Document {
    let id: UUID
    var vehicleId: UUID
    var type: DocumentType         // administrative, maintenance, repair, fuel, other
    var subtype: String?
    var title: String
    var amount: Double?
    var date: Date
    var mileage: String?
    var note: String?
    var filePath: String           // Chemin relatif vers le fichier
}
```

#### Relations

```
Vehicle (1) ──────── (N) Document
   ↓
VehicleRecord ──────── FileMetadataRecord
   ↓                          ↓
VehicleDTO    ──────── FileMetadataDTO
              (VehicleMetadataFile.json)
```

### Base de Données (GRDB)

**Configuration** :
- **Mode** : WAL (Write-Ahead Logging)
- **Foreign Keys** : Activées
- **Synchronisation** : NORMAL
- **Location** : Application Support Directory

**Tables** :
- `VehicleRecord` : Véhicules
- `FileMetadataRecord` : Métadonnées des documents (fichiers physiques séparés)

**Migrations** :
- Gérées par `DatabaseMigrator`
- Versionnées et incrémentales

### Système de Fichiers

**Structure des dossiers** :

```
[User-Selected Root]/
├── Vehicle-{UUID}/
│   ├── .vehicle_metadata.json     # Métadonnées + Documents
│   └── documents/
│       ├── {UUID}.pdf
│       ├── {UUID}.jpg
│       └── ...
├── Vehicle-{UUID}/
│   └── ...
```

**Stratégie** :
- L'utilisateur choisit un dossier racine (via Folder Picker)
- Un sous-dossier par véhicule
- Fichier JSON de métadonnées dans chaque dossier
- Documents stockés dans `documents/`

## State Management

### Stores TCA

**19 Stores organisés par fonctionnalité** :

#### Navigation Racine
- **AppStore** : Navigation principale, routes

#### Dashboard
- **MainStore** : Dashboard principal
  - `TotalCostVehicleStore` : Coût total par véhicule
  - `WarningVehicleStore` : Alertes (contrôle technique, assurance)
  - `VehicleMonthlyExpensesStore` : Graphiques mensuels

#### Gestion Véhicules
- **VehiclesListStore** : Liste des véhicules
- **VehicleDetailsStore** : Détails d'un véhicule
- **AddVehicleStore** : Ajout véhicule
- **AddFirstVehicleStore** : Onboarding premier véhicule
- **EditVehicleStore** : Édition véhicule

#### Gestion Documents
- **AddDocumentStore** : Ajout document
- **EditDocumentStore** : Édition document
- **DocumentDetailStore** : Affichage détail
- **VehicleCardDocumentScanStore** : Scan carte grise avec OCR

#### Paramètres
- **GlobalSettingsStore** : Paramètres globaux
- **StorageSettingsStore** : Configuration dossier de stockage
- **UnitAndMeasureSettingStore** : Unités et mesures

#### Onboarding
- **OnboardingStore** : Onboarding initial
- **StorageOnboardingStore** : Choix dossier de stockage

### Shared State avec @Shared

Le state partagé entre stores utilise la macro `@Shared` :

```swift
@Shared(.vehicles) var vehicles: [Vehicle] = []
@Shared(.userPreferences) var preferences: UserPreferences
```

**Keys** :
- `.vehicles` : Liste des véhicules
- `.userPreferences` : Préférences utilisateur
- `.storageFolder` : Chemin du dossier de stockage

### Dependencies

Le pattern **Dependencies** (Point-Free) est utilisé pour l'injection :

```swift
@Dependency(\.vehicleGRDBClient) var vehicleClient
@Dependency(\.database) var database
@Dependency(\.storageManager) var storageManager
@Dependency(\.syncManagerClient) var syncManager
```

**Avantages** :
- Testabilité (mocks faciles)
- Découplage
- Configuration centralisée

## Design System

### Tokens

**ColorTokens** :
- Couleurs sémantiques (primary, secondary, accent, etc.)
- Support Dark Mode

**SpacingTokens** :
- Espacements standardisés (xs, sm, md, lg, xl)

**RadiusTokens** :
- Rayons de coins (sm, md, lg)

**TypographyTokens** :
- Styles de texte (heading, body, caption)

### Composants

**Hiérarchie de Boutons** :
- `PrimaryButton` : Action principale
- `SecondaryButton` : Actions secondaires
- `TertiaryButton` : Actions tertiaires
- `AccentButton` : Actions d'accent

**Variants** : Default, Positive, Negative

**Labels** : Même hiérarchie que les boutons

### Composants Partagés

**Forms** :
- `FormField` : Champs de formulaire standardisés

**Cards** :
- `StatCard` : Carte statistique
- `DocumentCard` : Carte document
- `DetailCard` : Carte de détail

**Charts** :
- `MonthlyExpenseChart` : Graphique dépenses mensuelles

**Media** :
- `ThumbnailView` : Miniatures PDF/images
- `DocumentScannerView` : Scanner documents
- `CameraView` : Capture photo

## Fonctionnalités Clés

### Multi-Véhicules

- Gestion de véhicules multiples (voitures, motos, camions, vélos, autres)
- Un véhicule peut être marqué comme **principal**
- Dashboard global avec statistiques par véhicule

### Documents

**Types de documents** :
- **Administratifs** : Carte grise, assurance, contrôle technique
- **Entretien** : Vidanges, révisions
- **Réparations** : Pannes, accidents
- **Carburant** : Plein d'essence
- **Autres** : Documents custom

**Import** :
- Caméra (photos)
- Bibliothèque photos
- Fichiers (PDF, images)

**Scan Carte Grise** :
- OCR automatique via `VisionKit`
- Extraction : marque, modèle, immatriculation, date

### Statistiques

- **Coût total** par véhicule
- **Dépenses mensuelles** (graphique)
- **Alertes** : Contrôle technique, assurance à renouveler
- **Kilométrage** suivi

### Export/Backup

- **Export automatique JSON** après chaque modification (debouncing 500ms)
- **Portabilité** : Copier/déplacer le dossier racine
- **Reconstruction** : Recréer la BDD depuis les JSON

## Testing

### Stratégie de Tests

**Pattern BDD (Given-When-Then)** :

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
- Pas de `try!` dans le code de prod

### Couverture

Tests unitaires pour :
- ✅ Stores TCA (avec `TestStore`)
- ✅ Repositories
- ✅ Database (GRDB)
- ✅ Mappers (Record ↔ Domain ↔ DTO)

Tests UI :
- ❌ Non exécutés (marqués skip)

## Déploiement

### Fastlane

**Actions disponibles** :
- `setup_match` : Configuration certificats
- `regenerate_certificates` : Régénération certificats
- `beta` : Upload TestFlight
- `build` : Build Release
- `screenshots` : Génération screenshots

### Certificats (Match)

- Repository Git privé pour certificats
- Chiffrement avec mot de passe
- Partage entre développeurs/CI

### CI/CD

Configuration via Fastlane :
- Incrémentation build number
- Build automatique
- Upload TestFlight
- Mise à jour métadonnées

## Sécurité et Confidentialité

### App Sandbox

- **Activé** pour sécurité macOS/iOS
- **User Selected File Access** : Lecture/écriture uniquement sur dossier choisi par utilisateur

### Données Locales

- **Aucune donnée envoyée au cloud**
- **Tout stocké localement** (GRDB + fichiers)
- **Pas de telemetry** (Firebase présent mais non utilisé)

### Permissions

- **Camera** : Pour scanner documents et carte grise
- **Photos** : Pour importer depuis bibliothèque

## Évolutions Futures (Non Implémentées)

### Sync Cloud (Optionnel)

- Supabase Swift déjà référencé
- Permettrait sync multi-appareils
- Resterait **opt-in** (local-first par défaut)

### Fonctionnalités Potentielles

- Export PDF des statistiques
- Rappels automatiques (contrôle technique, assurance)
- Partage de véhicules entre utilisateurs
- Historique de kilométrage avec graphiques
- Comparaison de coûts entre véhicules

## Points d'Attention

### Limitations Actuelles

- **Quick Scan** : Documentation basée sur patterns, pas sur analyse exhaustive du code
- **iOS uniquement** : Pas de support macOS/visionOS
- **Pas de sync cloud** : Uniquement local
- **Pas de widgets** : Pas d'extension Home Screen

### Dettes Techniques

- Migration GRDB complète à vérifier
- Tests UI à implémenter ou retirer
- Documentation inline à améliorer

## Références

### Documentation Interne

- `CLAUDE.md` : Guide complet du projet
- `docs/source-tree-analysis.md` : Structure détaillée
- `docs/development-guide.md` : Guide de développement
- `docs/deployment-guide.md` : Guide de déploiement

### Documentation Externe

- [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [SQLite Data](https://github.com/pointfreeco/sqlite-data)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Swift 6 Documentation](https://docs.swift.org/swift-book/)

---

**Note** : Cette architecture a été générée via un Quick Scan. Pour des détails d'implémentation précis, consulter le code source et `CLAUDE.md`.
