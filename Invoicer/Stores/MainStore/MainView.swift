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
//        .onAppear {
//            if store.vehicles.isEmpty {
//                store.send(.loadVehicles)
//            }
//            store.send(.calculateTotalCost)
//        }
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
            VStack(spacing: 16) {
                // Header section - Not scrollable
                headerView
                    .padding(.horizontal, 16)

                // Scrollable content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Stats cards
                        statsCardsView

                        // Monthly expenses chart
                        monthlyExpensesChartView

                        // Divider
                        Divider()

                        // Titre de la section documents
                        HStack {
                            Image(systemName: "folder.fill")
                                .font(.title3)
                                .foregroundColor(Color(.label))

                            Text("\(store.currentVehicleDocuments.count) documents")
                                .font(.title2.weight(.bold))
                                .foregroundColor(Color(.label))
                        }

                        // Documents list
                        if store.currentVehicleDocuments.isEmpty {
                            emptyDocumentsView
                        } else {
                            documentsListView
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .scrollBounceBehavior(.basedOnSize)
            }

            // Floating action button
            Button {
                store.send(.showAddDocument)
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(.purple)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(24)
        }
    }

    // MARK: - Empty Documents View
    private var emptyDocumentsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.fill")
                .imageScale(.large)
                .foregroundStyle(Color(.secondaryLabel))
            Text("Aucun document")
                .font(.headline)
                .foregroundStyle(Color(.label))
            Text("Ajoutez des documents en prenant des photos")
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Documents List View
    private var documentsListView: some View {
        LazyVStack(spacing: 0) {
            ForEach(store.currentVehicleDocuments.groupedByMonth(), id: \.title) { section in
                VStack(alignment: .leading, spacing: 16) {
                    Text(section.title)
                        .titleGroup()
                        .foregroundStyle(Color(.secondaryLabel))

                    ForEach(section.items) { document in
                        eventElement(of: document)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
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
//                    Divider()
//                    Menu("Partager") {
//                        Button(action: {}) {
//                            Label("La propriété du véhicule",
//                                  systemImage: "square.and.arrow.up.badge.checkmark")
//                        }
//                        Button(action: {}) {
//                            Label("La lecture du véhicule",
//                                  systemImage: "square.and.arrow.up.badge.clock")
//                        }
//                    }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(store.currentVehicle?.isPrimary == true ? "Véhicule principal" : "Véhicule secondaire")
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .rotationEffect(.degrees(90))
                        }
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))

                        if let vehicle = store.currentVehicle {
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(vehicle.brand.uppercased())
                                    .font(.largeTitle)
                                    .fontWeight(.black)
                                    .kerning(-1)
                                    .foregroundColor(Color(.label))

                                Text(vehicle.model)
                                    .font(.title3)
                                    .foregroundColor(Color(.label))
                            }
                        }
                    }
                }
                .menuActionDismissBehavior(.automatic)
                
                Spacer()
//                Button {
//                    store.send(.showSettings)
//                } label: {
//                    Image(systemName: "gearshape")
//                        .font(.title)
//                        .foregroundColor(Color(.label))
//                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Stats Cards
    private var statsCardsView: some View {
        HStack(spacing: 12) {
            // Total cost card
            Color(.systemBackground)
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .cornerRadius(16)
                .overlay {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Coût total")
                                .font(.subheadline)
                                .foregroundStyle(Color(.label))
                            Spacer()
                        }
                        Spacer()
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(formatAmount(store.currentVehicleTotalCost))
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(Color(.label))
                            Text("€")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        Text("Sur l'année en cours")
                            .font(.caption)
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                }

            // Alerts card
            Color(.systemBackground)
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .cornerRadius(16)
                .overlay {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Alertes")
                                .font(.subheadline)
                                .foregroundStyle(Color(.label))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        Spacer()
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.yellow)

                            Text("0")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(Color(.label))
                        }
                        Text("Nécessite votre attention")
                            .font(.caption)
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                }
        }
    }

    // MARK: - Monthly Expenses Chart
    private var monthlyExpensesChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dépenses mensuelles")
                .font(.headline)
                .foregroundStyle(Color(.label))

            if store.currentVehicleMonthlyExpenses.isEmpty {
                emptyExpensesChart
            } else {
                expensesChart
            }

            Text("Dépenses mensuelles sur l'année \(Calendar.current.component(.year, from: Date()))")
                .font(.caption)
                .foregroundStyle(Color(.secondaryLabel))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - Empty Expenses Chart
    private var emptyExpensesChart: some View {
        Chart {
            ForEach(1...12, id: \.self) { month in
                RectangleMark(
                    x: .value("Mois", monthName(for: month)),
                    y: .value("Montant", 0),
                    height: 0.5
                )
                .foregroundStyle(Color(.tertiaryLabel))
            }
        }
        .frame(height: 120)
        .chartYScale(domain: 0...100)
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    if let monthName = value.as(String.self) {
                        let currentMonth = Calendar.current.component(.month, from: Date())
                        let isCurrentMonth = monthName == self.monthName(for: currentMonth)

                        Text(String(monthName.prefix(3)))
                            .font(isCurrentMonth ? .caption2.weight(.bold) : .caption2)
                            .foregroundStyle(isCurrentMonth ? Color(.label) : Color(.secondaryLabel))
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .accessibilityLabel("Graphique des dépenses mensuelles")
        .accessibilityValue("Aucune dépense enregistrée cette année")
    }

    // MARK: - Expenses Chart
    private var expensesChart: some View {
        Chart {
            ForEach(store.currentVehicleMonthlyExpenses) { expense in
                if expense.amount > 0 {
                    BarMark(
                        x: .value("Mois", expense.monthName),
                        yStart: .value("Start", 0),
                        yEnd: .value("Montant", expense.amount)
                    )
                    .foregroundStyle(expense.month == Calendar.current.component(.month, from: Date()) ? Color(.systemPurple) : Color(.systemPurple).opacity(0.5))
                    .clipShape(Capsule())
                } else {
                    RectangleMark(
                        x: .value("Mois", expense.monthName),
                        y: .value("Montant", 0),
                        height: 0.5
                    )
                    .foregroundStyle(Color(.tertiaryLabel))
                }
            }
        }
        .frame(height: 120)
        .chartYScale(domain: 0...max(store.currentVehicleMonthlyExpenses.map(\.amount).max() ?? 100, 100))
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    if let monthName = value.as(String.self) {
                        let currentMonth = Calendar.current.component(.month, from: Date())
                        let isCurrentMonth = store.currentVehicleMonthlyExpenses.first(where: { $0.monthName == monthName })?.month == currentMonth

                        Text(String(monthName.prefix(3)))
                            .font(isCurrentMonth ? .caption2.weight(.bold) : .caption2)
                            .foregroundStyle(isCurrentMonth ? Color(.label) : Color(.secondaryLabel))
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .accessibilityLabel("Graphique des dépenses mensuelles")
        .accessibilityValue(accessibilityExpensesDescription)
    }

    // MARK: - Accessibility
    private var accessibilityExpensesDescription: String {
        let totalExpenses = store.currentVehicleMonthlyExpenses.reduce(0) { $0 + $1.amount }
        let monthsWithExpenses = store.currentVehicleMonthlyExpenses.filter { $0.amount > 0 }.count

        if totalExpenses == 0 {
            return "Aucune dépense enregistrée cette année"
        }

        return "Total de \(formatAmount(totalExpenses)) euros sur \(monthsWithExpenses) mois"
    }

    // MARK: - Document Display Methods
    private func eventElement(of document: Document) -> some View {
        HStack(spacing: 12) {
            // Icon du type de document
            Image(systemName: document.type.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(Color(.secondaryLabel))

            // Informations du document
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(document.name)
                        .bodyDefaultSemibold()
                        .foregroundStyle(Color(.label))
                    Circle()
                        .fill(Color(.secondaryLabel))
                        .frame(width: 6, height: 6)
                    Text(formattedDate(document.date))
                        .bodyDefaultSemibold()
                        .foregroundStyle(Color(.secondaryLabel))
                }

                HStack {
                    if let amount = document.amount {
                        Text(formatCurrency(amount))
                            .bodySmallRegular()
                            .foregroundStyle(Color(.secondaryLabel))
                    } else {
                        Text("-- €")
                            .bodySmallRegular()
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    Circle().fill(Color(.secondaryLabel))
                        .frame(width: 6, height: 6)
                    Text(document.type.displayName)
                        .bodySmallRegular()
                        .foregroundStyle(Color(.secondaryLabel))
                }

                // Badge incomplet si pas de montant
                if document.amount == nil {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                        Text("Incomplet")
                            .font(.caption2.weight(.medium))
                    }
                    .foregroundStyle(.yellow)
                }

                HStack(alignment: .center) {
                    Image(systemName: "gauge.open.with.lines.needle.33percent")
                        .bodySmallRegular()
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("\(document.mileage) km")
                        .bodySmallRegular()
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }

            Spacer()

            // Thumbnail du document
            DocumentThumbnailView(fileURL: document.fileURL)
                .frame(width: 60, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            store.send(.showDocumentDetail(document))
        }
    }


    // MARK: - Helpers
    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "MMM"

        var components = DateComponents()
        components.month = month
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date).capitalized
        }
        return ""
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "0 €"
    }

    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}

// MARK: - Document Thumbnail View
struct DocumentThumbnailView: View {
    let fileURL: String
    @State private var thumbnail: UIImage?

    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "doc.fill")
                            .foregroundStyle(Color(.secondaryLabel))
                    )
            }
        }
        .task {
            await loadThumbnail()
        }
    }

    private nonisolated func loadThumbnail() async {
        let url = URL(fileURLWithPath: fileURL)
        let size = CGSize(width: 60, height: 80)
        let scale = await MainActor.run { UIScreen.main.scale }

        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: size,
            scale: scale,
            representationTypes: .thumbnail
        )

        let generator = QLThumbnailGenerator.shared

        do {
            let representation = try await generator.generateBestRepresentation(for: request)
            let thumbnailImage = representation.uiImage
            await MainActor.run { [thumbnailImage] in
                self.thumbnail = thumbnailImage
            }
        } catch {
            print("Failed to generate thumbnail: \(error)")
        }
    }
}

#Preview() {
    NavigationView {
        MainView(
            store: Store(
                initialState: MainStore.State(
                    selectedVehicle: Shared(value: .init(
                        brand: "Lexus",
                        model: "CT200H",
                        mileage: "120000",
                        registrationDate: Date(timeIntervalSince1970: 1322784000),
                        plate: "BZ-029-YV",
                        documents: []
                    )),
                    currentVehicleTotalCost: 1645,
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
