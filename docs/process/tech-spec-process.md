# 테크 스펙(의도 문서) 프로세스

PR 리뷰의 기준은 diff가 아니라 **의도 문서**다. 태스크를 시작할 때 지라 티켓에서 테크 스펙을 생성하고,
요약·테스트 케이스(TC)를 먼저 적는다. 이후 단계(테스트 케이스 도출, PR 본문 생성, 드리프트 분석)는 모두 이 문서를 기준으로 동작한다.

## 구조

```
Jira 티켓 (TH-xxxx)
  └─ 커스텀 필드 `테크스펙` (URL)  ──▶  Notion "테크 스펙" DB의 페이지
                                          └─ 프로퍼티 `티켓` : 지라 티켓 링크 (여러 개 가능, iOS/AOS 공유)
```

- 노션 DB: https://app.notion.com/p/3e07ad52990e8043a7aace08d1b9879d
- 템플릿 페이지: https://app.notion.com/p/3e07ad52990e816985dffa6ffcf761b8
- 연결의 **단일 진실 소스는 지라의 `테크스펙` 필드**다. 자동 생성이든 수동 붙여넣기든 여기에만 URL이 있으면 된다.

## 문서 템플릿

| 섹션 | 내용 |
|---|---|
| 1. 요약 | 배경 · 목표(있으면) · 디자인 가이드(피그마 링크) |
| 2. 요구사항 | 이 티켓을 처리하기 위한 요구사항 |
| 3. 테스트 케이스 (TC) | 사용자 관점의 케이스를 한 줄씩. `TC-1`, `TC-2`… **ID는 바꾸지 않는다.** 테스트 코드가 `test_{티켓}_TC{n}_…` 으로 이 번호를 그대로 쓴다 (`docs/process/testing.md`). 구현하다 케이스가 늘면 코드에 임의 번호를 만들지 말고 **여기에 TC를 먼저 추가**한다 |
| 기타 | 범위 밖, 참고 링크, 열린 질문 |

## 생성 방법

### A. 지라에서 버튼으로 (기본)

1. 티켓 화면 우측 상단 **Actions(⋯) → "테크스펙 생성"** 클릭
2. 몇 초 뒤 `테크스펙` 필드에 노션 URL이 채워지고 코멘트가 달린다
3. 노션에서 요약·TC를 작성한다

이미 `테크스펙` 필드가 채워져 있으면 룰은 아무것도 하지 않는다 (중복 생성 방지).

### B. 수동 연결

이미 스펙이 있는 경우(예: iOS 티켓에서 만든 스펙을 AOS 티켓에도 연결):

1. 지라 티켓 `테크스펙` 필드에 노션 URL 붙여넣기
2. 노션 페이지 `티켓` 프로퍼티에 지라 티켓 링크 추가 (역방향)

---

## 지라 설정 가이드 (최초 1회)

### 1. 노션 integration 만들기

1. https://www.notion.so/profile/integrations → **New integration**
   - 이름: `Jira 테크스펙 자동화`, 워크스페이스: 가슴속 3천원, Type: Internal
   - Capabilities: Insert content, Update content, Read content
2. 발급된 **Internal Integration Secret**(`ntn_...`) 복사
3. 노션 "테크 스펙" 페이지 → 우측 상단 `⋯` → **Connections** → 위 integration 연결
   (상위 페이지에 연결하면 하위 DB까지 권한이 내려간다)

### 2. 지라 커스텀 필드

Project settings → Fields (또는 Jira settings → Issues → Custom fields)

- 이름: `테크스펙`
- 타입: **URL Field**
- Task / Story / Bug 화면(Create·View)에 노출

### 3. Automation 룰

Project settings → Automation → **Create rule**

| 순서 | 블록 | 설정 |
|---|---|---|
| 1 | Trigger: **Manual trigger** | 이름 `테크스펙 생성`. "Groups who can trigger": 전체 |
| 2 | Condition: **Issue fields condition** | Field `테크스펙` · Condition **is empty** |
| 3 | Action: **Send web request** | 아래 참고 |
| 4 | Action: **Edit issue** | Field `테크스펙` = `{{webResponse.body.url}}` |
| 5 | Action: **Comment on issue** | `테크스펙 문서가 생성됐어요: {{webResponse.body.url}}` |

**Send web request 설정**

- Web request URL: `https://api.notion.com/v1/pages`
- HTTP method: `POST`
- Headers:
  - `Authorization`: `Bearer ntn_xxxxxxxx` (1단계 시크릿) — 값은 **Hidden** 체크
  - `Notion-Version`: `2022-06-28`
  - `Content-Type`: `application/json`
- Web request body: **Custom data**
- ✅ **Delay execution of subsequent rule actions until we've received a response for this web request** 반드시 체크

Custom data에 아래 JSON을 그대로 붙여넣는다. 제목은 `[iOS/유저앱] ` 같은 접두 태그를 떼고 들어가고,
`티켓` 프로퍼티에는 지라 링크가 들어간다.

```json
{
  "parent": { "database_id": "3e07ad52990e8043a7aace08d1b9879d" },
  "icon": { "type": "emoji", "emoji": "📄" },
  "properties": {
    "이름": {
      "title": [
        { "text": { "content": "{{issue.summary.replaceAll("^\\[[^\\]]*\\]\\s*","").jsonEncode}}" } }
      ]
    },
    "티켓": {
      "rich_text": [
        { "text": { "content": "{{issue.key}}", "link": { "url": "{{issue.url}}" } } }
      ]
    }
  },
  "children": [
    {
      "object": "block", "type": "callout",
      "callout": {
        "icon": { "type": "emoji", "emoji": "💡" },
        "rich_text": [
          { "text": { "content": "이 문서는 " } },
          { "text": { "content": "의도 문서" }, "annotations": { "bold": true } },
          { "text": { "content": "야. 구현(diff)이 아니라 여기 적힌 요약·TC를 기준으로 테스트 케이스가 도출되고, PR 본문이 자동으로 채워져. 티켓 여러 개(iOS/AOS)가 같은 스펙을 공유하면 티켓 프로퍼티에 링크를 전부 걸어줘." } }
        ]
      }
    },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [ { "text": { "content": "요약" } } ] } },
    { "object": "block", "type": "paragraph", "paragraph": { "rich_text": [ { "text": { "content": "뭘, 왜 하는지 2~3줄. (문제 → 기대 효과)" } } ] } },
    { "object": "block", "type": "bulleted_list_item", "bulleted_list_item": { "rich_text": [ { "text": { "content": "배경: " } } ] } },
    { "object": "block", "type": "bulleted_list_item", "bulleted_list_item": { "rich_text": [ { "text": { "content": "목표: " } } ] } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [ { "text": { "content": "테스트 케이스 (TC)" } } ] } },
    { "object": "block", "type": "paragraph", "paragraph": { "rich_text": [ { "text": { "content": "사용자 관점에서 \"이게 되면 완료\"인 조건을 한 줄씩. ID는 바꾸지 말고 유지해줘 — 테스트 코드 메서드명이 test_TH1234_TC1_… 처럼 이 번호를 그대로 쓰고, PR 본문 커버리지 표도 이 ID로 묶여. 구현하다 케이스가 늘면 코드에 새 번호를 만들지 말고 여기에 TC를 추가해." } } ] } },
    { "object": "block", "type": "to_do", "to_do": { "checked": false, "rich_text": [ { "text": { "content": "TC-1" }, "annotations": { "bold": true } }, { "text": { "content": " — Given … / When … / Then …" } } ] } },
    { "object": "block", "type": "to_do", "to_do": { "checked": false, "rich_text": [ { "text": { "content": "TC-2" }, "annotations": { "bold": true } }, { "text": { "content": " — " } } ] } },
    { "object": "block", "type": "to_do", "to_do": { "checked": false, "rich_text": [ { "text": { "content": "TC-3" }, "annotations": { "bold": true } }, { "text": { "content": " — " } } ] } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [ { "text": { "content": "기타" } } ] } },
    { "object": "block", "type": "paragraph", "paragraph": { "rich_text": [ { "text": { "content": "범위 밖, 참고 링크(피그마·API·디스코드 논의), 열린 질문 등 자유롭게." } } ] } },
    { "object": "block", "type": "bulleted_list_item", "bulleted_list_item": { "rich_text": [ { "text": { "content": "" } } ] } }
  ]
}
```

### 4. 검증

1. 테스트용 티켓 하나 열고 Actions → 테크스펙 생성
2. Automation → Audit log에서 web request 응답 코드 200 확인
   - `400 validation_error`: 프로퍼티 이름(`이름`/`티켓`)이 노션 DB와 다르거나 JSON 깨짐
   - `404 object_not_found`: integration이 DB에 연결 안 됨 (1-3단계)
   - `401`: 시크릿 오타
3. 티켓 `테크스펙` 필드에 URL이 들어갔는지, 노션에 페이지가 템플릿대로 생겼는지 확인

### 참고: 플랜별 자동화 한도

Jira Free는 월 100회 실행 제한. 티켓당 1회라 충분하지만, 초과하면 그 달은 수동 연결(B)로 대체.
