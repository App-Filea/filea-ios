//
//  AddDocumentMultiStepView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 13/10/2025.
//

import SwiftUI
import ComposableArchitecture

struct AddDocumentMultiStepView: View {
    @Bindable var store: StoreOf<AddDocumentStore>
    @State private var currentStep: AddDocumentStep = .selectSource

    var body: some View {
        ZStack {
            ColorTokens.surfaceSecondary
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                // Header with navigation
                VStack(spacing: Spacing.md) {
                    HStack {
                        Button("Retour", action: {
                            if let previousStep = currentStep.previous {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep = previousStep
                                }
                            } else {
                                store.send(.cancelCreation)
                            }
                        })
                        .foregroundStyle(ColorTokens.actionPrimary)

                        Spacer()

                        Text(currentStep.title)
                            .font(Typography.title2)
                            .foregroundStyle(ColorTokens.textPrimary)
                            .multilineTextAlignment(.center)

                        Spacer()

                        Button(currentStep == .metadata ? "Enregistrer" : "Suivant", action: {
                            // Validate current step
                            let validation = currentStep.validate(
                                hasSource: store.hasSourceSelected,
                                name: store.documentName,
                                mileage: store.documentMileage,
                                amount: store.documentAmount
                            )

                            if !validation.isValid {
                                store.send(.setShowValidationError(true))
                                return
                            }

                            store.send(.setShowValidationError(false))

                            if currentStep == .metadata {
                                store.send(.saveDocument)
                            } else {
                                if let nextStep = currentStep.next {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentStep = nextStep
                                    }
                                }
                            }
                        })
                        .foregroundStyle(ColorTokens.actionPrimary)
                        .disabled(store.isLoading)
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

                // Validation error
                if store.showValidationError {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(ColorTokens.warning)
                        Text(currentStep.validate(
                            hasSource: store.hasSourceSelected,
                            name: store.documentName,
                            mileage: store.documentMileage,
                            amount: store.documentAmount
                        ).error ?? "")
                            .font(Typography.caption1)
                            .foregroundStyle(ColorTokens.textPrimary)
                    }
                    .padding(Spacing.sm)
                    .background(ColorTokens.warning.opacity(0.1))
                    .cornerRadius(Radius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(ColorTokens.warning, lineWidth: 1)
                    )
                    .padding(.horizontal, Spacing.md)
                    .transition(.scale.combined(with: .opacity))
                }

                // Vertical scrolling step content with animations
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        AddDocumentStepView(
                            step: currentStep,
                            store: store
                        )
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.lg)
                }
                .scrollDismissesKeyboard(.interactively)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 1.05).combined(with: .opacity)
                ))
                .id(currentStep.id)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    AddDocumentMultiStepView(store: Store(initialState: AddDocumentStore.State(vehicleId: UUID())) {
        AddDocumentStore()
    })
}
