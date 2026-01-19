//
//  VehicleDetailTabStore_QuickActionsSpec.swift
//  HolfyTests
//
//  Created by Claude Code on 15/01/2026.
//

import ComposableArchitecture
import XCTest
@testable import Invoicer

@MainActor
final class VehicleDetailTabStore_QuickActionsSpec: XCTestCase {

    // MARK: - Quick Action Label Tests

    func test_quickActionLabel_overviewTab_returnsNil() {
        givenState(selectedTab: .overview)
        whenGettingQuickActionLabel()
        thenQuickActionLabelShouldBeNil()
    }

    func test_quickActionLabel_statisticsTab_returnsNil() {
        givenState(selectedTab: .statistics)
        whenGettingQuickActionLabel()
        thenQuickActionLabelShouldBeNil()
    }

    func test_quickActionLabel_maintenanceTab_returnsCorrectLabel() {
        givenState(selectedTab: .maintenance)
        whenGettingQuickActionLabel()
        thenQuickActionLabelShouldBe("➕ Ajouter Entretien")
    }

    func test_quickActionLabel_administrationTab_returnsCorrectLabel() {
        givenState(selectedTab: .administration)
        whenGettingQuickActionLabel()
        thenQuickActionLabelShouldBe("➕ Ajouter Document Admin")
    }

    func test_quickActionLabel_fuelTab_returnsCorrectLabel() {
        givenState(selectedTab: .fuel)
        whenGettingQuickActionLabel()
        thenQuickActionLabelShouldBe("➕ Ajouter Plein")
    }

    // MARK: - Pre-Selected Document Type Tests

    func test_preSelectedDocumentType_overviewTab_returnsNil() {
        givenState(selectedTab: .overview)
        whenGettingPreSelectedDocumentType()
        thenPreSelectedDocumentTypeShouldBeNil()
    }

    func test_preSelectedDocumentType_statisticsTab_returnsNil() {
        givenState(selectedTab: .statistics)
        whenGettingPreSelectedDocumentType()
        thenPreSelectedDocumentTypeShouldBeNil()
    }

    func test_preSelectedDocumentType_maintenanceTab_returnsMaintenance() {
        givenState(selectedTab: .maintenance)
        whenGettingPreSelectedDocumentType()
        thenPreSelectedDocumentTypeShouldBe(.maintenance)
    }

    func test_preSelectedDocumentType_administrationTab_returnsNil() {
        givenState(selectedTab: .administration)
        whenGettingPreSelectedDocumentType()
        thenPreSelectedDocumentTypeShouldBeNil()
    }

    func test_preSelectedDocumentType_fuelTab_returnsNil() {
        givenState(selectedTab: .fuel)
        whenGettingPreSelectedDocumentType()
        thenPreSelectedDocumentTypeShouldBeNil()
    }

    // MARK: - Shows Quick Action Tests

    func test_showsQuickAction_overviewTab_returnsFalse() {
        givenState(selectedTab: .overview)
        whenGettingShowsQuickAction()
        thenShowsQuickActionShouldBe(false)
    }

    func test_showsQuickAction_statisticsTab_returnsFalse() {
        givenState(selectedTab: .statistics)
        whenGettingShowsQuickAction()
        thenShowsQuickActionShouldBe(false)
    }

    func test_showsQuickAction_maintenanceTab_returnsTrue() {
        givenState(selectedTab: .maintenance)
        whenGettingShowsQuickAction()
        thenShowsQuickActionShouldBe(true)
    }

    func test_showsQuickAction_administrationTab_returnsTrue() {
        givenState(selectedTab: .administration)
        whenGettingShowsQuickAction()
        thenShowsQuickActionShouldBe(true)
    }

    func test_showsQuickAction_fuelTab_returnsTrue() {
        givenState(selectedTab: .fuel)
        whenGettingShowsQuickAction()
        thenShowsQuickActionShouldBe(true)
    }

    // MARK: - Given

    private func givenState(selectedTab: VehicleDetailTabStore.Tab) {
        state = VehicleDetailTabStore.State(selectedTab: selectedTab)
    }

    // MARK: - When

    private func whenGettingQuickActionLabel() {
        quickActionLabel = state.quickActionLabel
    }

    private func whenGettingPreSelectedDocumentType() {
        preSelectedDocumentType = state.preSelectedDocumentType
    }

    private func whenGettingShowsQuickAction() {
        showsQuickAction = state.showsQuickAction
    }

    // MARK: - Then

    private func thenQuickActionLabelShouldBeNil() {
        XCTAssertNil(quickActionLabel, "Quick action label should be nil for read-only tabs")
    }

    private func thenQuickActionLabelShouldBe(_ expected: String) {
        XCTAssertEqual(quickActionLabel, expected, "Quick action label should match expected value")
    }

    private func thenPreSelectedDocumentTypeShouldBeNil() {
        XCTAssertNil(preSelectedDocumentType, "Pre-selected document type should be nil for non-supported tabs")
    }

    private func thenPreSelectedDocumentTypeShouldBe(_ expected: DocumentType) {
        XCTAssertEqual(preSelectedDocumentType, expected, "Pre-selected document type should match expected value")
    }

    private func thenShowsQuickActionShouldBe(_ expected: Bool) {
        XCTAssertEqual(showsQuickAction, expected, "Shows quick action should be \(expected)")
    }

    // MARK: - Properties

    private var state: VehicleDetailTabStore.State!
    private var quickActionLabel: String?
    private var preSelectedDocumentType: DocumentType?
    private var showsQuickAction: Bool = false
}
