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

    @Shared(.selectedCurrency) var currency: Currency
    @Shared(.selectedDistanceUnit) var distanceUnit: DistanceUnit

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.lg) {
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
                    FormField(titleLabel: "document_form_name_title", infoLabel: "document_form_name_info") {
                        TextField("document_form_name_placeholder", text: $store.name)
                            .formFieldLeadingTitle()
                    }
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
                    FormField(titleLabel: "document_form_additional_info", infoLabel: "document_form_mileage_info") {
                        HStack(spacing: 12) {
                            Text("document_form_mileage_label")
                                .formFieldLeadingTitle()

                            Spacer()

                            TextField("document_form_amount_placeholder", text: $store.mileage)
                                .formFieldLeadingTitle()
                                .keyboardType(.numbersAndPunctuation)
                                .multilineTextAlignment(.trailing)

                            Text(distanceUnit.symbol)
                                .formFieldLeadingTitle()
                        }
                    }
                    FormField(infoLabel: "document_form_amount_info") {
                        HStack(spacing: 12) {
                            Text("document_form_amount_label")
                                .formFieldLeadingTitle()

                            Spacer()

                            TextField("document_form_amount_placeholder", text: $store.amount)
                                .formFieldLeadingTitle()
                                .keyboardType(.numbersAndPunctuation)
                                .multilineTextAlignment(.trailing)

                            Text(currency.symbol)
                                .formFieldLeadingTitle()
                        }
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, Spacing.screenMargin)
            }
            .scrollBounceBehavior(.basedOnSize)
            .safeAreaInset(edge: .bottom, spacing: 24) {
                VStack(spacing: 0) {
                    Divider()
                    
                    VStack(spacing: Spacing.md) {
                        
                        PrimaryButton("all_save", action: {
                            store.send(.save)
                        })

                        TertiaryButton("all_cancel", action: {
                            store.send(.cancel)
                        })
                    }
                    .padding(16)
                }
                .background(Color(.tertiarySystemBackground))
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
