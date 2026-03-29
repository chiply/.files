---
name: design-to-prd
description: "Convert a dev-agent-backlog design document (.org) to Ralph prd.json format. Use when you have a design doc with tasks and want to run them through Ralph. Triggers on: convert design doc to prd, design to ralph, make prd from design doc, ralph from design doc."
user-invocable: true
version: 0.2.0
---

# Design Doc to prd.json Converter

Converts a dev-agent-backlog design document (org-mode) to one or more Ralph
prd.json files for autonomous execution.

## Prerequisites

- A design doc at `docs/design/NNN-*.org` with status `Accepted` or `Active`
- The design doc must have a `* Tasks` section with `** TODO [ID] Title` entries

If the design doc has status `Draft` or `Review`, warn the user that unresolved
questions (OPEN items) may lead to incomplete specifications. Suggest running
`/backlog:design-review` first.

---

## Step 1: Parse the design doc

Read the specified design doc and extract:

1. **Metadata**: Title, status, category from `#+TITLE:`, `#+STATUS:`, `#+CATEGORY:`
2. **Context**: Summary and Goals sections (used for prd description)
3. **Non-goals**: From the Non-Goals section
4. **Tasks**: All `** TODO [ID] Title` entries under `* Tasks` (see parsing rules below)
5. **Unresolved questions**: Any `** OPEN` entries under `* Questions`

### Org-mode feature parsing rules

Design doc tasks may use the full range of org-mode tracking features. Handle
each as follows:

**Properties to extract and map:**

| Org feature | Example | Handling |
|---|---|---|
| Priority cookies | `** TODO [#A] [ID] Title` | Map to priority: `[#A]`→1, `[#B]`→2, `[#C]`→3 |
| Priority tags | `:p0:`, `:p1:`, `:p2:` | Map to priority: p0→1, p1→2, p2→3 |
| Effort | `:EFFORT: M` | Use for humanReview heuristic (L→true). Preserve in notes. |
| Dependencies | `:BLOCKED_BY:`, `:WAITS_FOR:` | Translate to priority ordering |
| Checkboxes in body | `- [ ] criterion text` | Map directly to acceptanceCriteria entries |
| Description body | Plain text under heading | Use for story description and criteria generation |

If both a priority cookie (`[#A]`) and a priority tag (`:p0:`) are present,
the priority cookie takes precedence.

**Properties to ignore (do not break on these):**

| Org feature | Example | Why ignored |
|---|---|---|
| CLOCK entries | `:LOGBOOK:` drawer with `CLOCK:` lines | Time tracking — orthogonal to execution |
| SCHEDULED | `SCHEDULED: <2026-03-15 Sat>` | Date-based scheduling — Ralph executes by priority, not date |
| DEADLINE | `DEADLINE: <2026-03-20 Fri>` | Same — no date concept in prd.json |
| Repeaters | `+1w`, `.+2d` on timestamps | Not applicable to one-shot tasks |
| State change log | `:LOGBOOK:` with state change entries | Historical — not relevant to execution |
| Custom properties | Any `:PROPERTY:` not listed above | Skip silently |
| Inherited tags | Tags from parent headings | Only task-level tags matter |

**Properties to preserve in design doc but not convert:**

All org-mode tracking data (clocks, schedules, deadlines, state changes) stays
in the design doc untouched. The converter only READS the design doc to extract
task information — it does NOT modify org-mode tracking features. The design doc
remains the permanent record with full org-mode fidelity.

### Task state filtering

Only convert tasks with state `TODO`. Skip:
- `WIP` — already in progress (should be in backlog.org)
- `HOLD` — blocked (not ready for Ralph)
- `DONE` — already completed

---

## Step 2: Check for unresolved questions

If there are OPEN questions in the design doc:

1. Present them to the user
2. Ask: "These questions are unresolved. Ralph may make incorrect assumptions. Continue anyway, or resolve these first?"
3. If the user wants to resolve: suggest running `/backlog:design-review`
4. If the user wants to continue: note the open questions in the prd description

---

## Step 3: Determine parallelism

Analyze task dependencies to identify independent workstreams:

1. Build a dependency graph from `:BLOCKED_BY:` and `:WAITS_FOR:` properties
2. Identify connected components — groups of tasks linked by dependencies
3. Tasks with NO cross-component dependencies are independent workstreams

Ask the user: "I found N independent workstreams. Generate separate prd files for parallel execution?"

- If yes: generate one `tasks/prd-[feature]-[component].json` per workstream
- If no: generate a single `tasks/prd-[feature].json`

---

## Step 4: Map tasks to prd.json format

For each task in the design doc:

### ID mapping

Design doc IDs like `DAB-016-01` map to Ralph IDs like `US-001`.
Store the original design doc ID in `sourceTaskId` for automated reconciliation.

### Priority mapping

Priority is determined by (in order of precedence):

1. Org priority cookie: `[#A]`→1, `[#B]`→2, `[#C]`→3
2. Priority tag: `:p0:`→1, `:p1:`→2, `:p2:`→3
3. Dependency order: tasks that block others get lower numbers (run first)
4. Document order: tasks appearing earlier in the Tasks section

Within the same priority level, order by dependency (blockers first).

### Acceptance criteria generation

Design doc tasks may have explicit criteria (checkboxes) or just descriptions.

1. Extract any `- [ ] text` checkbox items → these become acceptanceCriteria directly
2. If no checkboxes: generate criteria from the task description text
3. Always add: "Typecheck passes" (if the project has typecheck configured)
4. For UI tasks (tagged `:frontend:` or description mentions UI): add browser verification
5. For elisp tasks (description mentions .el files): add emacs-eval verification

### Dependency handling

For a single prd file: translate `:BLOCKED_BY:` / `:WAITS_FOR:` into priority
ordering. If task B depends on task A, ensure A has a lower priority number
(runs first).

For multiple prd files: dependencies within a workstream become priority
ordering. Cross-workstream dependencies should not exist (if they do, merge
those workstreams into one prd).

### humanReview mapping

Default `humanReview: true` for:
- Tasks with `:EFFORT: L` (large effort — likely needs human verification)
- Tasks that are the last in a dependency chain (natural checkpoint)
- Tasks tagged `:review:` explicitly

Ask the user if they want to adjust these defaults.

---

## Step 5: Generate prd.json

### Branch name

Derive from the design doc title:
- `docs/design/016-multi-agent-coordination.org` → `ralph/multi-agent-coordination`

For multiple prd files, append the component:
- `ralph/multi-agent-coordination-foundation`
- `ralph/multi-agent-coordination-commands`

### Output format

```json
{
  "project": "[from README.org project prefix]",
  "branchName": "ralph/[derived-name]",
  "description": "[from design doc Summary section]",
  "sourceDesignDoc": "docs/design/NNN-title.org",
  "userStories": [
    {
      "id": "US-001",
      "sourceTaskId": "DAB-016-01",
      "title": "Task title",
      "description": "As a developer, I want [task description].",
      "acceptanceCriteria": ["Generated criterion 1", "Typecheck passes"],
      "priority": 1,
      "passes": false,
      "humanReview": false,
      "notes": ""
    }
  ]
}
```

The `sourceTaskId` field enables automated reconciliation back to the design doc.

### Save location

- Single prd: `tasks/prd-[feature].json`
- Multiple prds: `tasks/prd-[feature]-[component].json`

---

## Step 6: Update the design doc and backlog

After generating prd.json(s):

1. If the design doc status is `Accepted`, update to `Active`
2. Add a note to the design doc's Changelog:
   `- *[date]:* Generated Ralph prd.json for autonomous execution`
3. Do NOT modify any org-mode tracking data (clocks, schedules, etc.)

### backlog.org integration

If `backlog.org` exists in the project root, add a delegation entry to the
Active section so the backlog knows these tasks are under Ralph's control:

```org
*** WIP [Ralph] Design doc NNN - Feature title
:PROPERTIES:
:DESIGN: [[file:docs/design/NNN-title.org][NNN Title]]
:DELEGATED_TO: ralph
:PRD_FILES: tasks/prd-feature-a.json, tasks/prd-feature-b.json
:END:

Tasks from this design doc are being executed autonomously via Ralph.
Track progress in tasks/prd-*.json and progress.txt.
```

Do NOT check out individual tasks to backlog.org — prd.json is the working
surface for Ralph-executed tasks. The backlog entry is a pointer, not a
duplicate.

### Tasks NOT suitable for Ralph

If some tasks in the design doc are better suited for interactive work (e.g.,
tasks requiring extensive human judgment, exploratory research, or subjective
design decisions), exclude them from the prd.json and note them:

```
These tasks were excluded from Ralph and should be worked interactively
via the normal backlog workflow:
- [PROJECT-NNN-05] Design the user onboarding flow (subjective UX work)
- [PROJECT-NNN-09] Research authentication library options (exploratory)

Use /backlog:task-queue to check these out individually.
```

---

## Step 7: Present summary

Show the user:

```
## Design Doc → Ralph Conversion

Source: docs/design/NNN-title.org
Status: [status] → Active

### PRD Files Generated
| File | Branch | Stories | Description |
| tasks/prd-feature-a.json | ralph/feature-a | 5 | Component A |
| tasks/prd-feature-b.json | ralph/feature-b | 3 | Component B |

### Org-Mode Features Preserved
- Clock data: [X entries preserved in design doc]
- Schedules/Deadlines: [Y tasks had dates — ignored for Ralph ordering]
- Effort estimates: [mapped to humanReview where L]

### Dependency Resolution
- [list any dependency reordering done]

### Open Questions (unresolved)
- [list any OPEN questions from the design doc]

### Human Review Points
- US-003: [reason]
- US-007: [reason]

### Excluded (interactive work)
- [list any tasks excluded from Ralph]

Run `/ralph` to begin autonomous execution.
```
