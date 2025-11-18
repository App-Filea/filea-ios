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

extension AlertState where Action == MainStore.Action.Alert {
    static func deleteCurrentVehicleAlert() -> Self {
        AlertState {
            TextState("Supprimer le véhicule")
        } actions: {
            ButtonState(role: .destructive, action: .confirmDelete) {
                TextState("Supprimer")
            }
            ButtonState(role: .cancel) {
                TextState("Annuler")
            }
        } message: {
            TextState("Êtes-vous sûr de vouloir supprimer ce véhicule ? Cette action est irréversible.")
        }
    }
}
