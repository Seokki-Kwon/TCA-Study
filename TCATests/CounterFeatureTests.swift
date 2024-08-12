//
//  CounterFeatureTests.swift
//  TCATests
//
//  Created by 권석기 on 8/12/24.
//

import ComposableArchitecture
import XCTest

@testable import TCA

@MainActor
final class CounterFeatureTests: XCTestCase {
    func testCounter() async {

        let store = TestStore(initialState: CounterFeature.State()) {
             CounterFeature()
           }
        
        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }
        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }
    }
    
    func testTimer() async {
        let clock = TestClock()
        
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }
        
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
        }
        // timerTick 액션이 실행되고나서 예상값
        // 1초가 지나기전에 테스트가 실패하기 때문에 timeout을 걸어준다.
//        await store.receive(\.timerTick, timeout: .seconds(2)) {
//            $0.count = 1
//        }
        
        // 시계를 1초씩 앞당긴다?
        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick) {
            $0.count = 1
        }
        
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = false
        }
    }
    
    func testNumberFact() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.numberFact.fetch = { "\($0) is a good number" }
        }
        
        await store.send(.factButtonTapped) {
            $0.isLoading = true
        }
        
        await store.receive(\.factResponse) {
            $0.isLoading = false
            $0.fact = "0 is a good number"
        }
    }
}
