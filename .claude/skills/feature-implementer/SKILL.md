---
name: feature-implementer
description: 테크스펙 문서를 기반으로 새로운 피처를 구현하는 전체 파이프라인을 자동화합니다. 구현 → 테스트 → 수정 → 커밋까지 자동으로 수행합니다.
---

# 피처 구현 자동화 Skill

테크스펙 문서를 기반으로 새로운 피처를 자동으로 구현하고 테스트합니다.

---

## 입력

다음 형태 중 하나로 테크스펙을 제공할 수 있습니다:

1. **마크다운 파일 경로** (예: `/path/to/TH-XXX.md`)
2. **텍스트 파일 경로** (예: `/path/to/spec.txt`)
3. **직접 텍스트 입력** (대화형)
4. (선택) 피그마 디자인 URL

인자 없이 호출 시 대화형으로 테크스펙을 입력받습니다.

---

## 실행 절차

### Step 1: 사전 검증 (자동 승인)

#### 테크스펙 파일/텍스트 확인

입력받은 테크스펙 확인:
- **파일 경로인 경우**: Read tool로 파일 내용 읽기
- **직접 텍스트인 경우**: 입력받은 텍스트 사용
- **인자 없이 호출된 경우**: AskUserQuestion으로 테크스펙 텍스트 입력 요청
- **실패**: ❌ "테크스펙을 읽을 수 없습니다." 출력 후 종료

#### Figma MCP 연결 확인 (선택)

피그마 URL이 제공된 경우 연결 확인:
- **성공**: 피그마 디자인 가져오기 가능
- **실패**: ⚠️ 경고만 표시하고 계속 진행 (필수 아님)

#### GitHub 권한 확인

```bash
gh auth status
```

GitHub 인증 확인:
- **실패**: ❌ "GitHub 인증이 필요합니다. 'gh auth login' 명령어를 실행해주세요." 출력 후 종료

```bash
gh pr list --limit 1
```

저장소 권한 확인:
- **실패**: ❌ "현재 저장소에 대한 GitHub 권한이 없습니다." 출력 후 종료

---

### Step 2: 테크스펙 분석 (자동 승인)

#### 테크스펙 문서 읽기

1. 제공된 테크스펙에서 다음 정보 추출:
   - **피처 이름**: 구현할 기능 이름
   - **JIRA 티켓 번호**: 브랜치명에 사용 (예: TH-XXX)
   - **요구사항**: 기능 상세 설명
   - **API 스펙**: 서버 API 엔드포인트 및 요청/응답 구조
   - **화면 구성**: UI 구조 및 레이아웃
   - **데이터 모델**: 필요한 Model 구조
   - **유저 플로우**: 사용자 시나리오

2. 정보가 부족한 경우 AskUserQuestion으로 추가 정보 요청

#### 피그마 디자인 확인 (선택)

피그마 URL이 제공된 경우:
1. Figma MCP의 `get_design_context` 도구로 디자인 정보 가져오기
2. 다음 정보 추출:
   - UI 컴포넌트 구조
   - 색상, 폰트, 간격 정보
   - 화면별 레이아웃
   - 인터랙션 패턴

#### 유사 패턴 탐색

노션 테크스펙에서 언급된 기존 피처나 유사 기능이 있다면:
```bash
# 예: "기여자 목록 화면과 유사하게 구현"
```
- Glob/Grep으로 관련 파일 검색
- Read로 참고할 코드 읽기

---

### Step 3: 플랜 모드 진입 및 설계

#### EnterPlanMode 호출 ⚠️

**사용자에게 플랜 모드 진입 승인 요청**
- 승인되면 계속 진행
- 거부되면 종료

#### Phase 1: 코드베이스 탐색 (Read-only)

**Task tool로 Explore agent 실행하여 유사 패턴 탐색:**

1. **유사 ViewModel 찾기**
   - 노션 테크스펙에서 언급된 기존 피처 찾기
   - 비슷한 구조의 ViewModel 읽기
   - Input/Output/Route/Config/Dependency/State 패턴 확인

2. **유사 Repository 찾기**
   - API 스펙과 유사한 Repository 찾기
   - API enum + RequestType 패턴 확인
   - Protocol + Impl 구조 확인

3. **SDU 모듈 사용 여부 확인**
   - 서버에서 UI 데이터를 제공하는 경우 SDU 사용
   - SDUCollectionView, SDUDataSource 패턴 확인
   - 기존 SDU 사용 예시 읽기

4. **UI 패턴 확인**
   - BaseViewController 상속 패턴
   - SnapKit 레이아웃 패턴
   - DesignSystem 사용 패턴

**참고 파일 읽기:**
- CLAUDE.md (프로젝트 고유 패턴)
- ios-viewmodel-pattern skill (ViewModel 구조)
- ios-repository-pattern skill (Repository 구조)
- 유사 기능의 ViewModel, ViewController, Repository

#### Phase 2: 구현 계획 수립

**구현해야 할 파일 목록 작성:**

1. **Model 추가** (있다면)
   - 위치: `Modules/Core/Model/Sources/Domain/Response/`
   - API 응답 구조체
   - 서버 스펙과 동일한 네이밍

2. **API 추가**
   - 위치: `Modules/Core/Network/Sources/API/{Domain}Api.swift`
   - API enum case 추가
   - RequestType 확장 (param, method, header, path)

3. **Repository 추가**
   - 위치: `Modules/Core/Network/Sources/Repository/{Domain}Repository.swift`
   - Protocol에 메서드 추가
   - Impl에 구현 추가

4. **ViewModel 생성**
   - 위치: `Modules/Feature/{Feature}/Targets/{Feature}/Sources/Domains/{Screen}/`
   - Input/Output/Route/Config/Dependency/State 구조
   - bind() 메서드 구현
   - async/await 메서드 구현

5. **ViewController 생성**
   - 위치: `Modules/Feature/{Feature}/Targets/{Feature}/Sources/Domains/{Screen}/`
   - BaseViewController 상속
   - UI 구성 (SnapKit)
   - ViewModel 바인딩
   - Route 처리

6. **테스트 코드 생성** (Phase 2 추가)
   - 위치: `App/Targets/three-dollar-in-my-pocketTests/ViewModelTests/`
   - Given-When-Then 패턴
   - Mock Repository
   - 유저 플로우 기반 테스트

#### Phase 3: 플랜 작성

플랜 파일에 다음 내용을 체계적으로 작성:

```markdown
# Implementation Plan: {피처 이름}

## Feature Overview

### 테크스펙
- 티켓 번호: {JIRA 티켓 번호} (있는 경우)
- 피처명: {이름}
- 요구사항: {요약}

### 피그마 디자인 (if applicable)
- URL: {피그마 URL}
- 화면 구성: {요약}

## Technical Specification

### API Endpoints
- **GET** `/api/v1/{path}`: {설명}
  - Request: {구조}
  - Response: {구조}

### Data Models
- `{Model이름}Response`: {설명}
  - 필드 1: {타입} - {설명}
  - 필드 2: {타입} - {설명}

### UI Components
- {컴포넌트 1}: {설명}
- {컴포넌트 2}: {설명}

## Implementation Plan

### 1. Model 추가
**파일**: `Modules/Core/Model/Sources/Domain/Response/{Model이름}Response.swift`

```swift
public struct {Model이름}Response: Decodable {
    public let field1: String
    public let field2: Int
}
```

### 2. API 추가
**파일**: `Modules/Core/Network/Sources/API/{Domain}Api.swift`

```swift
// API enum에 추가
case fetch{Feature}(input: Fetch{Feature}Input)

// RequestType 확장
var param: Encodable? {
    case .fetch{Feature}(let input):
        return input
}

var method: RequestMethod {
    case .fetch{Feature}:
        return .get
}

var header: HTTPHeaderType {
    case .fetch{Feature}:
        return .json
}

var path: String {
    case .fetch{Feature}(let input):
        return "/api/v1/{path}/\(input.id)"
}
```

### 3. Repository 추가
**파일**: `Modules/Core/Network/Sources/Repository/{Domain}Repository.swift`

```swift
// Protocol에 추가
func fetch{Feature}(input: Fetch{Feature}Input) async -> Result<{Model}Response, Error>

// Impl에 추가
public func fetch{Feature}(input: Fetch{Feature}Input) async -> Result<{Model}Response, Error> {
    let request = {Domain}Api.fetch{Feature}(input: input)
    return await NetworkManager.shared.request(requestType: request)
}
```

### 4. ViewModel 생성
**파일**: `Modules/Feature/{Feature}/Targets/{Feature}/Sources/Domains/{Screen}/{Screen}ViewModel.swift`

**구조**:
- Input: load, didTapClose, didTap{Button}, loadMore
- Output: items, route, error, screenName
- Route: dismiss, push{Screen}
- Config: {필요한 초기 설정}
- Dependency: {Domain}Repository, LogManager
- State: cursor, isLoading

**참고**: ios-viewmodel-pattern skill

### 5. ViewController 생성
**파일**: `Modules/Feature/{Feature}/Targets/{Feature}/Sources/Domains/{Screen}/{Screen}ViewController.swift`

**구조**:
- BaseViewController 상속
- SnapKit으로 레이아웃
- DesignSystem 사용 (Colors, Fonts, Icons)
- ViewModel 바인딩

**참고**: CLAUDE.md의 ViewController 패턴

### 6. 테스트 코드 생성
**파일**: `App/Targets/three-dollar-in-my-pocketTests/ViewModelTests/{Screen}ViewModelTests.swift`

**테스트 케이스**:
- test_사용자가로드버튼을탭하면_데이터가로드된다
- test_네트워크에러시_에러메시지가전달된다
- test_닫기버튼탭시_dismiss라우팅이발생한다

**참고**: ios-viewmodel-test-generator skill

## SDU 모듈 사용 (if applicable)

서버에서 UI 데이터를 제공하는 경우:
- SDUCollectionView 사용
- SDUDataSource로 데이터 바인딩
- SDUItem enum 활용

**참고**: CLAUDE.md의 SDU 모듈 섹션

## User Flow

1. {사용자 액션 1}
2. {사용자 액션 2}
3. {예상 결과}

## Implementation Order

1. Model 추가 → 2. API 추가 → 3. Repository 추가 → 4. ViewModel 생성 → 5. ViewController 생성 → 6. 테스트 코드 생성

## Risks & Considerations

- {리스크 1}
- {리스크 2}

**난이도**: {낮음/중간/높음} - {이유}
```

#### ExitPlanMode 호출 ⚠️

**사용자에게 계획 승인 요청**
- 승인되면 구현 시작
- 거부되면 플랜 수정 또는 종료

---

### Step 4: 워크트리 설정 (자동 승인)

#### 브랜치 이름 결정

노션 테크스펙에서 JIRA 티켓 번호 추출 (예: TH-XXX) 또는 피처 이름 사용:
- JIRA 티켓이 있는 경우: `feature/TH-XXX-{간단한설명}`
- 없는 경우: `feature/{피처명}`

#### 워크트리 생성

```bash
# 저장소 루트 확인
git rev-parse --show-toplevel

# 워크트리 생성 (develop 브랜치 기반)
git worktree add -b feature/{브랜치명} ../worktree-{브랜치명} develop

# 워크트리로 이동
cd ../worktree-{브랜치명}
```

워크트리 디렉토리 경로: `{저장소루트}/../worktree-{브랜치명}`

#### 워크트리에서 작업

이후 모든 작업은 워크트리 디렉토리에서 진행하므로 원본 저장소는 영향받지 않습니다.

---

### Step 5: 코드 구현 (자동 승인)

#### TodoWrite로 작업 관리

플랜에 따라 구현 순서대로 todo 생성:

```
1. [pending] {Model이름}Response.swift 생성
2. [pending] {Domain}Api.swift에 API 추가
3. [pending] {Domain}Repository.swift에 메서드 추가
4. [pending] {Screen}ViewModel.swift 생성
5. [pending] {Screen}ViewController.swift 생성
6. [pending] {Screen}ViewModelTests.swift 생성
```

각 작업 시작 시 `in_progress`로 변경, 완료 시 `completed`로 변경

#### 1. Model 생성

**위치**: `Modules/Core/Model/Sources/Domain/Response/{Model이름}Response.swift`

**규칙**:
- Decodable 프로토콜 준수
- public 접근 제어자
- 서버 스펙과 동일한 필드명 (camelCase 변환)
- CodingKeys로 서버 필드명 매핑 (필요시)

**참고**: 기존 Response 파일들

#### 2. API 추가

**위치**: `Modules/Core/Network/Sources/API/{Domain}Api.swift`

**규칙**:
- enum case 추가
- RequestType 확장 (param, method, header, path)
- 서버 API 스펙과 동일하게 구현

**참고**: ios-repository-pattern skill

#### 3. Repository 추가

**위치**: `Modules/Core/Network/Sources/Repository/{Domain}Repository.swift`

**규칙**:
- Protocol에 메서드 시그니처 추가
- Impl에 메서드 구현 추가
- async/await + Result 타입 사용

**참고**: ios-repository-pattern skill

#### 4. ViewModel 생성

**위치**: `Modules/Feature/{Feature}/Targets/{Feature}/Sources/Domains/{Screen}/{Screen}ViewModel.swift`

**규칙**:
- BaseViewModel 상속
- Input/Output/Route/Config/Dependency/State 구조
- bind() 메서드 구현
- @MainActor async 메서드 구현

**참고**: ios-viewmodel-pattern skill

**필수 import**:
```swift
import Foundation
import Combine

import Common
import Log
import Model
import Networking
```

**템플릿 활용**:
- ios-viewmodel-pattern skill의 전체 템플릿 참고
- ContributorsViewModel 패턴 참고

#### 5. ViewController 생성

**위치**: `Modules/Feature/{Feature}/Targets/{Feature}/Sources/Domains/{Screen}/{Screen}ViewController.swift`

**규칙**:
- BaseViewController 상속
- SnapKit으로 레이아웃 (leading/trailing 사용)
- DesignSystem 사용 (Colors, Fonts, Icons)
- then 라이브러리 사용 금지
- bindViewModelInput(), bindViewModelOutput() 구현
- Route 처리는 extension으로 분리

**필수 import**:
```swift
import UIKit
import Combine

import Common
import DesignSystem
import Model
import SnapKit
```

**참고**: CLAUDE.md의 ViewController 패턴, ContributorsViewController

**UI 컴포넌트 생성 패턴**:
```swift
private let label: UILabel = {
    let label = UILabel()
    label.text = "텍스트"
    label.font = Fonts.semiBold.font(size: 16)
    label.textColor = Colors.gray100
    return label
}()
```

**SDU 사용 시**:
```swift
private let sduView = SDUCollectionView()
private lazy var dataSource = SDUDataSource(collectionView: sduView.collectionView)

// Layout 설정
sduView.setLayout(createLayout())

// 데이터 바인딩
viewModel.output.items
    .receive(on: DispatchQueue.main)
    .sink { [weak self] items in
        self?.dataSource.reload(items)
    }
    .store(in: &cancellables)
```

#### CLAUDE.md 컨벤션 준수

- Import 순서: 표준 → 내부모듈 → 서드파티 (각 그룹 사이 빈 줄)
- SnapKit 사용 시 leading/trailing 사용
- then 라이브러리 사용 금지
- BaseViewController, BaseViewModel 상속
- ViewModel 구조: Input, Output, Route, Config, Dependency, State
- UICollectionViewCell은 BaseCollectionViewCell 상속

---

### Step 6: 테스트 코드 생성 (자동 승인)

#### 테스트 파일 생성

**위치**: `App/Targets/three-dollar-in-my-pocketTests/ViewModelTests/{Screen}ViewModelTests.swift`

**규칙**:
- XCTestCase 상속
- Given-When-Then 패턴
- Mock Repository 생성
- 유저 플로우 기반 테스트 케이스
- async/await 테스트는 await Task.yield() 사용

**참고**: ios-viewmodel-test-generator skill

**필수 import**:
```swift
import XCTest
import Combine
@testable import three_dollar_in_my_pocket
```

**템플릿 활용**:
- ios-viewmodel-test-generator skill의 전체 템플릿 참고
- Mock Repository 패턴 참고

**기본 테스트 케이스**:
1. `test_사용자가로드버튼을탭하면_데이터가로드된다()` - 기본 데이터 로드
2. `test_네트워크에러시_에러메시지가전달된다()` - 에러 처리
3. `test_닫기버튼탭시_dismiss라우팅이발생한다()` - 화면 전환

**추가 테스트 케이스 (필요시)**:
- 페이지네이션 테스트
- 중복 요청 방지 테스트
- 빈 데이터 처리 테스트

#### Mock Repository 생성

테스트 파일 하단에 Mock 클래스 생성:

```swift
// MARK: - Mock Repository

final class Mock{Domain}Repository: {Domain}Repository {
    var fetch{Feature}Result: Result<{Model}Response, Error>?
    var lastRequestInput: Fetch{Feature}Input?

    func fetch{Feature}(input: Fetch{Feature}Input) async -> Result<{Model}Response, Error> {
        lastRequestInput = input
        guard let result = fetch{Feature}Result else {
            return .failure(NSError(domain: "Mock", code: -1))
        }
        return result
    }

    // 다른 메서드들은 기본 구현 제공
    // ...
}

// MARK: - Mock LogManager

final class MockLogManager: LogManagerProtocol {
    func sendPageView(screen: ScreenName, type: AnyClass) { }
    func sendEvent(_ event: LogEvent) { }
}
```

---

### Step 7: 코드 정리 (자동 승인)

#### code-cleanup skill 실행

Skill tool로 `code-cleanup` 호출하여 수정한 파일들의:
- Import 정렬 (표준 → 내부모듈 → 서드파티)
- 코드 스타일 정리
- 불필요한 공백 제거
- SwiftLint 검증 및 자동 수정

```bash
# code-cleanup이 실행하는 명령어들
swiftlint --fix
swiftlint lint
```

수정된 파일만 정리하고, 다른 파일은 건드리지 않습니다.

---

### Step 8: 빌드 및 테스트 (자동 승인)

#### Tuist 프로젝트 생성

워크트리 디렉토리에서 실행:

```bash
make project
```

프로젝트 생성이 완료될 때까지 대기합니다.

#### 빌드 실행

```bash
xcodebuild build \
  -workspace 3dollar-in-my-pocket.xcworkspace \
  -scheme three-dollar-in-my-pocket-debug \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

**빌드 결과 확인**:
- ✅ **성공**: 다음 단계(테스트) 진행
- ❌ **실패**: Step 9 (수정 루프) 진행

#### 테스트 실행

빌드 성공 후:

```bash
xcodebuild test \
  -workspace 3dollar-in-my-pocket.xcworkspace \
  -scheme three-dollar-in-my-pocket-debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

**테스트 결과 확인**:
- ✅ **성공**: Step 10 (커밋) 진행
- ❌ **실패**: Step 9 (수정 루프) 진행

#### SwiftLint 최종 검증

```bash
swiftlint lint
```

**SwiftLint 결과 확인**:
- ✅ **통과**: Step 10 (커밋) 진행
- ❌ **오류**: Step 9 (수정 루프) 진행

---

### Step 9: 수정 루프 (자동 승인, 최대 5회)

빌드 실패, 테스트 실패, SwiftLint 오류 발생 시 자동으로 수정을 시도합니다.

**최대 5회 시도**: 5회 이내에 해결되지 않으면 사용자에게 수동 개입 요청

#### 9-1. 컴파일 에러 수정

**에러 분석**:
```bash
xcodebuild build ... 2>&1 | grep -A 5 "error:"
```

에러 메시지에서 다음 정보 추출:
- 파일 경로
- 라인 번호
- 에러 메시지
- 에러 타입 (타입 불일치, 누락된 import, 메서드 미정의 등)

**일반적인 컴파일 에러 패턴**:

1. **Import 누락**
   - `Cannot find type 'XXX' in scope` → import 추가
   - 필요한 모듈: Common, Model, Networking, DesignSystem, SnapKit, Combine

2. **타입 불일치**
   - `Cannot convert value of type 'X' to expected type 'Y'` → 타입 캐스팅 수정
   - Result 타입 확인
   - Optional 처리 확인

3. **메서드 미정의**
   - `Value of type 'X' has no member 'Y'` → 메서드명 확인
   - Repository Protocol과 Impl 동기화 확인
   - API enum case와 RequestType 확장 확인

4. **접근 제어자 문제**
   - `'X' is inaccessible due to 'internal' protection level` → public 추가
   - Protocol, struct, init은 public으로 선언

**자동 수정**:
- Edit tool로 에러가 발생한 파일 수정
- 수정 후 즉시 재빌드

#### 9-2. 테스트 실패 수정

**테스트 실패 분석**:
```bash
xcodebuild test ... 2>&1 | grep -A 10 "Test Case.*failed"
```

실패한 테스트에서 다음 정보 추출:
- 테스트 메서드명
- 실패 이유 (XCTAssert 실패 메시지)
- 예상값 vs 실제값

**일반적인 테스트 실패 패턴**:

1. **Mock 데이터 불일치**
   - Mock Response의 구조가 실제 Model과 다름 → Mock 데이터 수정
   - 필드명, 타입 확인

2. **비동기 처리 누락**
   - `await Task.yield()` 누락 → 추가
   - async 메서드 호출 후 await 확인

3. **구독 누락**
   - Output 구독이 안되어 있음 → 구독 코드 추가
   - cancellables에 저장 확인

4. **Mock Repository 메서드 미구현**
   - Mock에서 필요한 메서드 누락 → 메서드 추가

**자동 수정**:
- 테스트 파일 Edit
- 수정 후 즉시 재테스트

#### 9-3. SwiftLint 오류 수정

**SwiftLint 오류 분석**:
```bash
swiftlint lint 2>&1 | grep -E "(error|warning):"
```

**자동 수정 가능한 오류**:
```bash
swiftlint --fix
```

**수동 수정이 필요한 오류**:

1. **line_length (라인 길이 초과)**
   - 긴 줄을 여러 줄로 분리
   - 특히 메서드 체이닝, 파라미터가 많은 경우

2. **function_body_length (메서드 길이 초과)**
   - 메서드를 작은 함수로 분리
   - private helper 메서드 생성

3. **type_body_length (타입 길이 초과)**
   - extension으로 분리
   - nested type을 별도 파일로 분리 (필요시)

4. **identifier_name (네이밍 규칙 위반)**
   - 변수명을 camelCase로 수정
   - 너무 짧거나 긴 이름 수정

**자동 수정**:
- Edit tool로 오류가 발생한 파일 수정
- 수정 후 즉시 SwiftLint 재검증

#### 수정 루프 흐름

```
수정 시도 1 → 빌드/테스트/SwiftLint
  ↓ 실패
수정 시도 2 → 빌드/테스트/SwiftLint
  ↓ 실패
수정 시도 3 → 빌드/테스트/SwiftLint
  ↓ 실패
수정 시도 4 → 빌드/테스트/SwiftLint
  ↓ 실패
수정 시도 5 → 빌드/테스트/SwiftLint
  ↓ 실패
❌ 수동 개입 요청 (사용자에게 에러 내용 전달)
```

**성공 시**: Step 10 (커밋) 진행

---

### Step 10: Git 커밋 (자동 승인)

#### 작은 단위로 커밋 분리

**구현 흐름에 따라 논리적으로 분리**:

1. **Model 추가** (있다면)
   ```bash
   git add Modules/Core/Model/Sources/Domain/Response/{Model이름}Response.swift
   git commit -m "{티켓번호} : {Model이름}Response 모델 추가

   - {필드 설명}
   - {필드 설명}

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

2. **API 정의**
   ```bash
   git add Modules/Core/Network/Sources/API/{Domain}Api.swift
   git commit -m "{티켓번호} : {Domain}Api에 fetch{Feature} API 추가

   - GET /api/v1/{path}
   - {설명}

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

3. **Repository 구현**
   ```bash
   git add Modules/Core/Network/Sources/Repository/{Domain}Repository.swift
   git commit -m "{티켓번호} : {Domain}Repository에 fetch{Feature} 메서드 추가

   - Protocol 시그니처 추가
   - Impl 구현 추가

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

4. **ViewModel 생성**
   ```bash
   git add Modules/Feature/{Feature}/Targets/{Feature}/Sources/Domains/{Screen}/{Screen}ViewModel.swift
   git commit -m "{티켓번호} : {Screen}ViewModel 생성

   - Input/Output/Route/Config/Dependency/State 구조
   - {주요 로직 설명}

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

5. **테스트 코드 생성**
   ```bash
   git add App/Targets/three-dollar-in-my-pocketTests/ViewModelTests/{Screen}ViewModelTests.swift
   git commit -m "{티켓번호} : {Screen}ViewModelTests 생성

   - Given-When-Then 패턴 테스트
   - Mock Repository 구현
   - {테스트 케이스 개수}개 테스트 케이스

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

6. **ViewController 생성**
   ```bash
   git add Modules/Feature/{Feature}/Targets/{Feature}/Sources/Domains/{Screen}/{Screen}ViewController.swift
   git commit -m "{티켓번호} : {Screen}ViewController 생성

   - BaseViewController 상속
   - SnapKit 레이아웃
   - ViewModel 바인딩

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

#### 커밋 메시지 형식 (HEREDOC 사용)

```bash
git commit -m "$(cat <<'EOF'
{티켓번호} : {한 줄 요약}

- 상세 설명 1
- 상세 설명 2

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

#### 원칙

- 각 커밋은 독립적으로 의미 있어야 함
- 코드 리뷰어가 흐름을 이해하기 쉽게
- 4-6개 커밋 정도가 적당 (Model → API → Repository → ViewModel → Tests → ViewController)
- 수정 파일이 있다면 별도 커밋으로 분리

---

### Step 11: 워크트리 정리 및 복귀 (자동 승인)

#### Push (PR 생성은 수동)

모든 커밋 완료 후 한번에 push:

```bash
git push -u origin feature/{브랜치명}
```

**중요**: PR 생성은 사용자가 직접 수행합니다.

이유:
- PR 본문 작성 시 사용자가 추가 정보를 넣을 수 있음
- PR 리뷰어 지정은 사용자가 결정
- PR 생성은 마지막 확인 단계

#### 원본 저장소로 복귀

```bash
cd {원본저장소경로}
```

#### 워크트리 제거

```bash
# 워크트리 제거
git worktree remove ../worktree-{브랜치명}

# 디렉토리가 남아있다면 강제 제거
git worktree remove --force ../worktree-{브랜치명} 2>/dev/null || true
rm -rf ../worktree-{브랜치명} 2>/dev/null || true
```

---

### Step 12: 완료 및 요약

#### 작업 요약 출력

```
✅ {피처 이름} 구현 완료!

📋 생성된 파일: {개수}개
   - {Model파일} (있다면)
   - {API파일} (업데이트)
   - {Repository파일} (업데이트)
   - {ViewModel파일}
   - {ViewController파일}
   - {Tests파일}

🧪 테스트: {개수}개 테스트 케이스 통과
   - {테스트 케이스 1}
   - {테스트 케이스 2}
   - {테스트 케이스 3}

🔧 커밋: {개수}개 (논리적 흐름으로 분리)
   - {커밋1 요약}
   - {커밋2 요약}
   - ...

🚀 브랜치: feature/{브랜치명}
   → Push 완료: origin/feature/{브랜치명}

📌 다음 단계:
   1. PR 생성 (수동):
      gh pr create --base develop --title "{티켓번호} : {PR 제목}" --body "{PR 본문}"

   2. PR 본문 예시:
      ## 구현 내용
      {피처 설명}

      ## 주요 변경사항
      - {변경사항 1}
      - {변경사항 2}

      ## 테스트
      - {테스트 항목 1}
      - {테스트 항목 2}

      🤖 Generated with [Claude Code](https://claude.com/claude-code)

   3. PR 리뷰 요청
   4. 테스트 진행
   5. 머지 후 배포
```

---

## Phase 3-4 완료 기준

✅ code-cleanup 실행 완료
✅ 빌드 성공 (three-dollar-in-my-pocket-debug)
✅ 테스트 통과 (모든 ViewModel 테스트)
✅ SwiftLint 검증 통과
✅ Git 커밋 완료 (4-6개 커밋)
✅ Push 완료
✅ 워크트리 정리 완료

---

## 자동 승인 권한

다음 작업들은 사용자 확인 없이 자동으로 진행됩니다:

- ✅ 모든 Read 작업 (Glob, Grep, Read)
- ✅ Figma MCP 호출 (선택사항)
- ✅ GitHub API 호출 (gh 명령어, Push 포함)
- ✅ Task/Explore/Plan agent 실행
- ✅ 워크트리 생성/제거
- ✅ 코드 생성 (Write, Edit)
- ✅ Task 도구 사용 (TaskCreate, TaskUpdate)
- ✅ Skill 실행 (code-cleanup)
- ✅ 빌드/테스트 실행 (make project, xcodebuild)
- ✅ SwiftLint 검증 및 자동 수정
- ✅ 컴파일 에러/테스트 실패 자동 수정 (최대 5회)
- ✅ Git 작업 (add, commit, push)
- ✅ AskUserQuestion 사용 (정보 부족 시)

## 사용자 승인 필요

다음 단계에서만 사용자 승인이 필요합니다:

- ⚠️ **EnterPlanMode** (플랜 모드 진입)
- ⚠️ **ExitPlanMode** (플랜 최종 승인)

**참고**: PR 생성은 자동화하지 않고 사용자가 직접 수행합니다.

---

## 에러 처리 전략

### 복구 불가능한 에러 (즉시 종료)

- 테크스펙 파일을 읽을 수 없음
- GitHub 권한 없음
- 필수 정보 부족 (API 스펙, 피처 이름 등)
- 테크스펙 형식이 올바르지 않음

### 복구 가능한 에러 (재시도/우회)

- Figma MCP 미연결: 경고 표시하고 계속 진행
- 일시적인 네트워크 오류: 1회 재시도
- 유사 패턴 없음: 기본 템플릿 사용
- 일부 정보 누락: AskUserQuestion으로 추가 정보 요청

---

## 워크트리 사용 이점

- ✅ 현재 작업 중인 브랜치에 영향 없음
- ✅ 독립적인 환경에서 안전하게 작업
- ✅ 깨끗한 환경에서 시작
- ✅ 문제 발생 시 쉽게 폐기 가능

---

## 코드 품질 보장

### CLAUDE.md 컨벤션 준수

- Import 순서: 표준 → 내부모듈 → 서드파티
- SnapKit 사용 시 leading/trailing 사용
- then 라이브러리 사용 금지
- BaseViewController, BaseViewModel 상속
- ViewModel 구조: Input, Output, Route, Config, Dependency, State
- UICollectionViewCell은 BaseCollectionViewCell 상속

### Skills 활용

- **ios-viewmodel-pattern**: ViewModel 생성 시 참고
- **ios-repository-pattern**: Repository 추가 시 참고
- **ios-viewmodel-test-generator**: 테스트 코드 생성 시 참고

---

## 사용 예시

### 예시 1: 마크다운 파일로 호출

```
/feature-implementer /path/to/TH-XXX-spec.md
```

### 예시 2: 파일 경로 + 피그마 URL

```
/feature-implementer /path/to/spec.md https://figma.com/design/...
```

### 예시 3: 인자 없이 호출 (대화형)

```
/feature-implementer
```

→ 사용자에게 테크스펙 텍스트 또는 파일 경로 입력 요청
→ (선택) 피그마 디자인 URL 입력 요청 (선택사항)

---

## 구현 가능한 피처 유형

### 1. CRUD 화면

- 목록 조회 (페이지네이션)
- 상세 조회
- 생성/수정/삭제

### 2. 복합 화면

- 여러 API를 조합한 화면
- SDU 기반 동적 UI
- 탭 구조, 페이징 구조

### 3. 폼 입력 화면

- 유효성 검증
- 멀티스텝 폼
- 파일 업로드

### 4. 리스트/그리드 화면

- CollectionView 기반
- 검색/필터링
- 정렬

---

## 제한사항

- 너무 복잡하거나 여러 모듈에 걸쳐있으면 수동 개입 필요
- 디자인이 매우 복잡하거나 커스텀 애니메이션이 필요한 경우 수동 작업 권장
- 서버 API가 아직 준비되지 않은 경우 Mock 데이터 사용

---

## 참고 Skills

- **ios-viewmodel-pattern**: ViewModel 구조 패턴
- **ios-repository-pattern**: Repository 패턴
- **ios-viewmodel-test-generator**: 테스트 코드 생성
- **code-cleanup**: 코드 정리 (Phase 3에서 사용)

---

## 참고 파일

- **CLAUDE.md**: 프로젝트 고유 패턴
- `ContributorsViewModel.swift`: ViewModel 예시
- `ContributorsViewController.swift`: ViewController 예시
- `StoreRepository.swift`: Repository 예시
- `StoreApi.swift`: API 예시
