//
//  EditDocumentView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 16/09/2025.
//

import ComposableArchitecture
import SwiftUI

struct EditDocumentView: View {
    @Bindable var store: StoreOf<EditDocumentStore>
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations du document") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nom du document")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Nom du document", text: .init(
                            get: { store.name },
                            set: { store.send(.updateName($0)) }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        DatePicker("Date", selection: .init(
                            get: { store.date },
                            set: { store.send(.updateDate($0)) }
                        ), displayedComponents: .date)
                        .datePickerStyle(.compact)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kilométrage")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Kilométrage", text: .init(
                            get: { store.mileage },
                            set: { store.send(.updateMileage($0)) }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Type de document")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Picker("Type", selection: .init(
                            get: { store.type },
                            set: { store.send(.updateType($0)) }
                        )) {
                            ForEach(DocumentType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                if store.hasChanges {
                    Section {
                        Text("Des modifications ont été apportées")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Éditer le document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        store.send(.cancel)
                    }
                    .disabled(store.isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        store.send(.save)
                    }
                    .disabled(!store.canSave)
                    .fontWeight(.semibold)
                }
            }
            .disabled(store.isLoading)
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
    EditDocumentView(store: Store(initialState: EditDocumentStore.State(
        vehicleId: UUID(),
        document: Document(
            fileURL: "/path/to/document.jpg",
            name: "Test Document",
            date: Date(),
            mileage: "50000",
            type: .facture
        )
    )) {
        EditDocumentStore()
    })
}