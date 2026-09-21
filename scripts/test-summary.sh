#!/bin/sh
# xcresult 번들을 PR용 마크다운 요약으로 변환한다.
#   사용: scripts/test-summary.sh <path.xcresult>  > summary.md
# 출력: 전체 결과 / 실패 목록 / TC 커버리지 표(test_TC{n}_ 접두 메서드 → 테스트 클래스별 TC 번호 집계)
# TC 번호는 테스트 파일(클래스) 안에서만 유일하므로 항상 `클래스 - TC{n}` 으로 묶어서 보여준다.
# docs/process/testing.md 의 "PR에 남기는 것" 형식과 맞춘다.

set -eu
BUNDLE="${1:?xcresult 경로가 필요합니다}"

xcrun xcresulttool get test-results summary --path "$BUNDLE" > /tmp/xc-summary.json
xcrun xcresulttool get test-results tests   --path "$BUNDLE" > /tmp/xc-tests.json

python3 - <<'PY'
import json, re, collections

summary = json.load(open("/tmp/xc-summary.json"))
tests = json.load(open("/tmp/xc-tests.json"))

cases = []  # (suite, name, result)
def walk(node, suite=None):
    t = node.get("nodeType")
    if t == "Test Suite":
        suite = node.get("name")
    if t == "Test Case":
        cases.append((suite, node.get("name", "").rstrip("()"), node.get("result")))
    for c in node.get("children", []):
        walk(c, suite)
for n in tests.get("testNodes", []):
    walk(n)

passed, failed, skipped = summary.get("passedTests", 0), summary.get("failedTests", 0), summary.get("skippedTests", 0)
device = ""
for d in summary.get("devicesAndConfigurations", []):
    dev = d.get("device", {})
    device = f'{dev.get("deviceName","")} · iOS {dev.get("osVersion","")}'
    break
icon = "✅" if failed == 0 and summary.get("result") == "Passed" else "❌"

print(f"### {icon} 테스트 결과: {passed} passed / {failed} failed / {skipped} skipped")
print(f"_{device} · {summary.get('environmentDescription','')}_")
print()

fails = [c for c in cases if c[2] != "Passed"]
if fails:
    print("**실패한 테스트**")
    for suite, name, result in fails:
        print(f"- `{suite}.{name}` — {result}")
    print()

# TC 커버리지: test_TC{n}_ 접두. TC 번호는 클래스 안에서만 유일하다.
by_tc = collections.defaultdict(list)
for suite, name, result in cases:
    m = re.match(r"test_TC(\d+)_", name)
    if m:
        by_tc[(suite or "", int(m.group(1)))].append((name, result))

if by_tc:
    print("**TC 커버리지** (메서드명 `test_TC{n}_` 기준, TC 번호는 테스트 클래스 단위)")
    print()
    print("| 테스트 클래스 | TC | 테스트 | 결과 |")
    print("|---|---|---|---|")
    prev_suite = None
    for suite, tc in sorted(by_tc):
        for name, result in by_tc[(suite, tc)]:
            mark = "✅" if result == "Passed" else "❌"
            shown = suite if suite != prev_suite else ""
            print(f"| {shown} | TC{tc} | `{name}` | {mark} |")
            prev_suite = suite
    print()
else:
    print("_TC 접두(`test_TC{n}_`)가 붙은 테스트가 없습니다. 이 PR에 테크스펙 TC가 있다면 `/3dollars:test-cases`로 테스트를 도출하세요._")
    print()

print("<details><summary>전체 테스트 목록</summary>")
print()
cur = None
for suite, name, result in cases:
    if suite != cur:
        cur = suite
        print(f"- **{suite}**")
    mark = "✅" if result == "Passed" else "❌"
    print(f"  - {mark} `{name}`")
print()
print("</details>")
PY
