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
        let vehicleId: UUID
        let documentId: UUID
        var originalDocument: Document
        var isLoading = false
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        
        // Editing fields
        var name: String
        var date: Date
        var mileage: String
        var type: DocumentType
        var amount: String

        init(vehicleId: UUID, document: Document) {
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

        var hasChanges: Bool {
            let amountDouble = Double(amount.replacingOccurrences(of: ",", with: "."))
            return name != originalDocument.name ||
                   date != originalDocument.date ||
                   mileage != originalDocument.mileage ||
                   type != originalDocument.type ||
                   amountDouble != originalDocument.amount
        }
        
        var canSave: Bool {
            return !name.isEmpty && hasChanges && !isLoading
        }
    }
    
    enum Action: Equatable {
        case updateName(String)
        case updateDate(Date)
        case updateMileage(String)
        case updateType(DocumentType)
        case updateAmount(String)
        case save
        case cancel
        case documentSaved
        case documentSaveFailed
    }
    
    @Dependency(\.documentRepository) var documentRepository
    @Dependency(\.vehicleRepository) var vehicleRepository
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .updateName(let name):
                state.name = name
                return .none
                
            case .updateDate(let date):
                state.date = date
                return .none
                
            case .updateMileage(let mileage):
                state.mileage = mileage
                return .none
                
            case .updateType(let type):
                state.type = type
                return .none

            case .updateAmount(let amount):
                state.amount = amount
                return .none

            case .save:
                guard state.canSave else { return .none }

                state.isLoading = true

                // Create updated document
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
                return .run { [vehicleId = state.vehicleId, vehicles = state.$vehicles] send in
                    do {
                        if let updatedVehicle = try await vehicleRepository.find(by: vehicleId) {
                            await vehicles.withLock { vehicles in
                                if let index = vehicles.firstIndex(where: { $0.id == vehicleId }) {
                                    vehicles[index] = updatedVehicle
                                }
                            }
                        }
                    } catch {
                        print("❌ [EditDocumentStore] Erreur lors du rechargement du véhicule: \(error.localizedDescription)")
                    }
                    await dismiss()
                }
                
            case .documentSaveFailed:
                state.isLoading = false
                return .none
            }
        }
    }
}