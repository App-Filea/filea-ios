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
    @State private var activeTab: VehicleSegmentedTab = .historique
    
    let circleSize: CGFloat = 12
    let lineWidth: CGFloat = 2
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(store.vehicle.brand.uppercased())
                                .bodyXLargeBlack()
                            Text(store.vehicle.model)
                                .bodyDefaultLight()
                            Spacer()
                            
                            Text(store.vehicle.plate)
                                .bodyXSmallRegular()
                                .foregroundStyle(.secondary)
                                .padding(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(.secondary, lineWidth: 0.5)
                                )
                                .alignmentGuide(.firstTextBaseline) { d in
                                    d[.bottom]
                                }
                        }
                        HStack(spacing: 4) {
                            Text("2011"/*vehicle.registrationDate*/)
                            Text("-")
                            Text("\(store.vehicle.mileage)km")
                            Spacer()
                        }
                        .bodyDefaultLight()
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Button(action: { store.send(.showEditVehicle) }) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "pencil.circle")
                                        .font(.largeTitle)
                                    Spacer()
                                    Text("Modifier")
                                        .bodyDefaultSemibold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .foregroundStyle(Color.blue)
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .padding(12)
                            .background(Color.blue.quinary)
                            .cornerRadius(8)
                            
                            Button(action: { store.send(.deleteVehicle) }) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "trash.circle")
                                        .font(.largeTitle)
                                    Spacer()
                                    Text("Supprimer")
                                        .bodyDefaultSemibold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .foregroundStyle(Color.red)
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .padding(12)
                            .background(Color.red.quinary)
                            .cornerRadius(8)
                            
                            Button(action: { store.send(.showAddDocument) }) {
                                VStack(alignment: .leading) {
                                    Image(systemName: "plus.circle")
                                        .font(.largeTitle)
                                    Spacer()
                                    Text("Nouveau document")
                                        .bodyDefaultSemibold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            .foregroundStyle(Color.black.secondary)
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .padding(12)
                            .background(Color.gray.quinary)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                VehicleSegmentedControl(
                    tabs: VehicleSegmentedTab.allCases,
                    activeTab: $activeTab,
                    activeTint: .black,
                    inActiveTint: .gray
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
                            .foregroundStyle(.tint)
                        Text("No documents yet")
                            .font(.headline)
                        Text("Add documents by taking photos")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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
    }
    
    private func eventElement(of document: Document) -> some View {
        HStack(spacing: 20) {
            Image(systemName: document.type.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(document.name)
                        .bodyDefaultSemibold()
                        .foregroundStyle(Color.black)
                    Circle().fill(.secondary)
                        .frame(width: 6, height: 6)
                    Text(formattedDate(document.date))
                        .bodyDefaultSemibold()
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("200 €")
                        .bodySmallRegular()
                        .foregroundStyle(.secondary)
                    Circle().fill(.secondary)
                        .frame(width: 6, height: 6)
                    Text(document.type.displayName)
                        .bodySmallRegular()
                        .foregroundStyle(.secondary)
                }
                HStack(alignment: .center) {
                    Image(systemName: "gauge.open.with.lines.needle.33percent")
                        .bodySmallRegular()
                        .foregroundStyle(.secondary)
                    Text("\(document.mileage) km")
                        .bodySmallRegular()
                        .foregroundStyle(.secondary)
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
                        .foregroundStyle(Color.black)
                    Circle().fill(.secondary)
                        .frame(width: 6, height: 6)
                    Text(formattedDate(document.date))
                        .bodyDefaultSemibold()
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("200 €")
                        .bodySmallRegular()
                        .foregroundStyle(.secondary)
                    Circle().fill(.secondary)
                        .frame(width: 6, height: 6)
                    Text(document.type.displayName)
                        .bodySmallRegular()
                        .foregroundStyle(.secondary)
                }
                Text(document.fileType)
                    .bodyXSmallSemibold()
                    .foregroundStyle(.black.opacity(0.6))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(
                        Rectangle()
                            .fill(Color.gray.opacity(0.3)) // couleur du rectangle
                            .cornerRadius(16)
                    )            }
            Spacer()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMM"
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

#Preview {
    NavigationView {
        VehicleView(store:
                        Store(initialState:
                                VehicleStore.State(vehicle:
                                                    Vehicle(brand: "Lexus",
                                                            model: "CT200h",
                                                            mileage: "122000",
                                                            registrationDate: "2020-01-01",
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
