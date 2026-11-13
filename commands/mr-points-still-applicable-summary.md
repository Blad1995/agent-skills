# mr-points-still-applicable-summary

Read and follow the **`mr-points-still-applicable-summary`** skill.

Summarize **unresolved** pull request review threads and classify which are still applicable in code vs already fixed, deferred, or discussion-only.

**Read-only** — do not resolve threads or change code unless the user asks separately.

Arguments:
  pr_url: Full pull request URL. Optional if PR number or repo is obvious from context.
  pr_number: PR number (e.g. `123`). Optional when `pr_url` is provided.

Usage examples:
/mr-points-still-applicable-summary pr_url="https://github.com/acme/api/pull/123"
/mr-points-still-applicable-summary pr_number="123"
/mr-points-still-applicable-summary

## Required source (one of)

- **GitHub plugin/MCP**: PR metadata + review threads
- **`gh` CLI**: `gh pr view`, `gh api graphql`

## Shell (local branch check only)

- `git branch --show-current`
- `git log -1 --oneline`
- Read referenced files to verify whether each thread is fixed
