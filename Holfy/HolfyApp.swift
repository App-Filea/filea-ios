//
//  InvoicerApp.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture
import Dependencies
import FirebaseCore
import FirebaseCrashlytics

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct HolfyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
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
