//
//  AddDocumentMultiStepView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 13/10/2025.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
import QuickLook

struct AddDocumentMultiStepView: View {
    @Bindable var store: StoreOf<AddDocumentStore>
    @State private var currentStep: AddDocumentStep = .selectSource
    @State private var previewURL: URL?

    private var isFormValid: Bool {
        !store.documentName.isEmpty
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ColorTokens.surfaceSecondary
                .ignoresSafeArea()

            Button(action: { store.send(.view(.closeButtonTapped)) }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .padding(.trailing)
            }
            
            switch store.viewState {
            case .modeChoice: modeChoiceView
            case .metadataForm: metadataFormView
            }
        }
        .quickLookPreview($previewURL)
        .fullScreenCover(isPresented: $store.showDocumentScanView) {
            DocumentScannerView(
                onFinish: { scan in
                    guard scan.pageCount > 0 else { return }
                    let images = (0..<scan.pageCount).map { scan.imageOfPage(at: $0) }
                    store.send(.view(.documentScanned(images)))
                },
                onCancel: { store.send(.view(.cancelCameraViewButtonTapped)) },
                onError: { _ in }
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $store.showPhotoPickerView) {
            PhotosPicker(
                "Sélectionner une photo",
                selection: $store.photoPickerItems,
                matching: .images,
                photoLibrary: .shared()
            )
            .photosPickerStyle(.inline)
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $store.showFileManagerView) {
            DocumentFilePickerView(
                onFileSelected: { url in
                    store.send(.filePickedFromManager(url))
                },
                onCancel: { store.send(.view(.cancelFileManagerButtonTapped)) }
            )
        }
    }

    // MARK: - Mode Choice View

    private var modeChoiceView: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()
                .frame(height: Spacing.xl)

            // Title
            Text("Comment créer votre document ?")
                .font(Typography.largeTitle)
                .foregroundStyle(ColorTokens.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.md)

            // Options List
            VStack(spacing: Spacing.md) {
                // Option 1: Camera Scan
                modeOptionCard(
                    icon: "camera.viewfinder",
                    title: "Scanner avec la caméra",
                    subtitle: "Pour un document papier",
                    action: { store.send(.view(.openCameraViewButtonTapped)) }
                )

                // Option 2: Import Photo
                modeOptionCard(
                    icon: "photo.on.rectangle.angled",
                    title: "Importer une photo",
                    subtitle: "Depuis votre bibliothèque",
                    action: { store.send(.view(.openPhotoPickerButtonTapped)) }
                )

                // Option 3: Import File
                modeOptionCard(
                    icon: "folder",
                    title: "Importer un fichier",
                    subtitle: "PDF, image depuis le cloud",
                    action: { store.send(.view(.openFileManagerButtonTapped)) }
                )

//                // Option 4: Manual Entry
//                modeOptionCard(
//                    icon: "square.and.pencil",
//                    title: "Saisie manuelle",
//                    subtitle: "Sans document à scanner",
//                    action: { /* TODO: Handle manual entry */ }
//                )
            }
            .padding(.horizontal, Spacing.md)

            Spacer()
        }
    }

    private func modeOptionCard(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: Spacing.md) {
                // Icon
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(ColorTokens.actionPrimary)

                // Text Content
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(Typography.title3)
                        .foregroundStyle(ColorTokens.textPrimary)

                    Text(subtitle)
                        .font(Typography.caption1)
                        .foregroundStyle(ColorTokens.textSecondary)
                }

                Spacer()
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity)
            .background(ColorTokens.surface)
            .cornerRadius(Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(ColorTokens.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var metadataFormView: some View {
        VStack(spacing: 0) {
            // Header with navigation buttons
            HStack {
                // Back button
                Button(action: {
                    store.send(.view(.backFromMetadataFormButtonTapped))
                }) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "chevron.left")
                            .font(.body)
                        Text("Retour")
                            .font(Typography.body)
                    }
                    .foregroundStyle(ColorTokens.actionPrimary)
                }

                Spacer()

                // Title
                Text("Détails du document")
                    .font(Typography.headline)
                    .foregroundStyle(ColorTokens.textPrimary)

                Spacer()

                // Save button
                Button("Enregistrer") {
                    store.send(.saveDocument)
                }
                .disabled(!isFormValid || store.isLoading)
                .foregroundStyle(ColorTokens.actionPrimary)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(ColorTokens.background)

            // Form content
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Single section for all fields
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Informations du document")
                            .font(Typography.subheadline)
                            .foregroundStyle(ColorTokens.textPrimary)

                        VStack(spacing: Spacing.formFieldSpacing) {
                            // Document name (required)
                            FormTextField(
                                title: "Nom du document",
                                text: $store.documentName,
                                placeholder: "Ex: Facture révision"
                            )

                            // Document date
                            FormDatePicker(
                                title: "Date du document",
                                date: $store.documentDate,
                                displayedComponents: [.date],
                                dateRange: Date.distantPast...Date()
                            )

                            // Mileage (optional)
                            FormTextField(
                                title: "Kilométrage (optionnel)",
                                text: $store.documentMileage,
                                placeholder: "120000",
                                keyboardType: .numberPad
                            )

                            // Amount (optional)
                            FormTextField(
                                title: "Montant (optionnel)",
                                text: $store.documentAmount,
                                placeholder: "150.00",
                                keyboardType: .decimalPad
                            )
                        }
                        .padding(Spacing.cardPadding)
                        .background(ColorTokens.surfaceElevated)
                        .cornerRadius(Radius.xl)
                    }
                    .padding(.horizontal, Spacing.md)
                }
                .padding(.vertical, Spacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

#Preview {
        AddDocumentMultiStepView(store: Store(initialState: AddDocumentStore.State(vehicleId: UUID())) {
            AddDocumentStore()
        })
}
