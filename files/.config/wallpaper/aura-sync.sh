#!/bin/bash
# Sync ~/Wallpapers to an Aura digital frame via its "email to frame" address.
#
# Aura has no public upload API. The two scriptable-ish paths are the web
# uploader (app.auraframes.com, manual drag-and-drop) and email-to-frame, which
# accepts one JPG/PNG/TIFF per message from an address registered on the frame.
# This script uses email-to-frame through the msmtp config already in .files,
# and keeps a ledger of what has been sent so re-runs only send new wallpapers.
#
# One-time setup:
#   1. Aura app -> frame -> Settings -> "Email to frame": copy the address.
#   2. Put in ~/.zshenv.local (not tracked):
#        export AURA_FRAME_EMAIL="something@frame.auraframes.com"
#        export AURA_MSMTP_ACCOUNT="<msmtp account>"  # the account whose from= is your Aura login
#   3. aura-sync.sh --limit 1   # send one, confirm it shows on the frame
#   4. aura-sync.sh             # send the rest (default 100/run; Gmail caps ~500/day)
#
# Env knobs (all optional except AURA_FRAME_EMAIL and AURA_MSMTP_ACCOUNT):
#   WALLPAPER_DIR        source dir                         (default ~/Wallpapers)
#   AURA_MSMTP_ACCOUNT   msmtp account; its from= must be the email on your Aura account
#   AURA_MAX_EDGE        downscale so the long edge <= this  (default 2048; never upscales)
#   AURA_ASPECT          optional center crop, e.g. 4:3 (Mason/Walden) or 16:10 (Carver)
#                        unset = no crop, let the frame's own fit setting decide
#   AURA_JPEG_QUALITY    starting JPEG quality               (default 85; lowered if > 9.5 MB)
#   AURA_SEND_SLEEP      seconds between emails              (default 4)
#
# Flags:
#   --limit N        send at most N images this run (default 100)
#   --dry-run        prepare + report what would be sent, send nothing
#   --prepare-only   just build the converted cache, no ledger writes
#   --status         counts: total / sent / pending
#   --force FILE     re-send FILE even if the ledger says it went already
#
# State:
#   ~/.local/state/aura/sent.tsv     sha256 <TAB> sent-at <TAB> source path
#   ~/.cache/aura/<sha256>.jpg       converted images (safe to delete)

set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Wallpapers}"
AURA_FRAME_EMAIL="${AURA_FRAME_EMAIL:-}"
AURA_MSMTP_ACCOUNT="${AURA_MSMTP_ACCOUNT:-}"   # required to send; no default (it names a personal account)
AURA_MAX_EDGE="${AURA_MAX_EDGE:-2048}"
AURA_ASPECT="${AURA_ASPECT:-}"
AURA_JPEG_QUALITY="${AURA_JPEG_QUALITY:-85}"
AURA_SEND_SLEEP="${AURA_SEND_SLEEP:-4}"
AURA_MAX_BYTES=$((9500 * 1000))   # Aura's stated 9.5 MB ceiling

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/aura"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/aura"
LEDGER="$STATE_DIR/sent.tsv"

LIMIT=100
DRY_RUN=0
PREPARE_ONLY=0
STATUS_ONLY=0
FORCE_FILE=""

while [ $# -gt 0 ]; do
    case "$1" in
        --limit)        LIMIT="$2"; shift 2 ;;
        --dry-run)      DRY_RUN=1; shift ;;
        --prepare-only) PREPARE_ONLY=1; shift ;;
        --status)       STATUS_ONLY=1; shift ;;
        --force)        FORCE_FILE="$2"; shift 2 ;;
        -h|--help)      sed -n '2,40p' "$0"; exit 0 ;;
        *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
done

mkdir -p "$STATE_DIR" "$CACHE_DIR"
touch "$LEDGER"

log() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

# ── Enumerate source images (sorted so runs are deterministic) ─────────
images=()
while IFS= read -r -d '' f; do images+=("$f"); done < <(
    find "$WALLPAPER_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.heic' \
           -o -iname '*.webp' -o -iname '*.tif' -o -iname '*.tiff' \) -print0 | sort -z)

if [ ${#images[@]} -eq 0 ]; then
    log "no images in $WALLPAPER_DIR"; exit 0
fi

sha_of() { shasum -a 256 "$1" | cut -d' ' -f1; }
in_ledger() { grep -q "^$1	" "$LEDGER"; }

if [ "$STATUS_ONLY" -eq 1 ]; then
    sent=0; pending=0
    for src in "${images[@]}"; do
        if in_ledger "$(sha_of "$src")"; then sent=$((sent+1)); else pending=$((pending+1)); fi
    done
    printf 'total=%d sent=%d pending=%d\nledger=%s\n' "${#images[@]}" "$sent" "$pending" "$LEDGER"
    exit 0
fi

if [ "$PREPARE_ONLY" -eq 0 ] && [ "$DRY_RUN" -eq 0 ] && [ -z "$AURA_FRAME_EMAIL" ]; then
    log "AURA_FRAME_EMAIL is not set (Aura app -> frame -> Settings -> Email to frame)"; exit 2
fi
if [ "$PREPARE_ONLY" -eq 0 ] && [ "$DRY_RUN" -eq 0 ] && [ -z "$AURA_MSMTP_ACCOUNT" ]; then
    log "AURA_MSMTP_ACCOUNT is not set (the msmtp account whose from= is your Aura login)"; exit 2
fi
command -v sips >/dev/null || { log "sips not found (macOS only)"; exit 2; }
if [ "$PREPARE_ONLY" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
    command -v msmtp >/dev/null || { log "msmtp not found (brew install msmtp)"; exit 2; }
fi

# From-address is read out of msmtp so the ledger/email match the account exactly.
from_addr() {
    msmtp -a "$AURA_MSMTP_ACCOUNT" -P nobody@example.com 2>/dev/null \
        | awk '/^from = /{print $3}'
}

# ── Convert one source image into the cache; echoes the cache path ─────
# JPEG, long edge <= AURA_MAX_EDGE (no upscaling), optional center crop,
# quality stepped down until the file is under Aura's 9.5 MB limit.
prepare() {
    local src="$1" sha="$2"
    local out="$CACHE_DIR/$sha.jpg"
    if [ -s "$out" ]; then echo "$out"; return 0; fi

    local w h
    w=$(sips -g pixelWidth  "$src" 2>/dev/null | awk '/pixelWidth/{print $2}')
    h=$(sips -g pixelHeight "$src" 2>/dev/null | awk '/pixelHeight/{print $2}')
    if [ -z "$w" ] || [ -z "$h" ]; then log "  ! unreadable, skipping: $src"; return 1; fi

    # macOS ships bash 3.2, where "${arr[@]}" on an empty array trips set -u;
    # pass the resample flag as a plain string instead.
    local resize=""
    if [ "$w" -gt "$AURA_MAX_EDGE" ] || [ "$h" -gt "$AURA_MAX_EDGE" ]; then
        resize="-Z $AURA_MAX_EDGE"
    fi

    local q="$AURA_JPEG_QUALITY" tmp="$out.tmp.jpg"
    while :; do
        # shellcheck disable=SC2086  # $resize is intentionally word-split
        sips -s format jpeg -s formatOptions "$q" $resize "$src" --out "$tmp" >/dev/null 2>&1 \
            || { log "  ! sips failed on $src"; rm -f "$tmp"; return 1; }

        if [ -n "$AURA_ASPECT" ]; then
            local aw="${AURA_ASPECT%%:*}" ah="${AURA_ASPECT##*:}" cw ch
            cw=$(sips -g pixelWidth  "$tmp" | awk '/pixelWidth/{print $2}')
            ch=$(sips -g pixelHeight "$tmp" | awk '/pixelHeight/{print $2}')
            # crop to the largest centered box with the requested aspect
            if [ $((cw * ah)) -gt $((ch * aw)) ]; then
                cw=$((ch * aw / ah))          # too wide: trim width
            else
                ch=$((cw * ah / aw))          # too tall: trim height
            fi
            sips -c "$ch" "$cw" "$tmp" >/dev/null 2>&1
        fi

        local bytes
        bytes=$(stat -f %z "$tmp")
        if [ "$bytes" -le "$AURA_MAX_BYTES" ] || [ "$q" -le 40 ]; then break; fi
        q=$((q - 15))
        log "  - $(basename "$src") is ${bytes}B > 9.5MB, retrying at quality $q"
    done
    mv "$tmp" "$out"
    echo "$out"
}

# ── Email one converted image to the frame ─────────────────────────────
send_one() {
    local file="$1" name="$2" from="$3"
    python3 - "$file" "$name" "$AURA_FRAME_EMAIL" "$from" <<'PY' | msmtp -a "$AURA_MSMTP_ACCOUNT" "$AURA_FRAME_EMAIL"
import sys, pathlib
from email.message import EmailMessage
path, name, to, frm = sys.argv[1:5]
m = EmailMessage()
m["To"] = to
m["From"] = frm
m["Subject"] = name
m.set_content("")
m.add_attachment(pathlib.Path(path).read_bytes(), maintype="image", subtype="jpeg", filename=name)
sys.stdout.buffer.write(m.as_bytes())
PY
}

# ── Main loop ──────────────────────────────────────────────────────────
from=""
if [ "$PREPARE_ONLY" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
    from=$(from_addr)
    [ -n "$from" ] || { log "could not read from= for msmtp account $AURA_MSMTP_ACCOUNT"; exit 2; }
    log "sending as $from -> $AURA_FRAME_EMAIL (limit $LIMIT, ${AURA_SEND_SLEEP}s apart)"
fi

sent=0; skipped=0; prepared=0; failed=0
for src in "${images[@]}"; do
    sha=$(sha_of "$src")
    if in_ledger "$sha" && [ "$src" != "$FORCE_FILE" ]; then skipped=$((skipped+1)); continue; fi
    if [ "$PREPARE_ONLY" -eq 0 ] && [ "$sent" -ge "$LIMIT" ]; then break; fi

    out=$(prepare "$src" "$sha") || { failed=$((failed+1)); continue; }
    prepared=$((prepared+1))
    name="$(basename "${src%.*}").jpg"

    if [ "$PREPARE_ONLY" -eq 1 ]; then continue; fi
    if [ "$DRY_RUN" -eq 1 ]; then
        log "  would send $name ($(stat -f %z "$out")B)"; sent=$((sent+1)); continue
    fi

    if send_one "$out" "$name" "$from"; then
        printf '%s\t%s\t%s\n' "$sha" "$(date -u +%FT%TZ)" "$src" >> "$LEDGER"
        sent=$((sent+1))
        log "  sent $sent/$LIMIT: $name"
        sleep "$AURA_SEND_SLEEP"
    else
        failed=$((failed+1))
        log "  ! msmtp failed on $name (not recorded; will retry next run)"
    fi
done

log "done: sent=$sent prepared=$prepared already-sent=$skipped failed=$failed"
