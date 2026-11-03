#!/usr/bin/env bash
# Storage regressions with atomic in-memory SecItem operations and isolated Defaults.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/pb-crossapp-storage.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT

SOURCES=()
for SOURCE in "$ROOT_DIR"/Sources/Implementation/*.m; do
  # UIKit device collection is replaced by a deterministic fixture in this test.
  if [[ "$SOURCE" != */PBCrossDeviceAttributeCollector.m ]]; then
    SOURCES+=("$SOURCE")
  fi
done

xcrun clang \
  -fobjc-arc -fmodules -Wall -Wextra -Wno-unused-parameter \
  -framework Foundation -framework Security \
  -I "$ROOT_DIR/Sources" \
  -I "$ROOT_DIR/Sources/Public" \
  -I "$ROOT_DIR/Sources/Private" \
  "${SOURCES[@]}" "$ROOT_DIR/Tests/PBCrossStorageVerification.m" \
  -o "$BUILD_DIR/verify_storage"

"$BUILD_DIR/verify_storage"
