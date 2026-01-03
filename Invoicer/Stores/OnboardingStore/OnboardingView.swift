//
//  OnboardingView.swift
//  Invoicer
//
//  Created by Claude on 2025-01-18.
//  Welcome onboarding view
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    
    @Bindable var store: StoreOf<OnboardingStore>
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    AppIconView()
                        .padding(.top, 60)
                        .padding(.bottom, 28)
                    
                    Text("Bienvenue dans Filea")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                    
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
                            description: "Stockage 100% local sur votre appareil ou votre cloud personnel. Vous restez maître de vos données."
                        )
                    }
                    .padding(.horizontal, 16)
                }
                .scrollBounceBehavior(.basedOnSize)
                
                PrimaryButton("Continuer", action: { store.send(.continueTapped) })
                .padding([.horizontal, .bottom], Spacing.screenMargin)
            }
        }
    }
}

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

struct OnboardingFeatureRow<style: ShapeStyle>: View {
    let icon: String
    let iconColor: style
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.tertiary)
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.primary)
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}

#Preview {
    OnboardingView(
        store: Store(initialState: OnboardingStore.State()) {
            OnboardingStore()
        }
    )
}
