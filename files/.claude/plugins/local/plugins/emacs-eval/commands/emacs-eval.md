---
description: Evaluate elisp in the running Emacs daemon
argument-hint: [elisp-expression-or-instruction]
allowed-tools: [Bash]
---

## Context

The user wants to evaluate elisp in their running Emacs daemon.

User's request: $ARGUMENTS

## Instructions

Read the skill at `${CLAUDE_PLUGIN_ROOT}/skills/emacs-eval/SKILL.md` and follow its instructions to accomplish the user's request. If no specific expression was provided, ask the user what they want to evaluate.
