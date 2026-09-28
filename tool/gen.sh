#!/usr/bin/env bash
# Runs build_runner for a workspace package, serialized with a lock so
# several processes can call it at the same time.
#
# Usage: tool/gen.sh [upcloud|upcloud_flutter]   (default: upcloud)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG="${1:-upcloud}"
LOCK="$ROOT/.dart_tool/gen-$PKG.lock"
mkdir -p "$ROOT/.dart_tool"
until mkdir "$LOCK" 2>/dev/null; do sleep 2; done
trap 'rmdir "$LOCK"' EXIT
cd "$ROOT/packages/$PKG"
dart run build_runner build --delete-conflicting-outputs 2>&1 | tail -15
