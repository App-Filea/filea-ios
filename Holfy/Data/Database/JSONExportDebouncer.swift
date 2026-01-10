//
//  JSONExportDebouncer.swift
//  Holfy
//
//  Created by Nicolas Barbosa on 10/01/2026.
//

import Foundation

/// Actor qui gère le debouncing des exports JSON pour éviter les exports multiples rapprochés
///
/// Utilise un délai de 500ms pour regrouper les mutations rapides sur un même véhicule
/// et ne faire qu'un seul export JSON à la fin de la période de mutations.
actor JSONExportDebouncer {

    // MARK: - Properties

    private let syncManager: VehicleMetadataSyncManager
    private let debounceInterval: Duration = .milliseconds(500)
    private var scheduledExports: [String: Task<Void, Never>] = [:]

    // MARK: - Initialization

    init(syncManager: VehicleMetadataSyncManager) {
        self.syncManager = syncManager
        print("🚀 [JSONExportDebouncer] Initialized with \(debounceInterval.components.seconds * 1000)ms debounce interval")
    }

    // MARK: - Public Methods

    /// Planifie un export JSON pour un véhicule avec debouncing
    ///
    /// Si un export est déjà planifié pour ce véhicule, il est annulé et un nouveau est programmé.
    /// L'export effectif n'aura lieu que 500ms après le dernier appel à cette méthode.
    ///
    /// - Parameter vehicleId: L'identifiant du véhicule à exporter
    func schedule(vehicleId: String) async {
        print("📝 [JSONExportDebouncer] Scheduling export for vehicle: \(vehicleId)")

        // Annuler l'export précédent s'il existe
        scheduledExports[vehicleId]?.cancel()

        // Créer une nouvelle tâche d'export
        scheduledExports[vehicleId] = Task {
            do {
                // Attendre le délai de debounce
                try await Task.sleep(for: debounceInterval)

                // Vérifier que la tâche n'a pas été annulée
                guard !Task.isCancelled else {
                    print("⏭️ [JSONExportDebouncer] Export cancelled for vehicle: \(vehicleId)")
                    return
                }

                // Effectuer l'export JSON
                try await syncManager.exportVehicleToJSON(vehicleId: vehicleId)
                print("💾 [JSONExportDebouncer] Exported JSON for vehicle: \(vehicleId)")

            } catch {
                // Gérer les erreurs sans crasher
                if error is CancellationError {
                    print("⏭️ [JSONExportDebouncer] Export cancelled for vehicle: \(vehicleId)")
                } else {
                    print("❌ [JSONExportDebouncer] Export failed for vehicle \(vehicleId): \(error.localizedDescription)")
                }
            }

            // Nettoyer la tâche terminée
            scheduledExports[vehicleId] = nil
        }
    }

    /// Annule tous les exports en attente
    ///
    /// Utilisé principalement lors de la destruction de l'actor ou pour des tests
    func cancelAll() {
        print("🛑 [JSONExportDebouncer] Cancelling all pending exports")
        scheduledExports.values.forEach { $0.cancel() }
        scheduledExports.removeAll()
    }

    /// Retourne le nombre d'exports actuellement planifiés
    ///
    /// - Returns: Le nombre de véhicules ayant un export en attente
    func pendingExportsCount() -> Int {
        return scheduledExports.count
    }
}
