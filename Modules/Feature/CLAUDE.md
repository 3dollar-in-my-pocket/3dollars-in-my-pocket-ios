# Modules/Feature — 작업 규칙

Feature는 화면 단위 모듈이다. 각 모듈은 `Targets/{Feature}`(구현), `Targets/Interface`(계약), `Targets/Demo`(단독 실행 앱)로 구성된다.
규칙의 이유·예시·예외는 [docs/architecture/RULES.md](../../docs/architecture/RULES.md)에 있다.

## 여기서 반드시 지킬 것

- **R2** 다른 Feature는 `.Interface.xxxInterface`로만 의존한다. `Project.swift`에 `.Feature.xxx`를 넣지 않는다. 화면 이동은 `Environment.xxxInterface` 또는 `DIContainer.shared.resolver.resolve(XxxInterface.self)`로 해소한다. 다른 Feature의 화면이 필요하면 그 Feature의 Interface에 `createXxxViewController(config:)`를 추가하고 `XxxInterfaceImpl`에서 구현한다(예: `FeedInterface.createFeedListViewController`).
- **R4** ViewModel에서 `NetworkManager.shared`를 부르지 않는다. Repository는 `Core/Network`에 만들고 `Dependency`로 주입받는다. DI 조회는 `DIContainer.shared.resolver.resolve(...)`만 쓴다(`container`는 등록 전용).
- **R5** `*ViewModel.swift`는 `import UIKit` 금지, `UIApplication.shared` 금지, `BaseViewModel` 상속, `Dependency` 프로퍼티는 protocol 타입. URL 열기·알럿 같은 UI 동작은 `Route`로 VC에 넘긴다.
- **R6** VC는 `BaseViewController`, Cell은 `BaseCollectionViewCell` 상속. `registerId` 같은 static 식별자 금지.
- **R7** 색/폰트/아이콘은 `Colors`/`Fonts`/`Icons`만. SnapKit은 `leading/trailing`. `then` 금지, 클로저 초기화 사용.
- **R8** 타입은 책임 하나. 여러 기능을 맡으면 하위 ViewModel/View로 분리한다. 책임이 하나인데 타입 500줄·파일 800줄을 넘으면 `// swiftlint:disable:next type_body_length - {사유}` / `// swiftlint:disable file_length - {사유}`. 같은 파일 `extension`으로 옮겨 줄 수만 맞추지 않는다.
- **R10** ViewModel은 `Input / Output / Route / Config / Dependency / State` 구조. Route 처리는 VC의 `// MARK: Route` extension. 템플릿은 루트 [CLAUDE.md](../../CLAUDE.md#viewmodel-구조-규칙).

## `Targets/Interface/` 안에서는

- **R3** `protocol`, `enum`, 값 타입(`struct XxxConfig`, `struct XxxDependency`)만 둔다. `class`와 구현 로직 금지.
- Interface는 Core(`Model`, `Common`, `Networking`, `Log`, `DependencyInjection`)만 의존한다. 새 Interface 메서드를 추가하면 `Modules/Mock`의 `MockXxxInterfaceImpl`도 같이 맞춘다 (Demo 앱이 이걸로 뜬다). 다른 Feature Interface를 의존하지 않는다.
- 새 화면을 다른 Feature에 노출하려면: Interface protocol에 `getXxxViewController(config:)` 추가 → 구현체에서 채움 → App의 DI 등록에 반영.

## 새 화면을 만들 때 순서

1. 테크스펙(노션)의 TC 확인 + 계층 배정(유닛/자동화/수동, `docs/process/testing.md`) → 2. Model/API/Repository(Core) → 3. ViewModel(+ Input/Output/Route) → 4. ViewController/View → 5. 유닛 테스트(`App/Targets/three-dollar-in-my-pocketTests/Sources/ViewModelTests/`, 메서드명 `test_{티켓}_TC{n}_`) → 6. 자동화 TC 는 `3dollars:simulator-test` 로 증거 캡처 → 7. `make lint`

## 검증

```bash
make lint
```
