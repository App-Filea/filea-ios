//
//  Vehicle.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import Foundation

enum VehicleType: String, Codable, CaseIterable, Identifiable {
    case car = "Car"
    case motorcycle = "Motorcycle"
    case truck = "Truck"
    case bicycle = "Bicycle"
    case other = "Other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .car: return "Voiture"
        case .motorcycle: return "Moto"
        case .truck: return "Camion"
        case .bicycle: return "Vélo"
        case .other: return "Autre"
        }
    }

    var iconName: String? {
        switch self {
        case .car: return "car.side"
        case .motorcycle: return "motorcycle"
        case .truck: return "truck.box"
        case .bicycle: return "bicycle"
        case .other: return nil
        }
    }

    var shouldFlipIcon: Bool {
        switch self {
        case .car: return false
        case .motorcycle, .truck, .bicycle: return true
        case .other: return false
        }
    }
}

struct Vehicle: Codable, Equatable, Identifiable {

    let id: UUID
    var type: VehicleType
    var brand: String
    var model: String
    var mileage: String?
    var registrationDate: Date
    var plate: String
    var isPrimary: Bool
    var documents: [Document] = []

    init(id: UUID? = nil,
         type: VehicleType = .car,
         brand: String = "",
         model: String = "",
         mileage: String? = nil,
         registrationDate: Date = .now,
         plate: String = "",
         isPrimary: Bool = false,
         documents: [Document] = []) {
        self.id = id ?? UUID()
        self.type = type
        self.brand = brand
        self.model = model
        self.mileage = mileage
        self.registrationDate = registrationDate
        self.plate = plate
        self.isPrimary = isPrimary
        self.documents = documents
    }
}
