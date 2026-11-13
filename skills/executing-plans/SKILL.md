---
name: executing-plans
description: Execute a written implementation plan step-by-step with review checkpoints. Works with .plan.md plan files (YAML frontmatter + markdown body) wherever they are stored. Use when the user asks to execute or implement a plan, runs /implement-plan, or references a .plan.md file.
---

# Executing Plans

Load a plan, review it critically, execute tasks in order, keep the plan file's todos in sync, and report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

Pair with **`writing-plans`** for plan creation. Plans produced by `/writing-plans` use the same `.plan.md` format this skill executes.

> Conflict rule: rules already in this skill override the Linus-derived sections below (Verification gate, Deviation log, Self-review, External-impact stop rule). Shared severity and precedence: `review-my-code/severity.md` (same skills directory).

---

## Plan sources

Resolve the plan from, in order:

1. **Explicit path or attachment** — `@path/to/file.plan.md` or a path in the user message (commonly project `.cursor/plans/`, `.claude/plans/`, or another location)
2. **Client plan feature** — if the user invoked a plan-execution UI in their agent client, use that plan file
3. If ambiguous, ask which plan to run

### Expected plan format

Plan files use YAML frontmatter + markdown body:

```yaml
---
name: Feature Name
overview: One sentence
todos:
  - id: task-slug
    content: What to do
    status: pending   # pending | completed
isProject: false
---

# Feature Name
## 1. First task
- detailed steps...
```

Execute from **both** the frontmatter `todos` (for tracking) and the markdown body (for implementation detail). If body and todos disagree, raise with the user before coding.

---

## Step 1: Load and review

1. Read the full plan file.
2. Review critically — gaps, wrong assumptions, missing files, unsafe migrations.
3. If concerns exist: raise them with the user **before** writing code.
4. If no blockers: initialize tracking (Step 2) and proceed.

---

## Step 2: Initialize todo tracking

Create a todo list (the client's todo/task tool, e.g. `TodoWrite`) using **the exact `id` values** from the plan frontmatter:

```yaml
todos:
  - id: unify-parsing-logic      # ← use this id in TodoWrite
    content: Move parsing logic...
    status: pending
```

Rules:

- One todo item per frontmatter todo; `id` and `content` must match the plan.
- Skip todos already `status: completed` in the plan file.
- Do not invent extra todos unless the user approves a plan amendment.

### Keep the plan file in sync

When a task starts or finishes, update **both**:

| Action | TodoWrite | Plan file frontmatter |
|--------|-----------|----------------------|
| Start task | `in_progress` | optional; `pending` is fine |
| Finish task | `status: completed` | `status: completed` via `StrReplace` on that todo block |

Use surgical `StrReplace` on the plan file — preserve `name`, `overview`, `isProject`, and other todos. This keeps plan-file progress accurate for any client that reads it.

Example:

```
StrReplace old: "  - id: unify-parsing-logic\n    content: ...\n    status: pending"
         new: "  - id: unify-parsing-logic\n    content: ...\n    status: completed"
```

---

## Coordinator mode

Main agent = coordinator / DRI. It dispatches, verifies, and syncs the plan; it does not implement non-trivial todos itself.

- **Delegate by default:** each pending todo goes to the `plan-task-implementer` subagent (fresh context, default model). Inline only trivial todos (single file, a few lines).
- **Sequential by default** (shared working tree). Parallel only for todos with disjoint files and no ordering dependency.
- **Pointers, not content:** pass plan path, todo `id`, file paths, `git diff` ranges, deviations. Never paste plan text or file contents.
- **After each report:** inspect `git diff` of touched files, run plan-listed verifications via `test-verifier`, apply the Verification gate (Step 3), update TodoWrite + plan frontmatter, log deviations in `## Deviations`.
- **No workarounds:** reject a result that bypasses conventions; re-dispatch with the specific correction.
- **Strategic track (every todo):** collect the implementer's environment-improvement candidates. Do not act on them mid-plan; list them in the final summary as suggestions.
- **Retro:** when a subagent run failed, deviated, or needed a retry, write a short retro (what context/rule was missing) and route it via `capture-lessons` (agent behavior -> lessons/rule/skill; domain facts -> `forgetful-memory-updater`).

---

## Step 3: Execute tasks

For each **pending** todo, in frontmatter order:

1. Mark `in_progress` in TodoWrite.
2. Find matching section in the markdown body (by task number, heading, or `id` slug).
3. Dispatch to `plan-task-implementer` per Coordinator mode (or implement inline if trivial). Plan steps are followed exactly — files, code snippets, verifications.
4. **Tests:** If the plan includes optional test steps, confirm with the user that implementation is final before writing tests (unless the plan already states tests are in scope and approved).
   - **Delegate, don't inline:** run/verify tests via the `test-verifier` subagent (it returns only a compact verdict + root causes) and create new tests via the `test-writer` subagent (it follows the repo test skills and self-verifies). This keeps pytest output and test-file authoring out of the main agent's context. Running/verifying tests directly from the main agent pollutes the chat — always delegate per this rule, per the repo lessons file (see `capture-lessons`).
5. Run verifications/tests specified in the plan when present.
6. **Verification gate (Linus-derived):** mark `completed` only after plan-listed verifications pass, plus lint on touched files (`pre-commit run --files <touched files>`). Does not force new tests; the "confirm before tests" rule above wins.
7. Mark `completed` in TodoWrite **and** update the plan file frontmatter.

### Deviation log (Linus-derived)

If implementation must differ from the plan, do not change approach silently. Add a `## Deviations` section to the plan body (create it once) with one bullet per deviation: task id, what changed, why.

### External-impact stop rule (Linus-derived)

If a step would break an external consumer (FE-facing OpenAPI, partners, events, queued Celery task args) that the plan's External impact section does not list, stop and ask. Internal rewrites in scope need no stop.

Implementation-time layering rules:
- **Load the aggregate once** (with the correct load options) and pass the graph down — don't fetch as a void existence check, then query again by id.
- **KISS on concurrency.** Sequential external calls are fine until measured latency proves otherwise.

### Special todo: `update-forgetful-memory`

Do not call `create_memory` from the main agent. Instead:

1. Ensure implementation todos are verified.
2. Delegate to `forgetful-memory-updater` with verified facts and provenance.
3. Follow the `forgetful` skill (`lifecycle.md`, `hygiene.md`, `entities.md`) when applicable.
4. Mark the todo completed after the subagent reports success.

Skip this todo if absent (typical for small-scope plans).

---

## Step 4: Complete

After all todos are `completed`:

- Run any final test suite the plan specifies (via `test-verifier`).
- **Self-review (Linus-derived):** run a light pass of the `severity.md` decision tree on your own diff (`git diff`). Fix every Error before reporting done; list remaining Things to improve in the summary.
- **Elegance pass:** for non-trivial changes ask "is there a more elegant way?"; replace hacky parts before reporting. Skip for simple, obvious fixes.
- Summarize what changed (files, behavior), plus strategic-track suggestions and retros done.
- Offer next steps: review diff, run additional tests, commit (`/commit` only if user asks).
- Never commit unless the user explicitly requests it.

---

## When to stop

**Stop immediately** when:

- Blocker: missing dependency, repeated test failure, unclear instruction
- Critical plan gap prevents starting
- Verification fails after reasonable retry

Ask for clarification rather than guessing.

**Return to Step 1** when the user updates the plan or the approach needs rethinking.

---

## Self-review checklist

- [ ] Plan file read; concerns raised before coding if any
- [ ] TodoWrite ids match plan frontmatter ids
- [ ] Plan file `status` fields updated as tasks complete
- [ ] Markdown body steps followed for each todo
- [ ] `update-forgetful-memory` delegated to subagent (if present)
- [ ] No commits unless user asked
- [ ] Not on main/master without explicit consent
- [ ] Each completed todo passed its verifications + lint on touched files
- [ ] Deviations recorded in the plan body
- [ ] Self-review on own diff done; no Errors left
- [ ] Elegance pass done for non-trivial changes; no hacky parts left
- [ ] Non-trivial todos delegated to `plan-task-implementer`
- [ ] Retros done for failed/deviated/retried subagent runs
- [ ] Strategic suggestions listed in the final summary
