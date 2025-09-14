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
                    List(store.vehicle.documents) { document in
                        Button(action: {
                            store.send(.showDocumentDetail(document.id))
                        }) {
                            HStack {
                                Image(systemName: "doc.fill")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text("Document")
                                        .font(.headline)
                                    Text(document.createdAt, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 4)
                    }
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
            .navigationTitle("Vehicle Details")
            .navigationBarTitleDisplayMode(.inline)
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
        .sheet(item: $store.scope(state: \.addDocument, action: \.addDocument)) { addDocumentStore in
            AddDocumentView(store: addDocumentStore)
        }
        .sheet(item: $store.scope(state: \.documentDetail, action: \.documentDetail)) { documentDetailStore in
            DocumentDetailView(store: documentDetailStore)
        }
        .sheet(item: $store.scope(state: \.editVehicle, action: \.editVehicle)) { editVehicleStore in
            EditVehicleView(store: editVehicleStore)
        }
    }
}

#Preview {
    VehicleView(store: Store(initialState: VehicleStore.State(vehicle: Vehicle(name: "Test Car", currentMileage: "50000", registrationDate: "2020-01-01", licensePlate: "ABC-123"))) {
        VehicleStore()
    })
}