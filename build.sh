#!/bin/bash
set -e

echo "=== Setting up Flutter SDK ==="
if [ ! -d "_flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter
fi

export PATH="$PATH:$(pwd)/_flutter/bin"

echo "=== Flutter Environment ==="
flutter --version

echo "=== Building Flutter Web Release ==="
flutter build web --release

echo "=== Build Complete ==="
