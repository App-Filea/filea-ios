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
                case .modeChoice: modeChoiceView
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
    
    private var modeChoiceView: some View {
        VStack(spacing: 64) {
            Text("Comment voulez-vous scanner ?")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                Button(action: { store.send(.view(.scanDocumentButtonTapped)) }) {
                    HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "camera.viewfinder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 32)
                            Text("Utiliser la caméra")
                                .font(.title2)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorTokens.surface)
                    .cornerRadius(8)
                }
                Button(action: { store.send(.view(.pickPhotoButtonTapped)) }) {
                    HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 32)
                        Text("Choisir une photo")
                                .font(.title2)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorTokens.surface)
                    .cornerRadius(8)
                }
                Button(action: { store.send(.view(.importFileButtonTapped)) }) {
                    HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "folder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 32)
                        Text("Importer un fichier")
                                .font(.title2)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorTokens.surface)
                    .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding([.horizontal, .bottom])
        .padding(.top, 64)
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

// MARK: - Previews

#Preview("Mode Choice") {
    VehicleCardDocumentScanView(store: Store(
        initialState: VehicleCardDocumentScanStore.State(
            viewState: .modeChoice
        )
    ) {
        VehicleCardDocumentScanStore()
    })
}

#Preview("Loading") {
    VehicleCardDocumentScanView(store: Store(
        initialState: VehicleCardDocumentScanStore.State(
            viewState: .loading
        )
    ) {
        VehicleCardDocumentScanStore()
    })
}

#Preview("Preview - High Confidence") {
    VehicleCardDocumentScanView(store: Store(
        initialState: VehicleCardDocumentScanStore.State(
            viewState: .preview,
            extractedData: ScannedVehicleData(
                brand: "Tesla",
                model: "Model 3",
                plate: "AB-123-CD",
                registrationDate: Date(timeIntervalSince1970: 1609459200), // 1 Jan 2021
                confidence: .high,
                sourceDocument: .registrationCard
            )
        )
    ) {
        VehicleCardDocumentScanStore()
    })
}

#Preview("Preview - Medium Confidence") {
    VehicleCardDocumentScanView(store: Store(
        initialState: VehicleCardDocumentScanStore.State(
            viewState: .preview,
            extractedData: ScannedVehicleData(
                brand: "Renault",
                model: nil,
                plate: "EF-456-GH",
                registrationDate: nil,
                confidence: .medium,
                sourceDocument: .invoice
            )
        )
    ) {
        VehicleCardDocumentScanStore()
    })
}

#Preview("Preview - Low Confidence") {
    VehicleCardDocumentScanView(store: Store(
        initialState: VehicleCardDocumentScanStore.State(
            viewState: .preview,
            extractedData: ScannedVehicleData(
                brand: "BMW",
                model: nil,
                plate: nil,
                registrationDate: nil,
                confidence: .low,
                sourceDocument: .receipt
            )
        )
    ) {
        VehicleCardDocumentScanStore()
    })
}

#Preview("Error") {
    VehicleCardDocumentScanView(store: Store(
        initialState: VehicleCardDocumentScanStore.State(
            viewState: .error,
            scanError: .noTextDetected
        )
    ) {
        VehicleCardDocumentScanStore()
    })
}
