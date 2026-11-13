---
name: review-my-code
description: Review code changes between current branch and master, checking against the task (task designator or link to plan/feature description) and coding best practices. Use when the user asks to review their code, runs /grill-me or /review-my-code, or wants feedback on current branch changes.
---

# Review My Code

This skill reviews the current branch's changes against `master`, ensuring they align with the task (task designator or link to plan/feature description), follow best practices, and use the best architectural approach.

> Conflict rule: rules already in this skill override the Linus-derived sections below (Severity, Contract check, Finding format, and anything sourced from `severity.md`).

## 1. Gather Context
- Run `git diff master...HEAD` (or the equivalent for the base branch) to see committed branch changes. If uncommitted work matters, also run `git diff` (unstaged) and `git diff --staged` (staged).
- **Check the task**: Does the code adhere to the task spec?
  - Spec sources, first match wins: task designator or link to plan/feature description given by the user (e.g. `ABC-123`, URL, file path, or pasted text) > `.plan.md` / `tmp/brief-*.md` for this branch > task designator in `git branch --show-current`. Resolve a designator or link with whatever plugin/MCP/tool is enabled for it. If no spec is found, **ask the user once**; if there is none, review against the diff and commit messages only and say so.
- **Persist context for reviewers**: write the diff to `<repo root>/tmp/review-diff-<slug>.patch` and the task spec text to `<repo root>/tmp/review-spec-<slug>.md` (create `tmp/` if missing).

## 1a. Fresh-context reviewers

Follow [goldfish.md](goldfish.md) (spawning, preamble, resolve step). Skip subagents and review in-session when the diff is under ~50 changed lines.

Launch 3 parallel goldfish. Each gets: diff path, spec path, repo root, the path of this skill, and its lens with the section names of §2 to apply:

| Lens | §2 sections |
|------|-------------|
| **Correctness and contract** | Logic & Correctness, Contract check, Special cases and comment truth; swallowed exceptions and dirty hacks from Code Quality |
| **Structure and YAGNI** | Architecture & Approach, Layering checklist, Function Granularity, Best Practices & Style, Naming & Documentation |
| **Requirements compliance** | Requirements Compliance, Testing triggers |

Then in the main agent:
1. Deduplicate findings; verify each against the code yourself.
2. Classify per the resolve step. Drop CONTEST items from the review (mention them in one line at the end with evidence); list ESCALATE items as questions to the user.
3. Map remaining findings to buckets via [severity.md](severity.md) (reviewer severity is input, the decision tree decides the bucket) and print the §3 output.

## 1b. Severity and precedence (Linus-derived)

Read and apply [severity.md](severity.md): precedence, decision tree, verdict, finding format, non-block list, contract check.

Precedence: **correctness > simplicity / good structure > overall stability > performance**.
- Internal rewrites are not findings by themselves; only breaking an external consumer (FE-facing OpenAPI, partners, events, queued Celery task args) without migration is an Error.
- Performance is ranked last; flag only clear issues (N+1, unbounded loads) unless the task is perf-related.
- When structure is poor, propose the cleaner rewrite, not just a local patch.

## 2. Review Guidelines

Goldfish lenses (§1a) apply these sections; in-session reviews apply all of them.
Focus your review on the following areas. Every finding must point at a concrete line or block, cited as a code reference (`startLine:endLine:filepath`) so it reads like an inline comment.

### Requirements Compliance
- Verify every requirement from the task spec is addressed.
- Flag anything missing, incomplete, or violating the spec.
- Note unhandled edge cases (malformed input, missing fields, invalid formats).

### Logic & Correctness
- Identify logical errors, incorrect assumptions, and boundary/edge-case failures.
- Check input validation and error propagation.

### Best Practices & Style
- **Data Structures**: Use models instead of dictionaries unless necessary (e.g. mappings).
- **Function Calls**: Enforce the use of named parameters.
- **Pythonic Code**: Prefer list comprehensions where applicable; flag non-idiomatic code and PEP 8 violations.
- **Abbreviations**: Absolutely **no abbreviations** in variable, function, or class names.
- **Type Hints**: Flag missing or incorrect type hints and weak error handling.
- **Dependencies**: Flag obscure or unnecessary third-party libraries and reinvention of stdlib functionality.

### Naming & Documentation
- Ensure naming is clear and intent-revealing.
- Verify that docstrings accurately correspond to the code implementation.

### Function Granularity
- **Avoid small "one-line" functions** that are only used in one place. Prefer inline code and fewer functions unless splitting provides a proven, tangible benefit (like reusing across multiple modules).

### Code Quality & Refinement
- Identify "vibe-coded" or unrefined parts: code that works but was clearly not thought through, copy-pasted, or AI-generated without cleanup.
- Spot dirty hacks: magic numbers, hardcoded values, commented-out code, swallowed exceptions, leftover print/debug statements, stray TODOs.

### Architecture & Approach
- Think critically about whether the chosen approach is the best possible one.
- Verify adherence to the overall repository structure.
- Check clean separation of concerns: data layer, business/domain logic, API layer, external API clients.
- Verify sensible dependency direction (business logic must not depend on the API layer or clients); flag mixed responsibilities, leaky abstractions, and circular dependencies.
- Prefer the simplest holistic solution that satisfies the spec. Flag overengineering (speculative abstractions, unnecessary design patterns, unused configurability) and premature optimizations without demonstrated need.
- Always suggest potential simplifications.
- Flag hacky fixes and symptom patches; propose the elegant root-cause solution.

### Layering checklist
- **Handler/DTO boundary**: API DTOs are built only at the external boundary (handler/edge); workflows/services must return domain data, not DTOs.
- **No dict-as-model**: `dict[str, …]` keyed bags passed between layers — flag; typed models (per repo convention) expected.
- **ORM leakage**: ORM/persistence entities used directly in workflows instead of existing domain models behind persistence helpers — flag.
- **Redundant loads**: data fetched as a void existence check then re-queried by id instead of loading the aggregate once and passing it down — flag.
- **Re-flattened results**: parent results rebuilding an ad-hoc bag from sources instead of composing per-child outputs — flag.
- **Premature concurrency**: parallel external calls without measured latency justification — flag.

### Contract check (Linus-derived)
- For every changed public symbol: search all callers (`rg`) and confirm they match the new signature and error semantics.
- Compare OpenAPI yaml vs handler vs response model; DB migration vs ORM model; Celery task args vs messages already queued; event payload vs consumer schema.
- Breaking an external consumer without migration = Error. Internal rewrites = not a finding by themselves.

### Testing triggers (Linus-derived)
- Missing integration test = Error if the plan or user agreed on tests; otherwise Things to improve.
- Tests that cover only the happy path = Things to improve.

### Special cases and comment truth (Linus-derived)
- An `if` that exists only for one edge case: ask whether a better data model removes it (Things to improve).
- Docstring or comment that contradicts the code = Error (a misleading comment is a bug).

### Non-block list (Linus-derived)
Never an Error: import order, formatting handled by Black/Ruff, test function naming, comment style. Repo style rules (named params, no abbreviations, docstring correctness) are not on this list.

## 3. Output Format

Provide the review in three parts: a **verdict line**, a **summary table**, then the **detailed sections**.

### Verdict line

First line of the review: `Verdict: reject | request-changes | approve-with-nits | approve` (definitions in [severity.md](severity.md)). Buckets map to severity: Errors = blocker, Things to improve = request-changes, Nice to have = nitpick.

### Summary table

Before the detailed sections, print a markdown table with exactly three columns — one per category. Each cell lists the **short title** of every finding in that category (one title per line inside the cell, or one row per finding when counts differ).

| Errors | Things to improve | Nice to have |
|--------|-------------------|--------------|
| Missing null check on `user_id` | Dict used instead of model | Extract shared validator |
| Wrong HTTP status returned | One-line helper only used once | |

Rules for the summary table:
- Give every finding a **short title** (3–8 words, intent-revealing, no abbreviations).
- Use the **same title** in the detailed section below so the table and prose cross-reference.
- If a category has no findings, put `—` in that column for that row.
- When categories have different counts, add rows until all titles are shown; leave empty cells where a category has no more items.
- If all three categories are empty, print the table with a single row: `| — | — | — |` and state that no issues were found.

### Detailed sections

After the table, provide the full review split strictly into the following sections. Each item must include the code reference of the line/block it applies to.

Item format (Linus-derived `[REASON] -> [ACT]`): bold short title, code reference, then:
- `Why:` pattern found + principle broken + consequence.
- `Fix:` exact change.

### 1) Errors
Clear errors in the logic, forgotten or commented-out code, typos, bugs, etc. Start each item with its **short title** in bold, then the explanation.

### 2) Things to improve
Potential simplifications, ways to increase readability, deduplication opportunities, wrong interfaces, unnecessary dictionaries used, missing logging, or performance concerns. Start each item with its **short title** in bold, then the explanation.

### 3) Nice to have
Things to improve in the future, architectural suggestions, or out-of-scope changes. Start each item with its **short title** in bold, then the explanation.

## 4. Save report

After the chat review, offer to save it to `<repo root>/tmp/review-<YYYY-MM-DD>-<slug>.md`.

## 5. Optional visual report

Only when the user asks for a visual/HTML review: after the chat review, render it with the `html-diagrams` skill using its `modes/diff-review.md` mode. Map Errors / Things to improve / Nice to have to `danger` / `warn` / `info` pills in the risk table. Chat review stays the primary output.
