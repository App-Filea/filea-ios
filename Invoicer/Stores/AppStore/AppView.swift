//
//  AppView.swift
//  Invoicer
//
//  Created by Nicolas Barbosa on 06/09/2025.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<AppStore>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {
                Text("LaunchScreen")
            }
            .onAppear {
                store.send(.initiate)
            }
        } destination: { store in
            switch store.state {
            case .main:
                if let store = store.scope(state: \.main, action: \.main) {
                    MainView(store: store)
                }
            case .vehicle:
                if let store = store.scope(state: \.vehicle, action: \.vehicle) {
                    VehicleView(store: store)
                }
            case .addVehicle:
                if let store = store.scope(state: \.addVehicle, action: \.addVehicle) {
                    AddVehicleView(store: store)
                }
            case .editVehicle:
                if let store = store.scope(state: \.editVehicle, action: \.editVehicle) {
                    EditVehicleView(store: store)
                }
            case .addDocument:
                if let store = store.scope(state: \.addDocument, action: \.addDocument) {
                    AddDocumentView(store: store)
                }
            case .documentDetail:
                if let store = store.scope(state: \.documentDetail, action: \.documentDetail) {
                    DocumentDetailCoordinatorView(store: store)
                }
            case .editDocument:
                if let store = store.scope(state: \.editDocument, action: \.editDocument) {
                    EditDocumentView(store: store)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    AppView(store: Store(initialState: AppStore.State()) {
        AppStore()
    })
}
