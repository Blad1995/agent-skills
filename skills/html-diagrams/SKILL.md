---
name: html-diagrams
description: Creates offline, self-contained HTML visual explainers - hand-drawn SVG diagrams (architecture, process, sequence, state, data flow) and multi-section pages for implementation plans, plan reviews, diff reviews, project recaps, fact-checks, and complex tables. Zero external dependencies. Use when the user asks for an HTML diagram, visual plan, visual review, recap, or when output would otherwise be a large ASCII table or diagram.
---

# HTML Diagrams / Visual Explainers

Produce **one self-contained `.html` file**: embedded CSS, inline SVG, tiny vanilla JS. Opens offline in any browser; no build step.

Based on [Cocoon-AI architecture-diagram-generator](https://github.com/Cocoon-AI/architecture-diagram-generator/tree/main/architecture-diagram) (MIT) and [visual-explainer](https://github.com/nicobailon/visual-explainer) (MIT), stripped of all CDN/Node dependencies.

## Hard rule: no network

- No `<script src>`, no `<link href="http...">`, no web fonts, no CDN, no Mermaid/Chart.js/html2canvas.
- Fonts: system stacks (`ui-monospace, 'JetBrains Mono', SFMono-Regular, Menlo, monospace`).
- Charts: pure SVG (see `css-patterns.md`). Export: built-in "Download SVG" + "Print / PDF".
- Only allowed `http` strings: SVG `xmlns` URIs.

## When to use

- User asks for a diagram, visual plan/review/recap, or invokes a mode below.
- A table would have **4+ rows or 3+ columns** -> render HTML, give a short chat summary.
- A flow has **4+ nodes or branches** that ASCII would mangle.
- Chat-only plans keep Mermaid in markdown - many clients render it natively. Use HTML when the user wants a standalone visual artifact.

## Mode router

| Request | Read | Template |
|---------|------|----------|
| Single diagram | [reference.md](reference.md) | [resources/template.html](resources/template.html) |
| Visual implementation plan | [modes/plan.md](modes/plan.md) | [resources/page-template.html](resources/page-template.html) |
| Review a plan vs code | [modes/plan-review.md](modes/plan-review.md) | page-template |
| Review a diff / branch / MR | [modes/diff-review.md](modes/diff-review.md) | page-template |
| Context-switch recap | [modes/recap.md](modes/recap.md) | page-template |
| Verify a generated doc | [modes/fact-check.md](modes/fact-check.md) | existing file |
| Tables, cards, timelines, charts | [css-patterns.md](css-patterns.md) | page-template |

## Representation router

| Content | Use |
|---------|-----|
| Topology, services, infra | SVG architecture (reference.md) |
| Steps, decisions, pipelines | SVG process / data flow |
| Request/response over time | SVG sequence |
| Entity lifecycle | SVG state |
| 15+ elements | Small SVG overview + `.ve-card` detail grid |
| Comparison, audit, risk matrix | `<table>` + pills |
| Phases, roadmap, history | `.timeline` |
| Metrics | KPI cards + pure-SVG bars/sparklines |
| Code changes | `.tree` + `.compare` before/after |

## Evidence rule

Research before rendering. Every file, function, type, number, and behavior on the page must come from code, git, or tool output - cite `file:line` or the command. Mark proposed items as "new". Never invent rationale.

## What to draw

- Depict the mechanism, not its name (the path a request takes, not a box labeled "cache").
- **Label every arrow** (`writes`, `enqueues`, `polls 30s`).
- One figure, one claim - the `figcaption` states it.
- To compare options, draw the difference (edges added green, removed red dashed).

## Design system (SVG)

### Colors (semantic)

| Role | Fill | Stroke |
|------|------|--------|
| Frontend / UI | `rgba(8, 51, 68, 0.4)` | `#22d3ee` |
| Backend / service | `rgba(6, 78, 59, 0.4)` | `#34d399` |
| Database / store | `rgba(76, 29, 149, 0.4)` | `#a78bfa` |
| Cloud / external | `rgba(120, 53, 15, 0.3)` | `#fbbf24` |
| Security / auth | `rgba(136, 19, 55, 0.4)` | `#fb7185` |
| Message bus / async | `rgba(251, 146, 60, 0.3)` | `#fb923c` |
| Process step | `rgba(30, 58, 138, 0.4)` | `#60a5fa` |
| Decision | `rgba(113, 63, 18, 0.4)` | `#fbbf24` |
| Terminal (ok) | `rgba(6, 78, 59, 0.5)` | `#34d399` |
| Terminal (error) | `rgba(127, 29, 29, 0.4)` | `#f87171` |
| Generic | `rgba(30, 41, 59, 0.5)` | `#94a3b8` |

### Canvas and type

- SVG background: opaque `#020617` rect + grid pattern (`#1e293b`, 40x40) - opaque so exported SVG is not transparent.
- SVG sizes: 12px labels, 9px sublabels, 8px annotations, 7px tiny.
- Diagram figures stay dark in both color schemes; page chrome follows `prefers-color-scheme` (see css-patterns.md).

### SVG rules

1. **Paint order:** background -> grid -> arrows -> opaque mask rects -> semi-transparent shapes -> text.
2. **Mask arrows** behind boxes: opaque `fill="#0f172a"` rect under each semi-transparent box.
3. **Spacing:** 60px box height; **>=40px** gaps; buses sit in gaps, not on boxes.
4. **Legend:** below all boundaries; extend `viewBox` (+20px margin).
5. **No `<foreignObject>`**; only `rect`, `text`, `path`, `polygon`, `line`, `ellipse`.
6. Root `<svg>` has `xmlns`, `role="img"`, `aria-label` = the claim, and `font-family` set (needed for standalone SVG export).
7. Arrowhead marker:

```svg
<marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
  <polygon points="0 0, 10 3.5, 0 7" fill="#64748b" />
</marker>
```

With multiple SVGs on one page, give marker/pattern ids a per-figure suffix (`arrowhead-2`) to avoid collisions.

### Line styles

| Meaning | Style |
|---------|-------|
| Data / sync call | Solid `#64748b`, `marker-end` |
| Async / event | Dashed `#fb923c` |
| Auth / security | Dashed `#fb7185` |
| Optional / failure path | Dotted `#94a3b8` |
| Region / group boundary | `stroke-dasharray="8,4"`, amber |
| Security group | `stroke-dasharray="4,4"`, rose |

## Page rules (multi-section)

- Start from `page-template.html`; delete unused sections, never leave placeholders.
- Sticky TOC for 4+ sections; drop it otherwise.
- First viewport: title stating the outcome, lead sentence, KPI cards, main diagram.
- Reference material (raw output, long lists) in `<details>`.
- Polished-utilitarian: no pulse/glow, no emoji markers, no gradient heroes; respect `prefers-reduced-motion`.
- Diff color language: red removed, green added, amber modified/risk, blue context.

## Output

- Filename: `{topic}-{type}.html` (e.g. `order-fulfillment-process.html`, `feature-x-diff-review.html`).
- Default: `~/.agent/diagrams/`; `docs/diagrams/` in repo only when asked.
- Open with `open <file>` after writing. Mention once: "Download SVG" / "Print / PDF" in the header.

## Final checklist

```
- [ ] Mode / diagram type chosen; correct template copied
- [ ] Every claim backed by file:line or command output
- [ ] No network: rg -n 'https?://' <file> shows only xmlns
- [ ] viewBox fits all content + legend; no overlaps (>=40px gaps)
- [ ] Arrows behind boxes (mask rects); every arrow labeled
- [ ] Each figure: figcaption states claim; svg has role="img" + aria-label
- [ ] Unique marker/pattern ids per SVG
- [ ] Tables wrap long text; wide content scrolls, no page-level horizontal overflow
- [ ] Light and dark schemes readable; print preview sane
- [ ] Unused template sections removed
```
