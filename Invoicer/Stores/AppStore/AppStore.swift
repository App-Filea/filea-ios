//
//  AppStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct AppStore {
    @ObservableState
    struct State: Equatable {
        var mainStore = MainStore.State()
        var isStorageInitialized = false
    }
    
    enum Action: Equatable {
        case mainAction(MainStore.Action)
        case initializeStorage
        case storageInitialized
    }
    
    @Dependency(\.fileStorageService) var fileStorageService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .initializeStorage:
                return .run { send in
                    await fileStorageService.initializeStorage()
                    await send(.storageInitialized)
                }
                
            case .storageInitialized:
                state.isStorageInitialized = true
                return .none
                
            case .mainAction:
                return .none
            }
        }
        
        Scope(state: \.mainStore, action: \.mainAction) {
            MainStore()
        }
    }
}

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
    func saveDocument(image: UIImage, for vehicleId: UUID) async
    func saveDocument(fileURL: URL, for vehicleId: UUID) async
    func deleteVehicle(_ vehicleId: UUID) async
    func deleteDocument(_ document: Document, for vehicleId: UUID) async
    func updateVehicle(_ vehicleId: UUID, with updatedVehicle: Vehicle) async
    func replaceDocumentPhoto(_ documentId: UUID, in vehicleId: UUID, with newImage: UIImage) async
}

extension FileStorageService: FileStorageServiceProtocol {
    func initializeStorage() async {
        await Task { [self] in
            initializeStorage()
        }.value
    }
    
    func openVehiclesFolder() async {
        await Task { [self] in
            openVehiclesFolder()
        }.value
    }
    
    func loadVehicles() async -> [Vehicle] {
        await Task { [self] in
            loadVehicles()
        }.value
    }
    
    func saveVehicle(_ vehicle: Vehicle) async {
        await Task { [self] in
            saveVehicle(vehicle)
        }.value
    }
    
    func saveDocument(image: UIImage, for vehicleId: UUID) async {
        await Task { [self] in
            saveDocument(image: image, for: vehicleId)
        }.value
    }
    
    func saveDocument(fileURL: URL, for vehicleId: UUID) async {
        await Task { [self] in
            saveDocument(fileURL: fileURL, for: vehicleId)
        }.value
    }
    
    func deleteVehicle(_ vehicleId: UUID) async {
        await Task { [self] in
            deleteVehicle(vehicleId)
        }.value
    }
    
    func deleteDocument(_ document: Document, for vehicleId: UUID) async {
        await Task { [self] in
            deleteDocument(document, for: vehicleId)
        }.value
    }
    
    func updateVehicle(_ vehicleId: UUID, with updatedVehicle: Vehicle) async {
        await Task { [self] in
            updateVehicle(vehicleId, with: updatedVehicle)
        }.value
    }
    
    func replaceDocumentPhoto(_ documentId: UUID, in vehicleId: UUID, with newImage: UIImage) async {
        await Task { [self] in
            replaceDocumentPhoto(documentId, in: vehicleId, with: newImage)
        }.value
    }
}
