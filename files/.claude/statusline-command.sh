#!/usr/bin/env bash
# Claude Code statusline. Mirrors the user's starship default prompt, then
# appends Claude-specific state:
#
#   <dir> <branch>[flags] via <node> vX via 🐍 vX  ctx N%  $X.XX  5h N%  <model> <effort> ⚡  · <session>
#
# Input is the harness JSON on stdin. No network calls. Language-version
# lookups are gated on project marker files so `node -v` / `python3 -V`
# only run where they are relevant. Colors are ANSI via printf; Claude Code
# renders the status line dimmed, so these read as muted accents.

# ---- knobs -----------------------------------------------------------------
USE_COLOR=1        # 0 disables all ANSI
SHORTEN_MODEL=1    # 1 trims a trailing parenthetical: "Opus 5 (1M context)" -> "Opus 5"
RATE_LIMIT_AT=50   # only show the 5h rate-limit segment at or above this %
SESSION_MAX=24     # truncate session name to this many chars

node_icon=""     # nerd-font nodejs glyph (starship default)
git_icon=""      # nerd-font branch glyph (starship default)
ESC=$'\033'

input=$(cat)

# ---- one jq pass -----------------------------------------------------------
# jq startup dominates this script's runtime, so extract every field at once
# rather than paying for it per field.
IFS=$'\t' read -r cwd model ctx_left cost_usd rate5h effort fast_mode session <<EOF
$(printf '%s' "$input" | jq -r '[
    (.workspace.current_dir // .cwd // ""),
    (.model.display_name // ""),
    (.context_window.remaining_percentage // ""),
    (.cost.total_cost_usd // ""),
    (.rate_limits.five_hour.used_percentage // ""),
    (.effort.level // ""),
    (.fast_mode // false),
    (.session_name // "")
  ] | @tsv')
EOF
[ -z "$cwd" ] && cwd="$PWD"

# is_num <val> -- guards the integer comparisons below against empty/garbage
is_num() { case "$1" in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac; }

# paint <ansi-code> <text> -- honours USE_COLOR, no subshell
paint() { if [ "$USE_COLOR" = 1 ]; then printf -v _p '%s' "${ESC}[${1}m${2}${ESC}[0m"; else _p="$2"; fi; }

# ---- directory: ~-relative, truncated to last 3 components -----------------
dir="$cwd"
case "$dir" in
  "$HOME") dir="~" ;;
  "$HOME"/*) dir="~/${dir#"$HOME"/}" ;;
esac
dir_out=$(printf '%s' "$dir" | awk -F/ '{
  n = NF
  if (n <= 3) { print $0; exit }
  printf "…/%s/%s/%s", $(n-2), $(n-1), $n
}')

# ---- git: branch + dirty/staged/ahead-behind -------------------------------
# Operate on the directory we are displaying. The harness cwd is not
# guaranteed to match .workspace.current_dir, and when it does not, git would
# otherwise report a different repo than the one shown (or none at all).
cd "$cwd" 2>/dev/null || true
git_out=""
if git --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  [ -z "$branch" ] && branch=$(git --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    status=$(git --no-optional-locks status --porcelain=v1 2>/dev/null)
    flags=""
    printf '%s\n' "$status" | grep -q '^??'     && flags="${flags}?"
    printf '%s\n' "$status" | grep -Eq '^.[MD]' && flags="${flags}!"
    printf '%s\n' "$status" | grep -Eq '^[MADRC]' && flags="${flags}+"
    ab=$(git --no-optional-locks rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null)
    if [ -n "$ab" ]; then
      ahead=$(printf '%s' "$ab" | awk '{print $1}')
      behind=$(printf '%s' "$ab" | awk '{print $2}')
      is_num "$ahead"  && [ "$ahead"  -gt 0 ] && flags="${flags}⇡${ahead}"
      is_num "$behind" && [ "$behind" -gt 0 ] && flags="${flags}⇣${behind}"
    fi
    git_out=" ${git_icon} ${branch}"
    [ -n "$flags" ] && git_out="${git_out} [${flags}]"
  fi
fi

# ---- language versions: gated on project marker files ----------------------
lang_out=""
if [ -f "$cwd/package.json" ] || [ -f "$cwd/.nvmrc" ]; then
  if command -v node >/dev/null 2>&1; then
    v=$(node -v 2>/dev/null)
    [ -n "$v" ] && lang_out="${lang_out} via ${node_icon} ${v}"
  fi
fi
if [ -f "$cwd/.python-version" ] || [ -f "$cwd/pyproject.toml" ] \
   || [ -f "$cwd/requirements.txt" ] || [ -f "$cwd/setup.py" ] \
   || [ -f "$cwd/Pipfile" ] || ls "$cwd"/*.py >/dev/null 2>&1; then
  if command -v python3 >/dev/null 2>&1; then
    v=$(python3 -V 2>&1 | awk '{print $2}')
    [ -n "$v" ] && lang_out="${lang_out} via 🐍 v${v}"
  fi
fi

# ---- context remaining, colored by headroom --------------------------------
ctx_out=""
if is_num "$ctx_left"; then
  code=32                                   # green: plenty
  [ "$ctx_left" -lt 50 ] && code=33         # yellow: getting on
  [ "$ctx_left" -lt 20 ] && code=31         # red: nearly out
  paint "$code" "ctx ${ctx_left}%"; ctx_out="  ${_p}"
fi

# ---- session cost ----------------------------------------------------------
cost_out=""
[ -n "$cost_usd" ] && cost_out=$(printf '  $%.2f' "$cost_usd" 2>/dev/null)

# ---- 5h rate limit: silent until it starts to matter -----------------------
rate_out=""
if is_num "$rate5h" && [ "$rate5h" -ge "$RATE_LIMIT_AT" ]; then
  code=33
  [ "$rate5h" -ge 80 ] && code=31
  paint "$code" "5h ${rate5h}%"; rate_out="  ${_p}"
fi

# ---- model + effort + fast mode --------------------------------------------
[ "$SHORTEN_MODEL" = 1 ] && model="${model%% (*}"
mode_out=""
[ -n "$model" ]  && mode_out="  ${model}"
[ -n "$effort" ] && mode_out="${mode_out} ${effort}"
[ "$fast_mode" = "true" ] && mode_out="${mode_out} ⚡"

# ---- session name (set via /rename) ----------------------------------------
sess_out=""
if [ -n "$session" ]; then
  if [ "${#session}" -gt "$SESSION_MAX" ]; then
    session="${session:0:$SESSION_MAX}…"
  fi
  paint 90 "· ${session}"; sess_out="  ${_p}"
fi

# ---- assemble --------------------------------------------------------------
printf '%s\n' "${dir_out}${git_out}${lang_out}${ctx_out}${cost_out}${rate_out}${mode_out}${sess_out}"
