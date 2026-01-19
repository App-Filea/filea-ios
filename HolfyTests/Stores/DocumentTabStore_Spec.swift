//
//  DocumentTabStore_Spec.swift
//  HolfyTests
//
//  Created by Claude Code on 19/01/2026.
//

import XCTest
import ComposableArchitecture
@testable import Holfy

final class DocumentTabStore_Spec: XCTestCase {

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        store = nil
        try await super.tearDown()
    }

    // MARK: - Filtering Tests

    func test_filteredDocuments_maintenanceTab_returnsMaintenanceDocuments() {
        givenMaintenanceTab()
        givenVehicleWithDocuments()
        whenGettingFilteredDocuments()
        thenShouldContainOnlyMaintenanceDocuments()
    }

    func test_filteredDocuments_administrationTab_returnsEmptyArray() {
        givenAdministrationTab()
        givenVehicleWithDocuments()
        whenGettingFilteredDocuments()
        thenShouldBeEmpty()
    }

    func test_filteredDocuments_fuelTab_returnsEmptyArray() {
        givenFuelTab()
        givenVehicleWithDocuments()
        whenGettingFilteredDocuments()
        thenShouldBeEmpty()
    }

    // MARK: - Action Tests

    func test_documentTapped_doesNotMutateState() async {
        givenStoreWithMaintenanceTab()
        await whenSendingDocumentTappedAction()
        await thenNoStateMutation()
    }

    func test_addDocumentTapped_doesNotMutateState() async {
        givenStoreWithMaintenanceTab()
        await whenSendingAddDocumentTappedAction()
        await thenNoStateMutation()
    }

    // MARK: - Given

    private func givenMaintenanceTab() {
        selectedTab = .maintenance
    }

    private func givenAdministrationTab() {
        selectedTab = .administration
    }

    private func givenFuelTab() {
        selectedTab = .fuel
    }

    private func givenVehicleWithDocuments() {
        @Shared(.selectedVehicle) var vehicle = Vehicle(
            id: UUID().uuidString,
            brand: "Tesla",
            model: "Model 3",
            mileage: "50000",
            registrationDate: .now,
            plate: "ABC-123",
            documents: [
                Document(fileURL: "", name: "Vidange", date: .now, mileage: "50000", type: .maintenance),
                Document(fileURL: "", name: "CT", date: .now, mileage: "50000", type: .technicalInspection),
                Document(fileURL: "", name: "Réparation", date: .now, mileage: "50000", type: .repair),
                Document(fileURL: "", name: "Autre", date: .now, mileage: "50000", type: .other)
            ]
        )
    }

    private func givenStoreWithMaintenanceTab() {
        store = TestStore(
            initialState: DocumentTabStore.State(tab: .maintenance),
            reducer: { DocumentTabStore() }
        )
    }

    // MARK: - When

    private func whenGettingFilteredDocuments() {
        let state = DocumentTabStore.State(tab: selectedTab)
        filteredDocuments = state.filteredDocuments
    }

    private func whenSendingDocumentTappedAction() async {
        let document = Document(fileURL: "", name: "Test", date: .now, mileage: "0", type: .maintenance)
        await store.send(.documentTapped(document))
    }

    private func whenSendingAddDocumentTappedAction() async {
        await store.send(.addDocumentTapped)
    }

    // MARK: - Then

    private func thenShouldContainOnlyMaintenanceDocuments() {
        // Maintenance tab should contain: maintenance, repair, technicalInspection
        XCTAssertEqual(filteredDocuments.count, 3, "Should filter 3 maintenance-related documents")
        XCTAssertTrue(
            filteredDocuments.allSatisfy { $0.type == .maintenance || $0.type == .repair || $0.type == .technicalInspection },
            "All documents should be maintenance-related types"
        )
    }

    private func thenShouldBeEmpty() {
        XCTAssertTrue(filteredDocuments.isEmpty, "Administration and Fuel tabs should return empty array (placeholder)")
    }

    private func thenNoStateMutation() async {
        // Actions are delegated to parent, no state mutation in DocumentTabStore
    }

    // MARK: - Properties

    private var store: TestStore<DocumentTabStore>!
    private var selectedTab: VehicleDetailTabStore.Tab = .maintenance
    private var filteredDocuments: [Document] = []
}
