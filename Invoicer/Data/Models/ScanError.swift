//
//  ScanError.swift
//  Invoicer
//
//  Created by Claude Code on 20/10/2025.
//

import Foundation

/// Erreurs possibles lors du scan OCR
enum ScanError: Error, Equatable, LocalizedError, Sendable {
    case cameraUnavailable
    case cameraAccessDenied
    case dataScannerNotSupported
    case textRecognitionFailed
    case noTextDetected
    case parsingFailed(reason: String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .cameraUnavailable:
            return "La caméra n'est pas disponible sur cet appareil."
        case .cameraAccessDenied:
            return "L'accès à la caméra a été refusé. Veuillez autoriser l'accès dans les Réglages."
        case .dataScannerNotSupported:
            return "La reconnaissance de texte en temps réel n'est pas supportée sur cet appareil. Vous pouvez utiliser la saisie manuelle."
        case .textRecognitionFailed:
            return "Impossible de détecter du texte. Assurez-vous que le document est bien éclairé et lisible."
        case .noTextDetected:
            return "Aucun texte n'a été détecté. Essayez de repositionner le document."
        case .parsingFailed(let reason):
            return "Erreur lors de l'analyse du document : \(reason)"
        case .unknown(let message):
            return "Erreur inconnue : \(message)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .cameraAccessDenied:
            return "Ouvrez l'application Réglages > Confidentialité > Appareil photo et activez l'accès pour Filea."
        case .dataScannerNotSupported:
            return "Utilisez la saisie manuelle pour ajouter votre véhicule."
        case .textRecognitionFailed, .noTextDetected:
            return "Améliorez l'éclairage, nettoyez l'objectif et assurez-vous que le texte est net."
        default:
            return "Réessayez ou utilisez la saisie manuelle."
        }
    }
}
