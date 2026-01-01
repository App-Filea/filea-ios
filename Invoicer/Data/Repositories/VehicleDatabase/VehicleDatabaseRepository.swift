//
//  VehicleDatabaseRepository.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 26/10/2025.
//

import Foundation
import GRDB
import Dependencies

actor VehicleDatabaseRepository {
    private let database: DatabaseManager

    init(database: DatabaseManager) {
        self.database = database
    }

    func create(vehicle: Vehicle, folderPath: String) async throws {
        let record = vehicle.toRecord(folderPath: folderPath)

        try await database.write { db in
            try VehicleRecord.insert { record }.execute(db)
        }
    }

    func fetchAll() async throws -> [Vehicle] {
        try await database.read { db -> [Vehicle] in
            let vehicleRecords = try VehicleRecord.all.fetchAll(db)

            return try vehicleRecords.map { vehicleRecord in
                // Fetch documents for each vehicle
                let fileRecords = try FileMetadataRecord
                    .where { $0.vehicleId.in([vehicleRecord.id]) }
                    .order { $0.date.desc() }
                    .fetchAll(db)

                var vehicle = vehicleRecord.toDomain()
                vehicle.documents = fileRecords.map {
                    $0.toDomain(vehicleFolderPath: vehicleRecord.folderPath)
                }

                return vehicle
            }
        }
    }

    func fetch(id: String) async throws -> Vehicle? {
        try await database.read { db in
            let record = try VehicleRecord.where { $0.id.in([id]) }.fetchOne(db)
            return record?.toDomain()
        }
    }

    func fetchPrimary() async throws -> Vehicle? {
        try await database.read { db in
            let record = try VehicleRecord.where(\.isPrimary).fetchOne(db)
            return record?.toDomain()
        }
    }

    func fetchWithDocuments(id: String) async throws -> Vehicle? {
        try await database.read { db -> Vehicle? in
            guard let vehicleRecord = try VehicleRecord.where { $0.id.in([id]) }.fetchOne(db) else {
                return nil
            }

            let fileRecords = try FileMetadataRecord
                .where { $0.vehicleId.in([id]) }
                .order { $0.date.desc() }
                .fetchAll(db)

            var vehicle = vehicleRecord.toDomain()
            vehicle.documents = fileRecords.map { $0.toDomain(vehicleFolderPath: vehicleRecord.folderPath) }

            return vehicle
        }
    }

    func update(vehicle: Vehicle, folderPath: String) async throws {
        var record = vehicle.toRecord(folderPath: folderPath)
        record.updatedAt = Date()

        try await database.write { db in
            try VehicleRecord.upsert { record }.execute(db)
        }
    }

    func setPrimary(id: String) async throws {
        try await database.write { db in
            let records = try VehicleRecord.all.fetchAll(db)

            for var record in records {
                let shouldBePrimary = record.id == id
                if record.isPrimary != shouldBePrimary {
                    record.isPrimary = shouldBePrimary
                    record.updatedAt = Date()
                    try VehicleRecord.upsert { record }.execute(db)
                }
            }
        }
    }

    func delete(id: String) async throws {
        try await database.write { db in
            // 1. Delete all associated documents (cascade delete)
            try FileMetadataRecord
                .where { $0.vehicleId.in([id]) }
                .delete()
                .execute(db)

            // 2. Delete vehicle
            try VehicleRecord.where { $0.id.in([id]) }.delete().execute(db)
        }
    }

    func count() async throws -> Int {
        try await database.read { db in
            try VehicleRecord.all.fetchCount(db)
        }
    }
}
