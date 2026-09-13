#!/usr/bin/env bash
# Append one plist line per Claude Code landing to the org-chain log.
#
# Wired in ~/.claude/settings.json for the Stop and Notification events
# beside claude-notify.sh.  This script only appends: no emacsclient, no
# elisp, no banner.  Emacs watches the file (org-chain-watch) and
# transitions the entry whose AGENT_SESSION matches -- AGENT to NEXT on
# a stop, to QUES on a question.  A line for a session no entry knows
# is reported there as an orphan, never dropped here.
#
# The line is an elisp plist the reader parses with `read':
#   (:session "UUID" :at 1789000000 :cwd "/path" :event stop :text "...")

set -uo pipefail

LOG="${ORG_CHAIN_LANDINGS:-$HOME/.zetta.d/.data/org/agent-landings.el}"
mkdir -p "$(dirname "$LOG")"

payload=$(cat)
event=$(jq -r '.hook_event_name // ""' <<<"$payload")
session=$(jq -r '.session_id // ""' <<<"$payload")
cwd=$(jq -r '.cwd // ""' <<<"$payload")
[ -n "$session" ] || exit 0

case "$event" in
  Stop|StopFailure)
    kind=stop
    text=$(jq -r '.last_assistant_message // ""' <<<"$payload" | tr '\n' ' ' | cut -c1-200)
    ;;
  Notification)
    kind=question
    text=$(jq -r '.message // .notification_type // ""' <<<"$payload" | tr '\n' ' ' | cut -c1-200)
    ;;
  *) exit 0 ;;
esac

# jq's string escaping is a subset of elisp's, so the quoted strings
# drop straight into a plist.
esc() { printf '%s' "${1-}" | jq -Rs . | tr -d '\n'; }
printf '(:session %s :at %d :cwd %s :event %s :text %s)\n' \
  "$(esc "$session")" "$(date +%s)" "$(esc "$cwd")" "$kind" "$(esc "$text")" >> "$LOG"
exit 0
