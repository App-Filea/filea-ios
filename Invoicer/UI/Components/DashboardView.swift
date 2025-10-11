//
//  DashboardView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 09/10/2025.
//
//  DASHBOARD COMMENTED OUT - Code kept for future implementation
//  Uncomment this entire file to enable the dashboard feature

import SwiftUI

// MARK: - Dashboard View (commented)
//struct DashboardView: View {
//    let vehicles: [Vehicle]
//
//    private var totalExpenses: Double {
//        vehicles.totalExpenses()
//    }
//
//    private var monthlyExpenses: Double {
//        vehicles.monthlyExpenses()
//    }
//
//    private var alerts: [VehicleAlert] {
//        vehicles.allAlerts()
//    }
//
//    private var vehicleCount: Int {
//        vehicles.count
//    }
//
//    var body: some View {
//        VStack(spacing: 16) {
//            // Global statistics section
//            VStack(spacing: 12) {
//                HStack(spacing: 16) {
//                    // Monthly expenses card
//                    StatCard(
//                        title: "Ce mois",
//                        value: formatCurrency(monthlyExpenses),
//                        subtitle: "\(vehicleCount) véhicule\(vehicleCount > 1 ? "s" : "")",
//                        icon: "calendar",
//                        color: Color("primary")
//                    )
//
//                    // Alerts card
//                    StatCard(
//                        title: "Alertes",
//                        value: "\(alerts.count)",
//                        subtitle: alerts.isEmpty ? "Tout va bien" : "À traiter",
//                        icon: alerts.isEmpty ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
//                        color: alerts.isEmpty ? .green : .orange
//                    )
//                }
//
//                // Alerts list if any
//                if !alerts.isEmpty {
//                    VStack(alignment: .leading, spacing: 8) {
//                        ForEach(alerts.prefix(3)) { alert in
//                            AlertRow(alert: alert)
//                        }
//
//                        if alerts.count > 3 {
//                            Text("+ \(alerts.count - 3) autre(s) alerte(s)")
//                                .bodyXSmallRegular()
//                                .foregroundStyle(Color("onBackgroundSecondary"))
//                                .padding(.top, 4)
//                        }
//                    }
//                    .padding(12)
//                    .background(Color.orange.opacity(0.1))
//                    .cornerRadius(12)
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.top, 16)
//        }
//    }
//
//    private func formatCurrency(_ amount: Double) -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencyCode = "EUR"
//        formatter.maximumFractionDigits = 0
//        return formatter.string(from: NSNumber(value: amount)) ?? "0 €"
//    }
//}

// MARK: - Stat Card Component (commented)
//struct StatCard: View {
//    let title: String
//    let value: String
//    let subtitle: String
//    let icon: String
//    let color: Color
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Image(systemName: icon)
//                    .font(.title3)
//                    .foregroundStyle(color)
//                Spacer()
//            }
//
//            Text(value)
//                .font(.title)
//                .foregroundStyle(Color("onBackground"))
//
//            Text(title)
//                .bodySmallRegular()
//                .foregroundStyle(Color("onBackgroundSecondary"))
//
//            Text(subtitle)
//                .bodyXSmallRegular()
//                .foregroundStyle(Color("onBackgroundSecondary"))
//        }
//        .padding(12)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color("surface"))
//        .cornerRadius(12)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color("outline"), lineWidth: 1)
//        )
//    }
//}
//
//// MARK: - Alert Row Component (commented)
//struct AlertRow: View {
//    let alert: VehicleAlert
//
//    var body: some View {
//        HStack(spacing: 8) {
//            Image(systemName: iconName)
//                .foregroundStyle(.orange)
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(alert.vehicleName)
//                    .bodySmallSemibold()
//                    .foregroundStyle(Color("onBackground"))
//
//                Text(alert.message)
//                    .bodyXSmallRegular()
//                    .foregroundStyle(Color("onBackgroundSecondary"))
//            }
//
//            Spacer()
//        }
//    }
//
//    private var iconName: String {
//        switch alert.type {
//        case .technicalControl:
//            return "checkmark.seal.fill"
//        case .revision:
//            return "wrench.fill"
//        case .insurance:
//            return "shield.fill"
//        }
//    }
//}

// MARK: - Preview (commented)
//#Preview("Dashboard with data") {
//    let vehicles = [
//        Vehicle(
//            brand: "BMW",
//            model: "Série 3",
//            mileage: "45230",
//            registrationDate: Date().addingTimeInterval(-700 * 24 * 60 * 60),
//            plate: "AB-123-CD",
//            documents: [
//                Document(fileURL: "/path", name: "Vidange", date: Date(), mileage: "45000", type: .vidange, amount: 85.50),
//                Document(fileURL: "/path", name: "Plein", date: Date(), mileage: "45230", type: .carburant, amount: 65.00),
//            ]
//        ),
//        Vehicle(
//            brand: "Renault",
//            model: "Clio",
//            mileage: "87000",
//            registrationDate: Date().addingTimeInterval(-1500 * 24 * 60 * 60),
//            plate: "XY-456-ZA",
//            documents: [
//                Document(fileURL: "/path", name: "Révision", date: Date(), mileage: "87000", type: .revision, amount: 245.00),
//            ]
//        )
//    ]
//
//    return ScrollView {
//        DashboardView(vehicles: vehicles)
//    }
//    .background(Color("background"))
//}
//
//#Preview("Dashboard empty") {
//    ScrollView {
//        DashboardView(vehicles: [])
//    }
//    .background(Color("background"))
//}
