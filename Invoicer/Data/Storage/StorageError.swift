//
//  StorageError.swift
//  Invoicer
//
//  Created by Claude on 2025-01-18.
//  Custom errors for storage management operations
//

import Foundation

/// Errors that can occur during storage operations
enum StorageError: LocalizedError, Equatable {
    case notConfigured
    case bookmarkCreationFailed
    case bookmarkResolutionFailed
    case accessDenied
    case folderCreationFailed(String)
    case fileSaveFailed(String)
    case securityScopedResourceAccessFailed

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Le stockage n'est pas encore configuré. Veuillez sélectionner un dossier."
        case .bookmarkCreationFailed:
            return "Impossible de créer le bookmark de sécurité."
        case .bookmarkResolutionFailed:
            return "Impossible de restaurer l'accès au dossier de stockage."
        case .accessDenied:
            return "Accès au dossier de stockage refusé."
        case .folderCreationFailed(let path):
            return "Impossible de créer le dossier: \(path)"
        case .fileSaveFailed(let filename):
            return "Impossible de sauvegarder le fichier: \(filename)"
        case .securityScopedResourceAccessFailed:
            return "Échec de l'accès sécurisé aux ressources."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .notConfigured:
            return "Sélectionnez un dossier de stockage dans les réglages."
        case .bookmarkCreationFailed, .bookmarkResolutionFailed:
            return "Essayez de sélectionner à nouveau le dossier de stockage."
        case .accessDenied:
            return "Vérifiez les autorisations d'accès au dossier."
        case .folderCreationFailed, .fileSaveFailed:
            return "Vérifiez l'espace disque disponible et les permissions."
        case .securityScopedResourceAccessFailed:
            return "Redémarrez l'application et sélectionnez à nouveau le dossier."
        }
    }
}
