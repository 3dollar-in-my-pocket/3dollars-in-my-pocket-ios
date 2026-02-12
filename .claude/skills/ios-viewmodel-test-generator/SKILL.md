---
name: ios-viewmodel-test-generator
description: iOS ViewModel 유저 플로우 기반 테스트 코드 자동 생성. Given-When-Then 패턴으로 Input/Output 검증 테스트를 생성합니다. XCTest와 Combine을 사용하며, 다른 iOS 프로젝트에서도 재사용 가능합니다.
---

# iOS ViewModel 테스트 생성

## 개요

ViewModel의 유저 플로우를 기반으로 XCTest 테스트 코드를 자동 생성합니다. Given-When-Then 패턴을 따르며, Mock Repository를 사용하여 네트워크 의존성을 제거합니다.

## 핵심 원칙

1. **Given-When-Then 패턴**: 테스트 구조를 명확히 합니다
2. **유저 플로우 기반**: 실제 사용자 시나리오를 테스트합니다
3. **Input → Output 검증**: ViewModel의 Input 이벤트가 Output으로 올바르게 변환되는지 확인합니다
4. **Mock Repository**: 네트워크 호출을 Mock으로 대체합니다
5. **XCTest 프레임워크**: iOS 표준 테스트 프레임워크 사용

## 테스트 파일 구조

### 위치
```
App/Targets/three-dollar-in-my-pocketTests/
└── ViewModelTests/
    ├── ContributorsViewModelTests.swift
    ├── StoreDetailViewModelTests.swift
    └── ...
```

### 네이밍 규칙
- 파일명: `{ViewModel이름}Tests.swift`
- 클래스명: `{ViewModel이름}Tests`
- 테스트 메서드: `test_{when}_{then}()`

## Given-When-Then 패턴

### 구조

```swift
func test_사용자가로드버튼을탭하면_데이터가로드된다() async {
    // Given: 초기 상태 설정
    let mockRepository = MockStoreRepository()
    mockRepository.fetchStoreContributorHistoriesResult = .success(mockResponse)

    let dependency = ContributorsViewModel.Dependency(
        storeRepository: mockRepository
    )
    let config = ContributorsViewModel.Config(storeId: 123, store: nil)
    let viewModel = ContributorsViewModel(config: config, dependency: dependency)

    var receivedItems: [SDUItem] = []
    viewModel.output.items
        .sink { items in
            receivedItems = items
        }
        .store(in: &cancellables)

    // When: 로드 액션 실행
    viewModel.input.load.send(())

    // Then: 결과 검증
    await Task.yield()
    XCTAssertFalse(receivedItems.isEmpty)
    XCTAssertEqual(receivedItems.count, 3)
}
```

### Given (초기 상태 설정)
- Mock Repository 생성 및 설정
- Dependency 주입
- ViewModel 생성
- Output 구독 설정

### When (액션 실행)
- Input 이벤트 전송 (viewModel.input.load.send(()))

### Then (결과 검증)
- await Task.yield() (비동기 처리 대기)
- XCTAssert로 결과 검증

## 전체 테스트 파일 템플릿

```swift
import XCTest
import Combine
@testable import three_dollar_in_my_pocket

final class ContributorsViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - 데이터 로드 테스트

    func test_사용자가로드버튼을탭하면_데이터가로드된다() async {
        // Given
        let mockRepository = MockStoreRepository()
        let mockResponse = StoreContributorHistoriesSection(
            data: .init(
                cursor: "next-cursor",
                cards: [
                    .init(data: .callout(.init(
                        promptTitle: .init(spans: [.init(text: "테스트 제목")]),
                        description: .init(spans: [.init(text: "테스트 설명")]),
                        style: .init(backgroundColor: "#FFFFFF")
                    ))),
                    .init(data: .iconText(.init(
                        icon: .init(imageUrl: "https://example.com/icon.png"),
                        text: .init(spans: [.init(text: "아이콘 텍스트")])
                    ))),
                    .init(data: .callout(.init(
                        promptTitle: .init(spans: [.init(text: "두 번째 제목")]),
                        description: .init(spans: [.init(text: "두 번째 설명")]),
                        style: .init(backgroundColor: "#EEEEEE")
                    )))
                ]
            )
        )
        mockRepository.fetchStoreContributorHistoriesResult = .success(mockResponse)

        let dependency = ContributorsViewModel.Dependency(
            storeRepository: mockRepository,
            logManager: MockLogManager()
        )
        let config = ContributorsViewModel.Config(storeId: 123, store: nil)
        let viewModel = ContributorsViewModel(config: config, dependency: dependency)

        var receivedItems: [SDUItem] = []
        viewModel.output.items
            .sink { items in
                receivedItems = items
            }
            .store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        await Task.yield()
        XCTAssertFalse(receivedItems.isEmpty)
        XCTAssertEqual(receivedItems.count, 3)
    }

    func test_네트워크에러가발생하면_에러메시지가전달된다() async {
        // Given
        let mockRepository = MockStoreRepository()
        let expectedError = NSError(domain: "Test", code: -1, userInfo: nil)
        mockRepository.fetchStoreContributorHistoriesResult = .failure(expectedError)

        let dependency = ContributorsViewModel.Dependency(
            storeRepository: mockRepository,
            logManager: MockLogManager()
        )
        let config = ContributorsViewModel.Config(storeId: 123, store: nil)
        let viewModel = ContributorsViewModel(config: config, dependency: dependency)

        var receivedError: Error?
        viewModel.output.error
            .sink { error in
                receivedError = error
            }
            .store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        await Task.yield()
        XCTAssertNotNil(receivedError)
        XCTAssertEqual((receivedError as NSError?)?.code, -1)
    }

    // MARK: - 화면 전환 테스트

    func test_닫기버튼을탭하면_dismiss라우팅이발생한다() {
        // Given
        let mockRepository = MockStoreRepository()
        let dependency = ContributorsViewModel.Dependency(
            storeRepository: mockRepository,
            logManager: MockLogManager()
        )
        let config = ContributorsViewModel.Config(storeId: 123, store: nil)
        let viewModel = ContributorsViewModel(config: config, dependency: dependency)

        var receivedRoute: ContributorsViewModel.Route?
        viewModel.output.route
            .sink { route in
                receivedRoute = route
            }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapClose.send(())

        // Then
        guard case .dismiss = receivedRoute else {
            XCTFail("Expected dismiss route")
            return
        }
    }

    // MARK: - 페이지네이션 테스트

    func test_추가로드시_커서가전달된다() async {
        // Given
        let mockRepository = MockStoreRepository()
        let firstResponse = StoreContributorHistoriesSection(
            data: .init(cursor: "first-cursor", cards: [])
        )
        let secondResponse = StoreContributorHistoriesSection(
            data: .init(cursor: "second-cursor", cards: [])
        )
        mockRepository.fetchStoreContributorHistoriesResult = .success(firstResponse)

        let dependency = ContributorsViewModel.Dependency(
            storeRepository: mockRepository,
            logManager: MockLogManager()
        )
        let config = ContributorsViewModel.Config(storeId: 123, store: nil)
        let viewModel = ContributorsViewModel(config: config, dependency: dependency)

        // When: 첫 번째 로드
        viewModel.input.load.send(())
        await Task.yield()

        // Then: 커서가 저장되었는지 확인
        mockRepository.fetchStoreContributorHistoriesResult = .success(secondResponse)
        viewModel.input.loadMore.send(())
        await Task.yield()

        XCTAssertEqual(mockRepository.lastCursor, "first-cursor")
    }
}

// MARK: - Mock Repository

final class MockStoreRepository: StoreRepository {
    var fetchStoreContributorHistoriesResult: Result<StoreContributorHistoriesSection, Error>?
    var lastCursor: String?

    func fetchStoreContributorHistories(storeId: Int, cursor: String?) async -> Result<StoreContributorHistoriesSection, Error> {
        lastCursor = cursor
        guard let result = fetchStoreContributorHistoriesResult else {
            return .failure(NSError(domain: "Mock", code: -1))
        }
        return result
    }

    // 다른 메서드들은 기본 구현 제공
    func createStore(input: UserStoreCreateRequestV3, nonceToken: String) async -> Result<UserStoreResponse, Error> {
        return .failure(NSError(domain: "Not implemented", code: -1))
    }

    // ... 나머지 메서드들
}

// MARK: - Mock LogManager

final class MockLogManager: LogManagerProtocol {
    func sendPageView(screen: ScreenName, type: AnyClass) { }
    func sendEvent(_ event: LogEvent) { }
}
```

## Mock Repository 생성 패턴

### 기본 구조
```swift
final class MockMyRepository: MyRepository {
    var fetchDataResult: Result<MyDataResponse, Error>?
    var lastRequestInput: FetchDataInput?

    func fetchData(input: FetchDataInput) async -> Result<MyDataResponse, Error> {
        lastRequestInput = input  // 호출 파라미터 저장
        guard let result = fetchDataResult else {
            return .failure(NSError(domain: "Mock", code: -1))
        }
        return result
    }
}
```

### 규칙
1. **Result 타입 프로퍼티**: 각 메서드마다 Result 타입 프로퍼티 생성
2. **호출 파라미터 저장**: 테스트에서 올바른 파라미터가 전달되었는지 검증
3. **기본 에러 반환**: result가 nil이면 기본 에러 반환

## 유저 플로우 시나리오

### 기본 시나리오

1. **데이터 로드**: 사용자가 화면에 진입하면 데이터가 로드된다
   ```swift
   func test_사용자가화면에진입하면_데이터가로드된다() async
   ```

2. **추가 로드**: 사용자가 스크롤하면 추가 데이터가 로드된다
   ```swift
   func test_사용자가스크롤하면_추가데이터가로드된다() async
   ```

3. **에러 처리**: 네트워크 에러 발생 시 에러 메시지가 표시된다
   ```swift
   func test_네트워크에러시_에러메시지가전달된다() async
   ```

4. **화면 전환**: 사용자가 버튼을 탭하면 다음 화면으로 이동한다
   ```swift
   func test_버튼탭시_다음화면으로이동한다()
   ```

### 엣지 케이스

1. **빈 데이터**: 서버에서 빈 배열이 반환되면 적절한 UI를 표시한다
   ```swift
   func test_빈데이터반환시_빈상태UI가표시된다() async
   ```

2. **중복 요청 방지**: 로딩 중 추가 요청이 발생하면 무시한다
   ```swift
   func test_로딩중_추가요청은무시된다() async
   ```

3. **빠른 연속 탭**: 버튼을 빠르게 여러 번 탭해도 한 번만 실행된다
   ```swift
   func test_빠른연속탭_한번만실행된다()
   ```

## async/await 테스트 패턴

### await Task.yield() 사용
```swift
// When
viewModel.input.load.send(())

// Then
await Task.yield()  // 비동기 처리 대기
XCTAssertFalse(receivedItems.isEmpty)
```

**주의사항**:
- async 메서드 호출 후 await Task.yield() 필수
- MainActor 메서드의 경우 UI 업데이트 대기

### 여러 번 대기
```swift
viewModel.input.load.send(())
await Task.yield()

viewModel.input.loadMore.send(())
await Task.yield()
```

## Combine 구독 패턴

### Output 구독
```swift
var receivedItems: [SDUItem] = []
viewModel.output.items
    .sink { items in
        receivedItems = items
    }
    .store(in: &cancellables)
```

### Route 구독
```swift
var receivedRoute: MyViewModel.Route?
viewModel.output.route
    .sink { route in
        receivedRoute = route
    }
    .store(in: &cancellables)
```

### Error 구독
```swift
var receivedError: Error?
viewModel.output.error
    .sink { error in
        receivedError = error
    }
    .store(in: &cancellables)
```

## XCTest Assertions

### 기본 검증
```swift
XCTAssertTrue(condition)
XCTAssertFalse(condition)
XCTAssertEqual(value1, value2)
XCTAssertNotEqual(value1, value2)
XCTAssertNil(value)
XCTAssertNotNil(value)
```

### 배열 검증
```swift
XCTAssertFalse(receivedItems.isEmpty)
XCTAssertEqual(receivedItems.count, 3)
XCTAssertEqual(receivedItems.first?.id, expectedId)
```

### Route 검증
```swift
guard case .dismiss = receivedRoute else {
    XCTFail("Expected dismiss route")
    return
}

guard case .pushDetail(let viewModel) = receivedRoute else {
    XCTFail("Expected pushDetail route")
    return
}
XCTAssertNotNil(viewModel)
```

### Error 검증
```swift
XCTAssertNotNil(receivedError)
XCTAssertEqual((receivedError as NSError?)?.code, -1)
XCTAssertEqual((receivedError as NSError?)?.domain, "Test")
```

## 테스트 커버리지 목표

### 필수 테스트
1. **Input → Output 경로**: 모든 Input 이벤트가 올바른 Output을 생성하는지 확인
2. **Success/Failure 경로**: 네트워크 성공/실패 시나리오 모두 테스트
3. **Route 이벤트**: 모든 화면 전환 경로 검증
4. **State 변화**: 내부 상태가 올바르게 업데이트되는지 확인 (간접 검증)

### 선택 테스트
1. **페이지네이션**: cursor 전달 및 추가 로드
2. **중복 요청 방지**: isLoading 상태 검증
3. **엣지 케이스**: 빈 데이터, nil 값 등

## 사용 시 주의사항

1. **async/await 테스트**: 메서드에 async 키워드 추가 필수
2. **Combine 구독**: cancellables에 저장, tearDown에서 제거
3. **Mock 데이터**: 실제 서버 응답과 동일한 구조 사용
4. **테스트 메서드명**: 한글로 작성하여 가독성 향상
5. **Given-When-Then 주석**: 테스트 구조를 명확히 표시
6. **XCTest import**: @testable import로 internal 멤버 접근
7. **Task.yield()**: async 메서드 호출 후 반드시 호출

## 실제 사용 예시

### ContributorsViewModel 테스트

```swift
final class ContributorsViewModelTests: XCTestCase {
    func test_로드시_3개아이템이반환된다() async {
        // Given
        let mockRepository = MockStoreRepository()
        mockRepository.fetchStoreContributorHistoriesResult = .success(mockResponse)
        let viewModel = ContributorsViewModel(
            config: .init(storeId: 123, store: nil),
            dependency: .init(storeRepository: mockRepository)
        )

        var receivedItems: [SDUItem] = []
        viewModel.output.items
            .sink { receivedItems = $0 }
            .store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        await Task.yield()
        XCTAssertEqual(receivedItems.count, 3)
    }
}
```

## 파일 위치

```
App/Targets/three-dollar-in-my-pocketTests/
└── ViewModelTests/
    ├── ContributorsViewModelTests.swift
    ├── StoreDetailViewModelTests.swift
    └── ...
```

**네이밍**:
- 파일명: `{ViewModel이름}Tests.swift`
- 클래스명: `{ViewModel이름}Tests`
