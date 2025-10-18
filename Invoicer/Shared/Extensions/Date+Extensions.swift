//
//  Date+Extensions.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Date formatting and manipulation extensions
//

import Foundation

extension Date {
    // MARK: - Formatting

    /// Formats the date as "dd/MM/yyyy"
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self)
    }

    /// Formats the date as "LLLL yyyy" (e.g., "Janvier 2025")
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: self).capitalized
    }

    /// Formats the date as "dd MMMM yyyy" (e.g., "16 Janvier 2025")
    var longDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: self).capitalized
    }

    /// Formats the date as "HH:mm"
    var timeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    /// Formats the date as "dd/MM/yyyy HH:mm"
    var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: self)
    }

    // MARK: - Relative Formatting

    /// Returns "Ce mois-ci" if the date is in the current month, otherwise returns "LLLL yyyy"
    var relativeMonthString: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDate(self, equalTo: now, toGranularity: .month),
           calendar.isDate(self, equalTo: now, toGranularity: .year) {
            return "Ce mois-ci"
        } else {
            return monthYearString
        }
    }

    // MARK: - Comparisons

    /// Checks if the date is in the same month and year as another date
    func isSameMonth(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: other, toGranularity: .month) &&
               calendar.isDate(self, equalTo: other, toGranularity: .year)
    }

    /// Checks if the date is in the same year as another date
    func isSameYear(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: other, toGranularity: .year)
    }

    /// Checks if the date is in the current month
    var isCurrentMonth: Bool {
        isSameMonth(as: Date())
    }

    /// Checks if the date is in the current year
    var isCurrentYear: Bool {
        isSameYear(as: Date())
    }

    // MARK: - Components

    /// Returns the month component (1-12)
    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    /// Returns the year component
    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    /// Returns the day component
    var day: Int {
        Calendar.current.component(.day, from: self)
    }

    /// Returns DateComponents for year and month
    var yearMonthComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month], from: self)
    }

    // MARK: - Manipulation

    /// Adds a number of months to the date
    func addingMonths(_ months: Int) -> Date? {
        Calendar.current.date(byAdding: .month, value: months, to: self)
    }

    /// Adds a number of days to the date
    func addingDays(_ days: Int) -> Date? {
        Calendar.current.date(byAdding: .day, value: days, to: self)
    }

    /// Returns the start of the day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns the start of the month
    var startOfMonth: Date? {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)
    }

    /// Returns the end of the month
    var endOfMonth: Date? {
        guard let start = startOfMonth else { return nil }
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: start)
    }
}

// MARK: - DateFormatter Helpers

extension DateFormatter {
    /// Returns a pre-configured DateFormatter for French locale with short date style
    static var frenchShortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .short
        return formatter
    }

    /// Returns a pre-configured DateFormatter for French locale with medium date style
    static var frenchMediumDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        return formatter
    }

    /// Returns a pre-configured DateFormatter for French locale with long date style
    static var frenchLongDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .long
        return formatter
    }
}
