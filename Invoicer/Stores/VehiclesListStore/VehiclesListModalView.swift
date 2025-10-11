//
//  VehiclesListModalView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 11/10/2025.
//

import SwiftUI
import ComposableArchitecture

struct VehiclesListModalView: View {
    @Bindable var store: StoreOf<VehiclesListModalStore>

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color(.secondarySystemBackground)
                    .ignoresSafeArea()

                if store.vehicles.isEmpty {
                    emptyStateView
                } else {
                    vehiclesListContent
                }

                // Floating action button
                Button {
                    store.send(.showAddVehicle)
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(.purple)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(24)
            }
            .onAppear {
                store.send(.loadVehicles)
            }
            .navigationTitle("Mes véhicules")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        store.send(.dismiss)
                    }
                }
            }
            .fullScreenCover(item: $store.scope(state: \.addVehicle, action: \.addVehicle)) { store in
                    AddVehicleView(store: store)
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "car.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            Text("Aucun véhicule enregistré")
                .font(.headline)
                .foregroundStyle(Color(.label))
            Text("Commencez par ajouter votre premier véhicule")
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
            Spacer()
        }
        .padding()
    }

    // MARK: - Vehicles List
    private var vehiclesListContent: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(store.vehicles) { vehicle in
                    vehicleCard(vehicle)
                }
            }
            .padding(16)
        }
    }

    // MARK: - Vehicle Card
    private func vehicleCard(_ vehicle: Vehicle) -> some View {
        Button {
            store.send(.selectVehicle(vehicle))
        } label: {
            HStack(spacing: 16) {
                // Vehicle info
                VStack(alignment: .leading, spacing: 0) {
                    Text("Véhicule principal")
                        .font(.footnote)
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: -5) {
                            Text(vehicle.brand.uppercased())
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .kerning(-1)
                                .foregroundStyle(Color(.label))

                            Text(vehicle.model)
                                .font(.headline)
                                .foregroundStyle(Color(.label))
                        }
                        Spacer()
                        // Vehicle type icon
                        if let iconName = vehicle.type.iconName {
                            Image(systemName: iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.label))
                                .frame(maxWidth: 128)
                                .scaleEffect(x: vehicle.type.shouldFlipIcon ? -1 : 1, y: 1)
                                .offset(x: vehicle.type.offsetX, y: -10)
                        }
                    }

                    HStack(spacing: 0) {
                        Text(vehicle.plate)
                        Spacer()
                        Text("\(vehicle.mileage) km")
                        Spacer()
                        Text("\(vehicle.registrationDate, style: .date)")
                    }
                    .font(.footnote)
                    .foregroundStyle(Color(.secondaryLabel))
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }

}

#Preview("Empty list") {
    VehiclesListModalView(store: Store(initialState: VehiclesListModalStore.State()) {
        VehiclesListModalStore()
    })
}

#Preview("With vehicles") {
    VehiclesListModalView(store: Store(initialState: VehiclesListModalStore.State(vehicles: [
        .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
        .init(brand: "Tesla", model: "Model 3", mileage: "45000", registrationDate: Date(timeIntervalSince1970: 1577836800), plate: "AB-123-CD", documents: []),
        .init(brand: "BMW", model: "X5", mileage: "98000", registrationDate: Date(timeIntervalSince1970: 1546300800), plate: "EF-456-GH", documents: [])
    ])) {
        VehiclesListModalStore()
    })
}
