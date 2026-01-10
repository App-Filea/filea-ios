//
//  VehicleRecord.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 18/10/2025.
//

import Foundation
import GRDB
import SQLiteData

/// Record de persistence pour les véhicules
/// Utilisé uniquement pour la couche base de données
@Table
struct VehicleRecord {
    // MARK: - Properties

    /// Identifiant unique du véhicule
    let id: String

    /// Type du véhicule (car, motorcycle, truck, etc.)
    var type: String

    /// Marque du véhicule
    var brand: String

    /// Modèle du véhicule
    var model: String

    /// Kilométrage (stocké comme String)
    var mileage: String?

    /// Date d'immatriculation
    var registrationDate: Date

    /// Plaque d'immatriculation
    var plate: String

    /// Indique si c'est le véhicule principal
    var isPrimary: Bool

    /// Chemin du dossier contenant les fichiers du véhicule
    var folderPath: String

    /// Date de création de l'enregistrement
    var createdAt: Date

    /// Date de dernière modification
    var updatedAt: Date
}
