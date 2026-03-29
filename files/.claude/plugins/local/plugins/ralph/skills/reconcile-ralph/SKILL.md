---
name: reconcile-ralph
description: "Reconcile completed Ralph work back to design docs and backlog.org. Use after Ralph finishes executing stories. Triggers on: reconcile ralph, ralph done, sync design doc, update design doc from ralph."
user-invocable: true
version: 0.1.0
---

# Reconcile Ralph Results

After Ralph finishes executing stories, this skill reconciles the results
back to the source design documents and cleans up backlog.org.

This is an automated process — it uses the `sourceDesignDoc` and `sourceTaskId`
fields in prd.json to map completed stories back to their origin.

---

## Step 1: Locate completed prd files

Find prd.json files with completed stories:

1. Check `prd.json` in project root
2. Check `tasks/prd-*.json`
3. For each file, count stories where `passes: true`

If an argument was provided, operate on that specific file only.

Present a summary:

```
## Ralph Results to Reconcile

| PRD File | Design Doc | Completed | Remaining | Failed |
| tasks/prd-auth.json | docs/design/016-*.org | 4/5 | 0 | 1 |
| tasks/prd-dashboard.json | docs/design/016-*.org | 3/3 | 0 | 0 |
```

---

## Step 2: Update design doc tasks

For each story where `passes: true` in prd.json:

1. Read the `sourceDesignDoc` path from the prd file
2. Read the `sourceTaskId` from the story (e.g., `DAB-016-01`)
3. Find the matching task heading in the design doc: `** TODO [DAB-016-01]`
4. Update the org heading state from `TODO` to `DONE`:
   - Change `** TODO [DAB-016-01]` to `** DONE [DAB-016-01]`
5. Add properties to the task's property drawer:
   ```org
   :COMPLETED_BY: ralph
   :COMPLETED_AT: [YYYY-MM-DD]
   ```

**Important**: Do NOT modify any other org-mode data in the task:
- Preserve CLOCK entries, LOGBOOK drawers
- Preserve SCHEDULED, DEADLINE timestamps
- Preserve effort estimates, tags, all other properties
- Only change the TODO state and add completion properties

For stories where `passes: false`:
- Do NOT change the design doc task state
- Add the failure notes from prd.json to the task description:
  ```org
  Ralph failure notes: [content of notes field]
  ```

---

## Step 3: Check design doc completion

After updating all tasks, check if ALL tasks in the design doc's `* Tasks`
section are now `DONE`.

If yes:
1. Update `#+STATUS: Active` to `#+STATUS: Complete`
2. Add changelog entry: `- *[date]:* All tasks completed via Ralph`
3. If `docs/design/README.org` exists, update the status in the index table

If no:
- Report which tasks remain as TODO/WIP/HOLD
- These may be tasks excluded from Ralph (interactive tasks) or failed stories

---

## Step 4: Clean up backlog.org

If `backlog.org` exists:

1. Find the delegation entry: `*** WIP [Ralph] Design doc NNN`
2. If ALL prd stories passed:
   - Remove the delegation entry entirely
3. If SOME stories failed:
   - Update the entry to note failures:
     ```org
     *** HOLD [Ralph] Design doc NNN - Feature title (partial)
     :PROPERTIES:
     :DESIGN: [[file:docs/design/NNN-title.org][NNN Title]]
     :END:

     Ralph completed X/Y stories. Failed stories:
     - [TASK-ID]: [failure reason]

     Re-run /ralph to retry, or /backlog:task-queue to work interactively.
     ```

---

## Step 5: Archive prd files

For fully completed prd files (all stories passed):

1. Create archive directory: `archive/YYYY-MM-DD-[feature-name]/`
2. Move prd.json file(s) to archive
3. Move progress.txt (or progress-[feature].txt) to archive
4. These are now historical — the design doc is the permanent record

For partially completed prd files: leave them in place for re-running.

---

## Step 6: Present summary

```
## Ralph Reconciliation Complete

### Design Doc Updates
| Design Doc | Status | Tasks Updated |
| docs/design/016-*.org | Active → Complete | 7/7 DONE |

### backlog.org
- Removed delegation entry for design doc 016

### Archived
- tasks/prd-foundation.json → archive/2026-03-07-multi-agent/
- tasks/prd-commands.json → archive/2026-03-07-multi-agent/
- progress.txt → archive/2026-03-07-multi-agent/

### Remaining Work
- [list any TODO tasks still in the design doc]
- [list any failed stories that need retry or manual work]
```
