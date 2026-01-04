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

extension SharedReaderKey where Self == InMemoryKey<Vehicle>.Default {
    static var selectedVehicle: Self {
        Self[.inMemory("selectedVehicle"), default: .null()]
    }
}

extension SharedReaderKey where Self == AppStorageKey<String?>.Default {
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

// MARK: - User Preferences SharedKeys
extension SharedReaderKey where Self == AppStorageKey<Currency>.Default {
    static var selectedCurrency: Self {
        Self[.appStorage("selectedCurrency"), default: .euro]
    }
}

extension SharedReaderKey where Self == AppStorageKey<DistanceUnit>.Default {
    static var selectedDistanceUnit: Self {
        Self[.appStorage("selectedDistanceUnit"), default: .kilometers]
    }
}
