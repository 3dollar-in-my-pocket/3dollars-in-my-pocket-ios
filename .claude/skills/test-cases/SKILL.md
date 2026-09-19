---
name: test-cases
description: 현재 브랜치의 지라 티켓 → 노션 테크스펙의 TC 목록을 읽어 TC별 테스트 케이스 표(자연어, 자동/수동 분류)를 만들고, 사람 승인 후 테스트 코드를 생성·실행해 PR용 TC 커버리지 표를 만든다. "/test-cases", "테스트 케이스 뽑아줘", "TC로 테스트 만들어줘", "이 티켓 테스트 써줘"라고 하면 사용. 테스트는 diff가 아니라 TC에서 도출한다.
---

# /test-cases — TC → 테스트 케이스 → 테스트 코드

가이드 문서 `docs/process/testing.md`를 먼저 읽는다. 이 스킬은 그 문서의 흐름을 자동화한다.

## 입력

- 인자 없음: 현재 브랜치명에서 티켓 키를 뽑는다 (`feature/TH-1234-xxx` → `TH-1234`).
- 인자로 티켓 키(`TH-1234`), 지라 URL, 노션 URL 중 하나를 줄 수도 있다.

## 절차

### 1. 의도 문서 찾기
1. 브랜치명 → 티켓 키.
2. `mcp__atlassian__getJiraIssue`로 티켓 조회 → 커스텀 필드 **`테크스펙`**(URL) 읽기. 비어 있으면 중단하고 "지라 Actions → 테크스펙 생성 후 TC를 적어달라"고 안내.
3. `mcp__notion__notion-fetch`로 노션 페이지 읽기 → "테스트 케이스 (TC)" 섹션의 `TC-n — ...` 항목 추출. TC가 0개면 중단.
4. 요약·요구사항 섹션도 읽어 어떤 화면/서비스가 대상인지 파악.

### 2. 코드 대상 매핑
- 현재 브랜치의 diff(`git diff develop...HEAD --name-only`)에서 바뀐 ViewModel·서비스 파일을 찾는다. **diff는 "어느 파일을 테스트할지" 찾는 데만 쓰고, "무엇을 검증할지"는 TC에서만 가져온다.**
- 각 TC를 아래 중 하나로 분류:
  - **ViewModel**: 화면 동작 → 대상 `XxxViewModel`, 관련 Input/Output/Route 이름
  - **Service**: 서비스·매니저·API 정의 → 대상 클래스/메서드
  - **Decoding**: 서버 응답 구조 변경 → 대상 Model 타입
  - **수동**: 애니메이션·지도·외부 SDK·권한·푸시 (testing.md 기준)

### 3. 테스트 케이스 표 제안 (여기서 멈추고 승인받는다)

```
| TC | 종류 | 대상 | Given | When | Then | 테스트 메서드명 |
|---|---|---|---|---|---|---|
| TC-1 | ViewModel | StoreSectionsViewModel | 서버가 섹션 1개 응답 | load | output.sections 1개 | test_TC1_로드하면_섹션이전달된다 |
| TC-2 | 수동 | — | — | — | 마커 확대 애니메이션 | (PR 체크리스트) |
```

- TC 하나가 여러 케이스로 갈라지면 행을 늘린다 (같은 `test_TC1_` 접두).
- 필요한 목/픽스처가 없으면 "신규 필요" 열에 표시 (`MockFeedRepository` 신규, `HomeStores.json` 재사용 등).
- 사용자가 표를 수정·승인하기 전에는 코드를 쓰지 않는다.

### 4. 코드 생성 (승인 후)
- 위치·네이밍·목·픽스처 규칙은 `docs/process/testing.md`. ViewModel 테스트의 구체 템플릿은 `ios-viewmodel-test-generator` 스킬.
- 목이 없으면 `Sources/Support/Mock{Protocol}.swift`에 만든다 (fatalError 금지, `.failure(MockError.notStubbed())`).
- 픽스처가 없으면 사용자에게 Proxyman 캡처를 요청하거나, 기존 픽스처를 복사해 값만 바꾼다.
- 테스트 타깃이 대상 Feature 모듈을 의존하지 않으면 `App/Project.swift` 테스트 타깃 `dependencies`에 추가하고 `make project` (사용자에게 알린다).

### 5. 실행·검증
```bash
xcodebuild test -workspace 3dollar-in-my-pocket.xcworkspace -scheme three-dollar-in-my-pocketTests \
  -destination 'platform=iOS Simulator,id=<UDID>' -only-testing:three-dollar-in-my-pocketTests/{TestClass}
```
- 실패하면 테스트가 틀렸는지 구현이 틀렸는지 판단해 보고한다. **TC와 구현이 다르면 구현을 고치는 게 기본** (TC가 의도).
- `make lint` 통과 확인.

### 6. 결과 표 출력 (PR 본문용)

```
| TC | 테스트 | 결과 |
|---|---|---|
| TC-1 | `test_TC1_로드하면_섹션이전달된다` | ✅ |
| TC-2 | 수동 — 마커 확대 애니메이션 | ☐ |
```

커버되지 않은 TC(테스트도 수동 항목도 없음)가 있으면 맨 위에 ⚠️로 표시한다.

## 하지 말 것
- diff를 읽고 "이 코드가 이렇게 동작한다"를 테스트로 옮기지 않는다 (구현 복제 테스트).
- TC에 없는 케이스를 임의로 추가하지 않는다. 필요하면 "TC 추가 제안"으로 따로 표시해 사용자가 노션에 반영하게 한다.
- 승인 없이 코드 생성으로 넘어가지 않는다.
- 커밋하지 않는다 (사용자가 요청할 때만).
