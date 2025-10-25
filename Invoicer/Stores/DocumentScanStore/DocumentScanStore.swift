//
//  DocumentScanStore.swift
//  Invoicer
//
//  Created by Claude Code on 20/10/2025.
//

import ComposableArchitecture
import Foundation
import UIKit

@Reducer
struct DocumentScanStore {

    @ObservableState
    struct State: Equatable {
        var scanMode: ScanMode = .registrationCard
        var cameraAvailability: CameraAvailability = .checking
        var isScanning: Bool = false
        var isProcessing: Bool = false
        var scannedText: String = ""
        var extractedData: ScannedVehicleData? = nil
        var scanError: ScanError? = nil
        var showModeSelector: Bool = false
        var showPreview: Bool = false
        var showCamera: Bool = true
        var scanSource: DocumentSource? = nil
    }

    enum Action: Equatable {
        case onAppear
        case checkCameraAvailability
        case cameraAvailabilityChecked(CameraAvailability)
        case selectScanMode(ScanMode)
        case startScanning
        case stopScanning
        case captureImage(UIImage)
        case textRecognized(String)
        case parsingCompleted(ScannedVehicleData)
        case scanFailed(ScanError)
        case confirmData
        case retryScanning
        case requestRetry
        case cancelScan
    }

    @Dependency(\.ocrService) var ocrService
    @Dependency(\.documentParser) var documentParser
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .onAppear:
                print("🚀 [DocumentScanStore] View appeared")
                return .send(.checkCameraAvailability)

            case .checkCameraAvailability:
                print("🔍 [DocumentScanStore] Checking camera availability...")
                return .run { send in
                    let availability = await ocrService.checkCameraAvailability()
                    await send(.cameraAvailabilityChecked(availability))
                }

            case .cameraAvailabilityChecked(let availability):
                state.cameraAvailability = availability
                print("📱 [DocumentScanStore] Camera availability: \(availability)")

                if case .available = availability {
                    // Caméra prête
                } else if let errorMessage = availability.errorMessage {
                    state.scanError = .unknown(errorMessage)
                }
                return .none

            case .selectScanMode(let mode):
                print("📄 [DocumentScanStore] Mode sélectionné: \(mode.displayName)")
                state.scanMode = mode
                state.showModeSelector = false
                return .none

            case .startScanning:
                print("📸 [DocumentScanStore] Démarrage du scan...")
                state.isScanning = true
                state.scanError = nil
                state.scannedText = ""
                state.extractedData = nil
                return .none

            case .stopScanning:
                print("⏸️ [DocumentScanStore] Arrêt du scan")
                state.isScanning = false
                return .none

            case .captureImage(let image):
                print("📷 [DocumentScanStore] Image capturée, lancement OCR...")
                state.isScanning = false
                state.isProcessing = true
                state.showCamera = false

                return .run { [mode = state.scanMode] send in
                    do {
                        // Étape 1: OCR
                        let recognizedText = try await ocrService.recognizeTextStatic(image)
                        await send(.textRecognized(recognizedText))

                        // Étape 2: Parsing
                        let parsedData = documentParser.parse(recognizedText, mode)
                        await send(.parsingCompleted(parsedData))

                    } catch let error as ScanError {
                        await send(.scanFailed(error))
                    } catch {
                        await send(.scanFailed(.unknown(error.localizedDescription)))
                    }
                }

            case .textRecognized(let text):
                print("✅ [DocumentScanStore] Texte reconnu (\(text.count) caractères)")
                state.scannedText = text
                return .none

            case .parsingCompleted(let data):
                print("✅ [DocumentScanStore] Parsing terminé")
                print("   ├─ Confiance: \(data.confidence.rawValue)")
                print("   └─ Champs remplis: \(data.filledFieldsCount)/4")

                state.extractedData = data
                state.isProcessing = false
                state.showPreview = true

                if !data.hasData {
                    state.scanError = .noTextDetected
                }

                return .none

            case .scanFailed(let error):
                print("❌ [DocumentScanStore] Scan échoué: \(error.localizedDescription)")
                state.scanError = error
                state.isScanning = false
                state.isProcessing = false
                state.showCamera = true
                return .none

            case .confirmData:
                print("✅ [DocumentScanStore] Données confirmées par l'utilisateur")
                // Les données sont transmises au AddVehicleStore via dismiss
                return .run { _ in
                    await dismiss()
                }

            case .requestRetry:
                print("🔄 [DocumentScanStore] Utilisateur demande un retry")

                // Si la source était photoLibrary, on ferme (le parent gérera la réouverture)
                if state.scanSource == .photoLibrary {
                    print("   └─ Source: photoLibrary - Fermeture du scanner")
                    return .run { _ in
                        await dismiss()
                    }
                }

                // Si c'était la caméra, on reset pour recommencer
                print("   └─ Source: camera - Reset du scanner")
                return .send(.retryScanning)

            case .retryScanning:
                print("🔄 [DocumentScanStore] Reset pour nouveau scan")
                state.scanError = nil
                state.scannedText = ""
                state.extractedData = nil
                state.showPreview = false
                state.showCamera = true
                state.isProcessing = false
                return .none

            case .cancelScan:
                print("❌ [DocumentScanStore] Scan annulé")
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}
