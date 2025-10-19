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
    @State private var scrollPosition: AddDocumentStep? = .selectSource
    private let totalSteps: Int = AddDocumentStep.allCases.count
    private var currentStep: AddDocumentStep {
        scrollPosition ?? .selectSource
    }

    var body: some View {
        ZStack {
            ColorTokens.surfaceSecondary
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Button("Retour", action: {
                            if let previousStep = currentStep.previous {
                                scrollPosition = previousStep
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
                                    scrollPosition = nextStep
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

                // Horizontal scrolling steps
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: 0) {
                        ForEach(AddDocumentStep.allCases) { step in
                            AddDocumentStepView(
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
    }
}

#Preview {
    AddDocumentMultiStepView(store: Store(initialState: AddDocumentStore.State(vehicleId: UUID())) {
        AddDocumentStore()
    })
}
