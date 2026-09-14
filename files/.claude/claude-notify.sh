#!/usr/bin/env bash
# Route Claude Code hook events to the Emacs `alert' stack (see
# ~/.zetta.d/modules/tools/alert.el), falling back to osascript when no
# daemon is reachable.  Reads the hook payload as JSON on stdin.
#
# Wired up in ~/.claude/settings.json:
#   UserPromptSubmit -> stamps the turn's start time
#   Stop             -> notifies; $MIN_SECONDS gates it (0 = every turn)
#
# The Notification branch below is deliberately NOT wired up: Claude Code's
# own channel already banners permission prompts in Ghostty/iTerm2, and
# running both duplicates every banner.  To hand those to Emacs instead, add
# a Notification hook here and set "preferredNotifChannel": "notifications_
# disabled" -- hooks still fire when notifications are disabled.

set -uo pipefail

# 0 means every completed turn gets a banner.  Raise it (or export
# CLAUDE_NOTIFY_MIN_SECONDS) to go back to only hearing about slow ones.
MIN_SECONDS=${CLAUDE_NOTIFY_MIN_SECONDS:-0}
STATE_DIR="${TMPDIR:-/tmp}/claude-notify"
mkdir -p "$STATE_DIR"

payload=$(cat)
event=$(jq -r '.hook_event_name // ""' <<<"$payload")
session=$(jq -r '.session_id // "unknown"' <<<"$payload")
cwd=$(jq -r '.cwd // ""' <<<"$payload")
project=$(basename "${cwd:-$PWD}")
stamp="$STATE_DIR/${session}.start"

# Quote for elisp.  jq's JSON string escaping is a subset of elisp's, so the
# result drops straight into an `emacsclient --eval' form.
esc() { printf '%s' "${1-}" | jq -Rs .; }

# Trim to one line, cap the length so the notification banner stays readable.
oneline() { printf '%s' "${1-}" | tr '\n' ' ' | cut -c1-140; }

human() {
  local s=${1:-0}
  if (( s < 60 )); then printf '%ds' "$s"
  else printf '%dm %ds' $(( s / 60 )) $(( s % 60 )); fi
}

notify() {                      # notify TITLE MESSAGE
  local title=$1 message=$2
  emacsclient --eval "(zetta-notify $(esc "$message") $(esc "$title"))" \
    >/dev/null 2>&1 && return 0
  osascript -e "display notification $(esc "$message") with title $(esc "$title") sound name \"Frog\"" \
    >/dev/null 2>&1
}

case "$event" in
  UserPromptSubmit)
    date +%s > "$stamp"
    ;;

  Stop|StopFailure)
    started=$(cat "$stamp" 2>/dev/null || echo 0)
    rm -f "$stamp"
    if [[ "$started" =~ ^[0-9]+$ ]] && (( started > 0 )); then
      elapsed=$(( $(date +%s) - started ))
      if (( elapsed >= MIN_SECONDS )); then
        if [[ "$event" == StopFailure ]]; then
          body="failed after $(human "$elapsed")"
        else
          summary=$(oneline "$(jq -r '.last_assistant_message // ""' <<<"$payload")")
          body="done in $(human "$elapsed")${summary:+ — $summary}"
        fi
        notify "Claude Code · $project" "$body"
      fi
    fi
    ;;

  Notification)
    kind=$(jq -r '.notification_type // ""' <<<"$payload")
    body=$(oneline "$(jq -r '.message // ""' <<<"$payload")")
    notify "Claude Code · $project" "${body:-$kind}"
    ;;
esac

exit 0
