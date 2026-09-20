# 아키텍처 규칙 (RULES.md)

이 문서는 가슴속 3천원 iOS 레포의 **아키텍처 규칙 10개**다.
AI가 코드를 많이 쓰는 환경에서 사람은 diff 전체가 아니라 **의도(TC)·모듈 경계·검증 증거**만 본다.
그래서 경계에 관한 규칙은 엄격하게, 모듈 내부 구현은 관대하게 둔다.

## 운영 원칙

- **기계로 판별 가능한 규칙은 문서가 아니라 린트·스크립트로 강제한다.** 이 문서는 "왜"와 "예외"를 설명하는 곳이지, 위반을 잡는 곳이 아니다.
- **기존 위반은 베이스라인으로 동결하고 새 위반만 막는다.** 베이스라인에 있는 코드를 고칠 의무는 없지만, 그 파일을 크게 손댈 때 같이 고치는 걸 권장한다.
- 규칙은 10개를 넘기지 않는다. 새 규칙을 넣으려면 기존 규칙을 빼거나 합친다.
- 규칙 포맷: **규칙 한 문장 / 이유 / 좋은 예·나쁜 예 / 강제 수단 / 예외**.
- 강제 수단 우선순위: **린트(SwiftLint custom_rules) > 스크립트(의존성 검사) > 문서(이 파일 + 디렉터리별 CLAUDE.md)**. 문서로만 강제되는 규칙은 R10 하나다.

## 한눈에 보기

| # | 규칙 | 강제 수단 | 베이스라인 |
|---|---|---|---|
| R1 | 의존 방향은 App → Feature → Core 한 방향 | 스크립트 `check-module-deps` | 0건 (AppInterface 예외) |
| R2 | Feature끼리는 Interface 타깃으로만 통신 | 스크립트 `check-module-deps` | 0건 |
| R3 | Interface 타깃엔 protocol·enum·값 타입만 | 린트 `interface_no_class` | 0건 |
| R4 | 서버 호출은 Core/Network의 Repository에서만 | 린트 `no_network_manager_outside_network` | 0건 |
| R5 | ViewModel은 UI를 모르고, 의존은 주입받는다 | 린트 `viewmodel_*` 3개 | 18건 동결 |
| R6 | ViewController/Cell은 Base 클래스를 상속 | 린트 `vc_inherits_base`, `cell_inherits_base`, `no_register_id` | 5건 동결 |
| R7 | UI 표현은 DesignSystem·leading/trailing·클로저 초기화 | 린트 `no_uicolor_literal`, `snapkit_leading_trailing`, `no_then` | 736건 동결 |
| R8 | 타입 하나는 300줄을 넘기지 않는다 | 린트 기본 룰 `type_body_length` | 7건 동결 |
| R9 | 로그는 Log 모듈로, `print`·`as!`·`try!` 금지 | 린트 `no_print` + 기본 룰 error 승격 | 6건 동결 |
| R10 | ViewModel 구조·Route 분리·서버 네이밍 통일 | 문서 + AI 리뷰 | — |

---

## R1. 의존 방향은 App → Feature → Core 한 방향이다

**규칙** — Core 모듈은 Feature·App을 의존하지 않고, Feature 모듈은 App을 의존하지 않는다.

**이유** — 의존성 역전(DIP). 하위 계층이 상위를 알면 Core를 떼어 테스트하거나 Demo 앱을 띄울 수 없다. Core→Feature 의존은 곧 순환이다.

**좋은 예**
```swift
// Modules/Core/Common/Project.swift
dependencies: [
    .Core.model,
    .Core.log,
    .Core.designSystem
]
```

**나쁜 예**
```swift
// Modules/Core/Common/Project.swift
dependencies: [
    .Feature.store   // ❌ Core가 Feature를 앎
]
```

**강제 수단** — `scripts/check-module-deps.sh`. `Modules/Core/*/Project.swift`에 `.Feature.`가 나오면 실패. `make lint`와 PR CI에서 실행.

**예외** — `AppInterface`(`App/Targets/AppInterface`, `.Interface.appInterface`)만 Core가 의존할 수 있다. App이 하위 계층에 노출하는 계약(세션 초기화, 애널리틱스 전송, 리모트 컨피그 등)이고 구현체는 App 타깃에 있어 DI 컨테이너로 주입된다. 현재 Core에서 쓰는 곳은 `BaseViewController`(onClearSession), `LogManager`(sendEvent/sendPageView), `NetworkManager`(experimentContext) 3곳. 이 예외를 없애려면 Core가 필요한 port(protocol)를 Core 안에 정의하고 App이 구현하는 방식으로 뒤집어야 한다 — 후속 티켓.

---

## R2. Feature끼리는 Interface 타깃으로만 통신한다

**규칙** — Feature 모듈은 다른 Feature의 구현체(`.Feature.xxx`)를 의존하지 않는다. 필요한 화면·기능은 `.Interface.xxxInterface`를 의존하고 런타임에 DI 컨테이너로 해소한다.

**이유** — 인터페이스 분리(ISP)·의존성 역전(DIP). Feature 구현체를 직접 물면 빌드 그래프가 얽혀 한 모듈 수정이 다른 모듈 재빌드를 유발하고, Demo 앱이 앱 절반을 끌고 오게 된다. Interface 타깃을 만든 이유가 바로 이것이다.

**좋은 예**
```swift
// Modules/Feature/MyPage/Project.swift
dependencies: [
    .Interface.storeInterface,
    .Interface.membershipInterface
]

// 사용처
let storeInterface = Environment.storeInterface   // 또는 container.resolve(StoreInterface.self)
let vc = storeInterface.getStoreDetailViewController(storeId: id)
```

**나쁜 예**
```swift
// Modules/Feature/Home/Project.swift
dependencies: [
    .Feature.feed      // ❌ Feed 구현체 직접 의존
]
```

**강제 수단** — `scripts/check-module-deps.sh`. `Modules/Feature/*/Project.swift`에 `.Feature.`가 나오면 실패.

**예외(베이스라인)** — 현재 0건. 정당한 예외가 생기면 `scripts/module-deps-baseline.txt`에 `From -> To` 한 줄로 등록하고 사유를 주석으로 남긴다. (TH-1338에서 `Home → Feed`는 `FeedInterface.createFeedListViewController`로, `Store → SDU`는 SDU를 `Modules/Core/SDU`로 올려 해소했다. SDU는 화면이 아니라 서버 주도 UI 렌더링 인프라라 Core가 맞다.)

---

## R3. Interface 타깃엔 protocol·enum·값 타입만 둔다

**규칙** — `Targets/Interface/Sources`에는 `protocol`, `enum`, 그리고 화면 생성에 필요한 `struct XxxConfig`/`struct XxxDependency` 같은 값 타입만 둔다. `class`와 구현 로직은 두지 않는다.

**이유** — Interface가 두꺼워지면 R2가 무의미해진다. Interface는 "무엇을 할 수 있는가"의 계약이고, "어떻게"는 구현체에 있어야 한다. 값 타입 Config는 계약의 일부(입력 파라미터)라 허용한다.

**좋은 예**
```swift
// Modules/Feature/Store/Targets/Interface/Sources/StoreInterface.swift
public struct UploadPhotoConfig {
    public let storeId: Int
    public init(storeId: Int) { self.storeId = storeId }
}

public protocol StoreInterface {
    func getUploadPhotoViewController(config: UploadPhotoConfig) -> UIViewController
}
```

**나쁜 예**
```swift
// Targets/Interface/Sources/StoreInterface.swift
public final class StoreRouter {          // ❌ 구현체가 Interface에
    public func push(...) { ... }
}
```

**강제 수단** — SwiftLint custom_rule `interface_no_class` (`Targets/Interface/` 경로 안에서 `class ` 선언 금지).

**예외** — 없음.

---

## R4. 서버 호출은 Core/Network의 Repository에서만 한다

**규칙** — HTTP 요청은 `Modules/Core/Network`의 `XxxApi`(enum + `RequestType`) + `XxxRepository`(protocol) + `XxxRepositoryImpl`로만 한다. `NetworkManager.shared`를 Network 모듈 밖에서 호출하지 않는다.

**이유** — 단일 책임(SRP). 네트워크를 목으로 바꿀 수 있는 지점이 Repository 하나여야 ViewModel 테스트가 서버 없이 돈다. 또한 서버 스키마 변경 시 고칠 곳이 한 곳으로 모인다.

**좋은 예**
```swift
// Modules/Core/Network/Sources/...
public protocol StoreRepository {
    func fetchStore(id: Int) async -> Result<StoreResponse, Error>
}

public struct StoreRepositoryImpl: StoreRepository {
    public func fetchStore(id: Int) async -> Result<StoreResponse, Error> {
        await NetworkManager.shared.request(requestType: StoreApi.fetchStore(id: id))
    }
}
```

**나쁜 예**
```swift
// Modules/Feature/Store/.../StoreDetailViewModel.swift
let result = await NetworkManager.shared.request(requestType: StoreApi.fetchStore(id: id))  // ❌
```

**강제 수단** — SwiftLint custom_rule `no_network_manager_outside_network` (`Modules/Core/Network/` 외 경로에서 `NetworkManager.shared` 금지).

**예외** — 없음.

---

## R5. ViewModel은 UI를 모르고, 의존은 주입받는다

**규칙** — ViewModel은 `BaseViewModel`을 상속하고, `UIKit`을 import하지 않으며, 외부 의존(Repository, LogManager 등)은 `Dependency`에 **protocol 타입**으로 주입받는다. `UIApplication.shared` 같은 싱글턴을 본문에서 직접 호출하지 않는다.

**이유** — 테스트 가능성. ViewModel이 UIKit이나 싱글턴을 직접 만지면 시뮬레이터 없이 테스트할 수 없다. "URL 열기" 같은 UI 동작은 `Route`로 뷰컨트롤러에 넘긴다.

**좋은 예**
```swift
// ViewModel
enum Route {
    case openURL(URL)
}
input.didTapCall
    .sink { [weak self] in self?.output.route.send(.openURL(url)) }

// ViewController (extension)
case .openURL(let url):
    UIApplication.shared.open(url)
```

**나쁜 예**
```swift
// Modules/Feature/Store/.../MapDetailViewModel.swift
UIApplication.shared.open(url)   // ❌ VM이 UI를 직접 조작

struct Dependency {
    let repository: StoreRepositoryImpl   // ❌ 구현체 타입 → 목 교체 불가
}
```

**강제 수단** — SwiftLint custom_rules, `*ViewModel.swift` 파일 대상:
- `viewmodel_no_uikit_import` — `import UIKit` 금지
- `viewmodel_no_uiapplication` — `UIApplication.shared` 금지
- `viewmodel_inherits_base` — `class XxxViewModel` 선언이 `BaseViewModel`을 상속하지 않으면 실패

**예외(베이스라인)** — `import UIKit` 14건, `UIApplication.shared` 4건(MapDetailViewModel, StoreSectionsViewModel) 동결. `Dependency`의 `init` 기본값 인자(`repository: StoreRepository = StoreRepositoryImpl()`)는 구현체 이름이 나와도 허용한다. 프로퍼티 타입이 protocol이면 된다.

---

## R6. ViewController와 Cell은 Base 클래스를 상속한다

**규칙** — ViewController는 `BaseViewController`, CollectionViewCell은 `BaseCollectionViewCell`을 상속한다. Cell 안에 `registerId`/`reuseIdentifier` 같은 static 식별자를 두지 않는다.

**이유** — `cancellables`·`taskBag`·생명주기 훅을 Base 한 곳에서 관리해야 메모리 누수와 바인딩 누락을 구조적으로 막는다. Cell 등록/디큐는 Common의 확장(`register(_:)`, `dequeueReusableCell(indexPath:)`)이 타입 이름으로 처리하므로 별도 식별자는 중복이다.

**좋은 예**
```swift
final class StoreDetailViewController: BaseViewController { ... }
final class MenuCell: BaseCollectionViewCell { ... }

collectionView.register([MenuCell.self])
let cell: MenuCell = collectionView.dequeueReusableCell(indexPath: indexPath)
```

**나쁜 예**
```swift
final class StorePreviewBottomSheetViewController: UIViewController { ... }   // ❌

final class MedalInfoTableViewCell: UITableViewCell {
    static let registerId = "\(MedalInfoTableViewCell.self)"   // ❌
}
```

**강제 수단** — SwiftLint custom_rules `vc_inherits_base`, `cell_inherits_base`, `no_register_id` (`Modules/Core/Common/` 및 App 익스텐션 타깃 제외).

**예외(베이스라인)** — VC 2건(`StorePreviewBottomSheetViewController`, `MainTabBarViewController` 내부 `WriteTabBarIconViewController`), `registerId` 선언 3건 동결. `content-extension`/`service-extension` 타깃, `Mock` 모듈, 각 Feature의 `Targets/Demo`는 규칙 대상이 아니다.

---

## R7. UI 표현은 DesignSystem·leading/trailing·클로저 초기화로 통일한다

**규칙** — 색·폰트·아이콘은 `DesignSystem`(`Colors`, `Fonts`, `Icons`)만 쓴다. SnapKit 제약은 `left/right` 대신 `leading/trailing`을 쓴다. 뷰 초기화에 `then` 라이브러리를 쓰지 않고 클로저 초기화를 쓴다.

**이유** — 디자인 토큰 단일 출처(다크모드·리브랜딩 시 한 곳만 수정), RTL 대응, 그리고 AI·사람이 같은 모양의 코드를 빠르게 읽게 하기 위함. `then`은 이미 CLAUDE.md에서 금지했지만 강제 수단이 없어 341건이 남아 있다.

**좋은 예**
```swift
private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = Colors.gray100.color
    label.font = Fonts.semiBold.font(size: 16)
    return label
}()

titleLabel.snp.makeConstraints {
    $0.leading.equalToSuperview().offset(20)
}
```

**나쁜 예**
```swift
private let titleLabel = UILabel().then {          // ❌ then
    $0.textColor = UIColor(r: 255, g: 0, b: 0)      // ❌ 색 리터럴
}
titleLabel.snp.makeConstraints { $0.left.equalToSuperview() }   // ❌ left
```

**강제 수단** — SwiftLint custom_rules `no_uicolor_literal`(hex 문자열 리터럴·RGB 직접 생성 금지. 서버가 내려준 색을 변수로 넘기는 `UIColor(hex: value)`는 허용, `Modules/Core/DesignSystem/` 제외), `snapkit_leading_trailing`(`$0.left.`/`.right.`/`make.left` 등), `no_then`(`.then {` 및 `import Then`).

**예외(베이스라인)** — `UIColor(` 47건, left/right 284건, `then` 405건(`import Then` 64 + `.then {` 341) 전부 동결. `DesignSystem` 모듈 내부는 `UIColor(` 사용이 정당하므로 제외. `left`/`right`가 의미상 물리적 방향이어야 하는 경우(예: 지도 위 좌우 버튼)는 `// swiftlint:disable:next snapkit_leading_trailing` + 이유 주석으로 예외 처리한다.

---

## R8. 타입 하나는 300줄을 넘기지 않는다

**규칙** — 클래스·구조체·enum 본문은 300줄(warning), 500줄(error)을 넘기지 않는다.

**이유** — 단일 책임(SRP)의 근사 지표. 1,032줄짜리 `HomeViewModel`은 사람도 AI도 한 번에 못 읽고, 테스트 케이스 하나가 수십 개의 상태에 얽힌다. 길어지면 화면 안의 섹션·기능 단위로 ViewModel을 쪼갠다(예: `StoreSectionsViewModel`).

**좋은 예** — 화면이 커지면 하위 ViewModel로 분리하고 상위는 조합만 한다.

**나쁜 예** — 한 ViewModel이 지도·리스트·필터·광고·딥링크를 전부 처리.

**강제 수단** — SwiftLint 기본 룰 `type_body_length: warning 300 / error 500`. (현재 `.swiftlint.yml`이 중복 키로 파싱 실패해 기본값이 적용되고 있었다. 설정 수정 후 살아난다.)

**예외(베이스라인)** — 7건 동결. `HomeViewModel`은 별도 리팩터링 티켓 대상.

---

## R9. 로그는 Log 모듈로 남기고 `print`·`as!`·`try!`는 쓰지 않는다

**규칙** — 앱 로그·이벤트는 `Log` 모듈(`LogManager`)로 남긴다. `print`, 강제 캐스팅 `as!`, 강제 시도 `try!`는 쓰지 않는다.

**이유** — `print`는 릴리즈에서 유실되고 Crashlytics에 남지 않는다. `as!`/`try!`는 서버 응답이 바뀌는 순간 크래시로 직결된다. 실패는 `Result`/옵셔널로 흘려 `output.error`로 보낸다.

**좋은 예**
```swift
dependency.logManager.sendEvent(event: ClickEvent(clickLog: clickLog))

guard let cell = cell as? MenuCell else { return }
```

**나쁜 예**
```swift
print("fetch failed \(error)")          // ❌
let cell = cell as! MenuCell            // ❌
let data = try! JSONDecoder().decode(...)  // ❌
```

**강제 수단** — SwiftLint custom_rule `no_print` + 기본 룰 `force_cast`, `force_try`를 `error`로 승격.

**예외(베이스라인)** — `print` 4건, `as!` 2건 동결. `Modules/Core/Network/.../Logger/NetworkLogger.swift`와 `ResponseProvider.swift`의 디버그 출력은 네트워크 로거 자체라 규칙 대상에서 제외한다. App 익스텐션 타깃(`service-extension`)은 Log 모듈을 못 쓰므로 제외.

---

## R10. ViewModel 구조·Route 분리·서버 네이밍을 통일한다

**규칙** — 모든 ViewModel은 `Input / Output / Route / Config / Dependency / State`의 중첩 타입 구조를 따른다. `Route` 처리는 ViewController의 `extension`(`// MARK: Route`)으로 분리한다. API·Repository·Model 이름은 서버(OpenAPI)에서 정의한 이름과 동일하게 짓는다.

**이유** — 화면 98개가 같은 모양이어야 AI가 새 화면을 만들 때도, 사람이 리뷰할 때도 "어디를 보면 되는지"를 안다. 서버 네이밍을 그대로 쓰면 API 문서와 코드 사이 번역 비용이 사라진다.

**좋은 예** — 루트 `CLAUDE.md`의 "ViewModel 구조 규칙" 템플릿, `StoreSectionsViewController.swift`의 `// MARK: Route` extension.

**나쁜 예**
```swift
final class StoreViewModel: BaseViewModel {
    let didTapButton = PassthroughSubject<Void, Never>()   // ❌ Input 밖에 흩어진 입력
    var items: [Item] = []                                 // ❌ State 밖 상태
}

struct StoreDetail: Decodable { let storeName: String }   // ❌ 서버는 `name`
```

**강제 수단** — 이 문서 + 디렉터리별 `CLAUDE.md` + PR AI 리뷰. 기계 판별이 애매해 유일하게 문서로만 강제한다. 반복 지적이 쌓이면 부분 규칙(예: "`*ViewModel.swift`에 `struct Input`이 없으면 실패")을 린트로 승격한다.

**예외** — `Route`가 없는 단순 화면은 `Route` 생략 가능. `Config`/`Dependency`/`State`는 필요할 때만.

---

## 베이스라인 운영

- SwiftLint: `.swiftlint-baseline.json`(`swiftlint lint --write-baseline`으로 생성). 베이스라인에 있는 위반은 보고되지 않는다. 파일을 옮기거나 크게 고쳐 베이스라인 매칭이 깨지면 그때 고친다.
- 모듈 의존성: `scripts/module-deps-baseline.txt`에 `Home -> Feed` 형태로 한 줄씩. 해소하면 줄을 지운다.
- 베이스라인은 **줄어들기만** 해야 한다. 새 항목을 추가하는 PR은 리뷰어가 사유를 확인한다.

## 규칙을 바꾸는 방법

1. PR 리뷰에서 같은 지적이 **3번** 이상 나오면 규칙 후보가 된다.
2. 기계 판별 가능하면 린트(custom_rule) → 아니면 스크립트 → 그래도 안 되면 이 문서. 문서로만 강제되는 규칙은 최소로 유지한다.
3. 10개를 넘기면 기존 규칙을 합치거나 뺀다. 규칙 변경 PR은 이 문서·`.swiftlint.yml`·디렉터리별 `CLAUDE.md`를 한 번에 바꾼다.
