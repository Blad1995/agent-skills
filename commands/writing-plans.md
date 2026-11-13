# writing-plans

Create a comprehensive implementation plan for a multi-step feature **before writing code**.

Always follow the **`writing-plans`** skill, specifically:

1. **Clarify first** — if a `/brainstorm` brief exists (`tmp/brief-*.md` or passed path), read it first; surface ambiguous or problematic parts of the prompt/codebase; ask the user until requirements are clean; ask whether tests should be included (integration tests recommended).
2. **Classify scope** — small (refactor/restructure) vs large (new feature / significant logic change); format and Forgetful usage depend on this.
3. **Large scope only** — launch `forgetful-memory-retriever` before the final plan (never in Ask mode — MCP calls are blocked there; skip and defer to Agent mode); end with a Forgetful post-implementation section and `update-forgetful-memory` todo.
4. **Write the final plan** only after clarification is complete; save to the repo's plan location (e.g. `.cursor/plans/` or `.claude/plans/`) when the repo uses plan files.
5. Never include commit steps unless the user explicitly asks.

**Usage:** `/writing-plans <request>` or `/writing-plans tmp/brief-<date>-<slug>.md`
