//
//  DocumentScanView.swift
//  Invoicer
//
//  Created by Claude Code on 20/10/2025.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI

struct DocumentScanView: View {
    @Bindable var store: StoreOf<DocumentScanStore>
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            ColorTokens.background
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                // Header
                headerView

                // Content based on state
                if store.showPreview {
                    previewView
                } else {
                    scannerView
                }
            }
            .padding(Spacing.md)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .alert(
            "Erreur de scan",
            isPresented: Binding(
                get: { store.scanError != nil },
                set: { if !$0 { store.send(.retryScanning) } }
            )
        ) {
            Button("Réessayer") {
                store.send(.retryScanning)
            }
            Button("Annuler", role: .cancel) {
                store.send(.cancelScan)
            }
        } message: {
            if let error = store.scanError {
                Text(error.localizedDescription)
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    store.send(.captureImage(image))
                }
            }
        }
        .onChange(of: store.showPreview) { oldValue, newValue in
            // Réinitialiser le PhotosPicker quand on cache la preview
            if !newValue {
                selectedItem = nil
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Button("Annuler") {
                    store.send(.cancelScan)
                }
                .foregroundStyle(ColorTokens.textSecondary)

                Spacer()

                Text("Scanner une carte grise")
                    .font(Typography.title2)
                    .foregroundStyle(ColorTokens.textPrimary)

                Spacer()

                // Phantom button for alignment
                Button("Annuler") {
                    store.send(.cancelScan)
                }
                .opacity(0)
            }

            if !store.showPreview {
                Text("Placez la carte grise dans le cadre. Assurez-vous que les champs A, B, D.1 et D.3 sont visibles et bien éclairés.")
                    .bodySmallRegular()
                    .foregroundStyle(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var scannerView: some View {
        VStack {
            // Placeholder pour le scanner avec PhotosPicker
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(ColorTokens.surfaceSecondary)
                    .frame(height: 400)

                VStack(spacing: Spacing.md) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 60))
                        .foregroundStyle(ColorTokens.actionPrimary)

                    Text("Sélectionnez une image du document")
                        .bodyDefaultSemibold()
                        .foregroundStyle(ColorTokens.textPrimary)
                        .multilineTextAlignment(.center)

                    if store.isScanning {
                        ProgressView()
                            .tint(ColorTokens.actionPrimary)
                    }
                }
            }

            Spacer()

            // Action buttons
            VStack(spacing: Spacing.md) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Choisir une photo")
                    }
                }
                .buttonStyle(.primaryTextOnly())

                Button("Retour") {
                    store.send(.retryScanning)
                }
                .buttonStyle(.primaryTextOnly())
            }
        }
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

                    Button("Réessayer le scan") {
                        store.send(.retryScanning)
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
    DocumentScanView(store: Store(initialState: DocumentScanStore.State()) {
        DocumentScanStore()
    })
}
