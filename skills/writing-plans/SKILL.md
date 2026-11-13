---
name: writing-plans
description: Create implementation plans for multi-step tasks before writing code. Clarifies ambiguities with the user, classifies scope, optionally integrates Forgetful MCP memory for large features. Use when the user asks for an implementation plan, feature plan, or runs /writing-plans.
---

# Writing Plans

Apply the `concise-english` skill to all plan prose (STE-flavored mode).

Pair with **`executing-plans`** for implementation: plans from this skill are executed with the **`executing-plans`** skill (same skills directory), which loads the plan, syncs todos, runs tasks in order, and records deviations. Write plans in the format `executing-plans` expects (YAML frontmatter `todos` + markdown body), and mention in the plan that it should be executed with `/executing-plans`.

> Conflict rule: rules already in this skill override the Linus-derived sections below (Data model first, External impact, Structure-first option, Bisectable tasks, Rejected alternatives, Risk / rollback).

Precedence when choosing an approach: **correctness > simplicity / good structure > overall stability > performance** (see `review-my-code/severity.md`, same skills directory). Performance only matters when the task asks for it.

Create a comprehensive implementation plan **before writing code**. Assume the engineer has zero context — document files to touch, code to write, and how to verify.

## Forgetful delegation (do not re-implement)

| Phase | Delegate to | Purpose |
|-------|-------------|---------|
| Pre-plan retrieval | Subagent `forgetful-memory-retriever` | Surface relevant memories without bloating main context |
| Graph exploration | Skill `forgetful` ([explore.md](../forgetful/explore.md)) | When recall is fragmented (retriever escalates) |
| Retrieval mechanics | Skill `forgetful` ([memory.md](../forgetful/memory.md)) | `query_memory` / `get_memory` (subagent only) |
| Post-implementation persistence | Subagent `forgetful-memory-updater` | Create/update/link/obsolete/entity after feature is verified |
| Entity modelling | Skill `forgetful` ([entities.md](../forgetful/entities.md)) | Model services/components at capture time (updater) |
| Cleanup mechanics | Skill `forgetful` ([hygiene.md](../forgetful/hygiene.md)) | Dedupe, obsolescence, linking (subagent only) |
| Lifecycle rules | Skill `forgetful` ([lifecycle.md](../forgetful/lifecycle.md)) | When to engage / skip Forgetful |

## Example-data delegation

When the plan needs real DB examples (sample rows, table/column verification, edge-case data), delegate to a subagent (e.g. `generalPurpose`) instead of querying MCP/DB from the main agent. Ask it for a compact Summary/Data/Notes digest that keeps main context brief.

```
Task(
  subagent_type="generalPurpose",
  prompt="Gather examples for planning: <tables/domain>. Need: <columns, filters, sample size>. Purpose: <plan task that uses the data>.",
  run_in_background=true
)
```

Use gathered examples in plan tasks (e.g. realistic fixtures, edge-case rows, verified column names) and cite them as the source.

---

## Step 0: Clarify before planning (mandatory)

**Do not write the final plan until requirements are clean and unambiguous.**

1. Parse the user's request and explore the relevant codebase. If a brainstorm brief exists (path passed, or latest `tmp/brief-*.md` matching the feature), read it first: carry its goals, non-goals, and key decisions forward; reuse "Alternatives weighed" as **Rejected alternatives**; treat its open questions as clarification items.
2. Identify **problematic or unclear** areas:
   - Ambiguous requirements or missing acceptance criteria
   - Unclear ownership between services/modules
   - Edge cases, migration risks, or breaking-change surfaces
   - Contradictions between the prompt and existing code behavior
   - Open questions about scope, rollout, or backwards compatibility
3. **Ask the user** targeted questions about each unclear point. Use `AskQuestion` when it fits; otherwise ask conversationally.
4. Repeat until every important decision is resolved. Summarize agreed decisions briefly before proceeding.
5. **Ask whether tests should be included in the plan.** Recommended default: **integration tests only** (repo convention for meaningful behavior coverage). Respect the user's choice — if they decline tests, omit test steps from the plan.
6. **Structure-first option (Linus-derived).** If the touched area is poorly structured, offer two variants through `AskQuestion`: "rewrite" (cleaner structure) and "minimal" (local change). Recommend "rewrite" when it simplifies the code. The plan follows the chosen variant.

Only after clarification is complete, proceed to scope classification and the final plan.

---

## Step 1: Classify scope

Determine plan size before choosing format:

| Scope | Examples | Full header + Mermaid | Forgetful memory |
|-------|----------|----------------------|------------------|
| **Small** | Refactor, rename, restructure, move files, narrow bugfix | Not required | Skip unless durable domain knowledge changes |
| **Large** | New feature, new workflow, cross-module change, significant logic change | Required | Retrieve before plan; post-implementation section in plan |

When unsure, treat as **large**.

---

## Step 2: Retrieve domain memory (large scope only)

For **new features** or **bigger changes to existing logic**, retrieve before writing the final plan.

Skip for small refactors/restructuring unless the task touches unfamiliar domain knowledge.

**Never launch the retriever in Ask mode** — MCP calls are blocked there and retrieval always fails (`None retrieved`). In Ask mode, skip this step, note the deferral to Agent mode, and plan without memory.

1. Launch the retriever subagent immediately (non-blocking):

```
Task(
  subagent_type="forgetful-memory-retriever",
  prompt="Feature: <name>. Goal: <goal>. Repo: <owner/repo>. Surface memories relevant to <domain/components/files/services>. Use multiple query angles; escalate to graph exploration if fragmented. Return digest: memory IDs, entity IDs, titles, key facts, gaps.",
  run_in_background=true
)
```

1. While retrieval runs, continue codebase exploration as needed.
2. When the digest returns, incorporate it into planning:
   - Cite relevant memory IDs and facts that affect design.
   - Note **gaps** — candidates for post-implementation capture.
3. If retrieval finds nothing relevant, state that explicitly and continue.

---

## Step 3: Write the final plan

### Plan document header (large scope only)

For **large** plans, start with this header (include a Mermaid architecture diagram):

```
# [Feature Name] Implementation Plan

**Goal:** [One sentence]
**Architecture:** [2-3 sentences]
**Architecture Diagram:** (mermaid graph TD)
**Tech Stack:** [Key technologies]
**Relevant Forgetful memories:** [IDs and one-line facts from Step 2, or "None found" / "Skipped — small scope"]
```

For **small** plans, a short title and bullet list of steps is enough. No Mermaid diagram required.

### Design sections (Linus-derived)

Put these before the tasks:

- **Data model first** (all scopes when models change): list new or changed domain models, DB columns, DTOs, and their relations. Tasks derive from this list. Prefer a model change that removes special-case branches over adding branches.
- **External impact** (large scope only): changes visible to FE, partners, events, or queued Celery messages, plus the migration strategy (nullable column, dual-read, deprecation). Internal rewrites need no compatibility plan; write "None" when nothing external changes.
- **Rejected alternatives** (large scope; 1-3 bullets): each with one-line "why not". Rank by correctness, then simplicity, then stability. Mention performance only if the task asks for it.
- **Risk / rollback** (when migrations or behavior changes exist): what can go wrong and how to revert.

**Optional visual plan (large scope):** if the user wants a standalone visual artifact, also render the plan with the `html-diagrams` skill via its `modes/plan.md` mode (offline HTML, `~/.agent/diagrams/`). The markdown plan stays the source of truth; keep its Mermaid diagram.

### Task structure

Break into bite-sized, independent tasks. Use this template per task:

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `test/integration/exact/path/to/test.py` (optional)

- [ ] **Step 1: Write the implementation**
(include exact code snippets when they clarify non-obvious changes)

- [ ] **Step 2: (Optional) Write tests**
(only if user agreed in Step 0; prefer integration tests)

- [ ] **Step 3: (Optional) Run tests to verify**
Run: `pytest test/integration/path/test.py::test_name -v`
Expected: PASS
```

### Strict rules

- Never include commit steps unless the user explicitly asks.
- Include a Mermaid diagram only for **large** scope plans.
- Include code snippets where they reduce ambiguity.
- **No placeholders:** Every step must contain actionable content. Never write "TBD", "TODO", "implement later", "add error handling" without showing the code, or "similar to Task N".
- Save the plan to the repo's plan location when it uses plan files (e.g. `.cursor/plans/<feature_slug>.plan.md` or `.claude/plans/`).
- **Bisectable tasks (Linus-derived):** each task leaves the repo green (lint passes, existing tests pass). No task depends on a later task to import or run.
- **Verification per task:** each task names a verification command (lint, targeted test, or manual check).

## Layering rules (apply when designing tasks)

1. **Handlers adapt, workflows compute.** Map domain results to response DTOs at the external boundary (handler/edge). Workflows and services return domain data, never API DTOs.
2. **Domain stays domain-shaped.** Storage paths, IDs, money, etc. keep their domain form until the boundary adapts them for the client.
3. **No `dict[str, …]` as a data model.** Use typed models (per repo convention). Lists of primitives on fields are fine; keyed bags passed between layers are not.
4. **Prefer existing domain models over raw ORM entities.** ORM/persistence objects stay behind persistence helpers; workflows consume domain models.
5. **Load the aggregate once.** Load it (with correct options) at the boundary and pass the graph down — don't do void existence checks then re-query by id.
6. **Compose nested results.** Parent-level results compose per-child outputs; don't re-flatten sources into a second ad-hoc bag.
7. **KISS on concurrency.** Sequential external calls until measured latency proves parallelism is needed.

Plans should structure tasks so these boundaries hold (e.g. separate handler/adaptation steps from workflow/domain steps).

### Plan frontmatter (when using plan files, `*.plan.md`)

Add `update-forgetful-memory` only for **large** scope:

```yaml
---
name: [Feature Name]
overview: [One sentence]
todos:
  - id: task-1
    content: [First implementation task]
    status: pending
  - id: update-forgetful-memory
    content: Persist verified feature decisions to Forgetful MCP via forgetful-memory-updater
    status: pending
isProject: false
---
```

Omit the `update-forgetful-memory` todo for small-scope plans.

---

## Step 4: Forgetful memory section (large scope only)

For **new features** or **bigger changes to existing logic**, end the plan with a **Forgetful Memory (post-implementation)** section that:

1. States memory should be updated **after** implementation is verified (not during planning).
2. Lists candidate memories: decisions/invariants from the plan + gaps from Step 2 retrieval.
3. References delegation to `forgetful-memory-updater`, hygiene and entities via the `forgetful` skill (`hygiene.md`, `entities.md`) when memories concern modelled systems.
4. Includes provenance: `source_repo`, `source_files`, `source_url`, `confidence`.
5. Requires re-running `query_memory` after persistence to verify discoverability.

Post-implementation invocation:

```
Task(
  subagent_type="forgetful-memory-updater",
  prompt="Feature <name> shipped. Verified facts:\n- <fact>\nSources: <files/PR URL>. Dedupe; route type; create/update atomic entries; link related and entities; mark obsolete if needed."
)
```

Do **not** call `create_memory` from the main agent during planning.

Skip this section entirely for small refactors/restructuring.

---

## Self-review checklist

Before finishing, verify:

- [ ] Ambiguities were surfaced and resolved with the user before the final plan
- [ ] User was asked whether tests should be included (integration tests recommended)
- [ ] Scope classified as small or large; format matches
- [ ] For large scope: `forgetful-memory-retriever` launched and memories cited (or none found)
- [ ] For large scope: Mermaid diagram and **Forgetful Memory** section present
- [ ] For large scope: `update-forgetful-memory` todo in frontmatter (when using plan files)
- [ ] No placeholders; code snippets included where needed
- [ ] No commit steps unless user requested them
- [ ] Data model listed first when models change
- [ ] For large scope: External impact, Rejected alternatives present
- [ ] Risk / rollback present when migrations or behavior changes exist
- [ ] Plan mentions execution via `executing-plans` skill
- [ ] Every task has a verification command and leaves the repo green
- [ ] No special-case branch that a model change would remove
- [ ] If a brief was used: every place where the plan contradicts a brief decision is listed (quote both) and the user decided each one. Do not silently align either side — the plan may be right because it read more code.
- [ ] Plan suggests `/review-plan <plan path>` before `/implement-plan` for large scope
