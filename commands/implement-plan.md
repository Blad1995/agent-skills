# implement-plan

Execute a written implementation plan step-by-step.

Always follow the **`executing-plans`** skill, specifically:

1. **Resolve the plan** — from a `@*.plan.md` attachment, explicit path, or your client's plan UI.
2. **Review first** — raise concerns before coding; do not start on `main`/`master` without consent. For large plans with no `tmp/plan-review-*-<slug>.md`, suggest `/review-plan` first (do not block if the user declines).
3. **Sync todos** — todo tool ids must match plan frontmatter `todos[].id` (one item per todo); update plan file `status: completed` as each task finishes (keeps plan-file progress in sync).
4. **Coordinate, don't implement** — delegate each non-trivial todo to `plan-task-implementer`; coordinator verifies, syncs plan, runs strategic track.
5. **Execute in order** — follow markdown body steps per todo; confirm with user before optional tests.
6. **Verify each todo** — mark completed only after plan-listed checks + lint on touched files pass; log deviations under `## Deviations` in the plan; stop if a step breaks an unlisted external consumer.
7. **`update-forgetful-memory`** — delegate to `forgetful-memory-updater`, do not write memory from the main agent.
8. **Finish** — self-review own diff with `severity.md`, fix Errors; summarize changes + strategic suggestions; offer next steps; never commit unless the user asks.

**Usage:** `/implement-plan @my_feature.plan.md` (any `*.plan.md` path works)
