//
//  VehicleFuelView.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct VehicleFuelView: View {
    @Bindable var store: StoreOf<MainStore>

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "fuelpump")
                .font(.system(size: 48))
                .foregroundStyle(Color.secondary)

            Text("Historique de Carburant")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.primary)

            Text("Cette fonctionnalité sera disponible prochainement")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)

            Text("Vous pourrez suivre vos pleins d'essence et analyser votre consommation")
                .font(.footnote)
                .foregroundStyle(Color(.tertiaryLabel))
                .multilineTextAlignment(.center)
                .padding(.top, Spacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xxl)
    }
}
