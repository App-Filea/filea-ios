//
//  AddVehicleMultiStepView.swift
//  Invoicer
//
//  Created by Claude Code on 11/10/2025.
//

import SwiftUI
import ComposableArchitecture

// MARK: - Progress Arc Component
struct ProgressArcView: View {
    @State private var rotationAngle: Double = 0
    @State private var arcOpacity: Double = 0
    @State private var animationTask: Task<Void, Never>?

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.25)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        ColorTokens.surfaceSecondary,
                        ColorTokens.actionPrimary
                    ]),
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90)
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .frame(width: Spacing.lg, height: Spacing.lg)
            .rotationEffect(.degrees(rotationAngle + 90))
            .opacity(arcOpacity)
            .onAppear {
                // Attendre la fin de l'animation du rectangle (0.4s) puis démarrer
                Task {
                    try? await Task.sleep(nanoseconds: 400_000_000)
                    startRotationAnimation()
                }
            }
            .onDisappear {
                // Annuler l'animation quand le composant disparaît
                animationTask?.cancel()
            }
    }

    private func startRotationAnimation() {
        // Annuler l'animation précédente si elle existe
        animationTask?.cancel()

        // Créer une nouvelle tâche d'animation en boucle
        animationTask = Task {
            while !Task.isCancelled {
                // Fade in au début de la rotation
                withAnimation(.easeIn(duration: 0.2)) {
                    arcOpacity = 1.0
                }

                // Animation de rotation (1 seconde avec easing)
                withAnimation(.easeInOut(duration: 1.0)) {
                    rotationAngle = 360
                }

                // Attendre 0.6s puis fade out
                try? await Task.sleep(nanoseconds: 600_000_000)
                guard !Task.isCancelled else { return }

                withAnimation(.easeOut(duration: 0.4)) {
                    arcOpacity = 0
                }

                // Attendre 2 secondes puis réinitialiser et recommencer
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                guard !Task.isCancelled else { return }

                // Réinitialiser la rotation pour le prochain tour
                rotationAngle = 0
            }
        }
    }
}

struct AddVehicleMultiStepView: View {
    @Bindable var store: StoreOf<AddVehicleStore>
    @State private var scrollPosition: AddVehicleStep? = .type
    @State private var showPrimaryAlert: Bool = false
    private let totalSteps: Int = AddVehicleStep.allCases.count
    private var currentStep: AddVehicleStep {
        scrollPosition ?? .type
    }

    private var existingPrimaryVehicle: Vehicle? {
        store.vehicles.first(where: { $0.isPrimary })
    }

    var body: some View {
        ZStack {
            ColorTokens.background
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                VStack(spacing: Spacing.md) {
                    // Header with progress indicator
                    HStack(spacing: Spacing.xxxs) {
                        ForEach(0..<totalSteps, id: \.self) { step in
                            ZStack {
                                Circle()
                                    .stroke(lineWidth: 3)
                                    .frame(width: Spacing.lg, height: Spacing.lg)
                                    .foregroundStyle(step < currentStep.rawValue ? ColorTokens.actionPrimary : ColorTokens.surfaceSecondary)

                                // Arc de cercle animé pour l'étape actuelle
                                if step == currentStep.rawValue {
                                    ProgressArcView()
                                }

                                // Checkmark pour les étapes complétées
                                if step < currentStep.rawValue {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .frame(width: Spacing.lg, height: Spacing.lg)
                                        .foregroundStyle(ColorTokens.actionPrimary)
                                        .transition(.scale)
                                }
                            }
                            if step < totalSteps-1 {
                                ZStack(alignment: .leading){
                                    Rectangle()
                                        .frame(height: 3)
                                        .foregroundStyle(ColorTokens.surfaceSecondary)
                                    Rectangle()
                                        .frame(height: 3)
                                        .frame(maxWidth: step >= currentStep.rawValue ? 0 : .infinity, alignment: .leading)
                                        .foregroundStyle(ColorTokens.actionPrimary)
                                }
                            }
                        }
                    }
                    .animation(.default, value: currentStep.rawValue)
                    
                    HStack {
                        Button("Retour", action: {
                            if let previousStep = currentStep.previous {
                                scrollPosition = previousStep
                            } else {
                                store.send(.cancelCreation)
                            }
                        })
                        Spacer()
                        Text(currentStep.title)
                            .font(Typography.title2)
                            .foregroundStyle(ColorTokens.textPrimary)
                            .multilineTextAlignment(.center)
                        Spacer()
                        Button("Suivant", action: {
                            // Validate current step
                            let validation = currentStep.validate(
                                type: store.vehicleType,
                                brand: store.brand,
                                model: store.model,
                                plate: store.plate,
                                registrationDate: store.registrationDate,
                                mileage: store.mileage
                            )

                            if !validation.isValid {
                                store.send(.setShowValidationError(true))
                                return
                            }

                            store.send(.setShowValidationError(false))

                            // Si on est à l'étape Type et que le véhicule est principal
                            // et qu'il existe déjà un véhicule principal
                            if currentStep == .type && store.isPrimary && existingPrimaryVehicle != nil {
                                showPrimaryAlert = true
                                return
                            }

                            if currentStep == .summary {
                                store.send(.saveVehicle)
                            }
                            else {
                                if let nextStep = currentStep.next {
                                    scrollPosition = nextStep
                                }
                            }
                        })
                    }
                }
                .padding(.horizontal, Spacing.md)
                Text(currentStep.subtitle)
                    .bodyDefaultRegular()
                    .foregroundStyle(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 40, alignment: .top)
                    .padding(.horizontal, Spacing.md)

                // Horizontal scrolling steps
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: 0) {
                        ForEach(AddVehicleStep.allCases) { step in
                            AddVehicleStepView(
                                step: step,
                                store: store
                            )
                            .containerRelativeFrame(.horizontal)
                            .id(step)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $scrollPosition)
                .animation(.default, value: scrollPosition)
                .scrollIndicators(.hidden)
                .scrollDisabled(true)
            }
        }
            .navigationBarHidden(true)
            .alert("Véhicule principal existant", isPresented: $showPrimaryAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Continuer") {
                    if let nextStep = currentStep.next {
                        scrollPosition = nextStep
                    }
                }
            } message: {
                if let existingVehicle = existingPrimaryVehicle {
                    Text("Vous avez déjà un véhicule principal (\(existingVehicle.brand) \(existingVehicle.model)). En créant ce nouveau véhicule comme principal, l'actuel deviendra secondaire.")
                }
            }
    }
    
    // MARK: - Computed Properties

    private var canProceed: Bool {
        let validation = currentStep.validate(
            type: store.vehicleType,
            brand: store.brand,
            model: store.model,
            plate: store.plate,
            registrationDate: store.registrationDate,
            mileage: store.mileage
        )
        return validation.isValid
    }
}

#Preview {
//    NavigationStack {
        AddVehicleMultiStepView(store: Store(initialState: AddVehicleStore.State()) {
            AddVehicleStore()
        })
//    }
}
