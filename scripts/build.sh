#!/bin/sh
# scripts/build.sh — build dist/flip30-<version>.love on Linux/macOS
#
#   ./scripts/build.sh 1.0.0
set -eu

VERSION="${1:?usage: build.sh <version>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/dist"
OUT="$ROOT/dist/flip30-$VERSION.love"
rm -f "$OUT"

cd "$ROOT"
zip -9 -r "$OUT" \
  conf.lua \
  main.lua \
  LICENSE \
  README.md \
  src \
  rules \
  assets/brand

echo "built $OUT"
