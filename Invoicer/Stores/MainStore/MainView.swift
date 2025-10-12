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
                emptyStateView
            } else {
                mainContentView
            }
        }
        .onAppear {
            if store.vehicles.isEmpty {
                store.send(.loadVehicles)
            }
        }
        .navigationBarBackButtonHidden()
        .alert($store.scope(state: \.deleteAlert, action: \.deleteAlert))
        .fullScreenCover(item: $store.scope(state: \.vehiclesList, action: \.vehiclesList)) { store in
            VehiclesListModalView(store: store)
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "car.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            Text("Aucun véhicule enregistré")
                .font(.headline)
                .foregroundStyle(Color(.label))
            Text("Commencez par ajouter votre premier véhicule")
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
            Spacer()

            Button("Ajouter un véhicule",
                   systemImage: "plus.circle.fill",
                   action: { store.send(.showAddVehicle) })
            .font(.body.weight(.semibold))
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .padding()
        }
        .padding()
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
                    Divider()
                    Menu("Partager") {
                        Button(action: {}) {
                            Label("La propriété du véhicule",
                                  systemImage: "square.and.arrow.up.badge.checkmark")
                        }
                        Button(action: {}) {
                            Label("La lecture du véhicule",
                                  systemImage: "square.and.arrow.up.badge.clock")
                        }
                    }
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
                Button {
                    store.send(.showSettings)
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title)
                        .foregroundColor(Color(.label))
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Stats Cards
    private var statsCardsView: some View {
        HStack(spacing: 12) {
            // Total cost card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Coût total")
                        .font(.subheadline)
                        .foregroundStyle(Color(.label))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color(.secondaryLabel))
                }

                Text("500 €")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Color(.label))

                Text("Sur l'année en cours")
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .padding(16)
            .frame(height: 140)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(16)

            // Alerts card
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

                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3)
                        .foregroundStyle(.yellow)

                    Text("2")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color(.label))
                }

                Text("Nécessite votre attention")
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .padding(16)
            .frame(height: 140)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }

    // MARK: - Monthly Expenses Chart
    private var monthlyExpensesChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dépenses mensuel")
                .font(.headline)
                .foregroundStyle(Color(.label))

            // Mock chart data
            Chart {
                ForEach(0..<12, id: \.self) { month in
                    LineMark(
                        x: .value("Month", month),
                        y: .value("Amount", Double.random(in: 50...150))
                    )
                    .foregroundStyle(.blue)
                }
            }
            .frame(height: 120)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)

            Text("Dépenses mensuel sur l'année 2025")
                .font(.caption)
                .foregroundStyle(Color(.secondaryLabel))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
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
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "0 €"
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
            .init(brand: "Lexus", model: "CT200H", mileage: "120000", registrationDate: Date(timeIntervalSince1970: 1322784000), plate: "BZ-029-YV", documents: [])
        ])) {
            MainStore()
        })
    }
}
