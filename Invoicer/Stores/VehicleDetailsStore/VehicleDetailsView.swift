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
                                
                                Text(store.selectedVehicle.isPrimary == true ? "vehicle_form_status_primary" : "vehicle_form_status_secondary")
                                    .subLargeTitle()
                            }
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("vehicle_details_information_title")
                                .title()

                            VStack(spacing: Spacing.md) {
                                HStack {
                                    Text("vehicle_form_plate_title")
                                        .secondarySubheadline()
                                    Spacer()
                                    Text(store.selectedVehicle.plate)
                                        .primarySubheadline()
                                }
                                Divider()
                                HStack {
                                    Text("vehicle_form_mileage_title")
                                        .secondarySubheadline()
                                    Spacer()
                                    Text(store.selectedVehicle.mileage ?? "-- KM")
                                        .primarySubheadline()
                                }
                                Divider()
                                HStack {
                                    Text("vehicle_form_registration_date_title")
                                        .secondarySubheadline()
                                    Spacer()
                                    Text(formattedDate(store.selectedVehicle.registrationDate))
                                        .primarySubheadline()
                                }
                                Divider()
                                HStack {
                                    Text("vehicle_details_age_label")
                                        .secondarySubheadline()
                                    Spacer()
                                    Text(vehicleAge(from: store.selectedVehicle.registrationDate))
                                        .primarySubheadline()
                                }
                                Divider()
                                HStack {
                                    Text("vehicle_details_documents_label")
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
                            PrimaryButton("all_edit", systemImage: "square.and.pencil", action: {
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
            let key = years > 1 ? "vehicle_age_years_plural" : "vehicle_age_years_singular"
            return String(localized: String.LocalizationValue(stringLiteral: key))
                .replacingOccurrences(of: "%d", with: "\(years)")
        } else if let months = components.month, months > 0 {
            return String(localized: String.LocalizationValue(stringLiteral: "vehicle_age_months"))
                .replacingOccurrences(of: "%d", with: "\(months)")
        } else {
            return String(localized: "vehicle_age_new")
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
