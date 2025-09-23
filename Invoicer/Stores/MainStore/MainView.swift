//
//  MainView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct MainView: View {
    @Bindable var store: StoreOf<MainStore>
    
    var body: some View {
        VStack(spacing: 20) {
            if store.vehicles.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "car.fill")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Aucun véhicule enregistré")
                        .font(.headline)
                    Text("Commencez par ajouter votre premier véhicule")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
            } else {
                List(store.vehicles) { vehicle in
                    Button(action: {
                        store.send(.showVehicleDetail(vehicle))
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(vehicle.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("Plaque: \(vehicle.licensePlate)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Spacer()
            
            Button(action: {
                store.send(.showAddVehicle)
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter un véhicule")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            // Plus besoin de loadVehicles avec @Shared - la liste est automatiquement réactive
            if store.vehicles.isEmpty {
                store.send(.loadVehicles)
            }
        }
        .navigationTitle("Mes Véhicules")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden()
    }
}

#Preview("Empty list"){
    NavigationView {
        MainView(store: Store(initialState: MainStore.State()) {
            MainStore()
        })
    }
}

#Preview("1 vehicle") {
    NavigationView {
        MainView(store: Store(initialState: MainStore.State(vehicles: [.init(name: "test", currentMileage: "0", registrationDate: "0", licensePlate: "0", documents: [])])) {
            MainStore()
        })
    }
}
