#!/usr/bin/env bash
#
# Build GNU Emacs from a release tag on the kb-hub (Ubuntu 24.04, no X).
#
# Why: apt's emacs-nox is 29.3, and the zetta config is written against
# 31 -- tty child frames (corfu, vertico-posframe), the header-line
# faces, treesit-enabled-modes, consult-gh/omni's 29.4 floor, the
# repeatable and treesit-tap paths that fall back on 29.  This is the
# Linux sibling of ~/.files/install_emacs_source.sh: same idea (a pinned
# revision, an idempotent no-op when current), none of the macOS bundle
# work, and a release tag rather than a master commit -- the hub wants
# the pretest line the Mac runs, not the canvas branch.
#
# What it deliberately keeps: no window system and no librsvg
# (--without-x), so `(image-type-available-p 'svg)' stays nil and the
# capability predicates in zetta keep the SVG chrome off, exactly as
# with apt's build.  Type=notify in emacs.service needs libsystemd, so
# that is passed explicitly rather than left to autodetection.
#
# Installs under /usr/local (sudo for `make install' only).  apt's
# emacs-nox stays installed as /usr/bin/emacs: it is the lean fallback
# daemon's Emacs and the floor CI tests.  emacs.service resolves `emacs'
# through PATH with /usr/local/bin first, so the source build takes
# over at the next daemon restart.
#
# Run by hand (the bootstrap installs this file to ~/.local/bin but
# never runs it): an hour or so of compile on 1 OCPU, then the package
# rebuild it prints at the end, which is another hour.
#
# Usage:
#   install-emacs-source.sh              build the pinned tag (no-op if current)
#   install-emacs-source.sh --tag TAG    build another release tag (emacs-30.2, ...)
#   install-emacs-source.sh --rebuild    rebuild the pinned tag from scratch
#
# Environment:
#   EMACS_SRC_NATIVE_COMP   yes (default: Emacs's own Lisp is native-compiled
#                           on demand, one worker at a time on this box) |
#                           aot (everything at build time; hours) | no
#   EMACS_SRC_JOBS          make -j (default: nproc)

set -euo pipefail

# The pin.  Emacs 31.1 is the release the Mac's pretest line settled
# into (tagged 2026-08-24); bump this and commit like any dotfile.
TAG="emacs-31.1"

SRC_DIR="$HOME/source_code/emacs"
PREFIX="/usr/local"
UPSTREAM="https://github.com/emacs-mirror/emacs.git"
STATE_DIR="$HOME/.local/state/emacs-src"
STATE_FILE="$STATE_DIR/build-info"

NATIVE_COMP="${EMACS_SRC_NATIVE_COMP:-yes}"
JOBS="${EMACS_SRC_JOBS:-$(nproc)}"

say()  { printf '\n==> %s\n' "$*"; }
die()  { printf '\n==> %s\n' "$*" >&2; exit 1; }

FORCE_REBUILD=""
while [ $# -gt 0 ]; do
  case "$1" in
    --tag)     [ -n "${2:-}" ] || die "--tag needs a value"; TAG="$2"; shift ;;
    --rebuild) FORCE_REBUILD=t ;;
    -h|--help) sed -n '3,40p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
  shift
done

# ---------------------------------------------------------------------------
# Nothing to do?
# ---------------------------------------------------------------------------

built_tag() {
  [ -f "$STATE_FILE" ] || return 0
  awk -F= '/^tag=/ {print $2}' "$STATE_FILE"
}

if [ -z "$FORCE_REBUILD" ] && [ -x "$PREFIX/bin/emacs" ] && [ "$(built_tag)" = "$TAG" ]; then
  say "$PREFIX/bin/emacs is already $TAG -- nothing to do (--rebuild to force)"
  exit 0
fi

# ---------------------------------------------------------------------------
# Build dependencies
#
# gcc-14 + libgccjit-14-dev as a matched pair: Debian puts libgccjit.h
# under the versioned gcc include directory, so configure only finds it
# when CC is that gcc.  14 is the libgccjit0 runtime already on the box
# (apt's emacs-nox depends on it), so native compilation at run time and
# the header at build time agree.  libtree-sitter-dev is 0.20.8 here;
# Emacs 31 accepts >= 0.20.2, and the grammar ABI ceiling (14) is the
# same as with apt's Emacs, so the python grammar pin in zetta stays.
# ---------------------------------------------------------------------------

say "build dependencies (apt)"
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential gcc-14 libgccjit-14-dev autoconf texinfo pkg-config git \
  libgnutls28-dev libncurses-dev libxml2-dev libsqlite3-dev \
  libtree-sitter-dev libsystemd-dev libgmp-dev zlib1g-dev libacl1-dev

# ---------------------------------------------------------------------------
# Source: a shallow clone of one tag, deepened tag by tag on a bump
# ---------------------------------------------------------------------------

if [ ! -d "$SRC_DIR/.git" ]; then
  say "cloning $UPSTREAM ($TAG, shallow) into $SRC_DIR"
  mkdir -p "$(dirname "$SRC_DIR")"
  git clone --quiet --depth 1 --branch "$TAG" "$UPSTREAM" "$SRC_DIR"
elif ! git -C "$SRC_DIR" rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  say "fetching $TAG"
  git -C "$SRC_DIR" fetch --quiet --depth 1 origin "refs/tags/$TAG:refs/tags/$TAG"
fi

say "checking out $TAG"
git -C "$SRC_DIR" checkout --quiet --detach --force "$TAG"
git -C "$SRC_DIR" clean -xfdq

# ---------------------------------------------------------------------------
# Configure + build
#
# Passed explicitly rather than autodetected where a silent miss would
# change the Emacs: tree-sitter (the ts modes), sqlite3 (org-persist,
# hyperbole), libsystemd (Type=notify), gnutls (any https).  Dropped on
# purpose: X and every image library (no display to draw on), dbus and
# gsettings (would pull the glib stack for nothing), sound.
# ---------------------------------------------------------------------------

CONFIGURE_ARGS=(
  --prefix="$PREFIX"
  --without-x
  --with-x-toolkit=no
  --with-native-compilation="$NATIVE_COMP"
  --with-tree-sitter
  --with-sqlite3
  --with-gnutls
  --with-xml2
  --with-libsystemd
  --with-modules
  --without-dbus
  --without-gsettings
  --without-gconf
  --without-sound
  --without-compress-install
  "CC=gcc-14"
)

cd "$SRC_DIR"

say "autogen"
./autogen.sh

say "configure (native-comp=$NATIVE_COMP)"
./configure "${CONFIGURE_ARGS[@]}"

say "building with -j$JOBS (about an hour on 1 OCPU; aot is several)"
make -j"$JOBS"

# ---------------------------------------------------------------------------
# Verify the binary before it can be installed over a working one
# ---------------------------------------------------------------------------

BUILT="$SRC_DIR/src/emacs"
[ -x "$BUILT" ] || die "no binary at $BUILT after make"

FEATURES="$("$BUILT" -Q --batch --eval '(princ system-configuration-features)')"
say "features: $FEATURES"
for want in TREE_SITTER SQLITE3 GNUTLS LIBSYSTEMD MODULES; do
  case " $FEATURES " in
    *" $want "*) ;;
    *) die "built without $want; not installing" ;;
  esac
done
case "$NATIVE_COMP" in
  no) ;;
  *) case " $FEATURES " in
       *" NATIVE_COMP "*) ;;
       *) die "built without NATIVE_COMP; not installing" ;;
     esac ;;
esac
if [ "$("$BUILT" -Q --batch --eval '(princ (image-type-available-p (quote svg)))')" != "nil" ]; then
  die "this build renders SVG; zetta's headless predicates would load the SVG chrome. Not installing"
fi

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

say "installing to $PREFIX (sudo)"
sudo make install

mkdir -p "$STATE_DIR"
cat > "$STATE_FILE" <<EOF
tag=$TAG
version=$("$PREFIX/bin/emacs" --batch --eval '(princ emacs-version)' 2>/dev/null)
built=$(date -u +%Y-%m-%dT%H:%M:%SZ)
native_comp=$NATIVE_COMP
configure=${CONFIGURE_ARGS[*]}
EOF

say "installed $("$PREFIX/bin/emacs" --version | head -1) at $PREFIX/bin/emacs"
say "apt's emacs-nox stays at /usr/bin/emacs (emacs-lean.service, CI floor)"

cat <<'EOF'

Next, by hand (README "Emacs from source"):

  1. Bytecode and native code are per Emacs build.  Rebuild the packages
     (about an hour on 1 OCPU, unattended, in a tmux window):
       rm -rf ~/.zetta.d/elpaca/builds ~/.zetta.d/eln-cache
       nohup ~/.zetta.d/bin/zetta build > ~/zetta-build.log 2>&1 &
     Done when the log has ZETTA-OK and no ELPACA-FAILED line.
  2. Restart the daemon when no editing session is live; the unit's PATH
     puts /usr/local/bin first, so this is the switch-over:
       systemctl --user restart emacs
       emacsclient --eval 'emacs-version'
  3. Re-check the tree-sitter grammars (python stays on its v0.23.6 pin:
     libtree-sitter is still 0.20.8):
       emacsclient --eval '(mapcar (lambda (l) (cons l (treesit-language-available-p l))) (quote (python tsx typescript)))'
EOF
