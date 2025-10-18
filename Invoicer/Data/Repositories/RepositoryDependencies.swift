//
//  RepositoryDependencies.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Centralized dependency configuration for all repositories
//

import Foundation
import UIKit
import Dependencies

// MARK: - Repository Dependencies Extension

extension DependencyValues {
    // All repository dependencies are automatically registered via their individual files:
    // - vehicleRepository: VehicleRepositoryProtocol (VehicleRepository.swift)
    // - documentRepository: DocumentRepositoryProtocol (DocumentRepository.swift)
    // - statisticsRepository: StatisticsRepositoryProtocol (StatisticsRepository.swift)
}

// MARK: - Mock Repositories for Testing

#if DEBUG

// MARK: - Mock Vehicle Repository

final class MockVehicleRepository: VehicleRepositoryProtocol, @unchecked Sendable {
    var vehicles: [Vehicle] = []
    var shouldThrowError = false
    var errorToThrow: Error?

    func loadAll() async throws -> [Vehicle] {
        if shouldThrowError {
            throw errorToThrow ?? RepositoryError.loadFailed("Mock error")
        }
        return vehicles
    }

    func save(_ vehicle: Vehicle) async throws {
        if shouldThrowError {
            throw errorToThrow ?? RepositoryError.saveFailed("Mock error")
        }
        vehicles.append(vehicle)
    }

    func update(_ vehicle: Vehicle) async throws {
        if shouldThrowError {
            throw errorToThrow ?? RepositoryError.saveFailed("Mock error")
        }
        guard let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) else {
            throw RepositoryError.notFound("Vehicle not found")
        }
        vehicles[index] = vehicle
    }

    func delete(_ vehicleId: UUID) async throws {
        if shouldThrowError {
            throw errorToThrow ?? RepositoryError.deleteFailed("Mock error")
        }
        vehicles.removeAll { $0.id == vehicleId }
    }

    func find(by id: UUID) async throws -> Vehicle? {
        if shouldThrowError {
            throw errorToThrow ?? RepositoryError.loadFailed("Mock error")
        }
        return vehicles.first { $0.id == id }
    }
}

// MARK: - Mock Document Repository

final class MockDocumentRepository: DocumentRepositoryProtocol, @unchecked Sendable {
    var shouldThrowError = false
    var errorToThrow: Error?
    var savedDocuments: [Document] = []

    func save(image: UIImage, for vehicleId: UUID, metadata: DocumentMetadata) async throws -> Document {
        if shouldThrowError {
            throw errorToThrow ?? RepositoryError.saveFailed("Mock error")
        }
        let document = Document(
            fileURL: "/mock/path/\(UUID().uuidString).jpg",
            name: metadata.name,
            date: metadata.date,
            mileage: metadata.mileage,
            type: metadata.type,
            amount: metadata.amount
        )
        savedDocuments.append(document)
        return document
    }

    func save(fileURL: URL, for vehicleId: UUID, metadata: DocumentMetadata) async throws -> Document {
        if shouldThrowError {
            throw errorToThrow ?? RepositoryError.saveFailed("Mock error")
        }
        let document = Document(
            fileURL: fileURL.path,
            name: metadata.name,
            date: metadata.date,
            mileage: metadata.mileage,
            type: metadata.type,
            amount: metadata.amount
        )
        savedDocuments.append(document)
        return document
    }

    func update(_ document: Document, for vehicleId: UUID) async throws {
        if shouldThrowError {
            throw errorToThrow ?? RepositoryError.saveFailed("Mock error")
        }
        guard let index = savedDocuments.firstIndex(where: { $0.id == document.id }) else {
            throw RepositoryError.notFound("Document not found")
        }
        savedDocuments[index] = document
    }

    func delete(_ documentId: UUID, for vehicleId: UUID) async throws {
        if shouldThrowError {
            throw errorToThrow ?? RepositoryError.deleteFailed("Mock error")
        }
        savedDocuments.removeAll { $0.id == documentId }
    }

    func replacePhoto(_ documentId: UUID, for vehicleId: UUID, with newImage: UIImage) async throws {
        if shouldThrowError {
            throw errorToThrow ?? RepositoryError.saveFailed("Mock error")
        }
        guard let index = savedDocuments.firstIndex(where: { $0.id == documentId }) else {
            throw RepositoryError.notFound("Document not found")
        }
        savedDocuments[index].fileURL = "/mock/path/\(UUID().uuidString).jpg"
    }
}

// MARK: - Mock Statistics Repository

final class MockStatisticsRepository: StatisticsRepositoryProtocol, @unchecked Sendable {
    var mockTotalCost: Double = 0
    var mockMonthlyExpenses: [MonthlyExpense] = []

    func calculateTotalCost(for documents: [Document]) -> Double {
        mockTotalCost
    }

    func calculateMonthlyExpenses(for documents: [Document], year: Int) -> [MonthlyExpense] {
        mockMonthlyExpenses
    }

    func calculateYearlyTotal(for documents: [Document], year: Int) -> Double {
        mockTotalCost
    }

    func calculateAverageMonthlyCost(for documents: [Document], year: Int) -> Double {
        let monthsWithExpenses = mockMonthlyExpenses.filter { $0.amount > 0 }.count
        return monthsWithExpenses > 0 ? mockTotalCost / Double(monthsWithExpenses) : 0
    }

    func groupDocumentsByCategory(for documents: [Document]) -> [StatisticsDocumentCategory: [Document]] {
        Dictionary(grouping: documents) { _ in .other }
    }

    func calculateCategoryTotals(for documents: [Document]) -> [StatisticsDocumentCategory: Double] {
        [.other: mockTotalCost]
    }
}

// MARK: - Test Dependency Values

extension DependencyValues {
    /// Returns a mock vehicle repository for testing
    static var mockVehicleRepository: MockVehicleRepository {
        MockVehicleRepository()
    }

    /// Returns a mock document repository for testing
    static var mockDocumentRepository: MockDocumentRepository {
        MockDocumentRepository()
    }

    /// Returns a mock statistics repository for testing
    static var mockStatisticsRepository: MockStatisticsRepository {
        MockStatisticsRepository()
    }
}

#endif
