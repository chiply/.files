---
description: Run the two-phase code review loop (local CodeRabbit + remote CI/Copilot)
argument-hint: []
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep]
---

## Context

The user wants to run the autonomous two-phase code review loop on their current changes.

## Instructions

Read the skill at `${CLAUDE_PLUGIN_ROOT}/skills/review-loop/SKILL.md` and execute it
end-to-end. Read the project's CLAUDE.md for project-specific commands (lint, test,
compile, CI jobs, etc). Do NOT prompt the user between steps.
