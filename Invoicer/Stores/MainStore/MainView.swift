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

struct MainView: View {
    @Bindable var store: StoreOf<MainStore>

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.secondarySystemBackground)
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
                            .font(Typography.title3)
                            .foregroundColor(ColorTokens.textPrimary)

                        Text("\(store.selectedVehicle.documents.count) documents")
                            .font(Typography.title2.weight(.bold))
                            .foregroundColor(ColorTokens.textPrimary)
                        
                        Spacer()
                        
                        Button {
                            store.send(.showAddDocument)
                        } label: {
                            
                            ZStack {
                                Circle()
                                    .fill(.black)
                                    .frame(width: 40, height: 40)

                                Image(systemName: "plus")
                                    .font(.system(size: 16).weight(.bold))
                                    .foregroundColor(.white)
                            }
                            
//                            Image(systemName: "plus")
//                                .font(Typography.title2.weight(.semibold))
//                                .foregroundColor(ColorTokens.onActionPrimary)
//                                .frame(width: 60, height: 60)
//                                .background(
//                                    Circle()
//                                        .fill(ColorTokens.actionPrimary)
//                                )
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
                .foregroundStyle(ColorTokens.textSecondary)
            Text("Aucun document")
                .font(Typography.headline)
                .foregroundStyle(ColorTokens.textPrimary)
            Text("Ajoutez des documents en prenant des photos")
                .font(Typography.subheadline)
                .foregroundStyle(ColorTokens.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }

    private var documentsListView: some View {
        LazyVStack(spacing: Spacing.sm) {
            ForEach(store.selectedVehicle.documents.groupedByMonth(), id: \.title) { section in
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(section.title)
                        .titleGroup()
                        .foregroundStyle(ColorTokens.textSecondary)

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
                        Label("Changer de véhicule",
                              systemImage: "arrow.triangle.2.circlepath")
                    }
                    Button(action: {
                        store.send(.showVehicleDetail(store.selectedVehicle))
                    }) {
                        Label("Voir les détails",
                              systemImage: "eye")
                    }
                    Button(role: .destructive) {
                        store.send(.view(.deleteVehicleButtonTapped))
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                } label: {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        HStack(alignment: .center, spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white)
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: store.selectedVehicle.type.iconName)
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.separator), lineWidth: 1)
                            )
                            
                            HStack(alignment: .lastTextBaseline, spacing: 8) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(store.selectedVehicle.brand)
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary)

                                    Text(store.selectedVehicle.model)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.primary)
                                }

                                ZStack {
                                    Circle()
                                        .fill(.gray.tertiary)
                                        .frame(width: 18, height: 18)

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10).weight(.bold))
                                        .foregroundColor(.black)
                                }
                                .alignmentGuide(.lastTextBaseline) { d in
                                    d[.bottom]
                                }
                            }

                            
                            Spacer()
                        }
                    }                }
                .menuActionDismissBehavior(.automatic)

                Spacer()
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
                            .init(fileURL: "", name: "Vidange", date: .now, mileage: "100000", type: .maintenance)
                        ]
                    ))
                ),
                reducer: { MainStore() }
            )
        )
    }
}
