#!/usr/bin/env bash
#
# Build the Rust dynamic module for the Emacs 32 canvas API.
#
# Why a module at all: native-compiled Lisp is fine for integer pixel work
# (400x240 plasma at ~220 fps), but the moment real per-pixel mathematics
# appears the floats are heap-allocated and GC dominates -- a byte-compiled
# Mandelbrot measured 1538 ms/frame and 896 collections in five frames,
# against 14 ms and zero from this module.
#
# Why raw FFI rather than the `emacs` crate: `canvas_data` is a member of
# `struct emacs_env_32`, and that crate targets emacs_env_25/_29.  It cannot
# see the function, and the struct is accessed by field offset so it cannot
# be bolted on.  build.rs runs bindgen over the header shipped INSIDE the
# Emacs bundle, which pins the bindings to the exact binary being loaded
# into -- worth having when tracking a moving master.
#
# Prerequisites, both already handled elsewhere in .files:
#   rust                 Brewfile
#   libclang (bindgen)   Xcode command line tools, bootstrap.sh
#
# Gated on INCLUDE_EMACS_SRC: the module is useless without an Emacs that
# has canvas, which is the from-source build.

set -euo pipefail

SRC="$HOME/source_code/emacs-canvas-rs"
APP="$HOME/Applications/EmacsSrc.app"
DEST="$HOME/.zetta.d/source/lib/canvas-rs"
UPSTREAM="https://github.com/chiply/emacs-canvas-rs.git"

warn() { printf "\033[1;33m==>\033[0m %s\n" "$*" >&2; }
say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m==>\033[0m %s\n' "$*" >&2; exit 1; }

[ -d "$APP" ] || die "no $APP -- run install_emacs_source.sh first"
command -v cargo >/dev/null || die "cargo not found; \`brew install rust'"

HEADER="$APP/Contents/Resources/include/emacs-module.h"
[ -f "$HEADER" ] || die "no emacs-module.h in the bundle: $HEADER"

# The canvas API is Emacs 32+.  Fail with the version rather than with a
# bindgen error about a missing struct member.
if ! grep -q "canvas_data" "$HEADER"; then
    die "$HEADER has no canvas_data -- that Emacs predates the canvas API"
fi

if [ ! -d "$SRC" ]; then
    say "cloning $UPSTREAM"
    git clone "$UPSTREAM" "$SRC" 2>/dev/null || die "clone failed; the crate lives at $SRC"
fi

say "building against $HEADER"
cd "$SRC"
EMACS_MODULE_H="$HEADER" cargo build --release

# Emacs loads .so on every platform, including macOS -- .dylib is not
# searched by `module-load'.
mkdir -p "$DEST"
cp target/release/libemacs_canvas_rs.dylib "$DEST/canvas-rs.so"

# Re-sign after copying.  macOS caches a code signature against the path, so
# overwriting a dylib that was previously loaded from here leaves the cached
# signature describing the OLD bytes -- and the kernel then SIGKILLs any
# process that dlopens it.  It presents as Emacs dying instantly with exit
# 137 and no error at all, while the identical file under target/release
# loads fine.  A fresh ad-hoc signature clears it.
codesign --force --sign - "$DEST/canvas-rs.so" 2>/dev/null     || warn "could not re-sign the module; a rebuild may be SIGKILLed on load"
say "installed $DEST/canvas-rs.so"

"$APP/Contents/MacOS/Emacs" -Q --batch \
    --eval "(progn (module-load \"$DEST/canvas-rs.so\")
                   (unless (fboundp 'canvas-rs-plasma) (kill-emacs 1))
                   (princ \"module loads and defines its functions\n\"))" \
    || die "module built but failed to load"
