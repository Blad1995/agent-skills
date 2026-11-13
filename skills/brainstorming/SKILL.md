---
name: brainstorming
description: Turn a raw feature idea into a reviewed concept brief before planning. Open-ended clarification, readiness gate, parallel fresh-context reviewer lenses, brief file in tmp/. Use when the user runs /brainstorm or asks to brainstorm or explore a feature idea before writing a plan.
disable-model-invocation: true
---

# Brainstorming

Inspired by the Elephant-Goldfish Model: this session (the "elephant") holds the context and debates the idea with the user. Fresh subagents (the "goldfish") review only the written hypothesis, so they do not share the session's blind spots.

Apply `concise-english` to all written output.

## Hard rules

- **No code.** Do not edit code in this workflow. Reading code is fine.
- **Critique first.** Lead with risks, gaps, and the strongest counter-argument. Agree only after the idea survives scrutiny.
- **Brief goes to a file**, not into chat.

## Step 1: Clarify (multi-turn, open-ended)

Ask open-ended questions in chat. Do not offer pre-canned options here. Continue across turns until the problem and boundaries are clear. Cover:

- What problem does this solve? Who or what consumes it?
- Hard constraints (external consumers, data, rollout, deadlines).
- How is it handled today? Why does that not work?
- Edge cases and explicit non-goals.
- How do we measure success?

Explore the codebase as needed to ground questions in real code.

## Step 2: Readiness gate

Summarize the working hypothesis in 2-3 sentences. Then `AskQuestion` with one question:

- `Review with fresh reviewers`
- `Clarify more in chat`

Do not spawn reviewers before the user picks the first option.

## Step 3: Fresh-context lenses (parallel)

Launch 3 `generalPurpose` subagents in one message (`readonly: true`). Each gets only: the hypothesis text, the repo root path, and its lens. No chat history. Prompt template:

```
You are a read-only reviewer with no prior context. Do not edit files.
Repo: <repo root>
Feature hypothesis:
<2-3 sentence hypothesis + key constraints>
Lens: <lens name + questions below>
Search the code to ground each point. Report findings as:
- Severity: Blocker | Major | Nit
- Finding: <what is wrong or missing>
- Evidence: <file:line or "none">
- Requirement: <what the brief must state to address it>
No filler. If nothing found, say "No findings".
```

| Lens | Questions |
|------|-----------|
| **YAGNI and reuse** | Does this need to exist now? Does existing code, a library, or a service solve most of it? Is anything speculative? |
| **Migration and external impact** | What changes for FE-facing OpenAPI, partners, event payloads, queued Celery task args, DB schema? How do we roll back mid-rollout? |
| **Observability and on-call** | Which logs/metrics/traces prove it works? How does on-call debug a failure at 3 AM? |

If a reviewer fails, retry once. If it fails again, mark it `not run` in the brief. Never treat a failed reviewer as "no findings".

## Step 4: Write the brief

Deduplicate findings. Write `<repo root>/tmp/brief-<YYYY-MM-DD>-<slug>.md` (create `tmp/` if missing; warn if `tmp/` is not gitignored):

```markdown
# <Feature name>

**Date:** YYYY-MM-DD

## Overview
<Problem, consumer, value. Plain English.>

## Analysis
<Merged reviewer findings, highest severity first, with evidence.>

| Lens | Status |
|------|--------|
| YAGNI and reuse | completed / not run |
| Migration and external impact | completed / not run |
| Observability and on-call | completed / not run |

## Goals / Non-goals
- Goals: ...
- Non-goals: ...

## Alternatives weighed
- <Alternative> — Rejected by author: <reason>

## Key decisions
- <Decision> — <why>

## Open questions
- ...
```

In chat: give the path and 2-3 top objections. Do not paste the brief.

## Step 5: Iterate or hand off

`AskQuestion`:

- `Address objections` — back to Step 1 with the objections; re-run Step 3 after changes.
- `Hand off to /writing-plans` — tell the user to run `/writing-plans <brief path>`.
- `Stop and keep the brief`
