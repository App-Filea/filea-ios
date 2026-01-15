//
//  VehicleAdministrationView.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct VehicleAdministrationView: View {
    @Bindable var store: StoreOf<MainStore>

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "building.columns")
                .font(.system(size: 48))
                .foregroundStyle(Color.secondary)

            Text("Documents Administratifs")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.primary)

            Text("Cette fonctionnalité sera disponible prochainement")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)

            Text("Vous pourrez gérer vos documents administratifs comme les assurances, cartes grises, etc.")
                .font(.footnote)
                .foregroundStyle(Color(.tertiaryLabel))
                .multilineTextAlignment(.center)
                .padding(.top, Spacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xxl)
    }
}
