# review-plan

Review a `.plan.md` with fresh-context reviewers before implementation. Do not edit code.

Follow the **`review-my-code`** skill, specifically its `goldfish.md` (spawning, preamble, resolve step).

**Usage:** `/review-plan @<slug>.plan.md` (any plan path works; optional: `brief=tmp/brief-*.md`)

1. **Inputs** — plan path (required; ask if missing), optional brief path, repo root.
2. **Reviewers** — 3 parallel goldfish, each given plan path (+ brief path if any) + repo root:
   - **Comprehension** — first write in own words: "What this plan proposes" and "How the existing system works, per this plan" (2-5 sentences each). A section you cannot paraphrase = Blocker. Flag project-specific terms that are neither defined nor linked. Do not flag general engineering terms.
   - **Critic / zoom-out** — YAGNI and speculative abstractions; reinvented code (search with `rg` for existing equivalents); symptom patch instead of root cause; unmitigated risks; external consumers (OpenAPI, events, queued Celery args, migrations) without migration path. Check against the self-review checklist in the `writing-plans` skill.
   - **Implementation readiness** — per task: "do I know exactly what to code, where, and how?" Flag decisions left to the implementer (API signature, error strategy, data model), missing verification commands, references to files/symbols that do not exist unless marked Create, and tasks that do not leave the repo green (depend on a later task).
3. **Resolve** — deduplicate, classify FIX / CONTEST / ESCALATE / DECLINE per `goldfish.md`.
4. **Report** — write `<repo root>/tmp/plan-review-<YYYY-MM-DD>-<slug>.md`: reviewer status table, comprehension paraphrase verbatim, findings ordered Blocker -> Major -> Nit with class + justification + proposed edit.
5. **Chat** — report path, ESCALATE items first (they need user knowledge), then severity counts. Do not paste the report.
6. **Gate** — `AskQuestion`: apply all FIX edits to the plan / go item by item / continue without changes.
7. **Re-review** — after applying fixes, offer one re-run of the reviewers. Max 1 re-review; remaining findings become accepted trade-offs noted in the report.
