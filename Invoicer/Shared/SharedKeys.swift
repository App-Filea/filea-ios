//
//  SharedKeys.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 16/09/2025.
//

import ComposableArchitecture
import Foundation

// MARK: - Vehicle SharedKeys
extension SharedReaderKey where Self == InMemoryKey<[Vehicle]>.Default {
    static var vehicles: Self {
        Self[.inMemory("vehicles"), default: []]
    }
}

extension SharedReaderKey where Self == InMemoryKey<Vehicle?>.Default {
    static var selectedVehicle: Self {
        Self[.inMemory("selectedVehicle"), default: nil]
    }
}

extension SharedReaderKey where Self == AppStorageKey<UUID?>.Default {
    static var lastOpenedVehicleId: Self {
        Self[.appStorage("lastOpenedVehicleId"), default: nil]
    }
}

// MARK: - Onboarding SharedKeys
extension SharedReaderKey where Self == AppStorageKey<Bool>.Default {
    static var hasCompletedOnboarding: Self {
        Self[.appStorage("hasCompletedOnboarding"), default: false]
    }

    static var isStorageConfigured: Self {
        Self[.appStorage("isStorageConfigured"), default: false]
    }
}