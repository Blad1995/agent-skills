# brainstorm

Turn a raw feature idea into a reviewed concept brief before planning. No code.

Always follow the **`brainstorming`** skill, specifically:

1. **Clarify** — open-ended questions over several turns until problem, constraints, and non-goals are clear.
2. **Readiness gate** — 2-3 sentence hypothesis, then `AskQuestion`: review now / clarify more.
3. **Fresh reviewers** — 3 parallel read-only subagents (YAGNI and reuse, migration and external impact, observability and on-call) with no chat history.
4. **Brief** — write `tmp/brief-<date>-<slug>.md`; chat shows path + top objections only.
5. **Next** — iterate, or hand off to `/writing-plans <brief path>`.

**Usage:** `/brainstorm <feature idea>`
