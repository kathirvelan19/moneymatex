#!/bin/bash

set -e

echo "=== Installing Flutter SDK on Vercel ==="

FLUTTER_VERSION="3.27.4"

ROOT_DIR="$(pwd)"

cd /tmp

rm -rf flutter
rm -f flutter.tar.xz

curl -L \
  "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
  -o flutter.tar.xz

tar -xf flutter.tar.xz

export PATH="/tmp/flutter/bin:$PATH"

# Allow git to access /tmp/flutter in Vercel environment
git config --global --add safe.directory '*'

echo "=== Flutter Location ==="
which flutter

echo "=== Flutter Version ==="
flutter --version

echo "=== Getting Dependencies ==="

cd "$ROOT_DIR"

if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
    else
        touch .env
    fi
fi

flutter config --enable-web
flutter config --no-analytics
flutter pub get

echo "=== Building Flutter Web ==="

# SECURITY: GEMINI_API_KEY is intentionally NOT passed to Flutter via --dart-define.
# Gemini API calls are made by the Spring Boot backend on Render.
# The Flutter Web frontend only needs the backend API base URL.
DART_DEFINES=""

if [ -n "$API_BASE_URL" ]; then
    DART_DEFINES="$DART_DEFINES --dart-define=API_BASE_URL=$API_BASE_URL"
fi

flutter build web --release --no-tree-shake-icons $DART_DEFINES

echo "=== Build Completed Successfully ==="