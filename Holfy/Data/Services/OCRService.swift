//
//  OCRService.swift
//  Invoicer
//
//  Created by Claude Code on 20/10/2025.
//

import Foundation
import VisionKit
import Vision
import UIKit
import AVFoundation
import Dependencies

/// Service de reconnaissance de texte OCR avec VisionKit et Vision Framework
struct OCRService: Sendable {

    /// Vérifie si DataScanner est disponible sur le device
    var isDataScannerAvailable: @Sendable () async -> Bool

    /// Reconnaissance de texte statique avec Vision Framework
    var recognizeTextStatic: @Sendable (UIImage) async throws -> String

    /// Vérifie la disponibilité de la caméra
    var checkCameraAvailability: @Sendable () async -> CameraAvailability
}

// MARK: - Dependency Key

extension OCRService: DependencyKey {
    static let liveValue = OCRService(
        isDataScannerAvailable: {
            await MainActor.run {
                DataScannerViewController.isSupported && DataScannerViewController.isAvailable
            }
        },

        recognizeTextStatic: { image in
            return try await Self.performVisionOCR(on: image)
        },

        checkCameraAvailability: {
            print("🔍 [OCRService] Vérification de la disponibilité de la caméra")

            // Check 1: Device support
            let isSupported = await MainActor.run { DataScannerViewController.isSupported }
            guard isSupported else {
                print("   ├─ DataScanner non supporté (iOS 16+ requis ou device incompatible)")
                return .notSupported(reason: "Votre appareil ne supporte pas la reconnaissance de texte en temps réel. iOS 16+ requis.")
            }

            // Check 2: DataScanner availability
            let isAvailable = await MainActor.run { DataScannerViewController.isAvailable }
            guard isAvailable else {
                print("   ├─ DataScanner non disponible (peut-être désactivé dans les réglages)")
                return .unavailable
            }

            // Check 3: Camera authorization
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                print("✅ [OCRService] Caméra disponible et autorisée\n")
                return .available
            case .denied, .restricted:
                print("❌ [OCRService] Accès caméra refusé\n")
                return .accessDenied
            case .notDetermined:
                // Demander l'autorisation
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                print(granted ? "✅ [OCRService] Autorisation caméra accordée\n" : "❌ [OCRService] Autorisation caméra refusée\n")
                return granted ? .available : .accessDenied
            @unknown default:
                print("⚠️ [OCRService] Statut caméra inconnu\n")
                return .unavailable
            }
        }
    )

    // MARK: - Vision Framework OCR

    /// Effectue l'OCR sur une image avec Vision Framework
    private static func performVisionOCR(on image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw ScanError.textRecognitionFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    print("❌ [OCRService] Vision OCR failed: \(error.localizedDescription)")
                    continuation.resume(throwing: ScanError.textRecognitionFailed)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    print("❌ [OCRService] No text observations found")
                    continuation.resume(throwing: ScanError.noTextDetected)
                    return
                }

                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                if recognizedStrings.isEmpty {
                    print("❌ [OCRService] No text recognized")
                    continuation.resume(throwing: ScanError.noTextDetected)
                } else {
                    let fullText = recognizedStrings.joined(separator: "\n")
                    print("✅ [OCRService] Recognized \(recognizedStrings.count) lines of text")
                    continuation.resume(returning: fullText)
                }
            }

            // Configuration pour améliorer la reconnaissance
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["fr-FR", "en-US"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                print("❌ [OCRService] Handler perform failed: \(error.localizedDescription)")
                continuation.resume(throwing: ScanError.textRecognitionFailed)
            }
        }
    }
}

// MARK: - Test/Preview Values

extension OCRService {
    static let testValue = OCRService(
        isDataScannerAvailable: { true },
        recognizeTextStatic: { _ in "Mock OCR Text" },
        checkCameraAvailability: { .available }
    )

    static let previewValue = testValue
}

// MARK: - Dependency Extension

extension DependencyValues {
    var ocrService: OCRService {
        get { self[OCRService.self] }
        set { self[OCRService.self] = newValue }
    }
}
