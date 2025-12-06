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
                // EmptyState si aucun véhicule
                EmptyVehiclesListView {
                    store.send(.view(.openCreateVehicleButtonTapped))
                }
            } else {
                // Dashboard normal si au moins 1 véhicule
                mainContentView
            }
        }
//        .onAppear {
//            store.send(.onAppear)
//        }
        .navigationBarBackButtonHidden()
        .alert($store.scope(state: \.deleteAlert, action: \.deleteAlert))
        .sheet(item: $store.scope(state: \.vehiclesList, action: \.vehiclesList)) { store in
            VehiclesListView(store: store)
                .presentationDetents([.large])
        }  
        .sheet(item: $store.scope(state: \.addVehicle, action: \.addVehicle)) { store in
            AddVehicleMultiStepView(store: store)
                .presentationDetents([.large])
        }
        .fullScreenCover(item: $store.scope(state: \.addDocument, action: \.addDocument)) { store in
            AddDocumentMultiStepView(store: store)
                .presentationDetents([.large])
        }
    }

    // MARK: - Main Content
    private var mainContentView: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: Spacing.md) {
                // Header section - Not scrollable
                headerView
                    .padding(.horizontal, Spacing.md)

                // Scrollable content
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        // Stats cards
                        HStack(spacing: Spacing.sm) {
                            // Total cost card
                            TotalCostVehicleView(store: store.scope(state: \.totalCostVehicle, action: \.totalCostVehicle))

                            // Alerts card
                            WarningVehicleView(store: store.scope(state: \.warningVehicle, action: \.warningVehicle))
                        }

                        // Monthly expenses chart
                        VehicleMonthlyExpensesView(store: store.scope(state: \.vehicleMonthlyExpenses, action: \.vehicleMonthlyExpenses))

                        // Divider
                        Divider()

                        // Titre de la section documents
                        HStack {
                            Image(systemName: "folder.fill")
                                .font(Typography.title3)
                                .foregroundColor(ColorTokens.textPrimary)

                            Text("\(store.currentVehicleDocuments.count) documents")
                                .font(Typography.title2.weight(.bold))
                                .foregroundColor(ColorTokens.textPrimary)
                        }

                        // Documents list
                        if store.currentVehicleDocuments.isEmpty {
                            emptyDocumentsView
                        } else {
                            documentsListView
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
                .scrollBounceBehavior(.basedOnSize)
            }

            // Floating action button
            Button {
                store.send(.showAddDocument)
            } label: {
                Image(systemName: "plus")
                    .font(Typography.title2.weight(.semibold))
                    .foregroundColor(ColorTokens.onActionPrimary)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(ColorTokens.actionPrimary)
                    )
                    .shadow(color: ColorTokens.shadow, radius: 8, x: 0, y: 4)
            }
            .padding(Spacing.lg)
        }
    }

    // MARK: - Empty Documents View
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

    // MARK: - Documents List View
    private var documentsListView: some View {
        LazyVStack(spacing: Spacing.sm) {
            ForEach(store.currentVehicleDocuments.groupedByMonth(), id: \.title) { section in
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

    // MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .lastTextBaseline) {
                Menu {
                    Button(action: {
                        store.send(.presentVehiclesListView) //TODO: refactor this with a test and a view button
                    }) {
                        Label("Changer de véhicule",
                              systemImage: "arrow.triangle.2.circlepath")
                    }
                    Button(action: {
                        if let vehicle = store.currentVehicle {
                            store.send(.showVehicleDetail(vehicle))
                        }
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
                        HStack(spacing: Spacing.xxs) {
                            Text(store.currentVehicle?.isPrimary == true ? "Véhicule principal" : "Véhicule secondaire")
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .rotationEffect(.degrees(90))
                        }
                        .font(Typography.footnote)
                        .foregroundColor(ColorTokens.textSecondary)

                        if let vehicle = store.currentVehicle {
                            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                                Text(vehicle.brand.uppercased())
                                    .font(Typography.largeTitle)
                                    .fontWeight(.black)
                                    .kerning(-1)
                                    .foregroundColor(ColorTokens.textPrimary)

                                Text(vehicle.model)
                                    .font(Typography.title3)
                                    .foregroundColor(ColorTokens.textPrimary)
                            }
                        }
                    }
                }
                .menuActionDismissBehavior(.automatic)

                Spacer()
            }
        }
        .padding(.top, Spacing.xs)
    }

    // MARK: - Document Display Methods
    private func eventElement(of document: Document) -> some View {
        DocumentCard(document: document) {
            store.send(.showDocumentDetail(document))
        }
    }

}

#Preview() {
    @Dependency(\.uuid) var uuid
    NavigationView {
        MainView(
            store: Store(
                initialState: MainStore.State(
                    selectedVehicle: Shared(value: .init(
                        id: uuid(),
                        brand: "Lexus",
                        model: "CT200H",
                        mileage: "120000",
                        registrationDate: Date(timeIntervalSince1970: 1322784000),
                        plate: "BZ-029-YV",
                        documents: [
                            .init(fileURL: "", name: "Vidange", date: .now, mileage: "100000", type: .entretien)
                        ]
                    ))
                ),
                reducer: { MainStore() }
            )
        )
    }
}
