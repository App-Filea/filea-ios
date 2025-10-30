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
                mainContentView
        }
        .onAppear {
            // Calculate statistics when the view appears
            store.send(.setupVehicleStatistics)
        }
        .navigationBarBackButtonHidden()
        .alert($store.scope(state: \.deleteAlert, action: \.deleteAlert))
        .fullScreenCover(item: $store.scope(state: \.vehiclesList, action: \.vehiclesList)) { store in
            VehiclesListModalView(store: store)
        }
        .fullScreenCover(item: $store.scope(state: \.addDocument, action: \.addDocument)) { store in
            AddDocumentMultiStepView(store: store)
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
                        statsCardsView

                        // Monthly expenses chart
                        monthlyExpensesChartView

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
                        store.send(.showVehiclesList)
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
                        store.send(.deleteVehicleTapped)
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

    // MARK: - Stats Cards
    private var statsCardsView: some View {
        HStack(spacing: Spacing.sm) {
            // Total cost card
            StatCard(
                title: "Coût total",
                value: store.currentVehicleTotalCost.asCurrencyStringAdaptive,
                subtitle: "Sur l'année en cours",
                icon: nil,
                accentColor: ColorTokens.actionPrimary,
                action: nil
            )

            // Alerts card
            StatCard(
                title: "Alertes",
                value: "\(store.currentVehicleIncompleteDocumentsCount)",
                subtitle: store.currentVehicleIncompleteDocumentsCount == 0
                    ? "Tout est en ordre"
                    : "Nécessite votre attention",
                icon: store.currentVehicleIncompleteDocumentsCount == 0
                    ? "checkmark.circle.fill"
                    : "exclamationmark.triangle.fill",
                accentColor: store.currentVehicleIncompleteDocumentsCount == 0
                    ? ColorTokens.success
                    : ColorTokens.warning,
                action: nil
            )
        }
    }

    // MARK: - Monthly Expenses Chart
    private var monthlyExpensesChartView: some View {
        MonthlyExpenseChart(
            expenses: store.currentVehicleMonthlyExpenses,
            year: Calendar.current.component(.year, from: Date()),
            accentColor: ColorTokens.actionPrimary
        )
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
                    )),
                    currentVehicleTotalCost: 1234,
                    currentVehicleMonthlyExpenses: [
                        MonthlyExpense(month: 1, amount: 540),   // Janvier
                        MonthlyExpense(month: 2, amount: 0),     // Février (vide)
                        MonthlyExpense(month: 3, amount: 80),    // Mars
                        MonthlyExpense(month: 4, amount: 0),     // Avril (vide)
                        MonthlyExpense(month: 5, amount: 350),   // Mai
                        MonthlyExpense(month: 6, amount: 0),     // Juin (vide)
                        MonthlyExpense(month: 7, amount: 180),   // Juillet
                        MonthlyExpense(month: 8, amount: 95),    // Août
                        MonthlyExpense(month: 9, amount: 0),     // Septembre (vide)
                        MonthlyExpense(month: 10, amount: 400),  // Octobre
                        MonthlyExpense(month: 11, amount: 0),    // Novembre (vide)
                        MonthlyExpense(month: 12, amount: 0)     // Décembre (vide)
                    ]
                ),
                reducer: { MainStore() }
            )
        )
    }
}
