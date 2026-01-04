////
////  WarningVehicleStore_Spec.swift
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
//class WarningVehicleStore_Spec: XCTestCase {
//    
//    func test_Updates_alert_count_with_returned_statistics() async {
//        givenStore(selectedVehicle: .make(), countIncompleteDocumentsResponse: 5)
//        
//        await store.send(.computeVehicleWarnings)
//        await store.receive(.computedWarnings(5)) {
//            $0.currentVehicleIncompleteDocumentsCount = 5
//        }
//    }
//    
//    private func givenStore(selectedVehicle: Vehicle = .null(), countIncompleteDocumentsResponse: Int = 0) {
//        store = TestStore(initialState: WarningVehicleStore.State(selectedVehicle: Shared(value: selectedVehicle)),
//                          reducer: { WarningVehicleStore() },
//                          withDependencies: {
//            $0.statisticsRepository.countIncompleteDocuments = { _ in
//                return countIncompleteDocumentsResponse
//            }
//        })
//    }
//    private var store: TestStoreOf<WarningVehicleStore>!
//}
//
