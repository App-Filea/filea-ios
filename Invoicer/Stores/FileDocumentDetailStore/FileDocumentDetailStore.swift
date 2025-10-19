//
//  FileDocumentDetailStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 14/09/2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI
import UniformTypeIdentifiers
import PDFKit

@Reducer
struct FileDocumentDetailStore {
    @ObservableState
    struct State: Equatable {
        let vehicleId: UUID
        let documentId: UUID
        var document: Document?
        var fileData: Data?
        var fileContent: String?
        var pdfDocument: PDFDocument?
        var pageCount: Int?
        var isLoading = false
        var showShareSheet = false
    }
    
    enum Action: Equatable {
        case loadDocument
        case documentLoaded(Document?)
        case loadFileContent
        case fileContentLoaded(Data?, String?)
        case loadPDFDocument
        case pdfDocumentLoaded(PDFDocument?)
        case shareDocument
        case showShareSheet
        case hideShareSheet
        case deleteDocument
        case requestDeletion
        case documentDeleted
        case goBack
        case showEditDocument
    }
    
    @Dependency(\.vehicleRepository) var vehicleRepository
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadDocument:
                print("📖 [FileDocumentDetailStore] Chargement du document fichier: \(state.documentId)")
                return .run { [vehicleId = state.vehicleId, documentId = state.documentId] send in
                    do {
                        if let vehicle = try await vehicleRepository.find(by: vehicleId),
                           let document = vehicle.documents.first(where: { $0.id == documentId }) {
                            print("✅ [FileDocumentDetailStore] Document fichier trouvé: \(document.fileURL)")
                            await send(.documentLoaded(document))
                        } else {
                            print("❌ [FileDocumentDetailStore] Document fichier non trouvé avec ID: \(documentId)")
                            await send(.documentLoaded(nil))
                        }
                    } catch {
                        print("❌ [FileDocumentDetailStore] Erreur lors du chargement: \(error.localizedDescription)")
                        await send(.documentLoaded(nil))
                    }
                }
                
            case .documentLoaded(let document):
                state.document = document
                if let doc = document {
                    print("📄 [FileDocumentDetailStore] Document fichier chargé")
                    
                    // Determine if it's a PDF or text file
                    let url = URL(fileURLWithPath: doc.fileURL)
                    let pathExtension = url.pathExtension.lowercased()
                    
                    if pathExtension == "pdf" {
                        print("📑 [FileDocumentDetailStore] Document PDF détecté, chargement du PDF")
                        return .run { send in
                            await send(.loadPDFDocument)
                        }
                    } else {
                        print("📄 [FileDocumentDetailStore] Document non-PDF, chargement du contenu texte")
                        return .run { send in
                            await send(.loadFileContent)
                        }
                    }
                } else {
                    print("⚠️ [FileDocumentDetailStore] Aucun document fichier chargé")
                }
                return .none
                
            case .loadFileContent:
                guard let document = state.document else {
                    print("❌ [FileDocumentDetailStore] Impossible de charger le contenu - aucun document")
                    return .none
                }
                print("🔄 [FileDocumentDetailStore] Début du chargement du contenu: \(document.fileURL)")
                state.isLoading = true
                return .run { [fileURL = document.fileURL] send in
                    let (fileData, fileContent) = await loadFileContent(fileURL)
                    await send(.fileContentLoaded(fileData, fileContent))
                }
                
            case .fileContentLoaded(let data, let content):
                if data != nil {
                    print("✅ [FileDocumentDetailStore] Contenu du fichier chargé avec succès")
                } else {
                    print("❌ [FileDocumentDetailStore] Échec du chargement du contenu")
                }
                state.fileData = data
                state.fileContent = content
                state.isLoading = false
                return .none
                
            case .loadPDFDocument:
                guard let document = state.document else {
                    print("❌ [FileDocumentDetailStore] Impossible de charger le PDF - aucun document")
                    return .none
                }
                print("🔄 [FileDocumentDetailStore] Début du chargement du PDF: \(document.fileURL)")
                state.isLoading = true
                return .run { [fileURL = document.fileURL] send in
                    let pdfDocument = await loadPDFDocument(fileURL)
                    await send(.pdfDocumentLoaded(pdfDocument))
                }
                
            case .pdfDocumentLoaded(let pdfDocument):
                if let pdf = pdfDocument {
                    print("✅ [FileDocumentDetailStore] PDF chargé avec succès, \(pdf.pageCount) page(s)")
                    state.pageCount = pdf.pageCount
                } else {
                    print("❌ [FileDocumentDetailStore] Échec du chargement du PDF")
                }
                state.pdfDocument = pdfDocument
                state.isLoading = false
                return .none
                
            case .shareDocument:
                print("📤 [FileDocumentDetailStore] Partage du document")
                state.showShareSheet = true
                return .none
                
            case .showShareSheet:
                state.showShareSheet = true
                return .none
                
            case .hideShareSheet:
                state.showShareSheet = false
                return .none
                
                
            case .deleteDocument:
                print("🗑️ [FileDocumentDetailStore] Demande de suppression - fermeture d'abord")
                return .run { send in
                    await send(.requestDeletion)
                }
                
            case .requestDeletion:
                print("📤 [FileDocumentDetailStore] Demande de fermeture puis suppression")
                return .none
                
            case .documentDeleted:
                print("✅ [FileDocumentDetailStore] Document fichier supprimé avec succès (legacy)")
                state.isLoading = false
                return .run { send in
                    await send(.goBack)
                }
                
            case .goBack:
                print("🔙 [FileDocumentDetailStore] Retour à la vue précédente")
                return .none
                
            case .showEditDocument:
                return .none // This will be handled by the parent coordinator
            }
        }
    }
    
    private func loadFileContent(_ fileURL: String) async -> (Data?, String?) {
        print("📄 [FileDocumentDetailStore] Chargement du contenu depuis: \(fileURL)")
        
        let url = URL(fileURLWithPath: fileURL)
        
        do {
            let data = try Data(contentsOf: url)
            print("✅ [FileDocumentDetailStore] Données chargées avec succès, taille: \(data.count) bytes")
            
            // Try to load as text if it's a text file
            let pathExtension = url.pathExtension.lowercased()
            var textContent: String?
            
            if ["txt", "text", "md", "json", "xml", "csv"].contains(pathExtension) {
                textContent = String(data: data, encoding: .utf8)
                if textContent != nil {
                    print("✅ [FileDocumentDetailStore] Fichier texte décodé avec succès")
                } else {
                    print("⚠️ [FileDocumentDetailStore] Impossible de décoder le fichier comme texte UTF-8")
                }
            }
            
            return (data, textContent)
        } catch {
            print("❌ [FileDocumentDetailStore] Erreur lors du chargement du fichier: \(error.localizedDescription)")
            print("🔍 [FileDocumentDetailStore] URL tentée: \(url.path)")
            
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            print("📁 [FileDocumentDetailStore] Fichier existe: \(fileExists)")
            
            return (nil, nil)
        }
    }
    
    private func loadPDFDocument(_ fileURL: String) async -> PDFDocument? {
        print("📑 [FileDocumentDetailStore] Chargement du PDF depuis: \(fileURL)")
        
        let url = URL(fileURLWithPath: fileURL)
        
        do {
            let data = try Data(contentsOf: url)
            print("✅ [FileDocumentDetailStore] Données PDF chargées, taille: \(data.count) bytes")
            
            if let pdfDocument = PDFDocument(data: data) {
                let pageCount = pdfDocument.pageCount
                print("✅ [FileDocumentDetailStore] PDF créé avec succès, \(pageCount) page(s)")
                return pdfDocument
            } else {
                print("❌ [FileDocumentDetailStore] Impossible de créer PDFDocument à partir des données")
                return nil
            }
        } catch {
            print("❌ [FileDocumentDetailStore] Erreur lors du chargement du PDF: \(error.localizedDescription)")
            print("🔍 [FileDocumentDetailStore] URL tentée: \(url.path)")
            
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            print("📁 [FileDocumentDetailStore] Fichier existe: \(fileExists)")
            
            return nil
        }
    }
}

extension PDFDocument: @retroactive Equatable {
    public static func == (lhs: PDFDocument, rhs: PDFDocument) -> Bool {
        return lhs.documentURL == rhs.documentURL && lhs.pageCount == rhs.pageCount
    }
}