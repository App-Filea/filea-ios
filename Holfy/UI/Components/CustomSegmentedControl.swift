//
//  CustomSegmentedControl.swift
//  Holfy
//
//  Created by Claude Code on 15/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct CustomSegmentedControl: View {
    let store: StoreOf<VehicleDetailTabStore>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(VehicleDetailTabStore.Tab.allCases, id: \.self) { tab in
                    TabButton(
                        tab: tab,
                        isSelected: store.selectedTab == tab,
                        action: { store.send(.tabSelected(tab)) }
                    )
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

private struct TabButton: View {
    let tab: VehicleDetailTabStore.Tab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16))
                Text(tab.rawValue)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(isSelected ? Color.accentColor : Color(.tertiarySystemGroupedBackground))
            )
        }
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityLabel(tab.rawValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    CustomSegmentedControl(
        store: Store(
            initialState: VehicleDetailTabStore.State(),
            reducer: { VehicleDetailTabStore() }
        )
    )
}
