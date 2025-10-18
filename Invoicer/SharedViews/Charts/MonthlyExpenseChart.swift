//
//  MonthlyExpenseChart.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Reusable monthly expense chart component
//

import SwiftUI
import Charts

/// Reusable monthly expense chart component
struct MonthlyExpenseChart: View {
    let expenses: [MonthlyExpense]
    let year: Int
    var accentColor: Color = ColorTokens.actionPrimary
    var height: CGFloat = 120

    private var currentMonth: Int {
        Calendar.current.component(.month, from: Date())
    }

    private var maxExpense: Double {
        max(expenses.map(\.amount).max() ?? 100, 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Title
            Text("Dépenses mensuelles")
                .font(Typography.headline)
                .foregroundStyle(ColorTokens.textPrimary)

            // Chart
            if expenses.isEmpty || expenses.allSatisfy({ $0.amount == 0 }) {
                emptyChart
            } else {
                populatedChart
            }

            // Subtitle
            Text("Dépenses mensuelles sur l'année \(year)")
                .font(Typography.caption1)
                .foregroundStyle(ColorTokens.textSecondary)
        }
        .padding(Spacing.cardPadding)
        .background(ColorTokens.surface)
        .cornerRadius(Radius.card)
    }

    private var emptyChart: some View {
        Chart {
            ForEach(1...12, id: \.self) { month in
                RectangleMark(
                    x: .value("Mois", monthName(for: month)),
                    y: .value("Montant", 0),
                    height: 0.5
                )
                .foregroundStyle(ColorTokens.textTertiary.opacity(0.3))
            }
        }
        .frame(height: height)
        .chartYScale(domain: 0...100)
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    if let monthName = value.as(String.self) {
                        Text(String(monthName.prefix(3)))
                            .font(Typography.caption2.weight(
                                monthName == self.monthName(for: currentMonth) ? .bold : .regular
                            ))
                            .foregroundStyle(
                                monthName == self.monthName(for: currentMonth) ?
                                ColorTokens.textPrimary : ColorTokens.textSecondary
                            )
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .accessibilityLabel("Graphique des dépenses mensuelles")
        .accessibilityValue("Aucune dépense enregistrée cette année")
    }

    private var populatedChart: some View {
        Chart {
            ForEach(expenses) { expense in
                if expense.amount > 0 {
                    BarMark(
                        x: .value("Mois", expense.monthName),
                        yStart: .value("Start", 0),
                        yEnd: .value("Montant", expense.amount)
                    )
                    .foregroundStyle(
                        expense.month == currentMonth ?
                        accentColor : accentColor.opacity(0.5)
                    )
                    .clipShape(Capsule())
                } else {
                    RectangleMark(
                        x: .value("Mois", expense.monthName),
                        y: .value("Montant", 0),
                        height: 0.5
                    )
                    .foregroundStyle(ColorTokens.textTertiary.opacity(0.3))
                }
            }
        }
        .frame(height: height)
        .chartYScale(domain: 0...maxExpense)
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    if let monthName = value.as(String.self) {
                        let isCurrentMonth = expenses.first(where: { $0.monthName == monthName })?.month == currentMonth
                        Text(String(monthName.prefix(3)))
                            .font(Typography.caption2.weight(isCurrentMonth ? .bold : .regular))
                            .foregroundStyle(
                                isCurrentMonth ?
                                ColorTokens.textPrimary : ColorTokens.textSecondary
                            )
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .accessibilityLabel("Graphique des dépenses mensuelles")
        .accessibilityValue(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        let totalExpenses = expenses.reduce(0) { $0 + $1.amount }
        let monthsWithExpenses = expenses.filter { $0.amount > 0 }.count

        if totalExpenses == 0 {
            return "Aucune dépense enregistrée cette année"
        }

        return "Total de \(CurrencyFormatter.shared.formatValue(totalExpenses, includeDecimals: false)) euros sur \(monthsWithExpenses) mois"
    }

    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "MMM"

        var components = DateComponents()
        components.month = month
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date).capitalized
        }
        return ""
    }
}

#Preview {
    VStack(spacing: Spacing.lg) {
        // With data
        MonthlyExpenseChart(
            expenses: [
                MonthlyExpense(month: 1, amount: 540),
                MonthlyExpense(month: 2, amount: 0),
                MonthlyExpense(month: 3, amount: 80),
                MonthlyExpense(month: 4, amount: 0),
                MonthlyExpense(month: 5, amount: 350),
                MonthlyExpense(month: 6, amount: 0),
                MonthlyExpense(month: 7, amount: 180),
                MonthlyExpense(month: 8, amount: 95),
                MonthlyExpense(month: 9, amount: 0),
                MonthlyExpense(month: 10, amount: 400),
                MonthlyExpense(month: 11, amount: 0),
                MonthlyExpense(month: 12, amount: 0)
            ],
            year: 2025,
            accentColor: .purple
        )

        // Empty state
        MonthlyExpenseChart(
            expenses: [],
            year: 2025
        )
    }
    .padding()
    .background(Color(.secondarySystemBackground))
}
