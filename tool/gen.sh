#!/usr/bin/env bash
# Runs build_runner (freezed/json_serializable), serialized with a lock so
# several processes can call it at the same time.
#
# Usage: tool/gen.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOCK="$ROOT/.dart_tool/gen.lock"
mkdir -p "$ROOT/.dart_tool"
until mkdir "$LOCK" 2>/dev/null; do sleep 2; done
trap 'rmdir "$LOCK"' EXIT
cd "$ROOT"
dart run build_runner build --delete-conflicting-outputs 2>&1 | tail -15
