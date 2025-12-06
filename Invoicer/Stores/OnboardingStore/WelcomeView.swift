//
//  WelcomeView.swift
//  Invoicer
//
//  Created by Claude on 2025-01-18.
//  Welcome screen for onboarding - Apple native style
//

import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)

            // App Icon
            AppIconView()
                .padding(.bottom, 28)

            // Title
            Text("Bienvenue dans Filea")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)

            // Features List
            VStack(alignment: .leading, spacing: 24) {
                OnboardingFeatureRow(
                    icon: "doc.text.image",
                    iconColor: .blue,
                    title: "Gérez vos documents automobiles",
                    description: "Regroupez cartes grises, assurances, contrôles techniques et factures en un seul endroit."
                )

                OnboardingFeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: .green,
                    title: "Suivez vos dépenses",
                    description: "Visualisez vos coûts d'entretien, de carburant et de réparations avec des graphiques détaillés."
                )

                OnboardingFeatureRow(
                    icon: "lock.shield",
                    iconColor: .orange,
                    title: "Vos données restent privées",
                    description: "Stockage 100% local sur votre appareil ou votre cloud personnel. Aucune donnée n'est envoyée ailleurs."
                )
            }
            .padding(.horizontal, 32)

            Spacer()

            // Continue Button
            Button(action: onContinue) {
                Text("Continuer")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
        .background(Color(uiColor: .systemBackground))
    }
}

// MARK: - App Icon Component

struct AppIconView: View {
    var body: some View {
        Image("AppLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}

// MARK: - Onboarding Feature Row Component

struct OnboardingFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(iconColor)
            }

            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.primary)

                Text(description)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    WelcomeView(onContinue: {})
}
