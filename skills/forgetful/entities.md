# Modelling entities in Forgetful

Entities are the graph's nouns. Model the thing once, then let knowledge accrue through links — that is what makes `get_entity_memories` a useful reverse lookup later.

Invoke operations per the dual-mode runbook in [SKILL.md](SKILL.md).

## Step 1 — Apply the litmus, then dedupe

Can you point at it? "Backoff API" is an entity; "Backoff returns 409 on duplicate postpone" is a memory linked to it.

Before creating, `search_entities` for the thing under likely names — matches both `name` and `aka`. Set `aka` at creation for alternative names.

Done when: the thing either already exists (use it) or is confirmed new.

## Step 2 — Create with a type

`create_entity` with name and type: Organization, Individual, Team, Device, System, or Other (`custom_type` when Other).

Check `list_entities` for types already in use and match them — inconsistent typing fragments reverse lookups.

Common mappings for this workspace:
- Services/APIs/workers → `System`
- Teams/ squads → `Team`
- External orgs/vendors → `Organization`

Done when: entity exists once, typed consistently with the existing graph.

## Step 3 — Link knowledge and projects as they accrue

- `link_entity_to_memory` whenever a memory is *about* the entity — at capture time, not later archaeology.
- `link_entity_to_project` when the entity belongs to a project's world.

Done when: knowledge about the thing is reachable from the thing via `get_entity_memories`.

## Step 4 — Record relationships between entities

`create_entity_relationship` with direction and type. Keep vocabulary small and consistent:
- `part_of` — composition (service in monorepo)
- `depends_on` — coupling (service → database)
- `owns` — responsibility
- `uses` — consumption

Check `get_entity_relationships` on either entity first; reuse types already in the graph. Direction carries meaning: A `depends_on` B is a statement about A.

Done when: relationships that answer impact/structure/responsibility questions are recorded without duplicating edges.

## When another module routes here

From [memory.md](memory.md) or `forgetful-memory-updater`: create/search entity first, write the fact as a memory, then `link_entity_to_memory`.

From [explore.md](explore.md): entities discovered during graph walk may need creation if missing, then relationship harvest continues.
