---
title: 'Migration GRDB ValueObservation + JSON Backup Auto-Sync'
slug: 'migration-grdb-valueobservation-json-sync'
created: '2026-01-10'
revised: '2026-01-10'
status: 'review'
stepsCompleted: [1, 2, 3, 4]
corrections_applied:
  - 'F2: Architecture @Shared + GRDB corrigée avec docs officielles'
  - 'F3: afterNextTransaction remplacé par ValueObservation (GRDB docs)'
  - 'F6: Rollback strategy clarifié (git manual rollback)'
  - 'F15: Syntaxe corrigée (SQLiteData patterns)'
  - 'F30: Package name corrigé (sharing-grdb → SQLiteData/swift-sharing)'
tech_stack:
  - 'Swift 6'
  - 'SwiftUI'
  - 'TCA (Composable Architecture 1.22.2+)'
  - 'Swift Sharing (pour @Shared persistence)'
  - 'GRDB 7.9.0+ (ValueObservation)'
  - 'Swift Dependencies'
  - 'Actor isolation'
  - 'Combine'
files_to_modify:
  - 'DatabaseManager.swift (MODIFIER - ValueObservation)'
  - 'VehicleMetadataSyncManager.swift (MODIFIER - refactor pour observer)'
  - 'SharedKeys.swift (CRÉER - custom PersistenceKey pour GRDB)'
  - 'VehicleGRDBClient.swift (CRÉER - remplace VehicleDatabaseRepository)'
  - 'AddVehicleStore.swift (MIGRER)'
  - 'EditVehicleStore.swift (MIGRER)'
  - 'VehiclesListStore.swift (MIGRER)'
  - 'VehicleDetailsStore.swift (MIGRER)'
  - 'MainStore.swift (MIGRER)'
  - '+ Autres Stores à auditer'
code_patterns:
  - 'ValueObservation.tracking { } pour observer GRDB'
  - '@Shared avec custom PersistenceKey'
  - 'GRDB StructuredQueries : .where { $0.id.in([id]) }'
  - 'GRDB Write : VehicleRecord.insert { record }.execute(db)'
  - 'TCA Reducer pattern avec .run effects'
  - '@Table macro pour GRDB records'
sources_officielles:
  - 'https://github.com/pointfreeco/swift-sharing'
  - 'https://github.com/pointfreeco/sqlite-data'
  - 'https://github.com/groue/GRDB.swift'
  - 'https://github.com/pointfreeco/swift-composable-architecture'
---

# Tech-Spec: Migration GRDB ValueObservation + JSON Backup Auto-Sync

**Created:** 2026-01-10
**Revised:** 2026-01-10 (corrigé avec documentations officielles)

## ⚠️ CORRECTIONS APPLIQUÉES

Ce tech-spec a été **corrigé** après consultation des documentations officielles via Context7 :

1. **F2 CORRIGÉ** : `@Shared` ne se connecte PAS directement à GRDB - nécessite custom PersistenceKey + client GRDB
2. **F3 CORRIGÉ** : `afterNextTransaction` remplacé par `ValueObservation` (pattern GRDB officiel)
3. **F6 CORRIGÉ** : Stratégie de rollback clarifiée (git manual rollback par l'utilisateur)
4. **F15 CORRIGÉ** : Syntaxe corrigée avec patterns SQLiteData/swift-sharing
5. **F30 CORRIGÉ** : Package renommé : sharing-grdb → SQLiteData (archivé, nouvelle version)

**Sources consultées :**
- [Swift Sharing README](https://github.com/pointfreeco/swift-sharing)
- [SQLiteData (ex-sharing-grdb)](https://github.com/pointfreeco/sqlite-data)
- [GRDB.swift](https://github.com/groue/GRDB.swift)
- [TCA SharingState](https://github.com/pointfreeco/swift-composable-architecture/blob/shared-state-beta/Sources/ComposableArchitecture/Documentation.docc/Articles/SharingState.md)

---

## Overview

### Problem Statement

L'architecture actuelle utilise une couche Repository intermédiaire entre TCA Stores et GRDB avec appels manuels pour maintenir la synchronisation GRDB ↔ JSON.

**Complexité actuelle :**
- Appels manuels : `try await vehicleRepository.create(vehicle)` → `syncManager.exportVehicleToJSON()` ❌
- Risque d'oubli → désynchronisation GRDB ↔ JSON
- Architecture hybride : `@Shared` (local) + `@Dependency(\.vehicleRepository)`

### Solution

**⚠️ CORRECTION IMPORTANTE (F2, F3) :**

Contrairement à la version précédente du spec, `@Shared` ne peut PAS se connecter "directement à GRDB" et "remplacer le repository". Selon la [documentation officielle TCA](https://github.com/pointfreeco/swift-composable-architecture/blob/shared-state-beta/Sources/ComposableArchitecture/Documentation.docc/Articles/SharingState.md) et [Swift Sharing](https://github.com/pointfreeco/swift-sharing), `@Shared` nécessite :

1. **Un custom PersistenceKey** qui implémente la logique GRDB
2. **Un client/repository** qui fait les queries SQL
3. **ValueObservation** (GRDB pattern officiel) pour observer les changements

**Architecture cible CORRIGÉE :**

```
User Action → Store dispatch action
                    ↓
              .run effect
                    ↓
         VehicleGRDBClient.create(vehicle)
                    ↓
         GRDB write → VehicleRecord.insert { }
                    ↓ (success)
         ValueObservation détecte changement
                    ↓
         @Shared updated via custom PersistenceKey
                    ↓
         SyncManager.exportVehicleToJSON()
```

**Bénéfices :**
- ✅ Simplification de la couche Repository (consolidation en client GRDB)
- ✅ Réactivité automatique : ValueObservation → @Shared update → UI update
- ✅ Sync JSON garanti via ValueObservation onChange
- ✅ Réduction de code (suppression orchestrateur VehicleRepository)

### Scope

**In Scope:**
- Implémentation custom PersistenceKey pour @Shared + GRDB
- ValueObservation GRDB pour observer changements Vehicle
- Simplification Repository Layer (suppression wrapper, conservation client GRDB)
- Export JSON automatique via ValueObservation onChange
- Migration Stores vers @Shared(custom PersistenceKey)
- Tests de non-régression CRUD + JSON sync
- Conservation format JSON (.vehicle_metadata.json)

**Out of Scope:**
- Migration Big Bang (progressive : Vehicle → Documents → Cleanup)
- Modification format JSON (backward compatibility)
- Nouvelles features UI (Dashboard, Segmented Control, Reminders)
- SQLiteData package (trop différent, on garde GRDB + swift-sharing)

---

## Context for Development

### Architecture CORRIGÉE (basée sur docs officielles)

#### 1. Custom PersistenceKey pour GRDB

**Source:** [TCA SharingState - Custom Persistence](https://github.com/pointfreeco/swift-composable-architecture/blob/shared-state-beta/Sources/ComposableArchitecture/Documentation.docc/Articles/SharingState.md)

```swift
// SharedKeys.swift (NOUVEAU FICHIER)
import Sharing
import GRDB
import Dependencies

final class GRDBPersistenceKey<Value: Codable>: PersistenceKey {
  @Dependency(\.vehicleGRDBClient) var grdbClient

  func load(initialValue: Value?) -> Value? {
    // Load from GRDB
    try? grdbClient.fetchAll()
  }

  func save(_ value: Value) {
    // Save to GRDB via client
    Task {
      try? await grdbClient.syncAll(value)
    }
  }

  func subscribe(
    initialValue: Value?,
    didSet: @Sendable @escaping (Value?) -> Void
  ) -> Shared<Value>.Subscription {
    // Subscribe to ValueObservation
    let observation = ValueObservation.tracking { db in
      try VehicleRecord.fetchAll(db)
    }

    let cancellable = observation.start(
      in: grdbClient.database,
      onChange: { records in
        let vehicles = records.map { $0.toDomain() }
        didSet(vehicles as? Value)
      }
    )

    return Shared.Subscription {
      cancellable.cancel()
    }
  }
}

extension PersistenceReaderKey where Self == GRDBPersistenceKey<[Vehicle]> {
  static var vehicles: Self {
    GRDBPersistenceKey<[Vehicle]>()
  }
}
```

#### 2. ValueObservation pour observer GRDB

**Source:** [GRDB ValueObservation](https://groue.github.io/GRDB.swift/docs/5.20/Structs/ValueObservation.html)

```swift
// DatabaseManager.swift (MODIFIER)
import GRDB

actor DatabaseManager {
  private let dbQueue: DatabaseQueue

  func observeVehicles(
    onChange: @escaping ([VehicleRecord]) -> Void
  ) -> AnyCancellable {
    let observation = ValueObservation.tracking { db in
      try VehicleRecord.fetchAll(db)
    }

    return observation.start(
      in: dbQueue,
      onError: { error in
        print("❌ [DatabaseManager] ValueObservation error: \\(error)")
      },
      onChange: { records in
        print("🔄 [DatabaseManager] Vehicles changed: \\(records.count) vehicles")
        onChange(records)
      }
    )
  }
}
```

#### 3. Stores TCA avec @Shared custom persistence

```swift
// AddVehicleStore.swift (MIGRER)
@Reducer
struct AddVehicleStore {
  @ObservableState
  struct State {
    @Shared(.vehicles) var vehicles: [Vehicle] = []
    // @Shared utilise maintenant GRDBPersistenceKey
    // Observe automatiquement via ValueObservation
  }

  @Dependency(\.vehicleGRDBClient) var grdbClient
  @Dependency(\.uuid) var uuid

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      case .saveButtonTapped:
        let newVehicle = Vehicle(
          id: uuid().uuidString,
          brand: state.brand,
          model: state.model,
          // ...
        )

        return .run { send in
          // Write to GRDB via client
          try await grdbClient.create(newVehicle)

          // ValueObservation détecte changement
          // → @Shared updated automatiquement
          // → UI reactive automatiquement

          await send(.vehicleSaved)
        }
    }
  }
}
```

#### 4. JSON Export via ValueObservation onChange

```swift
// Dans GRDBPersistenceKey.subscribe()
let cancellable = observation.start(
  in: grdbClient.database,
  onChange: { records in
    // 1. Update @Shared
    let vehicles = records.map { $0.toDomain() }
    didSet(vehicles as? Value)

    // 2. Trigger JSON export automatiquement
    Task {
      for vehicle in vehicles {
        try? await VehicleMetadataSyncManager.shared.exportVehicleToJSON(
          vehicleId: vehicle.id
        )
      }
    }
  }
)
```

---

## Implementation Plan

### ⚠️ AVANT DE COMMENCER (Prérequis critiques)

1. **Audit de l'architecture actuelle**
   - Lister TOUS les fichiers Repository existants avec chemins absolus
   - Compter EXACTEMENT combien de Stores utilisent `@Dependency(\.vehicleRepository)`
   - Vérifier que VehicleRepositoryClient, VehicleRepository, VehicleDatabaseRepository existent réellement
   - **Blocker** : Ne PAS continuer sans cette liste complète

2. **Proof of Concept obligatoire**
   - Créer mini-projet isolé validant :
     - Custom PersistenceKey avec GRDB
     - ValueObservation → @Shared update
     - JSON export depuis ValueObservation onChange sans deadlock actor
   - **Blocker** : Si POC échoue, revoir l'approche

3. **Stratégie de rollback**
   - Stratégie validée par utilisateur : git manual rollback
   - Créer feature branch : `feat/grdb-valueobservation-migration`
   - Commiter après chaque phase réussie
   - Si échec : `git reset --hard` ou suppression branche

---

### PHASE 1 : Custom PersistenceKey + ValueObservation (Fondations)

- [ ] **Task 1.1 : Créer GRDBPersistenceKey custom**
  - File: `Holfy/Shared/SharedKeys.swift` (nouveau)
  - Action: Implémenter `PersistenceKey` protocol avec `load()`, `save()`, `subscribe()`
  - Notes: `subscribe()` utilise `ValueObservation.tracking { }` (GRDB pattern officiel)
  - **Dépendance POC** : Valider d'abord dans projet isolé

- [ ] **Task 1.2 : Créer VehicleGRDBClient simplifié**
  - File: `Holfy/Data/Database/Clients/VehicleGRDBClient.swift` (nouveau)
  - Action: Consolider CRUD de VehicleDatabaseRepository dans un client simple
  - Notes: Pas d'orchestration, juste queries GRDB + dependency injection

- [ ] **Task 1.3 : Implémenter ValueObservation dans DatabaseManager**
  - File: `Holfy/Data/Database/DatabaseManager.swift`
  - Action: Méthode `observeVehicles(onChange:)` retournant AnyCancellable
  - Notes: Utiliser `ValueObservation.tracking { try VehicleRecord.fetchAll(db) }`

- [ ] **Task 1.4 : Refactorer VehicleMetadataSyncManager pour ValueObservation**
  - File: `Holfy/Data/Database/VehicleMetadataSyncManager.swift`
  - Action: Rendre `exportVehicleToJSON()` appelable depuis ValueObservation onChange (résoudre actor isolation)
  - Notes: Peut nécessiter conversion en class (non-actor) ou utilisation de Task detached

- [ ] **Task 1.5 : Tests unitaires GRDBPersistenceKey**
  - File: `HolfyTests/Shared/SharedKeys_Spec.swift` (nouveau)
  - Action: Tester load(), save(), subscribe() avec base `:memory:`
  - Notes: Vérifier que ValueObservation trigger didSet callback

- [ ] **Task 1.6 : Tests unitaires ValueObservation**
  - File: `HolfyTests/Data/Database/DatabaseManager_ValueObservation_Spec.swift` (nouveau)
  - Action: Tester qu'INSERT/UPDATE/DELETE trigger onChange
  - Notes: Base `:memory:`, async/await patterns

- [ ] **Task 1.7 : Migrer AddVehicleStore (MVP single store)**
  - File: `Holfy/Stores/AddVehicleStore/AddVehicleStore.swift`
  - Action: Remplacer `@Dependency(\.vehicleRepository)` par `.run { await grdbClient.create() }`
  - Notes: `@Shared(.vehicles)` observe automatiquement via GRDBPersistenceKey

- [ ] **Task 1.8 : Tests AddVehicleStore avec @Shared(GRDB)**
  - File: `HolfyTests/Stores/AddVehicleStore_Spec.swift`
  - Action: Adapter tests pour mock `grdbClient`, vérifier @Shared update
  - Notes: Pattern TCA TestStore + `withDependencies { }`

- [ ] **Task 1.9 : Tests end-to-end Phase 1 (single store)**
  - File: `HolfyTests/Integration/GRDB_ValueObservation_EndToEnd_Spec.swift` (nouveau)
  - Action: Test complet : action Store → grdbClient.create() → ValueObservation → @Shared update → JSON export
  - Notes: Valider cycle complet sans perte de données

**🛑 CHECKPOINT PHASE 1** : Valider que AddVehicleStore + ValueObservation + JSON export fonctionnent avant de continuer

---

### PHASE 2 : Migration Autres Stores (si Phase 1 réussit)

- [ ] **Task 2.1 : Auditer TOUS les Stores restants**
  - Action: Lister fichiers Swift dans `/Stores/` avec `grep "@Dependency(\.vehicleRepository)"`
  - Notes: Créer liste exhaustive avec chemins absolus

- [ ] **Task 2.2 : Migrer EditVehicleStore**
  - File: `Holfy/Stores/EditVehicleStore/EditVehicleStore.swift`
  - Action: Pattern identique Task 1.7

- [ ] **Task 2.3 : Migrer VehiclesListStore**
  - File: `Holfy/Stores/VehiclesListStore/VehiclesListStore.swift`
  - Action: Lecture directe de `@Shared(.vehicles)`, tri dans computed property

- [ ] **Task 2.4 : Migrer VehicleDetailsStore**
  - File: `Holfy/Stores/VehicleDetailsStore/VehicleDetailsStore.swift`
  - Action: Lecture `vehicles.first(where: { $0.id == id })`

- [ ] **Task 2.5 : Migrer MainStore**
  - File: `Holfy/Stores/MainStore/MainStore.swift`
  - Action: Vérifier propagation @Shared aux child stores

- [ ] **Task 2.6 : Migrer Stores restants (selon audit Task 2.1)**
  - Files: Liste exhaustive de Task 2.1
  - Action: Appliquer pattern migration systématiquement

- [ ] **Task 2.7 : Tests de non-régression Phase 2**
  - Files: Adapter tous les tests existants
  - Action: Vérifier que TOUS les tests passent

**🛑 CHECKPOINT PHASE 2** : Build réussit + tests passent avant Phase 3

---

### PHASE 3 : Documents + Cleanup Final

- [ ] **Task 3.1 : Étendre GRDBPersistenceKey pour Documents**
  - File: `Holfy/Shared/SharedKeys.swift`
  - Action: Ajouter `.documents` custom PersistenceKey (si nécessaire)
  - Notes: Gérer foreign keys Vehicle → Documents dans ValueObservation

- [ ] **Task 3.2 : Migrer Stores Documents**
  - Files: `AddDocumentStore`, `EditDocumentStore`, `DocumentDetailStore`
  - Action: Pattern identique Stores Vehicle

- [ ] **Task 3.3 : Supprimer VehicleRepositoryClient (si existe)**
  - File: `Holfy/Data/Repositories/VehicleRepository/VehicleRepositoryClient.swift`
  - Action: **SUPPRIMER** si plus utilisé

- [ ] **Task 3.4 : Supprimer VehicleRepository wrapper (si existe)**
  - File: `Holfy/Data/Repositories/VehicleRepository/VehicleRepository.swift`
  - Action: **SUPPRIMER** orchestrateur

- [ ] **Task 3.5 : Supprimer VehicleDatabaseRepository (si migration complète)**
  - File: `Holfy/Data/Repositories/VehicleDatabase/VehicleDatabaseRepository.swift`
  - Action: **SUPPRIMER** si VehicleGRDBClient le remplace

- [ ] **Task 3.6 : Audit final**
  - Action: `grep -r "@Dependency(\.vehicleRepository)" Holfy/` → 0 résultats
  - Notes: Vérifier aucune référence restante

- [ ] **Task 3.7 : Build & Tests complets**
  - Action: `xcodebuild build && xcodebuild test`
  - Notes: 0 failures, 0 warnings critiques

- [ ] **Task 3.8 : Tests de rollback et error handling**
  - File: `HolfyTests/Integration/GRDB_Rollback_Spec.swift`
  - Action: Vérifier que write GRDB échoué ne trigger PAS JSON export
  - Notes: Simuler SQL errors (contrainte unique, etc.)

- [ ] **Task 3.9 : Documentation technique**
  - File: `Documentation/ARCHITECTURE_GRDB_VALUEOBSERVATION.md` (nouveau)
  - Action: Documenter custom PersistenceKey + ValueObservation pattern
  - Notes: Exemples pour futures entités

- [ ] **Task 3.10 : Update CLAUDE.md**
  - File: `CLAUDE.md`
  - Action: Supprimer mentions de Repository pattern, ajouter patterns @Shared + ValueObservation
  - Notes: **IMPORTANT** : À faire en Phase 1 (F19), pas Phase 3

---

## Acceptance Criteria

**Phase 1 (MVP single store) :**

- [ ] **AC 1.1** : Étant donné AddVehicleStore, quand je dispatch `.saveButtonTapped`, alors `grdbClient.create()` est appelé et ValueObservation détecte le changement
- [ ] **AC 1.2** : Étant donné un write GRDB réussi, quand ValueObservation onChange trigger, alors `@Shared(.vehicles)` est mis à jour automatiquement
- [ ] **AC 1.3** : Étant donné @Shared update, quand la valeur change, alors `.vehicle_metadata.json` est exporté automatiquement
- [ ] **AC 1.4** : Étant donné un write GRDB échoué, quand la transaction rollback, alors ValueObservation ne trigger PAS et pas d'export JSON
- [ ] **AC 1.5** : Étant donné le POC validé, quand implémenté dans l'app réelle, alors aucun deadlock actor ni crash observé

**Phase 2 (migration complète Stores) :**

- [ ] **AC 2.1** : Étant donné l'audit complet, quand je grep `@Dependency(\.vehicleRepository)`, alors seuls les Stores non migrés apparaissent
- [ ] **AC 2.2** : Étant donné tous les Stores migrés, quand je lance `xcodebuild build`, alors le build réussit sans erreurs
- [ ] **AC 2.3** : Étant donné tous les tests adaptés, quand je lance `xcodebuild test`, alors tous les tests passent (0 failures)

**Phase 3 (cleanup + validation) :**

- [ ] **AC 3.1** : Étant donné la migration Documents, quand un document est ajouté, alors le JSON du véhicule parent est mis à jour
- [ ] **AC 3.2** : Étant donné les fichiers Repository supprimés, quand je compile, alors aucune erreur de référence manquante
- [ ] **AC 3.3** : Étant donné le test end-to-end complet, quand j'exécute le cycle (action → GRDB → ValueObservation → JSON → import JSON), alors les données sont identiques (vérifié par checksum ou comparaison sémantique)
- [ ] **AC 3.4** : Étant donné la documentation créée, quand un développeur lit `ARCHITECTURE_GRDB_VALUEOBSERVATION.md`, alors il peut implémenter une nouvelle entité avec le même pattern

---

## Additional Context

### Dependencies

**Packages Swift requis :**
- `pointfreeco/swift-composable-architecture` (1.22.2+) - TCA ✅
- `pointfreeco/swift-sharing` (pour @Shared + custom PersistenceKey) ✅
- `groue/GRDB.swift` (7.9.0+) - GRDB + ValueObservation ✅
- `pointfreeco/swift-dependencies` - Injection de dépendances ✅

**⚠️ NE PAS utiliser :**
- ~~`pointfreeco/sharing-grdb`~~ - Package archivé, renommé en SQLiteData
- ~~`pointfreeco/sqlite-data`~~ - Différent de notre approche (utilise @FetchAll/@FetchOne)

### Testing Strategy

**Tests unitaires critiques :**
1. GRDBPersistenceKey : load(), save(), subscribe()
2. ValueObservation : détection INSERT/UPDATE/DELETE
3. Stores TCA : mutations → grdbClient → @Shared update
4. Actor isolation : pas de deadlock VehicleMetadataSyncManager
5. JSON export : trigger automatique via ValueObservation onChange

**Tests d'intégration :**
6. End-to-end : action Store → GRDB → ValueObservation → @Shared → JSON
7. Rollback : write GRDB fail → pas d'export JSON
8. Foreign keys : Documents → Vehicle cascade
9. Concurrence : mutations @Shared simultanées

**Convention tests :**
- Pattern Given-When-Then
- Base `:memory:`
- Extension `.make()` pour fixtures
- TestStore + `withDependencies { }`

### Notes

**Points d'attention critiques :**

1. **POC obligatoire avant Phase 1**
   - Custom PersistenceKey avec GRDB est complexe
   - ValueObservation + actor isolation peut causer deadlock
   - Valider dans projet isolé d'abord

2. **Rollback strategy (F6 résolu)**
   - Utilisateur gère manuellement via git
   - Feature branch + commits incrémentaux
   - Si échec : `git reset --hard` ou suppression branche

3. **Architecture clarifiée (F2 résolu)**
   - @Shared n'élimine PAS le repository/client
   - Custom PersistenceKey nécessite toujours queries GRDB
   - ValueObservation observe les changements → update @Shared

4. **Système JSON critique**
   - Format `.vehicle_metadata.json` inchangé (backward compatibility)
   - Export automatique via ValueObservation onChange
   - Utilisateurs comptent sur backup iCloud/Dropbox

**Risques avec mitigation :**

| Risque | Impact | Mitigation |
| ------ | ------ | ---------- |
| **POC échoue** | CRITIQUE - Approche invalide | POC obligatoire avant Phase 1, revoir si échec |
| **Actor deadlock** | HAUT - App freeze | Tests exhaustifs actor isolation, Task detached si nécessaire |
| **ValueObservation perf** | MOYEN - UI lag | Debouncing si nécessaire, tests performance |
| **Migration incomplète** | HAUT - Stores oubliés | Audit systématique Task 2.1, grep pour valider |
| **Perte données JSON** | CRITIQUE - Backup cassé | Tests end-to-end AC 3.3, checksum validation |

**Ressources officielles consultées :**
- [Swift Sharing - Custom Persistence](https://github.com/pointfreeco/swift-sharing/blob/main/README.md)
- [TCA SharingState Documentation](https://github.com/pointfreeco/swift-composable-architecture/blob/shared-state-beta/Sources/ComposableArchitecture/Documentation.docc/Articles/SharingState.md)
- [GRDB ValueObservation](https://groue.github.io/GRDB.swift/docs/5.20/Structs/ValueObservation.html)
- [SQLiteData (ex-sharing-grdb)](https://github.com/pointfreeco/sqlite-data)

**Prochaines étapes après migration :**
1. Dashboard Principal Enrichi (wireframes créés)
2. Custom Segmented Control 5 Onglets
3. EventKit Reminders Integration
4. Stats Multi-Niveaux Level 1
