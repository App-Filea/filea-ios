////
////  VehicleMetadataSyncManagerTests.swift
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
///// Tests TDD pour VehicleMetadataSyncManager
///// Vérifie la synchronisation bidirectionnelle entre GRDB et JSON, le scan de dossiers et la validation
//final class VehicleMetadataSyncManagerTests: XCTestCase {
//
//    // MARK: - Properties
//
//    var tempDatabasePath: String!
//    var tempFolderPath: String!
//    var databaseManager: DatabaseManager!
//    var syncManager: VehicleMetadataSyncManager!
//
//    // MARK: - Setup & Teardown
//
//    override func setUp() {
//        super.setUp()
//
//        // Créer un chemin temporaire pour la base de données
//        tempDatabasePath = NSTemporaryDirectory()
//            .appending("test_sync_\(UUID().uuidString).db")
//
//        // Créer un dossier temporaire pour les fichiers JSON
//        tempFolderPath = NSTemporaryDirectory()
//            .appending("test_vehicles_\(UUID().uuidString)")
//
//        do {
//            try FileManager.default.createDirectory(
//                atPath: tempFolderPath,
//                withIntermediateDirectories: true
//            )
//
//            // Initialiser le database manager et le sync manager
//            databaseManager = try DatabaseManager(databasePath: tempDatabasePath)
//            syncManager = VehicleMetadataSyncManager(database: databaseManager)
//
//            print("🧪 [SyncManagerTests] Setup terminé")
//            print("   ├─ Database : \(tempDatabasePath!)")
//            print("   └─ Folder : \(tempFolderPath!)")
//        } catch {
//            fatalError("❌ [SyncManagerTests] Setup failed: \(error)")
//        }
//    }
//
//    override func tearDown() {
//        // Nettoyer les fichiers temporaires
//        if let dbPath = tempDatabasePath {
//            try? FileManager.default.removeItem(atPath: dbPath)
//        }
//
//        if let folderPath = tempFolderPath {
//            try? FileManager.default.removeItem(atPath: folderPath)
//        }
//
//        syncManager = nil
//        databaseManager = nil
//        tempDatabasePath = nil
//        tempFolderPath = nil
//
//        print("🧹 [SyncManagerTests] Cleanup terminé")
//
//        super.tearDown()
//    }
//
//    // MARK: - Helper Methods
//
//    /// Crée un véhicule de test dans la base de données
//    private func createTestVehicle(
//        id: UUID = UUID(),
//        brand: String = "Toyota",
//        model: String = "Corolla",
//        folderPath: String
//    ) async throws -> UUID {
//        try await databaseManager.write { db in
//            let record = VehicleRecord(
//                id: id,
//                type: "Car",
//                brand: brand,
//                model: model,
//                mileage: "50000",
//                registrationDate: Date(),
//                plate: "AB-123-CD",
//                isPrimary: true,
//                folderPath: folderPath,
//                createdAt: Date(),
//                updatedAt: Date()
//            )
//            try VehicleRecord.insert { record }.execute(db)
//        }
//        return id
//    }
//
//    /// Crée un fichier de métadonnées de test dans la base de données
//    private func createTestFileMetadata(
//        vehicleId: UUID,
//        fileName: String = "test.pdf"
//    ) async throws {
//        try await databaseManager.write { db in
//            let fileRecord = FileMetadataRecord(
//                id: UUID(),
//                vehicleId: vehicleId,
//                fileName: fileName,
//                relativePath: "documents/\(fileName)",
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
//    }
//
//    /// Vérifie qu'un fichier JSON existe et est valide
//    private func assertJSONFileExists(at folderPath: String) throws -> VehicleMetadataFile {
//        let jsonURL = URL(fileURLWithPath: folderPath)
//            .appendingPathComponent(".vehicle_metadata.json")
//
//        XCTAssertTrue(FileManager.default.fileExists(atPath: jsonURL.path),
//                     "Le fichier .vehicle_metadata.json doit exister")
//
//        let jsonData = try Data(contentsOf: jsonURL)
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//
//        return try decoder.decode(VehicleMetadataFile.self, from: jsonData)
//    }
//
//    // MARK: - Export Tests (GRDB → JSON)
//
//    /// Test : Export d'un véhicule sans fichiers vers JSON
//    func test_export_vehicule_sans_fichiers_vers_json() async throws {
//        // GIVEN : Un véhicule dans la BDD
//        let vehicleFolderPath = tempFolderPath.appending("/vehicle1")
//        try FileManager.default.createDirectory(atPath: vehicleFolderPath, withIntermediateDirectories: true)
//
//        let vehicleId = try await createTestVehicle(folderPath: vehicleFolderPath)
//
//        // WHEN : Export vers JSON
//        try await syncManager.exportVehicleToJSON(vehicleId: vehicleId)
//
//        // THEN : Le fichier JSON doit exister et contenir les bonnes données
//        let metadataFile = try assertJSONFileExists(at: vehicleFolderPath)
//
//        XCTAssertEqual(metadataFile.vehicle.id, vehicleId)
//        XCTAssertEqual(metadataFile.vehicle.brand, "Toyota")
//        XCTAssertEqual(metadataFile.vehicle.model, "Corolla")
//        XCTAssertEqual(metadataFile.files.count, 0, "Il ne doit pas y avoir de fichiers")
//        XCTAssertEqual(metadataFile.metadata.version, "1.0")
//    }
//
//    /// Test : Export d'un véhicule avec fichiers vers JSON
//    func test_export_vehicule_avec_fichiers_vers_json() async throws {
//        // GIVEN : Un véhicule avec des fichiers dans la BDD
//        let vehicleFolderPath = tempFolderPath.appending("/vehicle2")
//        try FileManager.default.createDirectory(atPath: vehicleFolderPath, withIntermediateDirectories: true)
//
//        let vehicleId = try await createTestVehicle(folderPath: vehicleFolderPath)
//        try await createTestFileMetadata(vehicleId: vehicleId, fileName: "assurance.pdf")
//        try await createTestFileMetadata(vehicleId: vehicleId, fileName: "controle_technique.pdf")
//
//        // WHEN : Export vers JSON
//        try await syncManager.exportVehicleToJSON(vehicleId: vehicleId)
//
//        // THEN : Le fichier JSON doit contenir le véhicule et ses fichiers
//        let metadataFile = try assertJSONFileExists(at: vehicleFolderPath)
//
//        XCTAssertEqual(metadataFile.vehicle.id, vehicleId)
//        XCTAssertEqual(metadataFile.files.count, 2, "Il doit y avoir 2 fichiers")
//        XCTAssertTrue(metadataFile.files.contains { $0.fileName == "assurance.pdf" })
//        XCTAssertTrue(metadataFile.files.contains { $0.fileName == "controle_technique.pdf" })
//    }
//
//    /// Test : Export échoue si le véhicule n'existe pas
//    func test_export_echoue_si_vehicule_inexistant() async throws {
//        // GIVEN : Un ID de véhicule inexistant
//        let nonexistentId = UUID()
//
//        // WHEN/THEN : L'export doit échouer avec SyncError.vehicleNotFound
//        do {
//            try await syncManager.exportVehicleToJSON(vehicleId: nonexistentId)
//            XCTFail("L'export devrait échouer pour un véhicule inexistant")
//        } catch let error as SyncError {
//            XCTAssertEqual(error, .vehicleNotFound, "L'erreur doit être vehicleNotFound")
//        } catch {
//            XCTFail("L'erreur devrait être de type SyncError.vehicleNotFound")
//        }
//    }
//
//    /// Test : Format JSON exporté est correct et complet
//    func test_format_json_exporte_est_correct() async throws {
//        // GIVEN : Un véhicule avec toutes les propriétés renseignées
//        let vehicleFolderPath = tempFolderPath.appending("/vehicle_complete")
//        try FileManager.default.createDirectory(atPath: vehicleFolderPath, withIntermediateDirectories: true)
//
//        let specificDate = Date(timeIntervalSince1970: 1672531200) // 2023-01-01
//        let vehicleId = UUID()
//
//        try await databaseManager.write { db in
//            let record = VehicleRecord(
//                id: vehicleId,
//                type: "Motorcycle",
//                brand: "Honda",
//                model: "CBR600",
//                mileage: "25000",
//                registrationDate: specificDate,
//                plate: "XY-999-ZZ",
//                isPrimary: false,
//                folderPath: vehicleFolderPath,
//                createdAt: specificDate,
//                updatedAt: specificDate
//            )
//            try VehicleRecord.insert { record }.execute(db)
//        }
//
//        // WHEN : Export vers JSON
//        try await syncManager.exportVehicleToJSON(vehicleId: vehicleId)
//
//        // THEN : Toutes les propriétés doivent être présentes et correctes
//        let metadataFile = try assertJSONFileExists(at: vehicleFolderPath)
//
//        XCTAssertEqual(metadataFile.vehicle.id, vehicleId)
//        XCTAssertEqual(metadataFile.vehicle.type, "Motorcycle")
//        XCTAssertEqual(metadataFile.vehicle.brand, "Honda")
//        XCTAssertEqual(metadataFile.vehicle.model, "CBR600")
//        XCTAssertEqual(metadataFile.vehicle.mileage, "25000")
//        XCTAssertEqual(metadataFile.vehicle.plate, "XY-999-ZZ")
//        XCTAssertFalse(metadataFile.vehicle.isPrimary)
//
//        // Vérifier les métadonnées du fichier JSON
//        XCTAssertEqual(metadataFile.metadata.version, "1.0")
//        XCTAssertNotNil(metadataFile.metadata.lastSyncedAt)
//        XCTAssertNotNil(metadataFile.metadata.appVersion)
//    }
//
//    /// Test : L'export écrase le fichier JSON existant
//    func test_export_ecrase_fichier_json_existant() async throws {
//        // GIVEN : Un véhicule avec un JSON déjà exporté
//        let vehicleFolderPath = tempFolderPath.appending("/vehicle_update")
//        try FileManager.default.createDirectory(atPath: vehicleFolderPath, withIntermediateDirectories: true)
//
//        let vehicleId = try await createTestVehicle(brand: "Renault", model: "Clio", folderPath: vehicleFolderPath)
//
//        // Premier export
//        try await syncManager.exportVehicleToJSON(vehicleId: vehicleId)
//
//        let firstExport = try assertJSONFileExists(at: vehicleFolderPath)
//        XCTAssertEqual(firstExport.vehicle.brand, "Renault")
//
//        // WHEN : Modification du véhicule et nouvel export
//        try await databaseManager.write { db in
//            var record = try VehicleRecord.where { $0.id.in([vehicleId]) }.fetchOne(db)!
//            record.brand = "Peugeot"
//            record.model = "208"
//            try VehicleRecord.upsert { record }.execute(db)
//        }
//
//        try await syncManager.exportVehicleToJSON(vehicleId: vehicleId)
//
//        // THEN : Le fichier JSON doit être mis à jour
//        let secondExport = try assertJSONFileExists(at: vehicleFolderPath)
//        XCTAssertEqual(secondExport.vehicle.brand, "Peugeot")
//        XCTAssertEqual(secondExport.vehicle.model, "208")
//    }
//
//    // MARK: - Import Tests (JSON → GRDB)
//
//    /// Test : Import d'un véhicule depuis JSON
//    func test_import_vehicule_depuis_json() async throws {
//        // GIVEN : Un fichier JSON valide
//        let vehicleFolderPath = tempFolderPath.appending("/import_vehicle")
//        try FileManager.default.createDirectory(atPath: vehicleFolderPath, withIntermediateDirectories: true)
//
//        let vehicleId = UUID()
//        let metadataFile = VehicleMetadataFile(
//            vehicle: VehicleDTO(
//                id: vehicleId,
//                type: "Car",
//                brand: "Ford",
//                model: "Fiesta",
//                mileage: "30000",
//                registrationDate: Date(),
//                plate: "CD-456-EF",
//                isPrimary: true,
//                createdAt: Date(),
//                updatedAt: Date()
//            ),
//            files: [],
//            metadata: VehicleMetadataFile.MetadataInfo(
//                version: "1.0",
//                lastSyncedAt: Date(),
//                appVersion: "1.0.0"
//            )
//        )
//
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
//
//        let jsonData = try encoder.encode(metadataFile)
//        let jsonURL = URL(fileURLWithPath: vehicleFolderPath)
//            .appendingPathComponent(".vehicle_metadata.json")
//        try jsonData.write(to: jsonURL)
//
//        // WHEN : Import depuis JSON
//        let importedId = try await syncManager.importVehicleFromJSON(folderPath: vehicleFolderPath)
//
//        // THEN : Le véhicule doit être dans la BDD
//        XCTAssertEqual(importedId, vehicleId)
//
//        let vehicleRecord = try await databaseManager.read { db in
//            try VehicleRecord.where { $0.id.in([vehicleId]) }.fetchOne(db)
//        }
//
//        XCTAssertNotNil(vehicleRecord)
//        XCTAssertEqual(vehicleRecord?.brand, "Ford")
//        XCTAssertEqual(vehicleRecord?.model, "Fiesta")
//        XCTAssertEqual(vehicleRecord?.plate, "CD-456-EF")
//    }
//
//    /// Test : Import d'un véhicule avec fichiers depuis JSON
//    func test_import_vehicule_avec_fichiers_depuis_json() async throws {
//        // GIVEN : Un fichier JSON avec véhicule et fichiers
//        let vehicleFolderPath = tempFolderPath.appending("/import_with_files")
//        try FileManager.default.createDirectory(atPath: vehicleFolderPath, withIntermediateDirectories: true)
//
//        let vehicleId = UUID()
//        let file1Id = UUID()
//        let file2Id = UUID()
//
//        let metadataFile = VehicleMetadataFile(
//            vehicle: VehicleDTO(
//                id: vehicleId,
//                type: "Car",
//                brand: "BMW",
//                model: "320i",
//                mileage: "80000",
//                registrationDate: Date(),
//                plate: "GH-789-IJ",
//                isPrimary: false,
//                createdAt: Date(),
//                updatedAt: Date()
//            ),
//            files: [
//                FileMetadataDTO(
//                    id: file1Id,
//                    fileName: "carte_grise.pdf",
//                    relativePath: "documents/carte_grise.pdf",
//                    documentType: "Registration",
//                    documentName: "Carte Grise",
//                    date: Date(),
//                    mileage: "80000",
//                    amount: nil,
//                    fileSize: 2048,
//                    mimeType: "application/pdf",
//                    createdAt: Date(),
//                    modifiedAt: Date()
//                ),
//                FileMetadataDTO(
//                    id: file2Id,
//                    fileName: "vidange.pdf",
//                    relativePath: "documents/vidange.pdf",
//                    documentType: "Maintenance",
//                    documentName: "Vidange",
//                    date: Date(),
//                    mileage: "75000",
//                    amount: 120.0,
//                    fileSize: 1536,
//                    mimeType: "application/pdf",
//                    createdAt: Date(),
//                    modifiedAt: Date()
//                )
//            ],
//            metadata: VehicleMetadataFile.MetadataInfo(
//                version: "1.0",
//                lastSyncedAt: Date(),
//                appVersion: "1.0.0"
//            )
//        )
//
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
//
//        let jsonData = try encoder.encode(metadataFile)
//        let jsonURL = URL(fileURLWithPath: vehicleFolderPath)
//            .appendingPathComponent(".vehicle_metadata.json")
//        try jsonData.write(to: jsonURL)
//
//        // WHEN : Import depuis JSON
//        let importedId = try await syncManager.importVehicleFromJSON(folderPath: vehicleFolderPath)
//
//        // THEN : Le véhicule et les fichiers doivent être dans la BDD
//        XCTAssertEqual(importedId, vehicleId)
//
//        let fileRecords = try await databaseManager.read { db in
//            try FileMetadataRecord.where { $0.vehicleId.in([vehicleId]) }.fetchAll(db)
//        }
//
//        XCTAssertEqual(fileRecords.count, 2, "Il doit y avoir 2 fichiers importés")
//        XCTAssertTrue(fileRecords.contains { $0.fileName == "carte_grise.pdf" })
//        XCTAssertTrue(fileRecords.contains { $0.fileName == "vidange.pdf" })
//    }
//
//    /// Test : Import échoue si le fichier JSON n'existe pas
//    func test_import_echoue_si_json_inexistant() async throws {
//        // GIVEN : Un dossier sans fichier JSON
//        let emptyFolderPath = tempFolderPath.appending("/empty_folder")
//        try FileManager.default.createDirectory(atPath: emptyFolderPath, withIntermediateDirectories: true)
//
//        // WHEN/THEN : L'import doit échouer avec SyncError.jsonFileNotFound
//        do {
//            _ = try await syncManager.importVehicleFromJSON(folderPath: emptyFolderPath)
//            XCTFail("L'import devrait échouer sans fichier JSON")
//        } catch let error as SyncError {
//            XCTAssertEqual(error, .jsonFileNotFound, "L'erreur doit être jsonFileNotFound")
//        } catch {
//            XCTFail("L'erreur devrait être de type SyncError.jsonFileNotFound")
//        }
//    }
//
//    /// Test : Import échoue si le JSON est invalide
//    func test_import_echoue_si_json_invalide() async throws {
//        // GIVEN : Un fichier JSON invalide
//        let invalidJSONFolderPath = tempFolderPath.appending("/invalid_json")
//        try FileManager.default.createDirectory(atPath: invalidJSONFolderPath, withIntermediateDirectories: true)
//
//        let jsonURL = URL(fileURLWithPath: invalidJSONFolderPath)
//            .appendingPathComponent(".vehicle_metadata.json")
//
//        let invalidJSON = "{ invalid json content }"
//        try invalidJSON.write(to: jsonURL, atomically: true, encoding: .utf8)
//
//        // WHEN/THEN : L'import doit échouer avec une erreur de décodage
//        do {
//            _ = try await syncManager.importVehicleFromJSON(folderPath: invalidJSONFolderPath)
//            XCTFail("L'import devrait échouer avec un JSON invalide")
//        } catch {
//            // Success : erreur de décodage attendue
//            XCTAssertNotNil(error)
//        }
//    }
//
//    /// Test : Import met à jour (upsert) un véhicule existant
//    func test_import_met_a_jour_vehicule_existant() async throws {
//        // GIVEN : Un véhicule existant dans la BDD
//        let vehicleFolderPath = tempFolderPath.appending("/upsert_vehicle")
//        try FileManager.default.createDirectory(atPath: vehicleFolderPath, withIntermediateDirectories: true)
//
//        let vehicleId = UUID()
//        try await databaseManager.write { db in
//            let record = VehicleRecord(
//                id: vehicleId,
//                type: "Car",
//                brand: "Volkswagen",
//                model: "Golf",
//                mileage: "40000",
//                registrationDate: Date(),
//                plate: "KL-111-MN",
//                isPrimary: true,
//                folderPath: vehicleFolderPath,
//                createdAt: Date(),
//                updatedAt: Date()
//            )
//            try VehicleRecord.insert { record }.execute(db)
//        }
//
//        // WHEN : Import d'un JSON avec le même ID mais des valeurs différentes
//        let metadataFile = VehicleMetadataFile(
//            vehicle: VehicleDTO(
//                id: vehicleId,
//                type: "Car",
//                brand: "Volkswagen",
//                model: "Polo", // Modèle changé
//                mileage: "50000", // Kilométrage changé
//                registrationDate: Date(),
//                plate: "KL-111-MN",
//                isPrimary: false, // isPrimary changé
//                createdAt: Date(),
//                updatedAt: Date()
//            ),
//            files: [],
//            metadata: VehicleMetadataFile.MetadataInfo(
//                version: "1.0",
//                lastSyncedAt: Date(),
//                appVersion: "1.0.0"
//            )
//        )
//
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        let jsonData = try encoder.encode(metadataFile)
//        let jsonURL = URL(fileURLWithPath: vehicleFolderPath)
//            .appendingPathComponent(".vehicle_metadata.json")
//        try jsonData.write(to: jsonURL)
//
//        _ = try await syncManager.importVehicleFromJSON(folderPath: vehicleFolderPath)
//
//        // THEN : Le véhicule doit être mis à jour
//        let updatedRecord = try await databaseManager.read { db in
//            try VehicleRecord.where { $0.id.in([vehicleId]) }.fetchOne(db)
//        }
//
//        XCTAssertEqual(updatedRecord?.model, "Polo")
//        XCTAssertEqual(updatedRecord?.mileage, "50000")
//        XCTAssertFalse(updatedRecord?.isPrimary ?? true)
//    }
//
//    // MARK: - Scan and Rebuild Tests
//
//    /// Test : Scan d'un dossier racine avec plusieurs véhicules
//    func test_scan_dossier_racine_avec_plusieurs_vehicules() async throws {
//        // GIVEN : Un dossier racine avec 3 sous-dossiers de véhicules
//        let vehicleIds = [UUID(), UUID(), UUID()]
//        let brands = ["Toyota", "Honda", "Mazda"]
//        let models = ["Corolla", "Civic", "3"]
//
//        for (index, vehicleId) in vehicleIds.enumerated() {
//            let vehicleFolderPath = tempFolderPath.appending("/vehicle_\(index)")
//            try FileManager.default.createDirectory(atPath: vehicleFolderPath, withIntermediateDirectories: true)
//
//            let metadataFile = VehicleMetadataFile(
//                vehicle: VehicleDTO(
//                    id: vehicleId,
//                    type: "Car",
//                    brand: brands[index],
//                    model: models[index],
//                    mileage: "\(10000 * (index + 1))",
//                    registrationDate: Date(),
//                    plate: "XX-\(index)-YY",
//                    isPrimary: index == 0,
//                    createdAt: Date(),
//                    updatedAt: Date()
//                ),
//                files: [],
//                metadata: VehicleMetadataFile.MetadataInfo(
//                    version: "1.0",
//                    lastSyncedAt: Date(),
//                    appVersion: "1.0.0"
//                )
//            )
//
//            let encoder = JSONEncoder()
//            encoder.dateEncodingStrategy = .iso8601
//            encoder.outputFormatting = [.prettyPrinted]
//
//            let jsonData = try encoder.encode(metadataFile)
//            let jsonURL = URL(fileURLWithPath: vehicleFolderPath)
//                .appendingPathComponent(".vehicle_metadata.json")
//            try jsonData.write(to: jsonURL)
//        }
//
//        // WHEN : Scan et reconstruction
//        let importedIds = try await syncManager.scanAndRebuildDatabase(rootFolderPath: tempFolderPath)
//
//        // THEN : Tous les véhicules doivent être importés
//        XCTAssertEqual(importedIds.count, 3, "3 véhicules doivent être importés")
//        XCTAssertEqual(Set(importedIds), Set(vehicleIds), "Les IDs importés doivent correspondre")
//
//        // Vérifier dans la BDD
//        let allVehicles = try await databaseManager.read { db in
//            try VehicleRecord.all.fetchAll(db)
//        }
//
//        XCTAssertEqual(allVehicles.count, 3)
//        XCTAssertTrue(allVehicles.contains { $0.brand == "Toyota" })
//        XCTAssertTrue(allVehicles.contains { $0.brand == "Honda" })
//        XCTAssertTrue(allVehicles.contains { $0.brand == "Mazda" })
//    }
//
//    /// Test : Scan ignore les dossiers sans fichier de métadonnées
//    func test_scan_ignore_dossiers_sans_metadata() async throws {
//        // GIVEN : Un dossier racine avec 2 véhicules valides et 1 dossier sans JSON
//        let validVehicleId1 = UUID()
//        let validVehicleId2 = UUID()
//
//        // Véhicule 1 (valide)
//        let vehicle1Path = tempFolderPath.appending("/valid_vehicle_1")
//        try FileManager.default.createDirectory(atPath: vehicle1Path, withIntermediateDirectories: true)
//
//        let metadata1 = VehicleMetadataFile(
//            vehicle: VehicleDTO(
//                id: validVehicleId1,
//                type: "Car",
//                brand: "Audi",
//                model: "A4",
//                mileage: "60000",
//                registrationDate: Date(),
//                plate: "AA-111-BB",
//                isPrimary: true,
//                createdAt: Date(),
//                updatedAt: Date()
//            ),
//            files: [],
//            metadata: VehicleMetadataFile.MetadataInfo(
//                version: "1.0",
//                lastSyncedAt: Date(),
//                appVersion: "1.0.0"
//            )
//        )
//
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//
//        let json1 = try encoder.encode(metadata1)
//        try json1.write(to: URL(fileURLWithPath: vehicle1Path).appendingPathComponent(".vehicle_metadata.json"))
//
//        // Véhicule 2 (valide)
//        let vehicle2Path = tempFolderPath.appending("/valid_vehicle_2")
//        try FileManager.default.createDirectory(atPath: vehicle2Path, withIntermediateDirectories: true)
//
//        let metadata2 = VehicleMetadataFile(
//            vehicle: VehicleDTO(
//                id: validVehicleId2,
//                type: "Car",
//                brand: "Mercedes",
//                model: "C220",
//                mileage: "70000",
//                registrationDate: Date(),
//                plate: "CC-222-DD",
//                isPrimary: false,
//                createdAt: Date(),
//                updatedAt: Date()
//            ),
//            files: [],
//            metadata: VehicleMetadataFile.MetadataInfo(
//                version: "1.0",
//                lastSyncedAt: Date(),
//                appVersion: "1.0.0"
//            )
//        )
//
//        let json2 = try encoder.encode(metadata2)
//        try json2.write(to: URL(fileURLWithPath: vehicle2Path).appendingPathComponent(".vehicle_metadata.json"))
//
//        // Dossier invalide (sans JSON)
//        let invalidPath = tempFolderPath.appending("/invalid_folder")
//        try FileManager.default.createDirectory(atPath: invalidPath, withIntermediateDirectories: true)
//
//        // WHEN : Scan
//        let importedIds = try await syncManager.scanAndRebuildDatabase(rootFolderPath: tempFolderPath)
//
//        // THEN : Seuls les 2 véhicules valides doivent être importés
//        XCTAssertEqual(importedIds.count, 2, "Seuls les dossiers avec JSON doivent être importés")
//        XCTAssertTrue(importedIds.contains(validVehicleId1))
//        XCTAssertTrue(importedIds.contains(validVehicleId2))
//    }
//
//    /// Test : Scan continue même si un import échoue
//    func test_scan_continue_malgre_erreur_import() async throws {
//        // GIVEN : Un dossier avec 1 JSON valide et 1 JSON invalide
//        let validVehicleId = UUID()
//
//        // Véhicule valide
//        let validPath = tempFolderPath.appending("/valid")
//        try FileManager.default.createDirectory(atPath: validPath, withIntermediateDirectories: true)
//
//        let validMetadata = VehicleMetadataFile(
//            vehicle: VehicleDTO(
//                id: validVehicleId,
//                type: "Car",
//                brand: "Nissan",
//                model: "Qashqai",
//                mileage: "45000",
//                registrationDate: Date(),
//                plate: "EE-333-FF",
//                isPrimary: true,
//                createdAt: Date(),
//                updatedAt: Date()
//            ),
//            files: [],
//            metadata: VehicleMetadataFile.MetadataInfo(
//                version: "1.0",
//                lastSyncedAt: Date(),
//                appVersion: "1.0.0"
//            )
//        )
//
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//
//        let validJSON = try encoder.encode(validMetadata)
//        try validJSON.write(to: URL(fileURLWithPath: validPath).appendingPathComponent(".vehicle_metadata.json"))
//
//        // Véhicule avec JSON invalide
//        let invalidPath = tempFolderPath.appending("/invalid")
//        try FileManager.default.createDirectory(atPath: invalidPath, withIntermediateDirectories: true)
//
//        let invalidJSON = "{ corrupted json }"
//        try invalidJSON.write(
//            to: URL(fileURLWithPath: invalidPath).appendingPathComponent(".vehicle_metadata.json"),
//            atomically: true,
//            encoding: .utf8
//        )
//
//        // WHEN : Scan (ne doit pas planter)
//        let importedIds = try await syncManager.scanAndRebuildDatabase(rootFolderPath: tempFolderPath)
//
//        // THEN : Le véhicule valide doit être importé malgré l'erreur sur l'autre
//        XCTAssertEqual(importedIds.count, 1, "Le véhicule valide doit être importé")
//        XCTAssertEqual(importedIds.first, validVehicleId)
//    }
//
//    // MARK: - Sync After Change Tests
//
//    /// Test : Sync automatique après modification
//    func test_sync_automatique_apres_modification() async throws {
//        // GIVEN : Un véhicule dans la BDD
//        let vehicleFolderPath = tempFolderPath.appending("/auto_sync")
//        try FileManager.default.createDirectory(atPath: vehicleFolderPath, withIntermediateDirectories: true)
//
//        let vehicleId = try await createTestVehicle(folderPath: vehicleFolderPath)
//
//        // WHEN : Sync après changement
//        try await syncManager.syncAfterChange(vehicleId: vehicleId)
//
//        // THEN : Le fichier JSON doit exister et être à jour
//        let metadataFile = try assertJSONFileExists(at: vehicleFolderPath)
//        XCTAssertEqual(metadataFile.vehicle.id, vehicleId)
//        XCTAssertEqual(metadataFile.vehicle.brand, "Toyota")
//    }
//
//    // MARK: - Validation Tests
//
//    /// Test : hasValidMetadata retourne true pour un JSON valide
//    func test_hasvalidmetadata_retourne_true_pour_json_valide() async throws {
//        // GIVEN : Un dossier avec un JSON valide
//        let vehicleFolderPath = tempFolderPath.appending("/valid_metadata")
//        try FileManager.default.createDirectory(atPath: vehicleFolderPath, withIntermediateDirectories: true)
//
//        let metadataFile = VehicleMetadataFile(
//            vehicle: VehicleDTO(
//                id: UUID(),
//                type: "Car",
//                brand: "Citroen",
//                model: "C3",
//                mileage: "35000",
//                registrationDate: Date(),
//                plate: "GG-444-HH",
//                isPrimary: false,
//                createdAt: Date(),
//                updatedAt: Date()
//            ),
//            files: [],
//            metadata: VehicleMetadataFile.MetadataInfo(
//                version: "1.0",
//                lastSyncedAt: Date(),
//                appVersion: "1.0.0"
//            )
//        )
//
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//
//        let jsonData = try encoder.encode(metadataFile)
//        let jsonURL = URL(fileURLWithPath: vehicleFolderPath)
//            .appendingPathComponent(".vehicle_metadata.json")
//        try jsonData.write(to: jsonURL)
//
//        // WHEN : Vérification de la validité
//        let isValid = await syncManager.hasValidMetadata(folderPath: vehicleFolderPath)
//
//        // THEN : Doit retourner true
//        XCTAssertTrue(isValid, "Le fichier JSON est valide")
//    }
//
//    /// Test : hasValidMetadata retourne false si le fichier n'existe pas
//    func test_hasvalidmetadata_retourne_false_si_fichier_inexistant() async throws {
//        // GIVEN : Un dossier sans fichier JSON
//        let emptyFolderPath = tempFolderPath.appending("/no_metadata")
//        try FileManager.default.createDirectory(atPath: emptyFolderPath, withIntermediateDirectories: true)
//
//        // WHEN : Vérification
//        let isValid = await syncManager.hasValidMetadata(folderPath: emptyFolderPath)
//
//        // THEN : Doit retourner false
//        XCTAssertFalse(isValid, "Aucun fichier JSON n'existe")
//    }
//
//    /// Test : hasValidMetadata retourne false si le JSON est invalide
//    func test_hasvalidmetadata_retourne_false_si_json_invalide() async throws {
//        // GIVEN : Un dossier avec un JSON corrompu
//        let corruptedFolderPath = tempFolderPath.appending("/corrupted_metadata")
//        try FileManager.default.createDirectory(atPath: corruptedFolderPath, withIntermediateDirectories: true)
//
//        let jsonURL = URL(fileURLWithPath: corruptedFolderPath)
//            .appendingPathComponent(".vehicle_metadata.json")
//
//        try "{ not valid json }".write(to: jsonURL, atomically: true, encoding: .utf8)
//
//        // WHEN : Vérification
//        let isValid = await syncManager.hasValidMetadata(folderPath: corruptedFolderPath)
//
//        // THEN : Doit retourner false
//        XCTAssertFalse(isValid, "Le JSON est invalide")
//    }
//
//    // MARK: - Edge Cases Tests
//
//    /// Test : Export et import préservent toutes les propriétés (round-trip)
//    func test_roundtrip_export_import_preserve_toutes_proprietes() async throws {
//        // GIVEN : Un véhicule complet avec toutes les propriétés
//        let vehicleFolderPath = tempFolderPath.appending("/roundtrip")
//        try FileManager.default.createDirectory(atPath: vehicleFolderPath, withIntermediateDirectories: true)
//
//        let vehicleId = UUID()
//        let specificDate = Date(timeIntervalSince1970: 1672531200)
//
//        try await databaseManager.write { db in
//            let record = VehicleRecord(
//                id: vehicleId,
//                type: "Truck",
//                brand: "MAN",
//                model: "TGX",
//                mileage: "150000",
//                registrationDate: specificDate,
//                plate: "TRUCK-01",
//                isPrimary: false,
//                folderPath: vehicleFolderPath,
//                createdAt: specificDate,
//                updatedAt: specificDate
//            )
//            try VehicleRecord.insert { record }.execute(db)
//        }
//
//        // WHEN : Export puis suppression puis import
//        try await syncManager.exportVehicleToJSON(vehicleId: vehicleId)
//
//        try await databaseManager.write { db in
//            try VehicleRecord.where { $0.id.in([vehicleId]) }.delete().execute(db)
//        }
//
//        _ = try await syncManager.importVehicleFromJSON(folderPath: vehicleFolderPath)
//
//        // THEN : Toutes les propriétés doivent être préservées
//        let reimportedRecord = try await databaseManager.read { db in
//            try VehicleRecord.where { $0.id.in([vehicleId]) }.fetchOne(db)
//        }
//
//        XCTAssertNotNil(reimportedRecord)
//        XCTAssertEqual(reimportedRecord?.id, vehicleId)
//        XCTAssertEqual(reimportedRecord?.type, "Truck")
//        XCTAssertEqual(reimportedRecord?.brand, "MAN")
//        XCTAssertEqual(reimportedRecord?.model, "TGX")
//        XCTAssertEqual(reimportedRecord?.mileage, "150000")
//        XCTAssertEqual(reimportedRecord?.plate, "TRUCK-01")
//        XCTAssertFalse(reimportedRecord?.isPrimary ?? true)
//    }
//
//    /// Test : Import supprime et recrée les fichiers (clean import)
//    func test_import_supprime_et_recree_fichiers() async throws {
//        // GIVEN : Un véhicule avec des fichiers existants dans la BDD
//        let vehicleFolderPath = tempFolderPath.appending("/clean_import")
//        try FileManager.default.createDirectory(atPath: vehicleFolderPath, withIntermediateDirectories: true)
//
//        let vehicleId = UUID()
//        try await databaseManager.write { db in
//            let vehicleRecord = VehicleRecord(
//                id: vehicleId,
//                type: "Car",
//                brand: "Opel",
//                model: "Astra",
//                mileage: "55000",
//                registrationDate: Date(),
//                plate: "OP-555-EL",
//                isPrimary: true,
//                folderPath: vehicleFolderPath,
//                createdAt: Date(),
//                updatedAt: Date()
//            )
//            try VehicleRecord.insert { vehicleRecord }.execute(db)
//
//            // Anciens fichiers
//            let oldFile1 = FileMetadataRecord(
//                id: UUID(),
//                vehicleId: vehicleId,
//                fileName: "old_file_1.pdf",
//                relativePath: "old/old_file_1.pdf",
//                documentType: "Other",
//                documentName: "Old File 1",
//                date: Date(),
//                mileage: "50000",
//                amount: nil,
//                fileSize: 500,
//                mimeType: "application/pdf",
//                createdAt: Date(),
//                modifiedAt: Date()
//            )
//            try FileMetadataRecord.insert { oldFile1 }.execute(db)
//        }
//
//        // Vérifier qu'il y a 1 fichier
//        let beforeCount = try await databaseManager.read { db in
//            try FileMetadataRecord.where { $0.vehicleId.in([vehicleId]) }.fetchCount(db)
//        }
//        XCTAssertEqual(beforeCount, 1)
//
//        // WHEN : Import d'un JSON avec de nouveaux fichiers différents
//        let metadataFile = VehicleMetadataFile(
//            vehicle: VehicleDTO(
//                id: vehicleId,
//                type: "Car",
//                brand: "Opel",
//                model: "Astra",
//                mileage: "60000",
//                registrationDate: Date(),
//                plate: "OP-555-EL",
//                isPrimary: true,
//                createdAt: Date(),
//                updatedAt: Date()
//            ),
//            files: [
//                FileMetadataDTO(
//                    id: UUID(),
//                    fileName: "new_file_1.pdf",
//                    relativePath: "new/new_file_1.pdf",
//                    documentType: "Insurance",
//                    documentName: "New File 1",
//                    date: Date(),
//                    mileage: "60000",
//                    amount: 300.0,
//                    fileSize: 1000,
//                    mimeType: "application/pdf",
//                    createdAt: Date(),
//                    modifiedAt: Date()
//                ),
//                FileMetadataDTO(
//                    id: UUID(),
//                    fileName: "new_file_2.pdf",
//                    relativePath: "new/new_file_2.pdf",
//                    documentType: "Maintenance",
//                    documentName: "New File 2",
//                    date: Date(),
//                    mileage: "60000",
//                    amount: 150.0,
//                    fileSize: 800,
//                    mimeType: "application/pdf",
//                    createdAt: Date(),
//                    modifiedAt: Date()
//                )
//            ],
//            metadata: VehicleMetadataFile.MetadataInfo(
//                version: "1.0",
//                lastSyncedAt: Date(),
//                appVersion: "1.0.0"
//            )
//        )
//
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        let jsonData = try encoder.encode(metadataFile)
//        let jsonURL = URL(fileURLWithPath: vehicleFolderPath)
//            .appendingPathComponent(".vehicle_metadata.json")
//        try jsonData.write(to: jsonURL)
//
//        _ = try await syncManager.importVehicleFromJSON(folderPath: vehicleFolderPath)
//
//        // THEN : Les anciens fichiers doivent être supprimés et remplacés par les nouveaux
//        let afterFiles = try await databaseManager.read { db in
//            try FileMetadataRecord.where { $0.vehicleId.in([vehicleId]) }.fetchAll(db)
//        }
//
//        XCTAssertEqual(afterFiles.count, 2, "Il doit y avoir 2 nouveaux fichiers")
//        XCTAssertTrue(afterFiles.contains { $0.fileName == "new_file_1.pdf" })
//        XCTAssertTrue(afterFiles.contains { $0.fileName == "new_file_2.pdf" })
//        XCTAssertFalse(afterFiles.contains { $0.fileName == "old_file_1.pdf" })
//    }
//}
