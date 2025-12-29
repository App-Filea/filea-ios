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
        ZStack {
            ColorTokens.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Type Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Type de document")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        
                        Button(action: {}) {
                            HStack {
                                Text("Type")
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Picker("Type", selection: $store.type) {
                                    ForEach(DocumentType.allCases) { type in
                                        Text(type.displayName)
                                            .tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                            .padding(16)
                        }
                        .fieldCard()
                    }
                    
                    // Name Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOM DU DOCUMENT")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        VStack(spacing: 0) {
                            TextField("placeholder", text: $store.name)
                                .font(.system(size: 17))
                                .padding(16)
                                .multilineTextAlignment(.leading)
                            
                            HelpText(text: "Nom descriptif du document")
                        }
                        .fieldCard()
                    }
                    
                                        // Date Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DATE DU DOCUMENT")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        VStack(spacing: 0) {
                            HStack {
                                Text("Date")
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                DatePicker("", selection: $store.date, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                            }
                            .padding(16)
                            
                            HelpText(text: "Date d'émission du document")
                        }
                        .fieldCard()
                    }
                                        // Optional Fields
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Informations additionnelles")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                Text("Kilométrage")
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                TextField("0.00", text: $store.mileage)
                                    .font(.system(size: 17))
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                
                                Text("KM")
                                    .font(.system(size: 17))
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            
                            HelpText(text: "Kilométrage au moment du document")
                        }
                        .fieldCard()
                    }
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Text("Montant")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            TextField("0.00", text: $store.amount)
                                .font(.system(size: 17))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            
                            Text("€")
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        
                        HelpText(text: "Montant TTC du document")
                    }
                    .fieldCard()
                    
//                    VStack {
//                        Button(action: {}) {
//                            Text("Annuler")
//                                .font(.system(size: 17, weight: .semibold))
//                                .foregroundColor(.black)
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 16)
//                                .cornerRadius(14)
//                        }
//                        
//                        Button(action: {}) {
//                            Text("Enregistrer")
//                                .font(.system(size: 17, weight: .semibold))
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 16)
//                                .background(.black)
//                                .cornerRadius(14)
//                        }
//                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, Spacing.screenMargin)
            }
            .scrollBounceBehavior(.basedOnSize)
            .safeAreaInset(edge: .bottom, spacing: 24) {
                VStack {
                    Divider()
                    
                    VStack(spacing: 0) {
                        Button(action: { store.send(.cancel) }) {
                            Text("Annuler")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .cornerRadius(14)
                        }
                        
                        Button(action: { store.send(.save) }) {
                            Text("Enregistrer")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.black)
                                .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .background(ColorTokens.background)
            }
        }
        .navigationTitle("Modifier le document")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        EditDocumentView(store: Store(initialState: EditDocumentStore.State(
            vehicleId: UUID(),
            document: Document(
                fileURL: "/path/to/document.jpg",
                name: "Test Document",
                date: Date(),
                mileage: "50000",
                type: .maintenance
            )
        )) {
            EditDocumentStore()
        })
    }
}

// MARK: - Form Section Component
struct FormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            content
                .fieldCard()
        }
    }
}

extension View {
    func fieldCard() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.separator), lineWidth: 1)
            )
    }
}

// MARK: - Picker Row Component
struct PickerRow: View {
    let label: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Spacer()
                
                //                Picker("Type", selection: .constant(.repair)) {
                //                    ForEach(DocumentType.allCases) { type in
                //                        Text(type.displayName)
                //                            .tag(type)
                //                    }
                //                }
                //                .pickerStyle(.menu)
                //                .labelsHidden()
            }
            .padding(16)
        }
    }
}

// MARK: - Help Text Component
struct HelpText: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(12)
        .padding(.horizontal, 4)
        .background(Color(.systemGray6))
    }
}
