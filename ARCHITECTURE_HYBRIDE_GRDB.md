# Architecture Hybride Sharing-GRDB + JSON

## 📋 Vue d'ensemble

Ce document décrit l'architecture hybride mise en place pour Invoicer, combinant :
- **Sharing-GRDB** : Base de données locale performante (SQLite)
- **Fichiers JSON** : Backup et portabilité des métadonnées

### Objectifs

✅ **Performance** : Requêtes SQL rapides avec GRDB
✅ **Portabilité** : Les données voyagent avec les fichiers
✅ **Résilience** : Reconstruction possible depuis les JSON
✅ **Local-first** : Pas de cloud, pas de coûts
✅ **RGPD-friendly** : Données 100% locales

---

## 🏗️ Architecture Globale

```
📁 Dossier App Invoicer/
  ├── 📁 Renault Clio/
  │   ├── .vehicle_metadata.json    ← Métadonnées exportées
  │   ├── facture_garage_2024.pdf
  │   └── assurance.pdf
  ├── 📁 Peugeot 308/
  │   ├── .vehicle_metadata.json
  │   └── controle_technique.pdf

📱 App iOS
  ├── 🗄️ Sharing-GRDB (SQLite)
  │   ├── Table: vehicleRecord
  │   └── Table: fileMetadataRecord
  │
  ├── 📦 Domain Models (Business Logic)
  │   ├── Vehicle
  │   └── Document
  │
  └── 🔄 Sync Manager
      ├── GRDB → JSON (export)
      └── JSON → GRDB (import)
```

---

## 📂 Structure des Fichiers Créés

```
Invoicer/Data/Database/
├── Records/                          # 🗄️ Couche Persistence
│   ├── VehicleRecord.swift           # Table vehicleRecord (@Table)
│   └── FileMetadataRecord.swift      # Table fileMetadataRecord (@Table)
│
├── DTOs/                             # 📦 Transfer Objects (JSON)
│   ├── VehicleDTO.swift              # Structure JSON véhicule
│   ├── FileMetadataDTO.swift         # Structure JSON fichier
│   └── VehicleMetadataFile.swift     # Structure JSON complète
│
├── Mappers/                          # 🔄 Conversions entre couches
│   ├── VehicleMappers.swift          # Record ↔ Domain ↔ DTO
│   └── FileMetadataMappers.swift     # Record ↔ Domain ↔ DTO
│
├── DatabaseMigrator.swift            # 🔧 Migrations GRDB
├── DatabaseManager.swift             # 💾 Gestionnaire de BDD
└── VehicleMetadataSyncManager.swift  # ⚡ Sync GRDB ↔ JSON

Invoicer/Data/Repositories/
└── VehicleDatabaseRepository.swift   # 🎯 Repository avec CRUD
```

---

## 🎯 Les 3 Couches de l'Architecture

### 1️⃣ **Record Layer** (Persistence - Base de données)

**Responsabilité** : Stockage SQLite avec Sharing-GRDB

```swift
@Table
struct VehicleRecord {
    let id: UUID
    var type: String
    var brand: String
    var model: String
    var folderPath: String  // Stocké comme String
    var createdAt: Date
    var updatedAt: Date

    static let files = hasMany(FileMetadataRecord.self)
}
```

**Caractéristiques** :
- ✅ Macro `@Table` de Sharing-GRDB
- ✅ Types primitifs optimisés pour SQL
- ✅ Relations définies (hasMany, belongsTo)
- ✅ Pas de logique métier

---

### 2️⃣ **Domain Layer** (Business Logic - App)

**Responsabilité** : Modèles métier utilisés dans toute l'app

```swift
struct Vehicle: Identifiable {
    let id: UUID
    var type: VehicleType  // Enum avec logique
    var brand: String
    var model: String
    var documents: [Document]  // Relation chargée

    // Computed properties
    var displayName: String {
        "\(brand) \(model)"
    }
}
```

**Caractéristiques** :
- ✅ Types riches (enums, computed properties)
- ✅ Logique métier embarquée
- ✅ Utilisé dans SwiftUI, Composable Architecture
- ✅ Indépendant de la BDD

---

### 3️⃣ **DTO Layer** (Transfer Objects - JSON)

**Responsabilité** : Export/Import JSON

```swift
struct VehicleDTO: Codable {
    var id: UUID
    var type: String
    var brand: String
    var model: String
    var createdAt: Date
    var updatedAt: Date
}

struct VehicleMetadataFile: Codable {
    var vehicle: VehicleDTO
    var files: [FileMetadataDTO]
    var metadata: MetadataInfo
}
```

**Caractéristiques** :
- ✅ Codable pour JSON
- ✅ Pas de logique
- ✅ Structure plate et simple
- ✅ Versionné (metadata.version)

---

## 🔄 Flux de Données

### Workflow 1 : Utilisation Normale

```
User Action (Add Vehicle)
         ↓
   Domain Model (Vehicle)
         ↓
   VehicleRepository.create()
         ↓
   Vehicle → VehicleRecord (Mapper)
         ↓
   GRDB Insert
         ↓
   SyncManager.exportToJSON()
         ↓
   .vehicle_metadata.json créé
```

### Workflow 2 : Changement d'iPhone

```
1. Utilisateur copie son dossier via iCloud/Dropbox
         ↓
2. Nouvel iPhone : App ouverte
         ↓
3. Utilisateur choisit le dossier racine
         ↓
4. SyncManager.scanAndRebuildDatabase()
         ↓
5. Pour chaque sous-dossier :
   - Lire .vehicle_metadata.json
   - Décoder VehicleMetadataFile
   - Convertir DTO → Record
   - Insérer dans GRDB
         ↓
6. ✅ Base de données reconstruite !
```

### Workflow 3 : Modification d'un Véhicule

```
User modifie le kilométrage
         ↓
   VehicleRepository.update()
         ↓
   GRDB Update (VehicleRecord)
         ↓
   SyncManager.syncAfterChange()
         ↓
   Export automatique vers JSON
         ↓
   .vehicle_metadata.json mis à jour
```

---

## 📝 Format du Fichier JSON

### Exemple : `.vehicle_metadata.json`

```json
{
  "vehicle": {
    "id": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890",
    "type": "car",
    "brand": "Renault",
    "model": "Clio",
    "mileage": "45000",
    "registrationDate": "2020-03-15T00:00:00Z",
    "plate": "AB-123-CD",
    "isPrimary": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-06-20T14:22:00Z"
  },
  "files": [
    {
      "id": "F1234567-89AB-CDEF-0123-456789ABCDEF",
      "fileName": "facture_garage_2024.pdf",
      "relativePath": "facture_garage_2024.pdf",
      "documentType": "Entretien",
      "documentName": "Vidange et révision",
      "date": "2024-01-20T09:15:00Z",
      "mileage": "44500",
      "amount": 250.50,
      "fileSize": 245680,
      "mimeType": "application/pdf",
      "createdAt": "2024-01-20T09:15:00Z",
      "modifiedAt": "2024-01-20T09:15:00Z"
    },
    {
      "id": "F2345678-9ABC-DEF0-1234-56789ABCDEF0",
      "fileName": "assurance.pdf",
      "relativePath": "assurance.pdf",
      "documentType": "Assurance",
      "documentName": "Contrat annuel",
      "date": "2024-01-10T11:00:00Z",
      "mileage": "44000",
      "amount": 450.00,
      "fileSize": 128490,
      "mimeType": "application/pdf",
      "createdAt": "2024-01-10T11:00:00Z",
      "modifiedAt": "2024-01-10T11:00:00Z"
    }
  ],
  "metadata": {
    "version": "1.0",
    "lastSyncedAt": "2024-06-20T14:22:00Z",
    "appVersion": "1.0.0"
  }
}
```

---

## 💻 Exemples d'Utilisation

### Créer un Véhicule

```swift
import Dependencies

struct AddVehicleStore: Reducer {
    @Dependency(\.vehicleDatabaseRepository) var repository
    @Dependency(\.syncManager) var syncManager

    func createVehicle() async throws {
        let vehicle = Vehicle(
            type: .car,
            brand: "Renault",
            model: "Clio",
            plate: "AB-123-CD"
        )

        let folderPath = "/path/to/vehicle/folder"

        // 1. Créer dans GRDB
        try await repository.create(vehicle: vehicle, folderPath: folderPath)

        // 2. JSON exporté automatiquement par le repository

        print("✅ Véhicule créé et JSON synchronisé")
    }
}
```

### Récupérer les Véhicules

```swift
struct VehiclesListStore: Reducer {
    @Dependency(\.vehicleDatabaseRepository) var repository

    func loadVehicles() async throws {
        // Récupérer tous les véhicules
        let vehicles = try await repository.fetchAll()

        // Récupérer un véhicule avec ses documents
        if let vehicle = try await repository.fetchWithDocuments(id: vehicleId) {
            print("Vehicle: \(vehicle.displayName)")
            print("Documents: \(vehicle.documents.count)")
        }
    }
}
```

### Reconstruction depuis JSON (Premier Lancement)

```swift
struct OnboardingStore: Reducer {
    @Dependency(\.syncManager) var syncManager

    func rebuildFromFolder(folderPath: String) async throws {
        // Scanner le dossier et reconstruire la BDD
        let vehicleIds = try await syncManager.scanAndRebuildDatabase(
            rootFolderPath: folderPath
        )

        print("✅ \(vehicleIds.count) véhicules importés")
    }
}
```

### Observer les Changements dans SwiftUI

```swift
import SwiftUI
import SharingGRDB

struct VehiclesListView: View {
    @FetchAll(VehicleRecord.order(by: \.brand))
    var vehicleRecords: [VehicleRecord]

    var body: some View {
        List(vehicleRecords) { record in
            VehicleCard(vehicle: record.toDomain())
        }
    }
}
```

---

## 🔧 Configuration dans l'App

### 1. Setup dans `InvoicerApp.swift`

```swift
import SwiftUI
import SharingGRDB
import Dependencies

@main
struct InvoicerApp: App {
    init() {
        // Setup Sharing-GRDB
        prepareDependencies {
            do {
                let dbManager = try DatabaseManager()
                $0.database = dbManager
            } catch {
                fatalError("Failed to setup database: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppStore.State()) {
                    AppStore()
                }
            )
        }
    }
}
```

---

## 🧪 Tests

### Exemple de Test Unitaire

```swift
import XCTest
@testable import Invoicer

final class VehicleDatabaseRepositoryTests: XCTestCase {
    var repository: VehicleDatabaseRepository!
    var database: DatabaseManager!

    override func setUp() async throws {
        // Setup base de données en mémoire pour les tests
        database = try DatabaseManager(databasePath: ":memory:")
        repository = VehicleDatabaseRepository()
    }

    func testCreateAndFetchVehicle() async throws {
        // Given
        let vehicle = Vehicle(
            type: .car,
            brand: "Renault",
            model: "Clio",
            plate: "AB-123-CD"
        )

        // When
        try await repository.create(vehicle: vehicle, folderPath: "/tmp/test")
        let fetched = try await repository.fetch(id: vehicle.id)

        // Then
        XCTAssertEqual(fetched?.brand, "Renault")
        XCTAssertEqual(fetched?.model, "Clio")
    }
}
```

---

## 📊 Schéma de Base de Données

### Table : `vehicleRecord`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Identifiant unique |
| `type` | TEXT | NOT NULL | Type de véhicule (car, motorcycle...) |
| `brand` | TEXT | NOT NULL | Marque |
| `model` | TEXT | NOT NULL | Modèle |
| `mileage` | TEXT | NULLABLE | Kilométrage |
| `registrationDate` | DATETIME | NOT NULL | Date d'immatriculation |
| `plate` | TEXT | NOT NULL | Plaque |
| `isPrimary` | BOOLEAN | NOT NULL | Véhicule principal |
| `folderPath` | TEXT | NOT NULL | Chemin du dossier |
| `createdAt` | DATETIME | NOT NULL | Date de création |
| `updatedAt` | DATETIME | NOT NULL | Date de modification |

**Index** :
- `idx_vehicle_plate` sur `plate`
- `idx_vehicle_isPrimary` sur `isPrimary`

### Table : `fileMetadataRecord`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Identifiant unique |
| `vehicleId` | UUID | FOREIGN KEY | Référence au véhicule |
| `fileName` | TEXT | NOT NULL | Nom du fichier |
| `relativePath` | TEXT | NOT NULL | Chemin relatif |
| `documentType` | TEXT | NOT NULL | Type de document |
| `documentName` | TEXT | NOT NULL | Nom personnalisé |
| `date` | DATETIME | NOT NULL | Date du document |
| `mileage` | TEXT | NOT NULL | Kilométrage |
| `amount` | DOUBLE | NULLABLE | Montant |
| `fileSize` | INTEGER | NOT NULL | Taille en octets |
| `mimeType` | TEXT | NOT NULL | Type MIME |
| `createdAt` | DATETIME | NOT NULL | Date de création |
| `modifiedAt` | DATETIME | NOT NULL | Date de modification |

**Index** :
- `idx_file_vehicleId` sur `vehicleId`
- `idx_file_date` sur `date`
- `idx_file_documentType` sur `documentType`

**Contraintes** :
- `ON DELETE CASCADE` : Suppression des fichiers quand le véhicule est supprimé

---

## 🚀 Migration depuis l'Ancien Système

Si tu as déjà des données JSON dans l'ancien format, voici comment migrer :

```swift
struct LegacyMigrator {
    @Dependency(\.syncManager) var syncManager

    func migrateOldJSONs(rootFolder: String) async throws {
        // 1. Scanner l'ancien format
        let oldJSONs = findOldJSONFiles(in: rootFolder)

        // 2. Pour chaque ancien JSON
        for oldJSON in oldJSONs {
            // Lire et convertir vers nouveau format
            let newMetadata = convertToNewFormat(oldJSON)

            // Sauvegarder au nouveau format
            let folderPath = oldJSON.deletingLastPathComponent().path
            try saveNewMetadata(newMetadata, to: folderPath)
        }

        // 3. Reconstruire la BDD
        let vehicleIds = try await syncManager.scanAndRebuildDatabase(
            rootFolderPath: rootFolder
        )

        print("✅ Migration terminée : \(vehicleIds.count) véhicules")
    }
}
```

---

## ⚡ Avantages de cette Architecture

### 1. **Performance**
- ✅ Requêtes SQL ultra-rapides
- ✅ Index optimisés
- ✅ Pas de parsing JSON en temps réel

### 2. **Résilience**
- ✅ Reconstruction possible depuis JSON
- ✅ Backup automatique
- ✅ Pas de perte de données

### 3. **Portabilité**
- ✅ JSON voyage avec les fichiers
- ✅ Backup via iCloud/Dropbox natif
- ✅ Migration facile entre appareils

### 4. **Maintenabilité**
- ✅ Séparation des responsabilités claire
- ✅ Tests unitaires faciles
- ✅ Évolutions simples

### 5. **Privacy-First**
- ✅ 100% local
- ✅ Pas de cloud
- ✅ RGPD-compliant

---

## 🔮 Évolutions Futures Possibles

### Phase 2 : Optimisations

1. **Sync sélectif**
   - Export uniquement des véhicules modifiés
   - Debouncing des exports

2. **Compression**
   - JSON compressés (.gz)
   - Économie d'espace

3. **Versioning avancé**
   - Historique des modifications
   - Rollback possible

### Phase 3 : Fonctionnalités Avancées

1. **Export/Import global**
   - Export de toute la BDD en un fichier
   - Import depuis un autre utilisateur

2. **Sync optionnel vers cloud**
   - Supabase pour backup distant
   - Synchronisation multi-appareils

3. **Recherche Full-Text**
   - FTS5 de SQLite
   - Recherche dans les documents

---

## 📚 Ressources

### Documentation Officielle
- [Sharing-GRDB](https://github.com/pointfreeco/sharing-grdb)
- [GRDB.swift](https://github.com/groue/grdb.swift)
- [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)

### Fichiers Clés
- `VehicleRecord.swift:1` - Record principal
- `VehicleMetadataSyncManager.swift:1` - Logique de sync
- `DatabaseManager.swift:1` - Setup GRDB
- `VehicleDatabaseRepository.swift:1` - Repository pattern

---

## ✅ Checklist d'Intégration

- [ ] Ajouter les dépendances Sharing-GRDB au projet
- [ ] Configurer `InvoicerApp.swift` avec le setup GRDB
- [ ] Tester la création d'un véhicule
- [ ] Vérifier que le JSON est créé automatiquement
- [ ] Tester la reconstruction depuis JSON
- [ ] Migrer les repositories existants
- [ ] Mettre à jour les Stores TCA
- [ ] Tests unitaires
- [ ] Tests d'intégration

---

## 🆘 Troubleshooting

### Erreur : "Table vehicleRecord not found"
**Solution** : Les migrations n'ont pas été exécutées. Vérifier `DatabaseManager.runMigrations()`.

### Erreur : "JSON file not found"
**Solution** : Le fichier `.vehicle_metadata.json` n'existe pas. Exporter d'abord avec `syncManager.exportVehicleToJSON()`.

### Erreur : "Foreign key constraint failed"
**Solution** : Vérifier que `PRAGMA foreign_keys = ON` est activé dans `DatabaseManager`.

---

## 👨‍💻 Auteur

**Nicolas Barbosa**
Date : 18 Octobre 2025
Version : 1.0

---

## 📄 Licence

Ce code fait partie du projet Invoicer et suit les mêmes conditions de licence.

---

**🎉 Félicitations ! Tu disposes maintenant d'une architecture robuste, performante et évolutive ! 🚀**
