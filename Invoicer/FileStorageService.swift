//
//  FileStorageService.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import Foundation
import os.log
import SwiftUI
import Dependencies

extension DependencyValues {
    var fileStorageService: FileStorageServiceProtocol {
        get { self[FileStorageServiceKey.self] }
        set { self[FileStorageServiceKey.self] = newValue }
    }
}

private enum FileStorageServiceKey: DependencyKey {
    static let liveValue: FileStorageServiceProtocol = FileStorageService()
}

protocol FileStorageServiceProtocol: Sendable {
    func initializeStorage() async
    func openVehiclesFolder() async
    func loadVehicles() async -> [Vehicle]
    func saveVehicle(_ vehicle: Vehicle) async
    func saveDocument(image: UIImage, for vehicleId: UUID, name: String, date: Date, mileage: String, type: DocumentType) async
    func saveDocument(fileURL: URL, for vehicleId: UUID, name: String, date: Date, mileage: String, type: DocumentType) async
    func deleteVehicle(_ vehicleId: UUID) async
    func deleteDocument(_ document: Document, for vehicleId: UUID) async
    func updateVehicle(_ vehicleId: UUID, with updatedVehicle: Vehicle) async
    func updateDocument(_ document: Document, for vehicleId: UUID) async
    func replaceDocumentPhoto(_ documentId: UUID, in vehicleId: UUID, with newImage: UIImage) async
}

extension FileStorageService: FileStorageServiceProtocol {
    func initializeStorage() async {
        await Task {
            self.initializeStorage()
        }.value
    }
    
    func openVehiclesFolder() async {
        await Task {
            self.openVehiclesFolder()
        }.value
    }
    
    func loadVehicles() async -> [Vehicle] {
        await Task {
            self.loadVehicles()
        }.value
    }
    
    func saveVehicle(_ vehicle: Vehicle) async {
        await Task {
            self.saveVehicle(vehicle)
        }.value
    }
    
    func saveDocument(image: UIImage, for vehicleId: UUID, name: String, date: Date, mileage: String, type: DocumentType) async {
        await Task {
            self.saveDocument(
                image: image,
                for: vehicleId,
                name: name,
                date: date,
                mileage: mileage,
                type: type
            )
        }.value
    }
    
    func saveDocument(fileURL: URL, for vehicleId: UUID, name: String, date: Date, mileage: String, type: DocumentType) async {
        await Task {
            self.saveDocument(
                fileURL: fileURL,
                for: vehicleId,
                name: name,
                date: date,
                mileage: mileage,
                type: type
            )
        }.value
    }
    
    func deleteVehicle(_ vehicleId: UUID) async {
        await Task {
            self.deleteVehicle(vehicleId)
        }.value
    }
    
    func deleteDocument(_ document: Document, for vehicleId: UUID) async {
        await Task {
            self.deleteDocument(document, for: vehicleId)
        }.value
    }
    
    func updateVehicle(_ vehicleId: UUID, with updatedVehicle: Vehicle) async {
        await Task {
            self.updateVehicle(vehicleId, with: updatedVehicle)
        }.value
    }
    
    func updateDocument(_ document: Document, for vehicleId: UUID) async {
        await Task {
            self.updateDocument(document, for: vehicleId)
        }.value
    }
    
    func replaceDocumentPhoto(_ documentId: UUID, in vehicleId: UUID, with newImage: UIImage) async {
        await Task {
            self.replaceDocumentPhoto(documentId, in: vehicleId, with: newImage)
        }.value
    }
}


final class FileStorageService: @unchecked Sendable {
    private let logger = Logger(subsystem: "com.invoicer.nbarb.Invoicer", category: "FileStorage")
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var vehiclesDirectory: URL {
        documentsDirectory.appendingPathComponent("Vehicles")
    }
    
    private var vehiclesFileURL: URL {
        vehiclesDirectory.appendingPathComponent("vehicles.json")
    }
    
    func initializeStorage() {
        logger.info("🚀 Initialisation du système de stockage...")
        
        createVehiclesDirectoryIfNeeded()
        createVehiclesFileIfNeeded()
        
        logger.info("✅ Initialisation du stockage terminée")
    }
    
    private func createVehiclesDirectoryIfNeeded() {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: vehiclesDirectory.path) {
            logger.info("📁 Le dossier Vehicles existe déjà à: \(self.vehiclesDirectory.path)")
        } else {
            do {
                try fileManager.createDirectory(at: vehiclesDirectory, withIntermediateDirectories: true)
                logger.info("📁 Dossier Vehicles créé avec succès à: \(self.vehiclesDirectory.path)")
            } catch {
                logger.error("❌ Erreur lors de la création du dossier Vehicles: \(error.localizedDescription)")
            }
        }
    }
    
    private func createVehiclesFileIfNeeded() {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: vehiclesFileURL.path) {
            logger.info("📄 Le fichier vehicles.json existe déjà à: \(self.vehiclesFileURL.path)")
        } else {
            let emptyVehiclesList: [Vehicle] = []
            
            do {
                let jsonData = try JSONEncoder().encode(emptyVehiclesList)
                try jsonData.write(to: vehiclesFileURL)
                logger.info("📄 Fichier vehicles.json créé avec succès à: \(self.vehiclesFileURL.path)")
                logger.info("📝 Liste de véhicules vide initialisée")
            } catch {
                logger.error("❌ Erreur lors de la création du fichier vehicles.json: \(error.localizedDescription)")
            }
        }
    }
    
    func openVehiclesFolder() {
        logger.info("📂 Tentative d'ouverture du dossier Vehicles...")
        
        guard FileManager.default.fileExists(atPath: vehiclesDirectory.path) else {
            logger.error("❌ Le dossier Vehicles n'existe pas à: \(self.vehiclesDirectory.path)")
            return
        }
        
        DispatchQueue.main.async { [self] in
            if UIApplication.shared.canOpenURL(vehiclesDirectory) {
                UIApplication.shared.open(vehiclesDirectory) { success in
                    if success {
                        self.logger.info("✅ Dossier Vehicles ouvert avec succès")
                    } else {
                        self.logger.error("❌ Impossible d'ouvrir le dossier Vehicles")
                    }
                }
            } else {
                logger.error("❌ URL du dossier non supportée pour l'ouverture")
                // Alternative: utiliser UIDocumentInteractionController ou présenter une alerte
                presentFolderLocationInfo()
            }
        }
    }
    
    private func presentFolderLocationInfo() {
        DispatchQueue.main.async { [self] in
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                logger.error("❌ Impossible de trouver la fenêtre principale")
                return
            }
            
            let alert = UIAlertController(
                title: "Dossier Vehicles", 
                message: "Le dossier se trouve à:\n\(vehiclesDirectory.path)", 
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            if let presentedViewController = window.rootViewController?.presentedViewController {
                presentedViewController.present(alert, animated: true)
            } else {
                window.rootViewController?.present(alert, animated: true)
            }
            
            logger.info("📍 Affichage du chemin du dossier Vehicles")
        }
    }
    
    func loadVehicles() -> [Vehicle] {
        logger.info("📖 Chargement de la liste des véhicules...")
        
        guard FileManager.default.fileExists(atPath: vehiclesFileURL.path) else {
            logger.warning("⚠️ Le fichier vehicles.json n'existe pas encore")
            return []
        }
        
        do {
            let jsonData = try Data(contentsOf: vehiclesFileURL)
            var vehicles = try JSONDecoder().decode([Vehicle].self, from: jsonData)
            logger.info("✅ \(vehicles.count) véhicule(s) chargé(s) avec succès")
            
            // Clean up orphaned document references
            var shouldSave = false
            for vehicleIndex in 0..<vehicles.count {
                let vehicle = vehicles[vehicleIndex]
                var validDocuments: [Document] = []
                
                for document in vehicle.documents {
                    let fileURL = URL(fileURLWithPath: document.fileURL)
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        validDocuments.append(document)
                    } else {
                        logger.warning("🧹 Suppression de référence orpheline: \(document.fileURL)")
                        shouldSave = true
                    }
                }
                
                if validDocuments.count != vehicle.documents.count {
                    vehicles[vehicleIndex].documents = validDocuments
                    logger.info("🔧 Nettoyé \(vehicle.documents.count - validDocuments.count) référence(s) orpheline(s) pour '\(vehicle.name)'")
                }
            }
            
            // Save cleaned up data if necessary
            if shouldSave {
                logger.info("💾 Sauvegarde du JSON nettoyé...")
                let cleanJsonData = try JSONEncoder().encode(vehicles)
                try cleanJsonData.write(to: vehiclesFileURL)
                logger.info("✅ JSON nettoyé sauvegardé")
            }
            
            return vehicles
        } catch {
            logger.error("❌ Erreur lors du chargement des véhicules: \(error.localizedDescription)")
            return []
        }
    }
    
    func saveVehicle(_ vehicle: Vehicle) {
        logger.info("💾 Sauvegarde du véhicule: \(vehicle.name)")
        
        // First, create the vehicle directory
        guard createVehicleDirectory(for: vehicle) else {
            logger.error("❌ Échec de la création du dossier pour le véhicule '\(vehicle.name)'")
            return
        }
        
        var vehicles = loadVehicles()
        vehicles.append(vehicle)
        
        do {
            let jsonData = try JSONEncoder().encode(vehicles)
            try jsonData.write(to: vehiclesFileURL)
            logger.info("✅ Véhicule '\(vehicle.name)' sauvegardé avec succès")
            logger.info("📊 Total de véhicules: \(vehicles.count)")
        } catch {
            logger.error("❌ Erreur lors de la sauvegarde du véhicule: \(error.localizedDescription)")
        }
    }
    
    private func createVehicleDirectory(for vehicle: Vehicle) -> Bool {
        let vehicleDirectoryURL = vehiclesDirectory.appendingPathComponent(vehicle.name)
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: vehicleDirectoryURL.path) {
            logger.info("📁 Le dossier pour '\(vehicle.name)' existe déjà à: \(vehicleDirectoryURL.path)")
            return true
        } else {
            do {
                try fileManager.createDirectory(at: vehicleDirectoryURL, withIntermediateDirectories: true)
                logger.info("📁 Dossier pour '\(vehicle.name)' créé avec succès à: \(vehicleDirectoryURL.path)")
                return true
            } catch {
                logger.error("❌ Erreur lors de la création du dossier pour '\(vehicle.name)': \(error.localizedDescription)")
                return false
            }
        }
    }
    
    
    func saveDocument(image: UIImage, for vehicleId: UUID, name: String, date: Date, mileage: String, type: DocumentType) {
        logger.info("💾 Sauvegarde d'un document image pour le véhicule: \(vehicleId)")
        
        // Find the vehicle to get its folder name
        var vehicles = loadVehicles()
        guard let vehicleIndex = vehicles.firstIndex(where: { $0.id == vehicleId }) else {
            logger.error("❌ Véhicule non trouvé avec l'ID: \(vehicleId)")
            return
        }
        
        let vehicle = vehicles[vehicleIndex]
        
        // Create filename with timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let filename = "document_\(dateFormatter.string(from: Date())).jpg"
        
        let vehicleDirectoryURL = vehiclesDirectory.appendingPathComponent(vehicle.name)
        let imageFileURL = vehicleDirectoryURL.appendingPathComponent(filename)
        
        // Save image to disk
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            logger.error("❌ Impossible de convertir l'image en données JPEG")
            return
        }
        
        do {
            try imageData.write(to: imageFileURL)
            logger.info("📄 Image sauvegardée à: \(imageFileURL.path)")
            
            // Create document object with metadata
            let document = Document(
                fileURL: imageFileURL.path,
                name: name,
                date: date,
                mileage: mileage,
                type: type
            )
            
            // Add document to vehicle
            vehicles[vehicleIndex].documents.append(document)
            
            // Save updated vehicles list
            let jsonData = try JSONEncoder().encode(vehicles)
            try jsonData.write(to: vehiclesFileURL)
            
            logger.info("✅ Document image sauvegardé avec succès")
            logger.info("📊 Total de documents pour ce véhicule: \(vehicles[vehicleIndex].documents.count)")
            
        } catch {
            logger.error("❌ Erreur lors de la sauvegarde du document: \(error.localizedDescription)")
        }
    }
    
    func saveDocument(fileURL: URL, for vehicleId: UUID, name: String, date: Date, mileage: String, type: DocumentType) {
        logger.info("💾 Sauvegarde d'un fichier document pour le véhicule: \(vehicleId)")
        logger.info("📄 Fichier source: \(fileURL.lastPathComponent)")
        
        // Find the vehicle to get its folder name
        var vehicles = loadVehicles()
        guard let vehicleIndex = vehicles.firstIndex(where: { $0.id == vehicleId }) else {
            logger.error("❌ Véhicule non trouvé avec l'ID: \(vehicleId)")
            return
        }
        
        let vehicle = vehicles[vehicleIndex]
        
        // Get original filename and extension
        let originalFilename = fileURL.lastPathComponent
        let fileExtension = fileURL.pathExtension
        let baseName = (originalFilename as NSString).deletingPathExtension
        
        // Create filename with timestamp to avoid conflicts
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let filename: String
        
        if fileExtension.isEmpty {
            filename = "\(baseName)_\(timestamp)"
        } else {
            filename = "\(baseName)_\(timestamp).\(fileExtension)"
        }
        
        let vehicleDirectoryURL = vehiclesDirectory.appendingPathComponent(vehicle.name)
        let destinationFileURL = vehicleDirectoryURL.appendingPathComponent(filename)
        
        do {
            // Start accessing security-scoped resource
            let hasAccess = fileURL.startAccessingSecurityScopedResource()
            defer {
                if hasAccess {
                    fileURL.stopAccessingSecurityScopedResource()
                }
            }
            
            // Copy file to vehicle directory
            try FileManager.default.copyItem(at: fileURL, to: destinationFileURL)
            logger.info("📄 Fichier copié vers: \(destinationFileURL.path)")
            
            // Create document object with metadata
            let document = Document(
                fileURL: destinationFileURL.path,
                name: name,
                date: date,
                mileage: mileage,
                type: type
            )
            
            // Add document to vehicle
            vehicles[vehicleIndex].documents.append(document)
            
            // Save updated vehicles list
            let jsonData = try JSONEncoder().encode(vehicles)
            try jsonData.write(to: vehiclesFileURL)
            
            logger.info("✅ Document fichier sauvegardé avec succès")
            logger.info("📊 Total de documents pour ce véhicule: \(vehicles[vehicleIndex].documents.count)")
            
        } catch {
            logger.error("❌ Erreur lors de la sauvegarde du fichier: \(error.localizedDescription)")
        }
    }
    
    func deleteVehicle(_ vehicleId: UUID) {
        logger.info("🗑️ Suppression du véhicule avec ID: \(vehicleId)")
        
        var vehicles = loadVehicles()
        guard let vehicleIndex = vehicles.firstIndex(where: { $0.id == vehicleId }) else {
            logger.error("❌ Véhicule non trouvé avec l'ID: \(vehicleId)")
            return
        }
        
        let vehicle = vehicles[vehicleIndex]
        let vehicleDirectoryURL = vehiclesDirectory.appendingPathComponent(vehicle.name)
        
        // Delete vehicle directory and all its contents
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: vehicleDirectoryURL.path) {
            do {
                try fileManager.removeItem(at: vehicleDirectoryURL)
                logger.info("🗂️ Dossier du véhicule '\(vehicle.name)' supprimé avec succès")
            } catch {
                logger.error("❌ Erreur lors de la suppression du dossier: \(error.localizedDescription)")
            }
        }
        
        // Remove vehicle from array
        vehicles.remove(at: vehicleIndex)
        
        // Save updated vehicles list
        do {
            let jsonData = try JSONEncoder().encode(vehicles)
            try jsonData.write(to: vehiclesFileURL)
            logger.info("✅ Véhicule '\(vehicle.name)' supprimé du JSON avec succès")
            logger.info("📊 Véhicules restants: \(vehicles.count)")
        } catch {
            logger.error("❌ Erreur lors de la sauvegarde du fichier JSON: \(error.localizedDescription)")
        }
    }
    
    func deleteDocument(_ document: Document, for vehicleId: UUID) {
        logger.info("🗑️ Suppression du document: \(document.id)")
        
        var vehicles = loadVehicles()
        guard let vehicleIndex = vehicles.firstIndex(where: { $0.id == vehicleId }) else {
            logger.error("❌ Véhicule non trouvé avec l'ID: \(vehicleId)")
            return
        }
        
        let vehicle = vehicles[vehicleIndex]
        
        // Remove document from vehicle's documents array
        guard let documentIndex = vehicles[vehicleIndex].documents.firstIndex(where: { $0.id == document.id }) else {
            logger.error("❌ Document non trouvé avec l'ID: \(document.id)")
            return
        }
        
        vehicles[vehicleIndex].documents.remove(at: documentIndex)
        
        // Delete physical file
        let fileManager = FileManager.default
        let fileURL = URL(fileURLWithPath: document.fileURL)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
                logger.info("📄 Fichier du document supprimé: \(document.fileURL)")
            } catch {
                logger.error("❌ Erreur lors de la suppression du fichier: \(error.localizedDescription)")
            }
        }
        
        // Save updated vehicles list
        do {
            let jsonData = try JSONEncoder().encode(vehicles)
            try jsonData.write(to: vehiclesFileURL)
            logger.info("✅ Document supprimé du JSON avec succès")
            logger.info("📊 Documents restants pour '\(vehicle.name)': \(vehicles[vehicleIndex].documents.count)")
        } catch {
            logger.error("❌ Erreur lors de la sauvegarde du fichier JSON: \(error.localizedDescription)")
        }
    }
    
    func updateVehicle(_ vehicleId: UUID, with updatedVehicle: Vehicle) {
        logger.info("✏️ Mise à jour du véhicule avec ID: \(vehicleId)")
        
        var vehicles = loadVehicles()
        guard let vehicleIndex = vehicles.firstIndex(where: { $0.id == vehicleId }) else {
            logger.error("❌ Véhicule non trouvé avec l'ID: \(vehicleId)")
            return
        }
        
        let oldVehicle = vehicles[vehicleIndex]
        let oldVehicleDirectoryURL = vehiclesDirectory.appendingPathComponent(oldVehicle.name)
        let newVehicleDirectoryURL = vehiclesDirectory.appendingPathComponent(updatedVehicle.name)
        
        // If the name changed, rename the directory
        let fileManager = FileManager.default
        if oldVehicle.name != updatedVehicle.name && fileManager.fileExists(atPath: oldVehicleDirectoryURL.path) {
            do {
                try fileManager.moveItem(at: oldVehicleDirectoryURL, to: newVehicleDirectoryURL)
                logger.info("📁 Dossier renommé de '\(oldVehicle.name)' vers '\(updatedVehicle.name)'")
            } catch {
                logger.error("❌ Erreur lors du renommage du dossier: \(error.localizedDescription)")
                return
            }
        }
        
        // Update the vehicle properties while preserving ID and documents
        vehicles[vehicleIndex].name = updatedVehicle.name
        vehicles[vehicleIndex].currentMileage = updatedVehicle.currentMileage
        vehicles[vehicleIndex].registrationDate = updatedVehicle.registrationDate
        vehicles[vehicleIndex].licensePlate = updatedVehicle.licensePlate
        
        // Save updated vehicles list
        do {
            let jsonData = try JSONEncoder().encode(vehicles)
            try jsonData.write(to: vehiclesFileURL)
            logger.info("✅ Véhicule '\(updatedVehicle.name)' mis à jour avec succès")
        } catch {
            logger.error("❌ Erreur lors de la sauvegarde du fichier JSON: \(error.localizedDescription)")
        }
    }
    
    func replaceDocumentPhoto(_ documentId: UUID, in vehicleId: UUID, with newImage: UIImage) {
        logger.info("📸 Remplacement de la photo du document: \(documentId)")
        logger.info("🔍 Recherche du véhicule: \(vehicleId)")
        
        var vehicles = loadVehicles()
        logger.info("📊 \(vehicles.count) véhicule(s) chargé(s)")
        
        guard let vehicleIndex = vehicles.firstIndex(where: { $0.id == vehicleId }) else {
            logger.error("❌ Véhicule non trouvé avec l'ID: \(vehicleId)")
            return
        }
        
        logger.info("✅ Véhicule trouvé: '\(vehicles[vehicleIndex].name)' avec \(vehicles[vehicleIndex].documents.count) document(s)")
        
        guard let documentIndex = vehicles[vehicleIndex].documents.firstIndex(where: { $0.id == documentId }) else {
            logger.error("❌ Document non trouvé avec l'ID: \(documentId)")
            logger.error("📋 Documents disponibles: \(vehicles[vehicleIndex].documents.map { $0.id })")
            return
        }
        
        let document = vehicles[vehicleIndex].documents[documentIndex]
        let vehicle = vehicles[vehicleIndex]
        let oldFileURL = URL(fileURLWithPath: document.fileURL)
        
        logger.info("📄 Document trouvé, ancien fichier: \(document.fileURL)")
        
        // Create new filename with timestamp including milliseconds to ensure uniqueness
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss-SSS"
        let timestamp = dateFormatter.string(from: Date())
        let uniqueId = UUID().uuidString.prefix(8) // Add 8 chars from UUID for extra uniqueness
        let filename = "document_\(timestamp)_\(uniqueId).jpg"
        
        let vehicleDirectoryURL = vehiclesDirectory.appendingPathComponent(vehicle.name)
        let newFileURL = vehicleDirectoryURL.appendingPathComponent(filename)
        
        logger.info("🆕 Nouveau fichier: \(newFileURL.path)")
        
        // Critical check: ensure we're not trying to replace with the same file
        if oldFileURL.path == newFileURL.path {
            logger.error("🚨 ERREUR CRITIQUE: Tentative de remplacement avec le même nom de fichier!")
            logger.error("📋 Ancien: \(oldFileURL.path)")
            logger.error("📋 Nouveau: \(newFileURL.path)")
            return
        }
        
        logger.info("✅ Noms de fichiers différents confirmés")
        logger.info("📋 Ancien: \(oldFileURL.lastPathComponent)")
        logger.info("📋 Nouveau: \(newFileURL.lastPathComponent)")
        
        // Save new image
        guard let imageData = newImage.jpegData(compressionQuality: 0.8) else {
            logger.error("❌ Impossible de convertir l'image en données JPEG")
            return
        }
        
        logger.info("📊 Taille de l'image: \(imageData.count) bytes")
        
        let fileManager = FileManager.default
        
        do {
            // Ensure the vehicle directory exists before saving
            if !fileManager.fileExists(atPath: vehicleDirectoryURL.path) {
                logger.info("📁 Création du dossier véhicule manquant: \(vehicleDirectoryURL.path)")
                try fileManager.createDirectory(at: vehicleDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            // Save new image
            logger.info("💾 Sauvegarde de la nouvelle image...")
            logger.info("📂 Dossier de destination: \(vehicleDirectoryURL.path)")
            logger.info("📄 Nom du fichier: \(filename)")
            
            try imageData.write(to: newFileURL)
            logger.info("✅ Écriture terminée, vérification...")
            
            // Verify new file was created
            if fileManager.fileExists(atPath: newFileURL.path) {
                let attributes = try fileManager.attributesOfItem(atPath: newFileURL.path)
                let fileSize = attributes[.size] as? NSNumber
                logger.info("🔍 Vérification nouveau fichier: existe=true, taille=\(fileSize?.intValue ?? 0) bytes")
                
                // Double check the file can be read
                let testData = try Data(contentsOf: newFileURL)
                logger.info("📖 Test de lecture: \(testData.count) bytes lus avec succès")
            } else {
                logger.error("🚨 ERREUR CRITIQUE: Le nouveau fichier n'existe pas après sauvegarde!")
                logger.error("🔍 Chemin testé: \(newFileURL.path)")
                logger.error("🔍 Dossier parent existe: \(fileManager.fileExists(atPath: vehicleDirectoryURL.path))")
                return
            }
            
            // Delete old file
            if fileManager.fileExists(atPath: oldFileURL.path) {
                logger.info("🗑️ Suppression de l'ancienne image: \(oldFileURL.path)")
                try fileManager.removeItem(at: oldFileURL)
                
                // Verify old file was deleted
                if fileManager.fileExists(atPath: oldFileURL.path) {
                    logger.error("🚨 ERREUR: L'ancien fichier existe toujours après suppression!")
                } else {
                    logger.info("✅ Ancien fichier supprimé avec succès et confirmé absent")
                }
            } else {
                logger.warning("⚠️ Ancien fichier introuvable: \(oldFileURL.path)")
            }
            
            // Update document with new file path while preserving ID and creation date
            let oldPath = vehicles[vehicleIndex].documents[documentIndex].fileURL
            logger.info("🔄 Avant mutation - Ancien chemin: '\(oldPath)'")
            logger.info("🔄 ID du document avant mutation: \(vehicles[vehicleIndex].documents[documentIndex].id)")
            
            vehicles[vehicleIndex].documents[documentIndex].fileURL = newFileURL.path
            
            let newPath = vehicles[vehicleIndex].documents[documentIndex].fileURL
            logger.info("🔄 Après mutation - Nouveau chemin: '\(newPath)'")
            
            if newPath == newFileURL.path {
                logger.info("✅ Mutation réussie: le chemin a bien été modifié")
            } else {
                logger.error("🚨 ERREUR DE MUTATION: le chemin n'a pas été modifié correctement!")
                logger.error("📋 Attendu: '\(newFileURL.path)'")
                logger.error("📋 Obtenu: '\(newPath)'")
                return
            }
            
            // Save updated vehicles list
            logger.info("💾 Sauvegarde du JSON mis à jour...")
            let jsonData = try JSONEncoder().encode(vehicles)
            try jsonData.write(to: vehiclesFileURL)
            logger.info("✅ JSON sauvegardé avec succès")
            
            // Verification: reload and check if the update was successful
            let verificationVehicles = loadVehicles()
            if let verificationVehicle = verificationVehicles.first(where: { $0.id == vehicleId }),
               let verificationDocument = verificationVehicle.documents.first(where: { $0.id == documentId }) {
                logger.info("🔍 Vérification: nouveau chemin dans le JSON: \(verificationDocument.fileURL)")
                if verificationDocument.fileURL == newFileURL.path {
                    logger.info("✅ Vérification réussie - le JSON contient le bon chemin")
                } else {
                    logger.error("❌ Vérification échouée - le JSON contient: '\(verificationDocument.fileURL)' au lieu de '\(newFileURL.path)'")
                }
            } else {
                logger.error("❌ Vérification échouée - document non trouvé après sauvegarde")
            }
            
            logger.info("🎉 Photo du document remplacée avec succès!")
            logger.info("📋 Document ID: \(documentId), Nouveau fichier: \(newFileURL.path)")
            
        } catch {
            logger.error("💥 Erreur lors du remplacement de la photo: \(error.localizedDescription)")
            logger.error("🔍 Détails: oldFileURL=\(oldFileURL.path), newFileURL=\(newFileURL.path)")
        }
    }
    
    func updateDocument(_ document: Document, for vehicleId: UUID) {
        logger.info("📝 Mise à jour du document \(document.id) pour le véhicule: \(vehicleId)")
        
        // Load current vehicles
        var vehicles = loadVehicles()
        
        guard let vehicleIndex = vehicles.firstIndex(where: { $0.id == vehicleId }) else {
            logger.error("❌ Véhicule non trouvé avec l'ID: \(vehicleId)")
            return
        }
        
        guard let documentIndex = vehicles[vehicleIndex].documents.firstIndex(where: { $0.id == document.id }) else {
            logger.error("❌ Document non trouvé avec l'ID: \(document.id)")
            return
        }
        
        // Update the document
        vehicles[vehicleIndex].documents[documentIndex] = document
        
        do {
            // Save updated vehicles list
            let jsonData = try JSONEncoder().encode(vehicles)
            try jsonData.write(to: vehiclesFileURL)
            
            logger.info("✅ Document mis à jour avec succès")
            logger.info("📊 Nom: \(document.name), Type: \(document.type.displayName)")
            
        } catch {
            logger.error("❌ Erreur lors de la mise à jour du document: \(error.localizedDescription)")
        }
    }
    
}
