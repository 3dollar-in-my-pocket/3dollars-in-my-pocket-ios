# 검증 장치 변경 감지

린트·테스트·CI·모듈 규칙은 PR을 검증하는 **장치**다. 장치 자체를 바꾸는 PR은 린트·테스트가 초록불이어도 그 결과를 그대로 믿을 수 없다.
그래서 **경로만 보고 결정론적으로** 라벨을 붙이고, 바뀐 장치 파일 목록을 코멘트로 남긴다. AI 판단은 개입하지 않는다.

## 라벨 (`.github/labeler.yml`, `actions/labeler`)

| 라벨 | 붙는 조건 (경로) | 리뷰어가 볼 것 |
|---|---|---|
| `verification-change` | `.github/**`, `.swiftlint.yml`, 베이스라인, `scripts/**`, `makefile`, `ci_scripts/**`, `Tuist/**`, `**/Project.swift`, 테스트 타깃, `RULES.md`, `CLAUDE.md`류 | 코드보다 **이 파일들을 먼저** 본다. 왜 바꿨는지가 본문 "설명이 필요한 결정"에 있어야 한다 |
| `baseline-change` | `.swiftlint-baseline.json`, `scripts/module-deps-baseline.txt` | 베이스라인은 **줄어들기만** 해야 한다. 항목이 늘었으면 사유 확인 (RULES.md "베이스라인 운영") |
| `module-boundary` | `**/Project.swift`, `Tuist/ProjectDescriptionHelpers/**`, `Modules/Feature/*/Targets/Interface/**` | R1/R2 위반 여부. `scripts/check-module-deps.sh`가 통과해도 Interface에 구현이 들어갔는지(R3) 눈으로 본다 |

라벨은 **표시**일 뿐 검증을 실행하지 않는다. 린트·테스트(`lint.yml`, `test.yml`)는 라벨과 무관하게 모든 PR에서 돈다.
라벨을 조건으로 추가 검증을 돌리는 것(풀코스)은 `docs/process/pr-process.md`(위험도 차등)에서 정한다.

## 코멘트 (`.github/workflows/labeler.yml`)

`verification-change`가 붙으면 바뀐 장치 파일 목록을 PR 코멘트 하나에 갱신형으로 남긴다. 작성자는 각 파일을 왜 바꿨는지 본문에 적는다.

## 경로 목록을 바꿀 때

- `.github/labeler.yml`과 `labeler.yml` 워크플로의 grep 패턴을 **같이** 바꾼다.
- 새 검증 장치(예: 스냅샷 테스트, 새 스크립트)를 추가하면 그 경로도 추가한다.
- 라벨은 레포에 미리 만들어져 있어야 한다 (`gh label create`). `actions/labeler`는 라벨을 생성하지 않는다.
