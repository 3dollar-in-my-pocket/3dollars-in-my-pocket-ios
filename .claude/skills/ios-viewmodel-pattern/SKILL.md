---
name: ios-viewmodel-pattern
description: iOS MVVM 패턴의 ViewModel 구조 정의. Input/Output/Route/Config/Dependency/State 패턴으로 ViewModel을 생성합니다. Combine 기반으로 작동하며, 다른 iOS 프로젝트에서도 재사용 가능합니다.
---

# iOS ViewModel 패턴

## 개요

Combine 기반 MVVM 패턴의 ViewModel 구조를 정의합니다. BaseViewModel을 상속하며, Input/Output/Route/Config/Dependency/State 패턴을 따릅니다.

## 핵심 원칙

1. **BaseViewModel 상속 필수**: 모든 ViewModel은 BaseViewModel을 상속합니다
2. **Input/Output 패턴**: 단방향 데이터 흐름을 명확히 합니다
3. **Combine 기반**: PassthroughSubject와 CurrentValueSubject를 사용합니다
4. **async/await 통합**: 네트워크 호출 등은 async/await로 처리합니다

## 구조

### Input
뷰컨트롤러에서 ViewModel로 전달하는 이벤트를 정의합니다. PassthroughSubject로 선언합니다.

```swift
struct Input {
    let load = PassthroughSubject<Void, Never>()
    let didTapClose = PassthroughSubject<Void, Never>()
    let didTapEdit = PassthroughSubject<Void, Never>()
    let loadMore = PassthroughSubject<Void, Never>()
}
```

**규칙**:
- PassthroughSubject 사용 (즉시 값 전달)
- Error는 Never로 설정 (에러는 Output으로 전달)
- 동사 형태로 네이밍 (load, didTap, fetch 등)

### Output
ViewModel에서 뷰컨트롤러로 전달하는 데이터 및 이벤트를 정의합니다.

```swift
struct Output {
    let screenName: ScreenName = .storeContributors
    let items = PassthroughSubject<[SDUItem], Never>()
    let route = PassthroughSubject<Route, Never>()
    let error = PassthroughSubject<Error, Never>()
}
```

**규칙**:
- PassthroughSubject 또는 CurrentValueSubject 사용
- 데이터, 라우팅, 에러를 분리하여 전달
- screenName은 로깅용 (선택사항)

### Route
화면 전환 경로를 정의합니다. 라우팅 로직이 없다면 생략 가능합니다.

```swift
enum Route {
    case dismiss
    case pushDetail(DetailViewModel)
    case pushEditStore(EditStoreViewModelInterface)
}
```

**규칙**:
- enum으로 정의
- 필요한 ViewModel이나 데이터를 associated value로 전달
- 네이밍: dismiss, push{화면명}, present{화면명}

### Config
ViewModel 생성 시 필요한 초기 설정 값을 정의합니다.

```swift
public struct Config {
    let storeId: Int
    let store: UserStoreResponse?

    public init(storeId: Int, store: UserStoreResponse?) {
        self.storeId = storeId
        self.store = store
    }
}
```

**규칙**:
- struct로 정의
- public init 제공
- 불변 데이터 (let으로 선언)
- 생성자 주입으로 전달

### Dependency
외부 의존성 (Repository, LogManager 등)을 정의합니다. 의존성이 없다면 생략 가능합니다.

```swift
struct Dependency {
    let storeRepository: StoreRepository
    let logManager: LogManagerProtocol

    init(
        storeRepository: StoreRepository = StoreRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.storeRepository = storeRepository
        self.logManager = logManager
    }
}
```

**규칙**:
- struct로 정의
- 기본값 제공 (테스트 시 Mock 주입 가능)
- Protocol 타입으로 의존성 주입

### State
ViewModel 내부 상태를 정의합니다. 상태가 없다면 생략 가능합니다.

```swift
struct State {
    var cursor: String?
    var isLoading: Bool = false
}
```

**규칙**:
- struct로 정의
- 가변 상태 (var로 선언)
- 초기값 제공

## 전체 템플릿

```swift
import Foundation
import Combine

import Common
import Log
import Model
import Networking

extension MyViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let didTapButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let screenName: ScreenName = .myScreen
        let items = PassthroughSubject<[MyItem], Never>()
        let route = PassthroughSubject<Route, Never>()
        let error = PassthroughSubject<Error, Never>()
    }

    enum Route {
        case dismiss
        case pushDetail(MyDetailViewModel)
    }

    public struct Config {
        let id: Int
        let initialData: MyData?

        public init(id: Int, initialData: MyData?) {
            self.id = id
            self.initialData = initialData
        }
    }

    struct Dependency {
        let repository: MyRepository
        let logManager: LogManagerProtocol

        init(
            repository: MyRepository = MyRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.repository = repository
            self.logManager = logManager
        }
    }

    struct State {
        var cursor: String?
        var isLoading: Bool = false
    }
}

public final class MyViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state: State
    private let config: Config
    private let dependency: Dependency

    public init(config: Config, dependency: Dependency = Dependency()) {
        self.config = config
        self.dependency = dependency
        self.state = State()
    }

    public override func bind() {
        // Input → Output 바인딩
        input.load
            .withUnretained(self)
            .sink { (owner, _) in
                Task { [weak owner] in
                    await owner?.fetchData()
                }
            }
            .store(in: &cancellables)

        input.didTapButton
            .map { Route.dismiss }
            .subscribe(output.route)
            .store(in: &cancellables)
    }

    @MainActor
    private func fetchData() async {
        guard !state.isLoading else { return }
        state.isLoading = true

        let result = await dependency.repository.fetchData(
            id: config.id,
            cursor: state.cursor
        )

        state.isLoading = false

        switch result {
        case .success(let response):
            state.cursor = response.cursor
            output.items.send(response.items)

        case .failure(let error):
            output.error.send(error)
        }
    }
}
```

## bind() 메서드 패턴

### Combine 바인딩
```swift
input.load
    .withUnretained(self)
    .sink { (owner, _) in
        // 작업 수행
    }
    .store(in: &cancellables)
```

### async/await 통합
```swift
input.load
    .withUnretained(self)
    .sink { (owner, _) in
        Task { [weak owner] in
            await owner?.fetchData()
        }
    }
    .store(in: &cancellables)
```

### Route 직접 전달
```swift
input.didTapClose
    .map { Route.dismiss }
    .subscribe(output.route)
    .store(in: &cancellables)
```

### Route 로직 포함
```swift
input.didTapEdit
    .withUnretained(self)
    .sink { (owner, _) in
        owner.pushEditStore()
    }
    .store(in: &cancellables)

private func pushEditStore() {
    guard let store = config.store else { return }
    let viewModel = WriteInterface.getEditStoreViewModel(store: store)
    output.route.send(.pushEditStore(viewModel))
}
```

## async/await 메서드 패턴

```swift
@MainActor
private func fetchData() async {
    // 중복 요청 방지
    guard !state.isLoading else { return }
    state.isLoading = true

    // 네트워크 호출
    let result = await dependency.repository.fetchData(
        id: config.id,
        cursor: state.cursor
    )

    state.isLoading = false

    // 결과 처리
    switch result {
    case .success(let response):
        state.cursor = response.cursor
        output.items.send(response.items)

    case .failure(let error):
        output.error.send(error)
    }
}
```

**규칙**:
- @MainActor 사용 (UI 업데이트용)
- isLoading으로 중복 요청 방지
- Result 타입으로 성공/실패 분기

## 실제 사용 예시

### ContributorsViewModel (참고)
```swift
extension ContributorsViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let didTapClose = PassthroughSubject<Void, Never>()
        let didTapEdit = PassthroughSubject<Void, Never>()
        let loadMore = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let screenName: ScreenName = .storeContributors
        let items = PassthroughSubject<[SDUItem], Never>()
        let route = PassthroughSubject<Route, Never>()
        let error = PassthroughSubject<Error, Never>()
    }

    enum Route {
        case dismiss
        case pushEditStore(EditStoreViewModelInterface)
    }

    public struct Config {
        let storeId: Int
        let store: UserStoreResponse?
    }

    struct State {
        var cursor: String?
        var isLoading: Bool = false
    }

    struct Dependency {
        let storeRepository: StoreRepository
        let logManager: LogManagerProtocol
    }
}
```

## 사용 시 주의사항

1. **BaseViewModel 상속 필수**: Common 모듈 import 필요
2. **Input/Output은 let으로 선언**: 인스턴스 자체는 불변
3. **State는 var로 선언**: 내부 상태는 가변
4. **Dependency는 기본값 제공**: 테스트 시 Mock 주입 가능
5. **bind() 메서드에서 모든 바인딩 수행**: 생성자에서 자동 호출됨
6. **cancellables 사용**: BaseViewModel에서 제공하는 Set<AnyCancellable>
7. **@MainActor 사용**: async 메서드에서 UI 업데이트 시 필수
8. **withUnretained 사용**: 순환 참조 방지 ([weak self] 대신)

## ViewController와의 연동

ViewController에서 ViewModel을 사용할 때:

```swift
// 1. ViewModel 생성
let config = MyViewModel.Config(id: 123, initialData: nil)
let viewModel = MyViewModel(config: config)

// 2. Input 이벤트 전달
viewModel.input.load.send(())

// 3. Output 구독
viewModel.output.items
    .receive(on: DispatchQueue.main)
    .sink { items in
        // UI 업데이트
    }
    .store(in: &cancellables)
```

## 테스트

테스트 시 Dependency를 Mock으로 주입할 수 있습니다:

```swift
let mockRepository = MockMyRepository()
let dependency = MyViewModel.Dependency(
    repository: mockRepository,
    logManager: MockLogManager()
)
let viewModel = MyViewModel(config: config, dependency: dependency)
```
