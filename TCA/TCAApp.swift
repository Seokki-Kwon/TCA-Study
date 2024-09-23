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
    let store = Store(initialState: Parent.State(child: Child.State())) {
        Parent()
    }
    
    var body: some Scene {
        WindowGroup {
            ScopeView(store: store)
        }
    }
}
