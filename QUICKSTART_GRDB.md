# 🚀 Quick Start : Utilisation de l'Architecture GRDB

## Démarrage Rapide en 5 Minutes

### 1️⃣ Setup Initial dans l'App

Modifie `InvoicerApp.swift` :

```swift
import SwiftUI
import SharingGRDB
import Dependencies

@main
struct InvoicerApp: App {
    init() {
        // Setup Sharing-GRDB avec Dependencies
        prepareDependencies {
            do {
                // Créer le gestionnaire de base de données
                let dbManager = try DatabaseManager()
                $0.database = dbManager

                // Créer le sync manager
                let syncMgr = VehicleMetadataSyncManager()
                $0.syncManager = syncMgr

                // Créer le repository
                let repo = VehicleDatabaseRepository()
                $0.vehicleDatabaseRepository = repo

                print("✅ Base de données initialisée")
            } catch {
                fatalError("❌ Erreur lors du setup: \(error)")
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

### 2️⃣ Utilisation dans un Store TCA

#### Exemple : Créer un Véhicule

```swift
import ComposableArchitecture
import Dependencies

@Reducer
struct AddVehicleStore {
    @ObservableState
    struct State: Equatable {
        var brand = ""
        var model = ""
        var plate = ""
        var isLoading = false
    }

    enum Action {
        case saveButtonTapped
        case vehicleSaved(Result<Void, Error>)
    }

    @Dependency(\.vehicleDatabaseRepository) var repository
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .saveButtonTapped:
                state.isLoading = true

                let vehicle = Vehicle(
                    type: .car,
                    brand: state.brand,
                    model: state.model,
                    plate: state.plate
                )

                let folderPath = "/Users/Documents/Invoicer/\(vehicle.brand) \(vehicle.model)"

                return .run { send in
                    await send(
                        .vehicleSaved(
                            Result {
                                try await repository.create(
                                    vehicle: vehicle,
                                    folderPath: folderPath
                                )
                            }
                        )
                    )
                }

            case .vehicleSaved(.success):
                state.isLoading = false
                return .run { _ in await dismiss() }

            case .vehicleSaved(.failure(let error)):
                state.isLoading = false
                print("❌ Erreur : \(error)")
                return .none
            }
        }
    }
}
```

---

#### Exemple : Lister les Véhicules

```swift
@Reducer
struct VehiclesListStore {
    @ObservableState
    struct State: Equatable {
        var vehicles: [Vehicle] = []
        var isLoading = false
    }

    enum Action {
        case onAppear
        case vehiclesLoaded([Vehicle])
    }

    @Dependency(\.vehicleDatabaseRepository) var repository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true

                return .run { send in
                    let vehicles = try await repository.fetchAll()
                    await send(.vehiclesLoaded(vehicles))
                }

            case .vehiclesLoaded(let vehicles):
                state.vehicles = vehicles
                state.isLoading = false
                return .none
            }
        }
    }
}
```

---

### 3️⃣ Utilisation dans une Vue SwiftUI (avec @FetchAll)

#### Observer les changements en temps réel

```swift
import SwiftUI
import SharingGRDB

struct VehiclesListView: View {
    // Observe automatiquement les changements dans la BDD
    @FetchAll(VehicleRecord.order(by: \.brand))
    var vehicleRecords: [VehicleRecord]

    var body: some View {
        List {
            ForEach(vehicleRecords) { record in
                VehicleRow(vehicle: record.toDomain())
            }
        }
        .navigationTitle("Mes Véhicules")
    }
}

struct VehicleRow: View {
    let vehicle: Vehicle

    var body: some View {
        HStack {
            Image(systemName: vehicle.type.iconName ?? "car")
            VStack(alignment: .leading) {
                Text("\(vehicle.brand) \(vehicle.model)")
                    .font(.headline)
                Text(vehicle.plate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

---

### 4️⃣ Premier Lancement : Reconstruction depuis JSON

```swift
@Reducer
struct OnboardingStore {
    @ObservableState
    struct State: Equatable {
        var selectedFolderPath: String?
        var isImporting = false
        var importedVehiclesCount = 0
    }

    enum Action {
        case folderSelected(String)
        case startImport
        case importCompleted(Result<[UUID], Error>)
    }

    @Dependency(\.syncManager) var syncManager

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .folderSelected(let path):
                state.selectedFolderPath = path
                return .none

            case .startImport:
                guard let folderPath = state.selectedFolderPath else {
                    return .none
                }

                state.isImporting = true

                return .run { send in
                    await send(
                        .importCompleted(
                            Result {
                                try await syncManager.scanAndRebuildDatabase(
                                    rootFolderPath: folderPath
                                )
                            }
                        )
                    )
                }

            case .importCompleted(.success(let vehicleIds)):
                state.isImporting = false
                state.importedVehiclesCount = vehicleIds.count
                print("✅ \(vehicleIds.count) véhicules importés")
                return .none

            case .importCompleted(.failure(let error)):
                state.isImporting = false
                print("❌ Erreur d'import : \(error)")
                return .none
            }
        }
    }
}
```

---

### 5️⃣ Opérations Courantes

#### Mettre à jour un véhicule

```swift
// Dans un Store TCA
@Dependency(\.vehicleDatabaseRepository) var repository

// Modifier le kilométrage
var vehicle = try await repository.fetch(id: vehicleId)
vehicle?.mileage = "50000"

if let vehicle = vehicle {
    try await repository.update(
        vehicle: vehicle,
        folderPath: "/path/to/folder"
    )
}
```

#### Définir un véhicule comme principal

```swift
@Dependency(\.vehicleDatabaseRepository) var repository

try await repository.setPrimary(id: vehicleId)
```

#### Supprimer un véhicule

```swift
@Dependency(\.vehicleDatabaseRepository) var repository

try await repository.delete(id: vehicleId)
// Les fichiers metadata sont supprimés automatiquement (CASCADE)
```

#### Récupérer un véhicule avec ses documents

```swift
@Dependency(\.vehicleDatabaseRepository) var repository

if let vehicle = try await repository.fetchWithDocuments(id: vehicleId) {
    print("Véhicule : \(vehicle.brand) \(vehicle.model)")
    print("Documents : \(vehicle.documents.count)")

    for doc in vehicle.documents {
        print("- \(doc.name) (\(doc.type.displayName))")
    }
}
```

---

## 🎯 Exemples de Requêtes Avancées

### Filtrer les véhicules par type

```swift
import GRDB

@FetchAll(
    VehicleRecord
        .filter(Column("type") == "car")
        .order(by: \.brand)
)
var cars: [VehicleRecord]
```

### Compter les documents par véhicule

```swift
struct VehicleWithDocCount {
    var vehicle: VehicleRecord
    var documentCount: Int
}

@Dependency(\.database) var database

let results = try await database.read { db in
    try VehicleRecord
        .including(all: VehicleRecord.files)
        .fetchAll(db)
}
```

### Rechercher des documents par date

```swift
@FetchAll(
    FileMetadataRecord
        .filter(Column("date") >= Date().addingTimeInterval(-30 * 24 * 3600))
        .order { $0.date.desc() }
)
var recentDocuments: [FileMetadataRecord]
```

---

## 🧪 Tests

### Test Simple

```swift
import XCTest
@testable import Invoicer

final class VehicleRepositoryTests: XCTestCase {
    var repository: VehicleDatabaseRepository!

    override func setUp() async throws {
        // Base de données en mémoire pour les tests
        let dbManager = try DatabaseManager(databasePath: ":memory:")

        // Setup Dependencies pour les tests
        await withDependencies {
            $0.database = dbManager
        } operation: {
            repository = VehicleDatabaseRepository()
        }
    }

    func testCreateVehicle() async throws {
        // Given
        let vehicle = Vehicle(
            type: .car,
            brand: "Renault",
            model: "Clio",
            plate: "AB-123-CD"
        )

        // When
        try await repository.create(vehicle: vehicle, folderPath: "/tmp/test")

        // Then
        let fetched = try await repository.fetch(id: vehicle.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.brand, "Renault")
    }

    func testFetchAll() async throws {
        // Given
        let vehicle1 = Vehicle(type: .car, brand: "Renault", model: "Clio", plate: "AA-111-AA")
        let vehicle2 = Vehicle(type: .car, brand: "Peugeot", model: "308", plate: "BB-222-BB")

        try await repository.create(vehicle: vehicle1, folderPath: "/tmp/v1")
        try await repository.create(vehicle: vehicle2, folderPath: "/tmp/v2")

        // When
        let vehicles = try await repository.fetchAll()

        // Then
        XCTAssertEqual(vehicles.count, 2)
    }
}
```

---

## ⚠️ Points d'Attention

### 1. Chemins de Fichiers

**Toujours utiliser des chemins absolus** :

```swift
// ✅ Bon
let folderPath = "/Users/john/Documents/Invoicer/Renault Clio"

// ❌ Mauvais (chemin relatif)
let folderPath = "Renault Clio"
```

### 2. Gestion des Erreurs

**Toujours wrapper dans do-catch** :

```swift
do {
    try await repository.create(vehicle: vehicle, folderPath: path)
} catch {
    print("Erreur : \(error.localizedDescription)")
    // Gérer l'erreur proprement
}
```

### 3. Sync Automatique

Le sync vers JSON est **automatique** après chaque opération :
- `create()` → export JSON
- `update()` → export JSON
- `delete()` → pas d'export (le dossier peut être supprimé)

---

## 🎓 Next Steps

1. ✅ Intégrer dans tes Stores existants
2. ✅ Remplacer les anciens repositories
3. ✅ Tester la reconstruction depuis JSON
4. ✅ Migrer les données existantes
5. ✅ Écrire des tests unitaires

---

## 📚 Références

- [Architecture Complète](./ARCHITECTURE_HYBRIDE_GRDB.md)
- [Sharing-GRDB Docs](https://github.com/pointfreeco/sharing-grdb)
- [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)

---

**Bonne implémentation ! 🚀**
