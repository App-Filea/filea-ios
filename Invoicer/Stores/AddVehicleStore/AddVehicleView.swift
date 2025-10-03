//
//  AddVehicleView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct AddVehicleView: View {
    @Bindable var store: StoreOf<AddVehicleStore>
    @State private var openDateSheet: Bool = false
    @State private var date: Date = .now
    @State private var currentStep: AddVehicleStep = .brand
    @State private var validationErrors: [AddVehicleStep: String] = [:]
    @State private var activeStepID: Int? = 0
    @FocusState private var focusedField: AddVehicleStep?
    @State private var shouldFocusNextField: Bool = false
    
    private let animationDuration: Double = 0.3
    private let longAnimationDuration: Double = 0.4
    private let errorHeight: CGFloat = 30
    private let stepHeight: CGFloat = 100
    private let buttonHeight: CGFloat = 70
    private let headerHeight: CGFloat = 140
    private let horizontalPadding: CGFloat = 20
    
    private var isSummaryStep: Bool { currentStep == .summary }
    private var shouldShowProgress: Bool { true }
    private var shouldShowBottomButtons: Bool { true }
    private var shouldShowBackButton: Bool { currentStep.rawValue > 0 }
    private var shouldShowCancelButton: Bool { currentStep.rawValue == 0 }
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            if shouldShowProgress {
                StepProgressView(currentStep: currentStep.rawValue, totalSteps: AddVehicleStep.allCases.count)
                    .padding(.horizontal, horizontalPadding)
            }
            
            VStack(spacing: 12) {
                Text(currentStep.title)
                    .titleLarge()
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 40)
                    .animation(.easeInOut(duration: animationDuration), value: currentStep)
                
                Text(currentStep.subtitle)
                    .bodyDefaultRegular()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 44)
                    .animation(.easeInOut(duration: animationDuration), value: currentStep)
            }
            .frame(height: headerHeight)
            .padding(.horizontal, horizontalPadding)
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private var stepsScrollView: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(AddVehicleStep.allCases) { step in
                    stepView(for: step)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $activeStepID)
        .scrollDisabled(true)
        .animation(.easeInOut(duration: longAnimationDuration), value: activeStepID)
    }
    
    private func stepView(for step: AddVehicleStep) -> some View {
        Group {
            if step == .summary {
                summaryStepView(for: step)
            } else {
                regularStepView(for: step)
            }
        }
    }
    
    private func summaryStepView(for step: AddVehicleStep) -> some View {
        ScrollView(.vertical) {
            VStack(spacing: 24) {
                stepContentView(for: step)
                ErrorDisplayView(error: validationErrors[step], height: errorHeight)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, horizontalPadding)
        }
        .containerRelativeFrame(.horizontal)
        .id(step.id)
    }
    
    private func regularStepView(for step: AddVehicleStep) -> some View {
        VStack(spacing: 4) {
            stepContentView(for: step)
            ErrorDisplayView(error: validationErrors[step], height: errorHeight)
        }
        .padding(.horizontal, horizontalPadding)
        .containerRelativeFrame(.horizontal)
        .id(step.id)
        .frame(height: stepHeight)
    }
    
    struct ErrorDisplayView: View {
        let error: String?
        let height: CGFloat
        
        var body: some View {
            VStack {
                if let error = error {
                    Text(error)
                        .bodyXSmallRegular()
                        .foregroundStyle(.red)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                }
            }
            .frame(height: height)
            .animation(.easeInOut(duration: 0.3), value: error)
        }
    }
    
    private var primaryButton: some View {
        Button(action: handlePrimaryAction) {
            Text(currentStep.buttonTitle)
                .bodyDefaultSemibold()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor)
                )
        }
    }
    
    private func bottomButtonsSection(safeAreaBottom: CGFloat) -> some View {
        VStack(spacing: 12) {
            primaryButton
            
            if shouldShowBackButton {
                Button(action: previousStep) {
                    Text("Retour")
                        .bodyDefaultRegular()
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            if shouldShowCancelButton {
                Button(action: cancelVehicleCreation) {
                    Text("Annuler")
                        .bodyDefaultRegular()
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: buttonHeight)
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, safeAreaBottom + horizontalPadding)
        .animation(.easeInOut(duration: animationDuration), value: currentStep)
    }
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .ignoresSafeArea()
            
            GeometryReader { reader in
                VStack(spacing: 0) {
                    headerSection
                    Spacer()
                    stepsScrollView
                    Spacer()
                    if shouldShowBottomButtons {
                        bottomButtonsSection(safeAreaBottom: reader.safeAreaInsets.bottom)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: activeStepID) { _, _ in
            if shouldFocusNextField {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    focusedField = currentStep
                    shouldFocusNextField = false
                }
            }
        }
        .sheet(isPresented: $openDateSheet) {
            DatePickerSheet(
                date: $date,
                onSave: {
                    store.vehicle.registrationDate = formatDate(date)
                    openDateSheet = false
                },
                onCancel: {
                    openDateSheet = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func handlePrimaryAction() {
        if currentStep == .mileage {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if currentStep == .summary {
                    store.send(.saveVehicle)
                } else {
                    nextStep()
                }
            }
        } else {
            if currentStep == .summary {
                store.send(.saveVehicle)
            } else {
                nextStep()
            }
        }
    }
    
    private func nextStep() {
        let currentValue = getCurrentStepValue()
        
        if currentValue.isEmpty {
            validationErrors[currentStep] = "Ce champ est obligatoire"
            return
        }
        
        validationErrors[currentStep] = nil
        
        if currentStep.rawValue < AddVehicleStep.allCases.count - 1 {
            let nextStep = AddVehicleStep(rawValue: currentStep.rawValue + 1)!
            let wasFieldFocused = focusedField == currentStep
            
            shouldFocusNextField = wasFieldFocused && hasTextField(nextStep)
            currentStep = nextStep
            activeStepID = nextStep.id
        }
    }
    
    private func previousStep() {
        if currentStep.rawValue > 0 {
            let prevStep = AddVehicleStep(rawValue: currentStep.rawValue - 1)!
            let wasFieldFocused = focusedField == currentStep
            
            shouldFocusNextField = wasFieldFocused && hasTextField(prevStep)
            currentStep = prevStep
            activeStepID = prevStep.id
            validationErrors[currentStep] = nil
        }
    }
    
    private func cancelVehicleCreation() {
        store.send(.cancelCreation)
    }
    
    private func getCurrentStepValue() -> String {
        switch currentStep {
        case .brand: return store.vehicle.brand
        case .model: return store.vehicle.model
        case .plate: return store.vehicle.plate
        case .mileage: return store.vehicle.mileage
        case .date: return store.vehicle.registrationDate
        case .summary: return "complete"
        }
    }
    
    private func canNavigateForward() -> Bool {
        let currentValue = getCurrentStepValue()
        return !currentValue.isEmpty
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
    
    private func hasTextField(_ step: AddVehicleStep) -> Bool {
        switch step {
        case .brand, .model, .plate, .mileage:
            return true
        case .date, .summary:
            return false
        }
    }
    
    
    @ViewBuilder
    private func stepContentView(for step: AddVehicleStep) -> some View {
        switch step {
        case .brand:
            StepTextField(
                placeholder: "TOYOTA, BMW, MERCEDES...",
                text: $store.vehicle.brand
            )
            .autocapitalization(.allCharacters)
            .focused($focusedField, equals: .brand)
            .onChange(of: store.vehicle.brand) { _, _ in
                validationErrors[.brand] = nil
            }
            
        case .model:
            StepTextField(
                placeholder: "COROLLA, X3, CLASSE A...",
                text: $store.vehicle.model
            )
            .autocapitalization(.allCharacters)
            .focused($focusedField, equals: .model)
            .onChange(of: store.vehicle.model) { _, _ in
                validationErrors[.model] = nil
            }
            
        case .plate:
            StepTextField(
                placeholder: "AB-123-CD",
                text: $store.vehicle.plate
            )
            .autocapitalization(.allCharacters)
            .focused($focusedField, equals: .plate)
            .onChange(of: store.vehicle.plate) { _, _ in
                validationErrors[.plate] = nil
            }
            
        case .mileage:
            StepTextFieldWithSuffix(
                placeholder: "120000",
                text: $store.vehicle.mileage,
                suffix: "KM"
            )
            .keyboardType(.numberPad)
            .focused($focusedField, equals: .mileage)
            .onChange(of: store.vehicle.mileage) { _, _ in
                validationErrors[.mileage] = nil
            }
            
        case .date:
            Button(action: { 
                openDateSheet = true 
            }) {
                HStack {
                    Text(store.vehicle.registrationDate.isEmpty ? "Sélectionner une date" : store.vehicle.registrationDate)
                        .bodyDefaultRegular()
                        .foregroundStyle(store.vehicle.registrationDate.isEmpty ? .tertiary : .primary)
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .onChange(of: store.vehicle.registrationDate) { _, _ in
                validationErrors[.date] = nil
            }
            
        case .summary:
            SummaryView(store: store)
        }
    }
}

// MARK: - Components

struct StepProgressView: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.accentColor : Color(.systemGray4))
                        .frame(width: 8, height: 8)
                        .scaleEffect(step == currentStep ? 1.2 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                    
                    if step < totalSteps - 1 {
                        Rectangle()
                            .fill(step < currentStep ? Color.accentColor : Color(.systemGray4))
                            .frame(height: 2)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
            }
            
            Text("\(currentStep + 1) sur \(totalSteps)")
                .bodyXSmallRegular()
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}


struct SummaryView: View {
    @Bindable var store: StoreOf<AddVehicleStore>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informations du véhicule")
                .bodyDefaultSemibold()
                .foregroundStyle(.primary)
            
            VStack(spacing: 12) {
                SummaryRowView(
                    label: "Marque",
                    value: store.vehicle.brand.isEmpty ? "Non renseigné" : store.vehicle.brand
                )
                
                SummaryRowView(
                    label: "Modèle",
                    value: store.vehicle.model.isEmpty ? "Non renseigné" : store.vehicle.model
                )
                
                SummaryRowView(
                    label: "Plaque",
                    value: store.vehicle.plate.isEmpty ? "Non renseigné" : store.vehicle.plate
                )
                
                SummaryRowView(
                    label: "Kilométrage actuel",
                    value: store.vehicle.mileage.isEmpty ? "Non renseigné" : "\(store.vehicle.mileage) KM"
                )
                
                SummaryRowView(
                    label: "Date de mise en circulation",
                    value: store.vehicle.registrationDate.isEmpty ? "Non renseigné" : store.vehicle.registrationDate
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

struct SummaryRowView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .bodyXSmallRegular()
                .foregroundStyle(.secondary)
            
            Text(value)
                .bodyDefaultRegular()
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        AddVehicleView(store: Store(initialState: AddVehicleStore.State()) {
            AddVehicleStore()
        })
    }
}
