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
    enum FocusedField {
        case mileage, amount, name
    }
    
    @Bindable var store: StoreOf<AddDocumentStore>
    @State private var previewURL: URL?
    @FocusState private var focusedField: FocusedField?
    
    @Shared(.selectedCurrency) var currency: Currency
    @Shared(.selectedDistanceUnit) var distanceUnit: DistanceUnit
    
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
                    modeChoiceView
                case .extractingMetadata:
                    extractingStateView
                case .extractionSuccess(let metadata):
                    extractionConfirmationView(metadata: metadata)
                case .extractionError(let error):
                    extractionErrorView(error: error)
                case .metadataForm:
                    metadataFormView
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    if focusedField == .mileage || focusedField == .amount {
                        Button("keyboard_next_button") {
                            switch focusedField {
                            case .mileage: focusedField = .amount
                            case .amount: focusedField = .name
                            default: break
                            }
                        }
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
    }
    
    
    private var modeChoiceView: some View {
        ScrollView {
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
    }
    
    private var extractingStateView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.5)
            
            Text("add_document_extracting_metadata")
                .font(.headline)
                .foregroundStyle(Color.primary)
            
            Text("add_document_extracting_metadata_subtitle")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(Spacing.screenMargin)
    }
    
    private func extractionConfirmationView(metadata: ExtractedDocumentMetadata) -> some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(spacing: Spacing.sm) {
                    Text("add_document_extraction_success_title")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary)
                    
                    Text("add_document_extraction_success_subtitle")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Spacing.md)
                
                // Detected type card
                detectedTypeCard(type: metadata.detectedType)
                
                // Extracted metadata preview
                extractedMetadataPreview(metadata: metadata)
                
            }
            .padding(Spacing.screenMargin)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: 80) {
            VStack(spacing: 0) {
                Divider()
                
                VStack(spacing: Spacing.md) {
                    PrimaryButton("add_document_confirm_type_button", action: {
                        store.send(.confirmDetectedType)
                    })
                    
                    SecondaryButton("add_document_wrong_type_button", action: {
                        store.send(.skipMetadataExtraction)
                    })
                    
                    TertiaryButton("all_back", action: {
                        store.send(.view(.backFromExtractionButtonTapped))
                    })
                }
                .padding(16)
            }
            .background(Color(.tertiarySystemBackground))
        }
    }
    
    private func detectedTypeCard(type: DocumentType) -> some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 72, height: 72)
                
                Image(systemName: type.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(Color.accentColor)
            }
            
            Text(type.displayName)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func extractedMetadataPreview(metadata: ExtractedDocumentMetadata) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("add_document_extracted_info_title")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.secondary)
            
            VStack(spacing: 0) {
                if let date = metadata.date {
                    extractedInfoRow(
                        icon: "calendar",
                        label: "document_form_date_label",
                        value: date.formatted(date: .long, time: .omitted)
                    )
                    Divider()
                        .padding(.leading, 44)
                }
                
                if let amount = metadata.amount {
                    extractedInfoRow(
                        icon: "eurosign.circle",
                        label: "document_form_amount_label",
                        value: String(format: "%.2f %@", amount, currency.symbol)
                    )
                    Divider()
                        .padding(.leading, 44)
                }
                
                if let mileage = metadata.mileage {
                    extractedInfoRow(
                        icon: "gauge.with.needle",
                        label: "document_form_mileage_label",
                        value: "\(mileage) \(distanceUnit.symbol)"
                    )
                }
            }
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    private func extractedInfoRow(icon: String, label: LocalizedStringKey, value: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)
            
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.primary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }
    
    private func extractionErrorView(error: String) -> some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 72, height: 72)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .foregroundStyle(Color.orange)
            }
            
            Text("add_document_extraction_error_title")
                .font(.headline)
                .foregroundStyle(Color.primary)
            
            Text("add_document_extraction_error_subtitle")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(Spacing.screenMargin)
        .safeAreaInset(edge: .bottom, spacing: 80) {
            VStack(spacing: 0) {
                Divider()
                
                VStack(spacing: Spacing.md) {
                    PrimaryButton("add_document_fill_manually_button", action: {
                        store.send(.skipMetadataExtraction)
                    })
                    
                    TertiaryButton("all_back", action: {
                        store.send(.view(.backFromExtractionButtonTapped))
                    })
                }
                .padding(16)
            }
            .background(Color(.tertiarySystemBackground))
        }
    }
    
    private var metadataFormView: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        FormField(titleLabel: "document_form_type_title") {
                            HStack {
                                Text("document_form_type_label")
                                    .formFieldLeadingTitle()
                                
                                Spacer()
                                
                                if store.isTypePickerDisabled {
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
                        .padding(.bottom, Spacing.lg)
                        
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
                                  .padding(.bottom, Spacing.lg)
                        
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
                                      .padding(.bottom, Spacing.lg)
                        }
                        
                        FormField(titleLabel: "document_form_mileage_title",
                                  infoLabel: "document_form_mileage_info") {
                            HStack(spacing: 12) {
                                TextField("document_form_mileage_placeholder", text: $store.documentMileage)
                                    .formFieldLeadingTitle()
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.leading)
                                    .focused($focusedField, equals: .mileage)
                                
                                Text(distanceUnit.symbol)
                                    .formFieldLeadingTitle()
                            }
                        }
                                  .id(FocusedField.mileage)
                                  .padding(.bottom, Spacing.lg)
                        
                        FormField(titleLabel: "document_form_amount_title",
                                  infoLabel: "document_form_amount_info") {
                            HStack(spacing: 12) {
                                TextField("document_form_amount_placeholder", text: $store.documentAmount)
                                    .formFieldLeadingTitle()
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.leading)
                                    .focused($focusedField, equals: .amount)
                                
                                Text(currency.symbol)
                                    .formFieldLeadingTitle()
                            }
                        }
                                  .id(FocusedField.amount)
                                  .padding(.bottom, Spacing.lg)
                        
                        FormField(titleLabel: "document_form_name_title",
                                  infoLabel: "document_form_name_info",
                                  isError: store.validationErrors.contains(.nameEmpty)) {
                            TextField("document_form_name_placeholder", text: $store.documentName)
                                .formFieldLeadingTitle()
                                .focused($focusedField, equals: .name)
                                .submitLabel(.done)
                                .multilineTextAlignment(.leading)
                                .onSubmit { focusedField = nil }
                        }
                                  .id(FocusedField.name)
                                  .padding(.bottom, Spacing.lg)
                    }
                    .padding(Spacing.screenMargin)
                    VStack(spacing: 0) {
                        VStack(spacing: Spacing.md) {
                            PrimaryButton("all_save", action: {
                                store.send(.view(.saveButtonTapped))
                            })
                            
                            TertiaryButton("all_back", action: {
                                store.send(.view(.backFromMetadataFormButtonTapped))
                            })
                        }
                        .padding([.horizontal, .top], Spacing.screenMargin)
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .onChange(of: focusedField) { _, newValue in
                    guard let field = newValue else { return }
                    withAnimation {
                        proxy.scrollTo(field, anchor: .bottom)
                    }
                }
            }
        }
    }
}

#Preview("ModeChoice") {
    NavigationView {
        AddDocumentView(store: Store(initialState: AddDocumentStore.State.initialState(vehicleId: String())) {
            AddDocumentStore()
        })
    }
}

#Preview("ExtractMetadata - Loading") {
    NavigationView {
        AddDocumentView(store: Store(initialState: {
            AddDocumentStore.State.initialState(vehicleId: String(), viewState: .extractingMetadata)
        }()) {
            AddDocumentStore()
        })
    }
}

#Preview("ExtractMetadata - Success") {
    NavigationView {
        AddDocumentView(store: Store(initialState: {
            let metadata = ExtractedDocumentMetadata(
                detectedType: .technicalInspection,
                typeConfidence: .high,
                typeScore: 12,
                suggestedName: "Contrôle technique 15/01/2026",
                date: Date(),
                amount: 79.90,
                mileage: "85000"
            )
            return AddDocumentStore.State.initialState(
                vehicleId: String(),
                viewState: .extractionSuccess(metadata)
            )
        }()) {
            AddDocumentStore()
        })
    }
}

#Preview("ExtractMetadata - Error") {
    NavigationView {
        AddDocumentView(store: Store(initialState: {
            AddDocumentStore.State.initialState(
                vehicleId: String(),
                viewState: .extractionError("Impossible de lire le document")
            )
        }()) {
            AddDocumentStore()
        })
    }
}

#Preview("Metadata Form") {
    NavigationView {
        AddDocumentView(store: Store(initialState: AddDocumentStore.State.initialState(vehicleId: String(), viewState: .metadataForm)) {
            AddDocumentStore()
        })
    }
}
