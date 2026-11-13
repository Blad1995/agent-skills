---
name: migrate-and-prune-code
description: Migrate or rewrite old code to a new module while pruning dead branches and deduplicating years of bloat. Use when porting legacy code (e.g. monolith → modern service), decoupling from legacy helpers, or rewriting an adapter to a simpler form.
---

# Migrate and Prune Code

Guide for migrations that are also simplifications: port behavior, not code. The old code carries years of bloat; the migration is the chance to drop it. First plan is usually wrong — iterate on the domain model before writing code.

## Core principles

1. **Port behavior, not code.** Never copy legacy code line-by-line. Understand what it *does*, then express it minimally in the new design.
2. **First draft is wrong.** Expect the initial domain model / API schema to be over-engineered or shaped like the legacy data. Budget 2–3 iterations of simplification before code feels right. This is normal — do not commit to the first plan.
3. **Prune before you port.** Dead branches, defensive handling for data that no longer exists, and fallbacks nobody hits should be dropped — but only after verification (below).
4. **Deduplicate.** If the legacy code re-implements an existing helper/converter/model, reuse the existing one instead of porting the duplicate.
5. **No `dict[str, …]` as a data model.** Use typed models (per repo convention) in the new design. Lists of primitives on fields are fine; keyed bags passed between layers are not.
6. **Prefer existing domain models over raw ORM entities.** ORM/persistence objects stay behind persistence helpers; the new module consumes domain models.
7. **Compose nested results.** Parent-level results compose per-child outputs; don't re-flatten sources into a second ad-hoc bag.

## Workflow

### Phase 1: Understand the behavior (before planning)

- Read the legacy code end-to-end and list its *observable behaviors*: outputs, side effects, error/edge cases, ordering rules.
- Identify existing modern helpers/models/converters that cover part of the behavior — the migration should compose them, not duplicate them.
- Write the behavior list down; it becomes the equivalence checklist for tests.

### Phase 2: Verify which branches are live

Dead-branch pruning must be evidence-based:

- **DB examples**: query real rows from the production/staging database and check whether data shapes the code defends against actually occur. If a branch only guards data that never exists, prune it.
- **API responses / log events**: ask the user for real example payloads, or pull them from logs — never invent example data.
- **User confirmation**: for anything you cannot verify with examples, ask the user "is this branch still live?" and prune only on an explicit yes/no.

Available evidence sources (use whichever apply; check dynamic tools first):
- **Datadog MCP** — search real log events / API traffic to confirm which branches actually execute and capture real payloads.
- **DB MCP tools** (any enabled DB / warehouse MCP) — query real rows to verify data shapes, field values, and whether defensive branches guard data that never occurs.
- **Related skills** — `datadog-log-investigation` and any repo-specific investigation skills for real-data digging; `integration-tests` / `write-unit-tests` for fixture patterns; `forgetful-memory-retriever` for prior decisions about the code being migrated.
- Prefer *failing loudly* (let the source loader raise) over ported silent-skip / default-value fallbacks for malformed data — unless the user verified real corrupt data occurs.

### Phase 3: Brainstorm the target design with the user

- Before writing the plan, discuss the domain models and API schemas with the user: attrs for business logic, pydantic for I/O, RORO, converters as the ORM→domain boundary.
- Explicitly ask: "which of these legacy fields/branches do we actually consume?" Build the model around what is *used*, not what the legacy row contains.
- Challenge every field and every function: YAGNI. A field nobody reads is bloat; a one-use one-liner should not be a function.
- Expect the first proposed model to be rejected or heavily trimmed — that's the process working, not a failure.

### Phase 4: Behavioral equivalence tests first

- Write integration tests that pin the *observable behavior* of the legacy path (happy path, visibility/error contract, ordering, merge rules) BEFORE or alongside the new code.
- Use real example data from Phase 2 as fixtures (real IDs, payload shapes from production data) — synthetic invented shapes encode wrong assumptions.
- When mocking, mock at the external source boundary (the external API or DB loader), not internals, so the test survives refactors of the new module.

### Phase 5: Implement minimally, iterate on simplification

- Implement the smallest coordinator that satisfies the tests.
- After it works, do one dedicated simplification pass: remove redundant queries, single-format re-validations, unused imports, wrapper functions. (In the reference case, three successive plans went: over-engineered port → decoupled but still bloated → a short coordinator with three independent source loaders.)
- Re-run the behavior tests after each simplification — they are the proof pruning didn't change behavior.

## Signals you're over-engineering (checklist)

- Re-validating an input format that an upstream component has already classified (e.g. code re-checks a string prefix or regex to decide a type after a classifier function already sorted the inputs by type)
- A dedicated query for data already loaded on an existing object
- Functions used once that wrap one expression
- Fields on the domain model that no renderer/consumer reads
- Silent-skip + log fallbacks for data shapes you never saw in real examples
- A fallback path for a code path the user cannot confirm is live

## Anti-patterns

- Copying legacy dict-shuffling into the new module "to be safe"
- Keeping dead branches "just in case" without evidence
- Writing the plan first and the tests never (plan encodes legacy bloat)
- Inventing example payloads instead of loading real ones
- Big refactor beyond the migration scope (mention it, don't do it)
