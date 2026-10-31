#!/bin/sh
# 환경별 빌드 설정(App/Config/Environment-*.xcconfig)을 묶거나 복원한다.
#   pack         로컬 설정 파일을 base64 한 줄로 출력 (CI 변수 APP_CONFIG_ARCHIVE 값)
#   unpack       APP_CONFIG_ARCHIVE 를 풀어 설정 파일을 만든다 (Xcode Cloud ci_post_clone)
#   placeholder  유닛 테스트용 기본값으로 설정 파일을 만든다 (GitHub Actions)
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_DIR="$ROOT/App/Config"
FILES="Environment-Debug.xcconfig Environment-Release.xcconfig"

write_placeholder() {
  cat > "$CONFIG_DIR/$1" <<CONFIG
API_URL = https:/\$()/localhost
UNIVERSIAL_LINK_HOST = https:/\$()/localhost
KAKAO_APP_KEY = placeholder
KAKAO_REST_API_KEY = placeholder
NCP_CLIENT_ID = placeholder
NCP_CLIENT_SECRET = placeholder
ADMOB_APP_ID = ca-app-pub-3940256099942544~1458002511
ADMOB_UNIT_ID_POLL_DETAIL = ca-app-pub-3940256099942544/2435281174
ADMOB_UNIT_ID_HOME_LIST = ca-app-pub-3940256099942544/2435281174
ADMOB_UNIT_ID_HOME_LIST_CARD = ca-app-pub-3940256099942544/2435281174
ADMOB_UNIT_ID_HOME_CARD = ca-app-pub-3940256099942544/2435281174
ADMOB_UNIT_ID_COMMUNITY = ca-app-pub-3940256099942544/2435281174
ADMOB_UNIT_ID_CATEGORY_FILTER = ca-app-pub-3940256099942544/2435281174
ADMOB_UNIT_ID_STORE_DETAIL = ca-app-pub-3940256099942544/2435281174
ADMOB_UNIT_ID_FRONT_BANNER = ca-app-pub-3940256099942544/4411468910
ADMOB_UNIT_ID_SEARCH_ADDRESS = ca-app-pub-3940256099942544/2435281174
ADMOB_UNIT_ID_POLL_LIST_ITEM = ca-app-pub-3940256099942544/2435281174
ADMOB_UNIT_ID_LOCAL_NEWS_FEED = ca-app-pub-3940256099942544/2435281174
CONFIG
}

mkdir -p "$CONFIG_DIR"

case "$1" in
  pack)
    (cd "$CONFIG_DIR" && COPYFILE_DISABLE=1 tar -cf - $FILES | gzip -9) | base64 | tr -d '\n'
    echo
    ;;
  unpack)
    if [ -z "$APP_CONFIG_ARCHIVE" ]; then
      echo "❌ APP_CONFIG_ARCHIVE is not set" >&2
      exit 1
    fi
    printf '%s' "$APP_CONFIG_ARCHIVE" | base64 --decode | tar -xzf - -C "$CONFIG_DIR"
    echo "✅ app config restored"
    ;;
  placeholder)
    for file in $FILES; do
      write_placeholder "$file"
    done
    echo "✅ placeholder app config written"
    ;;
  *)
    echo "usage: $0 pack|unpack|placeholder" >&2
    exit 1
    ;;
esac
