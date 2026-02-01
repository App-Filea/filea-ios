//
//  WarningListView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 25/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct WarningListView: View {
    @Bindable var store: StoreOf<WarningListStore>

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            if !store.hasAlerts {
                emptyStateView
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        // Section Contrôle Technique
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            ForEach(store.technicalInspectionAlerts) { alert in
                                VStack(alignment: .leading) {
                                    HStack {
                                        alert.alertPriority.color
                                            .opacity(0.2)
                                            .frame(width: 64, height: 64)
                                            .cornerRadius(8)
                                            .overlay {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundStyle(alert.alertPriority.color)
                                                    .scaleEffect(1.5)
                                            }

                                        Spacer()
                                    }
                                    Text("Controle technique")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    Text("Votre controle technique arrive bientôt à échéance, prenez rendez-vous pour le repasser.")
                                    
//                                    AlertCard(alert: alert) {
//                                        store.send(.view(.alertTapped(alert)))
//                                    }
                                    HStack(spacing: Spacing.sm) {
                                        Circle()
                                            .fill(Color.accentColor.opacity(0.2))
                                            .frame(width: 32, height: 32)
                                            .overlay {
                                                Image(systemName: "calendar")
                                                    .foregroundStyle(Color.accentColor)
                                            }

                                        VStack(alignment: .leading, spacing: Spacing.xxs) {
//                                            Text(alert.message)
//                                                .primaryBody()
//                                                .fontWeight(.semibold)

                                            if let daysRemaining = alert.daysRemaining {
                                                HStack(spacing: Spacing.xxs) {
                                                    Image(systemName: "1.calendar")
                                                    Text("alert_days_remaining \(daysRemaining)")
                                                }
                                                .callout()
                                                .foregroundStyle(alert.alertPriority.color)
                                            }
//
//                                            Text(alert.relatedDocument.name)
//                                                .callout()
//                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()
                                    }
                                    .padding(Spacing.cardPadding)
                                    .buttonStyle(.plain)
                                    .background(Color(.tertiarySystemGroupedBackground))
                                    .cornerRadius(Radius.card)
                                }
                            }
                        }

                        // Section Documents Incomplets
//                        if !store.incompleteDocumentAlerts.isEmpty {
//                            VStack(alignment: .leading, spacing: Spacing.sm) {
//                                Text("warning_section_incomplete_documents")
//                                    .font(.title2)
//                                    .fontWeight(.semibold)
//
//                                ForEach(store.incompleteDocumentAlerts) { alert in
//                                    DocumentCard(document: alert.relatedDocument) {
//                                        store.send(.view(.alertTapped(alert)))
//                                    }
//                                }
//                            }
//                        }
                    }
                    .padding(Spacing.md)
                }
            }
        }
        .navigationTitle("stat_card_warnings_title")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
//            store.send(.view(.initiate))
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            VStack(spacing: Spacing.sm) {
                Text("warning_list_empty_title")
                    .largeTitle()

                Text("warning_list_empty_subtitle")
//                    .body()
//                    .multilineTextAlignment(.center)
            }

            Spacer()

            PrimaryButton("warning_list_back_to_dashboard") {
                store.send(.view(.dismissButtonTapped))
            }
            .padding(.horizontal, Spacing.screenMargin)
        }
        .padding(Spacing.screenMargin)
    }
}

#Preview("With alerts") {
    let ctDocument = Document(fileURL: "", name: "CT 2024", date: .now, mileage: "", type: .technicalInspection)
    let incompleteDoc = Document(fileURL: "", name: "Vidange", date: .now, mileage: "", type: .maintenance)

    let alerts: [VehicleAlert] = [
        .init(type: .technicalInspection, message: "CT expire dans 15 jours", daysRemaining: 15, relatedDocument: ctDocument),
        .init(type: .incompleteDocument, message: "Vidange - montant manquant", relatedDocument: incompleteDoc),
    ]

    NavigationView {
        WarningListView(store: Store(initialState: WarningListStore.State(alerts: alerts)) {
            WarningListStore()
        })
    }
}

#Preview("Empty - All good") {
    WarningListView(store: Store(initialState: WarningListStore.State()) {
        WarningListStore()
    })
}
