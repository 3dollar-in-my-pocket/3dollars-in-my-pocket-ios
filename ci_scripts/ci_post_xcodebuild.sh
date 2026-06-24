#!/bin/sh

#  ci_post_xcodebuild.sh
#  3dollar-in-my-pocket
#
#  Xcode Cloud가 빌드/아카이브 직후 실행하는 스크립트.
#  archive 액션(= TestFlight 업로드) 시 Discord 웹훅으로 배포 정보를 전송한다.

echo "✅ Starting CI post-xcodebuild script..."

# 1) archive 액션일 때만 실행 (test/build 등 다른 액션은 스킵)
if [ "$CI_XCODEBUILD_ACTION" != "archive" ]; then
  echo "ℹ️ Not an archive action (action=$CI_XCODEBUILD_ACTION). Skip Discord notify."
  exit 0
fi

# 2) 웹훅 URL이 없으면 스킵 (시크릿 미설정이어도 빌드는 깨지 않는다)
if [ -z "$DISCORD_WEBHOOK_URL" ]; then
  echo "⚠️ DISCORD_WEBHOOK_URL is not set. Skip Discord notify."
  exit 0
fi

# 3) 버전 / 빌드번호 추출
#    - 버전(마케팅 버전)은 아카이브 Info.plist에서 읽는다.
#    - 빌드번호는 CI_BUILD_NUMBER를 쓴다. 프로젝트의 CURRENT_PROJECT_VERSION이
#      "1"로 고정(DefaultSetting.swift)이라 아카이브의 CFBundleVersion은 항상 1이고,
#      TestFlight에 실제로 올라가는 번호는 Xcode Cloud가 매기는 CI_BUILD_NUMBER다.
ARCHIVE_PLIST="$CI_ARCHIVE_PATH/Info.plist"
VERSION="$(/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleShortVersionString" "$ARCHIVE_PLIST" 2>/dev/null)"
[ -z "$VERSION" ] && VERSION="-"
BUILD="$CI_BUILD_NUMBER"
[ -z "$BUILD" ] && BUILD="-"

# 4) 브랜치(또는 태그) / 마지막 커밋 메시지 / 짧은 SHA
BRANCH="${CI_BRANCH:-${CI_TAG:--}}"
COMMIT_MSG="$(git -C "$CI_PRIMARY_REPOSITORY_PATH" log -1 --pretty=%B 2>/dev/null)"
SHORT_SHA="$(printf '%s' "$CI_COMMIT" | cut -c1-7)"

echo "📦 version=$VERSION build=$BUILD branch=$BRANCH commit=$SHORT_SHA"

# 5) python3로 JSON 페이로드 안전하게 생성 (따옴표/줄바꿈/특수문자 이스케이프 처리)
payload="$(VERSION="$VERSION" BUILD="$BUILD" BRANCH="$BRANCH" \
  WORKFLOW="$CI_WORKFLOW" SHORT_SHA="$SHORT_SHA" COMMIT_MSG="$COMMIT_MSG" \
  python3 - <<'PY'
import os, json

version  = os.environ.get("VERSION") or "-"
build    = os.environ.get("BUILD") or "-"
branch   = os.environ.get("BRANCH") or "-"
workflow = os.environ.get("WORKFLOW") or "-"
sha      = os.environ.get("SHORT_SHA") or "-"
# Discord embed description는 4096자 제한이라 넉넉히 자른다
msg      = (os.environ.get("COMMIT_MSG") or "").strip()[:1500] or "-"

payload = {
    "username": "Xcode Cloud",
    "embeds": [{
        "title": "🧪 [iOS] TestFlight 빌드 업로드",
        "color": 5814783,
        "fields": [
            {"name": "버전",       "value": f"{version} ({build})", "inline": True},
            {"name": "브랜치",     "value": branch,                 "inline": True},
            {"name": "워크플로우", "value": workflow,               "inline": True},
        ],
        "description": f"**커밋** `{sha}`\n```\n{msg}\n```",
    }],
}
print(json.dumps(payload))
PY
)"

# 6) Discord로 전송 (-f: HTTP 4xx/5xx면 실패로 처리해 로그에서 누락 감지)
if curl -sf -X POST "$DISCORD_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$payload"; then
  echo "✅ Discord notify sent."
else
  echo "❌ Discord notify failed."
fi

# 알림 실패가 빌드 전체를 깨뜨리지 않도록 항상 0으로 종료
exit 0
