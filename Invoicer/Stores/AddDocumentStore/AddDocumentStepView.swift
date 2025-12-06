////
////  AddDocumentStepView.swift
////  Invoicer
////
////  Created by Nicolas Barbosa on 13/10/2025.
////
//
//import SwiftUI
//import ComposableArchitecture
//
//struct AddDocumentStepView: View {
//    let step: AddDocumentStep
//    @Bindable var store: StoreOf<AddDocumentStore>
//    @FocusState private var focusedField: Field?
//    @State private var openDateSheet: Bool = false
//
//    enum Field: Hashable {
//        case documentName, mileage, amount
//    }
//
//    var body: some View {
//        VStack(spacing: Spacing.lg) {
//            switch step {
//            case .selectSource:
//                selectSourceView
//            case .metadata:
//                metadataView
//            }
//        }
//        .fullScreenCover(isPresented: $store.showCamera) {
//            CameraView { image in
//                store.send(.imageCapture(image))
//            }
//        }
//        .fullScreenCover(isPresented: $store.showFilePicker) {
//            FilePickerView { url in
//                store.send(.fileSelected(url))
//            }
//        }
//        .sheet(isPresented: $openDateSheet) {
//            DatePickerSheet(
//                date: $store.documentDate,
//                onSave: { openDateSheet = false },
//                onCancel: { openDateSheet = false }
//            )
//            .presentationDetents([.medium])
//            .presentationDragIndicator(.visible)
//        }
//    }
//
//    // MARK: - Select Source View
//
//    private var selectSourceView: some View {
//        VStack(spacing: Spacing.lg) {
//            // Source Selection Buttons
//            VStack(spacing: Spacing.md) {
//                SourceButton(
//                    icon: "camera.fill",
//                    title: "Prendre une Photo",
//                    subtitle: "Utiliser l'appareil photo",
//                    isSelected: store.documentSource == .camera,
//                    action: { store.send(.showCamera) }
//                )
//
//                SourceButton(
//                    icon: "folder.fill",
//                    title: "Importer un Fichier",
//                    subtitle: "Depuis le stockage ou iCloud",
//                    isSelected: store.documentSource == .file,
//                    action: { store.send(.showFilePicker) }
//                )
//            }
//
//            // Preview if source selected
//            if store.hasSourceSelected {
//                previewSection
//                    .transition(.scale.combined(with: .opacity))
//            }
//        }
//        .animation(.easeInOut(duration: 0.3), value: store.hasSourceSelected)
//    }
//
//    private var previewSection: some View {
//        VStack(alignment: .leading, spacing: Spacing.md) {
//            HStack {
//                Text("Aperçu")
//                    .font(Typography.headline)
//                    .foregroundStyle(ColorTokens.textPrimary)
//
//                Spacer()
//
//                Button {
//                    store.send(.removeSource)
//                } label: {
//                    Label("Supprimer", systemImage: "xmark.circle.fill")
//                        .labelStyle(.iconOnly)
//                        .foregroundStyle(ColorTokens.error)
//                        .font(Typography.title3)
//                }
//            }
//
//            if let image = store.capturedImage, store.documentSource == .camera {
//                // Photo Preview
//                Image(uiImage: image)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxHeight: 300)
//                    .cornerRadius(Radius.md)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: Radius.md)
//                            .stroke(ColorTokens.actionPrimary, lineWidth: 2)
//                    )
//
//                Button {
//                    store.send(.showCamera)
//                } label: {
//                    Label("Reprendre la Photo", systemImage: "camera.fill")
//                        .font(Typography.subheadline)
//                        .foregroundStyle(ColorTokens.actionPrimary)
//                }
//            } else if let fileName = store.selectedFileName, store.documentSource == .file {
//                // File Preview
//                HStack(spacing: Spacing.sm) {
//                    Image(systemName: fileIcon(for: fileName))
//                        .font(Typography.title1)
//                        .foregroundStyle(ColorTokens.actionPrimary)
//
//                    VStack(alignment: .leading, spacing: Spacing.xxs) {
//                        Text(fileName)
//                            .font(Typography.subheadline)
//                            .foregroundStyle(ColorTokens.textPrimary)
//                            .lineLimit(2)
//
//                        Text(fileType(for: fileName))
//                            .font(Typography.caption1)
//                            .foregroundStyle(ColorTokens.textSecondary)
//                    }
//
//                    Spacer()
//                }
//                .padding(Spacing.md)
//                .background(ColorTokens.surfacePrimary)
//                .cornerRadius(Radius.md)
//                .overlay(
//                    RoundedRectangle(cornerRadius: Radius.md)
//                        .stroke(ColorTokens.actionPrimary, lineWidth: 2)
//                )
//
//                Button {
//                    store.send(.showFilePicker)
//                } label: {
//                    Label("Choisir un Autre Fichier", systemImage: "folder.fill")
//                        .font(Typography.subheadline)
//                        .foregroundStyle(ColorTokens.actionPrimary)
//                }
//            }
//        }
//        .padding(Spacing.md)
//        .background(ColorTokens.surfacePrimary)
//        .cornerRadius(Radius.md)
//    }
//
//    // MARK: - Metadata View
//
//    private var metadataView: some View {
//        VStack(spacing: Spacing.lg) {
//            // Document Name
//            VStack(alignment: .leading, spacing: Spacing.xs) {
//                Text("Nom du document")
//                    .font(Typography.subheadline)
//                    .foregroundStyle(ColorTokens.textPrimary)
//
//                TextField("Ex: Vidange moteur", text: $store.documentName)
//                    .padding(.horizontal, Spacing.md)
//                    .padding(.vertical, Spacing.md)
//                    .background(ColorTokens.surfacePrimary)
//                    .cornerRadius(Radius.md)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: Radius.md)
//                            .stroke(focusedField == .documentName ? ColorTokens.actionPrimary : ColorTokens.border, lineWidth: 2)
//                    )
//                    .focused($focusedField, equals: .documentName)
//                    .submitLabel(.next)
//                    .onSubmit { focusedField = .mileage }
//            }
//
//            // Document Type
//            VStack(alignment: .leading, spacing: Spacing.xs) {
//                Text("Type de document")
//                    .font(Typography.subheadline)
//                    .foregroundStyle(ColorTokens.textPrimary)
//
//                Menu {
//                    ForEach(DocumentCategory.allCases, id: \.self) { category in
//                        Section(category.displayName) {
//                            ForEach(DocumentType.allCases.filter { $0.category == category }, id: \.self) { type in
//                                Button {
//                                    store.documentType = type
//                                } label: {
//                                    HStack {
//                                        Image(systemName: type.imageName)
//                                        Text(type.displayName)
//                                        if store.documentType == type {
//                                            Spacer()
//                                            Image(systemName: "checkmark")
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                } label: {
//                    HStack {
//                        Image(systemName: store.documentType.imageName)
//                            .foregroundStyle(ColorTokens.actionPrimary)
//                        Text(store.documentType.displayName)
//                            .foregroundStyle(ColorTokens.textPrimary)
//                        Spacer()
//                        Image(systemName: "chevron.up.chevron.down")
//                            .font(Typography.caption1)
//                            .foregroundStyle(ColorTokens.textTertiary)
//                    }
//                    .padding(.horizontal, Spacing.md)
//                    .padding(.vertical, Spacing.md)
//                    .background(ColorTokens.surfacePrimary)
//                    .cornerRadius(Radius.md)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: Radius.md)
//                            .stroke(ColorTokens.border, lineWidth: 2)
//                    )
//                }
//            }
//
//            HStack(spacing: Spacing.sm) {
//                // Mileage
//                VStack(alignment: .leading, spacing: Spacing.xs) {
//                    Text("Kilométrage")
//                        .font(Typography.subheadline)
//                        .foregroundStyle(ColorTokens.textPrimary)
//
//                    HStack {
//                        TextField("120000", text: $store.documentMileage)
//                            .keyboardType(.numberPad)
//                            .focused($focusedField, equals: .mileage)
//                        Text("km")
//                            .foregroundStyle(ColorTokens.textSecondary)
//                    }
//                    .padding(.horizontal, Spacing.md)
//                    .padding(.vertical, Spacing.md)
//                    .background(ColorTokens.surfacePrimary)
//                    .cornerRadius(Radius.md)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: Radius.md)
//                            .stroke(focusedField == .mileage ? ColorTokens.actionPrimary : ColorTokens.border, lineWidth: 2)
//                    )
//                }
//
//                // Date
//                VStack(alignment: .leading, spacing: Spacing.xs) {
//                    Text("Date")
//                        .font(Typography.subheadline)
//                        .foregroundStyle(ColorTokens.textPrimary)
//
//                    Button {
//                        focusedField = nil
//                        openDateSheet = true
//                    } label: {
//                        HStack {
//                            Text(formatDate(store.documentDate))
//                                .foregroundStyle(ColorTokens.textPrimary)
//                            Spacer()
//                            Image(systemName: "calendar")
//                                .foregroundStyle(ColorTokens.textSecondary)
//                        }
//                        .padding(.horizontal, Spacing.md)
//                        .padding(.vertical, Spacing.md)
//                        .background(ColorTokens.surfacePrimary)
//                        .cornerRadius(Radius.md)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: Radius.md)
//                                .stroke(ColorTokens.border, lineWidth: 2)
//                        )
//                    }
//                }
//            }
//
//            // Amount
//            VStack(alignment: .leading, spacing: Spacing.xs) {
//                Text("Montant")
//                    .font(Typography.subheadline)
//                    .foregroundStyle(ColorTokens.textPrimary)
//
//                HStack {
//                    TextField("0,00", text: $store.documentAmount)
//                        .keyboardType(.decimalPad)
//                        .focused($focusedField, equals: .amount)
//                    Text("€")
//                        .foregroundStyle(ColorTokens.textSecondary)
//                }
//                .padding(.horizontal, Spacing.md)
//                .padding(.vertical, Spacing.md)
//                .background(ColorTokens.surfacePrimary)
//                .cornerRadius(Radius.md)
//                .overlay(
//                    RoundedRectangle(cornerRadius: Radius.md)
//                        .stroke(focusedField == .amount ? ColorTokens.actionPrimary : ColorTokens.border, lineWidth: 2)
//                )
//            }
//        }
//        .toolbar {
//            ToolbarItemGroup(placement: .keyboard) {
//                Spacer()
//                Button("Terminé") {
//                    focusedField = nil
//                }
//                .font(Typography.subheadline)
//                .foregroundStyle(ColorTokens.actionPrimary)
//            }
//        }
//    }
//
//    // MARK: - Helpers
//
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "fr_FR")
//        formatter.dateStyle = .medium
//        return formatter.string(from: date)
//    }
//
//    private func fileIcon(for fileName: String) -> String {
//        let ext = (fileName as NSString).pathExtension.lowercased()
//        switch ext {
//        case "pdf": return "doc.fill"
//        case "jpg", "jpeg", "png", "heic": return "photo.fill"
//        default: return "doc.fill"
//        }
//    }
//
//    private func fileType(for fileName: String) -> String {
//        let ext = (fileName as NSString).pathExtension.lowercased()
//        switch ext {
//        case "pdf": return "Document PDF"
//        case "jpg", "jpeg": return "Image JPEG"
//        case "png": return "Image PNG"
//        case "heic": return "Image HEIC"
//        default: return "Fichier"
//        }
//    }
//}
//
//// MARK: - Animated Icon Components
//
//struct AnimatedCameraIcon: View {
//    let isSelected: Bool
//    @State private var isAnimating = false
//    @State private var pulseScale: CGFloat = 1.0
//
//    var body: some View {
//        Image(systemName: "camera.fill")
//            .font(Typography.title2)
//            .foregroundStyle(isSelected ? ColorTokens.actionPrimary : ColorTokens.textSecondary)
//            .scaleEffect(pulseScale)
//            .frame(width: 40)
//            .onAppear {
//                if !isSelected {
//                    startAnimation()
//                }
//            }
//            .onChange(of: isSelected) { _, newValue in
//                if !newValue {
//                    startAnimation()
//                } else {
//                    stopAnimation()
//                }
//            }
//    }
//
//    private func startAnimation() {
//        withAnimation(
//            .easeInOut(duration: 1.2)
//            .repeatForever(autoreverses: true)
//        ) {
//            pulseScale = 1.15
//        }
//    }
//
//    private func stopAnimation() {
//        withAnimation(.easeOut(duration: 0.3)) {
//            pulseScale = 1.0
//        }
//    }
//}
//
//struct AnimatedFolderIcon: View {
//    let isSelected: Bool
//    @State private var pulseScale: CGFloat = 1.0
//    @State private var rotationAngle: Double = 0
//
//    var body: some View {
//        Image(systemName: "folder.fill")
//            .font(Typography.title2)
//            .foregroundStyle(isSelected ? ColorTokens.actionPrimary : ColorTokens.textSecondary)
//            .scaleEffect(pulseScale)
//            .rotationEffect(.degrees(rotationAngle))
//            .frame(width: 40)
//            .onAppear {
//                if !isSelected {
//                    startAnimation()
//                }
//            }
//            .onChange(of: isSelected) { _, newValue in
//                if !newValue {
//                    startAnimation()
//                } else {
//                    stopAnimation()
//                }
//            }
//    }
//
//    private func startAnimation() {
//        withAnimation(
//            .easeInOut(duration: 1.5)
//            .repeatForever(autoreverses: true)
//        ) {
//            pulseScale = 1.1
//        }
//
//        withAnimation(
//            .easeInOut(duration: 2.0)
//            .repeatForever(autoreverses: true)
//        ) {
//            rotationAngle = -3
//        }
//    }
//
//    private func stopAnimation() {
//        withAnimation(.easeOut(duration: 0.3)) {
//            pulseScale = 1.0
//            rotationAngle = 0
//        }
//    }
//}
//
//// MARK: - Source Button Component
//
//struct SourceButton: View {
//    let icon: String
//    let title: String
//    let subtitle: String
//    let isSelected: Bool
//    let action: () -> Void
//
//    @State private var isPressed = false
//
//    var body: some View {
//        Button(action: {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                isPressed = true
//            }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                    isPressed = false
//                }
//            }
//
//            action()
//        }) {
//            HStack(spacing: Spacing.md) {
//                // Animated icon based on type
//                if icon == "camera.fill" {
//                    AnimatedCameraIcon(isSelected: isSelected)
//                } else if icon == "folder.fill" {
//                    AnimatedFolderIcon(isSelected: isSelected)
//                } else {
//                    Image(systemName: icon)
//                        .font(Typography.title2)
//                        .foregroundStyle(isSelected ? ColorTokens.actionPrimary : ColorTokens.textSecondary)
//                        .frame(width: 40)
//                }
//
//                VStack(alignment: .leading, spacing: Spacing.xxs) {
//                    Text(title)
//                        .font(Typography.headline)
//                        .foregroundStyle(isSelected ? ColorTokens.actionPrimary : ColorTokens.textPrimary)
//                    Text(subtitle)
//                        .font(Typography.subheadline)
//                        .foregroundStyle(ColorTokens.textSecondary)
//                }
//
//                Spacer()
//
//                if isSelected {
//                    Image(systemName: "checkmark.circle.fill")
//                        .font(Typography.title3)
//                        .foregroundStyle(ColorTokens.actionPrimary)
//                        .transition(.scale.combined(with: .opacity))
//                }
//            }
//            .padding(Spacing.lg)
//            .background(ColorTokens.surfacePrimary)
//            .cornerRadius(Radius.md)
//            .overlay(
//                RoundedRectangle(cornerRadius: Radius.md)
//                    .stroke(isSelected ? ColorTokens.actionPrimary : ColorTokens.border, lineWidth: isSelected ? 2 : 1)
//            )
//            .scaleEffect(isPressed ? 0.97 : 1.0)
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//// MARK: - File Picker
//
//struct FilePickerView: UIViewControllerRepresentable {
//    let onFileSelected: (URL?) -> Void
//
//    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//        let picker = UIDocumentPickerViewController(
//            forOpeningContentTypes: [.pdf, .jpeg, .png, .text, .plainText]
//        )
//        picker.allowsMultipleSelection = false
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, UIDocumentPickerDelegate {
//        let parent: FilePickerView
//
//        init(_ parent: FilePickerView) {
//            self.parent = parent
//        }
//
//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            parent.onFileSelected(urls.first)
//        }
//
//        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//            parent.onFileSelected(nil)
//        }
//    }
//}
