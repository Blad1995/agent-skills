---
name: git-commit-helper
description: Generate descriptive commit messages and handle the commit workflow using semantic conventional commits. Use when the user asks to commit changes, runs /commit, or needs help with git staging and committing.
---

# Git Commit Helper

Commit staged changes with a semantic message in the **minimum number of shell calls** (2 normally, 3 if hooks rewrite files).

## Commit Message Format

Use this format — do **not** inspect past commits to derive style.

```
[FIX-123 | ]type(domain): short imperative subject

- imperative bullet naming concrete change
- imperative bullet naming concrete change
- add integration tests for ...
```

### Subject line

- **Ticket prefix** (optional): `ABC-123 |` — take it from the branch name (`[A-Z]+-\d+`) or conversation context. Never ask unless clearly relevant and not inferable.
- **Type** (lowercase): `feat|fix|refactor|chore|test|docs|perf`
- **Domain** (scope): touched area — e.g. `auth`, `api`, `billing`, `search`, `cli`
- **Subject**: lowercase, imperative, specific — e.g. `skip retry when token is already revoked`

Examples:
- `fix(api): reduce upstream request timeout from 60s to 20s`
- `ABC-637 | feat(auth): add refresh token endpoint`

### Body

- Omit for single-purpose changes (one constant, one rename, one removal).
- Otherwise 2–7 bullets (`-`), lowercase, imperative (`add`, `remove`, `skip`, `use`), naming concrete symbols/endpoints/files.
- Put tests last: `- add integration tests for ...`.
- Optional last line: relevant PR/issue link.

## Workflow

### 1. Inspect (one call)

```bash
git branch --show-current && git diff --staged --stat && git diff --staged
```

```bash
git branch --show-current && git diff --staged --stat && git diff --staged
```

- If nothing is staged, but `/commit` was invoked mid-conversation with work done in that chat: stage the files changed as part of that chat's task (from the conversation context, not `git add -A`), show them to the user, and proceed. If it's unclear which files belong to that work, ask the user before staging.
- If nothing is staged and there is no in-chat work to commit, ask the user what to stage.
- Derive the message from the staged diff only.
- Run mypy via `pre-commit run --hook-stage pre-push` (runs the mypy hook with its pinned `additional_dependencies`) — if it fails, fix types before committing.

### 2. Commit (one call, `required_permissions: ["all"]`)

Subject as first `-m`, body as second `-m`:

```bash
git commit -m "ABC-123 | feat(auth): add logout endpoint" -m "- add POST /auth/logout endpoint revoking the refresh token
- add integration tests for expired and revoked tokens"
```

`git commit` output already contains hash + subject — that is the report. Done.

### 3. Only if pre-commit failed

- **Hooks auto-fixed files** (black, ruff `--fix`, autoflake, trailing-whitespace): re-stage only originally-staged files and repeat the same commit in one call:

  ```bash
  git diff --name-only | grep -Fxf <(git diff --staged --name-only) | xargs git add -- && git commit -m "..." -m "..."
  ```

- **Hook needs a code edit** (pydocstyle, forbidden-keywords, non-fixable ruff): fix the file, then `git add -- <file> && git commit -m "..." -m "..."` in one call.
- **Infra failure** (pre-commit cannot run): `git commit --no-verify -m "..." -m "..."`. Never use `--no-verify` to bypass fixable code checks.

## Repo facts

- Run mypy via `pre-commit run --hook-stage pre-push` before committing (type errors are cheaper to fix pre-commit, even though the hook runs on pre-push). Do this after inspecting, before the commit call.
- `no-commit-to-branch` blocks commits on `master`.

## Forbidden (wasted calls)

- `cd <repo> && ...` — shell already starts in repo root.
- `git log` of any kind, `git status` before or after commit, `echo '---'` separators.
- Heredoc messages (`$(cat <<'EOF' ...)`) and temp message files.
- Separate `git add` and `git commit` calls when they can be chained.

## Safety Rules

- Never use destructive git commands; never amend unless requested.
- Never commit `.cursor` files or secrets (`.env`, credentials, tokens, keys).
- Never `git add -A` / `git add .`.
- Do not push or open PRs unless explicitly requested in the same message.
