//
//  RecentActivitiesStore.swift
//  Holfy
//
//  Created by Claude on 2026-01-27.
//

import ComposableArchitecture
import Foundation

@Reducer
struct RecentActivitiesStore {
    @ObservableState
    struct State: Equatable {
        @Shared(.selectedVehicle) var selectedVehicle: Vehicle
        
        var recentActivities: [Document] {
            selectedVehicle.documents
                .sorted { $0.date > $1.date }
                .prefix(5)
                .map { $0 }
        }
    }
    
    enum Action: Equatable {}
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
