//
//  VehicleView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct VehicleView: View {
    @Bindable var store: StoreOf<VehicleStore>

    var body: some View {
        ZStack(alignment: .top) {
            Color("background")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Vehicle header
                VStack(alignment: .leading, spacing: 4) {
                    // Vehicle type
                    Text(store.vehicle.type.displayName)
                        .bodySmallSemibold()
                        .foregroundStyle(Color("primary"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("primary").opacity(0.1))
                        .cornerRadius(6)

                    HStack(alignment: .firstTextBaseline) {
                        Text(store.vehicle.brand.uppercased())
                            .bodyXLargeBlack()
                            .foregroundStyle(Color("onBackground"))
                        Text(store.vehicle.model)
                            .bodyDefaultLight()
                            .foregroundStyle(Color("onBackground"))
                        Spacer()

                        Text(store.vehicle.plate)
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
                        Text(formattedDate(store.vehicle.registrationDate, isOnlyYear: true))
                        Text("-")
                        Text(store.vehicle.mileage != nil ? "\(store.vehicle.mileage!)km" : "Non renseigné")
                        Spacer()
                    }
                    .bodyDefaultLight()
                    .foregroundStyle(Color("onBackgroundSecondary"))
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // Action buttons
                VStack(spacing: .stackMD) {
                    HStack(spacing: .inlineMD) {
                        Button(action: { store.send(.showEditVehicle) }) {
                            HStack(spacing: .iconTextGap) {
                                Image(systemName: "square.and.pencil")
                                    .font(.title3)
                                    .foregroundStyle(Color("onSurface"))
                                Text("Modifier")
                                    .bodyDefaultSemibold()
                                    .foregroundStyle(Color("onSurface"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, .buttonPaddingVertical)
                            .padding(.horizontal, .buttonPaddingHorizontal)
                            .background(Color("tertiary"))
                            .cornerRadius(8)
                        }

                        Button(action: { store.send(.deleteVehicleTapped) }) {
                            HStack(spacing: .iconTextGap) {
                                Image(systemName: "trash")
                                    .font(.title3)
                                    .foregroundStyle(Color("onErrorContainer"))
                                Text("Supprimer")
                                    .bodyDefaultSemibold()
                                    .foregroundStyle(Color("onErrorContainer"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, .buttonPaddingVertical)
                            .padding(.horizontal, .buttonPaddingHorizontal)
                            .background(Color("errorContainer"))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, .gutterMD)

                Spacer()

                // Info message
                VStack(spacing: 12) {
                    Image(systemName: "info.circle")
                        .font(.largeTitle)
                        .foregroundStyle(Color("primary"))
                    Text("Gestion des documents")
                        .font(.headline)
                        .foregroundStyle(Color("onBackground"))
                    Text("Les documents sont maintenant gérés depuis l'écran principal")
                        .font(.subheadline)
                        .foregroundStyle(Color("onBackgroundSecondary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()
            }
        }
        .onAppear {
            store.send(.loadVehicleData)
        }
        .alert($store.scope(state: \.deleteAlert, action: \.deleteAlert))
    }
    
    private func formattedDate(_ date: Date, isOnlyYear: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = isOnlyYear ? "yyyy" : "d MMM"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        VehicleView(store:
                        Store(initialState:
                                VehicleStore.State(vehicle:
                                                    Vehicle(brand: "Lexus",
                                                            model: "CT200h",
                                                            mileage: "122000",
                                                            registrationDate: Date(timeIntervalSince1970: 1322784000),
                                                            plate: "ABC-123",
                                                            documents: [
                                                                .init(fileURL: "/path/to/document1.jpg", name: "Carte grise", date: Date(), mileage: "45000", type: .carteGrise),
                                                                .init(fileURL: "/path/to/document2.pdf", name: "Facture révision", date: Date(), mileage: "50000", type: .entretien),
                                                                .init(fileURL: "/path/to/document1.jpg", name: "Test 1", date: Date(timeIntervalSince1970: 999), mileage: "1", type: .entretien),
                                                                .init(fileURL: "/path/to/document2.pdf", name: "Test 2", date: Date(timeIntervalSince1970: 99999), mileage: "50000", type: .achatPiece),
                                                                .init(fileURL: "/path/to/document1.jpg", name: "Carte grise", date: Date(), mileage: "45000", type: .entretien),
                                                                .init(fileURL: "/path/to/document2.pdf", name: "Facture révision", date: Date(), mileage: "50000", type: .reparation),
                                                                .init(fileURL: "/path/to/document1.jpg", name: "Test 1", date: Date(timeIntervalSince1970: 999), mileage: "1", type: .entretien),
                                                                .init(fileURL: "/path/to/document2.pdf", name: "Test 2", date: Date(timeIntervalSince1970: 99999), mileage: "50000", type: .entretien)
                                                            ]))) {
                                                                VehicleStore()
                                                            })
    }
}
