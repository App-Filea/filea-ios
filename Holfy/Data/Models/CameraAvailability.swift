//
//  CameraAvailability.swift
//  Invoicer
//
//  Created by Claude Code on 20/10/2025.
//

import Foundation

/// État de disponibilité de la caméra et du DataScanner
enum CameraAvailability: Equatable, Sendable {
    case checking
    case available
    case notSupported(reason: String)
    case accessDenied
    case unavailable

    var canScan: Bool {
        if case .available = self {
            return true
        }
        return false
    }

    var errorMessage: String? {
        switch self {
        case .checking, .available:
            return nil
        case .notSupported(let reason):
            return reason
        case .accessDenied:
            return "Accès à la caméra refusé. Veuillez autoriser l'accès dans les Réglages."
        case .unavailable:
            return "La caméra n'est pas disponible pour le moment."
        }
    }
}
