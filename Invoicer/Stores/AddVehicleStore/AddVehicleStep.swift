//
//  AddVehicleStep.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import Foundation

enum AddVehicleStep: Int, CaseIterable, Identifiable {
    case type = 0
    case brandAndModel = 1
    case details = 2
    case summary = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .type: return "Type"
        case .brandAndModel: return "Identification"
        case .details: return "Détails"
        case .summary: return "Récapitulatif"
        }
    }

    var subtitle: String {
        switch self {
        case .type: return "Quel type de véhicule souhaitez-vous ajouter ?"
        case .brandAndModel: return "Quelle est la marque et le modèle de votre véhicule ?"
        case .details: return "Complétez les informations du véhicule"
        case .summary: return "Vérifiez les informations saisies"
        }
    }

    var buttonTitle: String {
        switch self {
        case .summary: return "Créer le véhicule"
        default: return "Continuer"
        }
    }

    var progress: Double {
        Double(rawValue) / Double(AddVehicleStep.allCases.count - 1)
    }

    var next: AddVehicleStep? {
        let nextIndex = rawValue + 1
        return AddVehicleStep.allCases.first { $0.rawValue == nextIndex }
    }

    var previous: AddVehicleStep? {
        let previousIndex = rawValue - 1
        return AddVehicleStep.allCases.first { $0.rawValue == previousIndex }
    }

    func validate(type: VehicleType?, brand: String, model: String, plate: String, registrationDate: Date, mileage: String) -> (isValid: Bool, errorMessage: String?) {
        switch self {
        case .type:
            if type == nil {
                return (false, "Le type de véhicule est obligatoire")
            }
            return (true, nil)
        case .brandAndModel:
            // Validate both brand and model
            let brandValid = !brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if !brandValid {
                return (false, "La marque est obligatoire")
            }
            let modelValid = !model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if !modelValid {
                return (false, "Le modèle est obligatoire")
            }
            return (true, nil)
        case .details:
            // Validate plate and date (mileage is optional)
            let plateValid = !plate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if !plateValid {
                return (false, "La plaque d'immatriculation est obligatoire")
            }
            // Mileage is optional, no validation needed
            // Date always valid, has default value
            return (true, nil)
        case .summary:
            // Validate all fields
            let allSteps = AddVehicleStep.allCases.filter { $0 != .summary }
            for step in allSteps {
                let validation = step.validate(type: type, brand: brand, model: model, plate: plate, registrationDate: registrationDate, mileage: mileage)
                if !validation.isValid {
                    return validation
                }
            }
            return (true, nil)
        }
    }
}