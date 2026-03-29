---
description: Run the Ralph autonomous agent loop to implement PRD stories using isolated subagents
argument-hint: [prd-file-or-options]
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep, Agent]
---

## Context

The user wants to run the Ralph autonomous loop on their current project.

## Instructions

Read the skill at `${CLAUDE_PLUGIN_ROOT}/skills/ralph/SKILL.md` and execute it
end-to-end. Read the project's CLAUDE.md for project-specific commands (lint, test,
compile, etc). Do NOT prompt the user between steps unless a story has `humanReview: true`.

If an argument was provided: $ARGUMENTS
