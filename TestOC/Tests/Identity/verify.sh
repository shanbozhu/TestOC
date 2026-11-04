#!/usr/bin/env bash
# No real device identities, Keychain records, or App Defaults are accessed.
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$TEST_DIR/../../Page/Mine/PBUniqueDeviceIdentifier"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/pb-identity-tests.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT

xcrun clang -fobjc-arc -fmodules -Wall -Wextra -Wno-unused-parameter \
  -framework Foundation -framework Security \
  -I "$TEST_DIR/Stubs" -I "$MODULE_DIR" \
  "$MODULE_DIR/PBDeviceIdentityManager.m" "$TEST_DIR/PBIdentityVerification.m" \
  -o "$BUILD_DIR/verify"
"$BUILD_DIR/verify"

COMPARISON_DIR="$TEST_DIR/../../Page/Mine/PBUniqueIdentifier"
xcrun clang -fobjc-arc -fmodules -Wall -Wextra -Wno-unused-parameter -fsanitize=address -g \
  -framework Foundation -framework Security \
  -I "$TEST_DIR/Stubs" -I "$COMPARISON_DIR" -I "$MODULE_DIR" \
  "$MODULE_DIR/PBDeviceIdentityStorage.m" \
  "$COMPARISON_DIR/PBUniqueIdentifierHelper.m" "$COMPARISON_DIR/PBUniqueIdentifierItem.m" \
  "$TEST_DIR/PBComparisonVerification.m" -o "$BUILD_DIR/verify_comparison"
"$BUILD_DIR/verify_comparison"
