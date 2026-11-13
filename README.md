# Agent Skills

Personal commands, subagents, skills and rules for **Cursor** and **Claude Code**. The repo is the single source of truth. Each tool gets symlinks to it from `~/.cursor` and `~/.claude`.

## Install

```bash
git clone git@github.com:Blad1995/agent-skills.git
cd agent-skills
./install.sh
```

`install.sh` is idempotent. It does this:

| Repo folder | Cursor | Claude Code |
|---|---|---|
| `commands/` | `~/.cursor/commands` (dir link) | `~/.claude/commands` (dir link) |
| `subagents/` | `~/.cursor/agents` (dir link) | `~/.claude/agents` (dir link) |
| `skills/` | `~/.cursor/skills/<name>` (per-skill link) | `~/.claude/skills/<name>` (per-skill link) |
| `rules/` | `~/.cursor/rules/<name>.mdc` | `~/.claude/rules/<name>.md` |

> Warning: `~/.cursor/{commands,agents}` and `~/.claude/{commands,agents}` are replaced by links. Real directories are moved to `*.bak-<timestamp>` first. Skills not from this repo stay untouched.

Skills with `disable-model-invocation: true` run only via explicit slash command or attachment.

## Commands

| Command | What it does |
|---|---|
| `/brainstorm` | Idea -> reviewed concept brief (`tmp/brief-*.md`) via `brainstorming`. No code. |
| `/writing-plans` | Plan via `writing-plans` (reads a `/brainstorm` brief if present). |
| `/review-plan` | Review a `.plan.md` with fresh-context reviewers before implementing. |
| `/implement-plan` | Execute a plan via `executing-plans` (todos delegated to `plan-task-implementer`). |
| `/grill-me` | Review the branch via `review-my-code`: 3 fresh-context lenses, resolve step, severity buckets. |
| `/generate-tests` | Write integration tests for branch changes vs `master`. |
| `/commit` | Commit via `git-commit-helper`. |
| `/squash-commits` | Squash branch commits via `branch-commit-squash`. |
| `/fix-pre-commit` | Run pre-commit and stage hook fixes via `fix-pre-commit`. |
| `/mr-points-still-applicable-summary` | Triage unresolved PR review threads. |
| `/handoff` | Compact the conversation into `tmp/handoff-*.md` for a fresh agent. |
| `/wait-what` | Stop and re-pitch: how we got here, questionable decisions. No code changes. |

Design flow (inspired by the [Elephant-Goldfish Model](https://github.com/google/elephant-goldfish-model)): `/brainstorm` -> `/writing-plans` -> `/review-plan` -> `/implement-plan` -> `/grill-me`.

## Subagents

| Subagent | What it does |
|---|---|
| `plan-task-implementer` | Implement one `.plan.md` todo in a fresh context. |
| `test-writer` | Write unit/integration tests from a spec, following repo conventions. |
| `test-verifier` | Run the repo's tests and diagnose failures; compact verdict. |
| `forgetful-memory-retriever` | Read-only Forgetful memory digest at task start. |
| `forgetful-memory-updater` | Store/dedupe/obsolete/link Forgetful memories during work. |

## Skills

| Skill | What it does |
|---|---|
| `brainstorming` | Idea -> concept brief with parallel fresh-context lenses. No code. |
| `writing-plans` | Implementation plans (`.plan.md`) with clarification and optional Forgetful memory. |
| `executing-plans` | Execute a plan step by step; coordinator mode delegates todos. |
| `review-my-code` | Review branch vs `master` against the issue/plan, with severity model. |
| `fix-mr-review-points` | Fetch unresolved PR review threads and implement fixes. Never resolves threads. |
| `mr-points-still-applicable-summary` | Classify PR review threads: still applicable vs fixed/deferred. Read-only. |
| `git-commit-helper` | Conventional commit messages + staging workflow. |
| `branch-commit-squash` | Squash branch commits into one, message from the net diff. |
| `fix-pre-commit` | Run pre-commit on in-scope files, re-stage hook-touched files. |
| `resolving-merge-conflicts` | Resolve merge/rebase conflicts, preserving local branch intent. |
| `migrate-and-prune-code` | Port legacy code while pruning dead branches, based on real-data evidence. |
| `parallel-exploring` | Explore a codebase with concurrent `explore` subagents. |
| `datadog-log-investigation` | Search/aggregate Datadog logs and APM traces. |
| `forgetful` | Forgetful memory: store/retrieve, entities, graph, hygiene, lifecycle. |
| `capture-lessons` | Route lessons from user corrections to memory, rules/skills, or the repo lessons file. |
| `html-diagrams` | Offline HTML visual explainers (SVG diagrams, plan/diff reviews, recaps). |
| `obsidian-manage-notes` | Manage Obsidian notes via the `obsidian` CLI. |
| `concise-english` | Rewrite text into short, unambiguous controlled English. |
| `write-docstrings` | Python docstrings: business what/why, NumPy style. |
| `writing-for-agents` | Reference for writing agent-facing documents (skills, AGENTS.md). |

## Rules

`rules/workflow-principles.mdc`: global workflow principles (re-plan, subagents, critique first, lessons, verification, elegance, bug fixing). If Cursor does not load it globally, paste it into Cursor Settings > Rules > User Rules.

## MCP setup

Only one MCP server is configured here: [Forgetful](https://github.com/scottrbk/forgetful) (needs [`uv`](https://docs.astral.sh/uv/)). Install the other integrations as **plugins** in Cursor / Claude Code, not via `mcp.json`.

- **Cursor**: merge [`mcp.example.json`](mcp.example.json) into `~/.cursor/mcp.json`.
- **Claude Code**: `claude mcp add forgetful -- uvx forgetful-ai` (or copy it into a project `.mcp.json`).

| Skill / command | Needs | Required? |
|---|---|---|
| `forgetful`, `forgetful-memory-retriever`, `forgetful-memory-updater` | Forgetful MCP | required |
| `writing-plans`, `capture-lessons`, `/generate-tests` | Forgetful MCP | optional |
| `datadog-log-investigation` | Datadog plugin | required |
| `migrate-and-prune-code` | Datadog plugin, any DB MCP | optional |
| `review-my-code`, `/grill-me` | Linear or GitHub plugin (issue context) | optional |
| `fix-mr-review-points`, `mr-points-still-applicable-summary` | GitHub plugin **or** authenticated [`gh`](https://cli.github.com/) CLI | one required |
| `obsidian-manage-notes` | Obsidian CLI + running Obsidian app | required |
| `test-writer`, `test-verifier` | Optional repo skills `running_tests_locally`, `integration-tests`, `write-unit-tests` | optional |

Everything else needs no MCP.
