---
disable-model-invocation: true
name: mr-points-still-applicable-summary
description: Fetches unresolved GitHub pull request review threads (GitHub plugin/MCP or gh CLI), compares each thread against the current branch code, and summarizes which review points are still applicable versus already fixed, deferred, or discussion-only. Use when the user asks which PR/MR comments still apply, wants a review-point triage summary, runs /mr-points-still-applicable-summary, or provides a PR URL for comment status.
---

# PR points still applicable summary

Read-only triage of pull request review threads. **Do not** resolve threads, edit code, or mark threads resolved unless the user asks separately.

## When to use

- User provides a PR URL or `#number` and wants to know what is still open in code.
- User asks which unresolved review comments still need work vs can be closed.
- User runs `/mr-points-still-applicable-summary`.

## Source contract (mandatory)

Use the first source that works:

1. **GitHub plugin/MCP** (if enabled): its read tools for PR metadata and review threads. Read the tool schema first.
2. **`gh` CLI** (authenticated): `gh pr view NUMBER --json headRefName,headRefOid,title,url` + the GraphQL query from `fix-mr-review-points` (same skills directory).

If both fail (missing tool, `gh` not installed/authenticated, bad PR number), **stop** and report the error. Do not invent threads.

## Parse PR input

From `https://github.com/<owner>/<repo>/pull/<number>`: take `owner`, `repo`, `number`.

If only a number is given, infer `owner/repo` from `git remote get-url origin` when obvious; otherwise ask once. If nothing is given, try `gh pr view --json number` for the current branch.

## Fetch unresolved threads

1. Fetch all review threads (paginate until `hasNextPage` is false).
2. **Unresolved thread**: `isResolved == false`.
3. For each thread, capture:
   - file: `path`; line: `line` (null when outdated, note `isOutdated`)
   - reviewer, body, replies (author + body)
   - thread id (short prefix ok)

## Compare against code

1. Confirm local branch matches PR work:
   - `git branch --show-current`
   - `git log -1 --oneline`
   - Prefer PR `headRefName` / `headRefOid` when local branch differs; note mismatch to user.
2. For each unresolved thread, read referenced files at current HEAD.
3. Classify every thread into **exactly one** bucket:

| Bucket | Meaning |
|--------|---------|
| **Fixed in code** | Request implemented; thread likely stale |
| **Still applicable** | Code change or naming/cleanup still needed |
| **Deferred / declined** | Author or reviewer agreed not to do in this PR |
| **Discussion / FYI** | Q&A, design note, conflict warning, out-of-scope — no code action |

Classification rules:

- Prefer **thread replies** over the opening question when they state intent ("We should.", "Good idea", "Out of scope", "I don't agree").
- **Fixed**: grep/read shows the suggested behavior, rename, event wrapper, or binding exists.
- **Still applicable**: reviewer asked for a concrete change and code at HEAD does not reflect it.
- **Deferred**: author explicitly pushed back or scoped out; no contradiction from reviewer.
- **Discussion**: clarification answered, or forward-looking question with no agreed implementation.
- When two threads contradict, list under **Needs user input** instead of guessing.

## Output format

Use this structure (adjust counts; omit empty sections):

```markdown
# PR #{number} — unresolved review triage

**Branch:** `{branch}` @ `{short_sha}`  
**PR:** {url}  
**Unresolved threads:** {N}

## Already fixed in code ({count})

| Topic | Location | Evidence |
|-------|----------|----------|
| … | `path:line` | One-line proof |

## Still applicable ({count})

1. **`path:line`** — {reviewer}: {ask}
   - Gap: {what code still lacks}

## Deferred / declined ({count})

- **`path:line`** — {summary + who declined/deferred}

## Discussion / FYI ({count})

- **`path:line`** — {one-line summary}

## Needs user input ({count})

- {contradiction or ambiguous thread — options}

## Summary

| Category | Count |
|----------|-------|
| Fixed | |
| Still applicable | |
| Deferred / declined | |
| Discussion / FYI | |
| Needs user input | |

**Highest priority:** {1–3 bullets}
```

Keep tables compact. Link PR URL in markdown. Do not resolve threads.

## Workflow

```
1. Pick source: GitHub plugin/MCP, else gh CLI
2. PR metadata → branch/head sha
3. Review threads (all pages) → unresolved threads
4. Fetch failure? → stop, report
5. Read referenced files on current branch
6. Classify each thread
7. Emit triage summary (format above)
```

## Examples

**Input:** `https://github.com/acme/api/pull/123`  
**Action:** `owner=acme`, `repo=api`, `pr=123`, fetch threads, compare to local branch, summarize fixed vs still applicable.

**Input:** `/mr-points-still-applicable-summary` on a branch with an open PR  
**Action:** Same; resolve PR from current branch via `gh pr view`.

## Related skills

- **fix-mr-review-points** — implement fixes from unresolved threads (still do not resolve them).
- **fix-pre-commit** — run after implementing fixes.
