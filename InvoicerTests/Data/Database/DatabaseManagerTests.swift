////
////  DatabaseManagerTests.swift
////  InvoicerTests
////
////  Created by Claude Code on 19/10/2025.
////
//
//import XCTest
//import GRDB
//import Dependencies
//@testable import Invoicer
//
///// Tests TDD pour DatabaseManager
///// Vérifie l'initialisation, la configuration, les migrations et les opérations de base de données
//final class DatabaseManagerTests: XCTestCase {
//
//    // MARK: - Properties
//
//    var tempDatabasePath: String!
//    var databaseManager: DatabaseManager!
//
//    // MARK: - Setup & Teardown
//
//    override func setUp() {
//        super.setUp()
//
//        // Créer un chemin temporaire unique pour chaque test
//        tempDatabasePath = NSTemporaryDirectory()
//            .appending("test_database_\(UUID().uuidString).db")
//
//        print("🧪 [DatabaseManagerTests] Setup avec base temporaire : \(tempDatabasePath!)")
//    }
//
//    override func tearDown() {
//        // Nettoyer la base de données temporaire
//        if let path = tempDatabasePath {
//            try? FileManager.default.removeItem(atPath: path)
//            print("🧹 [DatabaseManagerTests] Base temporaire supprimée")
//        }
//
//        databaseManager = nil
//        tempDatabasePath = nil
//
//        super.tearDown()
//    }
//
//    // MARK: - Initialization Tests
//
//    /// Test : Initialisation avec chemin par défaut (Application Support)
//    func test_initialisation_avec_chemin_par_defaut() async throws {
//        // WHEN : Initialisation sans paramètre
//        databaseManager = try DatabaseManager()
//
//        // THEN : La base de données est créée dans Application Support
//        let queue = await databaseManager.queue
//        XCTAssertNotNil(queue, "La DatabaseQueue doit être initialisée")
//
//        // Vérifier que le fichier existe
//        let fileManager = FileManager.default
//        let appSupportURL = try fileManager.url(
//            for: .applicationSupportDirectory,
//            in: .userDomainMask,
//            appropriateFor: nil,
//            create: false
//        )
//        let appDirectory = appSupportURL.appendingPathComponent("Invoicer", isDirectory: true)
//        let defaultDBPath = appDirectory.appendingPathComponent("invoicer.db").path
//
//        XCTAssertTrue(fileManager.fileExists(atPath: defaultDBPath),
//                     "Le fichier de base de données doit exister dans Application Support")
//
//        // Cleanup
//        try? fileManager.removeItem(atPath: appDirectory.path)
//    }
//
//    /// Test : Initialisation avec chemin personnalisé
//    func test_initialisation_avec_chemin_personnalise() async throws {
//        // GIVEN : Un chemin personnalisé
//        let customPath = tempDatabasePath!
//
//        // WHEN : Initialisation avec ce chemin
//        databaseManager = try DatabaseManager(databasePath: customPath)
//
//        // THEN : La base de données est créée au chemin spécifié
//        let queue = await databaseManager.queue
//        XCTAssertNotNil(queue, "La DatabaseQueue doit être initialisée")
//
//        let fileManager = FileManager.default
//        XCTAssertTrue(fileManager.fileExists(atPath: customPath),
//                     "Le fichier de base de données doit exister au chemin personnalisé")
//    }
//
//    /// Test : Initialisation avec chemin invalide
//    func test_initialisation_avec_chemin_invalide() async throws {
//        // GIVEN : Un chemin vers un dossier inexistant et non créable
//        let invalidPath = "/invalid/nonexistent/path/database.db"
//
//        // WHEN/THEN : L'initialisation doit échouer
//        do {
//            databaseManager = try DatabaseManager(databasePath: invalidPath)
//            XCTFail("L'initialisation devrait échouer avec un chemin invalide")
//        } catch {
//            // Success : erreur attendue
//            XCTAssertNotNil(error, "Une erreur doit être levée")
//        }
//    }
//
//    // MARK: - Configuration Tests
//
//    /// Test : Configuration PRAGMA foreign_keys activée
//    func test_configuration_foreign_keys_activee() async throws {
//        // GIVEN : Une base de données initialisée
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        // WHEN : Lecture de la configuration des clés étrangères
//        let foreignKeysEnabled = try await databaseManager.read { db in
//            try Bool.fetchOne(db, sql: "PRAGMA foreign_keys")
//        }
//
//        // THEN : Les clés étrangères doivent être activées
//        XCTAssertTrue(foreignKeysEnabled ?? false,
//                     "Les clés étrangères doivent être activées (PRAGMA foreign_keys = ON)")
//    }
//
//    /// Test : Configuration PRAGMA journal_mode en WAL
//    func test_configuration_journal_mode_wal() async throws {
//        // GIVEN : Une base de données initialisée
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        // WHEN : Lecture du mode journal
//        let journalMode = try await databaseManager.read { db in
//            try String.fetchOne(db, sql: "PRAGMA journal_mode")
//        }
//
//        // THEN : Le mode journal doit être WAL
//        XCTAssertEqual(journalMode?.uppercased(), "WAL",
//                      "Le mode journal doit être WAL pour de meilleures performances")
//    }
//
//    /// Test : Configuration PRAGMA synchronous en NORMAL
//    func test_configuration_synchronous_normal() async throws {
//        // GIVEN : Une base de données initialisée
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        // WHEN : Lecture du mode synchronous
//        let synchronousMode = try await databaseManager.read { db in
//            try Int.fetchOne(db, sql: "PRAGMA synchronous")
//        }
//
//        // THEN : Le mode synchronous doit être 1 (NORMAL)
//        XCTAssertEqual(synchronousMode, 1,
//                      "Le mode synchronous doit être NORMAL (1) pour un bon équilibre performance/sécurité")
//    }
//
//    // MARK: - Migration Tests
//
//    /// Test : Les migrations créent les tables attendues
//    func test_migrations_creent_tables_vehiclerecord_et_filemetadatarecord() async throws {
//        // GIVEN/WHEN : Une base de données initialisée (les migrations s'exécutent automatiquement)
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        // THEN : Les tables VehicleRecord et FileMetadataRecord doivent exister
//        let vehicleTableExists = try await databaseManager.read { db in
//            try db.tableExists("vehicleRecord")
//        }
//
//        let fileMetadataTableExists = try await databaseManager.read { db in
//            try db.tableExists("fileMetadataRecord")
//        }
//
//        XCTAssertTrue(vehicleTableExists, "La table vehicleRecord doit être créée par les migrations")
//        XCTAssertTrue(fileMetadataTableExists, "La table fileMetadataRecord doit être créée par les migrations")
//    }
//
//    /// Test : Vérification de la structure de la table vehicleRecord
//    func test_structure_table_vehiclerecord() async throws {
//        // GIVEN : Une base de données initialisée
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        // WHEN : Récupération des colonnes de la table vehicleRecord
//        let columns = try await databaseManager.read { db -> [String] in
//            try db.columns(in: "vehicleRecord").map { $0.name }
//        }
//
//        // THEN : Toutes les colonnes attendues doivent être présentes
//        let expectedColumns = [
//            "id", "type", "brand", "model", "mileage",
//            "registrationDate", "plate", "isPrimary", "folderPath",
//            "createdAt", "updatedAt"
//        ]
//
//        for expectedColumn in expectedColumns {
//            XCTAssertTrue(columns.contains(expectedColumn),
//                         "La colonne '\(expectedColumn)' doit exister dans vehicleRecord")
//        }
//    }
//
//    /// Test : Vérification de la structure de la table fileMetadataRecord
//    func test_structure_table_filemetadatarecord() async throws {
//        // GIVEN : Une base de données initialisée
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        // WHEN : Récupération des colonnes de la table fileMetadataRecord
//        let columns = try await databaseManager.read { db -> [String] in
//            try db.columns(in: "fileMetadataRecord").map { $0.name }
//        }
//
//        // THEN : Toutes les colonnes attendues doivent être présentes
//        let expectedColumns = [
//            "id", "vehicleId", "fileName", "relativePath", "documentType",
//            "documentName", "date", "mileage", "amount", "fileSize",
//            "mimeType", "createdAt", "modifiedAt"
//        ]
//
//        for expectedColumn in expectedColumns {
//            XCTAssertTrue(columns.contains(expectedColumn),
//                         "La colonne '\(expectedColumn)' doit exister dans fileMetadataRecord")
//        }
//    }
//
//    /// Test : Vérification de la clé étrangère entre fileMetadataRecord et vehicleRecord
//    func test_cle_etrangere_filemetadatarecord_vers_vehiclerecord() async throws {
//        // GIVEN : Une base de données initialisée
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        // WHEN : Récupération des clés étrangères de fileMetadataRecord
//        struct ForeignKeyInfo: Decodable, FetchableRecord {
//            let table: String
//            let from: String
//            let to: String
//        }
//
//        let foreignKeys = try await databaseManager.read { db -> [ForeignKeyInfo] in
//            try ForeignKeyInfo.fetchAll(db, sql: "PRAGMA foreign_key_list(fileMetadataRecord)")
//        }
//
//        // THEN : Il doit y avoir une clé étrangère vers vehicleRecord
//        XCTAssertFalse(foreignKeys.isEmpty, "fileMetadataRecord doit avoir au moins une clé étrangère")
//
//        let vehicleForeignKey = foreignKeys.first { $0.table == "vehicleRecord" }
//        XCTAssertNotNil(vehicleForeignKey, "Il doit y avoir une clé étrangère vers vehicleRecord")
//        XCTAssertEqual(vehicleForeignKey?.from, "vehicleId", "La colonne source doit être 'vehicleId'")
//        XCTAssertEqual(vehicleForeignKey?.to, "id", "La colonne cible doit être 'id'")
//    }
//
//    // MARK: - Read Operations Tests
//
//    /// Test : Opération de lecture réussie
//    func test_operation_lecture_reussie() async throws {
//        // GIVEN : Une base de données initialisée
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        // WHEN : Exécution d'une opération de lecture
//        let result = try await databaseManager.read { db in
//            try Int.fetchOne(db, sql: "SELECT 42")
//        }
//
//        // THEN : Le résultat doit être correct
//        XCTAssertEqual(result, 42, "L'opération de lecture doit retourner la valeur correcte")
//    }
//
//    /// Test : Lecture de la liste des tables
//    func test_lecture_liste_des_tables() async throws {
//        // GIVEN : Une base de données initialisée
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        // WHEN : Lecture de toutes les tables
//        let tables = try await databaseManager.read { db -> [String] in
//            try String.fetchAll(db, sql: """
//                SELECT name FROM sqlite_master
//                WHERE type='table' AND name NOT LIKE 'sqlite_%'
//                ORDER BY name
//            """)
//        }
//
//        // THEN : Les tables attendues doivent être présentes
//        XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit être dans la liste des tables")
//        XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit être dans la liste des tables")
//    }
//
//    // MARK: - Write Operations Tests
//
//    /// Test : Opération d'écriture réussie
//    func test_operation_ecriture_reussie() async throws {
//        // GIVEN : Une base de données initialisée
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        // WHEN : Insertion d'un véhicule de test
//        let vehicleId = UUID()
//        try await databaseManager.write { db in
//            let record = VehicleRecord(
//                id: vehicleId,
//                type: "Car",
//                brand: "Toyota",
//                model: "Corolla",
//                mileage: "50000",
//                registrationDate: Date(),
//                plate: "AB-123-CD",
//                isPrimary: true,
//                folderPath: "/test/path",
//                createdAt: Date(),
//                updatedAt: Date()
//            )
//
//            try VehicleRecord.insert { record }.execute(db)
//        }
//
//        // THEN : Le véhicule doit être dans la base de données
//        let insertedVehicle = try await databaseManager.read { db in
//            try VehicleRecord.where { $0.id.in([vehicleId]) }.fetchOne(db)
//        }
//
//        XCTAssertNotNil(insertedVehicle, "Le véhicule doit avoir été inséré")
//        XCTAssertEqual(insertedVehicle?.brand, "Toyota")
//        XCTAssertEqual(insertedVehicle?.model, "Corolla")
//    }
//
//    /// Test : Mise à jour d'un enregistrement
//    func test_operation_mise_a_jour_reussie() async throws {
//        // GIVEN : Une base de données avec un véhicule existant
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        let vehicleId = UUID()
//        try await databaseManager.write { db in
//            let record = VehicleRecord(
//                id: vehicleId,
//                type: "Car",
//                brand: "Toyota",
//                model: "Corolla",
//                mileage: "50000",
//                registrationDate: Date(),
//                plate: "AB-123-CD",
//                isPrimary: true,
//                folderPath: "/test/path",
//                createdAt: Date(),
//                updatedAt: Date()
//            )
//            try VehicleRecord.insert { record }.execute(db)
//        }
//
//        // WHEN : Mise à jour du kilométrage
//        try await databaseManager.write { db in
//            var record = try VehicleRecord.where { $0.id.in([vehicleId]) }.fetchOne(db)!
//            record.mileage = "60000"
//            record.updatedAt = Date()
//            try VehicleRecord.upsert { record }.execute(db)
//        }
//
//        // THEN : Les modifications doivent être persistées
//        let updatedVehicle = try await databaseManager.read { db in
//            try VehicleRecord.where { $0.id.in([vehicleId]) }.fetchOne(db)
//        }
//
//        XCTAssertEqual(updatedVehicle?.mileage, "60000", "Le kilométrage doit être mis à jour")
//    }
//
//    /// Test : Suppression d'un enregistrement
//    func test_operation_suppression_reussie() async throws {
//        // GIVEN : Une base de données avec un véhicule existant
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        let vehicleId = UUID()
//        try await databaseManager.write { db in
//            let record = VehicleRecord(
//                id: vehicleId,
//                type: "Car",
//                brand: "Toyota",
//                model: "Corolla",
//                mileage: "50000",
//                registrationDate: Date(),
//                plate: "AB-123-CD",
//                isPrimary: true,
//                folderPath: "/test/path",
//                createdAt: Date(),
//                updatedAt: Date()
//            )
//            try VehicleRecord.insert { record }.execute(db)
//        }
//
//        // WHEN : Suppression du véhicule
//        try await databaseManager.write { db in
//            try VehicleRecord.where { $0.id.in([vehicleId]) }.delete().execute(db)
//        }
//
//        // THEN : Le véhicule ne doit plus exister
//        let deletedVehicle = try await databaseManager.read { db in
//            try VehicleRecord.where { $0.id.in([vehicleId]) }.fetchOne(db)
//        }
//
//        XCTAssertNil(deletedVehicle, "Le véhicule doit avoir été supprimé")
//    }
//
//    // MARK: - Foreign Key Constraint Tests
//
//    /// Test : Suppression en cascade (vehicle → files)
//    func test_suppression_cascade_vehicle_vers_files() async throws {
//        // GIVEN : Une base de données avec un véhicule et des fichiers associés
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        let vehicleId = UUID()
//        let fileId = UUID()
//
//        try await databaseManager.write { db in
//            // Insérer un véhicule
//            let vehicleRecord = VehicleRecord(
//                id: vehicleId,
//                type: "Car",
//                brand: "Toyota",
//                model: "Corolla",
//                mileage: "50000",
//                registrationDate: Date(),
//                plate: "AB-123-CD",
//                isPrimary: true,
//                folderPath: "/test/path",
//                createdAt: Date(),
//                updatedAt: Date()
//            )
//            try VehicleRecord.insert { vehicleRecord }.execute(db)
//
//            // Insérer un fichier associé
//            let fileRecord = FileMetadataRecord(
//                id: fileId,
//                vehicleId: vehicleId,
//                fileName: "test.pdf",
//                relativePath: "documents/test.pdf",
//                documentType: "Insurance",
//                documentName: "Assurance 2025",
//                date: Date(),
//                mileage: "50000",
//                amount: 500.0,
//                fileSize: 1024,
//                mimeType: "application/pdf",
//                createdAt: Date(),
//                modifiedAt: Date()
//            )
//            try FileMetadataRecord.insert { fileRecord }.execute(db)
//        }
//
//        // WHEN : Suppression du véhicule
//        try await databaseManager.write { db in
//            try VehicleRecord.where { $0.id.in([vehicleId]) }.delete().execute(db)
//        }
//
//        // THEN : Le fichier doit aussi être supprimé (cascade)
//        let deletedFile = try await databaseManager.read { db in
//            try FileMetadataRecord.where { $0.id.in([fileId]) }.fetchOne(db)
//        }
//
//        XCTAssertNil(deletedFile, "Le fichier doit avoir été supprimé en cascade avec le véhicule")
//    }
//
//    /// Test : Violation de contrainte de clé étrangère
//    func test_violation_contrainte_cle_etrangere() async throws {
//        // GIVEN : Une base de données initialisée
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        // WHEN/THEN : Tentative d'insertion d'un fichier avec un vehicleId inexistant
//        do {
//            try await databaseManager.write { db in
//                let fileRecord = FileMetadataRecord(
//                    id: UUID(),
//                    vehicleId: UUID(), // ID de véhicule inexistant
//                    fileName: "test.pdf",
//                    relativePath: "documents/test.pdf",
//                    documentType: "Insurance",
//                    documentName: "Assurance 2025",
//                    date: Date(),
//                    mileage: "50000",
//                    amount: 500.0,
//                    fileSize: 1024,
//                    mimeType: "application/pdf",
//                    createdAt: Date(),
//                    modifiedAt: Date()
//                )
//                try FileMetadataRecord.insert { fileRecord }.execute(db)
//            }
//
//            XCTFail("L'insertion devrait échouer à cause de la contrainte de clé étrangère")
//        } catch {
//            // Success : erreur attendue (violation de contrainte)
//            XCTAssertNotNil(error, "Une erreur de contrainte de clé étrangère doit être levée")
//        }
//    }
//
//    // MARK: - Error Handling Tests
//
//    /// Test : Erreur lors d'une requête SQL invalide
//    func test_erreur_requete_sql_invalide() async throws {
//        // GIVEN : Une base de données initialisée
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        // WHEN/THEN : Exécution d'une requête SQL invalide
//        do {
//            _ = try await databaseManager.read { db in
//                try Int.fetchOne(db, sql: "SELECT * FROM nonexistent_table")
//            }
//
//            XCTFail("La requête devrait échouer avec une table inexistante")
//        } catch {
//            // Success : erreur attendue
//            XCTAssertNotNil(error, "Une erreur doit être levée pour une requête invalide")
//        }
//    }
//
//    // MARK: - Performance Tests
//
//    /// Test : Performance d'insertion en masse
//    func test_performance_insertion_masse() async throws {
//        // GIVEN : Une base de données initialisée
//        databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//
//        // WHEN : Insertion de 1000 véhicules
//        try await databaseManager.write { db in
//            for i in 0..<1000 {
//                let record = VehicleRecord(
//                    id: UUID(),
//                    type: "Car",
//                    brand: "Brand \(i)",
//                    model: "Model \(i)",
//                    mileage: "\(i * 1000)",
//                    registrationDate: Date(),
//                    plate: "AB-\(i)-CD",
//                    isPrimary: i == 0,
//                    folderPath: "/test/path/\(i)",
//                    createdAt: Date(),
//                    updatedAt: Date()
//                )
//                try VehicleRecord.insert { record }.execute(db)
//            }
//        }
//
//        // THEN : Vérifier que tous les véhicules ont été insérés
//        let count = try await databaseManager.read { db in
//            try VehicleRecord.all.fetchCount(db)
//        }
//
//        XCTAssertEqual(count, 1000, "Tous les véhicules doivent avoir été insérés")
//    }
//}
