//
//  InvoicerApp.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct InvoicerApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: AppStore.State()) {
                AppStore()
            })
        }
    }
}
