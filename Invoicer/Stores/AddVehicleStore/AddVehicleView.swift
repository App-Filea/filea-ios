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
    @State private var currentStep: FormStep = .brand
    @State private var validationErrors: [FormStep: String] = [:]
    @State private var activeStepID: Int? = 0
    
    enum FormStep: Int, CaseIterable, Identifiable {
        case brand = 0
        case model = 1
        case plate = 2
        case mileage = 3
        case date = 4
        case summary = 5
        
        var id: Int { rawValue }
        
        var title: String {
            switch self {
            case .brand: return "Marque du véhicule"
            case .model: return "Modèle du véhicule"
            case .plate: return "Plaque d'immatriculation"
            case .mileage: return "Kilométrage actuel"
            case .date: return "Date de mise en circulation"
            case .summary: return "Récapitulatif"
            }
        }
        
        var subtitle: String {
            switch self {
            case .brand: return "Quelle est la marque de votre véhicule ?"
            case .model: return "Quel est le modèle de votre véhicule ?"
            case .plate: return "Quelle est la plaque d'immatriculation ?"
            case .mileage: return "Quel est le kilométrage actuel ?"
            case .date: return "Quelle est la date de mise en circulation ?"
            case .summary: return "Vérifiez les informations saisies"
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .summary: return "Créer le véhicule"
            default: return "Continuer"
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .ignoresSafeArea()
            
            GeometryReader { reader in
                VStack(spacing: 0) {
                    // Progress Indicator (hidden on summary)
                    VStack(spacing: 0) {
                        if currentStep != .summary {
                            StepProgressView(currentStep: currentStep.rawValue, totalSteps: FormStep.allCases.count - 1)
                                .padding(.horizontal, 20)
                        }
                        
                        // Header avec titre et sous-titre fixes
                        VStack(spacing: 12) {
                            Text(currentStep.title)
                                .titleLarge()
                                .multilineTextAlignment(.center)
                                .frame(minHeight: 40)
                            
                            Text(currentStep.subtitle)
                                .bodyDefaultRegular()
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(minHeight: 44)
                        }
                        .frame(height: 140)
                        .padding(.horizontal, 20)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                    .ignoresSafeArea(.keyboard)
                    
                    Spacer()
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 0) {
                            ForEach(FormStep.allCases) { step in
                                if step == .summary {
                                    ScrollView(.vertical) {
                                        VStack(spacing: 24) {
                                            stepContentView(for: step)
                                            
                                            VStack {
                                                if let error = validationErrors[step] {
                                                    Text(error)
                                                        .bodyXSmallRegular()
                                                        .foregroundStyle(.red)
                                                        .transition(.asymmetric(
                                                            insertion: .opacity.combined(with: .move(edge: .top)),
                                                            removal: .opacity.combined(with: .move(edge: .top))
                                                        ))
                                                }
                                            }
                                            .frame(height: 30)
                                            
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
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 20)
                                    }
                                    .containerRelativeFrame(.horizontal)
                                    .id(step.id)
                                } else {
                                    VStack(spacing: 4) {
                                        stepContentView(for: step)
                                        
                                        VStack {
                                            if let error = validationErrors[step] {
                                                Text(error)
                                                    .bodyXSmallRegular()
                                                    .foregroundStyle(.red)
                                                    .transition(.asymmetric(
                                                        insertion: .opacity.combined(with: .move(edge: .top)),
                                                        removal: .opacity.combined(with: .move(edge: .top))
                                                    ))
                                            }
                                        }
                                        .frame(height: 30)
                                    }
                                    .padding(.horizontal, 20)
                                    .containerRelativeFrame(.horizontal)
                                    .id(step.id)
                                    .frame(height: 100)
                                }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $activeStepID)
                    .scrollDisabled(true)
                    
                    Spacer()
                    
                    if currentStep != .summary {
                        // Boutons en bas fixes
                        VStack(spacing: 12) {
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
                            
                            if currentStep.rawValue > 0 && currentStep != .summary {
                                Button(action: previousStep) {
                                    Text("Retour")
                                        .bodyDefaultRegular()
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(height: 70)
                        .padding(.horizontal, 20)
                        .padding(.bottom, reader.safeAreaInsets.bottom + 20)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
            }
        }

        .navigationBarHidden(true)
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
        // Fermer le clavier
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if currentStep == .summary {
            store.send(.saveVehicle)
        } else {
            nextStep()
        }
    }
    
    private func nextStep() {
        let currentValue = getCurrentStepValue()
        
        if currentValue.isEmpty {
            withAnimation(.easeInOut(duration: 0.3)) {
                validationErrors[currentStep] = "Ce champ est obligatoire"
            }
            return
        }
        
        validationErrors[currentStep] = nil
        
        withAnimation(.easeInOut(duration: 0.4)) {
            if currentStep.rawValue < FormStep.allCases.count - 1 {
                let nextStep = FormStep(rawValue: currentStep.rawValue + 1)!
                currentStep = nextStep
                activeStepID = nextStep.id
            }
        }
    }
    
    private func previousStep() {
        withAnimation(.easeInOut(duration: 0.4)) {
            if currentStep.rawValue > 0 {
                let prevStep = FormStep(rawValue: currentStep.rawValue - 1)!
                currentStep = prevStep
                activeStepID = prevStep.id
                validationErrors[currentStep] = nil
            }
        }
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
    
    
    @ViewBuilder
    private func stepContentView(for step: FormStep) -> some View {
        switch step {
        case .brand:
            StepTextField(
                placeholder: "TOYOTA, BMW, MERCEDES...",
                text: $store.vehicle.brand
            )
            .autocapitalization(.allCharacters)
            .onChange(of: store.vehicle.brand) { _, _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    validationErrors[.brand] = nil
                }
            }
            
        case .model:
            StepTextField(
                placeholder: "COROLLA, X3, CLASSE A...",
                text: $store.vehicle.model
            )
            .autocapitalization(.allCharacters)
            .onChange(of: store.vehicle.model) { _, _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    validationErrors[.model] = nil
                }
            }
            
        case .plate:
            StepTextField(
                placeholder: "AB-123-CD",
                text: $store.vehicle.plate
            )
            .autocapitalization(.allCharacters)
            .onChange(of: store.vehicle.plate) { _, _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    validationErrors[.plate] = nil
                }
            }
            
        case .mileage:
            StepTextFieldWithSuffix(
                placeholder: "120000",
                text: $store.vehicle.mileage,
                suffix: "KM"
            )
            .keyboardType(.numberPad)
            .onChange(of: store.vehicle.mileage) { _, _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    validationErrors[.mileage] = nil
                }
            }
            
        case .date:
            Button(action: { openDateSheet = true }) {
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
                withAnimation(.easeInOut(duration: 0.3)) {
                    validationErrors[.date] = nil
                }
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

struct StepTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .bodyDefaultRegular()
            .textFieldStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

struct StepTextFieldWithSuffix: View {
    let placeholder: String
    @Binding var text: String
    let suffix: String
    
    var body: some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: $text)
                .bodyDefaultRegular()
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            Text(suffix)
                .bodyDefaultRegular()
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                )
        }
    }
}

struct SummaryView: View {
    @Bindable var store: StoreOf<AddVehicleStore>
    
    var body: some View {
        VStack(spacing: 24) {
            // Marque
            SummaryFieldView(
                title: "Marque du véhicule",
                value: store.vehicle.brand,
                placeholder: "TOYOTA, BMW, MERCEDES..."
            )
            
            // Modèle
            SummaryFieldView(
                title: "Modèle du véhicule",
                value: store.vehicle.model,
                placeholder: "COROLLA, X3, CLASSE A..."
            )
            
            // Plaque
            SummaryFieldView(
                title: "Plaque d'immatriculation",
                value: store.vehicle.plate,
                placeholder: "AB-123-CD"
            )
            
            // Kilométrage
            SummaryFieldWithSuffixView(
                title: "Kilométrage actuel",
                value: store.vehicle.mileage,
                placeholder: "120000",
                suffix: "KM"
            )
            
            // Date
            SummaryFieldView(
                title: "Date de mise en circulation",
                value: store.vehicle.registrationDate,
                placeholder: "Sélectionner une date"
            )
        }
    }
}

struct SummaryFieldView: View {
    let title: String
    let value: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .bodySmallSemibold()
                .foregroundStyle(.secondary)
            
            Text(value.isEmpty ? placeholder : value)
                .bodyDefaultRegular()
                .foregroundStyle(value.isEmpty ? .tertiary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}

struct SummaryFieldWithSuffixView: View {
    let title: String
    let value: String
    let placeholder: String
    let suffix: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .bodySmallSemibold()
                .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                Text(value.isEmpty ? placeholder : value)
                    .bodyDefaultRegular()
                    .foregroundStyle(value.isEmpty ? .tertiary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                
                Text(suffix)
                    .bodyDefaultRegular()
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                    )
            }
        }
    }
}

struct DatePickerSheet: View {
    @Binding var date: Date
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DatePicker(
                    "Date de mise en circulation",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Date de mise en circulation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler", action: onCancel)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Valider", action: onSave)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

//// MARK: - Keyboard Toolbar Extension
//
//struct KeyboardToolbar: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .toolbar {
//                ToolbarItemGroup(placement: .keyboard) {
//                    Spacer()
//                    Button("Terminé") {
//                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                    }
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(.accentColor)
//                }
//            }
//    }
//}
//
//extension View {
//    func keyboardToolbar() -> some View {
//        self.modifier(KeyboardToolbar())
//    }
//}

#Preview {
    NavigationStack {
        AddVehicleView(store: Store(initialState: AddVehicleStore.State()) {
            AddVehicleStore()
        })
    }
}
