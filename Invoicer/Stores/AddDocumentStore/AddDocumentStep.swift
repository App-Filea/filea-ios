//
//  AddDocumentStep.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 13/10/2025.
//

import Foundation

enum AddDocumentStep: Int, CaseIterable, Identifiable {
    case selectSource = 0
    case metadata = 1

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .selectSource:
            return "Source du Document"
        case .metadata:
            return "Informations"
        }
    }

    var subtitle: String {
        switch self {
        case .selectSource:
            return "Choisissez comment ajouter votre document"
        case .metadata:
            return "Renseignez les détails du document"
        }
    }

    var next: AddDocumentStep? {
        let nextValue = rawValue + 1
        return AddDocumentStep(rawValue: nextValue)
    }

    var previous: AddDocumentStep? {
        let previousValue = rawValue - 1
        return AddDocumentStep(rawValue: previousValue)
    }

    func validate(
        hasSource: Bool,
        name: String,
        mileage: String,
        amount: String
    ) -> (isValid: Bool, error: String?) {
        switch self {
        case .selectSource:
            if !hasSource {
                return (false, "Veuillez capturer une photo ou sélectionner un fichier")
            }
            return (true, nil)

        case .metadata:
            if name.isEmpty {
                return (false, "Le nom du document est requis")
            }
            if mileage.isEmpty {
                return (false, "Le kilométrage est requis")
            }
            if amount.isEmpty {
                return (false, "Le montant est requis")
            }
            if Double(amount.replacingOccurrences(of: ",", with: ".")) == nil {
                return (false, "Montant invalide")
            }
            return (true, nil)
        }
    }
}
