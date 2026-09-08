#!/bin/bash
set -e

echo "=== Installing Flutter SDK on Vercel ==="
curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz -o flutter.tar.xz
tar -xf flutter.tar.xz
export PATH="$PATH:$(pwd)/flutter/bin"

echo "=== Flutter Version ==="
flutter --version

echo "=== Building Flutter Web App ==="
flutter config --enable-web
flutter pub get

if [ -n "$API_BASE_URL" ]; then
  echo "Building with API_BASE_URL=$API_BASE_URL"
  flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL"
else
  echo "Building with default API_BASE_URL"
  flutter build web --release
fi

echo "=== Build Completed Successfully ==="
