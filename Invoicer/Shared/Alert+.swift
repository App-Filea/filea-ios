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
                ButtonState(action: .yes) { TextState("Oui, je le remplace") }
                ButtonState(role: .cancel, action: .no) { TextState("Non") }
            },
            message: {
                TextState("")
            }
        )
    }
}
