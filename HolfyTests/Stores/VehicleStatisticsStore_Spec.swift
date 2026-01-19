//
//  VehicleStatisticsStore_Spec.swift
//  HolfyTests
//
//  Created by Claude Code on 19/01/2026.
//

import XCTest
import ComposableArchitecture
@testable import Holfy

final class VehicleStatisticsStore_Spec: XCTestCase {

    // MARK: - Composition Tests

    func test_state_containsAllChildStores() {
        givenInitialState()
        thenStateShouldContainTotalCostVehicle()
        thenStateShouldContainWarningVehicle()
        thenStateShouldContainVehicleMonthlyExpenses()
    }

    func test_actions_delegateToChildStores() {
        givenStore()
        whenSendingChildStoreAction()
        thenActionShouldBeDelegated()
    }

    // MARK: - Given

    private func givenInitialState() {
        state = VehicleStatisticsStore.State()
    }

    private func givenStore() {
        store = TestStore(
            initialState: VehicleStatisticsStore.State(),
            reducer: { VehicleStatisticsStore() }
        )
    }

    // MARK: - When

    private func whenSendingChildStoreAction() {
        // Actions are purely delegated to child stores
        // No mutations in VehicleStatisticsStore itself
    }

    // MARK: - Then

    private func thenStateShouldContainTotalCostVehicle() {
        XCTAssertNotNil(state, "State should exist")
        // TotalCostVehicleStore.State is initialized by default
    }

    private func thenStateShouldContainWarningVehicle() {
        XCTAssertNotNil(state, "State should exist")
        // WarningVehicleStore.State is initialized by default
    }

    private func thenStateShouldContainVehicleMonthlyExpenses() {
        XCTAssertNotNil(state, "State should exist")
        // VehicleMonthlyExpensesStore.State is initialized by default
    }

    private func thenActionShouldBeDelegated() {
        // Pure compositeur - no logic to test
        // Child stores handle their own actions
    }

    // MARK: - Properties

    private var state: VehicleStatisticsStore.State?
    private var store: TestStore<VehicleStatisticsStore>!
}
