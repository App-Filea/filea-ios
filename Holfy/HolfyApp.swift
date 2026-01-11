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

        // Lancer la migration des données legacy si nécessaire
        Task {
            @Dependency(\.legacyMigrator) var migrator
            @Dependency(\.storageManager) var storageManager

            // Get the storage root URL
            guard let storageRoot = await storageManager.getRootURL() else {
                print("ℹ️ [HolfyApp] No storage configured yet - skipping migration")
                return
            }

            let result = await migrator.migrateIfNeeded(storageRoot)

            print("📦 [HolfyApp] Migration result: \(result.userMessage)")

            // Log détaillé selon le résultat
            switch result {
            case .success(let vehicles, let documents):
                print("   ✅ \(vehicles) véhicule(s) et \(documents) document(s) migrés avec succès")
            case .partialSuccess(let vehicles, let documents, let errors):
                print("   ⚠️ \(vehicles) véhicule(s) et \(documents) document(s) migrés")
                print("   ⚠️ \(errors.count) erreur(s) rencontrée(s):")
                errors.forEach { print("      - \($0)") }
            case .noLegacyData:
                print("   ℹ️ Nouvelle installation - pas de données à migrer")
            case .alreadyMigrated:
                print("   ✅ Migration déjà effectuée précédemment")
            case .failed(let error):
                print("   ❌ Échec de la migration: \(error.localizedDescription)")
            }
            print("")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: AppStore.State()) {
                AppStore()
            })
        }
    }
}
