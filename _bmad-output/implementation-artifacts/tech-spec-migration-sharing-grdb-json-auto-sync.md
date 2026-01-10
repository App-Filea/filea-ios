---
title: 'Migration Sharing-GRDB + JSON Backup Auto-Sync'
slug: 'migration-sharing-grdb-json-auto-sync'
created: '2026-01-10'
status: 'ready-for-dev'
stepsCompleted: [1, 2, 3, 4]
tech_stack:
  - 'Swift 6'
  - 'SwiftUI'
  - 'TCA (Composable Architecture 1.22.2+)'
  - 'Sharing-GRDB (0.7.0+)'
  - 'GRDB (via Sharing-GRDB)'
  - 'Swift Dependencies'
  - 'Actor isolation'
  - 'Combine'
files_to_modify:
  - 'VehicleRepositoryClient.swift (SUPPRIMER)'
  - 'VehicleRepository.swift (SUPPRIMER)'
  - 'VehicleDatabaseRepository.swift (SUPPRIMER)'
  - 'RepositoryDependencies.swift (SUPPRIMER)'
  - 'DatabaseManager.swift (MODIFIER - hook after write)'
  - 'VehicleMetadataSyncManager.swift (MODIFIER - refactor pour hook)'
  - 'AddVehicleStore.swift (MIGRER)'
  - 'EditVehicleStore.swift (MIGRER)'
  - 'VehiclesListStore.swift (MIGRER)'
  - 'VehicleDetailsStore.swift (MIGRER)'
  - 'MainStore.swift (MIGRER)'
  - '+ 21 autres Stores à migrer'
code_patterns:
  - 'Actor isolation pour thread-safety'
  - '@Dependency pattern : struct + closures @Sendable'
  - '@Shared(.vehicles) pour state réactif local'
  - 'GRDB StructuredQueries : .where { $0.id.in([id]) }'
  - 'GRDB Write : VehicleRecord.insert { record }.execute(db)'
  - 'GRDB Upsert : VehicleRecord.upsert { record }.execute(db)'
  - 'Manual JSON sync : syncManager.syncAfterChange(vehicleId)'
  - 'TCA Reducer pattern avec .run effects'
  - '@Table macro pour GRDB records'
  - 'Repository 3-layer : Client → Wrapper → Implementation'
test_patterns:
  - 'Given-When-Then avec helpers privés'
  - 'Base de données en mémoire : :memory:'
  - 'Fixtures avec .make() extensions'
  - 'TestStore pour tests TCA'
  - 'UUID.incrementing pour tests déterministes'
  - 'Mock dependencies avec withDependencies { }'
  - 'Assertions XCTest avec messages descriptifs'
  - 'Tests async/await avec async throws'
---

# Tech-Spec: Migration Sharing-GRDB + JSON Backup Auto-Sync

**Created:** 2026-01-10

## Overview

### Problem Statement

L'architecture actuelle utilise une couche Repository intermédiaire entre TCA Stores et GRDB, ce qui crée de la complexité inutile et des appels manuels pour maintenir la synchronisation GRDB ↔ JSON. Les Stores doivent explicitement appeler des repositories qui eux-mêmes appellent le SyncManager pour exporter le JSON, créant un risque de désynchronisation.

**Exemples de complexité actuelle :**
- Les Stores utilisent `@Shared` pour le state local + `@Dependency(\.vehicleRepository)` pour les opérations CRUD
- Appels manuels : `try await vehicleRepository.create(vehicle)` → `syncManager.exportVehicleToJSON()`
- Risque d'oubli : Si un Store oublie d'appeler le sync, le JSON est obsolète
- 26 Stores utilisent déjà `@Shared` mais avec une architecture hybride inefficace

### Solution

Migrer vers Sharing-GRDB où `@Shared` se connecte directement à GRDB, éliminant la couche Repository. Implémenter un hook GRDB (after write) qui trigger automatiquement l'export JSON UNIQUEMENT si le write GRDB réussit, garantissant que la BDD reste la source de vérité.

**Architecture cible :**
```
User Action → @Shared mutation → GRDB write (automatic)
                                       ↓ (success)
                              Hook GRDB after write
                                       ↓
                        SyncManager.exportVehicleToJSON()
```

**Bénéfices :**
- Suppression de toute la couche Repository (simplification majeure)
- Réactivité automatique : mutation @Shared → UI update instantané
- Sync JSON garanti : impossible d'oublier, trigger automatique après succès GRDB
- Moins de code : ~30% de réduction (suppression repos + simplification Stores)

### Scope

**In Scope:**
- Migration progressive en 3 phases :
  - **Phase 1** : Vehicle (entité principale) - Migration @Shared(.vehicles) + hook GRDB + suppression VehicleDatabaseRepository + migration Stores Vehicle
  - **Phase 2** : Documents (dépend de Vehicle) - Migration @Shared(.documents) + extension hook + suppression repo Documents
  - **Phase 3** : Cleanup final - Suppression reste repos + tests bout-en-bout
- Remplacement Repository Layer par @Shared + Sharing-GRDB
- Hook GRDB automatique pour sync JSON après succès write
- Migration de tous les Stores Vehicle (AddVehicle, EditVehicle, VehiclesList, VehicleDetails, MainStore, etc.)
- Tests de non-régression CRUD + JSON sync
- Conservation du système JSON backup pour portabilité (.vehicle_metadata.json)

**Out of Scope:**
- Migration Big Bang (on fait progressif pour sécurité)
- Modification du format JSON existant (on garde VehicleMetadataFile structure)
- Nouvelles features (Dashboard Enrichi, Custom Segmented Control, EventKit Reminders) - elles viendront APRÈS cette migration technique
- Import JSON initial au premier lancement (déjà fonctionnel, on ne touche pas)
- Migration de l'UI/UX (pas de changement visuel pour l'utilisateur)

## Context for Development

### Codebase Patterns

**Architecture actuelle (AVANT migration) - 3 Couches :**

L'investigation a révélé une architecture complexe à 3 couches :

1. **VehicleRepositoryClient (Interface TCA)**
   - Struct avec closures @Sendable (Swift 6 compliant)
   - Définit les opérations : `createVehicle`, `updateVehicle`, `deleteVehicle`, etc.
   - Extension `DependencyKey` avec `liveValue`, `testValue`, `previewValue`
   - Utilisé dans les Stores via `@Dependency(\.vehicleRepository)`

2. **VehicleRepository (Actor Wrapper/Orchestrateur)**
   - Orchestre 4 dépendances :
     - `@Dependency(\.vehicleDatabaseRepository)` - GRDB repo
     - `@Dependency(\.syncManagerClient)` - SyncManager
     - `@Dependency(\.storageManager)` - Gestion système de fichiers
     - `@Dependency(\.fileVehicleRepository)` - Legacy file repo (deprecated)
   - **Appels manuels au sync** : `try await syncManager.syncAfterChange(vehicle.id)` ❌
   - Logique métier : création folderPath, gestion isPrimary

3. **VehicleDatabaseRepository (Actor Implementation GRDB)**
   - Implémentation réelle des opérations CRUD
   - Accès direct à `DatabaseManager`
   - Utilise StructuredQueries GRDB

**Code actuel dans les Stores TCA :**
```swift
// Stores TCA
@Shared(.vehicles) var vehicles  // State local uniquement
@Dependency(\.vehicleRepository) var vehicleRepository

case .saveButtonTapped:
    return .run { [vehicle] send in
        try await vehicleRepository.create(vehicle: vehicle, folderPath: path)
        // Repository appelle manuellement SyncManager
        await send(.vehicleSaved)
    }
```

**Code actuel dans VehicleRepository (wrapper) :**
```swift
func createVehicle(_ vehicle: Vehicle) async throws {
    let folderPath = /* compute path */

    // 1. Write to GRDB
    try await grdbRepo.create(vehicle, folderPath)

    // 2. ❌ MANUEL sync JSON - risque d'oubli
    try await syncManager.syncAfterChange(vehicle.id)

    // 3. Create folder on disk
    try await storageManager.createVehicleFolder(folderName)

    // 4. Legacy file repo (deprecated)
    try await fileRepo.save(vehicle)
}
```

**Architecture cible (APRÈS migration) :**
```swift
// Stores TCA simplifié
@Shared(.vehicles) var vehicles  // Connecté directement à GRDB via Sharing-GRDB

case .saveButtonTapped:
    $vehicles.withLock { vehicles in
        vehicles.append(newVehicle)
    }
    // → GRDB write automatique
    // → Hook GRDB trigger export JSON automatiquement
    // → UI reactivity automatique
    return .none
```

**Patterns GRDB actuels :**
- Records : `VehicleRecord`, `FileMetadataRecord` avec macro `@Table`
- Queries : StructuredQueries type-safe (ex: `VehicleRecord.where { $0.id.in([id]) }.fetchOne(db)`)
- Transactions : `database.write { db in ... }` et `database.read { db in ... }`

**Patterns JSON Sync actuels :**
- Export manuel après chaque write : `VehicleMetadataSyncManager.exportVehicleToJSON(vehicleId)`
- Format : `.vehicle_metadata.json` avec structure `VehicleMetadataFile(vehicle: VehicleDTO, files: [FileMetadataDTO], metadata: MetadataInfo)`
- Emplacement : `/{folderPath}/.vehicle_metadata.json`

### Files to Reference

**Architecture Layer - À SUPPRIMER (3 fichiers) :**

| File | Purpose | Lignes | Action |
| ---- | ------- | ------ | ------ |
| `Holfy/Data/Repositories/VehicleRepository/VehicleRepositoryClient.swift` | Interface TCA - struct avec closures @Sendable | 120 | **SUPPRIMER** |
| `Holfy/Data/Repositories/VehicleRepository/VehicleRepository.swift` | Actor wrapper/orchestrateur - 4 dépendances | 124 | **SUPPRIMER** |
| `Holfy/Data/Repositories/VehicleDatabase/VehicleDatabaseRepository.swift` | Implementation GRDB - CRUD réel | 122 | **SUPPRIMER** |
| `Holfy/Data/Repositories/RepositoryDependencies.swift` | Enregistrement dépendances | ? | **SUPPRIMER** |

**GRDB Layer - À MODIFIER (2 fichiers) :**

| File | Purpose | Lignes | Action |
| ---- | ------- | ------ | ------ |
| `Holfy/Data/Database/DatabaseManager.swift` | Manager GRDB - DatabaseQueue + migrations | 132 | **MODIFIER** - Ajout hook after write |
| `Holfy/Data/Database/VehicleMetadataSyncManager.swift` | SyncManager GRDB ↔ JSON | 260 | **MODIFIER** - Refactor pour hook automatique |

**Records & Models - RÉFÉRENCE (pas de modif structure) :**

| File | Purpose | Lignes | Action |
| ---- | ------- | ------ | ------ |
| `Holfy/Data/Database/Records/VehicleRecord.swift` | @Table struct GRDB | 51 | **RÉFÉRENCE** - Structure inchangée |
| `Holfy/Data/Database/Records/FileMetadataRecord.swift` | @Table struct GRDB (Phase 2) | ? | **RÉFÉRENCE** |
| `Holfy/Data/Models/Vehicle.swift` | Domain model métier | ? | **RÉFÉRENCE** |
| `Holfy/Data/Database/DTOs/VehicleDTO.swift` | DTO pour JSON Codable | ? | **RÉFÉRENCE** |
| `Holfy/Data/Database/Mappers/VehicleMappers.swift` | Conversions Record ↔ Domain ↔ DTO | ? | **RÉFÉRENCE** (simplification possible) |

**Stores TCA - À MIGRER (26 fichiers) :**

| File | Purpose | Action |
| ---- | ------- | ------ |
| `Holfy/Stores/AddVehicleStore/AddVehicleStore.swift` | Ajout véhicule | **MIGRER** - Supprimer @Dependency(\.vehicleRepository) |
| `Holfy/Stores/EditVehicleStore/EditVehicleStore.swift` | Édition véhicule | **MIGRER** |
| `Holfy/Stores/VehiclesListStore/VehiclesListStore.swift` | Liste véhicules | **MIGRER** |
| `Holfy/Stores/VehicleDetailsStore/VehicleDetailsStore.swift` | Détails véhicule | **MIGRER** |
| `Holfy/Stores/MainStore/MainStore.swift` | Store principal avec navigation | **MIGRER** |
| `+ 21 autres Stores` | Divers stores utilisant vehicleRepository | **MIGRER** |

### Technical Decisions

**Decision 1 : Hook GRDB (Option B validée)**
- **Décision** : Utiliser hook GRDB (after INSERT/UPDATE) pour trigger export JSON
- **Raison** : BDD = source de vérité. JSON update UNIQUEMENT si write GRDB succeed
- **Alternative rejetée** : Observer @Shared (Option A) - risque d'export JSON même si write GRDB échoue

**Decision 2 : Migration Progressive (Option A validée)**
- **Décision** : Migrer par phases (Vehicle → Documents → Cleanup)
- **Raison** :
  - Changement architectural majeur avec 26 Stores à migrer
  - Validation incrémentale + rollback possible
  - Confiance progressive (Vehicle = 60% du travail)
- **Alternative rejetée** : Big Bang (Option B) - trop risqué

**Decision 3 : Conservation du format JSON actuel**
- **Décision** : Garder structure `VehicleMetadataFile` et `.vehicle_metadata.json`
- **Raison** : Compatibilité backward, portabilité existante, pas d'impact utilisateur

**Decision 4 : Utilisation de Sharing-GRDB**
- **Décision** : Utiliser Point-Free Sharing-GRDB pour connecter @Shared à GRDB
- **Raison** : Solution officielle, bien testée, intégration native avec TCA
- **Dépendance** : `pointfreeco/sharing-grdb` version 0.7.0+

## Implementation Plan

### Tasks

**Migration progressive en 3 phases pour minimiser les risques.**

#### PHASE 1 : Migration Vehicle + Hook GRDB (Fondations)

- [ ] **Task 1.1 : Configurer Sharing-GRDB pour Vehicle**
  - File: `Holfy/Data/Database/DatabaseManager.swift`
  - Action: Importer `import SharingGRDB` et configurer le `SharedKey` pour `.vehicles`
  - Notes: Utiliser `SharingGRDB.shared(VehicleRecord.self, .vehicles)` pour connecter @Shared à GRDB

- [ ] **Task 1.2 : Implémenter le hook GRDB after write**
  - File: `Holfy/Data/Database/DatabaseManager.swift`
  - Action: Ajouter `configuration.prepareDatabase { db in db.afterNextTransaction { ... } }`
  - Notes: Hook doit détecter les changements sur `VehicleRecord` et trigger `VehicleMetadataSyncManager.exportVehicleToJSON()`

- [ ] **Task 1.3 : Refactorer VehicleMetadataSyncManager pour le hook**
  - File: `Holfy/Data/Database/VehicleMetadataSyncManager.swift`
  - Action: Rendre `exportVehicleToJSON()` appelable depuis le hook GRDB (pas d'actor isolation blocking)
  - Notes: Supprimer `syncAfterChange()` une fois le hook en place

- [ ] **Task 1.4 : Ajouter tests du hook GRDB**
  - File: `HolfyTests/Data/Database/DatabaseManager_Hook_Spec.swift` (nouveau)
  - Action: Créer suite de tests vérifiant que INSERT/UPDATE/DELETE trigger automatiquement JSON export
  - Notes: Tests avec base `:memory:`, vérifier que JSON n'est exporté QUE si write GRDB succeed

- [ ] **Task 1.5 : Migrer AddVehicleStore vers @Shared direct**
  - File: `Holfy/Stores/AddVehicleStore/AddVehicleStore.swift`
  - Action: Supprimer `@Dependency(\.vehicleRepository)`, utiliser `$vehicles.withLock { }` pour mutations
  - Notes: Plus besoin de `.run` effect, mutation synchrone avec réactivité automatique

- [ ] **Task 1.6 : Migrer EditVehicleStore vers @Shared direct**
  - File: `Holfy/Stores/EditVehicleStore/EditVehicleStore.swift`
  - Action: Supprimer `@Dependency(\.vehicleRepository)`, utiliser `$vehicles.withLock { }` pour update
  - Notes: Logique isPrimary doit être migrée dans le reducer

- [ ] **Task 1.7 : Migrer VehiclesListStore vers @Shared direct**
  - File: `Holfy/Stores/VehiclesListStore/VehiclesListStore.swift`
  - Action: Supprimer `@Dependency(\.vehicleRepository)`, lecture directe de `vehicles`
  - Notes: Le tri (isPrimary first, puis brand) doit être dans un computed property ou dans le reducer

- [ ] **Task 1.8 : Migrer VehicleDetailsStore vers @Shared direct**
  - File: `Holfy/Stores/VehicleDetailsStore/VehicleDetailsStore.swift`
  - Action: Supprimer `@Dependency(\.vehicleRepository)`, lecture directe de `vehicles`
  - Notes: Récupération d'un véhicule par ID via `vehicles.first(where: { $0.id == id })`

- [ ] **Task 1.9 : Migrer MainStore vers @Shared direct**
  - File: `Holfy/Stores/MainStore/MainStore.swift`
  - Action: Supprimer `@Dependency(\.vehicleRepository)`, utiliser `@Shared(.vehicles)`
  - Notes: MainStore contient des child stores, vérifier propagation du @Shared

- [ ] **Task 1.10 : Migrer les 21 autres Stores restants**
  - Files: Tous les Stores utilisant `@Dependency(\.vehicleRepository)`
  - Action: Appliquer le pattern : supprimer dependency, utiliser `$vehicles.withLock` pour mutations
  - Notes: Utiliser `grep -r "@Dependency(\.vehicleRepository)" Holfy/Stores/` pour identifier tous les Stores

- [ ] **Task 1.11 : Supprimer VehicleRepositoryClient**
  - File: `Holfy/Data/Repositories/VehicleRepository/VehicleRepositoryClient.swift`
  - Action: **SUPPRIMER** le fichier complet
  - Notes: Plus nécessaire, @Shared remplace l'interface

- [ ] **Task 1.12 : Supprimer VehicleRepository wrapper**
  - File: `Holfy/Data/Repositories/VehicleRepository/VehicleRepository.swift`
  - Action: **SUPPRIMER** le fichier complet
  - Notes: Plus d'orchestration nécessaire, hook GRDB gère le sync automatiquement

- [ ] **Task 1.13 : Supprimer VehicleDatabaseRepository**
  - File: `Holfy/Data/Repositories/VehicleDatabase/VehicleDatabaseRepository.swift`
  - Action: **SUPPRIMER** le fichier complet
  - Notes: Sharing-GRDB gère le CRUD directement

- [ ] **Task 1.14 : Nettoyer RepositoryDependencies**
  - File: `Holfy/Data/Repositories/RepositoryDependencies.swift`
  - Action: Supprimer les enregistrements de `vehicleRepository`, `vehicleDatabaseRepository`
  - Notes: Si le fichier devient vide, le supprimer

- [ ] **Task 1.15 : Tests de non-régression CRUD Vehicle**
  - File: `HolfyTests/Stores/AddVehicleStore_Spec.swift` (update)
  - Action: Adapter tests existants pour vérifier mutations @Shared + hook GRDB
  - Notes: Vérifier que `$vehicles.withLock` + hook GRDB = même comportement qu'avant

- [ ] **Task 1.16 : Tests bout-en-bout Phase 1**
  - File: `HolfyTests/Integration/VehicleMigration_EndToEnd_Spec.swift` (nouveau)
  - Action: Test complet : mutation @Shared → GRDB → JSON export → import JSON → rebuild BDD
  - Notes: Valider que le cycle complet fonctionne sans perte de données

#### PHASE 2 : Migration Documents (Extension du système)

- [ ] **Task 2.1 : Configurer Sharing-GRDB pour Documents**
  - File: `Holfy/Data/Database/DatabaseManager.swift`
  - Action: Ajouter `SharedKey` pour `.documents` si nécessaire
  - Notes: Documents dépendent de Vehicle (foreign key), vérifier cascade

- [ ] **Task 2.2 : Étendre le hook GRDB pour FileMetadataRecord**
  - File: `Holfy/Data/Database/DatabaseManager.swift`
  - Action: Hook doit aussi écouter les changements sur `FileMetadataRecord`
  - Notes: Export JSON doit inclure les documents du véhicule concerné

- [ ] **Task 2.3 : Migrer les Stores Documents vers @Shared**
  - Files: `AddDocumentStore.swift`, `EditDocumentStore.swift`, `DocumentDetailStore.swift`
  - Action: Supprimer `@Dependency(\.documentRepository)`, utiliser `@Shared(.documents)`
  - Notes: Mutation de documents doit aussi trigger update du vehicle parent dans JSON

- [ ] **Task 2.4 : Supprimer DocumentRepository layers**
  - Files: `DocumentRepositoryClient.swift`, `DocumentRepository.swift`, `DocumentDatabaseRepository.swift`
  - Action: **SUPPRIMER** tous les fichiers
  - Notes: Même pattern que Vehicle

- [ ] **Task 2.5 : Tests de non-régression Documents**
  - File: `HolfyTests/Stores/AddDocumentStore_Spec.swift` (update)
  - Action: Adapter tests pour @Shared + hook GRDB
  - Notes: Vérifier que modification d'un document trigger bien JSON export du vehicle parent

#### PHASE 3 : Cleanup Final & Tests Bout-en-Bout

- [ ] **Task 3.1 : Audit complet des Stores**
  - Action: Vérifier que TOUS les Stores ont été migrés (aucun `@Dependency(\.vehicleRepository)` restant)
  - Notes: Utiliser `grep -r "@Dependency(\.vehicleRepository)" Holfy/` pour validation

- [ ] **Task 3.2 : Supprimer legacy fileVehicleRepository**
  - File: `Holfy/Data/Repositories/FileVehicleRepository.swift` (si existe)
  - Action: **SUPPRIMER** le fichier (deprecated depuis migration GRDB)
  - Notes: Vérifié dans investigation que VehicleRepository l'utilisait avec try-catch silencieux

- [ ] **Task 3.3 : Nettoyer imports inutilisés**
  - Files: Tous les Stores migrés
  - Action: Supprimer `import Dependencies` si plus utilisé (seulement si @Shared uniquement)
  - Notes: Garder import si d'autres dependencies sont utilisées (ex: `\.uuid`)

- [ ] **Task 3.4 : Build & Tests complets**
  - Action: Lancer `xcodebuild build` et `xcodebuild test` pour vérifier aucune régression
  - Notes: Fix tous les warnings et erreurs de compilation

- [ ] **Task 3.5 : Tests de performance**
  - File: `HolfyTests/Performance/SharingGRDB_Performance_Spec.swift` (nouveau)
  - Action: Benchmarks pour vérifier que @Shared + hook n'ajoute pas de latence
  - Notes: Comparer avec baseline avant migration (si disponible)

- [ ] **Task 3.6 : Tests de rollback et error handling**
  - File: `HolfyTests/Integration/GRDB_Rollback_Spec.swift` (nouveau)
  - Action: Vérifier que si write GRDB échoue, pas d'export JSON + rollback transaction
  - Notes: Simuler erreurs SQL (contrainte unique, foreign key violation)

- [ ] **Task 3.7 : Documentation technique**
  - File: `Documentation/ARCHITECTURE_SHARING_GRDB.md` (nouveau)
  - Action: Documenter nouvelle architecture @Shared + hook GRDB
  - Notes: Patterns à suivre pour futures entités (ex: Statistics)

- [ ] **Task 3.8 : Update CLAUDE.md**
  - File: `CLAUDE.md`
  - Action: Mettre à jour avec nouvelle architecture (supprimer mentions de Repository pattern)
  - Notes: Ajouter exemples @Shared mutations et patterns de tests

### Acceptance Criteria

**Phase 1 - Vehicle + Hook GRDB :**

- [ ] **AC 1.1** : Étant donné un Store TCA, quand je mute `$vehicles.withLock { vehicles.append(newVehicle) }`, alors le véhicule est automatiquement sauvegardé en GRDB sans appel manuel au repository
- [ ] **AC 1.2** : Étant donné un write GRDB réussi sur VehicleRecord, quand le hook after write se déclenche, alors le fichier `.vehicle_metadata.json` est automatiquement exporté avec les données à jour
- [ ] **AC 1.3** : Étant donné un write GRDB échoué (ex: contrainte SQL violée), quand la transaction rollback, alors aucun export JSON n'est effectué
- [ ] **AC 1.4** : Étant donné 26 Stores utilisant `@Dependency(\.vehicleRepository)`, quand la migration est terminée, alors tous utilisent `@Shared(.vehicles)` et aucune référence au repository ne reste
- [ ] **AC 1.5** : Étant donné les 3 fichiers Repository (Client, Wrapper, Implementation), quand le cleanup est effectué, alors tous sont supprimés du projet et le build réussit
- [ ] **AC 1.6** : Étant donné un véhicule créé via @Shared, quand je lis le fichier `.vehicle_metadata.json`, alors la structure `VehicleMetadataFile` est identique au format précédent (backward compatibility)
- [ ] **AC 1.7** : Étant donné un test TCA avec `TestStore`, quand je mock `$vehicles.withLock`, alors les tests passent avec le pattern `withDependencies { dependencies.uuid = .incrementing }`

**Phase 2 - Documents :**

- [ ] **AC 2.1** : Étant donné un document ajouté à un véhicule via @Shared, quand le hook GRDB se déclenche, alors le JSON du véhicule parent est mis à jour avec le nouveau document
- [ ] **AC 2.2** : Étant donné un document supprimé via @Shared, quand le hook GRDB se déclenche, alors le JSON du véhicule parent reflète la suppression
- [ ] **AC 2.3** : Étant donné les Stores Documents (AddDocumentStore, EditDocumentStore), quand la migration est terminée, alors ils utilisent `@Shared(.documents)` sans repository

**Phase 3 - Cleanup & Validation :**

- [ ] **AC 3.1** : Étant donné l'audit complet du projet, quand je grep `@Dependency(\.vehicleRepository)`, alors aucun résultat n'est trouvé
- [ ] **AC 3.2** : Étant donné le legacy `fileVehicleRepository`, quand le cleanup est effectué, alors le fichier est supprimé et aucun Store ne l'utilise
- [ ] **AC 3.3** : Étant donné la suite de tests complète, quand je lance `xcodebuild test`, alors tous les tests passent (0 failures)
- [ ] **AC 3.4** : Étant donné un test de bout-en-bout (mutation @Shared → GRDB → JSON → import JSON → rebuild BDD), quand j'exécute le cycle complet, alors les données sont identiques avant/après (pas de perte de données)
- [ ] **AC 3.5** : Étant donné les tests de rollback, quand un write GRDB échoue, alors la transaction rollback ET aucun export JSON n'est effectué
- [ ] **AC 3.6** : Étant donné la documentation technique mise à jour, quand un développeur lit `ARCHITECTURE_SHARING_GRDB.md`, alors il comprend comment implémenter une nouvelle entité avec @Shared + hook GRDB

## Additional Context

### Dependencies

**Packages Swift existants :**
- `pointfreeco/swift-composable-architecture` (1.22.2+) - TCA
- `pointfreeco/sharing-grdb` (0.7.0+) - Sharing-GRDB ✅ Déjà présent
- `pointfreeco/swift-dependencies` - Injection de dépendances
- `supabase/supabase-swift` (2.5.1+) - Non utilisé actuellement

**Frameworks Apple :**
- SwiftUI, Combine, Foundation, GRDB (via Sharing-GRDB)

### Testing Strategy

**Tests Unitaires (Phase 1) :**

1. **DatabaseManager Hook Tests** (`DatabaseManager_Hook_Spec.swift`)
   - Test que INSERT sur VehicleRecord trigger hook GRDB
   - Test que UPDATE sur VehicleRecord trigger hook GRDB
   - Test que DELETE sur VehicleRecord trigger hook GRDB
   - Test que hook GRDB appelle `VehicleMetadataSyncManager.exportVehicleToJSON()`
   - Test que hook GRDB ne s'exécute PAS si transaction rollback

2. **VehicleMetadataSyncManager Tests** (mise à jour)
   - Test que `exportVehicleToJSON()` est callable depuis hook (pas d'actor deadlock)
   - Test que export JSON crée `.vehicle_metadata.json` avec structure correcte
   - Test que export JSON gère les erreurs de filesystem (permission denied, disk full)

3. **Stores TCA Tests** (mise à jour de tous les Stores migrés)
   - Test AddVehicleStore : mutation `$vehicles.withLock` sauvegarde en GRDB
   - Test EditVehicleStore : mutation `$vehicles.withLock` update en GRDB
   - Test VehiclesListStore : lecture de `vehicles` retourne la liste triée
   - Test VehicleDetailsStore : lecture de `vehicles.first(where:)` retourne le bon véhicule
   - Pattern : `TestStore` + `withDependencies { dependencies.uuid = .incrementing }`
   - Vérifier que mutations @Shared se produisent dans les bons blocs (`.send` vs `.receive`)

**Tests d'Intégration (Phase 1) :**

4. **End-to-End Tests** (`VehicleMigration_EndToEnd_Spec.swift`)
   - Test cycle complet : mutation @Shared → GRDB write → hook trigger → JSON export
   - Test import JSON → rebuild GRDB → vérifier identité des données
   - Test backward compatibility : JSON créé avec nouvelle architecture est lisible par ancien import

5. **Rollback & Error Handling Tests** (`GRDB_Rollback_Spec.swift`)
   - Test transaction rollback : si write échoue, pas d'export JSON
   - Test contrainte SQL violée (ex: unique constraint sur plate)
   - Test foreign key violation (si applicable)
   - Test que @Shared state est rollback si transaction échoue

**Tests de Performance (Phase 3) :**

6. **Performance Benchmarks** (`SharingGRDB_Performance_Spec.swift`)
   - Mesurer latence mutation @Shared vs ancien repository.create()
   - Mesurer temps d'export JSON (hook doit être rapide pour ne pas bloquer UI)
   - Mesurer mémoire utilisée par @Shared vs ancien pattern
   - Baseline : comparer avec performances avant migration

**Tests de Non-Régression (Phase 3) :**

7. **Regression Tests**
   - Tous les tests existants doivent passer après migration
   - Aucun test ne doit être supprimé (seulement adapté)
   - Vérifier que comportement utilisateur est identique (pas de changement visible)

**Convention de tests à suivre :**
- Pattern Given-When-Then avec helpers privés
- Helpers nommés : `givenX`, `whenX`, `thenX`
- Base de données en mémoire : `:memory:`
- Extension `.make()` pour fixtures (ex: `Vehicle.make(brand: "Tesla")`)
- Variables globales pour résultats (ex: `private var fetchedVehicle: Vehicle?`)
- Messages descriptifs dans assertions : `XCTAssertNotNil(vehicle, "Vehicle should exist in database")`
- Reset des variables dans `setUp()` et `tearDown()`

**Stratégie de Migration des Tests :**
1. Phase 1 : Adapter tests des 5 Stores principaux en premier (AddVehicle, EditVehicle, List, Details, Main)
2. Phase 1 : Créer tests hook GRDB et end-to-end
3. Phase 2 : Adapter tests Documents
4. Phase 3 : Lancer suite complète + tests de performance + audit

### Notes

**Points d'attention critiques :**

1. **Architecture Hybride Actuelle**
   - Les 26 Stores utilisent DÉJÀ `@Shared` mais uniquement pour l'état local (pas connecté à GRDB)
   - Actuellement : `@Shared(.vehicles)` + `@Dependency(\.vehicleRepository)` = duplication
   - Après migration : `@Shared(.vehicles)` connecté à GRDB = single source of truth

2. **Système JSON Critique**
   - Le système JSON `.vehicle_metadata.json` est CRITIQUE pour la portabilité
   - Utilisateurs comptent sur backup iCloud Drive / Dropbox du dossier racine
   - Format JSON doit rester identique (backward compatibility obligatoire)
   - Hook GRDB doit GARANTIR export JSON après succès write (validé par utilisateur)

3. **Migration Technique Invisible**
   - Aucun changement visuel pour l'utilisateur final
   - Migration purement technique (refactoring architectural)
   - Comportement de l'app doit être strictement identique avant/après

4. **Prérequis MVP**
   - Cette migration est un **prérequis obligatoire** pour les features V1 MVP :
     - Dashboard Principal Enrichi
     - Custom Segmented Control 5 Onglets
     - EventKit Reminders Integration
     - Stats Multi-Niveaux Level 1
   - Base technique saine nécessaire avant d'ajouter nouvelles features

**Risques identifiés et mitigation :**

| Risque | Impact | Probabilité | Mitigation |
| ------ | ------ | ----------- | ---------- |
| **Migration incomplète des 26 Stores** | HAUT - App crash ou comportement incohérent | MOYEN | Utiliser `grep -r "@Dependency(\.vehicleRepository)"` pour audit systématique (Task 3.1) |
| **Hook GRDB mal configuré** | HAUT - Boucle infinie ou deadlock | MOYEN | Tests unitaires exhaustifs du hook (Task 1.4), vérifier que hook ne trigger pas de write GRDB |
| **Actor isolation deadlock** | HAUT - App freeze | FAIBLE | `VehicleMetadataSyncManager` doit être refactoré pour être callable depuis hook sans actor blocking (Task 1.3) |
| **Perte de données JSON** | CRITIQUE - Perte backup utilisateur | FAIBLE | Tests end-to-end (Task 1.16) + tests backward compatibility |
| **Régression tests TCA** | MOYEN - Tests échouent après migration | ÉLEVÉ | Adapter tests progressivement (Task 1.15), utiliser pattern `$vehicles.withLock` dans assertions |
| **Performance dégradée** | MOYEN - Latence UI | FAIBLE | Benchmarks de performance (Task 3.5), vérifier que hook est rapide |
| **Rollback si échec GRDB non géré** | HAUT - Export JSON avec données invalides | MOYEN | Tests rollback (Task 3.6), vérifier que transaction rollback = pas d'export JSON |

**Considérations techniques :**

1. **Hook GRDB Implementation**
   - Utiliser `configuration.prepareDatabase { db in db.afterNextTransaction { ... } }` (GRDB standard)
   - Hook doit être idempotent (si appelé 2x, pas de side effect)
   - Hook ne doit PAS faire de write GRDB (risque de boucle infinie)
   - Hook doit être rapide (< 100ms) pour ne pas bloquer UI thread

2. **@Shared Persistence Strategy**
   - Sharing-GRDB connecte automatiquement @Shared à GRDB via `SharedKey`
   - Format : `@Shared(.vehicles)` où `.vehicles` est un `SharedKey<[Vehicle]>`
   - Mutations via `$vehicles.withLock { vehicles.append(newVehicle) }` trigger write GRDB
   - Réactivité SwiftUI automatique (pas besoin de `@Published`)

3. **Actor Isolation**
   - `VehicleDatabaseRepository` est un actor → thread-safe
   - `VehicleMetadataSyncManager` est un actor → attention deadlock avec hook
   - Solution : refactor `exportVehicleToJSON()` pour être callable sans actor context

4. **Legacy Code Cleanup**
   - `fileVehicleRepository` utilisé avec `try-catch` silencieux (deprecated)
   - `VehicleRepository` orchestre 4 dépendances (complexité inutile)
   - Supprimer progressivement après validation de chaque phase

5. **Backward Compatibility JSON**
   - Structure `VehicleMetadataFile` doit rester inchangée
   - Format : `{ "vehicle": { ... }, "files": [ ... ], "metadata": { "version": "1.0", ... } }`
   - Import JSON existant doit continuer de fonctionner après migration

**Prochaines étapes après migration :**
1. Dashboard Principal Enrichi (wireframes déjà créés)
2. Custom Segmented Control 5 Onglets
3. EventKit Reminders Integration
4. Stats Multi-Niveaux Level 1

**Ressources de référence :**
- [Sharing-GRDB Documentation](https://github.com/pointfreeco/sharing-grdb)
- [GRDB Hooks & Observers](https://github.com/groue/grdb.swift#database-changes-observation)
- [TCA @Shared Best Practices](https://github.com/pointfreeco/swift-composable-architecture/discussions)
- CLAUDE.md : Conventions de code et patterns existants
