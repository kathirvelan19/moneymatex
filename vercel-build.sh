#!/bin/bash
set -e

# Fix Git dubious ownership for Vercel build container
git config --global --add safe.directory "*"
git config --global --add safe.directory "$(pwd)"

echo "=== Installing Flutter SDK on Vercel ==="

FLUTTER_VERSION="3.24.3"
FLUTTER_DIR="$(pwd)/flutter"

# Download Flutter SDK
curl -L \
  "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
  -o flutter.tar.xz

# Extract
tar -xf flutter.tar.xz

# Mark extracted directory as safe
git config --global --add safe.directory "$FLUTTER_DIR"

# Add Flutter to PATH
export PATH="$FLUTTER_DIR/bin:$PATH"

echo "=== Flutter Version ==="
flutter --version

echo "=== Enabling Flutter Web ==="
flutter config --enable-web
flutter config --no-analytics

echo "=== Getting Dependencies ==="
flutter pub get

echo "=== Building Flutter Web ==="

if [ -n "$API_BASE_URL" ]; then
    echo "Using API_BASE_URL=$API_BASE_URL"

    flutter build web \
        --release \
        --dart-define=API_BASE_URL="$API_BASE_URL"
else
    echo "Using default API_BASE_URL"

    flutter build web --release
fi

echo "=== Build Completed Successfully ==="