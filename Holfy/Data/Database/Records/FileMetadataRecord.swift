//
//  FileMetadataRecord.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 18/10/2025.
//

import Foundation
import GRDB
import SQLiteData

/// Record de persistence pour les métadonnées de fichiers
/// Utilisé uniquement pour la couche base de données
@Table
struct FileMetadataRecord {
    // MARK: - Properties

    /// Identifiant unique du fichier
    let id: String

    /// Identifiant du véhicule associé
    var vehicleId: String

    /// Nom du fichier (avec extension)
    var fileName: String

    /// Chemin relatif du fichier par rapport au dossier véhicule
    var relativePath: String

    /// Type du document (ex: "Assurance", "Vidange", etc.)
    var documentType: String

    /// Nom personnalisé du document
    var documentName: String

    /// Date du document
    var date: Date

    /// Kilométrage au moment du document
    var mileage: String

    /// Montant associé au document
    var amount: Double?

    /// Taille du fichier en octets
    var fileSize: Int64

    /// Type MIME du fichier
    var mimeType: String

    /// Date de création de l'enregistrement
    var createdAt: Date

    /// Date de dernière modification
    var modifiedAt: Date
}
