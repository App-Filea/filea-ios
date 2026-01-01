//
//  EditDocumentStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 16/09/2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct EditDocumentStore {
    @ObservableState
    struct State: Equatable {
        let vehicleId: String
        let documentId: String
        var originalDocument: Document
        var isLoading = false
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        
        // Editing fields
        var name: String
        var date: Date
        var mileage: String
        var type: DocumentType
        var amount: String

        init(vehicleId: String, document: Document) {
            self.vehicleId = vehicleId
            self.documentId = document.id
            self.originalDocument = document

            // Initialize editing fields with current values
            self.name = document.name
            self.date = document.date
            self.mileage = document.mileage
            self.type = document.type
            self.amount = document.amount.map { String($0) } ?? ""
        }
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case save
        case cancel
        case documentSaved
        case documentSaveFailed
    }
    
    @Dependency(\.documentRepository) var documentRepository
    @Dependency(\.vehicleRepository) var vehicleRepository
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .save:
                var updatedDocument = state.originalDocument
                updatedDocument.name = state.name
                updatedDocument.date = state.date
                updatedDocument.mileage = state.mileage
                updatedDocument.type = state.type
                updatedDocument.amount = Double(state.amount.replacingOccurrences(of: ",", with: "."))
                
                return .run { [vehicleId = state.vehicleId, document = updatedDocument] send in
                    do {
                        try await documentRepository.update(document, for: vehicleId)
                        await send(.documentSaved)
                    } catch {
                        print("❌ [EditDocumentStore] Erreur lors de la mise à jour: \(error.localizedDescription)")
                        await send(.documentSaveFailed)
                    }
                }
                
            case .cancel:
                return .run { _ in
                    await dismiss()
                }
                
            case .documentSaved:
                state.isLoading = false
                // Recharger le véhicule pour mettre à jour la liste des documents dans @Shared
                return .run { [vehicleId = state.vehicleId, vehicles = state.$vehicles, selectedVehicle = state.$selectedVehicle] send in
                    do {
                        if let updatedVehicle = try await vehicleRepository.getVehicle(vehicleId) {
                            await vehicles.withLock { vehicles in
                                if let index = vehicles.firstIndex(where: { $0.id == vehicleId }) {
                                    vehicles[index] = updatedVehicle
                                }
                            }
                            await selectedVehicle.withLock { $0 = updatedVehicle }
                        }
                    } catch {
                        print("❌ [EditDocumentStore] Erreur lors du rechargement du véhicule: \(error.localizedDescription)")
                    }
                    await dismiss()
                }
                
            case .documentSaveFailed:
                state.isLoading = false
                return .none
                
            default: return .none
            }
        }
    }
}
