//
//  VehiclesListView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct VehiclesListView: View {
    @Bindable var store: StoreOf<VehiclesListStore>
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(ColorTokens.background)
                .ignoresSafeArea()
            
            if store.vehicles.isEmpty {
                EmptyVehiclesListView(onButtonTapped: { store.send(.showAddVehicle) })
            } else {
                VStack {
                    ScrollView {
                        Text("Mon garage")
                            .font(Typography.largeTitle)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding([.horizontal, .top], Spacing.screenMargin)
                        VStack(spacing: Spacing.listItemSpacing) {
                            ForEach(store.vehicles.sorted { $0.isPrimary && !$1.isPrimary }) { vehicle in
                                vehicleCard(vehicle)
                            }
                        }
                        .padding(Spacing.screenMargin)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    Button(action: {}) {
                        Text("Ajouter un nouveau véhicule")
                    }
                    .buttonStyle(.primaryTextOnly())
                }
            }
        }
        .navigationBarBackButtonHidden()
        .fullScreenCover(item: $store.scope(state: \.addVehicle, action: \.addVehicle)) { store in
            AddVehicleMultiStepView(store: store)
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
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: -5) {
                            Text(vehicle.brand.uppercased())
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .kerning(-1)
                                .foregroundStyle(ColorTokens.label)
                            
                            Text(vehicle.model)
                                .font(.headline)
                                .foregroundStyle(ColorTokens.label)
                        }
                        Spacer()
                        // Vehicle type icon
                        Image(systemName: vehicle.type.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .fontWeight(.bold)
                            .foregroundStyle(ColorTokens.label)
                            .frame(/*maxWidth: 128, */width: 120, height: 80)
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
                    .font(.footnote)
                    .foregroundStyle(Color(.secondaryLabel))
                }
            }
            .padding(Spacing.screenMargin)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: ColorTokens.shadow, radius: Spacing.xs, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Empty list") {
    NavigationView {
        VehiclesListView(store: Store(initialState: VehiclesListStore.State()) {
            VehiclesListStore()
        })
    }
}

#Preview("With vehicles") {
    @Dependency(\.uuid) var uuid
    NavigationView {
        VehiclesListView(store: Store(initialState: VehiclesListStore.State(vehicles: [
            .init(id: uuid(), type: .bicycle, brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(id: uuid(), type: .motorcycle, brand: "Tesla", model: "Model 3", mileage: "45000", registrationDate: Date(timeIntervalSince1970: 1577836800), plate: "AB-123-CD", documents: []),
            .init(id: uuid(), type: .truck, brand: "BMW", model: "X5", mileage: "98000", registrationDate: Date(timeIntervalSince1970: 1546300800), plate: "EF-456-GH", documents: []),
            .init(id: uuid(), type: .other, brand: "BMW", model: "X5", mileage: "98000", registrationDate: Date(timeIntervalSince1970: 1546300800), plate: "EF-456-GH", documents: []),
            .init(id: uuid(), type: .car, brand: "Toyota", model: "X5", mileage: "98000", registrationDate: Date(timeIntervalSince1970: 1546300800), plate: "EF-456-GH", isPrimary: true, documents: [])
        ])) {
            VehiclesListStore()
        })
    }
}
