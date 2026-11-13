---
name: branch-commit-squash
description: Squash all commits on top of master into one commit with a semantic message derived from the overall diff. Use when the user runs /squash-commits or asks to squash branch commits.
---

# Branch Commit Squash

Squash every commit on the current branch (above `master`) into a single commit. The new message must describe the **overall change**, not individual commit subjects.

Use the **`git-commit-helper`** skill (same skills directory) for commit message format and pre-commit handling.

## Commit message rules

- Derive the message from **`git diff $BASE...HEAD`** and changed files — the actual net change.
- **Do not** copy, merge, or paraphrase existing commit messages (`git log` subjects/bodies).
- Ignore generic or interim messages such as "code review fixes", "wip", "fix tests", "address comments".
- Write one cohesive subject + body that explains what the branch accomplishes end-to-end.
- Infer ticket prefix from branch name when obvious (e.g. `FIX-561-foo` → `FIX-561 |`).

## Workflow

1. **Preflight**
   - Run `git status --short`.
   - If the working tree is not clean (modified, deleted, or untracked files that are not part of the squash), stash everything first so unrelated work is not included in the squash commit:
     ```
     git stash push -u -m "squash-commits: stash pending work"
     ```
     - Record whether a stash was created (`STASHED=1` if `git stash list` shows the new entry).
     - If the tree is already clean, skip stashing.
   - Resolve base: `BASE=$(git merge-base master HEAD)`. If `master` is missing, try `main`; if neither exists, stop with an error.

2. **Inspect commits to squash** (context only — not for the message)
   - `COUNT=$(git rev-list --count $BASE..HEAD)`
   - If `COUNT` is `0`, stop: nothing ahead of base.
   - If `COUNT` is `1`, stop: only one commit — use `/commit` to amend or reword instead.
   - Capture the pre-squash commit list for the final report: `git log $BASE..HEAD --format='%h %s'` (save subjects; use full hashes if needed for clarity).

3. **Derive squash message from the diff**
   - Run `git diff --stat $BASE...HEAD` and `git diff $BASE...HEAD`.
   - Read the diff and summarize the overall logical change using git-commit-helper format.
   - Do **not** use `git log` output when writing the message.

4. **Squash**
   - `git reset --soft $BASE` — all branch changes become staged; working tree files stay as-is.
   - Verify with `git diff --staged` that staged content matches the intended squash.

5. **Commit**
   - Commit immediately with the derived message:
     ```
     git commit -m "type(domain): subject" -m "- bullet 1
     - bullet 2"
     ```
   - Use `required_permissions: ["all"]`.

6. **Pre-commit failures** (same as git-commit-helper)
   - Only if commit fails on pre-commit, run `pre-commit` on staged files and fix auto-fixable issues.
   - Re-stage only hook-modified files that were part of the squash.
   - Retry commit. Use `--no-verify` only when pre-commit cannot run due to infra/env failures.

7. **Restore stash** (if `STASHED=1`)
   - `git stash pop` — restore the pending work that was set aside in step 1.
   - If `stash pop` conflicts, stop and report; do not leave the stash dropped on conflict.

8. **Report** — use this exact format:

   ```
   Previous:
   - <short-hash> <subject>
   - <short-hash> <subject>
   ...

   New state:
   - <short-hash> <subject>

   <full commit body, every line>
   ```

   - **Previous**: every commit that was squashed (`$BASE..HEAD` before reset), one bullet per commit (`hash subject`).
   - **New state**: the single new commit hash, subject, then the full body (bullets and blank lines as committed). Use `git log -1 --format='%h %s%n%n%b'` after the squash commit.

## Safety rules

- Use **`git reset --soft`** only — never `--hard`.
- Always stash dirty working-tree state before squashing (step 1) so unrelated local changes are not committed; restore with `git stash pop` after the squash commit (step 7).
- Never commit `.cursor` files or secrets.
- Do not push unless the user explicitly asks.
- Do not push or open PRs as part of this command.
