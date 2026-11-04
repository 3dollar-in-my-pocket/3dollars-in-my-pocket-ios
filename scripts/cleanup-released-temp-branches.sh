#!/bin/sh
# 릴리즈에 작업이 모두 들어간 개발 배포용 temp 브랜치를 원격에서 지운다 (docs/process/pr-process.md "릴리즈 마무리")
#
#   temp/* 브랜치마다 병합 커밋을 뺀 커밋 중 릴리즈 태그에 없는 것이 하나라도 있으면 남기고, 없으면 지운다.
#   temp 전용 커밋(버전 올림 등)이 있는 브랜치는 릴리즈에 포함될 수 없어서 남는다 — 손으로 지운다.
#
# 사용: scripts/cleanup-released-temp-branches.sh <릴리즈 태그> [--dry-run]
#   CI(.github/workflows/cleanup-temp-branches.yml)가 릴리즈 공개 때 호출한다. 로컬 확인은 --dry-run.

set -eu

TAG="${1:-}"
DRY_RUN="${2:-}"
if [ -z "$TAG" ]; then
  echo "사용: $0 <릴리즈 태그> [--dry-run]" >&2
  exit 2
fi

git fetch --quiet --prune origin '+refs/heads/temp/*:refs/remotes/origin/temp/*' "+refs/tags/$TAG:refs/tags/$TAG"

deleted=0
kept=0
for ref in $(git for-each-ref --format='%(refname:strip=2)' refs/remotes/origin/temp/); do
  branch="${ref#origin/}"
  pending="$(git rev-list --no-merges --count "$TAG..$ref")"
  if [ "$pending" -eq 0 ]; then
    if [ "$DRY_RUN" = "--dry-run" ]; then
      echo "삭제 예정: $branch"
    else
      git push --quiet origin --delete "$branch"
      echo "삭제: $branch"
    fi
    deleted=$((deleted + 1))
  else
    echo "유지: $branch ($TAG 에 없는 커밋 $pending개)"
    kept=$((kept + 1))
  fi
done

echo "삭제 $deleted개 · 유지 $kept개 (기준 $TAG)"
