# grill-me

Review the current branch's changes against `master` for errors, improvements, and alignment with the plan or issue.

Always follow the **`review-my-code`** skill, specifically:

1. **Gather context** — run `git diff master...HEAD` (or the repo's base branch); save diff + spec to `tmp/` for reviewers.
2. **Check the plan** — verify changes match the plan or issue (any source: Linear/GitHub issue via plugin, plan file, user text); if none is found, ask the user once.
3. **Review** — 3 parallel fresh-context reviewers per `goldfish.md` (correctness and contract, structure and YAGNI, requirements compliance; in-session if diff < ~50 lines); main agent dedupes, verifies, resolves (FIX / CONTEST / ESCALATE / DECLINE), and buckets via `severity.md` (precedence: correctness > simplicity > stability > performance; decision tree; contract check).
4. **Output** — `Verdict:` line, then summary table (`Errors` | `Things to improve` | `Nice to have`), then detailed sections with matching bold short titles and `Why:` / `Fix:` per item.

**Usage:** `/grill-me`, `/grill-me ABC-123`, or `/grill-me path/to/feature.plan.md`
