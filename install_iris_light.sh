#!/usr/bin/env bash
# Build IRIS with a light-terminal palette into ~/bin.
#
# Upstream IRIS hardcodes a dark-mode palette in integration/overlay.go and has
# no theme config yet (issue #17; PR #81 in progress). Until that ships, this
# builds a patched binary whose colors match the grayscale light theme used
# across .files (fzf colors, bat GitHub theme). ~/bin precedes /opt/homebrew/bin
# in PATH, so this shadows the brew-installed binary.
#
# To revert to the stock (dark) build: rm ~/bin/iris
# When upstream ships theme support: rm ~/bin/iris, bump brew, delete this
# script and set colors in files/.config/iris/config.toml instead.
set -euo pipefail

IRIS_TAG="v0.4.21"

command -v go >/dev/null 2>&1 || { echo "error: go is required (brew install go)" >&2; exit 1; }

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
SRC_DIR="$WORK_DIR/iris"

git clone --quiet --depth 1 --branch "$IRIS_TAG" https://github.com/versenilvis/IRIS.git "$SRC_DIR"

OVERLAY="$SRC_DIR/integration/overlay.go"

# Dark -> light palette. Roles taken from the Theme struct and the footer mode
# pills in overlay.go. Light values mirror the fzf palette in .zshrc.
# Order matters: #ffffff must be remapped before #110f18 introduces new white.
sed -i '' \
  -e 's/#ffffff/#1a1a1a/g' \
  -e 's/#110f18/#ffffff/g' \
  -e 's/#edecee/#4d4d4c/g' \
  -e 's/#9692a8/#8e908c/g' \
  -e 's/#6d6a7f/#8e908c/g' \
  -e 's/#4B4A4C/#a8a8a8/g' \
  -e 's/#3d375e/#e8e8e8/g' \
  -e 's/#2a2342/#efefef/g' \
  -e 's/#1e1d28/#efefef/g' \
  -e 's/#1a2d36/#efefef/g' \
  -e 's/#61ffca/#333333/g' \
  -e 's/#a277ff/#555555/g' \
  -e 's/Border:     lipgloss.Color("#555555")/Border:     lipgloss.Color("#d6d6d6")/' \
  "$OVERLAY"

# Fail loudly if upstream moved/renamed colors and the patch no longer covers them
if grep -qE '#(a277ff|61ffca|110f18|edecee|3d375e|2a2342|1e1d28|1a2d36)' "$OVERLAY"; then
  echo "error: dark palette colors remain after patch — upstream changed, update this script" >&2
  exit 1
fi

mkdir -p "$HOME/bin"
(cd "$SRC_DIR" && go build \
  -ldflags="-X github.com/versenilvis/iris/root.Version=${IRIS_TAG}-light" \
  -o "$HOME/bin/iris" ./cmd/iris)

echo "installed: $HOME/bin/iris ($("$HOME/bin/iris" version))"
