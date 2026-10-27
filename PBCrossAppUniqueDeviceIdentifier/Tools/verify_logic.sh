#!/usr/bin/env bash
#
# 纯逻辑自检：指纹测试向量、匹配器、广告适配器、JSON 往返。
# 只编译不依赖 UIKit 的 Foundation 源码，因此可在 macOS 上直接运行。
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/pb-crossapp-logic.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT

SOURCES=(
  "$ROOT_DIR/Sources/Implementation/PBCrossDeviceAttributes.m"
  "$ROOT_DIR/Sources/Implementation/PBCrossConfiguration.m"
  "$ROOT_DIR/Sources/Implementation/PBCrossErrors.m"
  "$ROOT_DIR/Sources/Implementation/PBCrossCrypto.m"
  "$ROOT_DIR/Sources/Implementation/PBCrossIdentifier.m"
  "$ROOT_DIR/Sources/Implementation/PBCrossIdentity.m"
  "$ROOT_DIR/Sources/Implementation/PBCrossIdentityGenerator.m"
  "$ROOT_DIR/Sources/Implementation/PBCrossIdentityMatcher.m"
  "$ROOT_DIR/Sources/Implementation/PBCrossAdRequestAdapter.m"
  "$ROOT_DIR/Tests/PBCrossLogicVerification.m"
)

xcrun clang \
  -fobjc-arc -fmodules -Wall -Wextra -Wno-unused-parameter \
  -framework Foundation \
  -I "$ROOT_DIR/Sources" \
  -I "$ROOT_DIR/Sources/Public" \
  -I "$ROOT_DIR/Sources/Private" \
  "${SOURCES[@]}" \
  -o "$BUILD_DIR/verify_logic"

"$BUILD_DIR/verify_logic"
