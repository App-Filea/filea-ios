//
//  UnitAndMeasureSettingView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 03/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct UnitAndMeasureSettingView: View {
    @Bindable var store: StoreOf<UnitAndMeasureSettingStore>

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                FormField(titleLabel: "settings_currency_label") {
                    HStack {
                        Text("settings_currency_label")
                            .font(.system(size: 17))
                            .foregroundColor(.primary)

//                        Spacer()

                        Picker("settings_currency_label",
                               selection: $store.selectedCurrency.sending(\.currencyChanged)) {
                            ForEach(Currency.allCases) { currency in
                                HStack(spacing: Spacing.xs) {
                                    Text(currency.displayName)
                                }
                                .tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }

                FormField(titleLabel: "settings_distance_label") {
                    HStack {
                        Text("settings_distance_label")
                            .font(.system(size: 17))
                            .foregroundColor(.primary)

                        Picker("settings_distance_label",
                               selection: $store.selectedDistanceUnit.sending(\.distanceUnitChanged)) {
                            ForEach(DistanceUnit.allCases) { unit in
                                HStack(spacing: Spacing.xs) {
                                    Text(unit.displayName)
                                }
                                .tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }

                // Warning about unit change
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)

                        Text("settings_distance_warning_title")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                    }

                    Text("settings_distance_warning_message")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(Spacing.sm)
                .background(Color.orange.tertiary)
                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
            }
            .padding(Spacing.md)
        }
        .navigationTitle("settings_units_and_measure_title")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            store.send(.view(.onAppear))
        }
    }
}

#Preview {
    NavigationStack {
        UnitAndMeasureSettingView(
            store: Store(
                initialState: UnitAndMeasureSettingStore.State()
            ) {
                UnitAndMeasureSettingStore()
            }
        )
    }
}

#Preview("With Dollar and Miles") {
    NavigationStack {
        UnitAndMeasureSettingView(
            store: Store(
                initialState: UnitAndMeasureSettingStore.State(
                    selectedCurrency: .dollar,
                    selectedDistanceUnit: .miles
                )
            ) {
                UnitAndMeasureSettingStore()
            }
        )
    }
}
