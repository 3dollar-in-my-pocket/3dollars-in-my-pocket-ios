# 테스트 작성 가이드

테스트는 **diff가 아니라 의도 문서(테크스펙)의 TC에서 도출한다.** AI가 코드를 쓰더라도 "무엇을 검증할지"는 사람이 TC 목록으로 먼저 승인하고, 코드는 그 다음이다.
프로세스 전체 그림은 `docs/process/tech-spec-process.md`, 아키텍처 규칙은 `docs/architecture/RULES.md`.

## 흐름

```
노션 테크스펙 TC-1..n
   │  /3dollars:test-cases  (브랜치명 → 티켓 키 → 지라 `테크스펙` 필드 → 노션)
   ▼
TC별 테스트 케이스 표 (자연어, 자동/수동 분류)  ──▶ 사람 승인
   │
   ▼
테스트 코드 (자동 TC만)          수동 TC ──▶ PR 본문 수동 체크리스트
   │
   ▼
xcodebuild test 결과 ──▶ PR 본문 "TC 커버리지" 표
```

- **TC 하나당** 테스트 메서드 1개 이상 **또는** 수동 체크리스트 항목 1개. 둘 다 없는 TC는 PR을 열 수 없다.
- 수동 TC는 코드로 만들지 않는다. 자동화 대상이 아닌 것: 애니메이션·제스처, 지도(네이버맵) 렌더링, 외부 SDK(카카오 로그인·공유, 애드몹), OS 권한 팝업, 푸시 수신.

## 테스트 계층

| 계층 | 검증 대상 | 위치 | 대표 예 |
|---|---|---|---|
| **ViewModel** (화면 로직) | Input → Output/Route 변환, State 전이, 로그 전송 | `Sources/ViewModelTests/` | `StoreSectionsViewModelTests` |
| **Service** (서비스·매니저) | Core/App의 서비스 클래스 기능. 입력 → 결과/부수효과 | `Sources/ServiceTests/` | `DeepLinkHandlerTests`, `LogManagerTests`, `XxxApiTests`(경로·메서드·파라미터) |
| **Decoding** (응답 파싱) | 서버 JSON → Model 타입 디코딩, 미지의 값 처리 | `Sources/DecodingTests/` | `StoreCalloutSectionTests` |
| 공용 | 목·픽스처 로더 | `Sources/Support/` | `MockLogManager`, `MockStoreRepository`, `FixtureLoader` |

화면 TC는 기본적으로 **ViewModel 테스트**로 쓴다. ViewController·View는 테스트하지 않는다(R5 덕분에 ViewModel만으로 화면 로직이 검증된다).
서비스 TC는 테크스펙에 서비스/매니저 변경이 있을 때 **ServiceTests**로 쓴다. 대상 목록: Core의 `LogManager`, `LocationManager`, `ImageUploadService`, `NetworkManager`(RequestProvider/ResponseProvider), App의 `DeepLinkHandler`, `GlobalEventBus`, `RemoteConfigService`, `KakaoSigninManager`/`AppleSigninManager`, 그리고 21개 `XxxRepositoryImpl`/`XxxApi`.

## 파일 위치 · 네이밍

```
App/Targets/three-dollar-in-my-pocketTests/
├── Sources/
│   ├── ViewModelTests/{ViewModel이름}Tests.swift
│   ├── ServiceTests/{서비스이름}Tests.swift
│   ├── DecodingTests/{응답타입}Tests.swift
│   └── Support/Mock{Protocol}.swift, FixtureLoader.swift, MockError.swift
└── Resources/{픽스처}.json
```

- 테스트 메서드명: **`test_TC{n}_{조건}_{기대결과}()`** — 한글 허용, TC 번호가 접두로 들어가야 grep으로 커버리지를 뽑을 수 있다.
  - `test_TC1_로드하면_섹션이전달된다()`
  - `test_TC3_네트워크실패하면_error가전달된다()`
  - TC 하나를 여러 메서드로 나누면 전부 같은 접두: `test_TC2_...`, `test_TC2_...`
  - TC와 무관한 회귀 테스트는 `test_회귀_...` 접두 (예: 예전 버그 재발 방지)
- Given / When / Then 주석 3개를 반드시 쓴다.

## 실행

```bash
# 전체 (스킴은 three-dollar-in-my-pocketTests. -debug 스킴에는 test action이 없다)
xcodebuild test \
  -workspace 3dollar-in-my-pocket.xcworkspace \
  -scheme three-dollar-in-my-pocketTests \
  -destination 'platform=iOS Simulator,id=<simctl로 확인한 UDID>'

# 특정 클래스만
  -only-testing:three-dollar-in-my-pocketTests/StoreSectionsViewModelTests
```

시뮬레이터는 `xcrun simctl list devices available | grep iPhone`으로 고른다. `generic/platform=iOS Simulator`는 아키텍처 에러로 실패한다.
Buildable Folders 구조라 테스트 파일·픽스처를 추가해도 `make project`는 필요 없다. 단, 새 Feature 모듈을 `@testable import` 하려면 `App/Project.swift`의 테스트 타깃 `dependencies`에 `.Feature.xxx`를 추가하고 `make project`.

## CI (PR 증거)

`.github/workflows/test.yml`이 PR마다 macOS 러너에서 전체 테스트를 돌리고:
- `scripts/test-summary.sh`로 결과를 마크다운(전체 결과 / 실패 목록 / **TC 커버리지 표** / 전체 목록)으로 만들어 **PR 코멘트(갱신형)** 와 Job Summary에 붙인다
- `tests.xcresult`를 아티팩트로 올린다(14일)
- 실패한 테스트가 있으면 체크가 빨간불

TC 커버리지 표는 메서드명 `test_TC{n}_` 접두로 뽑는다. 그래서 네이밍 규칙이 곧 증거 규칙이다.
UI 회귀는 스냅샷 테스트 대신 `3dollars:simulator-test` 스킬로 시나리오별 스크린샷/영상을 찍어 PR 본문 Before/After 표에 첨부한다.

## ViewModel 테스트 작성법

```swift
import Combine
import XCTest

import Log
import Model
import Networking
@testable import Store          // Input/Output/Route/Dependency 가 internal 이라 @testable

final class StoreSectionsViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func test_TC1_로드하면_섹션이전달된다() async throws {
        // Given
        let repository = MockStoreRepository(fetchStoreScreenV2Result: .success(try makeResponse()))
        let viewModel = makeViewModel(repository: repository)
        let expectation = expectation(description: "sections")
        var received: [any StoreSectionComponent] = []
        viewModel.output.sections.sink { received = $0; expectation.fulfill() }.store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(received.count, 1)
    }
}
```

- **Dependency는 목으로 주입**한다. Repository는 `Support/Mock{Repository}.swift`, 로그는 `MockLogManager`.
- **비동기 판단**: ViewModel에서 `Task { }`로 감싼 Input(보통 `load`, `didTapSave`류)은 `expectation` + `await fulfillment`. 동기 Input은 `send` 후 바로 단언.
- **Route 검증**: `if case .presentXxx = route { fulfill }` 패턴.
- **로그 검증**: `MockLogManager.sentEvents`/`pageViews`로 어떤 이벤트가 몇 번 갔는지 단언. 로그 파라미터 회귀는 여기서 잡는다.
- **State 검증**: State가 private이면 Output으로 드러나는 결과로 검증한다. State를 노출하려고 접근 제어를 풀지 않는다.

## 목(Mock) 규칙

- 위치 `Sources/Support/Mock{Protocol}.swift`, 클래스명 `Mock{Protocol}` (`MockStoreRepository`, `MockLogManager`).
- 메서드마다 `var {메서드}Result: Result<..., Error> = .failure(MockError.notStubbed())` 프로퍼티. 스텁 안 한 메서드가 호출되면 `notStubbed(함수명)` 실패로 흘러 테스트 메시지에 드러난다. `fatalError` 금지.
- 호출 기록이 필요하면 `private(set) var xxxCalls: [입력]` 배열로 스파이.
- 테스트 파일 안에 `private class Mock...`을 만들지 않는다. 공용으로 빼야 다음 테스트가 재사용한다.

## 픽스처 규칙

- 가상 데이터를 손으로 만들지 말고 **실서버 응답**을 쓴다. Proxyman으로 잡아 `Resources/{화면}{상황}.json`으로 저장 (`StoreScreenV2WithCallout.json`). `{ok, data}` 래퍼는 벗기고 `data`만 저장.
- 로드: `FixtureLoader.decode(StoreScreenV2Response.self, from: "StoreScreenV2WithCallout")`.
- 서버가 안 내려주는 분기(알 수 없는 enum 값, 필드 누락)는 실데이터를 복사해 값만 바꾼 파일을 별도로 둔다.

## Service 테스트 작성법

- **순수 로직 서비스**(DeepLinkHandler의 URL 파싱, GlobalEventBus 발행/구독, RemoteConfig 값 매핑): 입력을 주고 결과·부수효과를 단언. 외부 SDK(Firebase, Kakao)는 protocol 뒤에 숨겨져 있을 때만 테스트 가능 → 안 숨겨져 있으면 먼저 protocol로 분리하는 게 테스트의 일부다.
- **API 정의**(`XxxApi: RequestType`): `path`, `method`, `param` 인코딩을 단언. 서버 계약이 바뀌었을 때 가장 싸게 잡히는 테스트.
  ```swift
  func test_TC4_가게상세API는_v2경로와GET을쓴다() {
      let api = StoreApi.fetchStoreScreenV2(input: .init(storeId: 1, latitude: 0, longitude: 0))
      XCTAssertEqual(api.path, "/api/v2/screen/store/1")
      XCTAssertEqual(api.method, .get)
  }
  ```
- **RepositoryImpl**은 `NetworkManager`를 그대로 부르는 얇은 래퍼라 보통 테스트하지 않는다. 응답 변환 로직이 있으면 그 부분만.
- App 타깃의 서비스는 `@testable import dollar_in_my_pocket`(PRODUCT_MODULE_NAME)으로 접근한다.

## Decoding 테스트 작성법

- 실서버 픽스처로 `Decodable` 타입을 디코딩하고, 필드 값·enum 매핑·기본값을 단언.
- 필수: **알 수 없는 enum 값이 와도 크래시 없이 `.unknown`/nil로 떨어지는지**. 서버가 값을 추가해도 구버전 앱이 죽지 않아야 한다.

## PR에 남기는 것

`/3dollars:test-cases`가 아래 표를 만들어 PR 본문에 넣는다. 사람은 이 표만 본다.

| TC | 테스트 | 결과 |
|---|---|---|
| TC-1 | `test_TC1_로드하면_섹션이전달된다` | ✅ |
| TC-2 | 수동 — 지도 마커 애니메이션 | ☐ 체크리스트 |
| TC-3 | `test_TC3_네트워크실패하면_error가전달된다` | ✅ |
