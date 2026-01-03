//
//  UnitAndMeasureSettingView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 03/01/2026.
//

import SwiftUI
import ComposableArchitecture

struct UnitAndMeasureSettingView: View {
    @Bindable var store: StoreOf<UnitAndMeasureSettingStore>
    
    var body: some View {
        Text("hello World")
    }
}

#Preview {
    UnitAndMeasureSettingView(store: .init(initialState: UnitAndMeasureSettingStore.State(), reducer: { UnitAndMeasureSettingStore() }))
}
