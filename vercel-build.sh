#!/bin/bash

set -e

echo "=== Installing Flutter SDK on Vercel ==="

FLUTTER_VERSION="3.47.2"

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

flutter config --enable-web
flutter config --no-analytics
flutter pub get

echo "=== Building Flutter Web ==="

if [ -n "$API_BASE_URL" ]; then
    flutter build web --release \
      --dart-define=API_BASE_URL="$API_BASE_URL"
else
    flutter build web --release
fi

echo "=== Build Completed Successfully ==="