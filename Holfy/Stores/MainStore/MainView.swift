//
//  MainView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture
import Charts
import QuickLook
import FirebaseCrashlytics

struct MainView: View {
    @Bindable var store: StoreOf<MainStore>

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground)
                .ignoresSafeArea()

            if store.vehicles.isEmpty {
                EmptyVehiclesListView {
                    store.send(.view(.openCreateVehicleButtonTapped))
                }
            } else {
                mainContentView
            }
        }
        .navigationBarBackButtonHidden()
        .alert($store.scope(state: \.deleteAlert, action: \.deleteAlert))
        .fullScreenCover(item: $store.scope(state: \.vehiclesList, action: \.vehiclesList)) { store in
            VehiclesListView(store: store)
                .presentationDetents([.large])
        }  
        .fullScreenCover(item: $store.scope(state: \.addFirstVehicle, action: \.addFirstVehicle)) { store in
            AddFirstVehicleView(store: store)
                .presentationDetents([.large])
        }
        .fullScreenCover(item: $store.scope(state: \.addDocument, action: \.addDocument)) { store in
            AddDocumentView(store: store)
                .presentationDetents([.large])
        }
    }

    private var mainContentView: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.horizontal, Spacing.md)

            // Custom Segmented Control
            CustomSegmentedControl(
                store: store.scope(
                    state: \.tabStore,
                    action: \.tabStore
                )
            )
            .padding(.vertical, Spacing.sm)
            .background(Color(.systemBackground))

            // Content based on selected tab
            tabContentView
            Spacer()
        }
    }

    @ViewBuilder
    private var tabContentView: some View {
        switch store.tabStore.selectedTab {
        case .overview:
            VehicleOverviewView(store: store)

        case .statistics:
            VehicleStatisticsView(store: store)

        case .maintenance:
            VehicleMaintenanceView(store: store)

        case .administration:
            VehicleAdministrationView(store: store)

        case .fuel:
            VehicleFuelView(store: store)
        }
    }


    private var headerView: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .lastTextBaseline) {
                Menu {
                    Button(action: {
                        store.send(.presentVehiclesListView)
                    }) {
                        Label("main_menu_change_vehicle",
                              systemImage: "arrow.triangle.2.circlepath")
                    }
                    Button(action: {
                        store.send(.showVehicleDetail(store.selectedVehicle))
                    }) {
                        Label("main_menu_view_details",
                              systemImage: "eye")
                    }
                    Button(role: .destructive) {
                        store.send(.view(.deleteVehicleButtonTapped))
                    } label: {
                        Label("all_delete", systemImage: "trash")
                    }
                } label: {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        HStack(alignment: .center, spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.tertiarySystemGroupedBackground))
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: store.selectedVehicle.type.iconName)
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.primary)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.tertiary, lineWidth: 1)
                            )
                            
                            HStack(alignment: .lastTextBaseline, spacing: 8) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(store.selectedVehicle.brand)
                                        .secondaryBody()

                                    Text(store.selectedVehicle.model)
                                        .title()
                                }

                                ZStack {
                                    Circle()
                                        .fill(.gray.quaternary)
                                        .frame(width: 20, height: 20)

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10).weight(.bold))
                                        .foregroundColor(Color.primary)
                                }
                                .alignmentGuide(.lastTextBaseline) { d in
                                    d[.bottom]
                                }
                                .offset(y: 2)
                            }

                            
                            Spacer()
                        }
                    }                }
                .menuActionDismissBehavior(.automatic)

                Spacer()
                
                SecondaryCircleButton(systemImage: "gearshape", action: {
                    store.send(.view(.settingsButtonTapped))
                })
            }
        }
        .padding(.top, Spacing.xs)
    }
}

#Preview("Empty vehicle list") {
    NavigationView {
        MainView(
            store: Store(
                initialState: MainStore.State(
                    selectedVehicle: Shared(value: .init(
                        id: "String",
                        brand: "Lexus",
                        model: "CT200H",
                        mileage: "120000",
                        registrationDate: Date(timeIntervalSince1970: 1322784000),
                        plate: "BZ-029-YV",
                        documents: [
                            .init(fileURL: "", name: "Vidange", date: .now, mileage: "100000", type: .maintenance)
                        ]
                    )),
                    tabStore: VehicleDetailTabStore.State()
                ),
                reducer: { MainStore() }
            )
        )
    }
}

#Preview("Selected vehicle") {
    @Shared(.selectedCurrency) var currency = .dollar
    @Shared(.selectedDistanceUnit) var distanceUnit = .miles

    NavigationView {
        MainView(
            store: Store(
                initialState: MainStore.State(
                    vehicles: [
                        .init(
                            id: "String",
                            brand: "Lexus",
                            model: "CT200H",
                            mileage: "120000",
                            registrationDate: Date(timeIntervalSince1970: 1322784000),
                            plate: "BZ-029-YV",
                            documents: [
                                .init(fileURL: "", name: "Vidange", date: .now, mileage: "100000", type: .maintenance)
                                .init(fileURL: "", name: "CT1", date: .now, mileage: "100000", type: .technicalInspection)
                                .init(fileURL: "", name: "Réparation", date: .now, mileage: "100000", type: .repair)
                                .init(fileURL: "", name: "J'sais plus", date: .now, mileage: "100000", type: .other)
                                .init(fileURL: "", name: "CT2", date: .now, mileage: "100000", type: .technicalInspection)
                            ]
                        )
                    ],
                    selectedVehicle: Shared(value: .init(
                        id: "String",
                        brand: "Lexus",
                        model: "CT200H",
                        mileage: "120000",
                        registrationDate: Date(timeIntervalSince1970: 1322784000),
                        plate: "BZ-029-YV",
                        documents: [
                            .init(fileURL: "", name: "Vidange", date: .now, mileage: "", type: .maintenance)
                        ]
                    )),
                    tabStore: VehicleDetailTabStore.State()
                ),
                reducer: { MainStore() }
            )
        )
    }
}
