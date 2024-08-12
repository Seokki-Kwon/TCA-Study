# Chapter1-your first feature

## CouterFeature 추가

State
```swift
 @ObservableState
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isLoading = false
        var isTimerRunning = false
    }
```
View에서 사용될 상태값 테스트를 위해서 Equatable 프로토콜을 채택해야한다.

Action
```swift
enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
        case factButtonTapped
        case factResponse(String)
        case timerTick
        case toggleTimerButtonTapped
    }
```
View에서 발생하는 인터랙션을 정의 연관값을 이용하여 값을 넘겨줄 수 있음 View에서는 send를 이용하여 타입을 넘겨준다.

Reducer 함수
```swift
var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                state.fact = nil
                return .none
                
            case .incrementButtonTapped:
                state.count += 1
                state.fact = nil
                return .none
            case .factButtonTapped:
                state.fact = nil
                state.isLoading = true
                
                return .run { [count = state.count] send in
                    let (data, _) = try await URLSession.shared
                        .data(from: URL(string: "http://numbersapi.com/\(count)")!)
                    let fact = String(decoding: data, as: UTF8.self)
                    await send(.factResponse(fact))
                }
            case let .factResponse(fact):
                state.fact = fact
                state.isLoading = false
                return .none
            case .timerTick:
                state.count += 1
                state.fact = nil
                return .none
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    return .run { send in
                        for await _ in self.clock.timer(interval: .seconds(1)) {
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    return .cancel(id: CancelID.timer)
                }
            }
        }
    }
```
Reducer 함수를 통해서 상태값을 변화하거나 사이드이펙트를 발생시킨다. 이때 Effect를 발생시키는데 `.none` 의 경우 아무런 추가작업 없이 즉시 완료되는 효과이다. 주로 외부와 통신없이 상태값만 변경하는 경우에 사용한다.

`.run` 의 경우 비동기 작업을 래핑하고 작업을 여러번 내보낸다. 즉 API 요청이나 타이머와같은 비동기 작업은 .run으로 효과를 내보내고 또다른 Action으로 그 값을 받아서 처리할 수 있다.

```swift
 case .factButtonTapped:
                state.fact = nil
                state.isLoading = true
                
                return .run { [count = state.count] send in
                    let (data, _) = try await URLSession.shared
                        .data(from: URL(string: "http://numbersapi.com/\(count)")!)
                    let fact = String(decoding: data, as: UTF8.self)
                    await send(.factResponse(fact))
                }
```
factButtonTapped 액션을 받으면 .run 클로저 내부에서 작업을 수행하고 그 결과를 다른 Action으로 결과값을 전송한다.

CounterView

```swift
struct CounterView: View {
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        VStack {
            Text("\(store.count)")
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
            HStack {
                Button("-") {
                    store.send(.decrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
                
                Button("+") {
                    store.send(.incrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
            }
    }
```
View에서 사용할때는 StoreOf로 해당 스토어를 가져와서 View에 바인딩해서 사용한다.
