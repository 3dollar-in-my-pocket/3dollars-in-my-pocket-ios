#!/bin/sh

#  ci_post_clone.sh
#  3dollar-in-my-pocket
#
#  Created by Hyun Sik Yoo on 2022/12/29.
#  Copyright © 2022 Macgongmon. All rights reserved.

set -e

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
mise exec tuist -- tuist install
mise exec tuist -- tuist generate --no-open --path ../

echo "✅ CI post-clone script completed!"
