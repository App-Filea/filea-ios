//
//  VehicleCardDocumentScanView.swift
//  Invoicer
//
//  Created by Claude Code on 20/10/2025.
//

import SwiftUI
import ComposableArchitecture
import VisionKit
import PhotosUI

struct VehicleCardDocumentScanView: View {
    @Bindable var store: StoreOf<VehicleCardDocumentScanStore>

    var body: some View {
        ZStack {
            ColorTokens.background
                .ignoresSafeArea()
            
            VStack {
                
                switch store.viewState {
                case .modeChoice:
                    VStack {
                        Button(action: { store.send(.view(.scanDocumentButtonTapped)) }) {
                            Text("Scanner un document")
                        }
                        Button(action: { store.send(.view(.pickPhotoButtonTapped)) }) {
                            Text("Choisir une photo")
                        }
                        Button(action: { store.send(.view(.importFileButtonTapped)) }) {
                            Text("Importer un fichier")
                        }
                    }
                case .loading: loadingView
                case .preview:
                    VStack(spacing: Spacing.xl) {
                    headerView
                    previewView
                }
                .padding(Spacing.md)
                case .error:
                    VStack {
                        Text("Une erreur est survenue")
                    }
                }
            }
        }
        .sheet(isPresented: $store.showPhotoPickerView) {
            PhotosPicker(
                "Test",
                selection: $store.photoPickerItem,
                matching: .images,
                photoLibrary: .shared()
            )
            .photosPickerStyle(.inline)
            .ignoresSafeArea(edges: .bottom)
        }
        .fullScreenCover(isPresented: $store.showDocumentScanView) {
            DocumentScannerView(
                onFinish: { scan in
                    store.send(.documentScanned(scan))
                },
                onCancel: {
                    store.send(.closeScannerSheet)
                },
                onError: { error in
                    store.send(.closeScannerSheet)
                    store.send(.scanFailed(.unknown(error.localizedDescription)))
                }
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $store.showFileManagerView) {
            DocumentFilePickerView(
                onFileSelected: { url in
                    store.send(.fileSelected(url))
                },
                onCancel: {
                    store.showFileManagerView = false
                }
            )
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            Button("Annuler") {
                store.send(.cancelScan)
            }
            .foregroundStyle(ColorTokens.textSecondary)

            Spacer()

            Text("Résultats du scan")
                .font(Typography.title2)
                .foregroundStyle(ColorTokens.textPrimary)

            Spacer()

            // Phantom button for alignment
            Button("Annuler") {
                store.send(.cancelScan)
            }
            .opacity(0)
        }
    }

    private var cameraView: some View {
        // VisionKit Document Scanner - full screen, no overlay
        DocumentScannerView(
            onFinish: { scan in
                // Extract first page from scan
                guard scan.pageCount > 0 else {
                    store.send(.scanFailed(.noTextDetected))
                    return
                }

                let firstPage = scan.imageOfPage(at: 0)
                print("📄 [VehicleCardDocumentScanView] Extracted page from scan")
                print("   ├─ Total pages: \(scan.pageCount)")
                print("   └─ Image size: \(firstPage.size)")

                store.send(.captureImage(firstPage))
            },
            onCancel: {
                store.send(.cancelScan)
            },
            onError: { error in
                store.send(.scanFailed(.unknown(error.localizedDescription)))
            }
        )
        .ignoresSafeArea()
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            VStack(spacing: Spacing.lg) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(ColorTokens.actionPrimary)

                Text("Analyse en cours...")
                    .font(Typography.title3)
                    .foregroundStyle(ColorTokens.textPrimary)

                Text("Extraction des informations de la carte grise")
                    .bodySmallRegular()
                    .foregroundStyle(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(Spacing.md)
    }

    private var previewView: some View {
        VStack(spacing: Spacing.lg) {
            if let data = store.extractedData {
                VStack(spacing: Spacing.md) {
                    // Confidence indicator
                    HStack {
                        Image(systemName: data.confidence == .high ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(data.confidence == .high ? ColorTokens.success : ColorTokens.warning)

                        Text("Confiance: \(data.confidence.displayName)")
                            .bodySmallSemibold()
                            .foregroundStyle(ColorTokens.textSecondary)
                    }

                    Text("\(data.filledFieldsCount) champ(s) détecté(s)")
                        .bodyXSmallRegular()
                        .foregroundStyle(ColorTokens.textTertiary)

                    // Extracted fields
                    VStack(spacing: Spacing.sm) {
                        if let brand = data.brand {
                            fieldRow(label: "Marque", value: brand)
                        }
                        if let model = data.model {
                            fieldRow(label: "Modèle", value: model)
                        }
                        if let plate = data.plate {
                            fieldRow(label: "Plaque", value: plate)
                        }
                        if let date = data.registrationDate {
                            fieldRow(label: "Date", value: formatDate(date))
                        }
                    }
                }

                Spacer()

                // Actions
                VStack(spacing: Spacing.sm) {
                    Button("Confirmer et continuer") {
                        store.send(.confirmData)
                    }
                    .buttonStyle(.primaryTextOnly())
                }
            }
        }
    }

    private func fieldRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .bodySmallSemibold()
                .foregroundStyle(ColorTokens.textSecondary)

            Spacer()

            Text(value)
                .bodyDefaultRegular()
                .foregroundStyle(ColorTokens.textPrimary)
        }
        .padding(Spacing.md)
        .background(ColorTokens.surfaceSecondary)
        .cornerRadius(Radius.sm)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

#Preview {
    VehicleCardDocumentScanView(store: Store(initialState: VehicleCardDocumentScanStore.State()) {
        VehicleCardDocumentScanStore()
    })
}
