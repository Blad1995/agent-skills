---
name: forgetful
description: Single entry point for Forgetful MCP long-term memory — store/retrieve durable business/domain knowledge, model entities, explore the knowledge graph, keep memories clean (dedupe, obsolete, link), and decide when to engage memory across a feature lifecycle. Use when user mentions forgetful, MCP memory, save/load memory, domain knowledge, knowledge base, entities, memory hygiene, dedupe, stale memories, graph exploration, or when planning/wrapping up a non-trivial feature.
---

# Forgetful

Apply the `concise-english` skill when writing memory titles, content, and context fields (Strict mode — consumed by agents without human review).

## Sub-modules (read only what the task needs)

| Task | Read |
|---|---|
| When to engage memory in a feature; delegate to retriever/updater subagents | [lifecycle.md](lifecycle.md) |
| Store / load memories, documents, code artifacts | [memory.md](memory.md) + [memory-reference.md](memory-reference.md) |
| Model people, orgs, services, components; entity relationships | [entities.md](entities.md) |
| Flat search returns fragments across domains; graph walk | [explore.md](explore.md) |
| Dedupe, obsolete, link, clean memories | [hygiene.md](hygiene.md) + [hygiene-reference.md](hygiene-reference.md) |

## Tool Invocation Pattern (dual-mode)

Forgetful exposes tools in one of two layouts depending on server/client version. **Never assume one layout** — resolve at runtime:

1. **Flat registry (new)**: each tool is a direct MCP tool on `user-forgetful` (`create_memory`, `query_memory`, `create_entity`, …). Call directly:

   ```json
   {
     "server": "user-forgetful",
     "toolName": "create_memory",
     "arguments": { "title": "..." }
   }
   ```

2. **Meta-tools (legacy)**: only `discover_forgetful_tools`, `execute_forgetful_tool`, `how_to_use_forgetful_tool` are registered. Dispatch through them:
  
```json
   {
     "server": "user-forgetful",
     "toolName": "execute_forgetful_tool",
     "arguments": { "tool_name": "create_memory", "arguments": { "title": "..." } }
   }
   ```

Examples in sub-modules may use either form; translate to the available layout.

### Runbook (always follow this order)

1. List available tools on `user-forgetful` (tool catalog inspection or `discover_forgetful_tools(category="memory")` — also `document`, `code_artifact`, `entity`, `project`).
2. If the target tool (e.g. `create_memory`) is registered → call it **directly** with flat args.
3. Else if `execute_forgetful_tool` is registered → dispatch the target tool through it.
4. If neither → run `mcp_auth`, re-check, and only then report failure.

Do not hardcode `execute_forgetful_tool` — it was removed from the registry in newer server versions and calls fail with "Tool not found in registry".

Get any operation's schema at runtime via `how_to_use_forgetful_tool` (legacy) or the tool's own input schema (flat) — do not embed schemas here.

## What belongs in Forgetful (business logic only)

Store durable **domain / product / architecture** knowledge that future agents need without re-reading the repo:

- Routing rules, invariants, state machines, thresholds, contracts
- Workflow decisions (what happens when X; which path for legacy vs new)
- Service / module boundaries and ownership
- API / event semantics that are not obvious from a single file

## What must not be stored

- Test files, pytest cases, assertions, or "how to make test Y pass"
- Factories, fixtures, Scenario setup, Redis test helpers, mock/spy patterns
- CI, lint, formatting, or local run commands (unless the user explicitly asks)
- One-off debugging notes, stack traces, or chat transcripts
- Pure mechanical refactors with no behavior change

Litmus: if the only consumers are test authors, skip. If production code or product behavior depends on the fact, store it (cite `source_files` under production paths, not `test/`).
