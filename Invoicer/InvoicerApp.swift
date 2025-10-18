//
//  InvoicerApp.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture
import Dependencies

@main
struct InvoicerApp: App {
    init() {
        // Forcer l'initialisation de la base de données au démarrage
        _ = DatabaseManager.liveValue
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: AppStore.State()) {
                AppStore()
            })
        }
    }
}
