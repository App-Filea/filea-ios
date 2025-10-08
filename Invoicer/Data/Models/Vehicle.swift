//
//  Vehicle.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import Foundation

struct Vehicle: Codable, Equatable, Identifiable {

    let id: UUID
//    var nickname: String?
    var brand: String
    var model: String
    var mileage: String
    var registrationDate: Date
    var plate: String
    var documents: [Document] = []

    init(/*nickname: String? = nil, */brand: String = "", model: String = "", mileage: String = "", registrationDate: Date = .now, plate: String = "", documents: [Document] = []) {
        self.id = UUID()
//        self.nickname = nickname
        self.brand = brand
        self.model = model
        self.mileage = mileage
        self.registrationDate = registrationDate
        self.plate = plate
        self.documents = documents
    }
}
