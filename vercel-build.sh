#!/bin/bash
set -e

# Mark git directories as safe for Vercel root container context
git config --global --add safe.directory '*'

echo "=== Installing Flutter SDK on Vercel ==="
curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz -o flutter.tar.xz
tar -xf flutter.tar.xz
export PATH="$PATH:$(pwd)/flutter/bin"

# Add downloaded Flutter folder to git safe directory
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
