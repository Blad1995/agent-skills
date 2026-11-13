# Mode: plan review

Input: plan path (e.g. `.cursor/plans/*.plan.md` or `.claude/plans/*.plan.md`) or plan text. Ask if missing.

## Gather

Read the plan fully: goals, assumptions, proposed files/functions/types, migrations, tests, rollout, stated risks. Read every referenced file plus importers/dependents (`rg`). Find similar implementations and current test style.

## Verify

For each proposed change: does the file/function/type exist? Does current behavior match the plan's assumption? What ripple effects are missing? Does proposed test coverage fit the repo (integration tests for features)? Cite plan section + `file:line`.

Classify each claim: `correct` (ok), `stale` (warn), `risky` (warn), `unsupported` (danger), `missing` (danger).

## Required sections

1. **Plan summary** - problem, core idea, scope.
2. **Accuracy verdict** - KPI cards with counts per class + table of claims.
3. **Current architecture** - SVG of the affected subsystem.
4. **Proposed architecture** - matching SVG; highlight added edges green, removed red (dashed).
5. **Gap / risk matrix** - correctness, tests, API, data model, security, performance, maintainability, release.
6. **File-by-file review** - table: proposed edit / current reality / recommendation.
7. **Better plan** - concrete corrections or simplifications (YAGNI).
8. **Decision** - callout: approve / revise / reject + rationale.

## Output

`~/.agent/diagrams/{topic}-plan-review.html`, then `open` it.
