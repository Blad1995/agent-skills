# Mode: diff review

Input: branch, commit, range, or MR. Default: working tree + branch vs `master`.

## Gather

```bash
git merge-base HEAD master
git diff --stat master...HEAD
git diff --name-status master...HEAD
git log --oneline master..HEAD
git diff master...HEAD -- <file>   # per important file
```

Read changed files fully plus call sites needed to validate behavior. Note: public API / OpenAPI changes, models + migrations, tasks, config, dependencies, tests touched, changelog.

## Verify

Know and cite before rendering: exact files + line counts, every function/type named, before/after behavior for important changes, coupling and test impact. Use `file:line` or command output. Never invent rationale.

## Required sections

1. **Executive summary** - problem solved, factual scope (KPI cards: files, +/-, tests, risks).
2. **File map** - full `.tree`, `add`/`mod`/`del`; `<details>` if long.
3. **Architecture impact** - SVG when relationships change; skip if purely local.
4. **Before / after** - `.compare` panels per important behavior change.
5. **Risk review** - table: correctness, tests, API compat, security, performance, maintainability.
6. **Coupling map** - dependents, hidden coupling, migration/release order.
7. **Recommendation** - callout: merge-ready / blockers / follow-ups.

Color language: red = removed/before, green = added/after, amber = modified/risk, blue = neutral context.

## Output

`~/.agent/diagrams/{branch}-diff-review.html`, then `open` it.
