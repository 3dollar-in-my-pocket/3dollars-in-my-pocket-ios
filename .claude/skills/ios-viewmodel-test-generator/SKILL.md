---
name: ios-viewmodel-test-generator
description: iOS ViewModel 테스트 코드 생성 템플릿. TC(테스트 케이스) 목록을 받아 Given-When-Then XCTest 코드를 이 레포 관례(@testable import Feature, Support 공용 목, test_{티켓}_TC{n}_ 네이밍)로 만든다. 보통 /test-cases 스킬이 승인된 TC 표를 넘겨 호출한다.
---

# iOS ViewModel 테스트 생성

규칙의 원본은 `docs/process/testing.md`. 여기에는 코드 템플릿만 둔다.

## 입력
- 대상 ViewModel 이름과 모듈 (예: `StoreSectionsViewModel`, `Store`)
- 승인된 테스트 케이스 표 (티켓 키 / 테크스펙 TC 번호 / Given / When / Then / 메서드명)
- TC 번호는 **테크스펙의 `TC-n` 을 그대로** 쓴다. 파일이 갈라져도 1부터 다시 시작하지 않는다

## 파일

`App/Targets/three-dollar-in-my-pocketTests/Sources/ViewModelTests/{ViewModel}Tests.swift`

```swift
import Combine
import XCTest

import Log
import Model
import Networking
@testable import Store   // 대상 Feature 모듈. Input/Output/Route/Dependency 가 internal 이라 @testable 필수

final class StoreSectionsViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1337 TC5

    func test_TH1337_TC5_로드하면_섹션이전달된다() async throws {
        // Given
        let repository = MockStoreRepository(fetchStoreScreenV2Result: .success(try makeResponse()))
        let viewModel = makeViewModel(repository: repository)
        let expectation = expectation(description: "sections")
        var received: [any StoreSectionComponent] = []
        viewModel.output.sections
            .sink { received = $0; expectation.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(received.count, 1)
    }

    // MARK: TH-1337 TC6 (동기 Input → Route)

    func test_TH1337_TC6_리뷰작성액션이면_리뷰작성Route가발행된다() {
        // Given
        let viewModel = makeViewModel(repository: MockStoreRepository())
        let expectation = expectation(description: "route")
        viewModel.output.route
            .sink { if case .presentWriteReview = $0 { expectation.fulfill() } }
            .store(in: &cancellables)

        // When
        viewModel.input.didSelectAction.send(.custom(.init(actionType: .storeReviewWrite), clickLog: nil))

        // Then
        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Helpers

    private func makeViewModel(repository: MockStoreRepository, logManager: MockLogManager = MockLogManager()) -> StoreSectionsViewModel {
        StoreSectionsViewModel(
            config: .init(storeId: 1, latitude: 37.5, longitude: 127.0),
            dependency: .init(storeRepository: repository, logManager: logManager)
        )
    }

    private func makeResponse() throws -> StoreScreenV2Response {
        try FixtureLoader.decode(StoreScreenV2Response.self, from: "StoreScreenV2WithCallout")
    }
}
```

## 판단 규칙

| 상황 | 패턴 |
|---|---|
| Input이 ViewModel 안에서 `Task { }`로 감싸짐 (`load`, `didTapSave` 등) | `async` 테스트 + `expectation` + `await fulfillment(of:timeout:)` |
| Input이 동기 (`didTap*`, `willDisplay`, `updateCards` 등) | `send` 직후 단언 또는 `wait(for:)` |
| Route 검증 | `if case .xxx = route { fulfill }` |
| 로그 검증 | `MockLogManager.sentEvents` / `pageViews` 단언 |
| 에러 경로 | 목 `xxxResult = .failure(NSError(domain:code:))` → `output.error` 구독 |
| State 검증 | Output으로 드러나는 결과로만. 접근 제어를 풀지 않는다 |

## 목·픽스처
- 목은 `Sources/Support/Mock{Protocol}.swift`. 없으면 만든다: 메서드마다 `var {메서드}Result = .failure(MockError.notStubbed())`, 스파이가 필요하면 `private(set) var xxxCalls`.
- 테스트 파일 안 `private class Mock...` 금지.
- 픽스처는 `Resources/*.json` 실서버 응답, `FixtureLoader.decode(_:from:)`.

## 실행
스킴 `three-dollar-in-my-pocketTests`, 목적지는 `simctl`로 확인한 UDID. 대상 Feature 모듈이 테스트 타깃 의존성에 없으면 `App/Project.swift`에 `.Feature.xxx` 추가 후 `make project`.
