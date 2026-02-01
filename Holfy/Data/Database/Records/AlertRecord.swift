//
//  AlertRecord.swift
//  Holfy
//
//  Created by Claude on 2026-02-01.
//  GRDB Record for persisting alerts
//

import Foundation
import GRDB
import SQLiteData

/// Record de persistence pour les alertes véhicules
/// Utilisé uniquement pour la couche base de données
@Table
struct AlertRecord {
    // MARK: - Properties

    /// Identifiant unique de l'alerte
    let id: String

    /// Titre de l'alerte
    var title: String

    /// Message descriptif de l'alerte
    var message: String

    /// Date de création de l'alerte
    var date: Date

    /// Indique si l'alerte a été lue
    var isRead: Bool

    /// Indique si l'alerte a été masquée
    var isDismissed: Bool

    /// Identifiant du véhicule associé (FK vers vehicleRecords)
    var vehicleId: String

    /// Date limite de l'alerte (ex: expiration CT)
    var deadline: Date?

    /// Catégorie de l'alerte (document, maintenance, reminder)
    var category: String

    /// Priorité de l'alerte (low, medium, high)
    var priority: String

    /// Indique si l'alerte peut être masquée par l'utilisateur
    var isDismissable: Bool

    /// Identifiant du document lié (FK optionnel vers fileMetadataRecords)
    var relatedDocumentId: String?

    /// Date de création de l'enregistrement
    var createdAt: Date

    /// Date de dernière modification
    var updatedAt: Date
}
