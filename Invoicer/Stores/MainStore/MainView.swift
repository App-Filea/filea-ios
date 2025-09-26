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
        ZStack(alignment: .bottom) {
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
                    ScrollView {
                        ForEach(store.vehicles) { vehicle in
                            VStack(alignment: .leading, spacing: 4) {
                                
                                HStack(alignment: .firstTextBaseline) {
                                    Text(vehicle.brand.uppercased())
                                        .bodyXLargeBlack()
                                    Text(vehicle.model)
                                        .bodyDefaultLight()
                                    Spacer()
                                    
                                    Text(vehicle.plate)
                                        .bodySmallRegular()
                                        .foregroundStyle(.secondary)
                                        .padding(6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(.secondary, lineWidth: 0.5)
                                        )
                                        .alignmentGuide(.firstTextBaseline) { d in
                                            d[.bottom]
                                        }
                                }
                                HStack(spacing: 4) {
                                    Text("2011"/*vehicle.registrationDate*/)
                                    Text("-")
                                    Text("\(vehicle.mileage)km")
                                    Spacer()
                                    
                                    HStack {
                                        Text("Voir les détails")
                                        Image(systemName: "arrow.right")
                                    }
                                    .bodySmallSemibold()
                                    .foregroundStyle(.primary)
                                }
                                .bodyDefaultLight()
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                store.send(.showVehicleDetail(vehicle))
                                print("Tap sur le véhicule")
                            }
                            
                            
                            if vehicle != store.vehicles.last {
                                Divider()
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .contentMargins(.bottom, 100, for: .scrollContent)
                }
            }
            
            Button(action: {
                store.send(.showAddVehicle)
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter un véhicule")
                }
                .bodyDefaultSemibold()
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.38), radius: 8, x: 0, y: 4)
            }
            .padding()
        }
        .onAppear {
            if store.vehicles.isEmpty {
                store.send(.loadVehicles)
            }
        }
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
        MainView(store: Store(initialState: MainStore.State(vehicles: [
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: "2011-12-02", plate: "BZ-029-YV", documents: []),
        ])) {
            MainStore()
        })
    }
}
