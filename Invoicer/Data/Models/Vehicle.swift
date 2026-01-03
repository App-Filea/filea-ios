//
//  Vehicle.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import Foundation
import SwiftUI

enum VehicleType: String, Codable, CaseIterable, Identifiable {
    case car
    case motorcycle
    case truck
    case bicycle
    case other

    var id: String { rawValue }

    var displayName: LocalizedStringKey {
        switch self {
        case .car: return "all_vehicle_type_car"
        case .motorcycle: return "all_vehicle_type_motorcycle"
        case .truck: return "all_vehicle_type_truck"
        case .bicycle: return "all_vehicle_type_bicycle"
        case .other: return "all_vehicle_type_other"
        }
    }

    var iconName: String {
        switch self {
        case .car: return "car.side"
        case .motorcycle: return "motorcycle"
        case .truck: return "truck.box"
        case .bicycle: return "bicycle"
        case .other: return "scooter"
        }
    }

    var shouldFlipIcon: Bool {
        switch self {
        case .car: return false
        case .motorcycle, .truck, .bicycle, .other: return true
        case .other: return false
        }
    }
}

struct Vehicle: Codable, Equatable, Identifiable {

    let id: String
    var type: VehicleType
    var brand: String
    var model: String
    var mileage: String?
    var registrationDate: Date
    var plate: String
    var isPrimary: Bool
    var documents: [Document] = []

    init(id: String,
         type: VehicleType = .car,
         brand: String = "",
         model: String = "",
         mileage: String? = nil,
         registrationDate: Date = .now,
         plate: String = "",
         isPrimary: Bool = false,
         documents: [Document] = []) {
        self.id = id
        self.type = type
        self.brand = brand
        self.model = model
        self.mileage = mileage
        self.registrationDate = registrationDate
        self.plate = plate
        self.isPrimary = isPrimary
        self.documents = documents
    }
    
    var isNull: Bool {
        self.id == "NULL" && self.brand == "NULL" && self.model == "NULL" && self.mileage == "NULL" && self.plate == "NULL"
    }
}

extension Vehicle {
    static func null() -> Self {
        .init(id: "NULL", type: .other, brand: "NULL", model: "NULL", mileage: "NULL", registrationDate: .now, plate: "NULL", isPrimary: false, documents: [])
    }
}
