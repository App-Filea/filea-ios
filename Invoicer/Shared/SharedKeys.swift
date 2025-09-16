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