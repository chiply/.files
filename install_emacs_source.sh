#!/usr/bin/env bash
#
# Build GNU Emacs from the upstream git tree as a fourth chemacs variant.
#
# Why a source build at all: it tracks master (Emacs 32.0.50), which is where
# the canvas feature landed -- canvas is unconditional on master, there is no
# --with-canvas flag and no patch to apply.  Building the emacs-31 branch
# instead would need minad's canvas-31.patch.
#
# Feature parity with the emacs-plus@31 daily driver is deliberate, so the
# switch is seamless.  That means more than the configure line: the four NS
# patches d12frosted maintains, the CFLAGS/LDFLAGS pair that lets configure
# find libgccjit, and four post-install edits to the app bundle.  The bundle
# edits are not cosmetic -- without the TCC usage descriptions, anything
# started from inside Emacs (M-x shell, compile, org-babel) is killed with
# SIGABRT the moment it touches a protected framework, and without the
# ad-hoc signature the bundle will not launch on Sequoia or later.
#
# Installs to ~/Applications/EmacsSrc.app.  Never touches
# /Applications/Emacs.app (the emacs-plus symlink) or ~/.zetta.d.
#
# Usage:
#   install_emacs_source.sh              build the pinned revision (no-op if current)
#   install_emacs_source.sh --bump       move the pin to origin/master and build
#   install_emacs_source.sh --bump <sha> move the pin to <sha> and build
#   install_emacs_source.sh --rebuild    rebuild the pinned revision from scratch
#   install_emacs_source.sh --rollback   swap in the previous bundle (seconds,
#                                        no rebuild) and move the pin with it
#
# Environment:
#   EMACS_SRC_REVISION      one-off revision override; does not touch the pin
#   EMACS_SRC_NATIVE_COMP   aot (default, matches emacs-plus) | yes | no
#   EMACS_SRC_SKIP_PATCHES  t = build unpatched (escape hatch when a patch
#                           stops applying against a moved master)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SRC_DIR="$HOME/source_code/emacs"
APP="$HOME/Applications/EmacsSrc.app"
# One generation back, kept so a bad master commit is a seconds-long swap
# rather than a 45-70 minute rebuild.  Only one generation: the source tree
# and the pin cover anything older, and each bundle is ~400 MB.
PREV_APP="$HOME/Applications/EmacsSrc.app.prev"
REVISION_FILE="$REPO_ROOT/files/.config/emacs-src/revision"
STATE_DIR="$HOME/.local/state/emacs-src"
STATE_FILE="$STATE_DIR/build-info"
PREV_STATE_FILE="$STATE_DIR/build-info.prev"
UPSTREAM="https://github.com/emacs-mirror/emacs.git"

NATIVE_COMP="${EMACS_SRC_NATIVE_COMP:-aot}"

# The NS patches emacs-plus applies.  Taken from the installed tap rather than
# vendored: d12frosted keeps them current against master (the @32 formula
# symlinks this same emacs-31 directory unchanged), so tracking the tap gets
# fixes for free.  They are copied into the source tree before use so a build
# is reproducible from the tree alone.
PATCH_NAMES=(
    fix-ns-x-colors
    system-appearance
    round-undecorated-frame
    fix-ns-scroll-crash
)

# TCC usage descriptions, transcribed from the emacs-plus tap's
# Library/PlistExtras.rb (USAGE_DESCRIPTIONS).  macOS attributes a privacy
# check to the responsible process, which for anything spawned from within
# Emacs is Emacs.app itself; a missing key is a hard crash for the class-based
# services.  Declaring a key grants nothing -- it only supplies the string
# shown in the permission dialog.  Upstream Emacs declines to ship these
# (bug#81526), and they cannot be added after signing.
PLIST_USAGE_KEYS=(
    "NSBluetoothAlwaysUsageDescription=An application in Emacs requires permission to use Bluetooth."
    "NSCalendarsUsageDescription=An application in Emacs requires permission to access your calendars."
    "NSCalendarsFullAccessUsageDescription=An application in Emacs requires full access to your calendars."
    "NSCalendarsWriteOnlyAccessUsageDescription=An application in Emacs requires permission to add events to your calendars."
    "NSCameraUsageDescription=An application in Emacs requires permission to use the camera."
    "NSContactsUsageDescription=An application in Emacs requires permission to access your contacts."
    "NSLocalNetworkUsageDescription=An application in Emacs requires permission to access the local network."
    "NSLocationUsageDescription=An application in Emacs requires permission to access your location."
    "NSLocationWhenInUseUsageDescription=An application in Emacs requires permission to access your location."
    "NSMicrophoneUsageDescription=An application in Emacs requires permission to use the microphone."
    "NSPhotoLibraryUsageDescription=An application in Emacs requires permission to access your photo library."
    "NSPhotoLibraryAddUsageDescription=An application in Emacs requires permission to add photos to your photo library."
    "NSRemindersUsageDescription=An application in Emacs requires permission to access your reminders."
    "NSRemindersFullAccessUsageDescription=An application in Emacs requires full access to your reminders."
    "NSSpeechRecognitionUsageDescription=Emacs requires permission to handle any speech recognition."
)

PLIST_BUDDY=/usr/libexec/PlistBuddy

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m==>\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------

BUMP=""
FORCE_REBUILD=""
ROLLBACK=""

while [ $# -gt 0 ]; do
    case "$1" in
        --bump)
            # Optional argument: only consume $2 when it is a revision rather
            # than the next flag, so `--bump --rebuild` means what it looks like.
            case "${2:-}" in
                ""|-*) BUMP="origin/master" ;;
                *)     BUMP="$2"; shift ;;
            esac
            ;;
        --rebuild)  FORCE_REBUILD=t ;;
        --rollback) ROLLBACK=t ;;
        -h|--help) sed -n '3,34p' "${BASH_SOURCE[0]}"; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
    shift
done

# ---------------------------------------------------------------------------
# The pin
# ---------------------------------------------------------------------------

read_pin() {
    [ -f "$REVISION_FILE" ] || return 0
    sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$REVISION_FILE" | tr -d '[:space:]' | head -1
}

write_pin() {
    mkdir -p "$(dirname "$REVISION_FILE")"
    cat > "$REVISION_FILE" <<EOF
# Emacs revision built by install_emacs_source.sh.
#
# Pinned rather than tracking HEAD so a fresh machine reproduces this exact
# Emacs, and so a bad master commit is one edit away from being rolled back.
# Move it forward with \`install_emacs_source.sh --bump\` (or the emacs-src-update
# alias), which rewrites this file -- then commit it like any other dotfile.
$1
EOF
}

# ---------------------------------------------------------------------------
# Rollback
#
# Swaps the installed bundle with the one generation kept beside it, so a bad
# master commit costs seconds rather than a 45-70 minute rebuild.  It is a
# swap rather than a discard: run it twice and you are back where you started,
# which makes it usable for A/B-ing a suspect revision.
#
# The pin moves with the bundle.  Leaving it pointing at the revision just
# rolled away from would make the next plain run rebuild exactly the bad Emacs
# that was rolled back -- so the restored revision is written back to
# files/.config/emacs-src/revision, and that file is then a normal commit.
# ---------------------------------------------------------------------------

if [ -n "$ROLLBACK" ]; then
    [ -d "$PREV_APP" ] || die "nothing to roll back to: $PREV_APP does not exist.
The previous bundle is kept from the second build onward, so there is no
rollback target until you have bumped at least once."

    OUTGOING="$(awk -F= '/^revision=/ {print $2}' "$STATE_FILE" 2>/dev/null)"
    INCOMING="$(awk -F= '/^revision=/ {print $2}' "$PREV_STATE_FILE" 2>/dev/null)"

    SWAP="$HOME/Applications/.EmacsSrc.app.swap"
    rm -rf "$SWAP"
    mv "$APP" "$SWAP"
    mv "$PREV_APP" "$APP"
    mv "$SWAP" "$PREV_APP"

    if [ -f "$PREV_STATE_FILE" ]; then
        mv "$STATE_FILE" "$STATE_DIR/.build-info.swap"
        mv "$PREV_STATE_FILE" "$STATE_FILE"
        mv "$STATE_DIR/.build-info.swap" "$PREV_STATE_FILE"
    fi

    [ -n "$INCOMING" ] && write_pin "$INCOMING"

    say "rolled back to ${INCOMING:-unknown}"
    say "the bundle rolled away from (${OUTGOING:-unknown}) is now $PREV_APP"
    say "run --rollback again to swap back; commit $REVISION_FILE to keep it"
    exit 0
fi

# ---------------------------------------------------------------------------
# Source tree
# ---------------------------------------------------------------------------

if [ ! -d "$SRC_DIR/.git" ]; then
    say "cloning $UPSTREAM into $SRC_DIR"
    mkdir -p "$(dirname "$SRC_DIR")"
    git clone "$UPSTREAM" "$SRC_DIR"
fi

say "fetching upstream"
git -C "$SRC_DIR" fetch --tags origin

# ---------------------------------------------------------------------------
# Revision: pinned in .files, bumped deliberately
# ---------------------------------------------------------------------------

if [ -n "$BUMP" ]; then
    REVISION="$(git -C "$SRC_DIR" rev-parse "$BUMP^{commit}")" \
        || die "cannot resolve revision: $BUMP"
    say "bumping pin to $REVISION"
    write_pin "$REVISION"
elif [ -n "${EMACS_SRC_REVISION:-}" ]; then
    REVISION="$(git -C "$SRC_DIR" rev-parse "${EMACS_SRC_REVISION}^{commit}")" \
        || die "cannot resolve EMACS_SRC_REVISION: $EMACS_SRC_REVISION"
    warn "using EMACS_SRC_REVISION override; the pin in $REVISION_FILE is unchanged"
else
    REVISION="$(read_pin)"
    if [ -z "$REVISION" ]; then
        REVISION="$(git -C "$SRC_DIR" rev-parse origin/master)"
        say "no pin recorded; seeding it with origin/master ($REVISION)"
        write_pin "$REVISION"
    fi
    REVISION="$(git -C "$SRC_DIR" rev-parse "${REVISION}^{commit}")" \
        || die "pinned revision not found in $SRC_DIR: $REVISION"
fi

# ---------------------------------------------------------------------------
# Nothing to do?
# ---------------------------------------------------------------------------

built_revision() {
    [ -f "$STATE_FILE" ] || return 0
    awk -F= '/^revision=/ {print $2}' "$STATE_FILE"
}

if [ -z "$FORCE_REBUILD" ] && [ -d "$APP" ] && [ "$(built_revision)" = "$REVISION" ]; then
    say "EmacsSrc.app is already at $REVISION -- nothing to do (--rebuild to force)"
    exit 0
fi

# ---------------------------------------------------------------------------
# Checkout + patches
# ---------------------------------------------------------------------------

say "checking out $REVISION"
git -C "$SRC_DIR" checkout --detach --force "$REVISION"
git -C "$SRC_DIR" clean -xfd

PATCH_STORE="$SRC_DIR/.emacs-plus-patches"

if [ "${EMACS_SRC_SKIP_PATCHES:-}" = "t" ]; then
    warn "EMACS_SRC_SKIP_PATCHES=t -- building without the emacs-plus NS patches"
else
    TAP="$(brew --repository d12frosted/emacs-plus 2>/dev/null || true)"
    [ -d "$TAP/patches/emacs-31" ] \
        || die "emacs-plus tap not found; \`brew tap d12frosted/emacs-plus\` or set EMACS_SRC_SKIP_PATCHES=t"

    mkdir -p "$PATCH_STORE"
    for name in "${PATCH_NAMES[@]}"; do
        cp "$TAP/patches/emacs-31/$name.patch" "$PATCH_STORE/$name.patch"
    done

    # GNU patch rather than `git apply`, because that is what Homebrew (and so
    # emacs-plus) uses, and its fuzz matching is what makes these emacs-31
    # patches keep working against a moving master.  `git apply` -- even
    # --3way -- is stricter: master added its sleep/wake handlers at the exact
    # anchor where system-appearance.patch inserts its appearance observer,
    # which git reports as a conflict and patch resolves by keeping both.
    #
    # A reject is fatal rather than skipped: silently dropping
    # system-appearance or round-undecorated-frame would surface later as a
    # config regression, not as a build failure.
    for name in "${PATCH_NAMES[@]}"; do
        say "applying $name.patch"
        if ! patch -p1 --no-backup-if-mismatch --forward \
             -d "$SRC_DIR" < "$PATCH_STORE/$name.patch"; then
            die "$name.patch no longer applies to $REVISION.
Inspect it and the .rej files in $SRC_DIR, or rebuild without the patches:
  EMACS_SRC_SKIP_PATCHES=t $0 --rebuild"
        fi
    done

    REJECTS="$(find "$SRC_DIR" -name '*.rej' -not -path '*/.git/*')"
    [ -z "$REJECTS" ] || die "patches left rejects behind:
$REJECTS"
fi

# ---------------------------------------------------------------------------
# Configure
# ---------------------------------------------------------------------------

brew_prefix() { brew --prefix "$1" 2>/dev/null || die "missing Homebrew formula: $1"; }

SQLITE="$(brew_prefix sqlite)"
GCC="$(brew_prefix gcc)"
LIBGCCJIT="$(brew_prefix libgccjit)"
IMAGEMAGICK="$(brew_prefix imagemagick)"

# libgccjit lives in the versioned gcc runtime directory; native compilation
# needs both -L and an rpath entry or the built Emacs cannot dlopen it.
GCC_LIB="$(ls -d "$(brew --prefix)"/lib/gcc/[0-9]* 2>/dev/null | sort -V | tail -1)"
[ -n "$GCC_LIB" ] || die "no versioned gcc runtime directory under $(brew --prefix)/lib/gcc"

# ImageMagick is keg-linked but its .pc lives outside the default search path.
export PKG_CONFIG_PATH="$IMAGEMAGICK/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"

# Homebrew's own include/lib.  emacs-plus never has to pass these because
# Homebrew builds formulae under `superenv`, which injects them automatically;
# a build run by hand gets no such help.  Without them configure silently
# misses every header that is only reachable through the linked prefix --
# gmp.h, gif_lib.h, jpeglib.h and tiff.h -- and quietly produces an Emacs
# without GMP, GIF, JPEG or TIFF while reporting success.  That is a real
# parity gap: mini-gmp replaces libgmp for bignums, and the image format
# defines change code paths in image.c.
BREW_PREFIX="$(brew --prefix)"

# Matches emacs-plus@31's configure line, with two additions: --with-tree-sitter
# and --with-sqlite3 are passed explicitly.  Both are autodetected today, but
# autodetection fails silently -- a missing header would quietly produce an
# Emacs without tree-sitter rather than a failed configure.
#
# Deliberately absent: --with-x11 (mutually exclusive with xwidgets, needs
# XQuartz -- ruled out in ~/.zetta.d/FONTS.org) and --with-mailutils (mbsync
# and mu4e handle mail; it only replaces the built-in POP client).
#
# Self-contained, unlike emacs-plus: emacs-plus passes
# --disable-ns-self-contained because it installs into a Homebrew Cellar
# prefix.  Installing into ~/Applications instead, the NS default puts lisp
# and native-lisp inside the bundle, which is what the emacs-mac trial in
# install_emacs_distros.sh already does.
CONFIGURE_ARGS=(
    --with-ns
    --with-native-compilation="$NATIVE_COMP"
    --with-modules
    --with-xml2
    --with-gnutls
    --with-rsvg
    --with-webp
    --with-imagemagick
    --with-dbus
    --with-xwidgets
    --with-tree-sitter
    --with-sqlite3
    --without-compress-install
    --without-mailutils
    --without-x
    "CFLAGS=-O2 -DFD_SETSIZE=10000 -DDARWIN_UNLIMITED_SELECT -I$BREW_PREFIX/include -I$SQLITE/include -I$GCC/include -I$LIBGCCJIT/include"
    "LDFLAGS=-L$BREW_PREFIX/lib -L$SQLITE/lib -L$GCC_LIB -Wl,-rpath,$GCC_LIB"
)

cd "$SRC_DIR"

say "autogen"
./autogen.sh

say "configure (native-comp=$NATIVE_COMP)"
./configure "${CONFIGURE_ARGS[@]}"

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

JOBS="$(sysctl -n hw.ncpu)"
say "building with -j$JOBS (AOT native compilation takes 45-70 minutes)"
gmake -j"$JOBS"
gmake install

BUILT_APP="$SRC_DIR/nextstep/Emacs.app"
[ -d "$BUILT_APP" ] || die "expected $BUILT_APP after \`gmake install\`"

# ---------------------------------------------------------------------------
# Bundle post-processing (mirrors emacs-plus's install/post_install)
#
# Staged in ~/Applications under a temporary name and only swapped in at the
# very end, so a failure anywhere here leaves the previously installed
# EmacsSrc.app untouched.  Order matters: codesign has to come last, because
# every Info.plist edit invalidates the signature.
#
# ditto rather than cp -R: it is the macOS-native bundle copy, and preserves
# ACLs, extended attributes and resource forks that cp drops.
# ---------------------------------------------------------------------------

mkdir -p "$HOME/Applications"
STAGING="$HOME/Applications/.EmacsSrc.app.new"
rm -rf "$STAGING"
say "staging the bundle at $STAGING"
ditto "$BUILT_APP" "$STAGING"

CONTENTS="$STAGING/Contents"
PLIST="$CONTENTS/Info.plist"

# Self-contained NS layout, from configure.ac: infodir, lispdir and
# locallisppath all sit under Contents/Resources, and eln files land in
# Contents/Frameworks/native-lisp (ELN_DESTDIR = ns_applibdir).
INFO_DIR="$CONTENTS/Resources/info"
SITE_LISP="$CONTENTS/Resources/site-lisp"

say "rebuilding the info directory"
if [ -d "$INFO_DIR" ]; then
    for f in "$INFO_DIR"/*.info; do
        [ -e "$f" ] || continue
        install-info --info-dir="$INFO_DIR" "$f" 2>/dev/null || true
    done
else
    warn "no info directory at $INFO_DIR; skipping install-info"
fi

plist_set() {
    # PlistBuddy has no upsert; Set fails on a missing key and Add on an
    # existing one, so try both.
    "$PLIST_BUDDY" -c "Set :$1 $3" "$PLIST" >/dev/null 2>&1 \
        || "$PLIST_BUDDY" -c "Add :$1 $2 $3" "$PLIST" >/dev/null 2>&1 \
        || warn "could not set $1 in Info.plist"
}

# A GUI-launched app inherits launchd's PATH, not the shell's -- so without
# this, native compilation cannot find gcc/libgccjit and every .eln fails.
say "injecting PATH into Info.plist"
NATIVE_COMP_PATH="$(brew --prefix)/bin:$(brew --prefix)/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
INJECT_PATH="$PATH"
for p in ${NATIVE_COMP_PATH//:/ }; do
    case ":$INJECT_PATH:" in
        *":$p:"*) ;;
        *) INJECT_PATH="$INJECT_PATH:$p" ;;
    esac
done
"$PLIST_BUDDY" -c "Add :LSEnvironment dict" "$PLIST" >/dev/null 2>&1 || true
plist_set "LSEnvironment:PATH" string "$INJECT_PATH"

say "declaring TCC usage descriptions"
for entry in "${PLIST_USAGE_KEYS[@]}"; do
    plist_set "${entry%%=*}" string "${entry#*=}"
done

# Stops macOS 26 (Tahoe) spawning an "AutoFill (Emacs)" helper that scans text
# fields for one-time codes.
plist_set NSAutoFillRequiresTextContentTypeForOneTimeCodeOnMac bool true

# Distinguish this build from emacs-plus in init code, the way emacs-plus's
# generated site-start.el defines ns-emacs-plus-version.  Resources/site-lisp
# is `locallisppath' for a self-contained NS build, so this is loaded on
# startup as `site-run-file'.
if [ -d "$SITE_LISP" ] || mkdir -p "$SITE_LISP"; then
    say "writing site-start.el"
    cat > "$SITE_LISP/site-start.el" <<EOF
;;; site-start.el --- source-build site initialization -*- lexical-binding: t -*-

;; Generated by ~/.files/install_emacs_source.sh.  Lets init code tell this
;; build apart from emacs-plus (which defines \`ns-emacs-plus-version') and
;; from the emacs-mac trial.

(defconst ns-emacs-source-build-revision "$REVISION"
  "Upstream git revision this Emacs was built from.")

(provide 'site-start)
;;; site-start.el ends here
EOF
fi

touch "$STAGING"

say "code signing"
codesign --force --deep --sign - "$STAGING"

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

# Rotate the outgoing bundle into the .prev slot so --rollback has a target.
# Only when the revision actually changed: otherwise a couple of --rebuild runs
# of the same commit would quietly overwrite the rollback target with a copy of
# what is already installed, and the safety net would be gone exactly when a
# bad bump needed it.
OUTGOING_REV="$(built_revision)"
if [ -d "$APP" ] && [ -n "$OUTGOING_REV" ] && [ "$OUTGOING_REV" != "$REVISION" ]; then
    say "keeping $OUTGOING_REV as $PREV_APP"
    rm -rf "$PREV_APP"
    mv "$APP" "$PREV_APP"
    if [ -f "$STATE_FILE" ]; then
        mv "$STATE_FILE" "$PREV_STATE_FILE"
    fi
fi

rm -rf "$APP"
mv "$STAGING" "$APP"
say "installed $APP"

mkdir -p "$STATE_DIR"
cat > "$STATE_FILE" <<EOF
revision=$REVISION
version=$("$APP/Contents/MacOS/Emacs" --batch --eval '(princ emacs-version)' 2>/dev/null)
built=$(date -u +%Y-%m-%dT%H:%M:%SZ)
native_comp=$NATIVE_COMP
patches=$([ "${EMACS_SRC_SKIP_PATCHES:-}" = "t" ] && echo none || echo "${PATCH_NAMES[*]}")
configure=${CONFIGURE_ARGS[*]}
EOF

if [ -d "$PREV_APP" ]; then
    say "rollback target: $(awk -F= '/^revision=/ {print $2}' "$PREV_STATE_FILE" 2>/dev/null || echo unknown) (--rollback)"
fi

say "features: $("$APP/Contents/MacOS/Emacs" --batch --eval '(princ system-configuration-features)')"
say "done -- launch with \`emacs-src\` (chemacs profile zetta-src)"
