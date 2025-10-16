//
//  VehicleCostCalculator.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import Foundation
import Dependencies

struct MonthlyExpense: Identifiable, Equatable, Sendable {
    let id: Int
    let month: Int
    let monthName: String
    let amount: Double

    init(month: Int, amount: Double) {
        self.id = month
        self.month = month
        self.amount = amount

        // Get month name in French
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "MMM"

        var components = DateComponents()
        components.month = month
        if let date = Calendar.current.date(from: components) {
            self.monthName = formatter.string(from: date).capitalized
        } else {
            self.monthName = ""
        }
    }
}

extension DependencyValues {
    var vehicleCostCalculator: VehicleCostCalculatorProtocol {
        get { self[VehicleCostCalculatorKey.self] }
        set { self[VehicleCostCalculatorKey.self] = newValue }
    }
}

private enum VehicleCostCalculatorKey: DependencyKey {
    static let liveValue: VehicleCostCalculatorProtocol = VehicleCostCalculator()

    static let testValue: VehicleCostCalculatorProtocol = VehicleCostCalculator()
}

protocol VehicleCostCalculatorProtocol: Sendable {
    func calculateTotalCost(_ documents: [Document]) -> Double
    func calculateMonthlyExpenses(_ documents: [Document], for year: Int) -> [MonthlyExpense]
}

struct VehicleCostCalculator: VehicleCostCalculatorProtocol {
    func calculateTotalCost(_ documents: [Document]) -> Double {
        documents
            .compactMap { $0.amount }
            .reduce(0, +)
    }

    func calculateMonthlyExpenses(_ documents: [Document], for year: Int) -> [MonthlyExpense] {
        let calendar = Calendar.current

        // Filter documents for the specified year
        let documentsForYear = documents.filter { document in
            let documentYear = calendar.component(.year, from: document.date)
            return documentYear == year
        }

        // Group documents by month
        var monthlyAmounts: [Int: Double] = [:]

        for document in documentsForYear {
            guard let amount = document.amount else { continue }
            let month = calendar.component(.month, from: document.date)
            monthlyAmounts[month, default: 0] += amount
        }

        // Create an array of 12 MonthlyExpense objects (one for each month)
        return (1...12).map { month in
            MonthlyExpense(month: month, amount: monthlyAmounts[month] ?? 0)
        }
    }
}
