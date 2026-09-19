# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

**가슴속 3천원**은 Swift와 Tuist 모듈러 아키텍처로 구축된 한국 길거리 음식 위치 발견 iOS 앱입니다. 사용자가 전국의 길거리 음식 판매점(특히 붕어빵)을 찾을 수 있도록 도와줍니다.

## 필수 명령어

### 빌드 및 개발 환경
```bash
# Ruby 의존성 설치
make install

# Xcode 프로젝트 생성 및 워크스페이스 열기
make project

# Tuist 프로젝트 설정 편집
tuist edit

# 생성된 파일 정리
make clean
```

### 빌드
```bash
# Debug 빌드
xcodebuild build \
  -workspace 3dollar-in-my-pocket.xcworkspace \
  -scheme three-dollar-in-my-pocket-debug \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro'

# Release 빌드
xcodebuild build \
  -workspace 3dollar-in-my-pocket.xcworkspace \
  -scheme three-dollar-in-my-pocket \
  -configuration Release \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro'
```

**주의사항**:
- 빌드 전 `make project`를 실행할 필요 없습니다. Buildable Folders 구조라 바로 `xcodebuild`로 빌드합니다 (Tuist 매니페스트인 `Project.swift`/`Tuist/` 변경 시에만 `make project` 재실행)
- **three-dollar-in-my-pocket-debug** 스키마 사용 (Debug 빌드)
- **three-dollar-in-my-pocket** 스키마 사용 (Release 빌드)
- `-destination`의 기기명은 **머신마다 다릅니다.** 설치된 기기를 먼저 확인하세요. 기기명이 틀리면 빌드가 시작조차 못 합니다
  ```bash
  xcrun simctl list devices available | grep iPhone
  ```
- 기기명을 고정하고 싶지 않으면 시뮬레이터 지정 없이 빌드할 수 있습니다
  ```bash
  -destination 'generic/platform=iOS Simulator'
  ```

### 테스트
```bash
# 전체 테스트 실행
xcodebuild test \
  -workspace 3dollar-in-my-pocket.xcworkspace \
  -scheme three-dollar-in-my-pocketTests \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro'

# 특정 테스트 클래스만 실행
xcodebuild test \
  -workspace 3dollar-in-my-pocket.xcworkspace \
  -scheme three-dollar-in-my-pocketTests \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -only-testing:three-dollar-in-my-pocketTests/StoreSectionsViewModelTests

# 특정 테스트 메서드만 실행
xcodebuild test \
  -workspace 3dollar-in-my-pocket.xcworkspace \
  -scheme three-dollar-in-my-pocketTests \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -only-testing:three-dollar-in-my-pocketTests/StoreSectionsViewModelTests/test_메서드명
```

**주의사항**:
- 테스트는 반드시 **three-dollar-in-my-pocketTests** 스키마로 실행합니다. `three-dollar-in-my-pocket-debug`에는 test action이 구성돼 있지 않아 테스트가 실행되지 않습니다
- `-only-testing:`은 **디렉토리 경로가 아니라 `타깃/클래스/메서드`** 형식입니다. 분류용 디렉토리(`ModelTests/` 등)는 식별자에 들어가지 않습니다

**테스트 파일 위치**: `App/Targets/three-dollar-in-my-pocketTests/Sources/`
- `ModelTests/` — 모델 디코딩/파싱 테스트
- `ViewModelTests/` — ViewModel 단위 테스트
- `Support/` — 공용 헬퍼 (`FixtureLoader` 등)
- JSON 픽스처는 `App/Targets/three-dollar-in-my-pocketTests/Resources/`에 두고 `FixtureLoader.decode(_:from:)`로 로드

ViewModel 테스트는 `@testable import {Feature}`로 작성합니다 (Input/Output/Route/Config/Dependency가 internal이며, Debug에 `ENABLE_TESTABILITY=YES`가 설정돼 있습니다).

### SwiftLint 검증
```bash
# 전체 검증
swiftlint lint

# 자동 수정
swiftlint --fix

# 특정 디렉토리 검증
swiftlint lint --path Modules/Feature/Store/Targets/Store/Sources/
```

**주의사항**:
- SwiftLint 오류가 있으면 빌드 실패
- 코드 작성 후 반드시 SwiftLint 검증 수행

## 프로젝트 구조

### Tuist 모듈러 아키텍처
- **Tuist 4.207.0**을 사용한 프로젝트 생성 및 모듈러 아키텍처
- 메인 워크스페이스: `3dollar-in-my-pocket.xcworkspace`
- 모든 소스 파일은 생성되므로 `.xcodeproj` 파일을 직접 편집하지 마세요
- **Buildable Folders(폴더 기반 구조)** 사용: Sources/Resources 폴더가 Xcode 동기화 폴더로 등록되므로, 폴더/파일 추가·삭제·리소스(문자열 등) 변경 시 `make project` 재실행 없이 바로 인식됩니다. 프로젝트 재생성은 타깃/의존성/빌드 설정 등 Tuist 매니페스트를 바꿨을 때만 필요합니다

### 모듈 구조
- 모든 코드는 기능별(Feature) 모듈, Core(공통) 모듈, App(엔트리포인트)로 분리합니다
- Feature 모듈은 실제 앱의 큰 단위 화면 단위로 분리하며, 각 모듈은 Targets, Derived 디렉토리 구조를 가집니다
- Targets 디렉토리는 피처 이름의 디렉토리(Resources, Sources로 구성), Demo(피처 모듈의 데모앱), Interface(피처 모듈을 호출할 수 있는 인터페이스) 디렉토리로 구성됩니다

### Core 모듈 (`Modules/Core/`)
- **Common**: 기본 클래스, 확장, 유틸리티 (`BaseViewController`, `BaseViewModel` 등)
- **DesignSystem**: 색상, 폰트, 아이콘, UI 컴포넌트
- **Model**: 도메인 모델, 네트워크 타입, 요청/응답 객체
- **Network**: API 정의, 리포지토리, 네트워킹 레이어
- **DependencyInjection**: DI 컨테이너 및 서비스 등록
- **Log**: 분석 및 로깅 시스템

### Feature 모듈 (`Modules/Feature/`)
- **Home**: 지도 뷰, 가게 목록, 검색 기능
- **Store**: 가게 상세, 리뷰, 방문 추적
- **Write**: 가게 생성 및 편집
- **Community**: 소셜 기능, 투표, 인기 가게
- **MyPage**: 사용자 프로필, 북마크, 설정
- **Membership**: 인증 및 사용자 온보딩

각 피처 모듈 구성:
- `Targets/{FeatureName}/Sources/`: 메인 구현부
- `Targets/Interface/Sources/`: 모듈 간 통신을 위한 공개 인터페이스
- `Targets/Demo/`: 해당 피처의 독립 실행형 데모 앱

### SDU (Server-Driven UI) 모듈 (`Modules/Feature/SDU/`)

SDU 모듈은 서버에서 전달하는 데이터 구조에 따라 동적으로 UI를 렌더링하는 시스템입니다.

**주요 컴포넌트**:
- **SDUCollectionView**: SDU 기반 CollectionView 래퍼
- **SDUDataSource**: CollectionView DataSource (UICollectionViewDiffableDataSource)
- **SDUCalloutCell**: Callout 스타일 셀 (제목 + 설명)
- **SDUIconTextCardCell**: 아이콘 + 텍스트 카드 셀

**사용 방법**:

```swift
// 1. SDUCollectionView 생성
private let sduView = SDUCollectionView()
private lazy var dataSource = SDUDataSource(collectionView: sduView.collectionView)

// 2. Layout 설정
sduView.setLayout(createLayout())

// 3. 데이터 바인딩
viewModel.output.items
    .receive(on: DispatchQueue.main)
    .sink { [weak self] items in
        self?.dataSource.reload(items)
    }
    .store(in: &cancellables)
```

**참고 파일**:
- `Modules/Feature/Store/Targets/Store/Sources/Domains/Contributors/ContributorsViewController.swift`
- `Modules/Feature/SDU/Targets/SDU/Sources/Cells/SDUCalloutCell.swift`

## 주요 개발 패턴

### ViewModel 구조 규칙

모든 화면(ViewController)용 ViewModel은 아래 구조를 반드시 따릅니다:

```swift
extension MyViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let didTapButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let screenName: ScreenName = .myScreen
        let items = PassthroughSubject<[Item], Never>()
        let route = PassthroughSubject<Route, Never>()
        let error = PassthroughSubject<Error, Never>()
    }

    enum Route {
        case dismiss
        case pushDetail(DetailViewModel)
    }

    public struct Config {
        let id: Int
        public init(id: Int) { self.id = id }
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

final class MyViewModel: BaseViewModel {
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
        input.load
            .withUnretained(self)
            .sink { (owner, _) in
                Task { [weak owner] in
                    await owner?.fetchData()
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func fetchData() async {
        guard !state.isLoading else { return }
        state.isLoading = true

        let result = await dependency.repository.fetchData(id: config.id)
        state.isLoading = false

        switch result {
        case .success(let response):
            output.items.send(response.items)
        case .failure(let error):
            output.error.send(error)
        }
    }
}
```

**구조 요소**:
- **Input**: 뷰컨트롤러에서 입력할 수 있는 이벤트 모음 (PassthroughSubject)
- **Output**: ViewModel에서 뷰컨트롤러로 전달하는 이벤트 모음
- **Route**: 연결된 ViewController에서 이동할 수 있는 라우팅 테이블 (선택사항)
- **Dependency**: ViewModel에서 의존하는 외부 클래스 (Repository, LogManager 등, 선택사항)
- **State**: ViewModel에서 가지고 있어야 할 상태 변수 (선택사항)
- **Config**: ViewModel을 생성하는데 필요한 변수 (선택사항)

### ViewController & MVVM 패턴 규칙

- 모든 ViewController는 BaseViewController를 상속합니다 (Common 모듈에서 `import Common` 필요)
- ViewModel은 생성자 주입 방식으로 연결
- Route 처리는 extension으로 분리

```swift
final class MyViewController: BaseViewController {
    private let viewModel: MyViewModel

    func bind() {
        viewModel.output.route
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
    }
}

// MARK: Route
extension MyViewController {
    private func handleRoute(_ route: MyViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true)
        case .pushDetail(let viewModel):
            pushDetailViewController(viewModel)
        }
    }
}
```

### UI 가이드라인

- **코드 기반 UI만 사용** - SnapKit으로 Auto Layout 구성
- SnapKit 사용 시 left, right 대신 leading, trailing을 사용합니다
- 색상, 폰트, 아이콘, 버튼 등은 반드시 DesignSystem(Colors, Fonts, Icons 등)으로만 사용합니다
- **신규 코드에서 `then` 라이브러리 사용 금지** - Swift 표준 문법(클로저, var/let 선언 후 속성 설정 등)을 사용합니다

UI 컴포넌트 생성 예시:
```swift
// 권장 방식
private let label: UILabel = {
    let label = UILabel()
    label.text = "텍스트"
    label.textColor = Colors.gray100
    label.font = Fonts.semiBold.font(size: 16)
    return label
}()

// 비권장(금지) 방식
private let label = UILabel().then {
    $0.text = "텍스트"
    $0.textColor = .black
}
```

### Network/Repository/Model 규칙

- 모든 API는 enum + RequestType 프로토콜 확장으로 구현합니다
- Repository는 Protocol + Impl 구조로 분리합니다
- API/Repository/Model 네이밍은 서버에서 정의한 네이밍과 동일하게 정의합니다

```swift
// 1. API enum 정의
enum MyApi {
    case fetchData(input: FetchDataInput)
    case saveData(id: String, isDelete: Bool)
}

// 2. RequestType 확장
extension MyApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchData(let input):
            return input
        case .saveData:
            return nil
        }
    }

    var method: RequestMethod {
        switch self {
        case .fetchData:
            return .get
        case .saveData(_, let isDelete):
            return isDelete ? .delete : .put
        }
    }

    var header: HTTPHeaderType {
        switch self {
        case .fetchData:
            return .json
        case .saveData:
            return .json
        }
    }

    var path: String {
        switch self {
        case .fetchData(let input):
            return "/api/v1/data/\(input.id)"
        case .saveData(let id, _):
            return "/api/v1/data/\(id)"
        }
    }
}

// 3. Repository Protocol
public protocol MyRepository {
    func fetchData(input: FetchDataInput) async -> Result<MyDataResponse, Error>
    func saveData(id: String, isDelete: Bool) async -> Result<String, Error>
}

// 4. Repository Impl
public struct MyRepositoryImpl: MyRepository {
    public init() { }

    public func fetchData(input: FetchDataInput) async -> Result<MyDataResponse, Error> {
        let request = MyApi.fetchData(input: input)
        return await NetworkManager.shared.request(requestType: request)
    }

    public func saveData(id: String, isDelete: Bool) async -> Result<String, Error> {
        let request = MyApi.saveData(id: id, isDelete: isDelete)
        return await NetworkManager.shared.request(requestType: request)
    }
}
```

### UICollectionViewCell 구현 규칙

- 새로 생성하는 모든 UICollectionViewCell은 반드시 BaseCollectionViewCell을 상속합니다
- 셀 내부에 registerId(혹은 reuseIdentifier)와 같은 static 프로퍼티를 별도로 생성하지 않습니다 (registerId 사용 금지)

## 코드 스타일/네이밍/구조 규칙

- SwiftLint 규칙(.swiftlint.yml) 및 Swift 표준 컨벤션을 따릅니다
- Import 순서: 표준 → 내부모듈 → 서드파티. 각 분류 사이에는 한 줄 띄어서 사용합니다
- 클래스/구조체/enum: PascalCase, 변수/함수/상수: camelCase
- 파일 구성: Import → 선언 → Nested Types → Properties → Initializers → Public Methods → Private Methods → Extensions
- 메서드 순서: Lifecycle → Setup → Binding → Action → Helper
- Combine 구독은 cancellables에 저장, Task는 taskBag에 저장
- 주석은 "왜"에 집중(코드 네이밍이 길거나 코드가 어려운 경우에 주로 사용), 문서화 주석은 Swift 표준 사용
- Git-flow 브랜치 전략, 커밋 메시지 컨벤션(feat/fix/docs 등) 준수

## 빌드 설정

### Debug 설정
- Bundle ID: `com.macgongmon.-dollar-in-my-pocket-debug`
- API URL: `https://dev.threedollars.co.kr`
- 딥링크 스킴: `dollars-dev`

### Release 설정
- Bundle ID: `com.macgongmon.-dollar-in-my-pocket`
- API URL: `https://threedollars.co.kr`
- 딥링크 스킴: `dollars`

## 의존성 및 외부 라이브러리

### 핵심 의존성
- **SnapKit**: Auto Layout
- **Combine**: 반응형 프로그래밍
- **Kingfisher**: 이미지 로딩
- **Firebase**: Analytics, Crashlytics, Remote Config, 푸시 알림
- **KakaoSDK**: 소셜 로그인 및 공유
- **Naver Maps**: 지도 통합 (`Frameworks/`에 위치)

### 개발 도구
- **SwiftLint**: 코드 스타일 검사
- **Netfox**: 네트워크 디버깅 (디버그 빌드 전용)

## 주요 참고사항

- iOS 배포 타겟: **18.0+**
- 현재 앱 버전: **4.35.0**
- Git-flow 브랜치 전략 사용
- 메인 개발 브랜치: `develop`
- SwiftUI 사용 안 함 - UIKit만 사용
- 한국어 및 영어 현지화 지원
- API 문서: https://dev.threedollars.co.kr/api/swagger-ui/swagger-ui/index.html

## Skills (자동화 도구)

반복적인 작업을 자동화하는 여러 Skills가 정의되어 있습니다. 각 Skill은 `/skill-name` 형태로 호출할 수 있습니다.

- **프로젝트 스킬** (`.claude/skills/`, 저장소에 포함): `ios-viewmodel-pattern`, `ios-repository-pattern`, `ios-viewmodel-test-generator`, `server-schema`
- **3dollars 플러그인** (`~/.claude/skills/3dollars/`, 개인 환경): `3dollars:feature-implementer`, `3dollars:bug-fix`, `3dollars:code-cleanup`, `3dollars:pr-code-review`, `3dollars:simulator-test`, `3dollars:deploy-dev-build` 등 11개 — **호출 시 `3dollars:` 접두어가 필요**합니다. 저장소에 없으므로 다른 팀원 환경에는 존재하지 않을 수 있습니다

### feature-implementer
JIRA 피처 티켓을 받아 구현부터 PR 생성까지 전체 파이프라인을 자동화합니다.

**기능**:
- JIRA 티켓 분석 + 프롬프트 추가 요구사항 병합 → 요구사항 체크리스트 확정
- 서버 OpenAPI 스키마 대조, 피그마 디자인 확인
- Model, API, Repository, ViewModel, ViewController, (조건부) 테스트 코드 생성
- 빌드/SwiftLint/테스트 검증
- 자체 코드리뷰(`/code-review`) 및 반영 후 재검증
- 시뮬레이터 Before/After 스크린샷·영상 검증 (`simulator-test`)
- Draft PR 생성 — 변경사항 요약 + Before/After 비교표 첨부

**사용법**:
```bash
# JIRA 티켓 URL
/3dollars:feature-implementer https://3dollarinmypocket.atlassian.net/browse/TH-1234

# 티켓 키 + 프롬프트 추가 요구사항 (충돌 시 프롬프트 우선)
/3dollars:feature-implementer TH-1234 정렬은 최신순 기본, 빈 상태 문구는 "아직 없어요"로

# 티켓 + 피그마 URL
/3dollars:feature-implementer TH-1234 https://figma.com/design/...

# 대화형 (인자 없이 호출)
/3dollars:feature-implementer
```

**참고**: JIRA(Atlassian) MCP 연결과 GitHub 권한이 필요합니다. JIRA 미연결 시 티켓 본문을 직접 붙여넣는 폴백으로 진행합니다. 버그 티켓은 이 스킬 대신 `/3dollars:bug-fix`를 사용하세요.

**정의 위치**: `~/.claude/skills/3dollars/skills/feature-implementer/SKILL.md` (3dollars 플러그인)

### ios-viewmodel-pattern
Combine 기반 MVVM 패턴의 ViewModel 구조를 정의합니다.

**제공 내용**:
- Input/Output/Route/Config/Dependency/State 패턴
- BaseViewModel 상속 구조
- async/await 통합 패턴
- bind() 메서드 구현 예시

**참고 파일**: `.claude/skills/ios-viewmodel-pattern/SKILL.md`

### ios-repository-pattern
Protocol + Impl 구조 및 API enum + RequestType 확장 패턴으로 네트워크 레이어를 구현합니다.

**제공 내용**:
- Repository Protocol + Impl 구조
- API enum 정의
- RequestType 확장 (param, method, header, path)
- async/await + Result 타입 사용

**참고 파일**: `.claude/skills/ios-repository-pattern/SKILL.md`

### ios-viewmodel-test-generator
ViewModel의 유저 플로우를 기반으로 XCTest 테스트 코드를 자동 생성합니다.

**제공 내용**:
- Given-When-Then 패턴
- Mock Repository 생성
- Input/Output 검증 테스트
- async/await 테스트 패턴

**참고 파일**: `.claude/skills/ios-viewmodel-test-generator/SKILL.md`

**테스트 파일 위치**: `App/Targets/three-dollar-in-my-pocketTests/ViewModelTests/`

### server-schema
서버 OpenAPI 스키마(`https://dev.threedollars.co.kr/api/v3/api-docs`)를 조회해 API 요청/응답 모델 구조를 확인합니다.

**기능**:
- 특정 엔드포인트의 응답/요청 모델 구조 확인 (allOf/oneOf/discriminator 펼치기)
- 필드명으로 전체 스키마 검색 (예: `storeType` 있는 모델 찾기)
- 두 엔드포인트/모델 비교 (마이그레이션 검토)
- 스키마 업데이트 여부 확인 및 dev 실응답 교차 검증

**사용 시점**: 서버 스키마가 궁금할 때, 응답 필드 유무 확인, 업데이트된 스키마 확인 등

**참고 파일**: `.claude/skills/server-schema/SKILL.md`
