//
//  AddVehicleStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AddVehicleStore {
    @ObservableState
    struct State: Equatable {
        var vehicleType: VehicleType? = nil
        var brand: String = ""
        var model: String = ""
        var plate: String = ""
        var registrationDate: Date = .now
        var mileage: String = ""
        var isPrimary: Bool = false
        var isLoading = false
        var showValidationError = false
        @Shared(.vehicles) var vehicles: [Vehicle] = []
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case saveVehicle
        case vehicleSaved(Vehicle)
        case cancelCreation
        case setShowValidationError(Bool)
    }

    @Dependency(\.vehicleRepository) var vehicleRepository
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .saveVehicle:
                state.isLoading = true

                // Construire le Vehicle à partir des champs séparés
                let vehicle = Vehicle(
                    type: state.vehicleType ?? .car,
                    brand: state.brand,
                    model: state.model,
                    mileage: state.mileage.isEmpty ? nil : state.mileage,
                    registrationDate: state.registrationDate,
                    plate: state.plate,
                    isPrimary: state.isPrimary
                )

                return .run { send in
                    do {
                        // Créer le véhicule (système dual : JSON + GRDB)
                        try await vehicleRepository.createVehicle(vehicle)

                        // Si véhicule principal, mettre à jour tous les autres
                        if vehicle.isPrimary {
                            try await vehicleRepository.setPrimaryVehicle(vehicle.id)
                        }

                        await send(.vehicleSaved(vehicle))
                    } catch {
                        print("❌ [AddVehicleStore] Erreur lors de la sauvegarde: \(error.localizedDescription)")
                        // Continue anyway to update UI
                        await send(.vehicleSaved(vehicle))
                    }
                }

            case .vehicleSaved(let vehicle):
                state.isLoading = false
                // Ajouter le véhicule à la liste partagée pour mise à jour réactive
                state.$vehicles.withLock { $0.append(vehicle) }
                return .run { _ in
                    await dismiss()
                }

            case .cancelCreation:
                return .run { _ in
                    await dismiss()
                }

            case .setShowValidationError(let show):
                state.showValidationError = show
                return .none
            }
        }
    }
}