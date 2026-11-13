# Forgetful — Store and Load Memories

Tool invocation (dual-mode) and what may/may not be stored: see [SKILL.md](SKILL.md).

## Step 1 — Route the type

| The content is... | Store as | Module |
|---|---|---|
| Single business fact, decision, or preference | Memory | this module |
| Detailed analysis or guide (>300 words) | Document + entry memories | this module |
| Reusable production code snippet | Code artifact + optional memory | this module |
| Person, org, service, component | Entity | [entities.md](entities.md) |
| Flat search returns fragments across domains | Graph walk | [explore.md](explore.md) |
| Tests, fixtures, trivial, or unverified | Skip | — |

## Step 2 — Resolve the project

Every write needs a deliberate `project_id`. Derive candidate from repo: `git remote get-url origin` → `owner/repo` → `list_projects` with `repo_name`. When no project matches, create one or ask; when several apply, ask.

Normalize `source_repo` to `owner/repo` (not `backend`, `gitlab.example.com/team/backend`, etc.).

## Step 3 — Query before create

Search for overlapping knowledge using the candidate's essence as the query. Both `query` and `query_context` are **required** — the call errors without `query_context`.

| Existing memory is... | Action |
|---|---|
| Still accurate and covers the point | Link if related; skip duplicate |
| Right but missing new detail | `update_memory` |
| Contradicted by new knowledge | `mark_memory_obsolete` + create replacement |
| Overlapping but distinct concept | Create new, then `link_memories` |

## Store Memory (Atomic, High-Signal)

Create one memory per concept. Atomicity test: title in ~10 words? Self-contained? ONE decision/fact/pattern?

Required fields:
- `title`: short and searchable (≤200 chars)
- `content`: one concept (≤2000 chars; ideal 200–400 words)
- `context`: why it matters (≤500 chars)
- `keywords`: search terms (≤10)
- `tags`: grouping labels (≤10)
- `importance`: 1-10
- `project_ids`: from Step 2

Recommended provenance fields:
- `source_repo` (normalized `owner/repo`)
- `source_files`
- `source_url`
- `confidence`
- `encoding_agent`
- `encoding_version`

### Importance rubric

About 70% of memories belong at 7–8; reserve 9–10 for foundational knowledge.

| Band | Use for |
|---|---|
| 9–10 | Foundational: architectural principles in constant use |
| 8–9 | Critical solutions, major decisions |
| 7–8 | Useful patterns, preferences, standard implementations |
| 6–7 | Milestones, minor context |
| 5 | Noise floor: bulk/automated captures meant to stay out of normal recall |

### Save Template

Flat args (add the `tool_name` wrapper only when dispatching via `execute_forgetful_tool`):

```json
{
  "tool_name": "create_memory",
  "arguments": {
    "title": "Short decision title",
    "content": "Single concept and outcome.",
    "context": "Why this matters for future tasks.",
    "keywords": ["domain", "component", "decision"],
    "tags": ["decision", "documentation"],
    "importance": 8,
    "project_ids": [1],
    "source_repo": "org/repo",
    "source_files": ["path/file.go"],
    "confidence": 0.9,
    "encoding_agent": "cursor-agent"
  }
}
```

After create, review auto-links returned by `create_memory`. Add manual `link_memories` for cross-domain, prerequisite, contrast, or evolution links that embeddings miss.

### Long-form and code variants

- **>300 words:** `create_document`, then 3–7 atomic entry memories with `document_ids`, each linked to relevant entities via `link_entity_to_memory`.
- **Reusable code:** `create_code_artifact`; add a memory pointing at it when the *decision* behind the code matters.

## Load Memory (Domain Knowledge Before Changes)

Use semantic search first, then drill down. For fragmented results across named systems, escalate to [explore.md](explore.md).

### Required query shape

Both `query` and `query_context` are required. Include exact identifiers verbatim (error codes, function names, config keys).

### Scope deliberately

Reads are cross-project by default. Narrow with:
- `project_ids` when task is project-bound
- `strict_project_filter=True` to keep linked memories inside those projects
- `importance_threshold` to cut noise (pairs with rubric; 5 = bulk floor)
- `k` for breadth vs focus (default 3; raise to 10–20 for broad entry)

### Handle truncation and misses

- `truncated: true` → narrow query (raise threshold, scope project) instead of accepting silent loss
- Miss on first angle → re-query from a different facet before concluding absence
- Re-entering a project after time away → `get_recent_memories` scoped to project ID

1. Query for task-relevant knowledge via `query_memory`
2. Open specific memory via `get_memory(memory_id=...)`
3. Follow linked documents/code via `get_document` / `get_code_artifact`
4. If stale → `update_memory`; if wrong → [hygiene.md](hygiene.md)

### Load Template

```json
{
  "tool_name": "query_memory",
  "arguments": {
    "query": "How do we classify breaking payment failures?",
    "query_context": "Implementing or documenting analysis logic",
    "k": 5,
    "include_links": true,
    "importance_threshold": 6
  }
}
```

## Deep gather (main chat only)

When the user asks for a full cited context pack (not delegated to retriever subagent):

1. Derive 3–5 query angles from the task (feature area, technology, error text, layer, adjacent domains)
2. Run `query_memory` per angle with task intent in `query_context`
3. Escalate strongest hits via [explore.md](explore.md) if fragmented
4. Open linked material: `get_document`, `get_code_artifact`; title-scan `list_documents` / `list_code_artifacts` when project-scoped
5. Synthesize: decisions, patterns, constraints, code pointers, gaps — all cited by memory ID

## Good Practices

- Store business decisions and thresholds immediately after verification.
- Prefer production `source_files` (e.g. `src/…`); mention tests only as provenance that behavior was verified, never as the memory subject.
- Keep memories atomic; split large topics; cite other IDs (`see memory #N`) instead of duplicating.
- Use consistent tags (`analysis`, `thresholds`, `workflow`, `api`).
- Link related memories, documents, artifacts, and entities when available.

## Avoid

- Storing test setup, factories, fixtures, or “fix pattern” memories.
- Dumping full transcripts into one memory.
- Omitting `query_context` on retrieval.
- Saving unverifiable claims without confidence/provenance.
- Rewriting a memory when `update_memory` is enough.
- Stating "supersedes #N" in content without calling `mark_memory_obsolete`.

See [reference.md](reference.md) for compact examples and decision flow.
