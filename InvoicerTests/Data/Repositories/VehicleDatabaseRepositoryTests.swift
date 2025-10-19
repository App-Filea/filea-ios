////
////  VehicleDatabaseRepositoryTests.swift
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
///// Tests TDD pour VehicleDatabaseRepository
///// Vérifie toutes les opérations CRUD, la synchronisation automatique JSON et la gestion des véhicules
//final class VehicleDatabaseRepositoryTests: XCTestCase {
//
//    // MARK: - Properties
//
//    var tempDatabasePath: String!
//    var tempRootFolderPath: String!
//    var databaseManager: DatabaseManager!
//    var syncManager: VehicleMetadataSyncManager!
//    var repository: VehicleDatabaseRepository!
//
//    // MARK: - Setup & Teardown
//
//    override func setUp() {
//        super.setUp()
//
//        // Créer un chemin temporaire pour la base de données
//        tempDatabasePath = NSTemporaryDirectory()
//            .appending("test_repo_\(UUID().uuidString).db")
//
//        // Créer un dossier racine temporaire pour les véhicules
//        tempRootFolderPath = NSTemporaryDirectory()
//            .appending("test_vehicles_\(UUID().uuidString)")
//
//        do {
//            try FileManager.default.createDirectory(
//                atPath: tempRootFolderPath,
//                withIntermediateDirectories: true
//            )
//
//            // Initialiser les composants
//            databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//            syncManager = VehicleMetadataSyncManager(database: databaseManager)
//            repository = VehicleDatabaseRepository(database: databaseManager, syncManager: syncManager)
//
//            print("🧪 [RepositoryTests] Setup terminé")
//            print("   ├─ Database : \(tempDatabasePath!)")
//            print("   └─ Root Folder : \(tempRootFolderPath!)")
//        } catch {
//            fatalError("❌ [RepositoryTests] Setup failed: \(error)")
//        }
//    }
//
//    override func tearDown() {
//        // Nettoyer les fichiers temporaires
//        if let dbPath = tempDatabasePath {
//            try? FileManager.default.removeItem(atPath: dbPath)
//        }
//
//        if let rootPath = tempRootFolderPath {
//            try? FileManager.default.removeItem(atPath: rootPath)
//        }
//
//        repository = nil
//        syncManager = nil
//        databaseManager = nil
//        tempDatabasePath = nil
//        tempRootFolderPath = nil
//
//        print("🧹 [RepositoryTests] Cleanup terminé")
//
//        super.tearDown()
//    }
//
//    // MARK: - Helper Methods
//
//    /// Crée un véhicule de test
//    private func createTestVehicle(
//        brand: String = "Toyota",
//        model: String = "Corolla",
//        type: VehicleType = .car,
//        isPrimary: Bool = false
//    ) -> Vehicle {
//        Vehicle(
//            type: type,
//            brand: brand,
//            model: model,
//            mileage: "50000",
//            registrationDate: Date(),
//            plate: "AB-123-CD",
//            isPrimary: isPrimary
//        )
//    }
//
//    /// Crée un dossier pour un véhicule
//    private func createVehicleFolder(vehicleId: UUID) throws -> String {
//        let folderPath = tempRootFolderPath.appending("/\(vehicleId.uuidString)")
//        try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true)
//        return folderPath
//    }
//
//    /// Vérifie qu'un fichier JSON existe pour un véhicule
//    private func assertJSONExists(at folderPath: String) -> Bool {
//        let jsonPath = folderPath.appending("/.vehicle_metadata.json")
//        return FileManager.default.fileExists(atPath: jsonPath)
//    }
//
//    // MARK: - Create Tests
//
//    /// Test : Création d'un véhicule avec dossier
//    func test_creation_vehicule_avec_dossier() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule et un dossier
//            let vehicle = createTestVehicle(brand: "Honda", model: "Civic")
//            let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            // WHEN : Création dans le repository
//            try await repository.create(vehicle: vehicle, folderPath: folderPath)
//
//            // THEN : Le véhicule doit être dans la BDD
//            let fetchedVehicle = try await repository.fetch(id: vehicle.id)
//
//            XCTAssertNotNil(fetchedVehicle, "Le véhicule doit avoir été créé")
//            XCTAssertEqual(fetchedVehicle?.brand, "Honda")
//            XCTAssertEqual(fetchedVehicle?.model, "Civic")
//            XCTAssertEqual(fetchedVehicle?.plate, "AB-123-CD")
//        }
//    }
//
//    /// Test : Création d'un véhicule crée automatiquement le JSON
//    func test_creation_vehicule_cree_automatiquement_json() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule et un dossier
//            let vehicle = createTestVehicle(brand: "BMW", model: "X5")
//            let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            // WHEN : Création
//            try await repository.create(vehicle: vehicle, folderPath: folderPath)
//
//            // THEN : Le fichier JSON doit exister
//            XCTAssertTrue(assertJSONExists(at: folderPath),
//                         "Le fichier .vehicle_metadata.json doit être créé automatiquement")
//        }
//    }
//
//    /// Test : Création de plusieurs véhicules
//    func test_creation_plusieurs_vehicules() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : 3 véhicules différents
//            let vehicle1 = createTestVehicle(brand: "Toyota", model: "Yaris")
//            let vehicle2 = createTestVehicle(brand: "Ford", model: "Focus")
//            let vehicle3 = createTestVehicle(brand: "Volkswagen", model: "Golf")
//
//            let folder1 = try createVehicleFolder(vehicleId: vehicle1.id)
//            let folder2 = try createVehicleFolder(vehicleId: vehicle2.id)
//            let folder3 = try createVehicleFolder(vehicleId: vehicle3.id)
//
//            // WHEN : Création des 3 véhicules
//            try await repository.create(vehicle: vehicle1, folderPath: folder1)
//            try await repository.create(vehicle: vehicle2, folderPath: folder2)
//            try await repository.create(vehicle: vehicle3, folderPath: folder3)
//
//            // THEN : Les 3 véhicules doivent être dans la BDD
//            let allVehicles = try await repository.fetchAll()
//
//            XCTAssertEqual(allVehicles.count, 3, "Il doit y avoir 3 véhicules")
//            XCTAssertTrue(allVehicles.contains { $0.brand == "Toyota" })
//            XCTAssertTrue(allVehicles.contains { $0.brand == "Ford" })
//            XCTAssertTrue(allVehicles.contains { $0.brand == "Volkswagen" })
//        }
//    }
//
//    // MARK: - Read Tests
//
//    /// Test : Récupération de tous les véhicules (liste vide)
//    func test_fetchall_retourne_liste_vide_si_aucun_vehicule() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Une BDD vide
//
//            // WHEN : Récupération de tous les véhicules
//            let vehicles = try await repository.fetchAll()
//
//            // THEN : La liste doit être vide
//            XCTAssertTrue(vehicles.isEmpty, "La liste doit être vide sans véhicules")
//        }
//    }
//
//    /// Test : Récupération de tous les véhicules
//    func test_fetchall_retourne_tous_les_vehicules() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : 2 véhicules créés
//            let vehicle1 = createTestVehicle(brand: "Audi", model: "A3")
//            let vehicle2 = createTestVehicle(brand: "Mercedes", model: "C200")
//
//            let folder1 = try createVehicleFolder(vehicleId: vehicle1.id)
//            let folder2 = try createVehicleFolder(vehicleId: vehicle2.id)
//
//            try await repository.create(vehicle: vehicle1, folderPath: folder1)
//            try await repository.create(vehicle: vehicle2, folderPath: folder2)
//
//            // WHEN : Récupération de tous
//            let allVehicles = try await repository.fetchAll()
//
//            // THEN : Les 2 véhicules doivent être retournés
//            XCTAssertEqual(allVehicles.count, 2)
//            XCTAssertTrue(allVehicles.contains { $0.brand == "Audi" })
//            XCTAssertTrue(allVehicles.contains { $0.brand == "Mercedes" })
//        }
//    }
//
//    /// Test : Récupération d'un véhicule par ID
//    func test_fetch_retourne_vehicule_par_id() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule créé
//            let vehicle = createTestVehicle(brand: "Peugeot", model: "208")
//            let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            try await repository.create(vehicle: vehicle, folderPath: folderPath)
//
//            // WHEN : Récupération par ID
//            let fetchedVehicle = try await repository.fetch(id: vehicle.id)
//
//            // THEN : Le véhicule correct doit être retourné
//            XCTAssertNotNil(fetchedVehicle)
//            XCTAssertEqual(fetchedVehicle?.id, vehicle.id)
//            XCTAssertEqual(fetchedVehicle?.brand, "Peugeot")
//            XCTAssertEqual(fetchedVehicle?.model, "208")
//        }
//    }
//
//    /// Test : Récupération d'un véhicule inexistant retourne nil
//    func test_fetch_retourne_nil_si_vehicule_inexistant() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un ID inexistant
//            let nonexistentId = UUID()
//
//            // WHEN : Tentative de récupération
//            let vehicle = try await repository.fetch(id: nonexistentId)
//
//            // THEN : Doit retourner nil
//            XCTAssertNil(vehicle, "Doit retourner nil pour un véhicule inexistant")
//        }
//    }
//
//    /// Test : Récupération du véhicule principal
//    func test_fetchprimary_retourne_vehicule_principal() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : 3 véhicules dont 1 principal
//            let vehicle1 = createTestVehicle(brand: "Renault", model: "Clio", isPrimary: false)
//            let vehicle2 = createTestVehicle(brand: "Citroen", model: "C3", isPrimary: true)
//            let vehicle3 = createTestVehicle(brand: "Dacia", model: "Sandero", isPrimary: false)
//
//            let folder1 = try createVehicleFolder(vehicleId: vehicle1.id)
//            let folder2 = try createVehicleFolder(vehicleId: vehicle2.id)
//            let folder3 = try createVehicleFolder(vehicleId: vehicle3.id)
//
//            try await repository.create(vehicle: vehicle1, folderPath: folder1)
//            try await repository.create(vehicle: vehicle2, folderPath: folder2)
//            try await repository.create(vehicle: vehicle3, folderPath: folder3)
//
//            // WHEN : Récupération du véhicule principal
//            let primaryVehicle = try await repository.fetchPrimary()
//
//            // THEN : Le véhicule Citroen doit être retourné
//            XCTAssertNotNil(primaryVehicle)
//            XCTAssertEqual(primaryVehicle?.brand, "Citroen")
//            XCTAssertEqual(primaryVehicle?.model, "C3")
//            XCTAssertTrue(primaryVehicle?.isPrimary ?? false)
//        }
//    }
//
//    /// Test : Récupération du véhicule principal retourne nil si aucun
//    func test_fetchprimary_retourne_nil_si_aucun_principal() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : 2 véhicules non principaux
//            let vehicle1 = createTestVehicle(brand: "Fiat", model: "500", isPrimary: false)
//            let vehicle2 = createTestVehicle(brand: "Seat", model: "Ibiza", isPrimary: false)
//
//            let folder1 = try createVehicleFolder(vehicleId: vehicle1.id)
//            let folder2 = try createVehicleFolder(vehicleId: vehicle2.id)
//
//            try await repository.create(vehicle: vehicle1, folderPath: folder1)
//            try await repository.create(vehicle: vehicle2, folderPath: folder2)
//
//            // WHEN : Récupération du véhicule principal
//            let primaryVehicle = try await repository.fetchPrimary()
//
//            // THEN : Doit retourner nil
//            XCTAssertNil(primaryVehicle, "Doit retourner nil si aucun véhicule principal")
//        }
//    }
//
//    /// Test : Récupération d'un véhicule avec ses documents
//    func test_fetchwithDocuments_retourne_vehicule_et_documents() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule avec des documents
//            let vehicle = createTestVehicle(brand: "Nissan", model: "Qashqai")
//            let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            try await repository.create(vehicle: vehicle, folderPath: folderPath)
//
//            // Ajouter des documents
//            try await databaseManager.write { db in
//                let file1 = FileMetadataRecord(
//                    id: UUID(),
//                    vehicleId: vehicle.id,
//                    fileName: "assurance.pdf",
//                    relativePath: "documents/assurance.pdf",
//                    documentType: "Insurance",
//                    documentName: "Assurance 2025",
//                    date: Date(),
//                    mileage: "50000",
//                    amount: 600.0,
//                    fileSize: 2048,
//                    mimeType: "application/pdf",
//                    createdAt: Date(),
//                    modifiedAt: Date()
//                )
//
//                let file2 = FileMetadataRecord(
//                    id: UUID(),
//                    vehicleId: vehicle.id,
//                    fileName: "revision.pdf",
//                    relativePath: "documents/revision.pdf",
//                    documentType: "Maintenance",
//                    documentName: "Révision 50000km",
//                    date: Date(),
//                    mileage: "50000",
//                    amount: 350.0,
//                    fileSize: 1024,
//                    mimeType: "application/pdf",
//                    createdAt: Date(),
//                    modifiedAt: Date()
//                )
//
//                try FileMetadataRecord.insert { file1 }.execute(db)
//                try FileMetadataRecord.insert { file2 }.execute(db)
//            }
//
//            // WHEN : Récupération avec documents
//            let vehicleWithDocs = try await repository.fetchWithDocuments(id: vehicle.id)
//
//            // THEN : Le véhicule et ses 2 documents doivent être retournés
//            XCTAssertNotNil(vehicleWithDocs)
//            XCTAssertEqual(vehicleWithDocs?.brand, "Nissan")
//            XCTAssertEqual(vehicleWithDocs?.documents.count, 2, "Il doit y avoir 2 documents")
//
//            let documents = vehicleWithDocs?.documents ?? []
//            XCTAssertTrue(documents.contains(where: { $0.fileURL.contains("assurance.pdf") }))
//            XCTAssertTrue(documents.contains(where: { $0.fileURL.contains("revision.pdf") }))
//        }
//    }
//
//    /// Test : Récupération d'un véhicule sans documents
//    func test_fetchwithDocuments_retourne_vehicule_sans_documents() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule sans documents
//            let vehicle = createTestVehicle(brand: "Mazda", model: "CX-5")
//            let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            try await repository.create(vehicle: vehicle, folderPath: folderPath)
//
//            // WHEN : Récupération avec documents
//            let vehicleWithDocs = try await repository.fetchWithDocuments(id: vehicle.id)
//
//            // THEN : Le véhicule doit être retourné avec une liste vide de documents
//            XCTAssertNotNil(vehicleWithDocs)
//            XCTAssertEqual(vehicleWithDocs?.documents.count, 0, "La liste de documents doit être vide")
//        }
//    }
//
//    /// Test : fetchWithDocuments retourne nil si véhicule inexistant
//    func test_fetchwithDocuments_retourne_nil_si_inexistant() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un ID inexistant
//            let nonexistentId = UUID()
//
//            // WHEN : Récupération avec documents
//            let vehicle = try await repository.fetchWithDocuments(id: nonexistentId)
//
//            // THEN : Doit retourner nil
//            XCTAssertNil(vehicle, "Doit retourner nil pour un véhicule inexistant")
//        }
//    }
//
//    // MARK: - Update Tests
//
//    /// Test : Mise à jour d'un véhicule
//    func test_update_vehicule_modifie_proprietes() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule existant
//            var vehicle = createTestVehicle(brand: "Opel", model: "Corsa")
//            let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            try await repository.create(vehicle: vehicle, folderPath: folderPath)
//
//            // WHEN : Modification et mise à jour
//            vehicle.brand = "Opel Updated"
//            vehicle.model = "Astra"
//            vehicle.mileage = "80000"
//            vehicle.plate = "XY-999-ZZ"
//
//            try await repository.update(vehicle: vehicle, folderPath: folderPath)
//
//            // THEN : Les modifications doivent être persistées
//            let updatedVehicle = try await repository.fetch(id: vehicle.id)
//
//            XCTAssertEqual(updatedVehicle?.brand, "Opel Updated")
//            XCTAssertEqual(updatedVehicle?.model, "Astra")
//            XCTAssertEqual(updatedVehicle?.mileage, "80000")
//            XCTAssertEqual(updatedVehicle?.plate, "XY-999-ZZ")
//        }
//    }
//
//    /// Test : Mise à jour synchronise automatiquement le JSON
//    func test_update_synchronise_automatiquement_json() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule existant
//            var vehicle = createTestVehicle(brand: "Skoda", model: "Octavia")
//            let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            try await repository.create(vehicle: vehicle, folderPath: folderPath)
//
//            // WHEN : Modification
//            vehicle.model = "Superb"
//
//            try await repository.update(vehicle: vehicle, folderPath: folderPath)
//
//            // THEN : Le JSON doit être mis à jour
//            let jsonPath = folderPath.appending("/.vehicle_metadata.json")
//            XCTAssertTrue(FileManager.default.fileExists(atPath: jsonPath))
//
//            let jsonData = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .iso8601
//
//            let metadataFile = try decoder.decode(VehicleMetadataFile.self, from: jsonData)
//            XCTAssertEqual(metadataFile.vehicle.model, "Superb", "Le JSON doit refléter la mise à jour")
//        }
//    }
//
//    /// Test : Définir un véhicule comme principal
//    func test_setprimary_definit_vehicule_comme_principal() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : 3 véhicules dont 1 principal
//            let vehicle1 = createTestVehicle(brand: "Alfa Romeo", model: "Giulia", isPrimary: true)
//            let vehicle2 = createTestVehicle(brand: "Lancia", model: "Ypsilon", isPrimary: false)
//            let vehicle3 = createTestVehicle(brand: "Maserati", model: "Ghibli", isPrimary: false)
//
//            let folder1 = try createVehicleFolder(vehicleId: vehicle1.id)
//            let folder2 = try createVehicleFolder(vehicleId: vehicle2.id)
//            let folder3 = try createVehicleFolder(vehicleId: vehicle3.id)
//
//            try await repository.create(vehicle: vehicle1, folderPath: folder1)
//            try await repository.create(vehicle: vehicle2, folderPath: folder2)
//            try await repository.create(vehicle: vehicle3, folderPath: folder3)
//
//            // WHEN : Définir vehicle2 comme principal
//            try await repository.setPrimary(id: vehicle2.id)
//
//            // THEN : Seul vehicle2 doit être principal
//            let allVehicles = try await repository.fetchAll()
//
//            let primaryVehicles = allVehicles.filter { $0.isPrimary }
//            XCTAssertEqual(primaryVehicles.count, 1, "Il ne doit y avoir qu'un seul véhicule principal")
//            XCTAssertEqual(primaryVehicles.first?.id, vehicle2.id, "Vehicle2 doit être le véhicule principal")
//
//            // Vérifier que les autres ne sont plus principaux
//            XCTAssertFalse(allVehicles.first { $0.id == vehicle1.id }?.isPrimary ?? true)
//            XCTAssertFalse(allVehicles.first { $0.id == vehicle3.id }?.isPrimary ?? true)
//        }
//    }
//
//    /// Test : setPrimary synchronise tous les véhicules affectés
//    func test_setprimary_synchronise_tous_vehicules() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : 2 véhicules
//            let vehicle1 = createTestVehicle(brand: "Jaguar", model: "XE", isPrimary: true)
//            let vehicle2 = createTestVehicle(brand: "Land Rover", model: "Discovery", isPrimary: false)
//
//            let folder1 = try createVehicleFolder(vehicleId: vehicle1.id)
//            let folder2 = try createVehicleFolder(vehicleId: vehicle2.id)
//
//            try await repository.create(vehicle: vehicle1, folderPath: folder1)
//            try await repository.create(vehicle: vehicle2, folderPath: folder2)
//
//            // WHEN : Changement de véhicule principal
//            try await repository.setPrimary(id: vehicle2.id)
//
//            // THEN : Les 2 fichiers JSON doivent être mis à jour
//            XCTAssertTrue(assertJSONExists(at: folder1), "JSON de vehicle1 doit exister")
//            XCTAssertTrue(assertJSONExists(at: folder2), "JSON de vehicle2 doit exister")
//
//            // Vérifier le contenu des JSON
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .iso8601
//
//            let json1Data = try Data(contentsOf: URL(fileURLWithPath: folder1).appendingPathComponent(".vehicle_metadata.json"))
//            let json2Data = try Data(contentsOf: URL(fileURLWithPath: folder2).appendingPathComponent(".vehicle_metadata.json"))
//
//            let metadata1 = try decoder.decode(VehicleMetadataFile.self, from: json1Data)
//            let metadata2 = try decoder.decode(VehicleMetadataFile.self, from: json2Data)
//
//            XCTAssertFalse(metadata1.vehicle.isPrimary, "Vehicle1 ne doit plus être principal dans le JSON")
//            XCTAssertTrue(metadata2.vehicle.isPrimary, "Vehicle2 doit être principal dans le JSON")
//        }
//    }
//
//    // MARK: - Delete Tests
//
//    /// Test : Suppression d'un véhicule
//    func test_delete_supprime_vehicule() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule existant
//            let vehicle = createTestVehicle(brand: "Kia", model: "Sportage")
//            let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            try await repository.create(vehicle: vehicle, folderPath: folderPath)
//
//            // Vérifier qu'il existe
//            let beforeDelete = try await repository.fetch(id: vehicle.id)
//            XCTAssertNotNil(beforeDelete)
//
//            // WHEN : Suppression
//            try await repository.delete(id: vehicle.id)
//
//            // THEN : Le véhicule ne doit plus exister
//            let afterDelete = try await repository.fetch(id: vehicle.id)
//            XCTAssertNil(afterDelete, "Le véhicule doit avoir été supprimé")
//        }
//    }
//
//    /// Test : Suppression en cascade des documents
//    func test_delete_supprime_documents_en_cascade() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule avec des documents
//            let vehicle = createTestVehicle(brand: "Hyundai", model: "i30")
//            let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            try await repository.create(vehicle: vehicle, folderPath: folderPath)
//
//            // Ajouter des documents
//            try await databaseManager.write { db in
//                let file = FileMetadataRecord(
//                    id: UUID(),
//                    vehicleId: vehicle.id,
//                    fileName: "doc.pdf",
//                    relativePath: "doc.pdf",
//                    documentType: "Other",
//                    documentName: "Document",
//                    date: Date(),
//                    mileage: "10000",
//                    amount: nil,
//                    fileSize: 100,
//                    mimeType: "application/pdf",
//                    createdAt: Date(),
//                    modifiedAt: Date()
//                )
//                try FileMetadataRecord.insert { file }.execute(db)
//            }
//
//            // Vérifier qu'il y a 1 document
//            let beforeDelete = try await databaseManager.read { db in
//                try FileMetadataRecord.where { $0.vehicleId.in([vehicle.id]) }.fetchCount(db)
//            }
//            XCTAssertEqual(beforeDelete, 1)
//
//            // WHEN : Suppression du véhicule
//            try await repository.delete(id: vehicle.id)
//
//            // THEN : Les documents doivent aussi être supprimés
//            let afterDelete = try await databaseManager.read { db in
//                try FileMetadataRecord.where { $0.vehicleId.in([vehicle.id]) }.fetchCount(db)
//            }
//            XCTAssertEqual(afterDelete, 0, "Les documents doivent avoir été supprimés en cascade")
//        }
//    }
//
//    /// Test : Suppression d'un véhicule inexistant ne plante pas
//    func test_delete_vehicule_inexistant_ne_plante_pas() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un ID inexistant
//            let nonexistentId = UUID()
//
//            // WHEN/THEN : La suppression ne doit pas planter (opération idempotente)
//            do {
//                try await repository.delete(id: nonexistentId)
//                // Success : pas d'erreur
//            } catch {
//                XCTFail("La suppression d'un véhicule inexistant ne devrait pas lever d'erreur")
//            }
//        }
//    }
//
//    // MARK: - Count Tests
//
//    /// Test : Comptage des véhicules (BDD vide)
//    func test_count_retourne_zero_si_bdd_vide() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Une BDD vide
//
//            // WHEN : Comptage
//            let count = try await repository.count()
//
//            // THEN : Doit retourner 0
//            XCTAssertEqual(count, 0, "Le comptage doit retourner 0 pour une BDD vide")
//        }
//    }
//
//    /// Test : Comptage des véhicules
//    func test_count_retourne_nombre_correct_de_vehicules() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : 5 véhicules créés
//            for i in 0..<5 {
//                let vehicle = createTestVehicle(brand: "Brand \(i)", model: "Model \(i)")
//                let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//                try await repository.create(vehicle: vehicle, folderPath: folderPath)
//            }
//
//            // WHEN : Comptage
//            let count = try await repository.count()
//
//            // THEN : Doit retourner 5
//            XCTAssertEqual(count, 5, "Le comptage doit retourner le nombre correct de véhicules")
//        }
//    }
//
//    /// Test : Comptage après suppressions
//    func test_count_apres_suppressions() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : 3 véhicules créés
//            var vehicleIds: [UUID] = []
//            for i in 0..<3 {
//                let vehicle = createTestVehicle(brand: "Brand \(i)", model: "Model \(i)")
//                let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//                try await repository.create(vehicle: vehicle, folderPath: folderPath)
//                vehicleIds.append(vehicle.id)
//            }
//
//            // WHEN : Suppression de 2 véhicules
//            try await repository.delete(id: vehicleIds[0])
//            try await repository.delete(id: vehicleIds[1])
//
//            // THEN : Le comptage doit retourner 1
//            let count = try await repository.count()
//            XCTAssertEqual(count, 1, "Il ne doit rester qu'un seul véhicule")
//        }
//    }
//
//    // MARK: - Integration Tests
//
//    /// Test : Cycle complet CRUD
//    func test_cycle_complet_crud() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // CREATE
//            var vehicle = createTestVehicle(brand: "Volvo", model: "XC60")
//            let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            try await repository.create(vehicle: vehicle, folderPath: folderPath)
//
//            // READ
//            let created = try await repository.fetch(id: vehicle.id)
//            XCTAssertNotNil(created, "Le véhicule doit avoir été créé")
//
//            // UPDATE
//            vehicle.model = "XC90"
//            try await repository.update(vehicle: vehicle, folderPath: folderPath)
//
//            let updated = try await repository.fetch(id: vehicle.id)
//            XCTAssertEqual(updated?.model, "XC90", "Le véhicule doit avoir été mis à jour")
//
//            // DELETE
//            try await repository.delete(id: vehicle.id)
//
//            let deleted = try await repository.fetch(id: vehicle.id)
//            XCTAssertNil(deleted, "Le véhicule doit avoir été supprimé")
//        }
//    }
//
//    /// Test : Synchronisation JSON tout au long du cycle de vie
//    func test_synchronisation_json_cycle_vie() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule
//            var vehicle = createTestVehicle(brand: "Porsche", model: "911")
//            let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            // CREATE : JSON doit être créé
//            try await repository.create(vehicle: vehicle, folderPath: folderPath)
//            XCTAssertTrue(assertJSONExists(at: folderPath), "JSON doit exister après création")
//
//            // UPDATE : JSON doit être mis à jour
//            vehicle.model = "Cayenne"
//            try await repository.update(vehicle: vehicle, folderPath: folderPath)
//            XCTAssertTrue(assertJSONExists(at: folderPath), "JSON doit exister après mise à jour")
//
//            // Vérifier le contenu
//            let jsonData = try Data(contentsOf: URL(fileURLWithPath: folderPath).appendingPathComponent(".vehicle_metadata.json"))
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .iso8601
//
//            let metadata = try decoder.decode(VehicleMetadataFile.self, from: jsonData)
//            XCTAssertEqual(metadata.vehicle.model, "Cayenne", "Le JSON doit refléter la dernière mise à jour")
//        }
//    }
//
//    /// Test : Création et récupération de différents types de véhicules
//    func test_differents_types_vehicules() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule de chaque type
//            let car = createTestVehicle(brand: "Tesla", model: "Model 3", type: .car)
//            let motorcycle = createTestVehicle(brand: "Ducati", model: "Panigale", type: .motorcycle)
//            let truck = createTestVehicle(brand: "Scania", model: "R450", type: .truck)
//            let bicycle = createTestVehicle(brand: "Trek", model: "Emonda", type: .bicycle)
//            let other = createTestVehicle(brand: "Custom", model: "Vehicle", type: .other)
//
//            let vehicles = [car, motorcycle, truck, bicycle, other]
//
//            // WHEN : Création de tous les véhicules
//            for vehicle in vehicles {
//                let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//                try await repository.create(vehicle: vehicle, folderPath: folderPath)
//            }
//
//            // THEN : Tous doivent être récupérables avec le bon type
//            let allVehicles = try await repository.fetchAll()
//            XCTAssertEqual(allVehicles.count, 5)
//
//            XCTAssertTrue(allVehicles.contains { $0.type == .car && $0.brand == "Tesla" })
//            XCTAssertTrue(allVehicles.contains { $0.type == .motorcycle && $0.brand == "Ducati" })
//            XCTAssertTrue(allVehicles.contains { $0.type == .truck && $0.brand == "Scania" })
//            XCTAssertTrue(allVehicles.contains { $0.type == .bicycle && $0.brand == "Trek" })
//            XCTAssertTrue(allVehicles.contains { $0.type == .other && $0.brand == "Custom" })
//        }
//    }
//
//    // MARK: - Edge Cases Tests
//
//    /// Test : Création avec des caractères spéciaux dans les noms
//    func test_creation_avec_caracteres_speciaux() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule avec caractères spéciaux
//            let vehicle = createTestVehicle(brand: "Citroën", model: "DS 4 É-Tense")
//            let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            // WHEN : Création
//            try await repository.create(vehicle: vehicle, folderPath: folderPath)
//
//            // THEN : Doit être récupérable correctement
//            let fetched = try await repository.fetch(id: vehicle.id)
//
//            XCTAssertEqual(fetched?.brand, "Citroën")
//            XCTAssertEqual(fetched?.model, "DS 4 É-Tense")
//        }
//    }
//
//    /// Test : Création avec mileage nil
//    func test_creation_avec_mileage_nil() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule sans kilométrage
//            let vehicle = Vehicle(
//                type: .car,
//                brand: "Alpine",
//                model: "A110",
//                mileage: nil,
//                registrationDate: Date(),
//                plate: "AB-123-CD",
//                isPrimary: false
//            )
//            let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            // WHEN : Création
//            try await repository.create(vehicle: vehicle, folderPath: folderPath)
//
//            // THEN : Le véhicule doit être créé avec mileage nil
//            let fetched = try await repository.fetch(id: vehicle.id)
//
//            XCTAssertNil(fetched?.mileage, "Le kilométrage doit être nil")
//        }
//    }
//
//    /// Test : Mise à jour du folderPath
//    func test_mise_a_jour_folderpath() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : Un véhicule existant
//            var vehicle = createTestVehicle(brand: "Lotus", model: "Elise")
//            let oldFolderPath = try createVehicleFolder(vehicleId: vehicle.id)
//
//            try await repository.create(vehicle: vehicle, folderPath: oldFolderPath)
//
//            // WHEN : Mise à jour avec un nouveau folderPath
//            let newFolderPath = try createVehicleFolder(vehicleId: UUID())
//
//            try await repository.update(vehicle: vehicle, folderPath: newFolderPath)
//
//            // THEN : Le nouveau folderPath doit être enregistré
//            let vehicleRecord = try await databaseManager.read { db in
//                try VehicleRecord.where { $0.id.in([vehicle.id]) }.fetchOne(db)
//            }
//
//            XCTAssertEqual(vehicleRecord?.folderPath, newFolderPath, "Le folderPath doit être mis à jour")
//        }
//    }
//
//    // MARK: - Performance Tests
//
//    /// Test : Performance de fetchAll avec beaucoup de véhicules
//    func test_performance_fetchall_avec_100_vehicules() async throws {
//        try await withDependencies {
//            $0.database = databaseManager
//            $0.syncManager = syncManager
//            $0.vehicleDatabaseRepository = repository
//        } operation: {
//            // Diagnostic : vérifier que les tables existent
//            let tables = try await databaseManager.verifyTablesExist()
//            print("📊 [Test] Tables disponibles: \(tables)")
//            XCTAssertTrue(tables.contains("vehicleRecord"), "vehicleRecord doit exister")
//            XCTAssertTrue(tables.contains("fileMetadataRecord"), "fileMetadataRecord doit exister")
//
//            // GIVEN : 100 véhicules
//            for i in 0..<100 {
//                let vehicle = createTestVehicle(brand: "Brand\(i)", model: "Model\(i)")
//                let folderPath = try createVehicleFolder(vehicleId: vehicle.id)
//                try await repository.create(vehicle: vehicle, folderPath: folderPath)
//            }
//
//            // WHEN : Récupération de tous les véhicules
//            let allVehicles = try await repository.fetchAll()
//
//            // THEN : Vérifier que tous les véhicules sont récupérés
//            XCTAssertEqual(allVehicles.count, 100, "Tous les véhicules doivent être récupérés")
//        }
//    }
//}
