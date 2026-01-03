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
        NavigationView {
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
            .navigationTitle("add_document_title")
            .navigationBarTitleDisplayMode(.inline)
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
    }
    
    
    private var modeChoiceView: some View {
        VStack {
            VStack(spacing: Spacing.md) {
                modeOptionCard(
                    icon: "camera.viewfinder",
                    title: "add_document_mode_camera_title",
                    subtitle: "add_document_mode_camera_subtitle",
                    action: { store.send(.view(.openCameraViewButtonTapped)) }
                )

                modeOptionCard(
                    icon: "photo.on.rectangle.angled",
                    title: "add_document_mode_photo_title",
                    subtitle: "add_document_mode_photo_subtitle",
                    action: { store.send(.view(.openPhotoPickerButtonTapped)) }
                )

                modeOptionCard(
                    icon: "folder",
                    title: "add_document_mode_file_title",
                    subtitle: "add_document_mode_file_subtitle",
                    action: { store.send(.view(.openFileManagerButtonTapped)) }
                )
                
            }
        }
        .padding(Spacing.screenMargin)
    }
    
    private func modeOptionCard(
        icon: String,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: Spacing.md) {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(Color.primary)
                
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(.title3)
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .caption()

                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(14)
        }
    }
    
    private var metadataFormView: some View {
        VStack(spacing: 24) {
            FormField(titleLabel: "document_form_type_title") {
                HStack {
                    Text("document_form_type_label")
                        .formFieldLeadingTitle()

                    Spacer()

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

                    Text("all_mileage_unit")
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

                    Text("all_currency_symbol")
                        .formFieldLeadingTitle()
                }
            }
        }
        .padding(Spacing.screenMargin)
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
