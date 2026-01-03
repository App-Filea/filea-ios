//
//  EditVehicleView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct EditVehicleView: View {
    @Bindable var store: StoreOf<EditVehicleStore>

    @Shared(.selectedDistanceUnit) var distanceUnit: DistanceUnit

    var body: some View {
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
        .navigationTitle("edit_vehicle_title")
        .navigationBarTitleDisplayMode(.inline)
    }
}



#Preview {
    @Shared(.selectedVehicle) var selectedVehicle: Vehicle = .init(id: "uuid", type: .car, brand: "Brand", model: "Model", mileage: "10000", registrationDate: Date.now, plate: "10-100-10", isPrimary: true, documents: [])
    NavigationView {
        EditVehicleView(store: Store(initialState: EditVehicleStore.State()) {
            EditVehicleStore()
        })
    }
}
