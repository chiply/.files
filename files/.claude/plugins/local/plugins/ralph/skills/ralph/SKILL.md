---
name: ralph
description: "Run the Ralph autonomous agent loop natively within Claude Code using subagents. Processes one or more prd.json files, each as a sequential workstream. Multiple PRDs run in parallel using isolated worktrees. Triggers on: run ralph, ralph loop, start ralph, execute prd, autonomous loop."
user-invocable: true
version: 0.2.0
---

# Native Ralph Loop

Execute PRD stories autonomously using subagents with worktree isolation. Each story
gets a fresh context window (subagent) and an isolated git worktree, preserving the
core Ralph properties: fresh context per iteration, memory via git + progress files.

**Parallelism model**: One prd.json file = one sequential workstream. To parallelize,
create multiple prd files. Each runs as an independent subagent in its own worktree.

**OVERRIDE**: When this skill is active, you ARE authorized to commit, push, and merge
worktree branches without asking. The user has explicitly opted into autonomous execution
by invoking /ralph.

The ONLY reasons to stop and ask the user are:
1. A story has `humanReview: true` — STOP and present changes for manual verification.
2. 3 consecutive failures on the same story.
3. Required tools are missing.

---

## STEP 1: Locate PRD files

Look for prd files in these locations (in order):
1. `prd.json` in the project root (single workstream)
2. `tasks/prd-*.json` (multiple workstreams — each file is one parallelizable unit)
3. `scripts/ralph/prd.json` (legacy single workstream)

If multiple `tasks/prd-*.json` files exist, each represents an independent workstream
that can run in parallel.

If no prd files exist but PRD markdown files exist in `tasks/`:
1. Ask the user which PRD(s) to convert
2. Convert each to its own `tasks/prd-[feature-name].json`

If nothing exists: STOP and tell the user to run `/prd` first.

### prd.json format

```json
{
  "project": "ProjectName",
  "branchName": "ralph/feature-name",
  "description": "Feature description",
  "userStories": [
    {
      "id": "US-001",
      "title": "Story title",
      "description": "As a [user], I want [feature] so that [benefit]",
      "acceptanceCriteria": ["Criterion 1", "Typecheck passes"],
      "priority": 1,
      "passes": false,
      "humanReview": false,
      "notes": ""
    }
  ]
}
```

Each prd file gets its own `branchName`. Stories within a single prd file execute
sequentially by priority (later stories may depend on earlier ones).

---

## STEP 2: Determine execution mode

- **Single PRD**: Execute stories sequentially in the current worktree (STEP 3-SINGLE).
- **Multiple PRDs**: Execute each PRD as a parallel workstream (STEP 3-MULTI).

---

## STEP 3-SINGLE: Single workstream execution

### 3s-a: Initialize progress tracking

If `progress.txt` does not exist, create it:

```
# Ralph Progress Log
Started: [current date/time]
Tool: Claude Code (native subagent mode)
PRD: [prd filename]

## Codebase Patterns
[populated by iterations as patterns are discovered]
---
```

If it exists, read the **Codebase Patterns** section — this is critical context for subagents.

### 3s-b: Ensure correct branch

Check the `branchName` from prd.json. If not on that branch:

```bash
git checkout -b <branchName> 2>/dev/null || git checkout <branchName>
```

### 3s-c: Iterate through stories

For each story in `userStories` where `passes: false`, in priority order:

**Human review gate**: If the story has `humanReview: true`:
1. Present the story details to the user
2. Summarize all changes made so far (stories completed, files modified)
3. Ask: "This story requires manual verification. Please test and confirm, then reply 'continue' to proceed."
4. STOP and wait for user response. Do NOT proceed until confirmed.

**Build subagent prompt**: See SUBAGENT PROMPT section below.

**Spawn subagent**:
```
Agent(
  prompt: [constructed prompt],
  isolation: "worktree",
  description: "Ralph: [Story ID] - [Story Title]"
)
```

**Process result**:
1. Parse the final line for SUCCESS or FAILURE
2. **On SUCCESS**:
   - Merge the worktree branch: `git merge <worktree-branch>`
   - Update prd.json: set `passes: true` for this story
   - Extract the progress report and append to `progress.txt`
   - Extract any codebase patterns and add to the Codebase Patterns section
   - Commit the prd.json and progress.txt updates
3. **On FAILURE**:
   - Log the failure in progress.txt
   - Add failure notes to the story's `notes` field in prd.json
   - Increment failure counter for this story
   - If 3 consecutive failures: STOP and ask user for help
   - Otherwise: retry with the failure context added to the prompt

**Check completion**: If ALL stories have `passes: true`, go to FINAL SUMMARY.
Otherwise continue to next story.

---

## STEP 3-MULTI: Parallel workstream execution

When multiple prd files are found, each runs as an independent workstream.

### 3m-a: Present the plan

Show the user what will run in parallel:

```
## Ralph: Parallel Workstreams

| # | PRD File | Branch | Stories | Description |
| 1 | tasks/prd-auth.json | ralph/auth | 4 stories | Authentication system |
| 2 | tasks/prd-dashboard.json | ralph/dashboard | 3 stories | Dashboard widgets |

Each workstream runs in its own isolated git worktree.
Proceed? (reply 'go' or specify which PRDs to run)
```

Wait for user confirmation. The user may choose to run a subset.

### 3m-b: Spawn workstream subagents

For EACH selected prd file, spawn a subagent **in parallel** — include all Agent
tool calls in a single response:

```
Agent(
  prompt: [workstream prompt — see below],
  isolation: "worktree",
  run_in_background: true,
  description: "Ralph workstream: [prd filename]"
)
```

The workstream prompt instructs the subagent to:
1. Read its assigned prd file
2. Execute all stories sequentially (the full single-workstream loop)
3. Create a `progress-[feature-name].txt` for its workstream
4. Commit all changes on its `branchName`
5. Output a final summary

The workstream subagent prompt:

```
You are an autonomous coding agent running a Ralph workstream.

## Your PRD
[full contents of the prd.json file]

## Project Context
[contents of project CLAUDE.md]

## Codebase Patterns (from previous work)
[contents of progress.txt Codebase Patterns section, if exists]

## Instructions

Execute ALL stories in this PRD sequentially, in priority order.

For each story where passes: false:
1. Implement the story
2. Run quality checks: [commands from CLAUDE.md]
3. If checks pass: git add -A && git commit -m "feat: [ID] - [title]"
4. If checks fail: fix and retry (max 3 attempts per story)

After each story, output a progress entry:
---PROGRESS---
## [Story ID] - [Story Title]
- What was implemented: [description]
- Files changed: [list]
- Learnings: [patterns, gotchas]
---END-PROGRESS---

If a story has humanReview: true, implement it but do NOT mark passes: true.
Instead output: NEEDS-REVIEW: [Story ID] - [what to verify]

After all stories are processed, output:
---WORKSTREAM-SUMMARY---
PRD: [filename]
Branch: [branchName]
Stories completed: X/Y
Stories needing review: [list of IDs]
Codebase patterns discovered: [list]
---END-WORKSTREAM-SUMMARY---
```

### 3m-c: Collect results

As each background workstream completes, collect its result.
When ALL workstreams complete:

1. Present a consolidated summary to the user
2. List any stories that need human review (humanReview: true)
3. List any failed stories across all workstreams
4. Ask the user how to proceed:
   - "merge all" — merge all workstream branches into the main branch
   - "merge [branch]" — merge specific workstreams
   - "review [branch]" — inspect a specific workstream before merging
   - "retry [prd]" — re-run a failed workstream

### 3m-d: Merge workstreams

For each workstream the user approves:

```bash
git merge <workstream-branch>
```

If merge conflicts occur between workstreams:
1. STOP and present the conflict to the user
2. The two workstreams touched the same files — this means they were not truly independent
3. Ask the user to resolve or to re-run one workstream on top of the other

After merging, run quality checks on the combined result.

---

## SUBAGENT PROMPT (for single-story subagents)

```
You are an autonomous coding agent working on a single user story.

## Your Story
ID: [id]
Title: [title]
Description: [description]
Acceptance Criteria:
[criteria list]

## Codebase Patterns (from previous iterations)
[patterns from progress.txt]

## Recent Progress (context from previous iterations)
[last 3 progress entries]

## Instructions
1. Implement this single user story
2. Run quality checks: [commands from CLAUDE.md]
3. If checks pass, commit ALL changes: git add -A && git commit -m "feat: [ID] - [title]"
4. Write a progress report (see format below)
5. If you discover reusable codebase patterns, note them clearly

## Progress Report Format
Output this at the end:
---PROGRESS---
## [Story ID] - [Story Title]
- What was implemented: [description]
- Files changed: [list]
- Learnings for future iterations:
  - [patterns discovered]
  - [gotchas encountered]
---END-PROGRESS---

## Final Status
Output exactly one of these as the very last line:
SUCCESS
FAILURE: [reason]
```

---

## FINAL SUMMARY

When all stories pass (or max iterations reached), output:

```
## Ralph Complete

### Stories Completed
| ID | Title | Status | Workstream |
[table of all stories with pass/fail status]

### Iterations
- Total subagents spawned: X
- Successful: Y
- Failed: Z
- Human reviews: W

### Codebase Patterns Discovered
[consolidated patterns from progress.txt]

### Files Modified
[aggregate list of all files changed across all stories]

### Unresolved Items
[any stories still failing, with failure reasons]
```

---

## Post-Completion

After the final summary, if ANY prd file has a `sourceDesignDoc` field:

1. Ask the user: "Ralph is complete. Run `/reconcile-ralph` to update the
   source design doc(s) and clean up backlog.org?"
2. If yes: invoke the reconcile-ralph skill
3. If no: remind the user to reconcile later

Then, if a review-loop skill is available:

4. Ask: "Run `/review-loop` for a final code review before creating a PR?"

---

## Integration with Other Skills

- If the project has a review-loop skill, run `/review-loop` AFTER all stories pass
  to do a final code review before the PR is created.
- If the project has an emacs-eval skill and stories modify .el files, include
  emacs-eval verification in the subagent prompt.
- If Playwright MCP is available and stories modify UI, include browser verification
  instructions in the subagent prompt.
