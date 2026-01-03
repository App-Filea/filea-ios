//
//  AddVehicleView.swift
//  Invoicer
//
//  Created by Claude Code on 11/10/2025.
//

import SwiftUI
import ComposableArchitecture

struct AddVehicleView: View {
    @Bindable var store: StoreOf<AddVehicleStore>

    @Shared(.selectedDistanceUnit) var distanceUnit: DistanceUnit

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        FormField(titleLabel: "vehicle_form_type_title") {
                            HStack {
                                Text("vehicle_form_type_label")
                                    .formFieldLeadingTitle()

                                Spacer()

                                Picker("vehicle_form_type_label", selection: $store.type) {
                                    ForEach(VehicleType.allCases) { type in
                                        Text(type.displayName)
                                            .tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                        }
                        
                        FormField(titleLabel: "vehicle_form_status_title") {
                            HStack {
                                Text("vehicle_form_status_label")
                                    .formFieldLeadingTitle()

                                Spacer()

                                Picker("vehicle_form_status_label", selection: $store.isPrimary) {
                                    Text("vehicle_form_status_primary").tag(true)
                                    Text("vehicle_form_status_secondary").tag(false)
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                        }
                        
                        FormField(titleLabel: "vehicle_form_brand_title",
                                  infoLabel: "vehicle_form_brand_info",
                                  isError: store.validationErrors.contains(.brandEmpty)) {
                            TextField("vehicle_form_brand_placeholder", text: $store.brand)
                                .formFieldLeadingTitle()
                                .multilineTextAlignment(.leading)
                                .autocapitalization(.allCharacters)
                                .submitLabel(.done)
                        }
                        
                        FormField(titleLabel: "vehicle_form_model_title",
                                  infoLabel: "vehicle_form_model_info",
                                  isError: store.validationErrors.contains(.modelEmpty)) {
                            TextField("vehicle_form_model_placeholder", text: $store.model)
                                .formFieldLeadingTitle()
                                .multilineTextAlignment(.leading)
                                .autocapitalization(.allCharacters)
                                .submitLabel(.done)
                        }
                        
                        FormField(titleLabel: "vehicle_form_plate_title",
                                  infoLabel: "vehicle_form_plate_info",
                                  isError: store.validationErrors.contains(.plateEmpty)) {
                            TextField("vehicle_form_plate_placeholder", text: $store.plate)
                                .formFieldLeadingTitle()
                                .multilineTextAlignment(.leading)
                                .autocapitalization(.allCharacters)
                                .submitLabel(.done)
                        }
                        
                        FormField(titleLabel: "vehicle_form_mileage_title", infoLabel: "vehicle_form_mileage_info") {
                            HStack(spacing: 12) {
                                Text("vehicle_form_mileage_title")
                                    .formFieldLeadingTitle()

                                Spacer()

                                TextField("vehicle_form_mileage_placeholder", text: $store.mileage)
                                    .formFieldLeadingTitle()
                                    .keyboardType(.numbersAndPunctuation)
                                    .multilineTextAlignment(.trailing)
                                    .submitLabel(.done)

                                Text(distanceUnit.symbol)
                                    .formFieldLeadingTitle()
                            }
                        }
                        
                        FormField(titleLabel: "vehicle_form_registration_date_title",
                                  infoLabel: "vehicle_form_registration_date_info") {
                            HStack {
                                Text("vehicle_form_date_label")
                                    .formFieldLeadingTitle()
                                
                                Spacer()
                                
                                DatePicker("", selection: $store.registrationDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                            }
                        }
                    }
                    .padding(Spacing.screenMargin)
                }
                .scrollBounceBehavior(.basedOnSize)
                .safeAreaInset(edge: .bottom, spacing: 80) {
                    VStack(spacing: 0) {
                        Divider()
                        
                        VStack(spacing: Spacing.md) {
                            PrimaryButton("all_save", action: {
                                store.send(.view(.saveButtonTapped))
                            })

                            TertiaryButton("all_cancel") {
                                store.send(.view(.cancelButtonTapped))
                            }
                        }
                        .padding(16)
                    }
                    .background(Color(.tertiarySystemBackground))
                }
            }
            .navigationTitle("add_vehicle_title")
            .navigationBarTitleDisplayMode(.inline)
            //        .sheet(item: $store.scope(state: \.scanStore, action: \.scanStore)) { scanStore in
            //            VehicleCardDocumentScanView(store: scanStore)
            //        }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

#Preview {
    NavigationStack {
        AddVehicleView(store: Store(initialState: AddVehicleStore.State()) {
            AddVehicleStore()
        })
    }
}
