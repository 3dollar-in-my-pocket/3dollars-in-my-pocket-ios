# 레포 조사 결과 (2026-09-19)

아키텍처 규칙 선정을 위한 현황 스냅샷. 카운트는 `Modules/`, `App/Targets/` 기준이며 Derived / Demo / Mock / Tests 제외.

## 1. 모듈 구조

| 계층 | 모듈 | 산출물 | 비고 |
|---|---|---|---|
| App | three-dollar-in-my-pocket, AppInterface, Tests, 2 extensions | app / framework | Tests 타깃은 App + Store만 의존 |
| Core | Model, DependencyInjection(Swinject), DesignSystem, Log, Common, Networking, Resource | framework (Log는 staticLibrary) | Resource는 Project.swift 없음(미사용?) |
| Feature | Home, Store, Write, Community, MyPage, Membership, Feed, SDU | framework + Interface + Demo | Home만 Interface 없음 |
| Mock | Mock | staticLibrary | Demo 앱용 |

## 2. 선언된 의존성 그래프 (Tuist Project.swift 기준)

```
Model ← (없음)
DependencyInjection ← Swinject
DesignSystem ← Lottie
AppInterface ← DependencyInjection, Model
Log ← DependencyInjection, Model, AppInterface
Common ← Model, Log, DependencyInjection, DesignSystem, AppInterface, Kingfisher, ZMarkupParser
Networking ← Common, DesignSystem, DependencyInjection, AppInterface

{Feature}Interface ← DependencyInjection, Model, Common, Networking, Log   (공통, 헬퍼에서 고정)

Home       ← Core*, AppInterface, StoreI, MembershipI, FeedI, **Feed(구현체)**, NaverMap …
Store      ← Core*, AppInterface, StoreI, WriteI, **SDU(구현체)**, NaverMap …
Write      ← Core*, AppInterface, StoreI, WriteI, NaverMap …
Community  ← Core*, CommunityI
MyPage     ← Core*, AppInterface, MyPageI, StoreI, MembershipI, CommunityI, DeviceKit
Membership ← Core*, AppInterface, MembershipI, MyPageI
Feed       ← Core*, AppInterface, MembershipI, StoreI, FeedI
SDU        ← Core*(DI/Log 제외)

App ← Core*, AppInterface, StoreI/WriteI/CommunityI, Home, Community, Membership, Store, Write, MyPage, (Feed·SDU는 전이)
```

Feature 간 통신은 `Environment.xxxInterface` / `container.resolve(XxxInterface.self)` (Swinject) 로 런타임 해소.

### 그래프에서 보이는 것

- ✅ Core → Feature 방향 의존 없음 (import 검색 0건)
- ✅ Repository 구현체(21개)는 전부 `Core/Network`에만 존재, `NetworkManager.shared` 직접 호출도 Network 밖 0건
- ✅ ViewModel `Dependency`에 `Impl` 타입으로 선언된 프로퍼티 0건 (protocol 타입 주입 지켜짐)
- ⚠️ **Feature → Feature 구현체 직접 의존 2건**: Home→Feed, Store→SDU (Interface 우회). SDU는 UI 컴포넌트 라이브러리 성격이라 Core로 옮기는 게 맞을 수 있음
- ⚠️ `Networking → Common, DesignSystem` : 네트워크 계층이 UI 계층(DesignSystem)에 의존. 실제 import는 `Common` 1건, `DesignSystem` 0건 → 선언만 남은 불필요 의존
- ⚠️ `Common ↔ Networking` 순환 위험: Common은 Networking 안 보지만 Networking이 Common을 봄. Common이 커지면 뒤집힐 수 있음
- ⚠️ Core 모듈(Common, Log, Networking)이 `AppInterface`(App 계층) 의존 — 방향은 위→아래가 아니라 옆. AppInterface가 사실상 "Core/Interface" 역할이라 위치가 App 아래인 게 이름과 안 맞음
- ⚠️ Interface 타깃 순수성: 대부분 protocol이지만 `struct XxxViewModelConfig/Dependency` 가 Feed/Membership/Store/Write Interface에 존재 (값 타입이라 허용 가능, 규칙으로 명시 필요)

## 3. 린트 / CI / 테스트

| 항목 | 현황 |
|---|---|
| SwiftLint 설정 | 기본 룰셋 + 2개 disabled, 임계값 완화(line 200, type body 300/500). `custom_rules` 없음, `baseline` 없음 |
| SwiftLint 실행 | **빌드 페이즈에 없음** (Tuist 스크립트에 swiftlint 0건). CLAUDE.md의 "린트 에러 시 빌드 실패"는 현재 사실이 아님 |
| CI | Xcode Cloud (`ci_scripts/`) — post_clone에서 tuist generate, post_xcodebuild에서 archive 시 Discord 알림. **테스트/린트 실행 여부는 Xcode Cloud 워크플로 설정에 있어 레포에서 확인 불가** |
| GitHub Actions `swift.yml` | `pod install` + 존재하지 않는 스키마 + iPhone 12/iOS 15 → **죽은 워크플로** (CocoaPods 시절 잔재) |
| 테스트 | App 테스트 타깃 1개, 파일 10개, `func test` 26개. ModelTests(SDU 응답 파싱 7개) + StoreSectionsViewModelTests + ViewControllTests. 모듈별 테스트 타깃 없음, 스냅샷 테스트 없음 |
| PR 템플릿 | 없음. 이슈 템플릿만 존재 |
| 최근 6개월 | 커밋 154, 머지 30 |

## 4. 암묵적 규칙 준수 현황 (CLAUDE.md에 적힌 규칙 vs 실제)

| 규칙 (CLAUDE.md) | 위반 | 위치 | 기계 판별 |
|---|---|---|---|
| 신규 코드 `then` 금지 | `import Then` 64파일, `.then {` 341건 | 전 Feature | 린트 custom_rule 가능 (베이스라인 필요) |
| SnapKit left/right 금지 → leading/trailing | 약 288건 (정규식 근사치) | 전 Feature | 린트 custom_rule 가능 |
| 색상은 DesignSystem만 | `UIColor(` 47건 (DesignSystem 30건 제외) | Home 13, Store 10, Common 8, Community 5, Feed 5, App 4, Membership 2 | 린트 custom_rule 가능 (DesignSystem 디렉터리 excluded) |
| `registerId` 금지 | 6건 (5파일) | MyPage/Medal, Write/CategorySelection | 린트 custom_rule 가능 |
| VC는 BaseViewController 상속 | 2건 | Home/StorePreviewBottomSheet, App/MainTabBar (+extension 1건은 예외) | 린트 custom_rule 가능 |
| Cell은 BaseCollectionViewCell 상속 | 1건 | — | 린트 custom_rule 가능 |
| ViewModel은 BaseViewModel 상속 | 98개 중 94개 | 4건 확인 필요 | 린트 custom_rule 가능 |
| VM에서 `.shared` 직접 호출 금지(암묵) | `UIApplication.shared.open` 4건 | Store/MapDetail, StoreSectionsVM | 린트 custom_rule 가능 (UIApplication → Route로 빼야 테스트 가능) |
| SwiftUI 금지 / 스토리보드 금지 | SwiftUI 0, storyboard 1(LaunchScreen 추정) | — | 린트/파일 검사 |
| `as!` / `try!` | 3 / 0 | — | 기본 룰 (현재 warning) |
| `print(` | 9건 | — | 기본 룰 `custom_rule` 또는 Log 강제 |
| SRP 근사: VM 300줄 초과 | 8개 (HomeViewModel 1032줄) | Home, Store, Write, MyPage | 기본 룰 `type_body_length` (현재 warning 300) |

## 5. 확인 필요 (레포에서 알 수 없음)

1. Xcode Cloud 워크플로가 PR마다 테스트를 돌리는지, 린트는 돌리는지
2. `swift.yml`(GitHub Actions) 은 삭제해도 되는지
3. 로컬에서 SwiftLint는 어떻게 돌리는지 (수동? Xcode 플러그인?)
4. `Core/Resource` 디렉터리 정체 (Project.swift 없음)
5. SDU를 Feature에 둘지 Core로 올릴지 (Store가 구현체로 직접 의존 중)
6. AppInterface를 Core로 옮길 의향 (Core 모듈들이 App 하위 타깃에 의존하는 모양새 정리)
