//
//  AddVehicleStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import ComposableArchitecture
import Foundation
import UIKit

@Reducer
struct AddVehicleStore {

    @ObservableState
    struct State: Equatable {
        var vehicleType: VehicleType? = nil
        var brand: String = ""
        var model: String = ""
        var plate: String = ""
        var registrationDate: Date
        var mileage: String = ""
        var isPrimary: Bool = false
        var isLoading = false
        var showValidationError = false
        var showDocumentSourcePicker: Bool = false
        var showImagePicker: Bool = false
        var showPrimaryAlert: Bool = false
        var showErrorAlert: Bool = false
        var errorMessage: String? = nil
        var pendingImage: UIImage? = nil
        @Shared(.vehicles) var vehicles: [Vehicle] = []
        @Presents var scanStore: DocumentScanStore.State?

        init(
            vehicleType: VehicleType? = nil,
            brand: String = "",
            model: String = "",
            plate: String = "",
            registrationDate: Date? = nil,
            mileage: String = "",
            isPrimary: Bool = false
        ) {
            @Dependency(\.date) var date

            self.vehicleType = vehicleType
            self.brand = brand
            self.model = model
            self.plate = plate
            self.registrationDate = registrationDate ?? date.now
            self.mileage = mileage
            self.isPrimary = isPrimary
            self._vehicles = Shared(.vehicles)
        }

        // MARK: - Computed Properties

        var existingPrimaryVehicle: Vehicle? {
            vehicles.first(where: { $0.isPrimary })
        }

        var isFormValid: Bool {
            !brand.isEmpty &&
            !model.isEmpty &&
            !plate.isEmpty
        }

        var shouldShowPrimaryWarning: Bool {
            isPrimary && existingPrimaryVehicle != nil
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case addButtonTapped
        case primaryWarningConfirmed
        case primaryWarningCancelled
        case imageSelected(UIImage?)
        case processImageForOCR(UIImage)
        case saveVehicle
        case updateVehiclesList([Vehicle])
        case vehicleSaved(Vehicle)
        case saveVehicleFailed(String)
        case dismissError
        case cancelCreation
        case setShowValidationError(Bool)
        case scanButtonTapped
        case selectDocumentSource(DocumentSource)
        case handleScanRetry(DocumentSource)
        case scanStore(PresentationAction<DocumentScanStore.Action>)
        case applyScanData(ScannedVehicleData)
    }

    @Dependency(\.vehicleRepository) var vehicleRepository
    @Dependency(\.uuid) var uuid
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .addButtonTapped:
                if state.shouldShowPrimaryWarning {
                    state.showPrimaryAlert = true
                    return .none
                }
                return .send(.saveVehicle)

            case .primaryWarningConfirmed:
                state.showPrimaryAlert = false
                return .send(.saveVehicle)

            case .primaryWarningCancelled:
                state.showPrimaryAlert = false
                return .none

            case .imageSelected(let image):
                state.showImagePicker = false
                state.pendingImage = nil

                guard let image else {
                    return .none
                }

                return .send(.processImageForOCR(image))

            case .processImageForOCR(let image):
                state.scanStore = DocumentScanStore.State(scanSource: .photoLibrary)
                return .run { send in
                    await send(.scanStore(.presented(.captureImage(image))))
                }

            case .scanButtonTapped:
                state.showDocumentSourcePicker = true
                return .none

            case .selectDocumentSource(let source):
                state.showDocumentSourcePicker = false

                switch source {
                case .camera:
                    state.scanStore = DocumentScanStore.State(scanSource: .camera)

                case .photoLibrary:
                    state.showImagePicker = true
                }

                return .none

            case .scanStore(.presented(.confirmData)):
                if let extractedData = state.scanStore?.extractedData {
                    return .send(.applyScanData(extractedData))
                }
                return .none

            case .scanStore(.presented(.requestRetry)):
                if let source = state.scanStore?.scanSource {
                    return .send(.handleScanRetry(source))
                }
                return .none

            case .handleScanRetry(let source):
                state.scanStore = nil
                switch source {
                case .photoLibrary:
                    state.showImagePicker = true
                case .camera:
                    state.scanStore = DocumentScanStore.State(scanSource: .camera)
                }
                return .none

            case .scanStore(.dismiss):
                return .none

            case .applyScanData(let data):
                if let brand = data.brand {
                    state.brand = brand
                }
                if let model = data.model {
                    state.model = model
                }
                if let plate = data.plate {
                    state.plate = plate
                }
                if let date = data.registrationDate {
                    state.registrationDate = date
                }
    
                return .none

            case .scanStore:
                return .none

            case .saveVehicle:
                state.isLoading = true

                let vehicle = Vehicle(
                    id: self.uuid(),
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
                        await send(.saveVehicleFailed(error.localizedDescription))
                    }
                }

            case .updateVehiclesList(let vehicles):
                state.isLoading = false
                state.$vehicles.withLock { sharedVehicles in
                    sharedVehicles = vehicles
                }
                return .run { _ in
                    await dismiss()
                }

            case \.vehicleSaved:
                state.isLoading = false
                // AppStore va gérer le rechargement, la fermeture et la navigation
                return .none

            case .saveVehicleFailed(let errorMessage):
                state.isLoading = false
                state.errorMessage = errorMessage
                state.showErrorAlert = true
                return .none

            case .dismissError:
                state.showErrorAlert = false
                state.errorMessage = nil
                return .none

            case .cancelCreation:
                return .run { _ in
                    await dismiss()
                }

            case .setShowValidationError(let show):
                state.showValidationError = show
                return .none
                
            case .vehicleSaved:
                return .none
            }
        }
        .ifLet(\.$scanStore, action: \.scanStore) {
            DocumentScanStore()
        }
    }
}
