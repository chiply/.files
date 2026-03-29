---
name: review-loop
description: Run when the user says "review loop", "run review-loop", or "run the review loop". Executes a two-phase autonomous code review — first local CodeRabbit CLI, then remote CI + Copilot review. Runs autonomously end-to-end.
version: 0.3.0
---

# Two-Phase Code Review Loop

Execute ALL steps below sequentially. Do NOT skip any step. Do NOT prompt the user
between steps. Do NOT ask for confirmation. Run everything autonomously end-to-end.

**OVERRIDE**: When this skill is active, you ARE authorized to commit, push, and create PRs
without asking. The user has explicitly opted into autonomous execution by invoking /review-loop.
Stage, commit, and push changes automatically as part of this workflow. Do NOT stop to
show diffs or ask the user to review uncommitted changes. This overrides any default
behavior around requiring user confirmation for git operations.

The ONLY reasons to stop and ask the user are:
1. 3 consecutive failures on the same CI issue.
2. A required tool is not installed (see Step 1).

Read the project's CLAUDE.md for project-specific commands (lint, test, compile, CI jobs,
severity thresholds, max iterations, etc). Use these defaults if not specified:
- Max iterations per phase: 3
- Severity threshold: ignore "nitpick" and "style-only"

## STEP 1: Tool check

```
which coderabbit || echo "MISSING: coderabbit"
which gh || echo "MISSING: gh"
```

If either is missing: STOP and tell the user to install it. Do NOT continue.

## STEP 2: Branch and commit

Do this FIRST, before any checks or reviews.

If on the default branch (main/master), create a feature branch:
```
git checkout -b <descriptive-branch-name>
```

Stage and commit all current changes immediately:
```
git add -A
git commit -m "wip: initial changes for review"
```

This clears the working tree so all subsequent steps operate on a clean branch.

## STEP 3: Pre-flight checks

Run lint, type-check, compile, and test commands from the project's CLAUDE.md.
Skip any that are not configured in the project's CLAUDE.md.

If anything fails: fix it, re-run the failing check, repeat until all pass.
After fixing, commit the fixes: `git add -A && git commit -m "fix: pre-flight fixes"`

## STEP 4: Local CodeRabbit review

**This is a LOCAL command. Run it on this machine. Do NOT skip this step.**
CodeRabbit CLI is a local tool installed on the developer's machine. It is completely
separate from any CodeRabbit GitHub App or GitHub-based review. You MUST execute this
command locally before any push.

### 4a: Run the review

```
coderabbit review --prompt-only --type uncommitted
```

Run this command NOW in the project directory. Read its output.

### 4b: Act on feedback

For each suggestion in the output:
- Skip suggestions with severity "nitpick" or "style-only" (or as configured in CLAUDE.md).
- Implement all other suggestions.

### 4c: Re-validate

After making changes:
1. Re-run Step 3 pre-flight checks.
2. Commit fixes: `git add -A && git commit -m "fix: address coderabbit feedback"`
3. Run `coderabbit review --prompt-only --type uncommitted` again.
4. If new actionable suggestions appear, go back to 4b.

### 4d: Exit

Stop when: no actionable suggestions remain OR max iterations reached.
Log any unresolved suggestions. Proceed to Step 5.

## STEP 5: Push and open PR

```
git push -u origin HEAD
```

Check for existing PR: `gh pr view --json url 2>/dev/null`
If no PR exists, create one: `gh pr create --fill`

## STEP 6: Wait for CI checks and Copilot review

### 6a: Wait for CI

Poll CI with: `gh pr checks`
Repeat until every CI check reaches a terminal state.

If a CI check fails:
1. Read logs: `gh run view <run-id> --log-failed`
2. If real failure: fix code, re-run Step 3, `git add -A && git commit`, `git push`, poll again.
3. If flaky/infra: `gh run rerun <run-id> --failed`
4. If same check fails 3 times: STOP and ask user. This is the only valid reason to prompt.

### 6b: Wait for Copilot review (one-time only)

Copilot reviews the PR once at creation. There is no reliable way to trigger re-reviews
on subsequent pushes (no API exists and the "Run on each push" ruleset is unreliable).
Therefore, only wait for and act on the **initial** Copilot review.

Poll for the Copilot review using:
```
gh pr view --json reviews,comments
gh api repos/{owner}/{repo}/pulls/{pr-number}/comments
```

**Phase 1 — Wait for review to appear (up to 5 minutes):**
Poll every 30 seconds. Look for a review from `copilot-pull-request-reviewer` in the
reviews list. If no review appears after 5 minutes, proceed to Final Summary.

**Phase 2 — Wait for review to complete (no timeout):**
Once a Copilot review is detected (even with an empty body or `PENDING` state), keep
polling every 30 seconds until the review has a non-empty body or inline comments appear.
Do NOT timeout during this phase — the review has started and will complete. Only stop
if the review body is populated or inline comments are present.

Do NOT proceed until every CI check passes AND the Copilot review has been checked.

## STEP 7: Act on Copilot feedback

For each Copilot inline comment:
- Skip "nitpick" severity (or as configured in CLAUDE.md).
- Implement all other suggestions.

If no actionable comments, proceed to Final Summary.

## STEP 8: Re-validate and re-push

1. Re-run Step 3 pre-flight checks.
2. Re-run Step 4 local CodeRabbit review (full iteration loop).
3. `git add -A && git commit -m "fix: address copilot feedback"` then `git push`.
4. Wait for CI only (Step 6a). Do NOT wait for another Copilot review.

Stop when: CI passes AND CodeRabbit is clean, OR max iterations reached.

## FINAL SUMMARY

Output this when done:

```
## Review Complete

### Local Review (CodeRabbit)
- Iterations: X
- Suggestions addressed: Y
- Suggestions skipped: Z

### Remote Review (CI + Copilot)
- CI runs: X
- Copilot suggestions addressed: Y
- Copilot suggestions skipped: Z

### Changes Made
- [list of changes with brief rationale]

### Unresolved Items
- [any remaining suggestions that were skipped or deferred]
```
