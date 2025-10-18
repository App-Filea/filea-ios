//
//  VehicleMetadataFile.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 18/10/2025.
//

import Foundation

/// Structure complète du fichier JSON de métadonnées d'un véhicule
/// Contient le véhicule, ses fichiers et les infos de version
struct VehicleMetadataFile: Codable {
    // MARK: - Properties

    /// Données du véhicule
    var vehicle: VehicleDTO

    /// Liste des métadonnées des fichiers
    var files: [FileMetadataDTO]

    /// Métadonnées du fichier JSON lui-même
    var metadata: MetadataInfo

    // MARK: - Nested Types

    /// Informations sur la version du fichier JSON
    struct MetadataInfo: Codable {
        /// Version du format JSON
        var version: String

        /// Date de dernière synchronisation
        var lastSyncedAt: Date

        /// Version de l'application qui a créé ce fichier
        var appVersion: String

        enum CodingKeys: String, CodingKey {
            case version
            case lastSyncedAt
            case appVersion
        }
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case vehicle
        case files
        case metadata
    }
}
