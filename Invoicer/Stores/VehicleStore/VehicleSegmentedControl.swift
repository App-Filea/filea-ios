//
//  SwiftUIView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 28/09/2025.
//

import SwiftUI

struct VehicleSegmentedControl: View {
    var tabs: [VehicleSegmentedTab]
    @Binding var activeTab: VehicleSegmentedTab
    var height: CGFloat = 45
    var activeTint: Color
    var inActiveTint: Color
    
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        activeTab = tab
                    }
                }) {
                    if activeTab == tab {
                        Text(tab.rawValue.capitalized)
                            .bodyDefaultSemibold()
                            .foregroundColor(activeTint)
                            .frame(/*maxWidth: .infinity, */maxHeight: .infinity)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                    } else {
                        Text(tab.rawValue.capitalized)
                            .bodyDefaultSemibold()
                            .foregroundColor(inActiveTint)
                            .frame(maxHeight: .infinity)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                    }

                }
                .background(
                    ZStack {
                        if activeTab == tab {
                            RoundedRectangle(cornerRadius: 0)
                                .fill(.blue)
                                .frame(height: 2)
                                .offset(y: 2)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                                .matchedGeometryEffect(id: "indicator", in: animation)
                        }
                    }
                )
            }
            Spacer()
        }
        .frame(height: height)
    }
}

#Preview {
    @Previewable @State var activeTab: VehicleSegmentedTab = .historique
    VehicleSegmentedControl(tabs: VehicleSegmentedTab.allCases, activeTab: $activeTab, activeTint: .blue, inActiveTint: .gray)
}

enum VehicleSegmentedTab: String, CaseIterable {
    case historique = "Historique"
    case documents = "Documents"
}
