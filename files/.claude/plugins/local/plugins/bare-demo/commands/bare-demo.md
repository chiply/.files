---
description: Generate a bare-Emacs (emacs -Q) install + config demo for an Emacs package
argument-hint: [path-to-package-repo-or-dir]
allowed-tools: [Bash, Read, Write, Edit, Grep, Glob]
---

## Context

The user wants to scaffold a self-contained `demo/` for an Emacs package so it can
be smoke-tested in a stock `emacs -Q` with no dependency on their personal config.

Target package directory (defaults to the current directory if empty): $ARGUMENTS

## Instructions

Read the skill at `${CLAUDE_PLUGIN_ROOT}/skills/bare-demo/SKILL.md` and follow it to
generate `demo/demo-init.el`, `demo/run.sh`, and the `.gitignore` entries for the
target package, then verify the demo loads in a sandboxed batch Emacs. If no package
directory was given, confirm the current directory is the intended package repo.
