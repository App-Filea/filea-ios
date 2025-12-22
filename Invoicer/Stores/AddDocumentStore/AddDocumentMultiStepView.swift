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


    private var modeChoiceView: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()
                .frame(height: Spacing.xl)

            Text("Comment créer votre document ?")
                .font(Typography.largeTitle)
                .foregroundStyle(ColorTokens.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.md)

            VStack(spacing: Spacing.md) {
                modeOptionCard(
                    icon: "camera.viewfinder",
                    title: "Scanner avec la caméra",
                    subtitle: "Pour un document papier",
                    action: { store.send(.view(.openCameraViewButtonTapped)) }
                )

                modeOptionCard(
                    icon: "photo.on.rectangle.angled",
                    title: "Importer une photo",
                    subtitle: "Depuis votre bibliothèque",
                    action: { store.send(.view(.openPhotoPickerButtonTapped)) }
                )

                modeOptionCard(
                    icon: "folder",
                    title: "Importer un fichier",
                    subtitle: "PDF, image depuis le cloud",
                    action: { store.send(.view(.openFileManagerButtonTapped)) }
                )

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
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(ColorTokens.actionPrimary)

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

                Text("Détails du document")
                    .font(Typography.headline)
                    .foregroundStyle(ColorTokens.textPrimary)

                Spacer()

                Button("Enregistrer") {
                    store.send(.saveDocument)
                }
                .disabled(!isFormValid || store.isLoading)
                .foregroundStyle(ColorTokens.actionPrimary)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(ColorTokens.background)

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Informations du document")
                            .font(Typography.subheadline)
                            .foregroundStyle(ColorTokens.textPrimary)

                        VStack(spacing: Spacing.formFieldSpacing) {
                            FormTextField(
                                title: "Nom du document",
                                text: $store.documentName,
                                placeholder: "Ex: Facture révision"
                            )

                            FormDatePicker(
                                title: "Date du document",
                                date: $store.documentDate,
                                displayedComponents: [.date],
                                dateRange: Date.distantPast...Date()
                            )

                            FormTextField(
                                title: "Kilométrage (optionnel)",
                                text: $store.documentMileage,
                                placeholder: "120000",
                                keyboardType: .numberPad
                            )

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

#Preview("ModeChoice") {
    AddDocumentMultiStepView(store: Store(initialState: AddDocumentStore.State.initialState(vehicleId: UUID())) {
            AddDocumentStore()
        })
}

#Preview("Metadata") {
    AddDocumentMultiStepView(store: Store(initialState: AddDocumentStore.State.initialState(vehicleId: UUID(), viewState: .metadataForm), reducer: { AddDocumentStore() }))
}
