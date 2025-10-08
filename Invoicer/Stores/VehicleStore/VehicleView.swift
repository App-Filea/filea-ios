//
//  VehicleView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture
import QuickLook

struct VehicleView: View {
    @Bindable var store: StoreOf<VehicleStore>
    @State private var activeTab: VehicleSegmentedTab = .historique
    
    let circleSize: CGFloat = 12
    let lineWidth: CGFloat = 2
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("background")
                .ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
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
                            Text("\(store.vehicle.mileage)km")
                            Spacer()
                        }
                        .bodyDefaultLight()
                        .foregroundStyle(Color("onBackgroundSecondary"))
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 10) {
                        
                        HStack {
                            Button(action: { store.send(.showEditVehicle) }) {
                                HStack(alignment: .lastTextBaseline) {
                                    Image(systemName: "square.and.pencil")
                                        .frame(maxHeight: 20)
                                        .foregroundStyle(Color("onSurface"))
                                        .font(.title3)
                                        .padding(6)
                                        .cornerRadius(8)
                                    Spacer()
                                    Text("Modifier")
                                        .bodyDefaultSemibold()
                                        .foregroundStyle(Color("onSurface"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 24)
                                .background(Color("tertiary"))
                                .cornerRadius(8)
                            }
                            
                            Button(action: { store.send(.deleteVehicleTapped) }) {
                                HStack(alignment: .lastTextBaseline) {
                                    Image(systemName: "trash")
                                        .frame(maxHeight: 20)
                                        .foregroundStyle(Color("onErrorContainer"))
                                        .font(.title3)
                                        .padding(6)
                                        .cornerRadius(8)
                                    Spacer()
                                    Text("Supprimer")
                                        .bodyDefaultSemibold()
                                        .foregroundStyle(Color("onErrorContainer"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 24)
                                .background(Color("errorContainer"))
                                .cornerRadius(8)
                            }
                        }
                        
                        Button(action: { store.send(.showAddDocument) }) {
                            HStack(alignment: .firstTextBaseline) {
                                Spacer()
                                Image(systemName: "plus")
                                    .foregroundStyle(Color("onPrimary"))
                                    .font(.title3)
                                    .padding(6)
                                    .cornerRadius(8)
                                Text("Nouveau document")
                                    .bodyDefaultSemibold()
                                    .foregroundStyle(Color("onPrimary"))
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 24)
                            .background(Color("primary"))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                VehicleSegmentedControl(
                    tabs: VehicleSegmentedTab.allCases,
                    activeTab: $activeTab,
                    activeTint: Color("primary"),
                    inActiveTint: .onDisabled
                )
                .padding(.top, 16)
                Divider()
                    .padding(.top, 3)
                    .padding(.bottom, 16)
                
                if store.vehicle.documents.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "doc.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color("onSurfaceVariant"))
                        Text("No documents yet")
                            .font(.headline)
                            .foregroundStyle(Color("onBackground"))
                        Text("Add documents by taking photos")
                            .font(.subheadline)
                            .foregroundStyle(Color("onBackgroundSecondary"))
                        Spacer()
                    }
                    .padding()
                } else {
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(store.vehicle.documents.groupedByMonth(), id: \.title) { section in
                                VStack(alignment: .leading, spacing: 24) {
                                    Text(section.title)
                                        .titleGroup()
                                        .foregroundStyle(.secondary)
                                    
                                    ForEach(section.items) { document in
                                        switch activeTab {
                                        case .historique: eventElement(of: document)
                                        case .documents: documentElement(of: document)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .onAppear {
            store.send(.loadVehicleData)
        }
        .alert($store.scope(state: \.deleteAlert, action: \.deleteAlert))
    }
    
    private func eventElement(of document: Document) -> some View {
        HStack(spacing: 20) {
            Image(systemName: document.type.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(Color("onSurfaceVariant"))
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(document.name)
                        .bodyDefaultSemibold()
                        .foregroundStyle(Color("onSurface"))
                    Circle()
                        .fill(Color("onSurfaceVariant"))
                        .frame(width: 6, height: 6)
                    Text(formattedDate(document.date))
                        .bodyDefaultSemibold()
                        .foregroundStyle(Color("onSurfaceVariant"))
                }
                HStack {
                    Text("200 €")
                        .bodySmallRegular()
                        .foregroundStyle(Color("onSurfaceVariant"))
                    Circle().fill(.secondary)
                        .frame(width: 6, height: 6)
                    Text(document.type.displayName)
                        .bodySmallRegular()
                        .foregroundStyle(Color("onSurfaceVariant"))
                }
                HStack(alignment: .center) {
                    Image(systemName: "gauge.open.with.lines.needle.33percent")
                        .bodySmallRegular()
                        .foregroundStyle(Color("onSurfaceVariant"))
                    Text("\(document.mileage) km")
                        .bodySmallRegular()
                        .foregroundStyle(Color("onSurfaceVariant"))
                }
            }
            Spacer()
        }
        .onTapGesture {
            store.send(.showDocumentDetail(document.id))
        }
    }
    
    private func documentElement(of document: Document) -> some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(document.name)
                        .bodyDefaultSemibold()
                        .foregroundStyle(Color("onSurface"))
                    Circle()
                        .fill(Color("onSurfaceVariant"))
                        .frame(width: 6, height: 6)
                    Text(formattedDate(document.date))
                        .bodyDefaultSemibold()
                        .foregroundStyle(Color("onSurfaceVariant"))
                }
                HStack {
                    Text("200 €")
                        .bodySmallRegular()
                        .foregroundStyle(Color("onSurfaceVariant"))
                    Circle().fill(.secondary)
                        .frame(width: 6, height: 6)
                    Text(document.type.displayName)
                        .bodySmallRegular()
                        .foregroundStyle(Color("onSurfaceVariant"))
                }
                Text(document.fileType)
                    .bodyXSmallSemibold()
                    .foregroundStyle(Color("onTertiary"))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(
                        Rectangle()
                            .fill(Color("tertiary")) // couleur du rectangle
                            .cornerRadius(16)
                    )
            }
            Spacer()

            DocumentThumbnailView(fileURL: document.fileURL)
                .frame(width: 60, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func formattedDate(_ date: Date, isOnlyYear: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = isOnlyYear ? "yyyy" : "d MMM"
        return formatter.string(from: date)
    }
    
    func yearString(from dateString: String) -> String {
        String(dateString.prefix(4))
    }
    
    
    @ViewBuilder
    func infoCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(Color.gray)
            Text(value)
                .font(.system(size: 16, weight: .bold))
        }
        .gridCellAnchor(.leading)
        .padding(.horizontal, 8)
    }
    
}

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
                            .foregroundStyle(.secondary)
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
