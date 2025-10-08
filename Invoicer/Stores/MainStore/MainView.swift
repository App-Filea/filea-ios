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
            Color("background")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if store.vehicles.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "car.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color("primary"))
                        Text("Aucun véhicule enregistré")
                            .font(.headline)
                            .foregroundStyle(Color("onBackground"))
                        Text("Commencez par ajouter votre premier véhicule")
                            .font(.subheadline)
                            .foregroundStyle(Color("onBackground"))
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
                                        .foregroundStyle(Color("onBackground"))
                                    Text(vehicle.model)
                                        .bodyDefaultLight()
                                        .foregroundStyle(Color("onBackground"))
                                    Spacer()
                                    
                                    Text(vehicle.plate)
                                        .bodyXSmallRegular()
                                        .foregroundStyle(Color("onBackgroundSecondary"))
                                        .padding(6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color("onBackgroundSecondary"), lineWidth: 0.5)
                                        )
                                        .alignmentGuide(.firstTextBaseline) { d in
                                            d[.bottom]
                                        }
                                }
                                HStack(spacing: 4) {
                                    Text(formattedDate(vehicle.registrationDate, isOnlyYear: true))
                                    Text("-")
                                    Text("\(vehicle.mileage)km")
                                    Spacer()
                                    
                                    HStack {
                                        Text("Voir les détails")
                                        Image(systemName: "arrow.right")
                                    }
                                    .bodyXSmallSemibold()
                                    .foregroundStyle(Color("onBackground"))
                                }
                                .bodyDefaultLight()
                                .foregroundStyle(Color("onBackgroundSecondary"))
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
            
            Button("Ajouter un véhicule",
                   systemImage: "plus.circle.fill",
                   action: { store.send(.showAddVehicle) })
            .bodyDefaultSemibold()
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .background(Color("primary"))
            .foregroundColor(Color("onPrimary"))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.38), radius: 8, x: 0, y: 4)
            .padding()
        }
        .onAppear {
            if store.vehicles.isEmpty {
                store.send(.loadVehicles)
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func formattedDate(_ date: Date, isOnlyYear: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = isOnlyYear ? "yyyy" : "d MMM"
        return formatter.string(from: date)
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
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: []),
        ])) {
            MainStore()
        })
    }
}
