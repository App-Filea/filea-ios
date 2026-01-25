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

    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Color.accentColor
                        .opacity(0.2)
                        .frame(width: 32, height: 32)
                        .cornerRadius(8)
                        .overlay {
                            Image(systemName: "bell")
                                .foregroundStyle(Color.accentColor)
                        }
                    
                    Text("technical_inspection_next_title")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.secondary)
                }
                if let inspection = store.latestTechnicalInspection {
                    HStack {
                        Text("technical_inspection_next_date")
                    }
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primary)
                    
                    HStack {
                        Text("technical_inspection_next_days")
                    }
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                } else {
                    Text("technical_inspection_no_next")
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

#Preview("Not empty") {
    @Shared(.selectedVehicle) var selectedVehicle: Vehicle = .init(id: "1", documents: [.init(fileURL: "", name: "", date: .now, mileage: "", type: .technicalInspection)])
    TechnicalInspectionView(store: .init(initialState: TechnicalInspectionStore.State(), reducer: { TechnicalInspectionStore() }))
}

#Preview("Empty") {
    TechnicalInspectionView(store: .init(initialState: TechnicalInspectionStore.State(), reducer: { TechnicalInspectionStore() }))
}
