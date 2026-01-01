////
////  VehicleMonthlyExpensesStore_Spec.swift
////  Invoicer
////
////  Created by Nicolas Barbosa on 19/11/2025.
////
//
//import ComposableArchitecture
//import XCTest
//@testable import Invoicer
//
//@MainActor
//class VehicleMonthlyExpensesStore_Spec: XCTestCase {
//    
//    func test_Calculates_Monthly_expenses_of_selected_vehicle() async {
//        givenStore(selectedVehicle: .make(), calculateMonthlyExpensesResponse: [.init(month: 0, amount: 20)])
//        
//        await store.send(.computeVehicleMontlyExpenses)
//        await store.receive(.vehicleMonthlyExpensesCalculated([.init(month: 0, amount: 20)])) {
//            $0.currentVehicleMonthlyExpenses = [.init(month: 0, amount: 20)]
//        }
//    }
//    
//    private func givenStore(selectedVehicle: Vehicle = .null(), calculateMonthlyExpensesResponse: [MonthlyExpense] = []) {
//        store = TestStore(initialState: VehicleMonthlyExpensesStore.State(selectedVehicle: Shared(value: selectedVehicle)),
//                          reducer: { VehicleMonthlyExpensesStore() },
//                          withDependencies: {
//            $0.statisticsRepository.calculateMonthlyExpenses = { _, _ in
//                return calculateMonthlyExpensesResponse
//            }
//        })
//    }
//    private var store: TestStoreOf<VehicleMonthlyExpensesStore>!
//}
//
