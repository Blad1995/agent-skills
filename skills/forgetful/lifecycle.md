# Feature Memory Workflow

Decides **when** to touch Forgetful memory during a feature's lifecycle and **who** handles it. Delegates mechanics to existing assets.

## Delegation map (do not re-implement)

| Phase | Delegate to | Purpose |
|-------|-------------|---------|
| Retrieval (pre-work) | Subagent `forgetful-memory-retriever` | Off-main-context multi-angle query, returns digest |
| Graph exploration | [explore.md](explore.md) | When retriever hits fragments / cross-domain trails |
| Retrieval mechanics | [memory.md](memory.md) | `query_memory` / `get_memory` usage |
| Persistence (post-work) | Subagent `forgetful-memory-updater` | Create/update/link/obsolete with hygiene |
| Entity modelling | [entities.md](entities.md) | Model services/components; link memories to entities |
| Cleanup mechanics | [hygiene.md](hygiene.md) | Dedupe, obsolescence, linking rules |

## When to engage

Engage at these triggers. Below them, skip Forgetful entirely.

### Query Forgetful (before coding)

- Feature planning or PRD review with 3+ steps or multiple files/modules.
- Unfamiliar domain, service, or endpoint referenced in the task.
- Ambiguous requirements where past decisions likely exist.
- Refactor, migration, or cross-cutting change.
- Debugging where root cause may relate to prior decisions/thresholds.

**Action**: delegate retrieval to the `forgetful-memory-retriever` subagent so the main agent keeps context free. Proceed with planning/coding in parallel once the digest returns.

**Never launch the retriever in Ask mode** — MCP calls are blocked there and retrieval always fails. In Ask mode, skip retrieval, note it is deferred to Agent mode, and proceed without it.

### Update Forgetful (after coding)

- Feature implemented and behavior verified (tests pass, PR ready, or merged).
- A **business** decision, threshold, contract, workflow, or caveat was established.
- Stale/incorrect memory was discovered during the task.
- Reusable domain knowledge emerged (service boundaries, naming, invariants).

**Action**: delegate to the `forgetful-memory-updater` subagent. Provide a short list of verified **business-logic** facts with provenance (production files, PR/MR URL, confidence). Do **not** ask it to store test cases, factories, fixtures, or “how to fix test X” — see [SKILL.md](SKILL.md) (business logic only).

### Skip Forgetful

- One-liner edits, typo fixes, formatting, or doc tweaks.
- Purely exploratory questions with no durable outcome.
- Speculative or unverified conclusions.

## Lifecycle checklist

Copy this into feature planning todos:

```
- [ ] Pre-work: retrieve relevant memories (forgetful-memory-retriever)
- [ ] Incorporate digest into plan / design decisions
- [ ] Implement and verify
- [ ] Post-work: persist decisions (forgetful-memory-updater)
- [ ] Verify retrieval of new memory for the same topic
```

## Subagent invocation snippets

Always set `model="chico"` on forgetful subagent invocations (retriever and updater), overriding any other default.

**Skip the retriever entirely in Ask mode** — MCP calls are blocked there and retrieval always fails; defer memory lookup to Agent mode.

Pre-work retrieval (non-blocking; run in background while planning):

```
Task(
  subagent_type="forgetful-memory-retriever",
  model="chico",
  prompt="Feature: <name>. Goal: <goal>. Repo: <owner/repo>. Surface memories relevant to <domain/components/files/services>. Use multiple query angles; escalate to graph exploration if fragmented. Return digest: memory IDs, entity IDs, titles, key facts, gaps.",
  run_in_background=true
)
```

Post-work persistence:

```
Task(
  subagent_type="forgetful-memory-updater",
  model="chico",
  prompt="Feature <name> shipped. Verified business-logic facts only (no tests/fixtures):\n- <fact 1>\n- <fact 2>\nSources: <production files/PR URL>. Dedupe; route type (memory/document/entity); update or create atomic entries; link related and entities; mark obsolete if needed. Skip anything that is only test setup."
)
```

## Handoff contract

When delegating, always provide:
- Feature/task name and concrete goal.
- Relevant components, files, services, or domain terms.
- For updates: verified facts only, with source files/URLs and confidence.

Expect back from retriever: memory IDs, entity IDs (if explored), titles, concise facts, and gaps.
Expect back from updater: actions performed (created/updated/linked/obsolete/entity), IDs touched, and retrieval verification.

## Anti-patterns

- Running `query_memory`/`create_memory` directly from the main agent when a subagent can isolate the work.
- Persisting speculative design notes before implementation is verified.
- Duplicating instructions from [memory.md](memory.md) or [hygiene.md](hygiene.md); link to them instead.
- Engaging Forgetful for trivial changes.
