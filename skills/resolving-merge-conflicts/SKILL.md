---
name: resolving-merge-conflicts
description: Resolve in-progress git merge or rebase conflicts by understanding local branch intent versus master/main. Use when a merge, rebase, cherry-pick, or conflict resolution is needed, especially when preserving the intent of commits that are local to the branch.
---

# Resolving Merge Conflicts

## Goal

Resolve the in-progress merge, rebase, or cherry-pick correctly based on intent. Prioritize understanding why the local branch changed behavior and how that intent interacts with the target branch.

Always resolve conflicts. Never abort the merge or rebase unless the user explicitly asks.

## Workflow

1. Inspect the current git state.
   - Run `git status`.
   - Identify whether this is a merge, rebase, cherry-pick, or revert.
   - List conflicted files and unresolved hunks.
   - Check the target branch being merged or rebased onto.

2. Understand branch intent before editing.
   - Read the local commits that are not in master/main.
   - Read the relevant commit messages and diffs.
   - When available, inspect linked PRs, the task designator, or the link to the plan/feature description.
   - Identify the primary source of each side of the conflict: local branch change, target branch change, generated file, formatter output, or test fixture update.

3. Resolve each conflict hunk.
   - Preserve both intents where they are compatible.
   - When intents conflict, choose the behavior that matches the stated goal of the local branch commits and the current merge/rebase.
   - Do not invent new behavior to make the conflict disappear.
   - Keep edits limited to files and lines directly involved in the conflict.
   - Remove conflict markers completely.
   - Keep generated or formatted output consistent with the project's tools.

4. Validate the resolution.
   - Use the repository's pre-commit workflow after resolving conflicts.
   - Before running hooks, record in-scope paths from staged and unstaged tracked changes.
   - Run `pre-commit run -a` from the repository root.
   - If hooks rewrite files, re-run `pre-commit run -a` until it passes or the failure is classified as code-related or infrastructure-related.
   - Stage only hook-rewritten files that were in the recorded in-scope path set.
   - Do not stage unrelated files or fix unrelated pre-existing failures unless the user asks.

5. Finish the operation.
   - Stage the resolved files.
   - For a merge, create or complete the merge commit.
   - For a rebase, run `git rebase --continue` and repeat the workflow for every subsequent conflict until the rebase completes.
   - For a cherry-pick or revert, continue the operation after staging.
   - Verify final `git status`.

## Decision Rules

- Local branch intent is determined from commits present on the current branch and not on master/main.
- Target branch intent is determined from the incoming side of the merge or the branch being rebased onto.
- If both sides changed the same API, adapt the local branch behavior to the target branch's current interface while preserving the local branch's purpose.
- If tests conflict, keep or update tests so they assert the resolved behavior, not merely whichever side is newer.
- If a conflict involves data migrations, generated API specs, lockfiles, or snapshots, inspect the source changes first, then regenerate when the project provides a standard command.

## Reporting

When finished, summarize:

- What conflict areas were resolved.
- Which intent was preserved when trade-offs were required.
- Which checks were run and their results.
- Any remaining risks or checks that could not be run.
