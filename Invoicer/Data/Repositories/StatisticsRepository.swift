//
//  StatisticsRepository.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Repository for calculating vehicle statistics and costs
//

import Foundation
import Dependencies
import os.log

// MARK: - Protocol

protocol StatisticsRepositoryProtocol: Sendable {
    func calculateTotalCost(for documents: [Document]) -> Double
    func calculateMonthlyExpenses(for documents: [Document], year: Int) -> [MonthlyExpense]
    func calculateYearlyTotal(for documents: [Document], year: Int) -> Double
    func calculateAverageMonthlyCost(for documents: [Document], year: Int) -> Double
    func groupDocumentsByCategory(for documents: [Document]) -> [StatisticsDocumentCategory: [Document]]
    func calculateCategoryTotals(for documents: [Document]) -> [StatisticsDocumentCategory: Double]
}

// MARK: - Dependency Registration

extension DependencyValues {
    var statisticsRepository: StatisticsRepositoryProtocol {
        get { self[StatisticsRepositoryKey.self] }
        set { self[StatisticsRepositoryKey.self] = newValue }
    }
}

private enum StatisticsRepositoryKey: DependencyKey {
    static let liveValue: StatisticsRepositoryProtocol = StatisticsRepository()
}

// MARK: - Statistics Document Category

enum StatisticsDocumentCategory: String, CaseIterable, Sendable {
    case administrative = "Administratif"
    case maintenance = "Entretien"
    case repair = "Réparation"
    case fuel = "Carburant"
    case other = "Autres"

    var displayName: String {
        rawValue
    }

    var symbolName: String {
        switch self {
        case .administrative: return "doc.text"
        case .maintenance: return "wrench.and.screwdriver"
        case .repair: return "exclamationmark.triangle"
        case .fuel: return "fuelpump"
        case .other: return "folder"
        }
    }
}

// MARK: - Implementation

final class StatisticsRepository: StatisticsRepositoryProtocol, @unchecked Sendable {
    private let logger = Logger(subsystem: AppConstants.bundleIdentifier, category: "StatisticsRepository")

    @Dependency(\.vehicleCostCalculator) var costCalculator

    // MARK: - Cost Calculations

    func calculateTotalCost(for documents: [Document]) -> Double {
        logger.info("📊 Calcul du coût total pour \(documents.count) documents")

        let total = costCalculator.calculateTotalCost(documents)

        logger.info("💰 Coût total: \(total) €")
        return total
    }

    func calculateMonthlyExpenses(for documents: [Document], year: Int) -> [MonthlyExpense] {
        logger.info("📊 Calcul des dépenses mensuelles pour l'année \(year)")

        let expenses = costCalculator.calculateMonthlyExpenses(documents, for: year)

        logger.info("📈 \(expenses.filter { $0.amount > 0 }.count) mois avec des dépenses")
        return expenses
    }

    func calculateYearlyTotal(for documents: [Document], year: Int) -> Double {
        logger.info("📊 Calcul du total annuel pour \(year)")

        let calendar = Calendar.current
        let documentsInYear = documents.filter { document in
            calendar.component(.year, from: document.date) == year
        }

        return calculateTotalCost(for: documentsInYear)
    }

    func calculateAverageMonthlyCost(for documents: [Document], year: Int) -> Double {
        logger.info("📊 Calcul de la moyenne mensuelle pour \(year)")

        let yearlyTotal = calculateYearlyTotal(for: documents, year: year)
        let monthsWithExpenses = calculateMonthlyExpenses(for: documents, year: year)
            .filter { $0.amount > 0 }
            .count

        guard monthsWithExpenses > 0 else {
            return 0
        }

        let average = yearlyTotal / Double(monthsWithExpenses)
        logger.info("📈 Moyenne mensuelle: \(average) €")
        return average
    }

    // MARK: - Category Analysis

    func groupDocumentsByCategory(for documents: [Document]) -> [StatisticsDocumentCategory: [Document]] {
        logger.info("📊 Regroupement par catégorie de \(documents.count) documents")

        let grouped = Dictionary(grouping: documents) { document in
            mapToStatisticsCategory(document.type.category)
        }

        logger.info("📂 \(grouped.keys.count) catégories trouvées")
        return grouped
    }

    func calculateCategoryTotals(for documents: [Document]) -> [StatisticsDocumentCategory: Double] {
        logger.info("📊 Calcul des totaux par catégorie")

        let grouped = groupDocumentsByCategory(for: documents)

        let totals = grouped.mapValues { docs in
            calculateTotalCost(for: docs)
        }

        logger.info("💰 Totaux calculés pour \(totals.keys.count) catégories")
        return totals
    }

    // MARK: - Private Helpers

    private func mapToStatisticsCategory(_ category: DocumentCategory) -> StatisticsDocumentCategory {
        switch category {
        case .administratif:
            return .administrative
        case .entretien:
            return .maintenance
        case .reparation:
            return .repair
        case .carburant:
            return .fuel
        case .autres:
            return .other
        }
    }
}
