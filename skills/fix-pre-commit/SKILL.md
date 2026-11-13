---
name: fix-pre-commit
description: Run pre-commit on changed files, apply hook fixes, and stage only files that were in scope for the current change and were modified by hooks. Use when the user runs /fix-pre-commit.
---

# Fix pre-commit

Run hooks on in-scope files only, re-run once after auto-fixes, then re-stage only hook-touched in-scope files. Never touch unrelated working-tree edits.

## Do not use a subagent

Run in this session with `required_permissions: ["all"]`. No `cd` prefix — shell already starts in repo root.

## 1. Run hooks (one call)

```bash
files=$({ git diff --cached --name-only; git diff --name-only; } | sort -u)
pre-commit run --files $files || pre-commit run --files $files
```

- Second run only executes if the first failed (typically after black/ruff/autoflake rewrites).
- Do **not** use `pre-commit run -a`.

## 2. Classify

- **`pass`**: second (or first) run succeeded.
- **`failed_code`**: hooks still fail on lint/docstring/forbidden-keyword issues — fix the code, then re-run step 1.
- **`failed_infra`**: missing binaries, network, permission, or sandbox failures.

## 3. Re-stage hook-touched in-scope files (one call)

Only when originally-staged files were rewritten by hooks:

```bash
git diff --name-only | grep -Fxf <(git diff --cached --name-only) | xargs -r git add --
```

- Never `git add -A`, `git add .`, or stage untracked/unrelated files.

## 4. Report

`status`, `last_command`, short `notes`. On `failed_infra`, the caller (e.g. `/commit`) may use `--no-verify` per repo policy.
