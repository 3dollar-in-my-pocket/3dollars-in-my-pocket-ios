#!/bin/sh

#  ci_post_clone.sh
#  3dollar-in-my-pocket
#
#  Created by Hyun Sik Yoo on 2022/12/29.
#  Copyright © 2022 Macgongmon. All rights reserved.

echo "✅ Starting CI post-clone script..."

if ! command -v tuist >/dev/null 2>&1; then
  echo "⚠️ Tuist not found, checking for mise..."

  if ! command -v mise >/dev/null 2>&1; then
    echo "🚀 Installing mise..."
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
  else
    echo "✅ mise already installed!"
  fi

  echo "📦 Installing tuist using mise..."
  mise install
else
  echo "✅ Tuist already installed!"
fi

echo "🛠 Generating project with tuist..."

# 재시도 로직 함수
retry_command() {
  local max_attempts=5
  local delay=10
  local attempt=1
  local command="$@"

  while [ $attempt -le $max_attempts ]; do
    echo "🔄 Attempt $attempt/$max_attempts: $command"

    if eval "$command"; then
      echo "✅ Command succeeded on attempt $attempt"
      return 0
    else
      echo "❌ Command failed on attempt $attempt"

      if [ $attempt -lt $max_attempts ]; then
        echo "⏳ Waiting ${delay}s before retry..."
        sleep $delay
        # 지수 백오프: 다음 시도까지 대기 시간 증가
        delay=$((delay * 2))
      fi

      attempt=$((attempt + 1))
    fi
  done

  echo "💥 Command failed after $max_attempts attempts"
  return 1
}

# tuist install을 재시도 로직으로 실행
retry_command "mise exec tuist -- tuist install"

# tuist generate를 재시도 로직으로 실행
retry_command "mise exec tuist -- tuist generate --no-open --path ../"

echo "✅ CI post-clone script completed!"
