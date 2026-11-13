# fix-pre-commit

Follow the **`fix-pre-commit`** skill in this session (no subagent, no `cd` prefix).

1. `pre-commit run --files <staged ∪ unstaged>` with `required_permissions: ["all"]`; re-run once if it fails.
2. Re-stage only originally-staged files that hooks rewrote. Never `git add .` or stage unrelated files.
