# Goldfish reviewers and resolve step (shared)

Shared by `/review-plan` and `review-my-code` (`/grill-me`). Inspired by the Elephant-Goldfish Model: the session that wrote the artifact (plan or code) is biased toward it. Fresh-context subagents review only the written artifact.

## Spawning

- `generalPurpose` subagents, `readonly: true`, all lenses in **one message** (parallel).
- Pass **file paths only** (artifact, context files, repo root) plus the lens. Never paste chat history or your own reasoning.
- Retry a failed reviewer once. If it fails again, report it as `not run`. Never count it as "no findings".

## Preamble (prepend to every reviewer prompt)

```
You are a read-only reviewer with zero prior context. Do not edit files.
Judge only what the files say; do not assume unstated intent.
No filler, no praise, no narration of tool use.
Report each finding as:
- Severity: Blocker | Major | Nit
- Title: 3-8 words
- Scope: file:line range or section heading
- Finding: what is wrong or missing, and why it matters
- Evidence: file:line you checked (or "none")
- Fix: exact change
If nothing found, output "No findings".
```

## Resolve step (main agent)

The main agent wrote the artifact, so a wish to disagree is not evidence. Classify each deduplicated finding:

| Class | When | Action |
|-------|------|--------|
| **FIX** | Finding is valid | Propose the exact edit |
| **CONTEST** | Reviewer is wrong, and evidence exists that the reviewer **could read** (file + symbol, or a line in the artifact) | Cite the evidence; no edit |
| **ESCALATE** | Reviewer is wrong, but the evidence is outside the readable files (team convention, verbal decision) | Ask the user; no edit |
| **DECLINE** | Nit not worth fixing | Record only |

Rules:
- "This was intentional" is not evidence. No checkable evidence -> ESCALATE or FIX.
- Never contest a comprehension gap: if a fresh reader could not follow it, context is missing.
- Never change a reviewer's severity. Disagree via CONTEST with a reason.
- Do not add context only to satisfy a zero-context reviewer; add it when a human reader needs it.
