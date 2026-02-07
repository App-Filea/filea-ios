//
//  EditDocumentView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 16/09/2025.
//

import ComposableArchitecture
import SwiftUI

struct EditDocumentView: View {
    enum FocusedField: Hashable {
        case mileage, amount, name
    }
    
    @Bindable var store: StoreOf<EditDocumentStore>
    @FocusState private var focusedField: FocusedField?
    
    @Shared(.selectedCurrency) var currency: Currency
    @Shared(.selectedDistanceUnit) var distanceUnit: DistanceUnit
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        FormField(titleLabel: "document_form_type_title") {
                            HStack {
                                Text("document_form_type_label")
                                    .formFieldLeadingTitle()
                                
                                Spacer()
                                
                                Picker("document_form_type_label", selection: $store.type) {
                                    ForEach(DocumentType.allCases) { type in
                                        Text(type.displayName)
                                            .tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                        }
                        .padding(.bottom, Spacing.lg)
                        
                        FormField(titleLabel: "document_form_date_title", infoLabel: "document_form_date_info") {
                            HStack {
                                Text("document_form_date_label")
                                    .formFieldLeadingTitle()
                                
                                Spacer()
                                
                                DatePicker("", selection: $store.date, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                            }
                        }
                        .padding(.bottom, Spacing.lg)
                        
                        
                        if store.type == .technicalInspection {
                            FormField(titleLabel: "document_form_expiration_date_title",
                                      infoLabel: "document_form_expiration_date_info") {
                                HStack {
                                    Text("document_form_expiration_date_label")
                                        .formFieldLeadingTitle()
                                    
                                    Spacer()
                                    
                                    DatePicker(
                                        "",
                                        selection: Binding(
                                            get: { store.expirationDate ?? Date() },
                                            set: { store.expirationDate = $0 }
                                        ),
                                        in: Date()...,
                                        displayedComponents: .date
                                    )
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                }
                            }
                                      .padding(.bottom, Spacing.lg)

                        }
                        
                        
                        FormField(titleLabel: "document_form_additional_info", infoLabel: "document_form_mileage_info") {
                            HStack(spacing: 12) {
                                TextField("document_form_amount_placeholder", text: $store.mileage)
                                    .formFieldLeadingTitle()
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.leading)
                                    .focused($focusedField, equals: .mileage)
                                
                                Text(distanceUnit.symbol)
                                    .formFieldLeadingTitle()
                            }
                        }
                        .id(FocusedField.mileage)
                        .padding(.bottom, Spacing.lg)
                        
                        
                        FormField(infoLabel: "document_form_amount_info") {
                            HStack(spacing: 12) {
                                TextField("document_form_amount_placeholder", text: $store.amount)
                                    .formFieldLeadingTitle()
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.leading)
                                    .focused($focusedField, equals: .amount)
                                
                                Text(currency.symbol)
                                    .formFieldLeadingTitle()
                            }
                        }
                        .id(FocusedField.amount)
                        .padding(.bottom, Spacing.lg)
                        
                        FormField(titleLabel: "document_form_name_title", infoLabel: "document_form_name_info") {
                            TextField("document_form_name_placeholder", text: $store.name)
                                .formFieldLeadingTitle()
                                .focused($focusedField, equals: .name)
                                .submitLabel(.done)
                                .onSubmit { focusedField = nil }
                        }
                        .id(FocusedField.name)
                        .padding(.bottom, Spacing.lg)
                    }
                    .padding(.horizontal, Spacing.screenMargin)
                    
                    VStack(spacing: 0) {
                        VStack(spacing: Spacing.md) {
                            
                            PrimaryButton("all_save", action: {
                                store.send(.save)
                            })
                            
                            TertiaryButton("all_cancel", action: {
                                store.send(.cancel)
                            })
                        }
                        .padding([.horizontal, .top], Spacing.screenMargin)
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .onChange(of: focusedField) { _, newValue in
                    guard let field = newValue else { return }
                    withAnimation {
                        proxy.scrollTo(field, anchor: .bottom)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    if focusedField == .mileage || focusedField == .amount {
                        Button("keyboard_next_button") {
                            switch focusedField {
                            case .mileage: focusedField = .amount
                            case .amount: focusedField = .name
                            default: break
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("edit_document_title")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    
    @Shared(.selectedCurrency) var currency = .dollar
    @Shared(.selectedDistanceUnit) var distanceUnit = .miles
    
    NavigationView {
        EditDocumentView(store: Store(initialState: EditDocumentStore.State(
            vehicleId: String(),
            document: Document(
                fileURL: "/path/to/document.jpg",
                name: "Test Document",
                date: Date(),
                mileage: "",
                type: .maintenance
            )
        )) {
            EditDocumentStore()
        })
    }
}
