//
//  VehicleCard.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  Reusable vehicle card component
//

import SwiftUI

/// Reusable vehicle card component
struct VehicleCard: View {
    let vehicle: Vehicle
    let isSelected: Bool
    let action: () -> Void

    init(vehicle: Vehicle, isSelected: Bool = false, action: @escaping () -> Void) {
        self.vehicle = vehicle
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Header with badge
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: vehicle.type.icon)
                                .font(.caption)
                                .foregroundStyle(ColorTokens.textSecondary)

                            Text(vehicle.type.rawValue)
                                .font(Typography.caption1)
                                .foregroundColor(ColorTokens.textSecondary)
                        }

                        if vehicle.isPrimary {
                            HStack(spacing: Spacing.xxs) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                Text("Principal")
                                    .font(Typography.caption2.weight(.medium))
                            }
                            .foregroundColor(ColorTokens.warning)
                        }
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(ColorTokens.success)
                    }
                }

                // Vehicle name
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(vehicle.brand.uppercased())
                        .font(Typography.title2.weight(.black))
                        .kerning(-1)
                        .foregroundColor(ColorTokens.textPrimary)

                    Text(vehicle.model)
                        .font(Typography.headline)
                        .foregroundColor(ColorTokens.textPrimary)
                }

                Spacer()

                // Footer info
                HStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(vehicle.registrationDate.year.description)
                            .font(Typography.caption1)
                    }

                    if let mileage = vehicle.mileage {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "gauge.open.with.lines.needle.33percent")
                                .font(.caption)
                            Text(mileage.asFormattedMileage)
                                .font(Typography.caption1)
                        }
                    }

                    Spacer()

                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "doc.fill")
                            .font(.caption)
                        Text("\(vehicle.documents.count)")
                            .font(Typography.caption1.weight(.medium))
                    }
                }
                .foregroundColor(ColorTokens.textSecondary)
            }
            .padding(Spacing.cardPadding)
        }
        .buttonStyle(.plain)
        .frame(height: 180)
        .background(isSelected ? ColorTokens.selection : ColorTokens.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card)
                .stroke(
                    isSelected ? ColorTokens.actionPrimary : Color.clear,
                    lineWidth: 2
                )
        )
        .cornerRadius(Radius.card)
        .shadow(
            color: ColorTokens.shadow,
            radius: isSelected ? 12 : 4,
            x: 0,
            y: isSelected ? 4 : 2
        )
    }
}

// MARK: - Vehicle Type Extension

extension VehicleType {
    var icon: String {
        switch self {
        case .car: return "car.fill"
        case .motorcycle: return "motorcycle.fill"
        case .truck: return "truck.box.fill"
        case .bicycle: return "bicycle"
        case .other: return "questionmark.circle.fill"
        }
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        VehicleCard(
            vehicle: Vehicle(
                id: "uuid",
                type: .car,
                brand: "Tesla",
                model: "Model 3",
                mileage: "45000",
                registrationDate: Date(),
                plate: "AB-123-CD",
                isPrimary: true,
                documents: Array(repeating: Document(
                    fileURL: "/path",
                    name: "Doc",
                    date: Date(),
                    mileage: "1000",
                    type: .maintenance
                ), count: 12)
            ),
            isSelected: false,
            action: {}
        )

        VehicleCard(
            vehicle: Vehicle(
                id: "uuid2",
                type: .motorcycle,
                brand: "Harley",
                model: "Davidson",
                mileage: "12000",
                registrationDate: Date(),
                plate: "EF-456-GH",
                isPrimary: false,
                documents: []
            ),
            isSelected: true,
            action: {}
        )
    }
    .padding()
    .background(Color(.secondarySystemBackground))
}
