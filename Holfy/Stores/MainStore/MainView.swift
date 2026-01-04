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
        VStack(spacing: Spacing.md) {
            headerView
                .padding(.horizontal, Spacing.md)

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    // Stats cards
                    HStack(spacing: Spacing.sm) {
                        TotalCostVehicleView(store: store.scope(state: \.totalCostVehicle, action: \.totalCostVehicle))

                        WarningVehicleView(store: store.scope(state: \.warningVehicle, action: \.warningVehicle))
                    }

                    VehicleMonthlyExpensesView(store: store.scope(state: \.vehicleMonthlyExpenses, action: \.vehicleMonthlyExpenses))

                    Divider()

                    HStack {
                        Image(systemName: "folder.fill")
                            .title()

                        Text(String(format: String(localized: "main_documents_count"), store.selectedVehicle.documents.count))
                            .title()
                        
                        Spacer()
                        
                        PrimaryCircleButton(systemImage: "plus") {
                            store.send(.showAddDocument)
                        }
                    }

                    if store.selectedVehicle.documents.isEmpty {
                        emptyDocumentsView
                    } else {
                        documentsListView
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private var emptyDocumentsView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "doc.fill")
                .imageScale(.large)
                .foregroundStyle(Color.secondary)
            Text("main_empty_documents_title")
                .font(.headline)
                .foregroundStyle(Color.primary)
            Text("main_empty_documents_subtitle")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }

    private var documentsListView: some View {
        LazyVStack(spacing: Spacing.sm) {
            ForEach(store.selectedVehicle.documents.groupedByMonth(), id: \.title) { section in
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(section.title)
                        .secondarySubheadline()

                    ForEach(section.items) { document in
                        eventElement(of: document)
                    }
                }
            }
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

    private func eventElement(of document: Document) -> some View {
        DocumentCard(document: document) {
            store.send(.showDocumentDetail(document))
        }
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
                    ))
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
                    ))
                ),
                reducer: { MainStore() }
            )
        )
    }
}
