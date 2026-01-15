//
//  VehicleDetailTabStore_Spec.swift
//  HolfyTests
//
//  Created by Claude Code on 15/01/2026.
//

import ComposableArchitecture
import XCTest
@testable import Invoicer

@MainActor
final class VehicleDetailTabStore_Spec: XCTestCase {

    func test_initialState_overviewTabSelected() {
        givenStore()
        thenSelectedTabShouldBe(.overview)
    }

    func test_tabSelected_changesSelectedTab() async {
        givenStore()
        await whenTabSelected(.statistics)
        thenSelectedTabShouldBe(.statistics)
    }

    func test_tabSelected_switchesBetweenMultipleTabs() async {
        givenStore()

        await whenTabSelected(.maintenance)
        thenSelectedTabShouldBe(.maintenance)

        await whenTabSelected(.fuel)
        thenSelectedTabShouldBe(.fuel)

        await whenTabSelected(.administration)
        thenSelectedTabShouldBe(.administration)

        await whenTabSelected(.overview)
        thenSelectedTabShouldBe(.overview)
    }

    func test_tabSelected_switchesToStatistics() async {
        givenStore()
        await whenTabSelected(.statistics)
        thenSelectedTabShouldBe(.statistics)
    }

    func test_tabSelected_switchesToAdministration() async {
        givenStore()
        await whenTabSelected(.administration)
        thenSelectedTabShouldBe(.administration)
    }

    // MARK: - Given

    private func givenStore(initialTab: VehicleDetailTabStore.Tab = .overview) {
        store = TestStore(
            initialState: VehicleDetailTabStore.State(selectedTab: initialTab),
            reducer: { VehicleDetailTabStore() }
        )
    }

    // MARK: - When

    private func whenTabSelected(_ tab: VehicleDetailTabStore.Tab) async {
        await store.send(.tabSelected(tab)) {
            $0.selectedTab = tab
        }
    }

    // MARK: - Then

    private func thenSelectedTabShouldBe(_ expectedTab: VehicleDetailTabStore.Tab) {
        XCTAssertEqual(
            store.state.selectedTab,
            expectedTab,
            "Selected tab should be \(expectedTab.rawValue)"
        )
    }

    // MARK: - Properties

    private var store: TestStore<VehicleDetailTabStore.State, VehicleDetailTabStore.Action>!
}
