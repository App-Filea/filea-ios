//
//  TechnicalInspectionView.swift
//  Holfy
//
//  Created by Nicolas Barbosa on 25/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct TechnicalInspectionView: View {
    @Bindable var store: StoreOf<TechnicalInspectionStore>

    private var statusColor: Color {
        if store.isExpired {
            return .red
        } else if store.isExpiringSoon {
            return .orange
        }
        return .accentColor
    }

    private var formattedExpirationDate: String {
        guard let date = store.nextExpirationDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }

    private var daysText: String {
        guard let days = store.daysUntilExpiration else { return "" }
        if days < 0 {
            let absDays = abs(days)
            return String(format: NSLocalizedString("technical_inspection_expired", comment: ""), absDays)
        } else if days == 0 {
            return NSLocalizedString("technical_inspection_today", comment: "")
        } else if days == 1 {
            return String(format: NSLocalizedString("technical_inspection_next_days_one", comment: ""), days)
        } else {
            return String(format: NSLocalizedString("technical_inspection_next_days", comment: ""), days)
        }
    }

    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    statusColor
                        .opacity(0.2)
                        .frame(width: 32, height: 32)
                        .cornerRadius(8)
                        .overlay {
                            Image(systemName: store.isExpired ? "exclamationmark.triangle" : "bell")
                                .foregroundStyle(statusColor)
                        }

                    Text("technical_inspection_next_title")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.secondary)
                }

                if store.nextExpirationDate != nil {
                    Text(formattedExpirationDate)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(statusColor)

                    Text(daysText)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                } else if store.latestTechnicalInspection != nil {
                    Text("technical_inspection_no_expiration")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                } else {
                    Text("technical_inspection_no_inspection")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                }
            }
            .padding(Spacing.cardPadding)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(Radius.card)
    }
}

#Preview("With expiration date") {
    @Shared(.selectedVehicle) var selectedVehicle: Vehicle = .init(
        id: "1",
        documents: [
            .init(
                fileURL: "",
                name: "CT 2024",
                date: .now,
                mileage: "",
                type: .technicalInspection,
                expirationDate: Calendar.current.date(byAdding: .day, value: 45, to: Date())
            )
        ]
    )
    return TechnicalInspectionView(store: .init(initialState: TechnicalInspectionStore.State(), reducer: { TechnicalInspectionStore() }))
}

#Preview("Expiring soon") {
    @Shared(.selectedVehicle) var selectedVehicle: Vehicle = .init(
        id: "1",
        documents: [
            .init(
                fileURL: "",
                name: "CT 2024",
                date: .now,
                mileage: "",
                type: .technicalInspection,
                expirationDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())
            )
        ]
    )
    return TechnicalInspectionView(store: .init(initialState: TechnicalInspectionStore.State(), reducer: { TechnicalInspectionStore() }))
}

#Preview("Expired") {
    @Shared(.selectedVehicle) var selectedVehicle: Vehicle = .init(
        id: "1",
        documents: [
            .init(
                fileURL: "",
                name: "CT 2024",
                date: .now,
                mileage: "",
                type: .technicalInspection,
                expirationDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())
            )
        ]
    )
    return TechnicalInspectionView(store: .init(initialState: TechnicalInspectionStore.State(), reducer: { TechnicalInspectionStore() }))
}

#Preview("No inspection") {
    TechnicalInspectionView(store: .init(initialState: TechnicalInspectionStore.State(), reducer: { TechnicalInspectionStore() }))
}
