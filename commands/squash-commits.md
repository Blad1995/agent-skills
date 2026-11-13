# squash-commits

Squash all commits on top of `master` into a single commit with one semantic message that describes the **overall** branch change.

Read and follow the **`branch-commit-squash`** skill.

For commit message format and pre-commit handling, also follow the **`git-commit-helper`** skill.

## Critical rule

Derive the squash commit message from **`git diff $BASE...HEAD`** (the net code change). **Do not** reuse or combine existing commit messages — they may be outdated, interim, or generic (e.g. "code review fixes").

## Scope

`/squash-commits` is **squash + commit only**. Do not push or open a PR unless the user explicitly asks in the same message.
