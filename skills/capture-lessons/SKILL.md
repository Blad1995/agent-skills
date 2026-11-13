---
name: capture-lessons
description: Route a lesson from a user correction to the right store - Forgetful (durable business/domain facts), a rule/skill edit (durable agent-behavior lessons), or the repo's lessons file (short-lived gotchas). Use after any user correction of agent behavior or output, or when the user says "remember this" / "don't do that again".
---

# Capture Lessons

Trigger: the user corrects agent behavior or output. Capture the pattern, not the incident.

## Route

| Lesson type | Store | Example |
|---|---|---|
| Durable business/domain fact | Forgetful via `forgetful-memory-updater` subagent | "Unpaid orders expire 24h after creation" |
| Durable agent-behavior lesson | Propose edit to a rule or skill; apply only after user approves | "Always run pre-commit on touched files before reporting done" |
| Short-lived gotcha (repo/branch/env specific) | the repo's lessons file (e.g. `<repo>/.cursor/lessons.md` or `<repo>/.claude/lessons.md`) | "horst DB needs `down -v` after crashed test run on this branch" |

Unsure between routes: ask the user.

## Repo lessons file

- One bullet per gotcha: `- YYYY-MM-DD <pattern> -> <rule to follow>`
- Read the file first; dedupe or update an existing bullet instead of appending.
- Delete bullets that are obsolete or promoted.
- Create the file if missing. Do not edit `.gitignore` unless asked (user gitignores it).

## Promotion

Same gotcha seen 2+ times, or clearly not short-lived -> propose a rule/skill edit (or Forgetful for business facts), then remove the bullet from `lessons.md`.

## Forgetful route

Business logic only (no tests, fixtures, agent behavior). Use the post-work persistence snippet in [../forgetful/lifecycle.md](../forgetful/lifecycle.md). Do not call `create_memory` from the main agent.

## Report

One line: lesson, route, file/memory touched.
