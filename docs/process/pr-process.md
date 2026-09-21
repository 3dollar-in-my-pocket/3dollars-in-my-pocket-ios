# PR 프로세스 (한 장 요약)

AI가 코드를 많이 쓰는 환경에서 사람 리뷰어는 **diff 전체가 아니라 의도(TC) · 모듈 경계 · 검증 증거**만 본다.
나머지(스타일, 구조 규칙, 회귀)는 린트·스크립트·테스트·AI가 맡는다. 이 문서는 전체 흐름과 도구 매핑, 그리고 PR 위험도별 요구 수준을 정한다.

## 흐름과 도구

| 단계 | 하는 일 | 도구 | 산출물이 가는 곳 |
|---|---|---|---|
| 1. 의도 정의 | 지라 티켓에서 테크스펙 생성, 요약·요구사항·TC 작성 | 지라 Actions "테크스펙 생성" → 노션 | 지라 `테크스펙` 필드 (단일 진실 소스) |
| 2. 코드 작성 | 규칙 10개(R1~R10) 안에서 구현 | `docs/architecture/RULES.md`, 디렉터리별 `CLAUDE.md`, `make lint`(SwiftLint custom_rules + `check-module-deps.sh`) | 로컬 + `lint.yml` |
| 3. 테스트 | TC에서 테스트 케이스 표 → 승인 → 코드 | `/3dollars:test-cases`, `docs/process/testing.md` | `Sources/{ViewModel,Service,Decoding}Tests/`, 메서드명 `test_TC{n}_` |
| 4. 동작 증거 | 테스트 결과·TC 커버리지 표·UI 캡처 | `test.yml` + `scripts/test-summary.sh`, `3dollars:simulator-test` | PR 코멘트(자동), 본문 "증거" |
| 5. 스코프 드리프트 | 요구사항 ↔ diff 대조, 스펙 밖 변경 목록 | `/3dollars:drift` | 본문 "스펙 밖 변경" |
| 6. 수동 범위 | 자동화 안 되는 TC + UI 변경 공통 체크 | `docs/process/manual-test-checklist.md` (pr-body가 자동 삽입) | 본문 "TC" 체크리스트 |
| 7. 검증 장치 변경 | 린트·CI·규칙 파일을 건드린 PR 표시 | `.github/labeler.yml` + `labeler.yml`, `docs/process/verification-change.md` | 라벨 + 파일 목록 코멘트 |
| 8. 설명 못 하는 부분 | 비자명한 결정 3개를 작성자에게 질문 | `/3dollars:ask-author` | 본문 "설명이 필요한 결정" |
| 9. 반복 지적 → 규칙 | 리뷰 코멘트 집계, 3회↑ 승격 제안 | `/3dollars:review-digest` | RULES.md·`.swiftlint.yml` 변경 PR |
| PR 생성 | 위 결과를 템플릿에 채워 생성/갱신 | `/3dollars:pr-body` (`.github/PULL_REQUEST_TEMPLATE.md`) | GitHub PR |
| 리뷰 | 의도·경계·증거 기준 리뷰 | `/3dollars:pr-code-review` + 사람 | PR 코멘트 |

작성자 기준 순서: **테크스펙 → 구현 → `/3dollars:test-cases` → `make lint` → (UI면) `simulator-test` → `/3dollars:pr-body`** (pr-body가 drift·ask-author·체크리스트를 안에서 호출).

## 위험도: 경량 / 풀코스

PR 본문 첫 줄 `위험도:`에 적는다. `/3dollars:pr-body`가 아래 기준으로 판정하고, 작성자가 바꿀 수 있다(바꾸면 사유 한 줄).

| | 경량 | 풀코스 |
|---|---|---|
| **조건** | 아래 전부: 문서/테스트/CI만 바뀜 **또는** 단일 Feature 모듈 안의 UI·로직 변경, Core/App/Network/DI/Tuist 매니페스트 미변경, 베이스라인 미변경, 로그인·결제·딥링크·푸시 흐름 미변경 | 하나라도: `module-boundary`·`baseline-change` 라벨, Core/App/Network 변경, 새 API·Repository, 로그인·결제·딥링크·푸시·권한 흐름, 3개 이상 Feature 모듈 동시 변경 |
| **자동 검증** | `lint.yml`, `test.yml` | 동일 |
| **본문 필수** | 의도 링크, 변경 불릿, 수동 TC 체크(해당 시) | + `drift` 요구사항 표 **전체**(스펙 밖 변경만이 아니라), `ask-author` Q/A, UI 변경이면 `simulator-test` Before/After 증거 |
| **사람 리뷰** | 본문만 보고 승인 가능. 스펙 밖 변경이 "없음"이면 diff를 열 필요 없음 | 라벨이 가리키는 파일(검증 장치·매니페스트·Interface)을 **먼저** 읽고, 그다음 drift 표의 "부분/없음" 항목 |
| **머지 조건** | CI 초록 + 수동 TC 전부 체크 | + 리뷰 승인 1명 |

라벨은 표시일 뿐이며 워크플로를 조건 실행하지 않는다. 풀코스 요구사항은 작성자와 리뷰어가 본문으로 확인한다. (라벨 조건 실행이 필요해지면 `test.yml`에 `if: contains(labels, ...)` 잡을 추가한다.)

## 예외

- **핫픽스**(`hotfix/`): 테크스펙 생략 가능. 대신 본문 "의도"에 장애 내용 1줄 + 재현 경로, 풀코스 취급.
- **릴리즈 브랜치**(`release/`): 버전·빌드 번호 변경만이면 경량.
- **의존성 업데이트**: `Tuist/Package.resolved`만 바뀌면 경량, `Project.swift`까지 바뀌면 풀코스.

## 규칙을 바꾸고 싶을 때

이 문서, `RULES.md`, `.swiftlint.yml`, 디렉터리별 `CLAUDE.md`는 **함께** 바뀐다. 입구는 `/3dollars:review-digest`(반복 지적) 또는 `verification-change` 라벨이 붙는 PR이며, 린트·CI 변경은 적용 전에 확인받는다.
