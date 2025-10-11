# CLAUDE.md

이 파일은 Claude Code (claude.ai/code)가 이 저장소에서 작업할 때 참고할 수 있는 가이드를 제공합니다.

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

### 프로젝트 구조
- **Tuist 4.44.3**을 사용한 프로젝트 생성 및 모듈러 아키텍처
- 메인 워크스페이스: `3dollar-in-my-pocket.xcworkspace`
- 모든 소스 파일은 생성되므로 `.xcodeproj` 파일을 직접 편집하지 마세요

## 프로젝트 구조 및 모듈화 규칙

- 모든 코드는 기능별(Feature) 모듈, Core(공통) 모듈, App(엔트리포인트)로 분리합니다.
- Feature 모듈은 실제 앱의 큰 단위 화면 단위로 분리하며, 각 모듈은 Targets, Derived 디렉토리 구조를 가집니다. (Derived 디렉토리는 Tuist를 통해 생성되는 디렉토리입니다.)
- Targets 디렉토리는 피처 이름의 디렉토리(해당 디렉토리 안에는 Resources, Sources 디렉토리로 구성), Demo(피처 모듈의 데모앱), Interface(피처 모듈을 호출할 수 있는 인터페이스) 디렉토리로 구성됩니다.
- Core 모듈은 공통 유틸리티, 네트워크, 디자인 시스템, 모델, DI 등을 포함합니다.
- 외부 라이브러리는 Frameworks/에 위치합니다.

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

### 앱 구조 (`App/`)
- 의존성 주입 설정이 포함된 메인 앱 타겟
- 푸시 알림용 확장 (`service-extension`, `content-extension`)
- Firebase 설정 및 빌드 스크립트

## 주요 개발 패턴

### ViewModel 구조 규칙

모든 화면(ViewController)용 ViewModel은 아래 구조를 반드시 따릅니다:
- Input, Output, Route, Config, Dependency, State 등은 ViewModel 클래스 정의 상단에 extension으로 선언합니다.
  - **Input**: 뷰컨트롤러에서 입력할 수 있는 이벤트 모음
  - **Output**: ViewModel에서 로직을 처리하고 뷰컨트롤러에 이벤트를 전달하거나 상/하위 계층의 ViewModel로 이벤트를 전달할 수 있는 모음
  - **Route**: 연결된 ViewController에서 이동할 수 있는 라우팅 테이블. 뷰모델에서 처리하는 라우팅 로직이 없다면 정의하지 않습니다.
  - **Dependency**: ViewModel에서 의존하고 있는 외부 클래스 모음 (API를 호출하는 Repository, 로그를 전송할 수 있는 LogManager 등이 주로 사용됩니다.) 뷰모델에서 의존할 클래스가 없다면 Dependency는 정의하지 않습니다.
  - **State**: 뷰모델에서 가지고 있어야 할 상태 변수가 있다면 정의하여 사용하는 구조체입니다.
  - **Config**: ViewModel을 생성하는데 필요한 변수를 가지고 있는 구조체입니다. Config가 있다면 생성자의 인자로 받아야 하고, Config를 통해 Output, State 등의 인스턴스를 생성할 수 있습니다.

예시:
```swift
extension MyViewModel {
    struct Input { 
        ... 
    }

    struct Output { 
        ... 
    }

    enum Route { 
        ...
    }

    struct Config { 
        ... 
    }

    struct Dependency { 
        ...
    }

    struct State {
        ...
    }
}

final class MyViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    // ... 기타 프로퍼티 및 init, bind 등 ...
}
```

### ViewController & MVVM 패턴 규칙

- 모든 ViewController는 BaseViewController를 상속합니다. BaseViewController는 Common 모듈에 있으므로 `import Common`이 코드 상단에 반드시 필요합니다.
- ViewController는 UI 구성, 이벤트 바인딩, ViewModel과의 바인딩만 담당합니다.
- ViewModel은 생성자 주입 방식으로 연결합니다.
- 화면 전환, 에러 처리, 로딩 등은 ViewModel Output/Route를 통해 처리합니다.
- ViewModel.output에 route 관련 이벤트 스트림이 있어 바인딩해야 한다면 extension을 생성하여 처리합니다.

예시:
```swift
final class MyViewController: BaseViewController {
    private let viewModel: MyViewModel

    ...

    func bind() {
        viewModel.output.route
            .main
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(&cancellables)
    }
}

// MARK: Route
extension MyViewController {
    private func handleRoute(_ route: MyViewModel.Route) {
        switch route {
            ...
        }
    }

    private func pushMySectionViewController(_ viewModel: ...) {

    }
}
```

### UI 가이드라인

- **코드 기반 UI만 사용** - SnapKit으로 Auto Layout 구성
- SnapKit 사용 시 left, right 대신 leading, trailing을 사용합니다
- 색상, 폰트, 아이콘, 버튼 등은 반드시 DesignSystem(Colors, Fonts, Icons 등)으로만 사용합니다
- **신규 코드에서 `then` 라이브러리 사용 금지** - Swift 표준 문법(클로저, var/let 선언 후 속성 설정 등)을 사용합니다
- Kingfisher로 이미지 로딩 및 캐싱
- 커스텀 뷰/컴포넌트는 재사용성을 고려해 설계합니다
- 접근성, 동적 타입, 반응형 레이아웃을 지원합니다

UI 컴포넌트 생성 예시:
```swift
// 권장 방식
private let label: UILabel = {
    let label = UILabel()
    label.text = "텍스트"
    label.textColor = .black
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
- 외부 API 연동, 인증, 에러 처리, 로깅은 NetworkManager/Logger를 통해 일관되게 처리합니다

### UICollectionViewCell 구현 규칙

- 새로 생성하는 모든 UICollectionViewCell은 반드시 BaseCollectionViewCell을 상속합니다
- 셀 내부에 registerId(혹은 reuseIdentifier)와 같은 static 프로퍼티를 별도로 생성하지 않습니다 (registerId 사용 금지)

### 테스트

- 단위 테스트: `App/Targets/three-dollar-in-my-pocketTests/`
- Xcode 스킴으로 테스트 실행: `three-dollar-in-my-pocketTests`

## 빌드 설정

### Debug 설정
- Bundle ID: `com.macgongmon.-dollar-in-my-pocket-debug`
- API URL: `https://dev.threedollars.co.kr`
- 딥링크 스킴: `dollars-dev`
- 테스트용 AdMob ID

### Release 설정
- Bundle ID: `com.macgongmon.-dollar-in-my-pocket`
- API URL: `https://threedollars.co.kr`
- 딥링크 스킴: `dollars`
- 프로덕션 AdMob ID

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

## 코드 스타일/네이밍/구조 규칙

- SwiftLint 규칙(.swiftlint.yml) 및 Swift 표준 컨벤션을 따릅니다
- Import 순서: 표준 → 내부모듈 → 서드파티. 각 분류 사이에는 한 줄 띄어서 사용합니다
- 클래스/구조체/enum: PascalCase, 변수/함수/상수: camelCase
- 파일 구성: Import → 선언 → Nested Types → Properties → Initializers → Public Methods → Private Methods → Extensions
- 메서드 순서: Lifecycle → Setup → Binding → Action → Helper
- Combine 구독은 cancellables에 저장, Task는 taskBag에 저장
- 주석은 "왜"에 집중(코드 네이밍이 길거나 코드가 어려운 경우에 주로 사용), 문서화 주석은 Swift 표준 사용
- Git-flow 브랜치 전략, 커밋 메시지 컨벤션(feat/fix/docs 등) 준수

## 주요 참고사항

- iOS 배포 타겟: **18.0+**
- 현재 앱 버전: **4.25.0**
- Git-flow 브랜치 전략 사용
- 메인 개발 브랜치: `develop`
- SwiftUI 사용 안 함 - UIKit만 사용
- 한국어 및 영어 현지화 지원
- API 문서: https://dev.threedollars.co.kr/api/swagger-ui/swagger-ui/index.html