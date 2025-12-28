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

struct StatisticsRepositoryClient: Sendable {
    var calculateTotalCost: @Sendable ([Document]) -> Double
    var calculateMonthlyExpenses: @Sendable ([Document], _ year: Int) -> [MonthlyExpense]
    var calculateYearlyTotal: @Sendable ([Document], _ year: Int) -> Double
    var calculateAverageMonthlyCost: @Sendable ([Document], _ year: Int) -> Double
    var countIncompleteDocuments: @Sendable ([Document]) -> Int
    var groupDocumentsByCategory: @Sendable ([Document]) -> [StatisticsDocumentCategory: [Document]]
    var calculateCategoryTotals: @Sendable ([Document]) -> [StatisticsDocumentCategory: Double]
}

extension StatisticsRepositoryClient: DependencyKey {
    static var liveValue: StatisticsRepositoryClient {
        let statisticRepository = DefaultStatisticsRepository()
        return StatisticsRepositoryClient(calculateTotalCost: {
            statisticRepository.calculateTotalCost(for: $0)
        }, calculateMonthlyExpenses: {
            statisticRepository.calculateMonthlyExpenses(for: $0, year: $1)
        }, calculateYearlyTotal: {
            statisticRepository.calculateYearlyTotal(for: $0, year: $1)
        }, calculateAverageMonthlyCost: {
            statisticRepository.calculateAverageMonthlyCost(for: $0, year: $1)
        }, countIncompleteDocuments: {
            statisticRepository.countIncompleteDocuments(for: $0)
        }, groupDocumentsByCategory: {
            statisticRepository.groupDocumentsByCategory(for: $0)
        }, calculateCategoryTotals: {
            statisticRepository.calculateCategoryTotals(for: $0)
        })
    }
    
    static var testValue: StatisticsRepositoryClient {
        return StatisticsRepositoryClient(calculateTotalCost: { _ in 0.0 },
                                          calculateMonthlyExpenses: { _, _ in [] },
                                          calculateYearlyTotal: { _, _ in 0.0 },
                                          calculateAverageMonthlyCost: { _, _ in 0.0 },
                                          countIncompleteDocuments: { _ in 0},
                                          groupDocumentsByCategory: { _ in [:] },
                                          calculateCategoryTotals: { _ in [:]})
    }
}

extension DependencyValues {
    var statisticsRepository: StatisticsRepositoryClient {
        get { self[StatisticsRepositoryClient.self] }
        set { self[StatisticsRepositoryClient.self] = newValue }
    }
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

final class DefaultStatisticsRepository: @unchecked Sendable {
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
    
    func countIncompleteDocuments(for documents: [Document]) -> Int {
        logger.info("📊 Comptage des documents incomplets")
        
        let count = documents.filter { $0.amount == nil }.count
        
        logger.info("⚠️ \(count) documents incomplets trouvés")
        return count
    }
    
    // MARK: - Category Analysis
    
    func groupDocumentsByCategory(for documents: [Document]) -> [StatisticsDocumentCategory: [Document]] {
        logger.info("📊 Regroupement par catégorie de \(documents.count) documents")
        
        let grouped = Dictionary(grouping: documents) { document in
            mapToStatisticsCategory(document.type)
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
    
    private func mapToStatisticsCategory(_ type: DocumentType) -> StatisticsDocumentCategory {
        switch type {
        case .technicalInspection:
            return .administrative
        case .maintenance:
            return .maintenance
        case .repair:
            return .repair
        case .other:
            return .other
        }
    }
}
