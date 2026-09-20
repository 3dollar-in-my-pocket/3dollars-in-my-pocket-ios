#!/bin/sh
# 모듈 의존성 규칙 검사 (docs/architecture/RULES.md R1·R2)
#
#   R1: Modules/Core/*/Project.swift 는 .Feature.* / .Interface.*Interface(Feature 인터페이스)를 의존하지 않는다.
#       예외: .Interface.appInterface — App 이 하위 계층에 노출하는 계약(RULES.md R1 예외)
#   R2: Modules/Feature/*/Project.swift 는 .Feature.* (다른 Feature 구현체)를 의존하지 않는다.
#
# 베이스라인: scripts/module-deps-baseline.txt ("From -> To" 한 줄씩). 여기 있는 조합은 통과.
# 사용: scripts/check-module-deps.sh   (레포 루트에서, make lint 가 호출). 새 위반이 있으면 exit 1.

set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASELINE="$ROOT/scripts/module-deps-baseline.txt"
OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT

# ".Feature.myPage" 토큰 → 디렉터리명 "MyPage"
to_module_name() {
  case "$1" in
    sdu) printf 'SDU' ;;
    *) printf '%s' "$1" | awk '{ print toupper(substr($0,1,1)) substr($0,2) }' ;;
  esac
}

in_baseline() {  # $1=From $2=To
  grep -v '^#' "$BASELINE" | grep -qx "$1 -> $2"
}

# $1=rule $2=proj-file $3=token-pattern(ERE) $4=exclude-token
scan() {
  rule="$1"; proj="$2"; pattern="$3"; exclude="$4"
  from="$(basename "$(dirname "$proj")")"
  # 줄 단위가 아니라 토큰 단위로 뽑는다 (한 줄에 여러 의존성이 있어도 놓치지 않게)
  grep -nEo "$pattern" "$proj" > "$OUT.lines" || true
  while IFS=: read -r line token; do
    [ "$token" = "$exclude" ] && continue
    name="$(printf '%s' "$token" | sed -E 's/^\.(Feature|Interface)\.//')"
    to="$(to_module_name "${name%Interface}")"
    if in_baseline "$from" "$to"; then
      echo "  (baseline) $from -> $to" >> "$OUT"
    else
      echo "❌ [$rule] $from -> $to  (${proj#$ROOT/}:$line)" >> "$OUT"
    fi
  done < "$OUT.lines"
  rm -f "$OUT.lines"
}

echo "▶ R1: Core 모듈 → Feature / Feature-Interface 의존 검사"
for proj in "$ROOT"/Modules/Core/*/Project.swift; do
  scan R1 "$proj" '\.(Feature|Interface)\.[A-Za-z]+' '.Interface.appInterface'
done

echo "▶ R2: Feature 모듈 → 다른 Feature 구현체 의존 검사"
for proj in "$ROOT"/Modules/Feature/*/Project.swift; do
  scan R2 "$proj" '\.Feature\.[A-Za-z]+' ''
done

cat "$OUT"
if grep -q '^❌' "$OUT"; then
  n="$(grep -c '^❌' "$OUT")"
  echo "✖ 모듈 의존성 규칙 위반 $n건. RULES.md R1·R2 참고. 정당한 예외면 scripts/module-deps-baseline.txt 에 사유와 함께 추가."
  exit 1
fi
echo "✔ 모듈 의존성 규칙 통과 (베이스라인 $(grep -c '(baseline)' "$OUT" || true)건 제외)"
