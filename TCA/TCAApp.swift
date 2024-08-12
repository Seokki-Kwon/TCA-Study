//
//  TCAApp.swift
//  TCA
//
//  Created by 권석기 on 8/12/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCAApp: App {
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            CounterView(store: TCAApp.store)
        }
    }
}
