//
//  Vehicle.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import Foundation

struct Vehicle: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var currentMileage: String
    var registrationDate: String
    var licensePlate: String
    var documents: [Document] = []
    
    init(name: String = "", currentMileage: String = "", registrationDate: String = "", licensePlate: String = "", documents: [Document] = []) {
        self.id = UUID()
        self.name = name
        self.currentMileage = currentMileage
        self.registrationDate = registrationDate
        self.licensePlate = licensePlate
        self.documents = documents
    }
}