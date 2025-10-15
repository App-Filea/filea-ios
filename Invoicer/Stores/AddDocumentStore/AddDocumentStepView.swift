//
//  AddDocumentStepView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 13/10/2025.
//

import SwiftUI
import ComposableArchitecture

struct AddDocumentStepView: View {
    let step: AddDocumentStep
    @Bindable var store: StoreOf<AddDocumentStore>
    @FocusState private var focusedField: Field?
    @State private var openDateSheet: Bool = false

    enum Field: Hashable {
        case documentName, mileage, amount
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch step {
                case .selectSource:
                    selectSourceView
                case .metadata:
                    metadataView
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .fullScreenCover(isPresented: $store.showCamera) {
            CameraView { image in
                store.send(.imageCapture(image))
            }
        }
        .fullScreenCover(isPresented: $store.showFilePicker) {
            FilePickerView { url in
                store.send(.fileSelected(url))
            }
        }
        .sheet(isPresented: $openDateSheet) {
            DatePickerSheet(
                date: $store.documentDate,
                onSave: { openDateSheet = false },
                onCancel: { openDateSheet = false }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Select Source View

    private var selectSourceView: some View {
        VStack(spacing: 24) {
            // Source Selection Buttons
            VStack(spacing: 16) {
                SourceButton(
                    icon: "camera.fill",
                    title: "Prendre une Photo",
                    subtitle: "Utiliser l'appareil photo",
                    isSelected: store.documentSource == .camera,
                    action: { store.send(.showCamera) }
                )

                SourceButton(
                    icon: "folder.fill",
                    title: "Importer un Fichier",
                    subtitle: "Depuis le stockage ou iCloud",
                    isSelected: store.documentSource == .file,
                    action: { store.send(.showFilePicker) }
                )
            }

            // Preview if source selected
            if store.hasSourceSelected {
                previewSection
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: store.hasSourceSelected)
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Aperçu")
                    .font(.headline)
                    .foregroundStyle(Color(.label))

                Spacer()

                Button {
                    store.send(.removeSource)
                } label: {
                    Label("Supprimer", systemImage: "xmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(Color(.systemRed))
                        .font(.title3)
                }
            }

            if let image = store.capturedImage, store.documentSource == .camera {
                // Photo Preview
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemPurple), lineWidth: 2)
                    )

                Button {
                    store.send(.showCamera)
                } label: {
                    Label("Reprendre la Photo", systemImage: "camera.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color(.systemPurple))
                }
            } else if let fileName = store.selectedFileName, store.documentSource == .file {
                // File Preview
                HStack(spacing: 12) {
                    Image(systemName: fileIcon(for: fileName))
                        .font(.title)
                        .foregroundStyle(Color(.systemPurple))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(fileName)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color(.label))
                            .lineLimit(2)

                        Text(fileType(for: fileName))
                            .font(.caption)
                            .foregroundStyle(Color(.secondaryLabel))
                    }

                    Spacer()
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemPurple), lineWidth: 2)
                )

                Button {
                    store.send(.showFilePicker)
                } label: {
                    Label("Choisir un Autre Fichier", systemImage: "folder.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color(.systemPurple))
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Metadata View

    private var metadataView: some View {
        VStack(spacing: 20) {
            // Document Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Nom du document")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(.label))

                TextField("Ex: Vidange moteur", text: $store.documentName)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .documentName ? Color(.systemPurple) : Color(.separator), lineWidth: 2)
                    )
                    .focused($focusedField, equals: .documentName)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .mileage }
            }

            // Document Type
            VStack(alignment: .leading, spacing: 8) {
                Text("Type de document")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(.label))

                Menu {
                    ForEach(DocumentCategory.allCases, id: \.self) { category in
                        Section(category.displayName) {
                            ForEach(DocumentType.allCases.filter { $0.category == category }, id: \.self) { type in
                                Button {
                                    store.documentType = type
                                } label: {
                                    HStack {
                                        Image(systemName: type.imageName)
                                        Text(type.displayName)
                                        if store.documentType == type {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: store.documentType.imageName)
                            .foregroundStyle(Color(.systemPurple))
                        Text(store.documentType.displayName)
                            .foregroundStyle(Color(.label))
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 2)
                    )
                }
            }

            HStack(spacing: 12) {
                // Mileage
                VStack(alignment: .leading, spacing: 8) {
                    Text("Kilométrage")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(.label))

                    HStack {
                        TextField("120000", text: $store.documentMileage)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .mileage)
                        Text("km")
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .mileage ? Color(.systemPurple) : Color(.separator), lineWidth: 2)
                    )
                }

                // Date
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(.label))

                    Button {
                        focusedField = nil
                        openDateSheet = true
                    } label: {
                        HStack {
                            Text(formatDate(store.documentDate))
                                .foregroundStyle(Color(.label))
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.separator), lineWidth: 2)
                        )
                    }
                }
            }

            // Amount
            VStack(alignment: .leading, spacing: 8) {
                Text("Montant")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(.label))

                HStack {
                    TextField("0,00", text: $store.documentAmount)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .amount)
                    Text("€")
                        .foregroundStyle(Color(.secondaryLabel))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .amount ? Color(.systemPurple) : Color(.separator), lineWidth: 2)
                )
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Terminé") {
                    focusedField = nil
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(.systemPurple))
            }
        }
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func fileIcon(for fileName: String) -> String {
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return "doc.fill"
        case "jpg", "jpeg", "png", "heic": return "photo.fill"
        default: return "doc.fill"
        }
    }

    private func fileType(for fileName: String) -> String {
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return "Document PDF"
        case "jpg", "jpeg": return "Image JPEG"
        case "png": return "Image PNG"
        case "heic": return "Image HEIC"
        default: return "Fichier"
        }
    }
}

// MARK: - Animated Icon Components

struct AnimatedCameraIcon: View {
    let isSelected: Bool
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        Image(systemName: "camera.fill")
            .font(.title2)
            .foregroundStyle(isSelected ? Color(.systemPurple) : Color(.secondaryLabel))
            .scaleEffect(pulseScale)
            .frame(width: 40)
            .onAppear {
                if !isSelected {
                    startAnimation()
                }
            }
            .onChange(of: isSelected) { _, newValue in
                if !newValue {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
    }

    private func startAnimation() {
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.15
        }
    }

    private func stopAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            pulseScale = 1.0
        }
    }
}

struct AnimatedFolderIcon: View {
    let isSelected: Bool
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0

    var body: some View {
        Image(systemName: "folder.fill")
            .font(.title2)
            .foregroundStyle(isSelected ? Color(.systemPurple) : Color(.secondaryLabel))
            .scaleEffect(pulseScale)
            .rotationEffect(.degrees(rotationAngle))
            .frame(width: 40)
            .onAppear {
                if !isSelected {
                    startAnimation()
                }
            }
            .onChange(of: isSelected) { _, newValue in
                if !newValue {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
    }

    private func startAnimation() {
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.1
        }

        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            rotationAngle = -3
        }
    }

    private func stopAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            pulseScale = 1.0
            rotationAngle = 0
        }
    }
}

// MARK: - Source Button Component

struct SourceButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }

            action()
        }) {
            HStack(spacing: 16) {
                // Animated icon based on type
                if icon == "camera.fill" {
                    AnimatedCameraIcon(isSelected: isSelected)
                } else if icon == "folder.fill" {
                    AnimatedFolderIcon(isSelected: isSelected)
                } else {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(isSelected ? Color(.systemPurple) : Color(.secondaryLabel))
                        .frame(width: 40)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(isSelected ? Color(.systemPurple) : Color(.label))
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color(.secondaryLabel))
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color(.systemPurple))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(.systemPurple) : Color(.separator), lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - File Picker

struct FilePickerView: UIViewControllerRepresentable {
    let onFileSelected: (URL?) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.pdf, .jpeg, .png, .text, .plainText]
        )
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
