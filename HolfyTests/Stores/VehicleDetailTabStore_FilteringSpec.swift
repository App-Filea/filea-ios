//
//  VehicleDetailTabStore_FilteringSpec.swift
//  HolfyTests
//
//  Created by Claude Code on 15/01/2026.
//

import ComposableArchitecture
import XCTest
@testable import Invoicer

@MainActor
final class VehicleDetailTabStore_FilteringSpec: XCTestCase {

    func test_filteredDocuments_overviewTab_returnsAllDocuments() {
        givenState(selectedTab: .overview)
        givenDocuments([
            makeDocument(type: .maintenance),
            makeDocument(type: .repair),
            makeDocument(type: .other)
        ])
        whenFilteringDocuments()
        thenFilteredDocumentCountShouldBe(3)
    }

    func test_filteredDocuments_maintenanceTab_returnsMaintenanceRepairAndTechnicalInspection() {
        givenState(selectedTab: .maintenance)
        givenDocuments([
            makeDocument(type: .maintenance),
            makeDocument(type: .repair),
            makeDocument(type: .technicalInspection),
            makeDocument(type: .other)
        ])
        whenFilteringDocuments()
        thenFilteredDocumentCountShouldBe(3)
        thenAllFilteredDocumentsShouldBeMaintenanceOrRepairOrTechnicalInspection()
    }

    func test_filteredDocuments_statisticsTab_returnsNoDocuments() {
        givenState(selectedTab: .statistics)
        givenDocuments([
            makeDocument(type: .maintenance),
            makeDocument(type: .repair)
        ])
        whenFilteringDocuments()
        thenFilteredDocumentCountShouldBe(0)
    }

    func test_filteredDocuments_administrationTab_returnsNoDocuments() {
        givenState(selectedTab: .administration)
        givenDocuments([
            makeDocument(type: .maintenance),
            makeDocument(type: .other)
        ])
        whenFilteringDocuments()
        thenFilteredDocumentCountShouldBe(0)
    }

    func test_filteredDocuments_fuelTab_returnsNoDocuments() {
        givenState(selectedTab: .fuel)
        givenDocuments([
            makeDocument(type: .maintenance),
            makeDocument(type: .other)
        ])
        whenFilteringDocuments()
        thenFilteredDocumentCountShouldBe(0)
    }

    func test_filteredDocuments_sortedByDateDescending() {
        givenState(selectedTab: .overview)
        let oldDoc = makeDocument(date: Date(timeIntervalSince1970: 1000))
        let newDoc = makeDocument(date: Date(timeIntervalSince1970: 2000))
        givenDocuments([oldDoc, newDoc])
        whenFilteringDocuments()
        thenFirstDocumentShouldBe(newDoc)
    }

    func test_documentCount_overviewTab_countsAllDocuments() {
        givenState(selectedTab: .overview)
        givenDocuments([
            makeDocument(type: .maintenance),
            makeDocument(type: .repair),
            makeDocument(type: .other)
        ])
        whenCalculatingDocumentCount(for: .overview)
        thenDocumentCountShouldBe(3)
    }

    func test_documentCount_maintenanceTab_countsMaintenanceRepairAndTechnicalInspection() {
        givenState(selectedTab: .maintenance)
        givenDocuments([
            makeDocument(type: .maintenance),
            makeDocument(type: .repair),
            makeDocument(type: .technicalInspection),
            makeDocument(type: .other)
        ])
        whenCalculatingDocumentCount(for: .maintenance)
        thenDocumentCountShouldBe(3)
    }

    func test_documentCount_statisticsTab_returnsZero() {
        givenState(selectedTab: .statistics)
        givenDocuments([
            makeDocument(type: .maintenance)
        ])
        whenCalculatingDocumentCount(for: .statistics)
        thenDocumentCountShouldBe(0)
    }

    // MARK: - Given

    private func givenState(selectedTab: VehicleDetailTabStore.Tab) {
        state = VehicleDetailTabStore.State(selectedTab: selectedTab)
    }

    private func givenDocuments(_ docs: [Document]) {
        documents = docs
    }

    // MARK: - When

    private func whenFilteringDocuments() {
        filteredDocuments = state.filteredDocuments(from: documents)
    }

    private func whenCalculatingDocumentCount(for tab: VehicleDetailTabStore.Tab) {
        documentCount = state.documentCount(for: tab, from: documents)
    }

    // MARK: - Then

    private func thenFilteredDocumentCountShouldBe(_ expectedCount: Int) {
        XCTAssertEqual(
            filteredDocuments.count,
            expectedCount,
            "Filtered documents count should be \(expectedCount)"
        )
    }

    private func thenAllFilteredDocumentsShouldBeMaintenanceOrRepairOrTechnicalInspection() {
        let allMatch = filteredDocuments.allSatisfy {
            $0.type == .maintenance || $0.type == .repair || $0.type == .technicalInspection
        }
        XCTAssertTrue(
            allMatch,
            "All filtered documents should be maintenance, repair, or technicalInspection type"
        )
    }

    private func thenFirstDocumentShouldBe(_ expectedDoc: Document) {
        XCTAssertEqual(
            filteredDocuments.first?.id,
            expectedDoc.id,
            "First document should be the most recent one"
        )
    }

    private func thenDocumentCountShouldBe(_ expectedCount: Int) {
        XCTAssertEqual(
            documentCount,
            expectedCount,
            "Document count should be \(expectedCount)"
        )
    }

    // MARK: - Test Helpers

    private func makeDocument(
        id: String = UUID().uuidString,
        type: DocumentType = .maintenance,
        date: Date = Date()
    ) -> Document {
        Document(
            id: id,
            fileURL: "",
            name: "Test Document",
            date: date,
            mileage: "0",
            type: type
        )
    }

    // MARK: - Properties

    private var state: VehicleDetailTabStore.State!
    private var documents: [Document] = []
    private var filteredDocuments: [Document] = []
    private var documentCount: Int = 0
}
