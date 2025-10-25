//
//  DismissSpy.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 29/10/2025.
//

import ComposableArchitecture

struct DismissEffectSpy {
    var isDismissInvoked: LockIsolated<[Bool]> = .init([])

    var dismissEffect: DismissEffect {
        DismissEffect { self.isDismissInvoked.withValue { $0.append(true) } }
    }
}
