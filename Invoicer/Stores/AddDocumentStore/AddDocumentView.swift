//
//  AddDocumentView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture
import UniformTypeIdentifiers

struct AddDocumentView: View {
    @Bindable var store: StoreOf<AddDocumentStore>
    @FocusState private var focusedField: Field?
    @State private var openDateSheet: Bool = false

    private let horizontalPadding: CGFloat = 20

    enum Field: Hashable {
        case documentName, mileage, amount
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header avec titre, sous-titre et indicateur de progression
                VStack(spacing: 12) {
                    Text(navigationTitle)
                        .titleLarge()
                        .foregroundStyle(Color("onBackground"))

                    Text(navigationSubtitle)
                        .bodyDefaultRegular()
                        .foregroundStyle(Color("onBackgroundSecondary"))
                        .multilineTextAlignment(.center)

                    StepIndicator(currentStep: currentStepIndex, totalSteps: 3)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 24)

                // Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        switch store.currentStep {
                        case .selectFile:
                            selectFileView()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        case .preview:
                            previewView()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        case .metadata:
                            metadataView()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: store.currentStep)
                    .padding(.horizontal, horizontalPadding)
                }

                Spacer()

                // Bottom buttons section
                VStack(spacing: 12) {
                    if shouldShowPrimaryButton {
                        Button(action: handlePrimaryAction) {
                            if store.isLoading {
                                ProgressView()
                                    .tint(Color("onPrimary"))
                            } else {
                                Text(primaryButtonTitle)
                                    .bodyDefaultSemibold()
                                    .foregroundStyle(Color("onPrimary"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isPrimaryButtonDisabled ? Color("primary").opacity(0.5) : Color("primary"))
                        )
                        .disabled(isPrimaryButtonDisabled || store.isLoading)
                    }

                    Button(action: handleSecondaryAction) {
                        Text(secondaryButtonTitle)
                            .bodyDefaultRegular()
                            .foregroundStyle(Color("onBackground"))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 16)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $openDateSheet) {
            DatePickerSheet(
                date: Binding(
                    get: { store.documentDate },
                    set: { store.send(.updateDocumentDate($0)) }
                ),
                onSave: {
                    openDateSheet = false
                },
                onCancel: {
                    openDateSheet = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: .init(
            get: { store.showCamera },
            set: { _ in store.send(.hideCamera) }
        )) {
            CameraView { image in
                store.send(.imageCapture(image))
            }
        }
        .fullScreenCover(isPresented: .init(
            get: { store.showFilePicker },
            set: { _ in store.send(.hideFilePicker) }
        )) {
            FilePickerView { url in
                store.send(.fileSelected(url))
            }
        }
    }

    // MARK: - Step Views
    
    @ViewBuilder
    private func selectFileView() -> some View {
        SelectFileButtons(
            onCameraSelected: { store.send(.showCamera) },
            onFilePickerSelected: { store.send(.showFilePicker) }
        )
    }
    
    @ViewBuilder
    private func previewView() -> some View {
        VStack(spacing: 16) {
            // Preview du contenu
            if let image = store.capturedImage, store.documentSource == .camera {
                // Photo capturée
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 400)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("outline"), lineWidth: 2)
                    )
            } else if let fileURL = store.selectedFileURL, let fileName = store.selectedFileName, store.documentSource == .file {
                // Fichier importé
                DocumentPreview(fileURL: fileURL, fileName: fileName)
            }

            // Bouton pour changer de source
            if store.documentSource == .camera {
                Button("Reprendre la Photo") {
                    store.send(.showCamera)
                }
                .bodyDefaultSemibold()
                .foregroundStyle(Color("primary"))
            } else if store.documentSource == .file {
                Button("Choisir un Autre Fichier") {
                    store.send(.showFilePicker)
                }
                .bodyDefaultSemibold()
                .foregroundStyle(Color("primary"))
            }
        }
    }
    
    @ViewBuilder
    private func metadataView() -> some View {
        VStack(spacing: 20) {
            // Document Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Nom du document")
                    .bodyDefaultSemibold()
                    .foregroundStyle(Color("onBackground"))

                OutlinedTextField(
                    focusedField: $focusedField,
                    field: Field.documentName,
                    placeholder: "Entretien, Réparation...",
                    text: .init(
                        get: { store.documentName },
                        set: { store.send(.updateDocumentName($0)) }
                    ),
                    hasError: false
                )
                .submitLabel(.next)
                .focused($focusedField, equals: .documentName)
                .onSubmit {
                    focusedField = .mileage
                }
            }

            // Mileage
            VStack(alignment: .leading, spacing: 8) {
                Text("Kilométrage")
                    .bodyDefaultSemibold()
                    .foregroundStyle(Color("onBackground"))

                OutlinedTextField(
                    focusedField: $focusedField,
                    field: Field.mileage,
                    placeholder: "120000",
                    text: .init(
                        get: { store.documentMileage },
                        set: { store.send(.updateDocumentMileage($0)) }
                    ),
                    hasError: false,
                    suffix: "KM"
                )
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .mileage)
                .toolbar {
                    if focusedField == .mileage {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button {
                                focusedField = nil
                                openDateSheet = true
                            } label: {
                                Text("Suivant")
                                    .bold()
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .foregroundColor(Color("primary"))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }

            // Date
            VStack(alignment: .leading, spacing: 8) {
                Text("Date")
                    .bodyDefaultSemibold()
                    .foregroundStyle(Color("onBackground"))

                Button(action: {
                    openDateSheet = true
                }) {
                    HStack {
                        Text(formatDate(store.documentDate))
                            .bodyDefaultRegular()
                            .foregroundStyle(Color("onSurface"))

                        Spacer()

                        Image(systemName: "calendar")
                            .foregroundStyle(Color("onBackgroundSecondary"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("background"))
                            .stroke(Color("outline"), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }

            // Document Type
            VStack(alignment: .leading, spacing: 8) {
                Text("Type de document")
                    .bodyDefaultSemibold()
                    .foregroundStyle(Color("onBackground"))

                Menu {
                    ForEach(DocumentCategory.allCases, id: \.self) { category in
                        Section(category.displayName) {
                            ForEach(DocumentType.allCases.filter { $0.category == category }, id: \.self) { type in
                                Button {
                                    store.send(.updateDocumentType(type))
                                } label: {
                                    HStack {
                                        Image(systemName: type.imageName)
                                        Text(type.displayName)
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: store.documentType.imageName)
                            .foregroundStyle(Color("primary"))
                        Text(store.documentType.displayName)
                            .bodyDefaultRegular()
                            .foregroundStyle(Color("onSurface"))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(Color("onSurface").opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("outline"), lineWidth: 2)
                    )
                }
            }

            // Amount
            VStack(alignment: .leading, spacing: 8) {
                Text("Montant")
                    .bodyDefaultSemibold()
                    .foregroundStyle(Color("onBackground"))

                OutlinedTextField(
                    focusedField: $focusedField,
                    field: Field.amount,
                    placeholder: "0.00",
                    text: .init(
                        get: { store.documentAmount },
                        set: { store.send(.updateDocumentAmount($0)) }
                    ),
                    hasError: false,
                    suffix: "€"
                )
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .amount)
            }
        }
    }
    

    // MARK: - Actions

    private func handlePrimaryAction() {
        switch store.currentStep {
        case .preview:
            store.send(.nextStep)
        case .metadata:
            store.send(.saveDocument)
        case .selectFile:
            break
        }
    }

    private func handleSecondaryAction() {
        switch store.currentStep {
        case .selectFile:
            store.send(.goBack)
        case .preview, .metadata:
            store.send(.previousStep)
        }
    }

    // MARK: - Computed Properties

    private var shouldShowBottomButtons: Bool {
        true
    }

    private var shouldShowPrimaryButton: Bool {
        store.currentStep != .selectFile
    }

    private var navigationTitle: String {
        switch store.currentStep {
        case .selectFile:
            return "Ajouter Document"
        case .preview:
            return "Prévisualisation"
        case .metadata:
            return "Informations"
        }
    }

    private var navigationSubtitle: String {
        switch store.currentStep {
        case .selectFile:
            return "Choisissez comment ajouter votre document"
        case .preview:
            return "Vérifiez le contenu de votre document"
        case .metadata:
            return "Renseignez les informations du document"
        }
    }

    private var primaryButtonTitle: String {
        switch store.currentStep {
        case .preview:
            return "Suivant"
        case .metadata:
            return "Enregistrer"
        case .selectFile:
            return ""
        }
    }

    private var secondaryButtonTitle: String {
        switch store.currentStep {
        case .selectFile:
            return "Annuler"
        case .preview, .metadata:
            return "Retour"
        }
    }

    private var isPrimaryButtonDisabled: Bool {
        switch store.currentStep {
        case .selectFile:
            return true
        case .preview:
            return !store.canProceedFromPreview
        case .metadata:
            return !store.canSaveDocument
        }
    }

    private var currentStepIndex: Int {
        switch store.currentStep {
        case .selectFile:
            return 1
        case .preview:
            return 2
        case .metadata:
            return 3
        }
    }
}


// MARK: - Step Indicator Component

struct StepIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color("primary") : Color("outline"))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
    }
}


// MARK: - Subcomponents

struct SelectFileButtons: View {
    let onCameraSelected: () -> Void
    let onFilePickerSelected: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            DocumentSourceButton(
                icon: "camera.fill",
                title: "Prendre une Photo",
                subtitle: "Utiliser l'appareil photo",
                action: onCameraSelected
            )

            DocumentSourceButton(
                icon: "folder.fill",
                title: "Importer un Fichier",
                subtitle: "Depuis le stockage ou iCloud",
                action: onFilePickerSelected
            )
        }
    }
}

struct DocumentSourceButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color("onPrimary"))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .bodyDefaultSemibold()
                        .foregroundStyle(Color("onPrimary"))
                    Text(subtitle)
                        .bodySmallRegular()
                        .foregroundStyle(Color("onPrimary").opacity(0.8))
                }

                Spacer()
            }
            .padding()
            .background(Color("primary"))
            .cornerRadius(12)
        }
    }
}

struct FilePickerView: UIViewControllerRepresentable {
    let onFileSelected: (URL?) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .jpeg, .png, .text, .plainText])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FilePickerView
        
        init(_ parent: FilePickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onFileSelected(urls.first)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onFileSelected(nil)
        }
    }
}

#Preview("Select file") {
    NavigationView {
        AddDocumentView(store: Store(initialState: AddDocumentStore.State(vehicleId: UUID(), currentStep: .selectFile)) {
            AddDocumentStore()
        })
    }
}

#Preview("preview") {
    NavigationView {
        AddDocumentView(store: Store(initialState: AddDocumentStore.State(vehicleId: UUID(),
                                                                          capturedImage: UIImage(systemName: "trash"),
                                                                          documentSource: .camera, currentStep: .preview)) {
            AddDocumentStore()
        })
    }
}

#Preview("metadata") {
    NavigationView {
        AddDocumentView(store: Store(initialState: AddDocumentStore.State(vehicleId: UUID(), currentStep: .metadata)) {
            AddDocumentStore()
        })
    }
}
