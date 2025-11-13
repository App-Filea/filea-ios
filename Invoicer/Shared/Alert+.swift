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
                TextState("")
            },
            actions: {
                ButtonState(role: .cancel, action: .confirm) { TextState("") }
            },
            message: {
                TextState("")
            }
        )
    }
}
