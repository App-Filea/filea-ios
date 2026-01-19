//
//  EmptyStateContent_Spec.swift
//  HolfyTests
//
//  Created by Claude Code on 19/01/2026.
//

import XCTest
@testable import Invoicer

final class EmptyStateContent_Spec: XCTestCase {

    // MARK: - Overview Tab Tests

    func test_content_overviewTab_returnsCorrectContent() {
        givenTab(.overview)
        whenGettingContent()
        thenContentShouldNotBeNil()
        thenTitleShouldBe("Aucun Document")
        thenIconShouldBe("doc.text")
        thenExamplesShouldContain("Explorez les onglets pour découvrir où ranger vos documents")
        thenCTALabelShouldBe("Ajouter un Document")
    }

    // MARK: - Statistics Tab Tests

    func test_content_statisticsTab_returnsNil() {
        givenTab(.statistics)
        whenGettingContent()
        thenContentShouldBeNil()
    }

    // MARK: - Maintenance Tab Tests

    func test_content_maintenanceTab_returnsCorrectContent() {
        givenTab(.maintenance)
        whenGettingContent()
        thenContentShouldNotBeNil()
        thenTitleShouldBe("Aucun Document d'Entretien")
        thenIconShouldBe("wrench.and.screwdriver")
        thenExamplesShouldContain("Vidange moteur")
        thenCTALabelShouldBe("➕ Ajouter Votre Premier Entretien")
    }

    func test_content_maintenanceTab_containsAllExpectedExamples() {
        givenTab(.maintenance)
        whenGettingContent()
        thenExamplesShouldContain("Vidange moteur")
        thenExamplesShouldContain("Changement pneus")
        thenExamplesShouldContain("Révision annuelle")
        thenExamplesShouldContain("Remplacement freins")
        thenExamplesShouldContain("Entretien climatisation")
    }

    // MARK: - Administration Tab Tests

    func test_content_administrationTab_returnsCorrectContent() {
        givenTab(.administration)
        whenGettingContent()
        thenContentShouldNotBeNil()
        thenTitleShouldBe("Aucun Document Administratif")
        thenIconShouldBe("doc.text.fill")
        thenExamplesShouldContain("Carte grise")
        thenCTALabelShouldBe("➕ Ajouter Votre Premier Document Admin")
    }

    func test_content_administrationTab_containsAllExpectedExamples() {
        givenTab(.administration)
        whenGettingContent()
        thenExamplesShouldContain("Carte grise")
        thenExamplesShouldContain("Assurance auto")
        thenExamplesShouldContain("Contrôle technique")
        thenExamplesShouldContain("Certificat de cession")
    }

    // MARK: - Fuel Tab Tests

    func test_content_fuelTab_returnsCorrectContent() {
        givenTab(.fuel)
        whenGettingContent()
        thenContentShouldNotBeNil()
        thenTitleShouldBe("Aucun Plein d'Essence")
        thenIconShouldBe("fuelpump.fill")
        thenExamplesShouldContain("Pleins d'essence")
        thenCTALabelShouldBe("➕ Ajouter Votre Premier Plein")
    }

    func test_content_fuelTab_containsAllExpectedExamples() {
        givenTab(.fuel)
        whenGettingContent()
        thenExamplesShouldContain("Pleins d'essence")
        thenExamplesShouldContain("Recharges électriques")
        thenExamplesShouldContain("Recharges hybrides")
        thenExamplesShouldContain("Suivi de consommation")
    }

    // MARK: - Given

    private func givenTab(_ tab: VehicleDetailTabStore.Tab) {
        selectedTab = tab
    }

    // MARK: - When

    private func whenGettingContent() {
        content = EmptyStateContent.content(for: selectedTab)
    }

    // MARK: - Then

    private func thenContentShouldBeNil() {
        XCTAssertNil(content, "Content should be nil for tabs without empty states")
    }

    private func thenContentShouldNotBeNil() {
        XCTAssertNotNil(content, "Content should not be nil for \(selectedTab.rawValue) tab")
    }

    private func thenTitleShouldBe(_ expectedTitle: String) {
        XCTAssertEqual(content?.title, expectedTitle, "Title should match expected value")
    }

    private func thenIconShouldBe(_ expectedIcon: String) {
        XCTAssertEqual(content?.icon, expectedIcon, "Icon should match expected value")
    }

    private func thenExamplesShouldContain(_ expectedExample: String) {
        XCTAssertTrue(
            content?.examples.contains(expectedExample) ?? false,
            "Examples should contain '\(expectedExample)'"
        )
    }

    private func thenCTALabelShouldBe(_ expectedLabel: String) {
        XCTAssertEqual(content?.ctaLabel, expectedLabel, "CTA label should match expected value")
    }

    // MARK: - Properties

    private var selectedTab: VehicleDetailTabStore.Tab!
    private var content: EmptyStateContent?
}
