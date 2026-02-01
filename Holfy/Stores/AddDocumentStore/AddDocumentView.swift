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

    @Shared(.selectedCurrency) var currency: Currency
    @Shared(.selectedDistanceUnit) var distanceUnit: DistanceUnit

    private var isFormValid: Bool {
        !store.documentName.isEmpty
    }

    var body: some View {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                switch store.viewState {
                case .modeChoice:
                    ScrollView {
                        modeChoiceView
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .safeAreaInset(edge: .bottom, spacing: 80) {
                        VStack(spacing: 0) {
                            Divider()
                            
                            VStack(spacing: Spacing.md) {
                                TertiaryButton("all_cancel", action: {
                                    store.send(.view(.closeButtonTapped))
                                })
                            }
                            .padding(16)
                        }
                        .background(Color(.tertiarySystemBackground))

                    }
                case .metadataForm:
                    ScrollView {
                        metadataFormView
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .safeAreaInset(edge: .bottom, spacing: 80) {
                        VStack(spacing: 0) {
                            Divider()
                            
                            VStack(spacing: Spacing.md) {
                                PrimaryButton("all_save", action: {
                                    store.send(.view(.saveButtonTapped))
                                })

                                TertiaryButton("all_back", action: {
                                    store.send(.view(.backFromMetadataFormButtonTapped))
                                })
                            }
                            .padding(16)
                        }
                        .background(Color(.tertiarySystemBackground))
                    }
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
                    "add_document_photo_picker_title",
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
        VStack(spacing: Spacing.lg) {
            VStack(spacing: Spacing.xs) {
                Text("add_document_mode_header_title")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)

                Text("add_document_mode_header_subtitle")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, Spacing.sm)

            Button {
                store.send(.view(.openCameraViewButtonTapped))
            } label: {
                VStack(spacing: Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: 72, height: 72)

                        Image(systemName: "camera.viewfinder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .foregroundStyle(Color.accentColor)
                    }

                    VStack(spacing: Spacing.xxs) {
                        HStack(spacing: Spacing.xs) {
                            Text("add_document_mode_camera_title")
                                .font(.headline)
                                .foregroundStyle(Color.primary)

                            Text("add_document_mode_recommended_badge")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor)
                                .clipShape(Capsule())
                        }

                        Text("add_document_mode_camera_subtitle")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
                .background(Color.accentColor.opacity(0.08))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            HStack(spacing: Spacing.md) {
                secondaryOptionCard(
                    icon: "photo.on.rectangle.angled",
                    title: "add_document_mode_photo_title",
                    action: { store.send(.view(.openPhotoPickerButtonTapped)) }
                )

                secondaryOptionCard(
                    icon: "folder",
                    title: "add_document_mode_file_title",
                    action: { store.send(.view(.openFileManagerButtonTapped)) }
                )
            }
        }
        .padding(Spacing.screenMargin)
    }

    private func secondaryOptionCard(
        icon: String,
        title: LocalizedStringKey,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color(.tertiarySystemFill))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.primary)
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var metadataFormView: some View {
        VStack(spacing: 24) {
            FormField(titleLabel: "document_form_type_title") {
                HStack {
                    Text("document_form_type_label")
                        .formFieldLeadingTitle()

                    Spacer()

                    if store.isTypePickerDisabled {
                        // Read-only display when type is pre-selected from Quick Action
                        Text(store.documentType.displayName)
                            .formFieldLeadingTitle()
                            .foregroundStyle(Color.secondary)
                    } else {
                        Picker("document_form_type_label", selection: $store.documentType) {
                            ForEach(DocumentType.allCases) { type in
                                Text(type.displayName)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                }
            }

            FormField(titleLabel: "document_form_name_title",
                      infoLabel: "document_form_name_info",
                      isError: store.validationErrors.contains(.nameEmpty)) {
                TextField("document_form_name_placeholder", text: $store.documentName)
                    .formFieldLeadingTitle()
                    .submitLabel(.done)
                    .multilineTextAlignment(.leading)
            }

            FormField(titleLabel: "document_form_date_title",
                      infoLabel: "document_form_date_info") {
                HStack {
                    Text("document_form_date_label")
                        .formFieldLeadingTitle()

                    Spacer()

                    DatePicker("", selection: $store.documentDate, in: Date.distantPast...Date(), displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }
            }

            if store.documentType == .technicalInspection {
                FormField(titleLabel: "document_form_expiration_date_title",
                          infoLabel: "document_form_expiration_date_info") {
                    HStack {
                        Text("document_form_expiration_date_label")
                            .formFieldLeadingTitle()

                        Spacer()

                        DatePicker(
                            "",
                            selection: Binding(
                                get: { store.documentExpirationDate },
                                set: { store.send(.view(.expirationDateChanged($0))) }
                            ),
                            in: store.documentDate...,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                    }
                }
            }

            FormField(titleLabel: "document_form_mileage_title",
                      infoLabel: "document_form_mileage_info") {
                HStack(spacing: 12) {
                    Text("document_form_mileage_label")
                        .formFieldLeadingTitle()

                    Spacer()

                    TextField("document_form_mileage_placeholder", text: $store.documentMileage)
                        .formFieldLeadingTitle()
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)

                    Text(distanceUnit.symbol)
                        .formFieldLeadingTitle()
                }
            }

            FormField(titleLabel: "document_form_amount_title",
                      infoLabel: "document_form_amount_info") {
                HStack(spacing: 12) {
                    Text("document_form_amount_label")
                        .formFieldLeadingTitle()

                    Spacer()

                    TextField("document_form_amount_placeholder", text: $store.documentAmount)
                        .formFieldLeadingTitle()
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)

                    Text(currency.symbol)
                        .formFieldLeadingTitle()
                }
            }
        }
        .padding(Spacing.screenMargin)
    }
}

// MARK: - Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("ModeChoice") {
    NavigationView {
        AddDocumentView(store: Store(initialState: AddDocumentStore.State.initialState(vehicleId: String())) {
            AddDocumentStore()
        })
    }
}

#Preview("Metadata") {
    NavigationView {
        AddDocumentView(store: Store(initialState: AddDocumentStore.State.initialState(vehicleId: String(), viewState: .metadataForm)) {
            AddDocumentStore()
        })
    }
}
