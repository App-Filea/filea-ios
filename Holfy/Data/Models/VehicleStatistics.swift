//
//  VehicleStatistics.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 09/10/2025.
//
//  STATISTICS & ALERTS COMMENTED OUT - Code kept for future dashboard implementation
//  Uncomment this entire file to enable statistics and alerts features

import Foundation

// MARK: - Statistics Extensions (commented)
//extension Array where Element == Vehicle {
//    /// Calculate total expenses for all vehicles
//    func totalExpenses() -> Double {
//        return self.reduce(0) { total, vehicle in
//            total + vehicle.documents.totalExpenses()
//        }
//    }
//
//    /// Calculate expenses for current month for all vehicles
//    func monthlyExpenses() -> Double {
//        return self.reduce(0) { total, vehicle in
//            total + vehicle.documents.monthlyExpenses()
//        }
//    }
//
//    /// Get all alerts for all vehicles
//    func allAlerts() -> [VehicleAlert] {
//        return self.flatMap { vehicle in
//            vehicle.alerts()
//        }
//    }
//}
//
//extension Vehicle {
//    /// Calculate total expenses for this vehicle
//    func totalExpenses() -> Double {
//        return documents.totalExpenses()
//    }
//
//    /// Calculate expenses for current month
//    func monthlyExpenses() -> Double {
//        return documents.monthlyExpenses()
//    }
//
//    /// Get alerts for this vehicle
//    func alerts() -> [VehicleAlert] {
//        var alerts: [VehicleAlert] = []
//
//        // Check for contrôle technique (every 2 years from registration date)
//        let twoYears: TimeInterval = 2 * 365 * 24 * 60 * 60
//        let nextTechnicalControl = registrationDate.addingTimeInterval(twoYears)
//        let daysUntilControl = Calendar.current.dateComponents([.day], from: Date(), to: nextTechnicalControl).day ?? 0
//
//        if daysUntilControl <= 30 && daysUntilControl >= 0 {
//            alerts.append(VehicleAlert(
//                vehicleId: id,
//                vehicleName: "\(brand) \(model)",
//                type: .technicalControl,
//                daysRemaining: daysUntilControl,
//                message: "Contrôle technique dans \(daysUntilControl) jour(s)"
//            ))
//        }
//
//        // Check for révision (every 15,000 km)
//        if let currentMileage = Int(mileage) {
//            let nextRevisionMileage = ((currentMileage / 15000) + 1) * 15000
//            let kmUntilRevision = nextRevisionMileage - currentMileage
//
//            if kmUntilRevision <= 1000 {
//                alerts.append(VehicleAlert(
//                    vehicleId: id,
//                    vehicleName: "\(brand) \(model)",
//                    type: .revision,
//                    kmRemaining: kmUntilRevision,
//                    message: "Révision dans \(kmUntilRevision) km"
//                ))
//            }
//        }
//
//        return alerts
//    }
//}
//
//extension Array where Element == Document {
//    /// Calculate total expenses from documents with amount
//    func totalExpenses() -> Double {
//        return self.reduce(0) { total, document in
//            total + (document.amount ?? 0)
//        }
//    }
//
//    /// Calculate expenses for current month
//    func monthlyExpenses() -> Double {
//        let calendar = Calendar.current
//        let now = Date()
//
//        return self.filter { document in
//            calendar.isDate(document.date, equalTo: now, toGranularity: .month) &&
//            calendar.isDate(document.date, equalTo: now, toGranularity: .year)
//        }.reduce(0) { total, document in
//            total + (document.amount ?? 0)
//        }
//    }
//
//    /// Group expenses by category
//    func expensesByCategory() -> [DocumentCategory: Double] {
//        var expenses: [DocumentCategory: Double] = [:]
//
//        for document in self {
//            let category = document.type.category
//            expenses[category, default: 0] += (document.amount ?? 0)
//        }
//
//        return expenses
//    }
//}
//
//// MARK: - Alert Model (commented)
//struct VehicleAlert: Identifiable, Equatable {
//    let id = String()
//    let vehicleId: String
//    let vehicleName: String
//    let type: AlertType
//    var daysRemaining: Int?
//    var kmRemaining: Int?
//    let message: String
//
//    enum AlertType {
//        case technicalControl
//        case revision
//        case insurance
//    }
//}
