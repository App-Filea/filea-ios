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
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xxl) {
                        HStack(alignment: .center, spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.tertiarySystemGroupedBackground))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: store.selectedVehicle.type.iconName)
                                    .font(.system(size: 36))
                                    .foregroundColor(Color.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(store.selectedVehicle.brand)
                                    .subLargeTitle()
                                
                                Text(store.selectedVehicle.model)
                                    .largeTitle()
                                
                                Text(store.selectedVehicle.isPrimary == true ? "Véhicule principal" : "Véhicule secondaire")
                                    .subLargeTitle()
                            }
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Informations")
                                .title()

                            VStack(spacing: Spacing.md) {
                                HStack {
                                    Text("Immatriculation")
                                        .secondarySubheadline()
                                    Spacer()
                                    Text(store.selectedVehicle.plate)
                                        .primarySubheadline()
                                }
                                Divider()
                                HStack {
                                    Text("Kilométrage")
                                        .secondarySubheadline()
                                    Spacer()
                                    Text(store.selectedVehicle.mileage ?? "-- €")
                                        .primarySubheadline()
                                }
                                Divider()
                                HStack {
                                    Text("Mise en circulation")
                                        .secondarySubheadline()
                                    Spacer()
                                    Text(formattedDate(store.selectedVehicle.registrationDate))
                                        .primarySubheadline()
                                }
                                Divider()
                                HStack {
                                    Text("Age du véhicule")
                                        .secondarySubheadline()
                                    Spacer()
                                    Text(vehicleAge(from: store.selectedVehicle.registrationDate))
                                        .primarySubheadline()
                                }
                                Divider()
                                HStack {
                                    Text("Documents associés")
                                        .secondarySubheadline()
                                    Spacer()
                                    Text("\(String(describing: store.selectedVehicle.documents.count))")
                                        .primarySubheadline()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 24)
                            .background(Color(.systemGroupedBackground))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(.separator), lineWidth: 1)
                            )
                        }
                        
                        Spacer()
                        
                        VStack {
                            PrimaryButton("Modifier", systemImage: "square.and.pencil", action: {
                                store.send(.editVehicleButtonTapped)
                            })
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
