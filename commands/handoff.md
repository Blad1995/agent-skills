# handoff

Compact the current conversation into a handoff document so a fresh agent can continue the work.

**Usage:** `/handoff` or `/handoff <what the next session will focus on>`

1. **Location** — save to `<current project root>/tmp/handoff-<YYYY-MM-DD>-<slug>.md` (create `tmp/` if missing). Never `$TMPDIR`. If `tmp/` is not gitignored, warn the user.
2. **Focus** — if arguments are passed, treat them as the next session's goal and tailor the doc to it.
3. **Content** (short, technical):
   - Goal / original request
   - Current state: done, in progress, not started
   - Key decisions + why (incl. rejected approaches)
   - Open questions / blockers
   - Next steps (ordered)
   - Relevant files (paths, line ranges)
   - Suggested skills — which skills the next agent should read (full paths)
4. **No duplication** — reference existing artifacts (plans in `.cursor/plans/`, issues, PRs, commits, diffs) by path/URL instead of copying.
5. **Redact** secrets, tokens, passwords, PII (emails, names, customer data).
6. **Output** — reply with the file path only plus a one-line prompt to paste into the next session: `Read <path> and continue.`
