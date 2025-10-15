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
            Color(.secondarySystemBackground)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    HStack {
                        Button("Retour", action: {
                            if let previousStep = currentStep.previous {
                                scrollPosition = previousStep
                            } else {
                                store.send(.cancelCreation)
                            }
                        })
                        .foregroundStyle(Color(.systemPurple))

                        Spacer()

                        Text(currentStep.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(.label))
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
                        .foregroundStyle(Color(.systemPurple))
                        .disabled(store.isLoading)
                    }
                }
                .padding(.horizontal, 16)

                Text(currentStep.subtitle)
                    .bodyDefaultRegular()
                    .foregroundStyle(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 40, alignment: .top)
                    .padding(.horizontal, 16)

                // Validation error
                if store.showValidationError {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        Text(currentStep.validate(
                            hasSource: store.hasSourceSelected,
                            name: store.documentName,
                            mileage: store.documentMileage,
                            amount: store.documentAmount
                        ).error ?? "")
                            .font(.caption)
                            .foregroundStyle(Color(.label))
                    }
                    .padding(12)
                    .background(Color(.systemYellow).opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemYellow), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
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
