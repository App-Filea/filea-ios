//
//  AddVehicleMultiStepView.swift
//  Invoicer
//
//  Created by Claude Code on 11/10/2025.
//

import SwiftUI
import ComposableArchitecture

struct AddVehicleMultiStepView: View {
    @Bindable var store: StoreOf<AddVehicleStore>

    var body: some View {
        ZStack {
            ColorTokens.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header fixe
                HStack {
                    Button("Annuler") {
                        store.send(.cancelCreation)
                    }
                    Spacer()
                    Text("Nouveau véhicule")
                        .font(Typography.headline)
                        .foregroundStyle(ColorTokens.textPrimary)
                    Spacer()
                    Button("Ajouter") {
                        store.send(.addButtonTapped)
                    }
                    .disabled(store.isLoading || !store.isFormValid)
                }
                .padding(.horizontal, Spacing.screenMargin)
                .padding(.vertical, Spacing.sm)
                .background(ColorTokens.background)

                // Contenu scrollable - Toutes les étapes affichées
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Étape 1 : Type
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Type de véhicule")
                                .font(Typography.subheadline)
                                .foregroundStyle(ColorTokens.textPrimary)

                            vehicleTypePicker
                        }
                        .padding(.horizontal, Spacing.md)

                        // Étape 2 : Informations
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            HStack(alignment: .bottom) {
                                Text("Informations du véhicule")
                                    .font(Typography.subheadline)
                                    .foregroundStyle(ColorTokens.textPrimary)

                                Spacer()

                                Button {
                                    store.send(.scanButtonTapped)
                                } label: {
                                    HStack(spacing: Spacing.xxs) {
                                        Image(systemName: "doc.text.viewfinder")
                                        Text("Scanner")
                                    }
                                    .font(Typography.footnote)
                                    .foregroundStyle(ColorTokens.actionPrimary)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xs)
                                    .background(ColorTokens.actionPrimary.opacity(0.1))
                                    .cornerRadius(Radius.sm)
                                }
                            }

                            brandAndModelContent
                        }
                        .padding(.horizontal, Spacing.md)

                        // Étape 3 : Détails
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Détails complémentaires")
                                .font(Typography.subheadline)
                                .foregroundStyle(ColorTokens.textPrimary)

                            detailsContent
                        }
                        .padding(.horizontal, Spacing.md)
                    }
                    .padding(.vertical, Spacing.lg)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .sheet(item: $store.scope(state: \.scanStore, action: \.scanStore)) { scanStore in
            DocumentScanView(store: scanStore)
        }
        .sheet(isPresented: $store.showImagePicker) {
            ImagePickerView(selectedImage: Binding(
                get: { store.pendingImage },
                set: { store.send(.imageSelected($0)) }
            ))
        }
        .confirmationDialog(
            "Ajouter un document",
            isPresented: $store.showDocumentSourcePicker
        ) {
            Button("Scanner un document") {
                store.send(.selectDocumentSource(.camera))
            }
            Button("Choisir une photo") {
                store.send(.selectDocumentSource(.photoLibrary))
            }
            Button("Annuler", role: .cancel) { }
        }
        .alert("Véhicule principal existant", isPresented: $store.showPrimaryAlert) {
            Button("Annuler", role: .cancel) {
                store.send(.primaryWarningCancelled)
            }
            Button("Continuer") {
                store.send(.primaryWarningConfirmed)
            }
        } message: {
            if let existingVehicle = store.existingPrimaryVehicle {
                Text("Vous avez déjà un véhicule principal (\(existingVehicle.brand) \(existingVehicle.model)). En créant ce nouveau véhicule comme principal, l'actuel deviendra secondaire.")
            }
        }
        .alert("Erreur", isPresented: $store.showErrorAlert) {
            Button("OK", role: .cancel) {
                store.send(.dismissError)
            }
        } message: {
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Content Components

    private var vehicleTypePicker: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(VehicleType.allCases) { type in
                        Button(action: {
                            if store.vehicleType == type {
                                store.vehicleType = nil
                            } else {
                                store.vehicleType = type
                            }
                        }) {
                            Image(systemName: type.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(x: type.shouldFlipIcon ? -1 : 1, y: 1)
                                .foregroundStyle(store.vehicleType == type ? ColorTokens.actionPrimary : ColorTokens.textPrimary)
                                .frame(height: 40)
                                .padding(Spacing.cardPadding)
                                .background(ColorTokens.surfaceDim)
                                .clipShape(.rect(cornerRadius: Radius.lg))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Radius.lg)
                                        .stroke(store.vehicleType == type ? ColorTokens.actionPrimary : ColorTokens.border, lineWidth: store.vehicleType == type ? 3 : 1)
                                )
                                .shadow(color: store.vehicleType == type ? ColorTokens.actionPrimary.opacity(0.3) : ColorTokens.shadow.opacity(0.1), radius: store.vehicleType == type ? 8 : 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.cardPadding)
                .padding(.vertical, Spacing.xs)
            }
        }
        .padding(.vertical, Spacing.cardPadding)
        .background(ColorTokens.surfaceElevated)
        .cornerRadius(Radius.xl, corners: .allCorners)
    }

    private var brandAndModelContent: some View {
        VStack(spacing: Spacing.formFieldSpacing) {
            // Marque
            VStack(alignment: .leading) {
                Text("Marque")
                    .font(Typography.subheadline)
                    .foregroundStyle(ColorTokens.textPrimary)
                TextField("TOYOTA, BMW, MERCEDES...", text: $store.brand)
                    .textInputAutocapitalization(.characters)
                    .submitLabel(.done)
                    .padding(Spacing.screenMargin)
                    .background(ColorTokens.surfaceDim)
                    .cornerRadius(Radius.textField, corners: .allCorners)
                Label("Champ D.1 de la carte grise", systemImage: "info.circle")
                    .font(Typography.footnote)
                    .foregroundStyle(ColorTokens.textSecondary)
            }

            // Modèle
            VStack(alignment: .leading) {
                Text("Modèle")
                    .font(Typography.subheadline)
                    .foregroundStyle(ColorTokens.textPrimary)
                TextField("COROLLA, X3, CLASSE A...", text: $store.model)
                    .textInputAutocapitalization(.characters)
                    .submitLabel(.done)
                    .padding(Spacing.screenMargin)
                    .background(ColorTokens.surfaceDim)
                    .cornerRadius(Radius.textField, corners: .allCorners)
                Label("Champ D.2 de la carte grise", systemImage: "info.circle")
                    .font(Typography.footnote)
                    .foregroundStyle(ColorTokens.textSecondary)
            }

            // Plaque d'immatriculation
            VStack(alignment: .leading) {
                Text("Immatriculation")
                    .font(Typography.subheadline)
                    .foregroundStyle(ColorTokens.textPrimary)
                TextField("AB-123-CD", text: $store.plate)
                    .textInputAutocapitalization(.characters)
                    .submitLabel(.done)
                    .padding(Spacing.screenMargin)
                    .background(ColorTokens.surfaceDim)
                    .cornerRadius(Radius.textField, corners: .allCorners)
                Label("Champ A de la carte grise", systemImage: "info.circle")
                    .font(Typography.footnote)
                    .foregroundStyle(ColorTokens.textSecondary)
            }

            // Date de mise en circulation
            VStack(alignment: .leading) {
                Text("Mise en circulation")
                    .font(Typography.subheadline)
                    .foregroundStyle(ColorTokens.textPrimary)
                DatePicker("Date", selection: $store.registrationDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(Spacing.sm)
                    .background(ColorTokens.surfaceDim)
                    .cornerRadius(Radius.textField, corners: .allCorners)
                Label("Champ B de la carte grise", systemImage: "info.circle")
                    .font(Typography.footnote)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
        }
        .padding(Spacing.cardPadding)
        .background(ColorTokens.surfaceElevated)
        .cornerRadius(Radius.xl, corners: .allCorners)
    }

    private var detailsContent: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Kilométrage
            VStack(alignment: .leading) {
                Text("Kilométrage")
                    .font(Typography.subheadline)
                    .foregroundStyle(ColorTokens.textPrimary)

                HStack {
                    TextField("120000", text: $store.mileage)
                        .keyboardType(.numberPad)

                    Text("km")
                        .foregroundStyle(ColorTokens.textSecondary)
                }
                .padding(Spacing.screenMargin)
                .background(ColorTokens.surfaceDim)
                .cornerRadius(Radius.textField, corners: .allCorners)

                Label("Consultez votre compteur", systemImage: "info.circle")
                    .font(Typography.footnote)
                    .foregroundStyle(ColorTokens.textSecondary)
            }

            // Véhicule principal
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Toggle(isOn: $store.isPrimary) {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("Véhicule principal")
                            .font(Typography.subheadline)
                            .foregroundStyle(ColorTokens.textPrimary)

                        Text("Définir comme véhicule principal")
                            .font(Typography.caption1)
                            .foregroundStyle(ColorTokens.textSecondary)
                    }
                }
                .toggleStyle(.switch)
                .tint(ColorTokens.actionPrimary)
            }
            .padding(Spacing.md)
            .background(ColorTokens.surfaceDim)
            .cornerRadius(Radius.md)
        }
        .padding(Spacing.md)
        .background(ColorTokens.surfaceElevated)
        .cornerRadius(Radius.md)
    }
}

#Preview {
    NavigationStack {
        AddVehicleMultiStepView(store: Store(initialState: AddVehicleStore.State()) {
            AddVehicleStore()
        })
    }
}
