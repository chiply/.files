#!/usr/bin/env bash
#
# Wire the Claude Code notification hooks into ~/.claude/settings.json.
#
# The script itself (files/.claude/claude-notify.sh) is symlinked by main.py
# like any other dotfile, but the settings entry that *invokes* it cannot be:
# settings.json also carries machine- and account-specific keys (env, model,
# effortLevel, enabledPlugins, extraKnownMarketplaces, theme), so the file is
# deliberately untracked.  This merges in just the two hook entries and leaves
# every other key untouched.
#
# Idempotent: re-running replaces the claude-notify entries rather than
# stacking duplicates, so it is safe to call from bootstrap.sh every time.

set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"
# Resolved now rather than left as a literal $HOME, so the value in the JSON
# never depends on how Claude Code chooses to invoke the command.
SCRIPT="$HOME/.claude/claude-notify.sh"

command -v jq >/dev/null || { echo "install_claude_hooks: jq not found" >&2; exit 1; }

mkdir -p "$(dirname "$SETTINGS")"
[[ -f "$SETTINGS" ]] || printf '{}\n' > "$SETTINGS"

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

jq --arg cmd "$SCRIPT" '
  # Drop any previous claude-notify entries, then drop hook groups left empty,
  # so re-running is a replace rather than an append.
  def without_notify:
    (. // [])
    | map(.hooks |= map(select((.command // "") | test("claude-notify\\.sh") | not)))
    | map(select((.hooks | length) > 0));

  .hooks //= {}
  # UserPromptSubmit stamps the turn start time; Stop reads it and notifies.
  # Stop is async so a slow notification never delays the turn ending.
  | .hooks.UserPromptSubmit =
      (.hooks.UserPromptSubmit | without_notify)
      + [{ hooks: [{ type: "command", command: $cmd }] }]
  | .hooks.Stop =
      (.hooks.Stop | without_notify)
      + [{ hooks: [{ type: "command", command: $cmd, async: true }] }]
' "$SETTINGS" > "$tmp"

# Only overwrite once jq has produced valid JSON.
jq -e . "$tmp" >/dev/null
cat "$tmp" > "$SETTINGS"

echo "install_claude_hooks: wired $SCRIPT into $SETTINGS"
