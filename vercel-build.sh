#!/bin/bash

set -e

echo "=== Installing Flutter SDK on Vercel ==="

# Flutter version required by the project
FLUTTER_VERSION="3.47.2"
FLUTTER_DIR="$(pwd)/flutter"

# Fix Git dubious ownership
git config --global --add safe.directory "*"
git config --global --add safe.directory "$(pwd)"

export BOT=true
export CI=true

echo "=== Downloading Flutter ${FLUTTER_VERSION} ==="

git clone \
  --depth 1 \
  --branch ${FLUTTER_VERSION} \
  https://github.com/flutter/flutter.git \
  "$FLUTTER_DIR"

# Mark Flutter SDK as trusted
git config --global --add safe.directory "$FLUTTER_DIR"

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "=== Flutter Version ==="
flutter --version

echo "=== Enabling Flutter Web ==="
flutter config --enable-web
flutter config --no-analytics

echo "=== Installing Dependencies ==="
flutter pub get

echo "=== Building Flutter Web App ==="

if [ -n "$API_BASE_URL" ]; then
  echo "Building with API_BASE_URL=$API_BASE_URL"

  flutter build web \
    --release \
    --dart-define=API_BASE_URL="$API_BASE_URL"
else
  echo "Building with default API_BASE_URL"

  flutter build web --release
fi

echo "=== Build Completed Successfully ==="