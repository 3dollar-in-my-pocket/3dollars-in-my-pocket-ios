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
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Release 빌드
xcodebuild build \
  -workspace 3dollar-in-my-pocket.xcworkspace \
  -scheme three-dollar-in-my-pocket \
  -configuration Release \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

**주의사항**:
- 빌드 전 반드시 `make project` 실행 (Tuist 프로젝트 생성)
- **three-dollar-in-my-pocket-debug** 스키마 사용 (Debug 빌드)
- **three-dollar-in-my-pocket** 스키마 사용 (Release 빌드)

### 테스트
```bash
# 전체 테스트 실행
xcodebuild test \
  -workspace 3dollar-in-my-pocket.xcworkspace \
  -scheme three-dollar-in-my-pocket-debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# 특정 테스트 파일 실행
xcodebuild test \
  -workspace 3dollar-in-my-pocket.xcworkspace \
  -scheme three-dollar-in-my-pocket-debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:three-dollar-in-my-pocketTests/ViewModelTests/{TestClassName}
```

**테스트 파일 위치**: `App/Targets/three-dollar-in-my-pocketTests/ViewModelTests/`

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
- **Tuist 4.44.3**을 사용한 프로젝트 생성 및 모듈러 아키텍처
- 메인 워크스페이스: `3dollar-in-my-pocket.xcworkspace`
- 모든 소스 파일은 생성되므로 `.xcodeproj` 파일을 직접 편집하지 마세요

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

프로젝트에는 반복적인 작업을 자동화하는 여러 Skills가 정의되어 있습니다. 각 Skill은 `/skill-name` 형태로 호출할 수 있습니다.

### feature-implementer
테크스펙 문서를 기반으로 새로운 피처를 구현하는 전체 파이프라인을 자동화합니다.

**기능**:
- 테크스펙 문서 분석 및 피그마 디자인 확인
- 워크트리 기반 안전한 작업 환경 구성
- Model, API, Repository, ViewModel, ViewController, 테스트 코드 자동 생성
- 빌드/테스트/SwiftLint 검증 및 자동 수정
- Git 커밋 (논리적 흐름으로 분리)

**사용법**:
```bash
# 마크다운 파일로 제공
/feature-implementer /path/to/TH-XXX-spec.md

# 파일 경로 + 피그마 URL
/feature-implementer /path/to/spec.md https://figma.com/design/...

# 대화형 (인자 없이 호출)
/feature-implementer
```

**참고**: 테크스펙 문서 또는 파일 경로가 필요합니다. GitHub 권한도 필요합니다.

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
