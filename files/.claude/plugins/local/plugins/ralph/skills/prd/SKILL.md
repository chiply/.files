---
name: prd
description: "Generate a Product Requirements Document (PRD) for a new feature. Use when planning a feature, starting a new project, or when asked to create a PRD. Triggers on: create a prd, write prd for, plan this feature, requirements for, spec out."
user-invocable: true
version: 0.1.0
---

# PRD Generator

Create detailed Product Requirements Documents that are clear, actionable, and suitable for autonomous implementation by Ralph or manual development.

---

## The Job

1. Receive a feature description from the user
2. Ask 3-5 essential clarifying questions (with lettered options)
3. Generate a structured PRD based on answers
4. Save to `tasks/prd-[feature-name].md`

**Important:** Do NOT start implementing. Just create the PRD.

---

## Step 1: Clarifying Questions

Ask only critical questions where the initial prompt is ambiguous. Focus on:

- **Problem/Goal:** What problem does this solve?
- **Core Functionality:** What are the key actions?
- **Scope/Boundaries:** What should it NOT do?
- **Success Criteria:** How do we know it is done?

Format questions with lettered options so the user can respond with "1A, 2C, 3B" for quick iteration.

---

## Step 2: PRD Structure

Generate the PRD with these sections:

### 1. Introduction/Overview
Brief description of the feature and the problem it solves.

### 2. Goals
Specific, measurable objectives (bullet list).

### 3. User Stories
Each story needs:
- **Title:** Short descriptive name
- **Description:** "As a [user], I want [feature] so that [benefit]"
- **Acceptance Criteria:** Verifiable checklist

Each story must be small enough to implement in ONE context window (one Ralph iteration or one focused session).

**Story sizing rules:**
- Right-sized: "Add a database column and migration", "Add a UI component to an existing page"
- Too big: "Build the entire dashboard", "Add authentication" (split these)
- Rule of thumb: If you cannot describe the change in 2-3 sentences, it is too big.

**Story ordering:** Dependencies first (schema -> backend -> UI -> integration).

**Splitting into multiple PRDs for parallelism:**
If a feature has independent workstreams that can run concurrently, create a separate
PRD file for each. Each PRD becomes its own sequential workstream with its own branch.
Ralph runs them in parallel, each in an isolated worktree.

Ask the user: "Does this feature have independent parts that could be developed in
parallel?" If yes, generate multiple files:
- `tasks/prd-[feature]-[workstream-a].md`
- `tasks/prd-[feature]-[workstream-b].md`

Each PRD must be self-contained — stories within one PRD must not depend on stories
in another PRD. If they share dependencies, either:
- Put the shared dependency in one PRD and run the other after it completes
- Or duplicate the shared setup in both PRDs

When in doubt, keep it as a single PRD — correctness over speed.

**Acceptance criteria must be verifiable:**
- Good: "Button shows confirmation dialog before deleting"
- Bad: "Works correctly"
- Always include: "Typecheck passes"
- UI stories must include: "Verify in browser" (if browser tools available)

### 4. Functional Requirements
Numbered list: "FR-1: The system must allow users to..."

### 5. Non-Goals (Out of Scope)
What this feature will NOT include.

### 6. Design Considerations (Optional)
UI/UX requirements, mockup links, existing components to reuse.

### 7. Technical Considerations (Optional)
Known constraints, integration points, performance requirements.

### 8. Success Metrics
How success is measured.

### 9. Open Questions
Remaining areas needing clarification.

---

## Output

- **Format:** Markdown (`.md`)
- **Location:** `tasks/`
- **Filename:** `prd-[feature-name].md` (kebab-case)

---

## Checklist

Before saving the PRD:

- [ ] Asked clarifying questions with lettered options
- [ ] Incorporated user's answers
- [ ] User stories are small and specific (one context window each)
- [ ] Stories ordered by dependency
- [ ] Functional requirements are numbered and unambiguous
- [ ] Non-goals section defines clear boundaries
- [ ] Every story has "Typecheck passes" as criterion
- [ ] UI stories have browser verification criterion
- [ ] Saved to `tasks/prd-[feature-name].md`
