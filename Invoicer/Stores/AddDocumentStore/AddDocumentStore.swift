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
    }
    
    enum Action: Equatable {
        case showCamera
        case hideCamera
        case imageCapture(UIImage?)
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
                return .none
                
            case .hideCamera:
                state.showCamera = false
                return .none
                
            case .imageCapture(let image):
                state.capturedImage = image
                state.showCamera = false
                return .none
                
            case .saveDocument:
                guard let image = state.capturedImage else {
                    return .none
                }
                
                state.isLoading = true
                return .run { [vehicleId = state.vehicleId] send in
                    await fileStorageService.saveDocument(image: image, for: vehicleId)
                    await send(.documentSaved)
                }
                
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