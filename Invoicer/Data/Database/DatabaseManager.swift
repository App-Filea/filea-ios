//
//  DatabaseManager.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 18/10/2025.
//

import Foundation
import GRDB
import Dependencies

/// Gestionnaire principal de la base de données
actor DatabaseManager {
    // MARK: - Properties

    /// Queue de la base de données
    private let dbQueue: DatabaseQueue

    /// Chemin du fichier de base de données
    private let databasePath: String

    // MARK: - Initialization

    /// Initialise le gestionnaire de base de données
    /// - Parameter databasePath: Chemin optionnel pour la base de données. Si nil, utilise le chemin par défaut.
    init(databasePath: String? = nil) throws {
        print("🚀 [DatabaseManager] Initialisation de la base de données...")

        // Déterminer le chemin de la base de données
        if let path = databasePath {
            self.databasePath = path
            print("   📍 Chemin personnalisé : \(path)")
        } else {
            // Utiliser Application Support par défaut
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )

            let appDirectory = appSupportURL.appendingPathComponent("Invoicer", isDirectory: true)

            // Créer le dossier si nécessaire
            if !fileManager.fileExists(atPath: appDirectory.path) {
                try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
                print("   📁 Dossier créé : \(appDirectory.path)")
            }

            self.databasePath = appDirectory.appendingPathComponent("invoicer.db").path
            print("   📍 Chemin par défaut : \(self.databasePath)")
        }

        // Créer la configuration de la base de données
        var configuration = Configuration()
        configuration.prepareDatabase { db in
            try db.execute(sql: "PRAGMA foreign_keys = ON")
            try db.execute(sql: "PRAGMA journal_mode = WAL")
            try db.execute(sql: "PRAGMA synchronous = NORMAL")
        }

        // Créer la queue de base de données avec la configuration
        self.dbQueue = try DatabaseQueue(path: self.databasePath, configuration: configuration)

        print("📊 [DatabaseManager] Configuration de la base de données terminée")
        print("   ├─ Clés étrangères : ON")
        print("   ├─ Journal mode : WAL")
        print("   └─ Synchronous : NORMAL")

        // Exécuter les migrations
        try runMigrations()

        print("✅ [DatabaseManager] Base de données prête à l'emploi\n")
    }

    /// Exécute les migrations de la base de données
    private nonisolated func runMigrations() throws {
        print("🔄 [DatabaseManager] Début des migrations...")
        let migrator = DatabaseMigrator.setupMigrations()
        try migrator.migrate(dbQueue)
        print("✅ [DatabaseManager] Migrations terminées avec succès")
    }

    // MARK: - Database Access

    /// Accès en lecture à la base de données
    func read<T>(_ block: (Database) throws -> T) async throws -> T {
        try dbQueue.read(block)
    }

    /// Accès en écriture à la base de données
    func write<T>(_ block: (Database) throws -> T) async throws -> T {
        try dbQueue.write(block)
    }

    /// Accès à la queue pour les opérations complexes
    var queue: DatabaseQueue {
        dbQueue
    }
}

// MARK: - Dependency Key

extension DatabaseManager: DependencyKey {
    static let liveValue: DatabaseManager = {
        do {
            return try DatabaseManager()
        } catch {
            fatalError("❌ [DatabaseManager] Échec de l'initialisation de la base de données: \(error.localizedDescription)")
        }
    }()
}

extension DependencyValues {
    var database: DatabaseManager {
        get { self[DatabaseManager.self] }
        set { self[DatabaseManager.self] = newValue }
    }
}
