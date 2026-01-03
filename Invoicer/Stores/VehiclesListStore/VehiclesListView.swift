//
//  VehiclesListView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 11/10/2025.
//

import SwiftUI
import ComposableArchitecture

struct VehiclesListView: View {
    @Bindable var store: StoreOf<VehiclesListStore>

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground)
                .ignoresSafeArea()
                VStack {
                    ScrollView {
                        Text("Mon garage")
                            .largeTitle()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, Spacing.screenMargin)
                        VStack(spacing: Spacing.md) {
                            ForEach(store.vehicles.sorted { $0.isPrimary && !$1.isPrimary }) { vehicle in
                                vehicleCard(vehicle)
                            }
                        }
                        .padding(Spacing.screenMargin)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: Spacing.md) {
                        
                        PrimaryButton("Ajouter un nouveau véhicule", action: {
                            store.send(.view(.openCreateVehicleButtonTapped))
                        })
                        
                        TertiaryButton("Fermer", action: {
                            store.send(.view(.dimissSheetButtonTapped))
                        })
                    }
                    .padding(Spacing.screenMargin)
                }
        }
        .navigationBarBackButtonHidden()
        .fullScreenCover(item: $store.scope(state: \.addVehicle, action: \.addVehicle)) { store in
            AddVehicleView(store: store)
                    .presentationDetents([.large])
        }
    }
    
    private func vehicleCard(_ vehicle: Vehicle) -> some View {
        Button {
            store.send(.view(.selectedVehicleButtonTapped(vehicle)))
        } label: {
            HStack(spacing: 16) {
                // Vehicle info
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: -5) {
                            Text(vehicle.brand.uppercased())
                                .font(.headline)
                                .foregroundStyle(Color.primary)

                            Text(vehicle.model)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primary)
                            
                        }
                        Spacer()
                            Image(systemName: vehicle.type.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primary)
                                .frame(width: 120, height: 80)
                                .scaleEffect(x: vehicle.type.shouldFlipIcon ? -1 : 1, y: 1)
                                .offset(x: 60, y: -10)
                    }

                    HStack(spacing: 0) {
                        Text(vehicle.plate)
                        Spacer()
                        Text(vehicle.mileage?.asFormattedMileage ?? "Non renseigné")
                        Spacer()
                        Text("\(vehicle.registrationDate.shortDateString)")
                    }
                    .caption()
                }
            }
            .padding(Spacing.screenMargin)
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.primary.opacity(0.15), radius: Spacing.xs, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Empty list") {
    VehiclesListView(store: Store(initialState: VehiclesListStore.State()) {
        VehiclesListStore()
    })
}

#Preview("With vehicles") {
    VehiclesListView(store: Store(initialState: VehiclesListStore.State(vehicles: [
        .init(id: "String", brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
        .init(id: "String2", brand: "Tesla", model: "Model 3", mileage: "45000", registrationDate: Date(timeIntervalSince1970: 1577836800), plate: "AB-123-CD", documents: []),
        .init(id: "String3", brand: "BMW", model: "X5", mileage: "98000", registrationDate: Date(timeIntervalSince1970: 1546300800), plate: "EF-456-GH", documents: [])
    ])) {
        VehiclesListStore()
    })
}
