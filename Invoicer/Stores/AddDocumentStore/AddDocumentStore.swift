//
//  AddDocumentStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct AddDocumentStore {
    @ObservableState
    struct State: Equatable {
        let vehicleId: UUID
        var capturedImage: UIImage?
        var isLoading = false
        var showCamera = false
        var showFilePicker = false
        var selectedFileURL: URL?
        var selectedFileName: String?
        var documentSource: DocumentSource = .none
        
        enum DocumentSource: Equatable {
            case none
            case camera
            case file
        }
    }
    
    enum Action: Equatable {
        case showCamera
        case hideCamera
        case showFilePicker
        case hideFilePicker
        case imageCapture(UIImage?)
        case fileSelected(URL?)
        case saveDocument
        case documentSaved
        case goBack
    }
    
    @Dependency(\.fileStorageService) var fileStorageService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showCamera:
                state.showCamera = true
                state.documentSource = .camera
                return .none
                
            case .hideCamera:
                state.showCamera = false
                return .none
                
            case .showFilePicker:
                state.showFilePicker = true
                state.documentSource = .file
                return .none
                
            case .hideFilePicker:
                state.showFilePicker = false
                return .none
                
            case .imageCapture(let image):
                state.capturedImage = image
                state.showCamera = false
                return .none
                
            case .fileSelected(let url):
                state.selectedFileURL = url
                state.selectedFileName = url?.lastPathComponent
                state.showFilePicker = false
                return .none
                
            case .saveDocument:
                if state.documentSource == .camera {
                    guard let image = state.capturedImage else {
                        return .none
                    }
                    
                    state.isLoading = true
                    return .run { [vehicleId = state.vehicleId] send in
                        await fileStorageService.saveDocument(image: image, for: vehicleId)
                        await send(.documentSaved)
                    }
                } else if state.documentSource == .file {
                    guard let fileURL = state.selectedFileURL else {
                        return .none
                    }
                    
                    state.isLoading = true
                    return .run { [vehicleId = state.vehicleId] send in
                        await fileStorageService.saveDocument(fileURL: fileURL, for: vehicleId)
                        await send(.documentSaved)
                    }
                }
                return .none
                
            case .documentSaved:
                state.isLoading = false
                return .none
                
            case .goBack:
                return .none
            }
        }
    }
}

extension UIImage: @retroactive @unchecked Sendable {}