# Reference: Memory Hygiene Decision Tree

## Decision Tree

1. New info arrives
2. Run `query_memory` for same concept (with `query_context`)
3. If strong match exists:
   - same concept + newer facts → `update_memory`
   - related but distinct → `link_memories`
   - about a modelled system → also `link_entity_to_memory`
4. If old memory is wrong/outdated:
   - create replacement (if needed)
   - `mark_memory_obsolete` with reason and `superseded_by` (not content-only supersede)
5. After create:
   - review auto-links from `create_memory`
   - add manual links for cross-domain, prerequisite, contrast, evolution
6. If link graph is noisy:
   - `unlink_memories` for weak/incorrect edges
7. Re-run `query_memory` to validate retrieval quality

## Compact Query Example

Dual-mode: newer servers register `query_memory` directly — call it with the inner `arguments` flat. Legacy servers only expose `execute_forgetful_tool` — wrap as below.

```json
{
  "server": "user-forgetful",
  "toolName": "execute_forgetful_tool",
  "arguments": {
    "tool_name": "query_memory",
    "arguments": {
      "query": "sector schedule breaking thresholds",
      "query_context": "dedupe before storing a new threshold memory",
      "k": 5,
      "include_links": true
    }
  }
}
```

## Compact Update Example

```json
{
  "server": "user-forgetful",
  "toolName": "execute_forgetful_tool",
  "arguments": {
    "tool_name": "update_memory",
    "arguments": {
      "memory_id": 84,
      "content": "Updated rule with cumulative ryanair thresholds.",
      "confidence": 0.98,
      "source_repo": "shot/waytogo",
      "source_files": ["internal/analysis/sector_schedules.go"]
    }
  }
}
```

## Suggested Hygiene Cadence

- After each substantial task: quick dedupe + links
- Weekly: stale-memory pass (`mark_memory_obsolete`)
- Monthly: tag normalization + `source_repo` normalization pass
