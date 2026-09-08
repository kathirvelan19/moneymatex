#!/bin/bash
set -e

# Disable git dubious ownership checks across all directories in Vercel environment
git config --global --add safe.directory '*'
git config --global --add safe.directory "$(pwd)"

export BOT=true
export CI=true

echo "=== Installing Flutter SDK on Vercel ==="
curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz -o flutter.tar.xz
tar -xf flutter.tar.xz
export PATH="$(pwd)/flutter/bin:$PATH"

# Ensure extracted Flutter SDK directory is marked safe
git config --global --add safe.directory "$(pwd)/flutter"

echo "=== Flutter Version ==="
flutter --version

echo "=== Building Flutter Web App ==="
flutter config --enable-web
flutter config --no-analytics
flutter pub get

if [ -n "$API_BASE_URL" ]; then
  echo "Building with API_BASE_URL=$API_BASE_URL"
  flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL"
else
  echo "Building with default API_BASE_URL"
  flutter build web --release
fi

echo "=== Build Completed Successfully ==="
