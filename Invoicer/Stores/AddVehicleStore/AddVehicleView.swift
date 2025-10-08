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
                    .foregroundStyle(Color("onBackground"))
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 40)
                    .animation(.easeInOut(duration: animationDuration), value: currentStep)
                
                Text(currentStep.subtitle)
                    .bodyDefaultRegular()
                    .foregroundStyle(Color("onBackgroundSecondary"))
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
                .foregroundStyle(Color("onPrimary"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("primary"))
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
                        .foregroundStyle(Color("onBackground"))
                }
                .buttonStyle(.plain)
            }
            
            if shouldShowCancelButton {
                Button(action: cancelVehicleCreation) {
                    Text("Annuler")
                        .bodyDefaultRegular()
                        .foregroundStyle(Color("onBackground"))
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
            Color("background")
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
                    store.vehicle.registrationDate = date
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
        case .date: return formatDate(store.vehicle.registrationDate)
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
            OutlinedTextField(
                focusedField: $focusedField,
                field: AddVehicleStep.brand,
                placeholder: "TOYOTA, BMW, MERCEDES...",
                text: $store.vehicle.brand,
                hasError: validationErrors[.brand] != nil
            )
            .autocapitalization(.allCharacters)
            .focused($focusedField, equals: .brand)
            .onChange(of: store.vehicle.brand) { _, _ in
                validationErrors[.brand] = nil
            }
            
        case .model:
            OutlinedTextField(
                focusedField: $focusedField,
                field: AddVehicleStep.model,
                placeholder: "COROLLA, X3, CLASSE A...",
                text: $store.vehicle.model,
                hasError: validationErrors[.model] != nil
            )
            .autocapitalization(.allCharacters)
            .focused($focusedField, equals: .model)
            .onChange(of: store.vehicle.model) { _, _ in
                validationErrors[.model] = nil
            }
        case .plate:
            OutlinedTextField(
                focusedField: $focusedField,
                field: AddVehicleStep.plate,
                placeholder: "AB-123-CD",
                text: $store.vehicle.plate,
                hasError: validationErrors[.plate] != nil
            )
            .autocapitalization(.allCharacters)
            .focused($focusedField, equals: .plate)
            .onChange(of: store.vehicle.plate) { _, _ in
                validationErrors[.plate] = nil
            }
            
        case .mileage:
            OutlinedTextField(
                focusedField: $focusedField,
                field: AddVehicleStep.mileage,
                placeholder: "120000",
                text: $store.vehicle.mileage,
                hasError: validationErrors[.mileage] != nil,
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
                    Text(formatDate(store.vehicle.registrationDate))
                        .bodyDefaultRegular()
                        .foregroundStyle(Color("onSurface"))

                    Spacer()

                    Image(systemName: "calendar")
                        .foregroundStyle(Color("onBackgroundSecondary"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(validationErrors[.date] != nil ? Color("error") : Color("outline"), lineWidth: 2)
                        .animation(.easeInOut(duration: 0.3), value: validationErrors[.date] != nil)
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
            HStack(spacing: 0) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle().stroke(lineWidth: 3)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(step < currentStep ? Color("primary") : Color("primaryContainer") )
                        .overlay {
                            if step < currentStep {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color("primary"))
                                    .transition(.scale)
                            }
                    }
                    
                    
                    if step < totalSteps - 1 {
                        ZStack(alignment: .leading){
                            Rectangle()
                                .frame(height: 3)
                                .foregroundStyle(Color("primaryContainer") )
                            Rectangle()
                                .frame(height: 3)
                                .frame(maxWidth: step >= currentStep ? 0 : .infinity, alignment: .leading)
                                .foregroundStyle(Color("primary"))
                        }
                    }
                }
            }
            
            .animation(.default, value: currentStep)

            Text("\(currentStep + 1) sur \(totalSteps)")
                .bodyXSmallRegular()
                .foregroundStyle(Color("onBackgroundSecondary"))
        }
        .padding(.vertical, 8)
    }
}


struct SummaryView: View {
    @Bindable var store: StoreOf<AddVehicleStore>

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informations du véhicule")
                .bodyDefaultSemibold()
                .foregroundStyle(Color("onBackground"))

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
                    value: formatDate(store.vehicle.registrationDate)
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("surface"))
                    .stroke(Color("outline"), lineWidth: 2)
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
                .foregroundStyle(Color("onBackgroundSecondary"))

            Text(value)
                .bodyDefaultRegular()
                .foregroundStyle(Color("onSurface"))
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

// Test commit pour vérifier l'auteur Git
