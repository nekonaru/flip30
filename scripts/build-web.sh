#!/bin/sh
# Build a web bundle with love.js. Requires Node.js and the love.js npm package.
# Usage: ./scripts/build-web.sh 2.0.0 /path/to/love.js
set -eu

VERSION="${1:?usage: build-web.sh <version> <lovejs-dir>}"
LOVEJS="${2:?usage: build-web.sh <version> <lovejs-dir>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/dist/web-$VERSION"
mkdir -p "$OUT"
cp -r "$LOVEJS"/. "$OUT"/
(cd "$ROOT" && zip -q -9 -r "$OUT/game.love" conf.lua main.lua LICENSE README.md README.id.md src rules assets/brand)
printf 'Flip30 %s web build in %s\n' "$VERSION" "$OUT"
