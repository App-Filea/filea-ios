//
//  AddVehicleStep.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import Foundation

enum AddVehicleStep: Int, CaseIterable, Identifiable {
    case brand = 0
    case model = 1
    case plate = 2
    case mileage = 3
    case date = 4
    case summary = 5
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .brand: return "Marque du véhicule"
        case .model: return "Modèle du véhicule"
        case .plate: return "Plaque d'immatriculation"
        case .mileage: return "Kilométrage actuel"
        case .date: return "Date de mise en circulation"
        case .summary: return "Récapitulatif"
        }
    }
    
    var subtitle: String {
        switch self {
        case .brand: return "Quelle est la marque de votre véhicule ?"
        case .model: return "Quel est le modèle de votre véhicule ?"
        case .plate: return "Quelle est la plaque d'immatriculation ?"
        case .mileage: return "Quel est le kilométrage actuel ?"
        case .date: return "Quelle est la date de mise en circulation ?"
        case .summary: return "Vérifiez les informations saisies"
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .summary: return "Créer le véhicule"
        default: return "Continuer"
        }
    }
}