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

struct AddDocumentView: View {
    @Bindable var store: StoreOf<AddDocumentStore>
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
        ZStack {
            ColorTokens.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Détails du document")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(ColorTokens.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(ColorTokens.background)

                Divider()

                ScrollView {
                    VStack(spacing: 24) {
                        FormField(titleLabel: "Type de document") {
                            HStack {
                                Text("Type")
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)

                                Spacer()

                                Picker("Type", selection: $store.documentType) {
                                    ForEach(DocumentType.allCases) { type in
                                        Text(type.displayName)
                                            .tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                        }

                        FormField(titleLabel: "Nom du document", infoLabel: "Nom descriptif du document") {
                            TextField("Ex: Facture révision", text: $store.documentName)
                                .font(.system(size: 17))
                                .textInputAutocapitalization(.sentences)
                                .submitLabel(.done)
                                .multilineTextAlignment(.leading)
                        }

                        FormField(titleLabel: "Date du document", infoLabel: "Date d'émission du document") {
                            HStack {
                                Text("Date")
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)

                                Spacer()

                                DatePicker("", selection: $store.documentDate, in: Date.distantPast...Date(), displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                            }
                        }

                        FormField(titleLabel: "Kilométrage (optionnel)", infoLabel: "Kilométrage au moment du document") {
                            HStack(spacing: 12) {
                                Text("Kilométrage")
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)

                                Spacer()

                                TextField("120000", text: $store.documentMileage)
                                    .font(.system(size: 17))
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)

                                Text("km")
                                    .font(.system(size: 17))
                                    .foregroundColor(.secondary)
                            }
                        }

                        FormField(titleLabel: "Montant (optionnel)", infoLabel: "Montant TTC du document") {
                            HStack(spacing: 12) {
                                Text("Montant")
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)

                                Spacer()

                                TextField("150.00", text: $store.documentAmount)
                                    .font(.system(size: 17))
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)

                                Text("€")
                                    .font(.system(size: 17))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, Spacing.screenMargin)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .bottom, spacing: 24) {
                    VStack(spacing: 0) {
                        Divider()

                        VStack(spacing: 0) {
                            Button(action: { store.send(.view(.backFromMetadataFormButtonTapped)) }) {
                                Text("Retour")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .cornerRadius(14)
                            }

                            Button(action: { store.send(.saveDocument) }) {
                                Text("Enregistrer")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(.black)
                                    .cornerRadius(14)
                            }
                            .disabled(!isFormValid || store.isLoading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                    .background(ColorTokens.background)
                }
            }
        }
    }
}

#Preview("ModeChoice") {
    AddDocumentView(store: Store(initialState: AddDocumentStore.State.initialState(vehicleId: String())) {
            AddDocumentStore()
        })
}

#Preview("Metadata") {
    AddDocumentView(store: Store(initialState: AddDocumentStore.State.initialState(vehicleId: String(), viewState: .metadataForm), reducer: { AddDocumentStore() }))
}
