---
disable-model-invocation: true
name: fix-mr-review-points
description: Fetches unresolved GitHub pull request review threads (GitHub plugin/MCP or gh CLI), then implements the requested code changes without resolving threads. Stops with a clear error if neither source works. Use when the user wants to fix PR/MR review points, address review comments from a pull request URL or number, or apply reviewer feedback without marking threads resolved.
---

# Fix PR review points

> Conflict rule: rules already in this skill override the Linus-derived sections below (Triage, Push back, Verify). Shared severity and precedence: `review-my-code/severity.md` (in the same skills directory).

## When to use

- User provides a pull request URL (e.g. `https://github.com/<owner>/<repo>/pull/123`) or a PR number in the current repo.
- User asks to fix review comments, apply PR feedback, or implement reviewer suggestions.

## Do not resolve threads

- **Never** mark review threads as resolved (no `resolveReviewThread` mutation or equivalent plugin/MCP call).
- **Never** use tools whose purpose is to resolve, close, or dismiss review threads.
- Only **read** threads; **write** changes in the repository. Reviewers keep control of resolving threads after they verify the fixes.

## Source contract (mandatory)

Use the first source that works:

1. **GitHub plugin/MCP** (if enabled): its read tool for PR review threads/comments. Read the tool schema first.
2. **`gh` CLI** (authenticated): GraphQL query below.

If both fail (tool missing, `gh` not installed/authenticated, bad PR number, non-success response), **stop immediately**. Tell the user what failed and **do not** pretend comments were fetched (no fabricated threads, no guessing from the URL alone).

## Parse PR input

From `https://github.com/<owner>/<repo>/pull/<number>`: take `owner`, `repo`, `number`.

If the user only gives a number, infer `owner/repo` from `git remote get-url origin`; if not obvious, ask once.

## Fetch all unresolved threads

With `gh` (paginates via `endCursor`):

```bash
gh api graphql --paginate -F owner=OWNER -F repo=REPO -F pr=NUMBER -f query='
query($owner:String!,$repo:String!,$pr:Int!,$endCursor:String){
  repository(owner:$owner,name:$repo){ pullRequest(number:$pr){
    reviewThreads(first:100, after:$endCursor){
      pageInfo{ hasNextPage endCursor }
      nodes{ id isResolved isOutdated path line
        comments(first:50){ nodes{ author{login} body } } } } } } }'
```

1. **Filter**: keep threads with `isResolved == false`.
2. **Flatten comments**: use every comment body for context; the first comment anchors `path`/`line`.
3. Top-level PR review summaries (not threads) live in `gh pr view NUMBER --json reviews`; use only if threads alone are insufficient.

If the filtered list is empty after a successful fetch, report that there are no unresolved threads (optional: mention total fetched).

## Triage before coding (Linus-derived)

1. For each unresolved thread, read the referenced file at current HEAD. If the request is already implemented or the thread is outdated (`isOutdated`) and the code reflects it, classify as `already-fixed` (same rules as `mr-points-still-applicable-summary`).
2. Classify every thread into exactly one bucket:

| Bucket | Meaning |
|--------|---------|
| `must-fix` | Correctness issue, bug, or clear reviewer instruction |
| `should-fix` | Structure / simplification request with a clear action |
| `nit` | Naming, style, small cleanup |
| `disagree` | Applying it would cause a bug, break an external consumer, or contradict AGENTS.md (see Push back) |
| `already-fixed` | Code at HEAD already reflects the request |
| `needs-input` | Ambiguous or contradicting threads (see "When to ask the user") |

1. Show the triage table (`thread | location | bucket | one-line ask`), then implement `must-fix`, `should-fix`, `nit`. Rank by precedence: correctness > simplicity / good structure > overall stability > performance.
2. Apply larger rewrites suggested by reviewers only when the thread asks for them; otherwise mention them in the summary.

## What to fix

- For each unresolved thread, implement the requested changes in the codebase **faithfully** and **minimally** (match existing style; no unrelated refactors).
- Prefer fixing at the referenced file/line.

## Capture learnings

- If a thread reveals a bigger point or a learning opportunity for the agent, consider adding the learning to the project's `AGENTS.md` file. This prevents the same issue in future changes.
- Use the `/concise-english` skill when writing the addition to `AGENTS.md`.

## When to ask the user (no guessing)

Ask **before** or **after** implementing (as appropriate) if **any** of these apply:

- Two or more comments in the same thread (or replies) **contradict** each other on approach.
- Reviewer and author **disagree** and there is no clear final direction (“I’d do X” / “actually Y” without resolution).
- The thread is **ambiguous** (e.g. “maybe extract this?”, “not sure about naming”) with no single actionable instruction.
- Implementing the comment would **conflict** with another unresolved thread or with stated product/architecture constraints.
- **Push back (Linus-derived)**: implementing the comment would introduce a bug, break an external consumer, or contradict AGENTS.md. Do not apply it silently and do not skip it silently. Ask the user and include a short reply draft for the reviewer (reason + evidence, 1-3 sentences).

Phrase questions concretely: options, trade-offs, and what you need to proceed.

## Per-thread report (Linus-derived)

For each thread, report:
- `[REASON]` what the reviewer asked + why it is valid or invalid.
- `[ACT]` change made (code reference) or reply draft.

## Verify

After fixes, run lint (`pre-commit run --files <touched files>` or `/fix-pre-commit`) and the tests that cover touched files. Report failures; do not claim done on red checks.

## Workflow summary

```
1. Pick source: GitHub plugin/MCP, else gh CLI
2. Fetch review threads (all pages) → unresolved only (read-only)
3. Fetch failure? → error + user notification, STOP
4. Triage threads (must-fix / should-fix / nit / disagree / already-fixed / needs-input) → show table
5. Implement fixes in code only; do NOT resolve threads
6. Push back cases → ask user with reply draft
7. Verify: lint + tests on touched files
8. Bigger point or learning opportunity? → add learning to AGENTS.md via /concise-english
9. Summarize per thread: [REASON] / [ACT] (files + rationale)
```

## Examples

**Input:** PR URL `https://github.com/acme/api/pull/123`  
**Action:** `owner=acme`, `repo=api`, `pr=123`, fetch threads, filter `isResolved == false`, then address each thread in code—**do not** resolve threads.

**Input:** “Fix comments on PR #123” in a cloned repo  
**Action:** Same; infer `owner/repo` from the `origin` remote.
