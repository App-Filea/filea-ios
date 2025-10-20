//
//  VehicleDetailsView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

// MARK: - Info Card Component
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let accentColor: Color

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(height: 88)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Mileage Card Component
struct MileageCard: View {
    let mileage: String?

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 60, height: 60)

                Image(systemName: "gauge.with.needle")
                    .font(.system(size: 28))
                    .foregroundStyle(.green)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Kilométrage")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)

                if let mileage = mileage, !mileage.isEmpty {
                    Text(mileage.asFormattedMileage)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.primary)
                } else {
                    Text("Non renseigné")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(height: 110)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Main View
struct VehicleDetailsView: View {
    @Bindable var store: StoreOf<VehicleDetailsStore>

    var body: some View {
        ZStack(alignment: .top) {
            Color(.secondarySystemBackground)
                .ignoresSafeArea()

            // Background Icon (Blurred)
            if let selectedVehicle = store.selectedVehicle, let iconName = selectedVehicle.type.iconName {
                GeometryReader { proxy in
                    VStack {
                        Image(systemName: iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 400)
                            .foregroundStyle(Color(.tertiaryLabel))
                            .scaleEffect(x: selectedVehicle.type.shouldFlipIcon ? -1 : 1, y: 1)
                            .blur(radius: 10)
                            .offset(x: proxy.size.width / 2, y: -40)
                        Spacer()
                    }
                    .frame(width: proxy.size.width)
                }
            }

            ScrollView {
                VStack(spacing: 24) {
                    if let selectedVehicle = store.selectedVehicle {
                        // MARK: - Header Section
                        VStack(spacing: 16) {
                            // Vehicle Type Badge + Brand & Model + Status
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    // Vehicle Type Badge
                                    Text(selectedVehicle.type.displayName)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.tertiarySystemBackground))
                                        .cornerRadius(8)

                                    // Status Badge
                                    Text(selectedVehicle.isPrimary ? "Principal" : "Secondaire")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(selectedVehicle.isPrimary ? .orange : .gray)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(selectedVehicle.isPrimary ? Color.orange.opacity(0.15) : Color.gray.opacity(0.15))
                                        )
                                }

                                // Brand and Model
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(selectedVehicle.brand.uppercased())
                                        .font(.system(size: 48, weight: .black))
                                        .kerning(-1)
                                        .foregroundStyle(Color(.label))

                                    Text(selectedVehicle.model)
                                        .font(.system(size: 32, weight: .light))
                                        .foregroundStyle(Color(.secondaryLabel))
                                }
                            }
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // MARK: - Mileage Section (Prominent)
                        MileageCard(mileage: selectedVehicle.mileage)
                            .padding(.horizontal, 16)

                        // MARK: - Information Cards Section
                        VStack(spacing: 12) {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                // Registration Date Card
                                InfoCard(
                                    icon: "calendar.badge.plus",
                                    title: "Circulation",
                                    value: formattedDate(selectedVehicle.registrationDate),
                                    accentColor: .blue
                                )

                                // Vehicle Age Card
                                InfoCard(
                                    icon: "hourglass",
                                    title: "Âge",
                                    value: vehicleAge(from: selectedVehicle.registrationDate),
                                    accentColor: .cyan
                                )

                                // License Plate Card
                                InfoCard(
                                    icon: "number.square",
                                    title: "Immatriculation",
                                    value: selectedVehicle.plate,
                                    accentColor: .orange
                                )

                                // Documents Card
                                InfoCard(
                                    icon: "folder.fill",
                                    title: "Documents",
                                    value: "\(selectedVehicle.documents.count)",
                                    accentColor: .indigo
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .alert($store.scope(state: \.deleteAlert, action: \.deleteAlert))
        .sheet(item: $store.scope(state: \.editVehicle, action: \.editVehicle)) { editStore in
            NavigationStack {
                EditVehicleView(store: editStore)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Modifier") {
                    store.send(.editVehicleTapped)
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func vehicleAge(from date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date, to: Date())

        if let years = components.year, years > 0 {
            return "\(years) an\(years > 1 ? "s" : "")"
        } else if let months = components.month, months > 0 {
            return "\(months) mois"
        } else {
            return "Neuf"
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        VehicleDetailsView(store:
                        Store(initialState:
                                VehicleDetailsStore.State(selectedVehicle: Shared(value: Vehicle(
                                    type: .car,
                                    brand: "Lexus",
                                    model: "CT200h",
                                    mileage: "122000",
                                    registrationDate: Date(timeIntervalSince1970: 1322784000),
                                    plate: "AB-123-CD",
                                    isPrimary: false,
                                    documents: [])))) {
            VehicleDetailsStore()
        })
    }
}
