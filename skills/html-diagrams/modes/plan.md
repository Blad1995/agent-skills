# Mode: visual implementation plan

Input: feature description, issue, or existing markdown plan.

## Research first

Read before drawing: entry points, affected modules, similar features, public APIs (OpenAPI specs), DB models, background tasks, tests, `AGENTS.md`/README constraints. Every file/function named on the page must exist or be explicitly marked "new".

## Required sections

1. **Goal and scope** - what changes, what is intentionally out (callout).
2. **Current state** - small SVG or table of the affected subsystem only.
3. **Proposed design** - SVG architecture / data / control flow (`reference.md`); figcaption states the core design claim.
4. **Phases** - `.timeline`, with dependencies in `.meta`.
5. **File map** - `.tree` with `add`/`mod`/`del`, one-line reason per file.
6. **Contracts** - endpoints, schemas, models, task signatures, config; table or short code blocks (signatures only, never full files).
7. **Risk / decision matrix** - table: correctness, migration, API compat, tests, security, performance, release; severity pills.
8. **Test plan** - table mapping case -> test file -> unit/integration.
9. **Acceptance** - `.checklist` of observable done criteria.

Hierarchy: overview + architecture dominate the first viewport; file/test detail compact or in `<details>`.

## Output

`~/.agent/diagrams/{topic}-plan.html` from `resources/page-template.html`, then `open` it.
