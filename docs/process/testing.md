# 테스트 작성 가이드

테스트는 **diff가 아니라 의도 문서(테크스펙)의 TC에서 도출한다.** AI가 코드를 쓰더라도 "무엇을 검증할지"는 사람이 TC 목록으로 먼저 승인하고, 코드는 그 다음이다.
프로세스 전체 그림은 `docs/process/tech-spec-process.md`, 아키텍처 규칙은 `docs/architecture/RULES.md`.

## 흐름

```
노션 테크스펙 TC-1..n
   │  /3dollars:test-cases  (브랜치명 → 티켓 키 → 지라 `테크스펙` 필드 → 노션)
   ▼
TC별 계층 배정 (유닛 / 자동화 / 수동)  ──▶ 사람 승인
   │              │                  │
   ▼              ▼                  ▼
유닛 테스트 코드   simulator-test     PR 본문 체크박스
   │              │                  │
   ▼              ▼                  ▼
CI 커버리지 표    스크린샷·영상 증거    작성자 체크
```

## 테스트의 세 계층

| 계층 | 무엇을 검증 | 실행 주체·시점 | 증거 |
|---|---|---|---|
| **1. 유닛 테스트 코드** | ViewModel Input→Output/Route, Service 로직, 응답 디코딩 | `xcodebuild test` — CI가 PR마다 | CI 코멘트의 TC 커버리지 표 |
| **2. 자동화 테스트 TC** | 시뮬레이터를 에이전트가 조작해 화면을 실제로 거치는 E2E. 탭·스와이프·딥링크를 넣고 스크린샷·영상으로 판정 | `3dollars:simulator-test` — PR 올리기 전, 이번 티켓 TC만 | PR 본문 "증거" 섹션의 스크린샷·영상 |
| **3. 수동 테스트 TC** | 시뮬레이터로 상황 자체를 만들 수 없어 실기기·사람이 필요한 것 | 작성자 — PR 올리기 전 | PR 본문 체크박스 |

- 테크스펙 TC 하나는 **반드시 셋 중 하나 이상**에 배정된다. 어디에도 없는 TC가 있으면 PR을 열 수 없다.
- **위 계층을 먼저 쓴다.** 유닛으로 덮이면 유닛, 안 되면 자동화, 그것도 안 되면 수동. 계층을 내릴 때는 이유가 있어야 한다.
- 한 TC가 두 계층에 걸쳐도 된다 (로그 파라미터는 유닛, 화면 전환은 자동화).
- **2와 3의 경계는 "시뮬레이터로 그 상황을 만들 수 있는가" 하나다.** 판정이 사람 눈이어야 한다는 건 2번이지 3번이 아니다 — 조작은 에이전트가 하고 스크린샷·영상을 증거로 남긴다.

### 무엇이 어느 계층인가

| 대상 | 계층 | 이유 |
|---|---|---|
| Input → Output/Route, State 전이, 로그 전송 | 1 유닛 | ViewModel 경계에서 단언된다 |
| 서버 JSON 디코딩, API path·method·param | 1 유닛 | 순수 함수 |
| 화면 진입·전환, 버튼 탭 후 결과, 목록 갱신 | 2 자동화 | 실제 화면을 거쳐야 의미가 있다 |
| 애니메이션·제스처, 바텀시트 스냅 | 2 자동화 | 영상으로 판정 |
| 지도(네이버맵) 마커·클러스터·카메라 | 2 자동화 | 스크린샷으로 판정 |
| OS 권한 팝업 | 2 자동화 | `simctl privacy reset` 후 재현 |
| 푸시 수신·딥링크 진입 | 2 자동화 | `simctl push` / `simctl openurl` |
| 다크모드·기기 폭·긴 텍스트·빈 데이터·오프라인 | 2 자동화 | 시뮬레이터 설정·Proxyman으로 상태를 만든다 |
| 카카오·애플 로그인, 카카오 공유 | 3 수동 | 시뮬레이터에 해당 앱·계정이 없다 |
| 애드몹 실광고, 인앱 결제·리뷰, 앱스토어 이동 | 3 수동 | 시뮬레이터에 기능 자체가 없다 |

세부 항목과 화면 변경 PR 공통 체크는 `docs/process/e2e-and-manual-tests.md`.

## 1. 유닛 테스트 코드

### 종류

| 계층 | 검증 대상 | 위치 | 대표 예 |
|---|---|---|---|
| **ViewModel** (화면 로직) | Input → Output/Route 변환, State 전이, 로그 전송 | `Sources/ViewModelTests/` | `StoreSectionsViewModelTests` |
| **Service** (서비스·매니저) | Core/App의 서비스 클래스 기능. 입력 → 결과/부수효과 | `Sources/ServiceTests/` | `DeepLinkHandlerTests`, `LogManagerTests`, `XxxApiTests`(경로·메서드·파라미터) |
| **Decoding** (응답 파싱) | 서버 JSON → Model 타입 디코딩, 미지의 값 처리 | `Sources/DecodingTests/` | `StoreCalloutSectionTests` |
| 공용 | 목·픽스처 로더 | `Sources/Support/` | `MockLogManager`, `MockStoreRepository`, `FixtureLoader` |

화면 TC는 기본적으로 **ViewModel 테스트**로 쓴다. ViewController·View는 테스트하지 않는다(R5 덕분에 ViewModel만으로 화면 로직이 검증된다).
서비스 TC는 테크스펙에 서비스/매니저 변경이 있을 때 **ServiceTests**로 쓴다. 대상 목록: Core의 `LogManager`, `LocationManager`, `ImageUploadService`, `NetworkManager`(RequestProvider/ResponseProvider), App의 `DeepLinkHandler`, `GlobalEventBus`, `RemoteConfigService`, `KakaoSigninManager`/`AppleSigninManager`, 그리고 21개 `XxxRepositoryImpl`/`XxxApi`.

### 파일 위치 · 네이밍

```
App/Targets/three-dollar-in-my-pocketTests/
├── Sources/
│   ├── ViewModelTests/{ViewModel이름}Tests.swift
│   ├── ServiceTests/{서비스이름}Tests.swift
│   ├── DecodingTests/{응답타입}Tests.swift
│   └── Support/Mock{Protocol}.swift, FixtureLoader.swift, MockError.swift
└── Resources/{픽스처}.json
```

- 테스트 메서드명: **`test_{티켓}_TC{n}_{조건}_{기대결과}()`** — 한글 허용. 티켓 키는 하이픈을 뺀다 (`TH-1340` → `TH1340`).
  - `test_TH1340_TC1_탭이_홈_제보_커뮤니티_마이페이지_순서로_4개다()`
  - `test_TH1337_TC5_삭제된가게면_서버메시지와함께_상세를닫는Route가발행된다()`
  - TC 하나를 여러 메서드로 나누면 전부 같은 접두: `test_TH1337_TC2_...` 2개
  - TC와 무관한 회귀 테스트는 `test_회귀_...` 접두 (예: 예전 버그 재발 방지)
- **TC 번호는 테크스펙(티켓) 안에서 유일하다. 노션 테크스펙의 `TC-n` 을 그대로 가져다 쓴다.**
  - 화면·서비스별로 파일이 갈라져도 번호는 스펙 순서 그대로다. **파일마다 1부터 다시 시작하지 않는다.**
  - 티켓 키가 네임스페이스라, 한 클래스에 여러 티켓의 테스트가 쌓여도 번호가 충돌하지 않는다.
  - 한 TC를 ViewModel·Decoding 등 여러 클래스에서 검증해도 번호는 하나다. 클래스는 커버리지 표에서 구분된다.
  - 테크스펙에 없는 케이스를 테스트로 만들고 싶으면 **테크스펙에 TC를 먼저 추가**하고 그 번호를 쓴다. 코드가 스펙보다 앞서가지 않는다.
  - 테크스펙이 없는 티켓(버그·태스크)은 티켓 안에서 1부터 순서대로 붙인다. 이때 번호의 원본은 PR 본문이다.
- `// MARK: {티켓} TC{n}` 으로 묶는다 (`// MARK: TH-1337 TC5`).
- Given / When / Then 주석 3개를 반드시 쓴다.

### 실행

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

### CI (PR 증거)

`.github/workflows/test.yml`이 PR마다 macOS 러너에서 전체 테스트를 돌리고:
- `scripts/test-summary.sh`로 결과를 마크다운(전체 결과 / 실패 목록 / **TC 커버리지 표** / 전체 목록)으로 만들어 **PR 코멘트(갱신형)** 와 Job Summary에 붙인다
- `tests.xcresult`를 아티팩트로 올린다(14일)
- 실패한 테스트가 있으면 체크가 빨간불

TC 커버리지 표는 메서드명 `test_{티켓}_TC{n}_` 접두로 뽑아 티켓별·스펙 번호순으로 정렬한다. 그래서 네이밍 규칙이 곧 증거 규칙이다. 스펙 TC 중 표에 없는 번호가 곧 미커버 TC다.
UI 회귀는 스냅샷 테스트를 쓰지 않는다. 2번 계층(자동화 테스트 TC)이 대신한다.

### ViewModel 테스트 작성법

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

    // MARK: TH-1337 TC5

    func test_TH1337_TC5_로드하면_섹션이전달된다() async throws {
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

### 목(Mock) 규칙

- 위치 `Sources/Support/Mock{Protocol}.swift`, 클래스명 `Mock{Protocol}` (`MockStoreRepository`, `MockLogManager`).
- 메서드마다 `var {메서드}Result: Result<..., Error> = .failure(MockError.notStubbed())` 프로퍼티. 스텁 안 한 메서드가 호출되면 `notStubbed(함수명)` 실패로 흘러 테스트 메시지에 드러난다. `fatalError` 금지.
- 호출 기록이 필요하면 `private(set) var xxxCalls: [입력]` 배열로 스파이.
- 테스트 파일 안에 `private class Mock...`을 만들지 않는다. 공용으로 빼야 다음 테스트가 재사용한다.

### 픽스처 규칙

- 가상 데이터를 손으로 만들지 말고 **실서버 응답**을 쓴다. Proxyman으로 잡아 `Resources/{화면}{상황}.json`으로 저장 (`StoreScreenV2WithCallout.json`). `{ok, data}` 래퍼는 벗기고 `data`만 저장.
- 로드: `FixtureLoader.decode(StoreScreenV2Response.self, from: "StoreScreenV2WithCallout")`.
- 서버가 안 내려주는 분기(알 수 없는 enum 값, 필드 누락)는 실데이터를 복사해 값만 바꾼 파일을 별도로 둔다.

### Service 테스트 작성법

- **순수 로직 서비스**(DeepLinkHandler의 URL 파싱, GlobalEventBus 발행/구독, RemoteConfig 값 매핑): 입력을 주고 결과·부수효과를 단언. 외부 SDK(Firebase, Kakao)는 protocol 뒤에 숨겨져 있을 때만 테스트 가능 → 안 숨겨져 있으면 먼저 protocol로 분리하는 게 테스트의 일부다.
- **API 정의**(`XxxApi: RequestType`): `path`, `method`, `param` 인코딩을 단언. 서버 계약이 바뀌었을 때 가장 싸게 잡히는 테스트.
  ```swift
  func test_TH1337_TC9_가게상세API는_v2경로와GET을쓴다() {
      let api = StoreApi.fetchStoreScreenV2(input: .init(storeId: 1, latitude: 0, longitude: 0))
      XCTAssertEqual(api.path, "/api/v2/screen/store/1")
      XCTAssertEqual(api.method, .get)
  }
  ```
- **RepositoryImpl**은 `NetworkManager`를 그대로 부르는 얇은 래퍼라 보통 테스트하지 않는다. 응답 변환 로직이 있으면 그 부분만.
- App 타깃의 서비스는 `@testable import dollar_in_my_pocket`(PRODUCT_MODULE_NAME)으로 접근한다.

### Decoding 테스트 작성법

- 실서버 픽스처로 `Decodable` 타입을 디코딩하고, 필드 값·enum 매핑·기본값을 단언.
- 필수: **알 수 없는 enum 값이 와도 크래시 없이 `.unknown`/nil로 떨어지는지**. 서버가 값을 추가해도 구버전 앱이 죽지 않아야 한다.

## 2. 자동화 테스트 TC

시뮬레이터를 에이전트가 직접 조작해 TC 조건을 만들고, 스크린샷·영상으로 판정한다. 실행은 `3dollars:simulator-test`.

- **테스트 코드를 만들지 않는다.** XCTest UI 테스트도 쓰지 않는다. 산출물은 코드가 아니라 증거다.
- **시나리오의 원본은 테크스펙 TC 한 줄이다.** Given/When/Then 을 그대로 스킬에 넘긴다. 재현 단계를 레포에 따로 파일로 두지 않는다 (스펙과 이중 관리가 되면 둘 다 썩는다).
- **언제**: PR 올리기 전, **이번 티켓의 자동화 TC만** 돌린다. 과거 TC 회귀는 기본으로 돌리지 않는다.
- **판정**: 스킬이 케이스마다 `PASS` / `FAIL` / `UNCLEAR` / `BLOCKED` 를 매긴다. **UNCLEAR·BLOCKED 는 통과가 아니다** — 재현 경로를 고치거나 수동 TC로 내린다.
- **증거**: 스크린샷·영상을 PR 본문 "증거" 섹션에 TC 번호와 함께 붙인다 (`/3dollars:pr-body` 가 레포의 `verification-assets` prerelease 에 올려 다운로드 URL 로 건다. git 브랜치에 커밋하지 않는다).

```
| TC | 시나리오 | 결과 | 증거 |
|---|---|---|---|
| TC-3 | 전체화면에서 "지도 보기" 탭 → 시트가 tip 으로 내려감 | ✅ PASS | before.png / after.png |
| TC-5 | 시트 드래그 중 버튼 알파 연속 변화 | ✅ PASS | drag.mp4 |
```

## 3. 수동 테스트 TC

시뮬레이터로 **상황 자체를 만들 수 없는 것만** 남는다 (외부 SDK 로그인·공유, 애드몹 실광고, 인앱 결제·리뷰, 실기기 푸시).
목록과 화면 변경 PR 공통 체크 항목은 `docs/process/e2e-and-manual-tests.md`.
PR 본문에 체크박스로 넣고 **작성자가 올리기 전에 체크**한다. 리뷰어는 미체크 항목이 있으면 머지하지 않는다.

## PR에 남기는 것

`/3dollars:pr-body`가 PR 본문 `## TC` 섹션 맨 위에 **커버리지 표**를 넣는다. 사람은 이 표만 본다.
표는 세션 기억이 아니라 매번 **노션 스펙 TC 목록 + 레포의 `test_{티켓}_TC{n}_` 메서드 + `simulator-test` 판정**으로 다시 만든다. 그래서 `/3dollars:test-cases` 를 다른 세션에서 돌렸어도 빠지지 않는다.

```markdown
커버리지 3/4 · ⚠️ 미커버 TC-6

| TC | 내용 | 계층 | 테스트 / 증거 | 결과 |
|---|---|---|---|---|
| TC-1 | 신고 성공 시 닫힘 | 유닛 | `test_TH1337_TC1_신고에성공하면_dismissRoute가발행된다` | ✅ |
| TC-5 | 삭제된 가게 처리 | 유닛 | `test_TH1337_TC5_삭제된가게면_…` | ✅ |
| TC-6 | 중복 신고 안내 | — | — | ⚠️ 미커버 |
| TC-8 | 완료 토스트 → 닫힘 | 자동화 | report.mp4 | ✅ PASS |
```

- **미커버** = 유닛 테스트도, 자동화 PASS 증거도, 수동 배정도 없는 스펙 TC. 숨기지 않고 ⚠️ 로 보인다 — CI 코멘트의 커버리지 표는 테스트 메서드만 보므로 이걸 못 잡는다.
- 수동 TC 는 표에 `☐` 로 두고, 표 아래 체크리스트에서 작성자가 체크한다.
- CI 코멘트(`test.yml`)는 유닛 실행 결과의 원본이고, 본문 표는 **스펙 대비 커버 여부**의 원본이다.
