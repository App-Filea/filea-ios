//
//  Alert+.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 13/11/2025.
//

import ComposableArchitecture

extension AlertState where Action == AddVehicleStore.Action.Alert {
    static func saveNewPrimaryVehicleAlert() -> Self {
        AlertState(
            title: {
                TextState(String(localized: "alert_create_vehicle_primary_already_exist_title"))
            },
            actions: {
                ButtonState(action: .yes) { TextState(String(localized: "alert_create_vehicle_primary_already_exist_yes_button")) }
                ButtonState(role: .cancel, action: .no) { TextState(String(localized: "all_no")) }
            },
            message: {
                TextState(String(localized: "alert_create_vehicle_primary_already_exist_message"))
            }
        )
    }
}

extension AlertState where Action == MainStore.Action.Alert {
    static func deleteCurrentVehicleAlert() -> Self {
        AlertState {
            TextState(String(localized: "alert_delete_vehicle_title"))
        } actions: {
            ButtonState(role: .destructive, action: .confirmDelete) {
                TextState(String(localized: "all_delete"))
            }
            ButtonState(role: .cancel) {
                TextState(String(localized: "all_cancel"))
            }
        } message: {
            TextState(String(localized: "alert_delete_vehicle_message"))
        }
    }
}
