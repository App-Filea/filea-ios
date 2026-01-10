---
title: 'Simplification Repository Layer + Optimisation JSON Sync'
slug: 'simplification-repository-json-optimization'
created: '2026-01-10'
status: 'ready-for-dev'
stepsCompleted: [1, 2, 3, 4]
approach: 'Simplification pragmatique - Consolidation Repository + Garde @Shared InMemory'
tech_stack:
  - 'Swift 6'
  - 'SwiftUI'
  - 'TCA (Composable Architecture 1.22.2+)'
  - 'SQLiteData (ex-sharing-grdb) - package URL update'
  - 'GRDB 7.9.0+'
  - 'Swift Dependencies'
  - 'Actor isolation'
files_to_modify:
  - 'Package.swift (UPDATE package URL sharing-grdb → sqlite-data)'
  - 'VehicleRepositoryClient.swift (SUPPRIMER)'
  - 'VehicleRepository.swift (SUPPRIMER wrapper)'
  - 'VehicleDatabaseRepository.swift (RENOMMER en VehicleGRDBClient + simplifier)'
  - 'VehicleMetadataSyncManager.swift (OPTIMISER avec debouncing)'
  - 'SharedKeys.swift (garder @Shared InMemory - pas de changement)'
  - 'Stores/*.swift (MIGRER @Dependency vers nouveau client)'
code_patterns:
  - '@Shared InMemory avec refresh manuel (pattern actuel conservé)'
  - 'GRDB StructuredQueries : .where { $0.id.in([id]) }'
  - 'JSON export async avec debouncing'
  - 'Actor isolation maintenue'
  - 'Error handling explicite (pas de try? silencieux)'
---

# Tech-Spec: Simplification Repository Layer + Optimisation JSON Sync

**Created:** 2026-01-10
**Approach:** Simplification pragmatique sans refonte architecturale complète

---

## 📋 Résumé Exécutif

### Objectif
Simplifier l'architecture en supprimant les couches Repository inutiles tout en **conservant** l'architecture @Shared InMemory actuelle qui fonctionne bien.

### Scope Réduit
- ✅ Consolidation 3 couches → 1 client GRDB simple
- ✅ Optimisation JSON export (debouncing, async, error handling)
- ✅ Mise à jour package : `sharing-grdb` → `sqlite-data`
- ✅ Migration Stores vers nouveau client
- ❌ Pas de custom PersistenceKey complexe
- ❌ Pas de ValueObservation (risque deadlock)
- ❌ Pas de changement @Shared (InMemory fonctionne bien)

### Bénéfices
- 🎯 Simplification réelle : ~30% de réduction de code
- 🚀 Migration rapide : 1-2 jours au lieu de 2-3 semaines
- 🔒 Risque minimal : Pas de refonte architecturale
- ✅ Performance maintenue : @Shared InMemory + refresh manuel

---

## Overview

### Problem Statement

L'architecture actuelle utilise **3 couches Repository** qui créent de la complexité inutile :

```
Store → VehicleRepositoryClient (interface)
              ↓
        VehicleRepository (wrapper/orchestrateur)
              ↓ (4 dépendances : grdbRepo, syncManager, storageManager, fileRepo)
        VehicleDatabaseRepository (implémentation GRDB)
```

**Complexité identifiée :**
- Couche `VehicleRepositoryClient` : Simple struct wrapper sans logique
- Couche `VehicleRepository` : Orchestrateur qui délègue tout
- 4 dépendances injectées dans le wrapper (sur-engineering)
- Navigation difficile : 3 fichiers à parcourir pour comprendre une opération CRUD

**⚠️ IMPORTANT :** Le sync JSON est **DÉJÀ automatique** via `syncManager.syncAfterChange()` appelé dans `VehicleRepository`. Il n'y a PAS de risque d'oubli comme mentionné dans les versions précédentes du spec.

### Solution

**Simplification en 1 seul client GRDB** :

```
Store → VehicleGRDBClient (tout-en-un)
              ↓ (direct GRDB + services)
        GRDB + SyncManager + StorageManager
```

**Architecture cible :**
```swift
// Store
@Dependency(\.vehicleGRDBClient) var grdbClient

return .run { send in
    try await grdbClient.create(vehicle)  // Simple, direct
    await send(.vehicleSaved)
}
```

**Conservation de @Shared InMemory :**
```swift
// Pattern actuel CONSERVÉ (fonctionne bien)
@Shared(.vehicles) var vehicles: [Vehicle] = []  // InMemory cache

// Après mutation
$vehicles.withLock { $0 = try await grdbClient.fetchAll() }  // Manual refresh
```

**Optimisation JSON Export :**
```swift
// Dans VehicleGRDBClient
func create(_ vehicle: Vehicle) async throws {
    // 1. Write GRDB
    try await database.write { db in
        try VehicleRecord.insert { vehicle.toRecord() }.execute(db)
    }

    // 2. Debounced JSON export (async, non-blocking)
    await jsonExportDebouncer.schedule(vehicleId: vehicle.id)
}
```

**Bénéfices :**
- ✅ Suppression de 2 couches (Client + Wrapper)
- ✅ Navigation code simplifiée (1 fichier au lieu de 3)
- ✅ @Shared InMemory conservé (performant)
- ✅ JSON export optimisé (debouncing)
- ✅ Pas de risque deadlock (pas de ValueObservation complexe)

### Scope

**In Scope:**
- Mise à jour Package.swift : `sharing-grdb` → `sqlite-data`
- Suppression VehicleRepositoryClient.swift
- Suppression VehicleRepository.swift (wrapper)
- Renommage VehicleDatabaseRepository → VehicleGRDBClient
- Simplification VehicleGRDBClient (retrait orchestration, ajout logique métier)
- Optimisation VehicleMetadataSyncManager (debouncing, error handling)
- Migration Stores vers nouveau client
- Tests de non-régression

**Out of Scope:**
- Custom PersistenceKey (@Shared reste InMemory)
- ValueObservation GRDB (risque deadlock)
- Modification architecture @Shared (fonctionne bien)
- Migration Big Bang (progressive : Vehicle → Documents → Cleanup)
- Nouvelles features UI (Dashboard, etc.)

---

## Context for Development

### Architecture AVANT (actuelle)

**3 Couches :**

```swift
// 1. VehicleRepositoryClient.swift - Interface TCA
struct VehicleRepositoryClient: Sendable {
    var createVehicle: @Sendable (Vehicle) async throws -> Void
    var updateVehicle: @Sendable (Vehicle) async throws -> Void
    // ... 7 méthodes
}

// 2. VehicleRepository.swift - Wrapper/Orchestrateur
actor VehicleRepository {
    @Dependency(\.vehicleDatabaseRepository) var grdbRepo
    @Dependency(\.syncManagerClient) var syncManager
    @Dependency(\.storageManager) var storageManager
    @Dependency(\.fileVehicleRepository) var fileRepo  // Legacy

    func createVehicle(_ vehicle: Vehicle) async throws {
        let folderPath = /* compute */
        try await grdbRepo.create(vehicle, folderPath)
        try await syncManager.syncAfterChange(vehicle.id)  // ✅ Déjà automatique
        try await storageManager.createVehicleFolder(folderName)
        try await fileRepo.save(vehicle)  // Legacy
    }
}

// 3. VehicleDatabaseRepository.swift - Implémentation GRDB
actor VehicleDatabaseRepository {
    private let database: DatabaseManager

    func create(_ vehicle: Vehicle, _ folderPath: String) async throws {
        try await database.write { db in
            try VehicleRecord.insert { vehicle.toRecord(folderPath) }.execute(db)
        }
    }
}
```

**Store actuel :**
```swift
@Dependency(\.vehicleRepository) var vehicleRepository

case .saveButtonTapped:
    return .run { [vehicle] send in
        try await vehicleRepository.createVehicle(vehicle)
        await send(.vehicleSaved)
    }
```

---

### Architecture APRÈS (simplifiée)

**1 Seul Client :**

```swift
// VehicleGRDBClient.swift (renommé de VehicleDatabaseRepository)
actor VehicleGRDBClient {
    private let database: DatabaseManager
    private let syncManager: VehicleMetadataSyncManager
    private let storageManager: VehicleStorageManager
    private let jsonDebouncer: JSONExportDebouncer

    func create(_ vehicle: Vehicle) async throws {
        // 1. Compute folderPath (logique métier consolidée ici)
        guard let rootURL = await storageManager.getRootURL() else {
            throw VehicleGRDBError.storageNotConfigured
        }
        let folderPath = rootURL
            .appendingPathComponent("Vehicles")
            .appendingPathComponent("\\(vehicle.brand)\\(vehicle.model)")
            .path

        // 2. Create folder
        try await storageManager.createVehicleFolder("\\(vehicle.brand)\\(vehicle.model)")

        // 3. Write to GRDB
        try await database.write { db in
            let record = vehicle.toRecord(folderPath: folderPath)
            try VehicleRecord.insert { record }.execute(db)
        }

        // 4. Debounced JSON export (async, non-blocking)
        await jsonDebouncer.schedule(vehicleId: vehicle.id)

        print("✅ [VehicleGRDBClient] Vehicle created: \\(vehicle.brand) \\(vehicle.model)")
    }

    func fetchAll() async throws -> [Vehicle] {
        try await database.read { db in
            let vehicleRecords = try VehicleRecord.all.fetchAll(db)
            return try vehicleRecords.map { vehicleRecord in
                let fileRecords = try FileMetadataRecord
                    .where { $0.vehicleId.in([vehicleRecord.id]) }
                    .order { $0.date.desc() }
                    .fetchAll(db)
                var vehicle = vehicleRecord.toDomain()
                vehicle.documents = fileRecords.map {
                    $0.toDomain(vehicleFolderPath: vehicleRecord.folderPath)
                }
                return vehicle
            }.sorted {
                if $0.isPrimary != $1.isPrimary {
                    return $0.isPrimary
                }
                return $0.brand < $1.brand
            }
        }
    }

    func update(_ vehicle: Vehicle) async throws {
        // Similar pattern
    }

    func delete(id: String) async throws {
        // Similar pattern
    }

    func setPrimary(id: String) async throws {
        // Toggle isPrimary logic
    }

    func fetchPrimary() async throws -> Vehicle? {
        // Fetch primary vehicle
    }
}

// Dependency registration
extension VehicleGRDBClient: DependencyKey {
    static let liveValue: VehicleGRDBClient = {
        do {
            return try VehicleGRDBClient(
                database: DatabaseManager(),
                syncManager: VehicleMetadataSyncManager(),
                storageManager: VehicleStorageManager()
            )
        } catch {
            fatalError("❌ [VehicleGRDBClient] Init failed: \\(error)")
        }
    }()

    static let testValue: VehicleGRDBClient = {
        // Test implementation with :memory: database
    }()
}

extension DependencyValues {
    var vehicleGRDBClient: VehicleGRDBClient {
        get { self[VehicleGRDBClient.self] }
        set { self[VehicleGRDBClient.self] = newValue }
    }
}
```

**Store simplifié :**
```swift
@Dependency(\.vehicleGRDBClient) var grdbClient

case .saveButtonTapped:
    return .run { [vehicle] send in
        try await grdbClient.create(vehicle)

        // Refresh @Shared cache
        let updatedVehicles = try await grdbClient.fetchAll()
        await send(.vehiclesUpdated(updatedVehicles))
    }

case .vehiclesUpdated(let vehicles):
    state.$vehicles.withLock { $0 = vehicles }
    return .none
```

---

### Optimisation JSON Export avec Debouncing

**Problème actuel :**
- Chaque mutation → export JSON immédiat
- Mutations rapides → exports multiples
- Bloque parfois l'UI (FileManager.write synchrone)

**Solution : JSONExportDebouncer**

```swift
// JSONExportDebouncer.swift (NOUVEAU)
actor JSONExportDebouncer {
    private let syncManager: VehicleMetadataSyncManager
    private let debounceInterval: Duration = .milliseconds(500)
    private var scheduledExports: [String: Task<Void, Never>] = [:]

    func schedule(vehicleId: String) async {
        // Cancel previous task if exists
        scheduledExports[vehicleId]?.cancel()

        // Schedule new debounced export
        scheduledExports[vehicleId] = Task {
            try? await Task.sleep(for: debounceInterval)

            guard !Task.isCancelled else { return }

            do {
                try await syncManager.exportVehicleToJSON(vehicleId: vehicleId)
                print("💾 [JSONExportDebouncer] Exported JSON for vehicle: \\(vehicleId)")
            } catch {
                print("❌ [JSONExportDebouncer] Export failed: \\(error.localizedDescription)")
                // TODO: Retry logic or user notification
            }

            scheduledExports[vehicleId] = nil
        }
    }

    func flush(vehicleId: String) async {
        // Force immediate export (pour tests ou actions critiques)
        scheduledExports[vehicleId]?.cancel()
        do {
            try await syncManager.exportVehicleToJSON(vehicleId: vehicleId)
        } catch {
            print("❌ [JSONExportDebouncer] Flush failed: \\(error)")
        }
    }
}
```

**Bénéfices :**
- ✅ Mutations rapides → 1 seul export après 500ms
- ✅ Async non-blocking
- ✅ Error handling explicite
- ✅ Testable facilement

---

## Implementation Plan

### PHASE 0 : Préparation (Obligatoire)

- [ ] **Task 0.1 : Mise à jour Package.swift**
  - File: `Package.swift`
  - Action: Remplacer `https://github.com/pointfreeco/sharing-grdb` par `https://github.com/pointfreeco/sqlite-data`
  - Notes: Package renommé, API compatible
  - Commande: Xcode → File → Packages → Update to Latest Package Versions

- [ ] **Task 0.2 : Audit Stores utilisant vehicleRepository**
  - Action: `grep -r "@Dependency(\\.vehicleRepository)" Holfy/Stores/`
  - Notes: Créer liste exhaustive des Stores à migrer
  - Output: Liste dans un fichier `_bmad-output/stores-to-migrate.txt`

- [ ] **Task 0.3 : Backup GRDB database**
  - Action: Copier `*.sqlite` vers `_bmad-output/backup-before-migration/`
  - Notes: Rollback possible si migration échoue

---

### PHASE 1 : Simplification Repository Layer

- [ ] **Task 1.1 : Créer JSONExportDebouncer**
  - File: `Holfy/Data/Database/JSONExportDebouncer.swift` (nouveau)
  - Action: Implémenter actor avec debouncing 500ms
  - Notes: Code complet fourni ci-dessus

- [ ] **Task 1.2 : Renommer VehicleDatabaseRepository → VehicleGRDBClient**
  - File: `Holfy/Data/Repositories/VehicleDatabase/VehicleDatabaseRepository.swift`
  - Action: Renommer fichier + class, déplacer vers `Holfy/Data/Database/Clients/VehicleGRDBClient.swift`
  - Notes: Xcode → Refactor → Rename

- [ ] **Task 1.3 : Consolider logique métier dans VehicleGRDBClient**
  - File: `Holfy/Data/Database/Clients/VehicleGRDBClient.swift`
  - Action:
    - Ajouter dependencies : `database`, `syncManager`, `storageManager`, `jsonDebouncer`
    - Migrer logique folderPath depuis VehicleRepository
    - Migrer logique isPrimary toggle
    - Remplacer `syncManager.syncAfterChange()` par `jsonDebouncer.schedule()`
  - Notes: Consolidation de toute la logique métier Vehicle

- [ ] **Task 1.4 : Supprimer VehicleRepositoryClient**
  - File: `Holfy/Data/Repositories/VehicleRepository/VehicleRepositoryClient.swift`
  - Action: **SUPPRIMER** le fichier complet
  - Notes: Plus nécessaire, Store appelle directement VehicleGRDBClient

- [ ] **Task 1.5 : Supprimer VehicleRepository wrapper**
  - File: `Holfy/Data/Repositories/VehicleRepository/VehicleRepository.swift`
  - Action: **SUPPRIMER** le fichier complet
  - Notes: Logique métier consolidée dans VehicleGRDBClient

- [ ] **Task 1.6 : Nettoyer RepositoryDependencies**
  - File: `Holfy/Data/Repositories/RepositoryDependencies.swift`
  - Action: Supprimer enregistrements `vehicleRepository`, `vehicleRepositoryClient`, `vehicleDatabaseRepository`
  - Notes: Si fichier vide, le supprimer

- [ ] **Task 1.7 : Tests unitaires VehicleGRDBClient**
  - File: `HolfyTests/Data/Database/VehicleGRDBClient_Spec.swift` (nouveau)
  - Action: Migrer tests de VehicleDatabaseRepository_Spec
  - Notes: Base `:memory:`, vérifier logique métier consolidée

- [ ] **Task 1.8 : Tests unitaires JSONExportDebouncer**
  - File: `HolfyTests/Data/Database/JSONExportDebouncer_Spec.swift` (nouveau)
  - Action: Tester debouncing (mutations rapides → 1 export), flush immédiat
  - Notes: Utiliser `Task.sleep` pour simuler délais

---

### PHASE 2 : Migration Stores

- [ ] **Task 2.1 : Migrer AddVehicleStore (MVP)**
  - File: `Holfy/Stores/AddVehicleStore/AddVehicleStore.swift`
  - Action: Remplacer `@Dependency(\.vehicleRepository)` par `@Dependency(\.vehicleGRDBClient)`
  - Notes: Pattern : `.run { try await grdbClient.create() }` puis refresh @Shared

- [ ] **Task 2.2 : Adapter tests AddVehicleStore**
  - File: `HolfyTests/Stores/AddVehicleStore_Spec.swift`
  - Action: Mock `vehicleGRDBClient` au lieu de `vehicleRepository`
  - Notes: Vérifier @Shared refresh après mutation

- [ ] **Task 2.3 : Migrer EditVehicleStore**
  - File: `Holfy/Stores/EditVehicleStore/EditVehicleStore.swift`
  - Action: Pattern identique Task 2.1

- [ ] **Task 2.4 : Migrer VehiclesListStore**
  - File: `Holfy/Stores/VehiclesListStore/VehiclesListStore.swift`
  - Action: Pattern identique Task 2.1

- [ ] **Task 2.5 : Migrer VehicleDetailsStore**
  - File: `Holfy/Stores/VehicleDetailsStore/VehicleDetailsStore.swift`
  - Action: Pattern identique Task 2.1

- [ ] **Task 2.6 : Migrer MainStore**
  - File: `Holfy/Stores/MainStore/MainStore.swift`
  - Action: Pattern identique Task 2.1, vérifier propagation @Shared aux child stores

- [ ] **Task 2.7 : Migrer autres Stores (selon audit Task 0.2)**
  - Files: Liste de Task 0.2
  - Action: Appliquer pattern migration systématiquement
  - Notes: Commit après chaque Store migré

- [ ] **Task 2.8 : Build & Tests Phase 2**
  - Action: `xcodebuild build && xcodebuild test`
  - Notes: Tous les tests doivent passer avant Phase 3

**🛑 CHECKPOINT PHASE 2** : Build réussit + tests passent

---

### PHASE 3 : Cleanup & Validation

- [ ] **Task 3.1 : Supprimer legacy FileVehicleRepository (si existe)**
  - File: `Holfy/Data/Repositories/FileVehicleRepository.swift`
  - Action: **SUPPRIMER** si plus utilisé (deprecated)
  - Notes: Grep pour vérifier aucune référence

- [ ] **Task 3.2 : Audit final dependencies**
  - Action: `grep -r "@Dependency(\\.vehicleRepository)" Holfy/` → 0 résultats
  - Notes: Vérifier aucune référence aux anciens Repository

- [ ] **Task 3.3 : Nettoyer imports inutilisés**
  - Action: Xcode → Product → Analyze (⌘+Shift+B)
  - Notes: Fix warnings imports inutilisés

- [ ] **Task 3.4 : Tests de non-régression complets**
  - Action: `xcodebuild test -scheme Invoicer`
  - Notes: Suite complète, 0 failures

- [ ] **Task 3.5 : Tests JSON export performance**
  - File: `HolfyTests/Integration/JSONExport_Performance_Spec.swift` (nouveau)
  - Action: Tester 10 mutations rapides → 1 export après 500ms
  - Notes: Mesurer latence < 50ms

- [ ] **Task 3.6 : Update CLAUDE.md**
  - File: `CLAUDE.md`
  - Action:
    - Supprimer mentions VehicleRepositoryClient, VehicleRepository wrapper
    - Ajouter section VehicleGRDBClient
    - Documenter pattern @Shared InMemory + refresh manuel
  - Notes: ⚠️ Faire MAINTENANT (pas en fin Phase 3)

- [ ] **Task 3.7 : Documentation architecture simplifiée**
  - File: `Documentation/ARCHITECTURE_SIMPLIFIED.md` (nouveau)
  - Action: Documenter nouvelle architecture (1 client au lieu de 3 couches)
  - Notes: Diagrammes avant/après, exemples code

---

## Acceptance Criteria

**Phase 1 - Simplification Repository :**

- [ ] **AC 1.1** : Étant donné Package.swift, quand je build, alors sqlite-data package est utilisé (pas sharing-grdb)
- [ ] **AC 1.2** : Étant donné VehicleGRDBClient, quand j'appelle `create()`, alors la logique métier (folderPath, storage) est consolidée dans le client
- [ ] **AC 1.3** : Étant donné JSONExportDebouncer, quand 5 mutations en 100ms, alors 1 seul export JSON après 500ms
- [ ] **AC 1.4** : Étant donné les fichiers VehicleRepositoryClient et VehicleRepository, quand je cherche dans le projet, alors ils n'existent plus
- [ ] **AC 1.5** : Étant donné les tests VehicleGRDBClient, quand je lance la suite, alors tous passent avec base `:memory:`

**Phase 2 - Migration Stores :**

- [ ] **AC 2.1** : Étant donné AddVehicleStore, quand j'utilise `@Dependency(\.vehicleGRDBClient)`, alors le Store compile et fonctionne
- [ ] **AC 2.2** : Étant donné tous les Stores migrés, quand je grep `@Dependency(\.vehicleRepository)`, alors 0 résultats (sauf imports legacy à nettoyer)
- [ ] **AC 2.3** : Étant donné @Shared(.vehicles), quand je mute puis refresh, alors l'UI est réactive et montre les données à jour
- [ ] **AC 2.4** : Étant donné les tests de tous les Stores, quand je lance `xcodebuild test`, alors 0 failures

**Phase 3 - Cleanup & Validation :**

- [ ] **AC 3.1** : Étant donné l'audit final, quand je cherche références aux anciens Repository, alors aucune trouvée
- [ ] **AC 3.2** : Étant donné le build Xcode, quand je compile en Release, alors 0 erreurs et 0 warnings critiques
- [ ] **AC 3.3** : Étant donné les tests de performance JSON, quand 10 mutations rapides, alors export unique après debounce et latence < 50ms
- [ ] **AC 3.4** : Étant donné CLAUDE.md à jour, quand un développeur lit la doc, alors il comprend la nouvelle architecture simplifiée
- [ ] **AC 3.5** : Étant donné l'app en prod avec données utilisateur, quand je teste create/update/delete, alors JSON backup reste synchronisé

---

## Additional Context

### Dependencies

**Package Swift à mettre à jour :**
- ~~`pointfreeco/sharing-grdb`~~ (archivé)
- ✅ `pointfreeco/sqlite-data` (version maintenue) - **JUSTE CHANGER L'URL**

**Autres packages (inchangés) :**
- `pointfreeco/swift-composable-architecture` (1.22.2+)
- `pointfreeco/swift-dependencies`
- `groue/GRDB.swift` (via sqlite-data)

### Testing Strategy

**Tests unitaires :**
1. VehicleGRDBClient : CRUD + logique métier consolidée
2. JSONExportDebouncer : debouncing + flush + error handling
3. Stores : mock grdbClient, vérifier @Shared refresh

**Tests d'intégration :**
4. JSON export performance : 10 mutations rapides → 1 export
5. Concurrence : mutations simultanées @Shared + GRDB
6. Error handling : disk full, permission denied

**Convention tests :**
- Pattern Given-When-Then
- Base `:memory:` pour GRDB
- Extension `.make()` pour fixtures
- TestStore + `withDependencies { }`

### Rollback Strategy

**Stratégie validée par utilisateur :**
- Git manual rollback
- Feature branch : `feat/simplify-repository-layer`
- Commits incrémentaux après chaque phase
- Si échec : `git reset --hard` ou suppression branche

**Checkpoints :**
- Après Phase 1 : Tag `v1-phase1-repository-simplified`
- Après Phase 2 : Tag `v1-phase2-stores-migrated`
- Après Phase 3 : Tag `v1-migration-complete`

### Migration Timeline Estimée

**Phase 0** : 30min (package update + audit)
**Phase 1** : 3-4h (simplification Repository + tests)
**Phase 2** : 4-6h (migration Stores selon nombre exact)
**Phase 3** : 2h (cleanup + validation)

**Total** : 1-2 jours de travail

---

## Notes Importantes

### Pourquoi cette Approche ?

1. **Pragmatique** : Résout la vraie complexité (3 couches → 1)
2. **Sûre** : Garde @Shared InMemory qui fonctionne bien
3. **Rapide** : Migration 1-2 jours au lieu de semaines
4. **Testable** : Architecture simple = tests simples
5. **Performante** : Debouncing JSON export + async

### Ce qui NE Change PAS

- ✅ @Shared reste InMemory (cache performant)
- ✅ Refresh manuel après mutation (pattern actuel)
- ✅ Format JSON `.vehicle_metadata.json` (backward compatible)
- ✅ GRDB comme source de vérité
- ✅ Actor isolation maintenue

### Ce qui Change

- ✅ 3 couches Repository → 1 client simple
- ✅ Logique métier consolidée dans VehicleGRDBClient
- ✅ JSON export optimisé (debouncing)
- ✅ Error handling explicite (pas de `try?`)
- ✅ Package `sqlite-data` au lieu de `sharing-grdb` archivé

### Risques Identifiés & Mitigation

| Risque | Impact | Mitigation |
| ------ | ------ | ---------- |
| **Oubli Store dans migration** | MOYEN | Audit Task 0.2 + grep validation Task 3.2 |
| **JSON export débouncing trop long** | FAIBLE | Paramètre configurable (500ms ajustable) |
| **Tests régression échouent** | MOYEN | Migration progressive + checkpoint après chaque phase |
| **Performance dégradée** | FAIBLE | Tests performance Task 3.5 avant validation |

### Prochaines Étapes Après Migration

1. Dashboard Principal Enrichi
2. Custom Segmented Control 5 Onglets
3. EventKit Reminders Integration
4. Stats Multi-Niveaux Level 1

---

**🎯 Spec prêt pour implémentation ! Migration simple, sûre, rapide.**
