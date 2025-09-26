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
    let circleSize: CGFloat = 12
    let lineWidth: CGFloat = 2
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 16) {
                // Vehicle info section
                VStack(alignment: .leading, spacing: 4) {
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text(store.vehicle.brand.uppercased())
                            .bodyXLargeBlack()
                        Text(store.vehicle.model)
                            .bodyDefaultLight()
                        Spacer()
                        
                        Text(store.vehicle.plate)
                            .bodySmallRegular()
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
                    HStack {
                        Button(action: { store.send(.showEditVehicle) }) {
                            Label("Modifier", systemImage: "pencil")
                        }
                        .foregroundStyle(Color.blue)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.blue.quinary)
                        .cornerRadius(8)
                        
                        Spacer()
                        Button(role: .destructive, action: { store.send(.deleteVehicle) }) {
                            Label("Supprimer", systemImage: "trash")
                        }
                        .foregroundStyle(Color.red)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.red.quinary)
                        .cornerRadius(8)
                    }
                    
                    Button(role: .destructive, action: { store.send(.showAddDocument) }) {
                        Label("Ajouter un nouveau document", systemImage: "plus.circle")
                    }
                    .foregroundStyle(Color.black.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.gray.quinary)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                
                Divider()
                
                // Documents section
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
                            Text("\(store.vehicle.documents.count) documents")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 8)
                            ForEach(store.vehicle.documents, id: \.date) { document in
                                HStack(alignment: .top, spacing: 16) {
                                    // timeline point
                                    VStack(spacing: 0) {
                                        Circle()
                                            .fill(Color.clear)
                                            .frame(width: 16, height: 16)
                                            .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                        
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 2)
                                            .frame(maxHeight: .infinity)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(document.type.displayName)
                                                .font(.caption2)
                                                .padding(4)
                                                .background(getDocumentColor(for: document.type))
                                                .clipShape(Capsule())
                                            Image(systemName: getDocumentIcon(for: document.fileURL))
                                                .font(.caption2)
                                                .padding(6)
                                                .background(getDocumentColor(for: document.type))
                                                .clipShape(Circle())
                                            Spacer()
                                        }
                                        Text(document.name)
                                            .bodyDefaultSemibold()
                                            .foregroundStyle(.primary)
                                        HStack {
                                            Text("\(document.mileage) KM")
                                                .bodySmallRegular()
                                                .foregroundStyle(.secondary)
                                            Spacer()
                                            // Affichage formaté de la date
                                            Text(formattedDate(document.date))
                                                .bodySmallRegular()
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(10)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(12)
                                    .padding(.vertical, 8)
                                    //                                .shadow(radius: 7, x: 0, y: 6)
                                    .shadow( color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                    .onTapGesture {
                                        store.send(.showDocumentDetail(document.id))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
        }
        .onAppear {
            store.send(.loadVehicleData)
        }
    }
    
    private func getDocumentIcon(for filePath: String) -> String {
        let url = URL(fileURLWithPath: filePath)
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "pdf":
            return "doc.richtext.fill"
        case "jpg", "jpeg", "png", "gif", "bmp", "tiff", "heic", "heif":
            return "photo.fill"
        case "txt", "text", "md":
            return "doc.text.fill"
        case "json", "xml":
            return "doc.badge.gearshape.fill"
        case "csv":
            return "tablecells.fill"
        default:
            return "doc.fill"
        }
    }
    
    private func getDocumentColor(for type: DocumentType) -> Color {
        switch type {
        case .carteGrise:
            return .orange
        case .facture:
            return .blue
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func yearString(from dateString: String) -> String {
        // sécurité : si la string a au moins 4 caractères, on prend les 4 premiers
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
                                                                .init(fileURL: "/path/to/document2.pdf", name: "Facture révision", date: Date(), mileage: "50000", type: .facture),
                                                                .init(fileURL: "/path/to/document1.jpg", name: "Test 1", date: Date(timeIntervalSince1970: 999), mileage: "1", type: .facture),
                                                                .init(fileURL: "/path/to/document2.pdf", name: "Test 2", date: Date(timeIntervalSince1970: 99999), mileage: "50000", type: .facture),
                                                                .init(fileURL: "/path/to/document1.jpg", name: "Carte grise", date: Date(), mileage: "45000", type: .carteGrise),
                                                                .init(fileURL: "/path/to/document2.pdf", name: "Facture révision", date: Date(), mileage: "50000", type: .facture),
                                                                .init(fileURL: "/path/to/document1.jpg", name: "Test 1", date: Date(timeIntervalSince1970: 999), mileage: "1", type: .facture),
                                                                .init(fileURL: "/path/to/document2.pdf", name: "Test 2", date: Date(timeIntervalSince1970: 99999), mileage: "50000", type: .facture)
                                                            ]))) {
                                                                VehicleStore()
                                                            })
    }
}

struct RedMenu: MenuStyle {
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .foregroundColor(.red)
    }
}
