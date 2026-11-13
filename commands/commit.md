# commit

ONLY run if `/commit` is in the user's message body. Never just because the command was loaded.

Follow the **`git-commit-helper`** skill exactly: inspect (plus `uv run mypy`) in one call, commit in one call, re-stage + recommit only if hooks rewrote files.

## Scope

Commit-only. Do **not** push or open a PR unless explicitly requested in the same message.
