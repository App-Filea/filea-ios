//
//  MonthlyExpenseChart.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Reusable monthly expense chart component
//

import SwiftUI
import Charts
import ComposableArchitecture

struct MonthlyExpenseChart: View {
    let expenses: [MonthlyExpense]
    let year: Int
    var height: CGFloat = 120

    @Shared(.selectedCurrency) var currency: Currency

    private var currentMonth: Int {
        Calendar.current.component(.month, from: Date())
    }

    private var maxExpense: Double {
        max(expenses.map(\.amount).max() ?? 100, 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("chart_monthly_expenses")
                .secondarySubheadline()

            if expenses.isEmpty || expenses.allSatisfy({ $0.amount == 0 }) {
                emptyChart
            } else {
                populatedChart
            }

            Text(String(format: String(localized: "chart_monthly_expenses_year"), year))
                .caption()
        }
        .padding(Spacing.cardPadding)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(Radius.card)
    }

    private var emptyChart: some View {
        Chart {
            ForEach(1...12, id: \.self) { month in
                RectangleMark(
                    x: .value(String(localized: "chart_axis_month"), monthName(for: month)),
                    y: .value(String(localized: "chart_axis_amount"), 0),
                    height: 0.5
                )
                .foregroundStyle(Color.primary.tertiary)
            }
        }
        .frame(height: height)
        .chartYScale(domain: 0...100)
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    if let monthName = value.as(String.self) {
                        Text(String(monthName.prefix(3)))
                            .font(.caption2.weight(
                                monthName == self.monthName(for: currentMonth) ? .bold : .regular
                            ))
                            .foregroundStyle(
                                monthName == self.monthName(for: currentMonth) ?
                                Color.primary : Color.secondary
                            )
                    }
                }
            }
        }
        .chartYAxis(.hidden)
    }

    private var populatedChart: some View {
        Chart {
            ForEach(expenses) { expense in
                if expense.amount > 0 {
                    BarMark(
                        x: .value(String(localized: "chart_axis_month"), expense.monthName),
                        yStart: .value("Start", 0),
                        yEnd: .value(String(localized: "chart_axis_amount"), expense.amount)
                    )
                    .foregroundStyle(
                        expense.month == currentMonth ?
                        Color.accentColor : Color.accentColor.opacity(0.5)
                    )
                    .clipShape(Capsule())
                } else {
                    RectangleMark(
                        x: .value(String(localized: "chart_axis_month"), expense.monthName),
                        y: .value(String(localized: "chart_axis_amount"), 0),
                        height: 0.5
                    )
                    .foregroundStyle(Color.primary.tertiary)
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
                            .font(.caption2.weight(isCurrentMonth ? .bold : .regular))
                            .foregroundStyle(
                                isCurrentMonth ?
                                Color.primary : Color.secondary
                            )
                    }
                }
            }
        }
        .chartYAxis(.hidden)
    }

    private var accessibilityDescription: String {
        let totalExpenses = expenses.reduce(0) { $0 + $1.amount }
        let monthsWithExpenses = expenses.filter { $0.amount > 0 }.count

        if totalExpenses == 0 {
            return String(localized: "chart_no_expense_this_year")
        }

        return String(
            format: String(localized: "chart_total_expenses_months"),
            totalExpenses.asCurrencyStringNoDecimals(currency: currency),
            monthsWithExpenses
        )
    }

    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
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
            year: 2025
        )

        MonthlyExpenseChart(
            expenses: [],
            year: 2025
        )
    }
    .padding()
    .background(Color(.secondarySystemBackground))
}
