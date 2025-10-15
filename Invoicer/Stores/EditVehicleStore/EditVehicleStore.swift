//
//  EditVehicleStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct EditVehicleStore {
    @ObservableState
    struct State: Equatable {
        let originalVehicle: Vehicle
        var type: VehicleType
        var brand: String
        var model: String
        var mileage: String
        var registrationDate: Date
        var plate: String
        var isPrimary: Bool
        var isLoading = false
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle?
        var updatedVehicle: Vehicle?

        init(vehicle: Vehicle) {
            self.originalVehicle = vehicle
            self.type = vehicle.type
            self.brand = vehicle.brand
            self.model = vehicle.model
            self.mileage = vehicle.mileage ?? ""
            self.registrationDate = vehicle.registrationDate
            self.plate = vehicle.plate
            self.isPrimary = vehicle.isPrimary
        }

        // Computed property pour avoir le véhicule avec les changements actuels
        var vehicle: Vehicle {
            updatedVehicle ?? Vehicle(
                type: type,
                brand: brand,
                model: model,
                mileage: mileage.isEmpty ? nil : mileage,
                registrationDate: registrationDate,
                plate: plate,
                isPrimary: isPrimary,
                documents: originalVehicle.documents
            )
        }
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case updateVehicle
        case vehicleUpdated
        case goBack
    }
    
    @Dependency(\.fileStorageService) var fileStorageService
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .updateVehicle:
                state.isLoading = true

                // Si le véhicule devient principal, mettre tous les autres en secondaire
                if state.isPrimary && !state.originalVehicle.isPrimary {
                    state.$vehicles.withLock { vehicles in
                        for index in vehicles.indices {
                            if vehicles[index].id != state.originalVehicle.id {
                                vehicles[index].isPrimary = false
                            }
                        }
                    }
                }

                let updatedVehicle = Vehicle(
                    type: state.type,
                    brand: state.brand,
                    model: state.model,
                    mileage: state.mileage.isEmpty ? nil : state.mileage,
                    registrationDate: state.registrationDate,
                    plate: state.plate,
                    isPrimary: state.isPrimary,
                    documents: state.originalVehicle.documents
                )

                return .run { [vehicles = state.vehicles, originalVehicleId = state.originalVehicle.id] send in
                    // Sauvegarder tous les véhicules mis à jour
                    for existingVehicle in vehicles {
                        if existingVehicle.id != originalVehicleId {
                            await fileStorageService.updateVehicle(existingVehicle.id, with: existingVehicle)
                        }
                    }
                    // Mettre à jour le véhicule actuel
                    await fileStorageService.updateVehicle(originalVehicleId, with: updatedVehicle)
                    await send(.vehicleUpdated)
                }

            case .vehicleUpdated:
                state.isLoading = false
                // Créer le véhicule mis à jour et le stocker
                let updatedVehicle = Vehicle(
                    type: state.type,
                    brand: state.brand,
                    model: state.model,
                    mileage: state.mileage.isEmpty ? nil : state.mileage,
                    registrationDate: state.registrationDate,
                    plate: state.plate,
                    isPrimary: state.isPrimary,
                    documents: state.originalVehicle.documents
                )
                state.updatedVehicle = updatedVehicle

                // Mettre à jour la liste partagée
                state.$vehicles.withLock { vehicles in
                    if let index = vehicles.firstIndex(where: { $0.id == state.originalVehicle.id }) {
                        vehicles[index] = updatedVehicle
                    }
                }

                // CRUCIAL: Mettre à jour selectedVehicle directement
                state.$selectedVehicle.withLock { $0 = updatedVehicle }

                return .run { _ in
                    await dismiss()
                }
                
            case .goBack:
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}
