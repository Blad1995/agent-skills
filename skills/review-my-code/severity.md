# Severity and precedence (shared)

Shared by `review-my-code`, `fix-mr-review-points`, and `executing-plans`. Adapted from the Linus Torvalds review method.

> Conflict rule: rules already in the calling skill override this file.

## Precedence

When two rules conflict, the higher one wins:

1. **Correctness** — no wrong behavior, no data corruption, no wrong money or order state, no security or PII leak (user IDs in logs, missing auth).
2. **Simplicity / good structure** — clean data model, clear layering, no special cases. Rewrites that improve structure are welcome, also outside the strict diff when they clearly help the repo.
3. **Overall stability** — internal APIs and modules may be rewritten freely. Only external consumers need a migration path: FE-facing OpenAPI responses, partners, event payloads, args of queued Celery tasks.
4. **Performance** — lowest priority unless the task or user asks for it. Never trade structure for unmeasured speed. Flag only clear issues (N+1 queries, unbounded loads).

## Severity mapping

| Bucket | Severity | Blocks merge |
|--------|----------|--------------|
| Errors | blocker | yes |
| Things to improve | request-changes | should fix |
| Nice to have | nitpick | no |

Verdict:
- `reject` — design is wrong; needs rework.
- `request-changes` — at least one Error.
- `approve-with-nits` — no Errors; only Things to improve / Nice to have.
- `approve` — nothing found.

## Decision tree

Go top-down; first match wins.

1. Breaks an external consumer without migration -> **Error**. Internal signature or module rewrites are not findings by themselves.
2. Data corruption, wrong money/order state, swallowed exception, security/PII leak -> **Error**.
3. Docstring or comment contradicts the code -> **Error** (a misleading comment is a bug).
4. Missing integration test -> **Error** if the plan or user agreed on tests; otherwise **Things to improve**. Happy-path-only tests -> **Things to improve**.
5. Layering violation, dict-as-model, non-trivial logic duplicated in 2+ places -> **Things to improve**. The "no one-line helpers used once" rule still applies; no wrapper functions.
6. Special-case branch that exists only for one edge -> **Things to improve**; ask whether a better data model removes it.
7. Poor structure that a rewrite would fix -> propose the rewrite in **Things to improve** (in scope) or **Nice to have** (out of scope).
8. Performance -> **Things to improve** only for clear issues; otherwise **Nice to have**. Ranked last.
9. Naming, style -> **Nice to have** (except repo rules such as named params and no abbreviations, which keep their existing bucket).

## Finding format

Each finding:

```markdown
**Short title** (3-8 words)
`startLine:endLine:filepath` code reference
Why: pattern found + principle broken + consequence.
Fix: exact change.
```

## Non-block list

Never an Error; at most Nice to have:
- Import order
- Formatting that Black / Ruff handle
- Test function naming
- Comment style (single-line vs block)

Repo style rules (named params, no abbreviations, docstring correctness) are **not** on this list.

## Contract check

For every changed public symbol:
- Search all callers (`rg`) and check they still match the new signature and error semantics.
- OpenAPI yaml vs handler vs response model.
- DB migration vs ORM model.
- Celery task arg changes vs messages already in the queue.
- Event payload vs consumer schema.
