# Reference: Forgetful Memory Ops

## Decision Flow

1. Is it business logic / domain decision? If only tests/fixtures/CI → **skip**
2. Route type (memory / document / code_artifact / entity / explore / skip)
3. Resolve `project_id` via `list_projects` + git remote
4. `query_memory` before create
5. Need short reusable concept → `create_memory`
6. Need long-form guide/spec → `create_document`, then extract entry memories with `document_ids`
7. Need reusable **production** code → `create_code_artifact`, optional memory for the decision
8. Need to search domain context → `query_memory` (both `query` + `query_context` required)
9. Need full record → `get_memory`
10. Need correction/new details → `update_memory`
11. Need relationship graph → `link_memories`, `link_entity_to_memory`
12. Fragmented cross-domain hits → [explore.md](explore.md)

## Minimal Save Example

Dual-mode: newer servers register `create_memory` directly — call it with the inner `arguments` object directly. Legacy servers only expose `execute_forgetful_tool` — wrap as below.

```json
{
  "server": "user-forgetful",
  "toolName": "execute_forgetful_tool",
  "arguments": {
    "tool_name": "create_memory",
    "arguments": {
      "title": "Rule: US rerouting airport changes are breaking",
      "content": "For US-touching segments, station-code changes emit airport_changed_us.",
      "context": "Used by order cancellation severity analysis.",
      "keywords": ["us", "rerouting", "airport_changed_us"],
      "tags": ["analysis", "rules"],
      "importance": 8,
      "project_ids": [1],
      "source_repo": "shot/waytogo",
      "source_files": ["internal/analysis/sector_rerouting.go"],
      "confidence": 0.98,
      "encoding_agent": "cursor-agent"
    }
  }
}
```

## Minimal Load Example

```json
{
  "server": "user-forgetful",
  "toolName": "execute_forgetful_tool",
  "arguments": {
    "tool_name": "query_memory",
    "arguments": {
      "query": "breaking thresholds for sector schedule changes",
      "query_context": "Need rules before updating docs or code",
      "k": 5,
      "include_links": true,
      "importance_threshold": 6
    }
  }
}
```

## Re-entry catch-up

```json
{
  "tool_name": "get_recent_memories",
  "arguments": {
    "project_ids": [1],
    "limit": 10
  }
}
```

## Practical Retrieval Loop

1. Run `query_memory` with `query_context`; check `truncated`
2. Re-query from different facet if thin
3. For each strong hit, run `get_memory`
4. Escalate to [explore.md](explore.md) if fragmented
5. Cross-check against repo files/docs
6. If outdated, run `update_memory` with provenance
7. Link related memories/entities

## Suggested Tags

- `rules`
- `thresholds`
- `analysis`
- `workflow`
- `decision`
- `incident`
