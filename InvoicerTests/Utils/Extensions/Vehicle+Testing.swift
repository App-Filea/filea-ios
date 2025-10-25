//
//  Vehicle+Testing.swift
//  InvoicerTests
//
//  Created by Nicolas Barbosa on 25/10/2025.
//

import Foundation
import Dependencies
@testable import Invoicer

/// Extension for creating test fixtures of Vehicle
extension Vehicle {
    /// Creates a Vehicle with sensible default values for testing
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - type: Vehicle type (defaults to .car)
    ///   - brand: Vehicle brand (defaults to "Tesla")
    ///   - model: Vehicle model (defaults to "Model 3")
    ///   - mileage: Vehicle mileage (defaults to "50000")
    ///   - registrationDate: Registration date (defaults to now)
    ///   - plate: License plate (defaults to unique "TEST-XXX")
    ///   - isPrimary: Whether this is the primary vehicle (defaults to false)
    ///   - documents: Associated documents (defaults to empty array)
    /// - Returns: A Vehicle instance configured for testing
    static func make(
        id: UUID = UUID(),
        type: VehicleType = .car,
        brand: String = "Tesla",
        model: String = "Model 3",
        mileage: String? = "50000",
        registrationDate: Date = Date(timeIntervalSince1970: 0),
        plate: String = "TEST-PLATE",
        isPrimary: Bool = false,
        documents: [Document] = []
    ) -> Vehicle {
        Vehicle(
            id: id,
            type: type,
            brand: brand,
            model: model,
            mileage: mileage,
            registrationDate: registrationDate,
            plate: plate,
            isPrimary: isPrimary,
            documents: documents
        )
    }
}
