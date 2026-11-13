# Forgetful Memory Hygiene

Use this module to keep memory storage clean, current, and easy to retrieve.

## Quick Workflow

1. Search before creating:
   - `query_memory` with clear `query_context`
2. Decide action:
   - duplicate → update existing or link
   - stale → `mark_memory_obsolete` + `superseded_by` (not just "supersedes #N" in content)
   - valid but fragmented → link related memories/entities/documents
3. Apply change:
   - `update_memory`, `link_memories`, `unlink_memories`, `mark_memory_obsolete`, `link_entity_to_memory`
4. Verify:
   - re-run `query_memory` for the same topic

## Hygiene Rules (Lightweight)

- Prefer updating a near-duplicate over creating a new copy.
- Keep one concept per memory; split mixed memories.
- When a memory is outdated, `mark_memory_obsolete` with reason and `superseded_by` — preserve audit trail.
- Prefer `mark_memory_obsolete` + `superseded_by` over stating "supersedes #N" only in content.
- Link strongly related memories to improve recall context.
- Keep tags/keywords consistent across related topics.
- Normalize `source_repo` to `owner/repo` on updates.
- Preserve provenance on important updates.

## Action Guide

### 1) Deduplicate

Run semantic search first. If an existing memory already captures the concept:
- update that memory with new details, or
- keep both and `link_memories` if they represent distinct angles.
- cite existing IDs in new content (`see memory #N`; do not duplicate contracts).

### 2) Handle stale/incorrect knowledge

Use `mark_memory_obsolete` with a reason.
If there is a replacement memory, set `superseded_by`.
Do not leave old IDs live with only a content note that they were superseded.

### 3) Maintain graph quality

- Link related memories (`link_memories`) for discoverability.
- Link memories to entities (`link_entity_to_memory`) when knowledge is *about* a modelled system.
- Link entry memories to documents via `document_ids` at create/update time.
- Remove noisy/incorrect links (`unlink_memories`) when relationships are weak or wrong.
- After `create_memory`, review auto-links; add manual links for four kinds embeddings miss:
  - **Cross-domain** connections
  - **Prerequisite** chains
  - **Contrast** (this-not-that)
  - **Evolution** (old approach → new approach)

## Minimal Examples

Dual-mode: newer servers register tools directly on `user-forgetful` — call e.g. `mark_memory_obsolete` with the inner `arguments` flat. Legacy servers only expose `execute_forgetful_tool` — wrap as below. Check which layout is available first.

```json
{
  "server": "user-forgetful",
  "toolName": "execute_forgetful_tool",
  "arguments": {
    "tool_name": "mark_memory_obsolete",
    "arguments": {
      "memory_id": 42,
      "reason": "Replaced by updated threshold rules",
      "superseded_by": 84
    }
  }
}
```

```json
{
  "server": "user-forgetful",
  "toolName": "execute_forgetful_tool",
  "arguments": {
    "tool_name": "link_memories",
    "arguments": {
      "memory_id": 84,
      "related_ids": [85, 90]
    }
  }
}
```

```json
{
  "server": "user-forgetful",
  "toolName": "execute_forgetful_tool",
  "arguments": {
    "tool_name": "link_entity_to_memory",
    "arguments": {
      "entity_id": 3,
      "memory_id": 84
    }
  }
}
```

## Anti-Patterns

- Creating a new memory without checking for existing matches.
- Overwriting old decisions instead of preserving audit trail.
- Keeping broad "kitchen sink" memories with multiple unrelated concepts.
- Ignoring low-confidence facts without provenance.
- Inconsistent `source_repo` naming across related memories.

See [reference.md](reference.md) for a compact decision tree.
