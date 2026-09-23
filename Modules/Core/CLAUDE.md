# Modules/Core — 작업 규칙

Core는 모든 Feature와 App이 공유하는 하위 계층이다. 여기서 작업할 때 지켜야 할 규칙만 적는다.
규칙의 이유·예시·예외는 [docs/architecture/RULES.md](../../docs/architecture/RULES.md)에 있다.

## 여기서 반드시 지킬 것

- **R1** Core는 Feature·App을 의존하지 않는다. `Project.swift`에 `.Feature.xxx`나 `.Interface.xxxInterface`(Feature 인터페이스)를 넣지 않는다. 유일한 예외는 `.Interface.appInterface`(App이 하위에 노출하는 계약, RULES.md R1 예외).
- **R4** 서버 호출은 `Core/Network`의 `XxxApi`(enum + `RequestType`) → `XxxRepository`(protocol) → `XxxRepositoryImpl` 구조로만 만든다. 네이밍은 서버 OpenAPI와 동일하게.
- **R4** DI 조회는 `DIContainer.shared.resolver.resolve(...)`만 쓴다. `container`는 등록 전용이고 동기화되지 않아 동시 조회 시 크래시한다.
- **R9** `print` 대신 `Log` 모듈. `Network/.../Logger/`만 예외.
- Common의 `BaseViewController` / `BaseViewModel` / `BaseCollectionViewCell`은 모든 화면이 상속하는 클래스다(R5·R6). 시그니처를 바꾸면 98개 ViewModel·전 화면에 영향이 가니 변경 전에 사용처를 확인한다.

## 모듈별 역할 (새 코드가 어디에 가야 하는지)

| 모듈 | 넣을 것 | 넣지 말 것 |
|---|---|---|
| Model | 서버 요청/응답 DTO, 도메인 enum | UI 타입, 네트워크 코드, 주석 |
| Network | API enum, Repository, NetworkManager | 화면 로직 |
| Common | Base 클래스, UIKit/Foundation 확장, 공용 유틸 | 특정 Feature 전용 뷰 |
| DesignSystem | Colors/Fonts/Icons, 공용 UI 컴포넌트 | 비즈니스 로직 |
| Log | LogManager, 이벤트 정의 | — |
| DependencyInjection | Swinject 컨테이너(`container`=등록, `resolver`=조회) | 구현체 등록은 App에서 |
| SDU | 서버 주도 UI 셀·데이터소스·컬렉션뷰 래퍼 | 특정 화면 로직 |

## 검증

```bash
make lint
```
SwiftLint + 모듈 의존성 검사(`scripts/check-module-deps.sh`)를 함께 돌린다. 새 위반이 0이어야 한다.
