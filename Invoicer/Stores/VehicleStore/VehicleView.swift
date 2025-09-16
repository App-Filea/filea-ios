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
    let gap: CGFloat = 40          // distance voulue entre les points
        let circleSize: CGFloat = 12
        let lineWidth: CGFloat = 2
        let leftColumnWidth: CGFloat = 40
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Vehicle info section
                VStack(alignment: .leading, spacing: 8) {
                    Text(store.vehicle.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("License Plate:")
                            .fontWeight(.medium)
                        Text(store.vehicle.licensePlate)
                    }
                    
                    HStack {
                        Text("Mileage:")
                            .fontWeight(.medium)
                        Text(store.vehicle.currentMileage)
                    }
                    
                    HStack {
                        Text("Registration Date:")
                            .fontWeight(.medium)
                        Text(store.vehicle.registrationDate)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Documents section
                if store.vehicle.documents.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.fill")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                        Text("No documents yet")
                            .font(.headline)
                        Text("Add documents by taking photos")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(store.vehicle.documents.enumerated()), id: \.element.id) { index, document in
                                Button(action: {
                                    store.send(.showDocumentDetail(document.id))
                                }) {
                                    HStack(alignment: .center, spacing: 12) {
                                        // Timeline column
                                        VStack(spacing: 0) {
                                            // Top half (except for first)
                                            if index != 0 {
                                                Rectangle()
                                                    .fill(Color.gray)
                                                    .frame(width: lineWidth, height: gap / 2)
                                                    .fixedSize()
                                            } else {
                                                Spacer().frame(height: gap / 2)
                                            }

                                            // Circle
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: circleSize, height: circleSize)

                                            // Bottom half (except for last)
                                            if index != store.vehicle.documents.count - 1 {
                                                Rectangle()
                                                    .fill(Color.gray)
                                                    .frame(width: lineWidth, height: gap / 2)
                                                    .fixedSize()
                                            } else {
                                                Spacer().frame(height: gap / 2)
                                            }
                                        }
                                        .frame(width: leftColumnWidth, alignment: .top)
                                        .padding(.top, 0)

                                        // Document content
                                        HStack {
                                            Image(systemName: getDocumentIcon(for: document.fileURL))
                                                .foregroundColor(getDocumentColor(for: document.type))
                                                .font(.title2)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(document.name)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)
                                                
                                                HStack(spacing: 8) {
                                                    Text(document.type.displayName)
                                                        .font(.caption)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 2)
                                                        .background(getDocumentColor(for: document.type).opacity(0.2))
                                                        .foregroundColor(getDocumentColor(for: document.type))
                                                        .cornerRadius(8)
                                                    
                                                    Text(document.date, style: .date)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    
                                                    if !document.mileage.isEmpty {
                                                        Text("\(document.mileage) km")
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 8)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
//                        ScrollView {
//                            VStack(spacing: 0) {
//                            ForEach(store.vehicle.documents) { document in
//                                Button(action: {
//                                    store.send(.showDocumentDetail(document.id))
//                                }) {
//                                    HStack {
//                                        Color.black
//                                            .frame(maxWidth: 2, maxHeight: .infinity)
//                                        
//                                        Image(systemName: "doc.fill")
//                                            .foregroundColor(.blue)
//                                        VStack(alignment: .leading) {
//                                            Text("Document")
//                                                .font(.headline)
//                                            Text(document.createdAt, style: .date)
//                                                .font(.caption)
//                                                .foregroundColor(.secondary)
//                                        }
//                                        Spacer()
//                                        Image(systemName: "chevron.right")
//                                            .foregroundColor(.gray)
//                                            .font(.caption)
//                                    }
//                                }
////                                .buttonStyle(PlainButtonStyle())
//                            }
//                        }
//                    }
//                    List(store.vehicle.documents) { document in
//                        Button(action: {
//                            store.send(.showDocumentDetail(document.id))
//                        }) {
//                            HStack {
//                                Image(systemName: "doc.fill")
//                                    .foregroundColor(.blue)
//                                VStack(alignment: .leading) {
//                                    Text("Document")
//                                        .font(.headline)
//                                    Text(document.createdAt, style: .date)
//                                        .font(.caption)
//                                        .foregroundColor(.secondary)
//                                }
//                                Spacer()
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(.gray)
//                                    .font(.caption)
//                            }
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        .padding(.vertical, 4)
//                    }
                }
                
                Spacer()
                
                Button(action: {
                    store.send(.showAddDocument)
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Add Document")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .padding()
//            .navigationTitle("Vehicle Details")
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        store.send(.goBack)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button("Edit") {
                            store.send(.showEditVehicle)
                        }
                        
                        Button("Delete", role: .destructive) {
                            store.send(.deleteVehicle)
                        }
                    }
                }
            }
            .onAppear {
                store.send(.loadVehicleData)
            }
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
}

#Preview {
    VehicleView(store:
                    Store(initialState:
                            VehicleStore.State(vehicle:
                                                Vehicle(name: "Test Car",
                                                        currentMileage: "50000",
                                                        registrationDate: "2020-01-01",
                                                        licensePlate: "ABC-123",
                                                        documents: [
                                                            .init(fileURL: "/path/to/document1.jpg", name: "Carte grise", date: Date(), mileage: "45000", type: .carteGrise),
                                                            .init(fileURL: "/path/to/document2.pdf", name: "Facture révision", date: Date(), mileage: "50000", type: .facture)
                                                        ]))) {
        VehicleStore()
    })
}
