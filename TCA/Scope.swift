//
//  Child.swift
//  TCA
//
//  Created by 권석기 on 9/23/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct Child {
    @ObservableState
    struct State {
        var count = 0
    }
    
    enum Action {
        case increment
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .increment:
                print("Child count incremnet")
                state.count += 1
                return .none
            }
        }
    }
}

@Reducer
struct Parent {
    @ObservableState
    struct State {
        var count = 0
        var child: Child.State
    }
    
    enum Action {
        case child(Child.Action)
        case increment
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.child, action: \.child) {
            Child()
        }
        Reduce { state, action in
            switch action {
            case .increment:
                print("Parent count incremnet")
                state.count += 1
                return .none
            case .child(.increment):
                print("Child count increment detected")
                return .none
            }
        }
    }
}

struct ScopeView: View {
    let store: StoreOf<Parent>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Parent Count: \(store.state.count)")
                
                ChildView(store: store.scope(state: \.child, action: \.child))
                
                Button(action: {
                    store.send(.increment)
                }, label: {
                    Text("Parent Button")
                })
            }
        }
    }
}

struct ChildView: View {
    let store: StoreOf<Child>
    
    var body: some View {
        WithPerceptionTracking {
            Text("Child Count: \(store.count)")
            
            Button(action: {
                store.send(.increment)
            }) {
                Text("Child Button")
            }
        }
    }
}
