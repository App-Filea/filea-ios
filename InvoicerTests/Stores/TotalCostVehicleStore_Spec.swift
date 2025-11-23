//
//  TotalCostVehicleStore.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 19/11/2025.
//

import ComposableArchitecture
import XCTest
@testable import Invoicer

@MainActor
class TotalCostVehicleStore_Spec: XCTestCase {
    
    func test_Calculate_vehicle_total_cost() async {
        givenStore(selectedVehicle: .make(), calculateTotalCostResponse: 100)
        
        await store.send(.computeVehicleTotalCost)
        await store.receive(.vehicleTotalCostCalculated(100)) {
            $0.currentVehicleTotalCost = 100
        }
    }
    
    private func givenStore(selectedVehicle: Vehicle? = nil, calculateTotalCostResponse: Double = 0.0) {
        store = TestStore(initialState: TotalCostVehicleStore.State(selectedVehicle: Shared(value: selectedVehicle)),
                          reducer: { TotalCostVehicleStore() },
                          withDependencies: {
            $0.statisticsRepository.calculateTotalCost = { _ in
                return calculateTotalCostResponse
            }
        })
    }
    private var store: TestStoreOf<TotalCostVehicleStore>!
}

