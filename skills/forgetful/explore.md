# Exploring the knowledge graph

A flat query answers "what matches"; exploration answers "how it connects". Output is a synthesized picture with cited IDs — never a raw dump of hops.

Invoke operations per the dual-mode runbook in [SKILL.md](SKILL.md).

## Choose a depth first

- **Shallow** (phases 1–2): confirm or refresh something specific.
- **Medium** (phases 1–4): understand a topic and its immediate neighbourhood.
- **Deep** (all phases): cross-project investigation or "everything we know about X".

Track visited memory and entity IDs throughout — a revisited ID means that branch is done.

## Phase 1 — Semantic entry

Broad `query_memory` on the topic with `query_context` stating investigation intent. Favour breadth: raise `k` above default (max 20).

Done when: a handful of strong entry memories are identified.

## Phase 2 — Expand the strongest hits

`get_memory` on each entry point for full content and linked memory IDs; follow links that bear on the question.

Done when: each entry point's local cluster is understood.

## Phase 3 — Discover the entities

Collect entities referenced by expanded memories; `search_entities` for obvious actors (systems, people, components) that memories may not name directly.

Create missing entities per [entities.md](entities.md) only when needed for the investigation — do not bootstrap entire repos.

Done when: the cast of relevant entities is listed.

## Phase 4 — Walk the relationships

`get_entity_relationships` on each relevant entity; follow types that answer the question (`depends_on` for impact, `part_of` for structure, `owns` for responsibility).

Done when: connections between entities are mapped; cycles skipped via visited set.

## Phase 5 — Harvest entity-linked memories

`get_entity_memories` on central entities — surfaces knowledge attached to the *thing* that topic queries miss. Returns linked IDs + titles; `get_memory` per chosen ID for full text.

Done when: central entities have had attached knowledge collected.

## Synthesize

Report the picture, not the walk:
- What is known and how it connects
- Where knowledge is thin
- Cite memory and entity IDs
- State traversal path in one line (e.g. "query → 3 memories → Backoff entity → 2 dependents → 5 linked memories")

Done when: user gets a connected answer with cited IDs and visible gaps.

## When to use

- Retriever subagent escalates here when flat recall is fragmented.
- Main agent uses this when investigating cross-cutting concerns (service boundaries, incident history across repos).
- Do not use for simple single-fact lookup — `query_memory` + `get_memory` is enough.
