# Mode: project / branch recap

Input: repo, module path, or branch; optional time window (e.g. `2w`). Goal: rebuild the mental model after a context switch.

## Gather

README / AGENTS.md, top-level tree of the target module, `git status`, `git log --since=<window> --oneline`, open branches, TODO/FIXME in recently touched files, plan files in the repo's plan directory (e.g. `.cursor/plans/`), key entry points.

## Verify

Cite command output or `file:line` for state, names, recent activity, blockers, next steps. Do not fabricate momentum or rationale.

## Required sections

1. **Identity** - what it is, stack, entry points.
2. **Architecture snapshot** - SVG of conceptual modules and data flow.
3. **Recent activity** - grouped narrative (`.timeline`), not raw log.
4. **Current state** - uncommitted work, branches, TODOs, blockers (table + pills).
5. **Mental model map** - key modules, data flow, test/deploy paths.
6. **Risks / gotchas** - hotspots, cognitive debt.
7. **Useful commands and files** - compact table.
8. **Next steps** - evidence-based `.checklist`.

## Output

`~/.agent/diagrams/{topic}-recap.html`, then `open` it.
