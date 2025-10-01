//
//  FileDocumentDetailView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 14/09/2025.
//

import SwiftUI
import ComposableArchitecture
import UniformTypeIdentifiers
import PDFKit

struct FileDocumentDetailView: View {
    @Bindable var store: StoreOf<FileDocumentDetailStore>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if store.isLoading || store.document == nil {
                    ProgressView("Chargement...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let document = store.document {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Document info
                            documentInfoSection(document: document)
                            
                            // Document preview section
                            documentPreviewSection()
                            
                            // Action buttons
                            actionButtonsSection()
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .imageScale(.large)
                            .foregroundColor(.orange)
                        Text("Impossible de charger le document")
                            .font(.headline)
                        Text("Le fichier a peut-être été déplacé ou supprimé")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationTitle("Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Retour") {
                        store.send(.goBack)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            store.send(.shareDocument)
                        }) {
                            Label("Partager", systemImage: "square.and.arrow.up")
                        }
                        
                        Button("Supprimer", role: .destructive) {
                            store.send(.deleteDocument)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .disabled(store.isLoading)
                }
            }
            .onAppear {
                store.send(.loadDocument)
            }
        }
        .sheet(isPresented: .init(
            get: { store.showShareSheet },
            set: { _ in store.send(.hideShareSheet) }
        )) {
            if let document = store.document {
                ShareSheet(activityItems: [URL(fileURLWithPath: document.fileURL)])
            }
        }
    }
    
    @ViewBuilder
    private func documentInfoSection(document: Document) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Détails du Document")
                    .font(.headline)
                
                Spacer()
                
                Button("Éditer") {
                    store.send(.showEditDocument)
                }
                .foregroundColor(.blue)
                .disabled(store.isLoading)
            }
            
            HStack {
                Text("Nom:")
                    .fontWeight(.medium)
                Text(document.name)
                    .foregroundColor(.primary)
            }
            
            HStack {
                Text("Date:")
                    .fontWeight(.medium)
                Text(document.date, style: .date)
            }
            
            HStack {
                Text("Kilométrage:")
                    .fontWeight(.medium)
                Text(document.mileage.isEmpty ? "Non renseigné" : "\(document.mileage) km")
                    .foregroundColor(document.mileage.isEmpty ? .secondary : .primary)
            }
            
            HStack {
                Text("Type:")
                    .fontWeight(.medium)
                Text(document.type.displayName)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
//                    .background(getDocumentColor(for: document.type).opacity(0.2))
//                    .foregroundColor(getDocumentColor(for: document.type))
                    .cornerRadius(8)
                    
                Spacer()
                
                Text(fileTypeDescription(for: document.fileURL))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let fileData = store.fileData {
                HStack {
                    Text("Taille:")
                        .fontWeight(.medium)
                    Text(ByteCountFormatter.string(fromByteCount: Int64(fileData.count), countStyle: .file))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func documentPreviewSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aperçu")
                .font(.headline)
            
            if let pdfDocument = store.pdfDocument {
                // PDF preview
                VStack(spacing: 12) {
                    HStack {
                        Text("Aperçu PDF")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if let pageCount = store.pageCount {
                            Text("\(pageCount) page(s)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    PDFPreviewView(pdfDocument: pdfDocument)
                        .frame(height: 400)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
            } else if let fileContent = store.fileContent {
                // Text file preview
                ScrollView {
                    Text(fileContent)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                .frame(maxHeight: 300)
            } else {
                // No preview available
                VStack(spacing: 16) {
                    Image(systemName: fileIconName(for: store.document?.fileURL ?? ""))
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Aperçu non disponible")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Utilisez 'Partager / Ouvrir avec' pour afficher ce fichier")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func actionButtonsSection() -> some View {
        VStack(spacing: 12) {
            Button(action: {
                store.send(.shareDocument)
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Partager / Ouvrir avec...")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
    
    private func fileTypeDescription(for filePath: String) -> String {
        let url = URL(fileURLWithPath: filePath)
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "pdf":
            return "Document PDF"
        case "txt", "text":
            return "Fichier Texte"
        case "md":
            return "Fichier Markdown"
        case "json":
            return "Fichier JSON"
        case "xml":
            return "Fichier XML"
        case "csv":
            return "Fichier CSV"
        case "doc", "docx":
            return "Document Word"
        case "xls", "xlsx":
            return "Feuille Excel"
        case "ppt", "pptx":
            return "Présentation PowerPoint"
        default:
            return "Fichier (\(pathExtension.uppercased()))"
        }
    }
    
    private func fileIconName(for filePath: String) -> String {
        let url = URL(fileURLWithPath: filePath)
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "pdf":
            return "doc.richtext.fill"
        case "txt", "text", "md":
            return "doc.text.fill"
        case "json", "xml":
            return "doc.badge.gearshape.fill"
        case "csv":
            return "tablecells.fill"
        case "doc", "docx":
            return "doc.text.fill"
        case "xls", "xlsx":
            return "tablecells.fill"
        case "ppt", "pptx":
            return "rectangle.on.rectangle.angled.fill"
        default:
            return "doc.fill"
        }
    }
}

// Share Sheet pour partager des fichiers
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// PDF Preview View
struct PDFPreviewView: UIViewRepresentable {
    let pdfDocument: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document != pdfDocument {
            uiView.document = pdfDocument
        }
    }
}

#Preview {
    FileDocumentDetailView(store: Store(initialState: FileDocumentDetailStore.State(
        vehicleId: UUID(),
        documentId: UUID()
    )) {
        FileDocumentDetailStore()
    })
}
