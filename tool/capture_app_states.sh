#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
latest_dir="$repo_dir/tmp/screenshots/latest"
flutter_bin="$(command -v flutter)"
flutter_root="$(cd "$(dirname "$flutter_bin")/.." && pwd)"
font_directory="$flutter_root/bin/cache/artifacts/material_fonts"

mkdir -p "$latest_dir"
find "$latest_dir" -maxdepth 1 -type f -name '*.png' -delete

cd "$repo_dir"
flutter test \
  --dart-define=CAPTURE_SCREENSHOTS=true \
  --dart-define="SCREENSHOT_FONT_DIRECTORY=$font_directory" \
  --update-goldens \
  test/screenshots/app_states_test.dart

printf 'Updated %s screenshot states in %s\n' "$(find "$latest_dir" -type f -name '*.png' | wc -l | tr -d ' ')" "$latest_dir"
