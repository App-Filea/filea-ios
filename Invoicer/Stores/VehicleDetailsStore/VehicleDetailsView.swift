//
//  VehicleDetailsView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct VehicleDetailsView: View {
    @Bindable var store: StoreOf<VehicleDetailsStore>

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ColorTokens.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xxl) {
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white)
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: store.selectedVehicle.type.iconName)
                                    .font(.system(size: 36))
                                    .foregroundColor(.black)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(store.selectedVehicle.brand)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                
                                Text(store.selectedVehicle.model)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text(store.selectedVehicle.isPrimary == true ? "Véhicule principal" : "Véhicule secondaire")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: Spacing.formFieldSpacing) {
                            Text("Informations")
                                .font(Typography.title2.weight(.bold))
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            VStack(spacing: Spacing.formFieldSpacing) {
                                HStack {
                                    Text("Immatriculation")
                                        .font(.subheadline)
                                        .foregroundStyle(ColorTokens.textSecondary)
                                    Spacer()
                                    Text(store.selectedVehicle.plate)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(ColorTokens.textPrimary)
                                }
                                Divider()
                                HStack {
                                    Text("Kilométrage")
                                        .font(.subheadline)
                                        .foregroundStyle(ColorTokens.textSecondary)
                                    Spacer()
                                    Text(store.selectedVehicle.mileage ?? "-- €")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(ColorTokens.textPrimary)
                                }
                                Divider()
                                HStack {
                                    Text("Mise en circulation")
                                        .font(.subheadline)
                                        .foregroundStyle(ColorTokens.textSecondary)
                                    Spacer()
                                    Text(formattedDate(store.selectedVehicle.registrationDate))
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(ColorTokens.textPrimary)
                                }
                                Divider()
                                HStack {
                                    Text("Age du véhicule")
                                        .font(.subheadline)
                                        .foregroundStyle(ColorTokens.textSecondary)
                                    Spacer()
                                    Text(vehicleAge(from: store.selectedVehicle.registrationDate))
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(ColorTokens.textPrimary)
                                }
                                Divider()
                                HStack {
                                    Text("Documents associés")
                                        .font(.subheadline)
                                        .foregroundStyle(ColorTokens.textSecondary)
                                    Spacer()
                                    Text("\(String(describing: store.selectedVehicle.documents.count))")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(ColorTokens.textPrimary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 24)
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(.separator), lineWidth: 1)
                            )
                        }
                        
                        Spacer()
                        
                        VStack {
                            
                            Button(action: { store.send(.editVehicleButtonTapped) }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.pencil")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Modifier")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.black)
                                .cornerRadius(14)
                            }
                        }
                    }
                    .padding([.horizontal, .bottom], 16)
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
    }

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

#Preview {
    NavigationView {
        VehicleDetailsView(store:
                        Store(initialState:
                                VehicleDetailsStore.State(selectedVehicle: Shared(value: Vehicle(
                                    id: "uuid",
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
