# CSS patterns (offline page components)

All classes below already exist in [resources/page-template.html](resources/page-template.html). Copy markup, not CSS, unless building from scratch. Curated from [visual-explainer](https://github.com/nicobailon/visual-explainer) (MIT); every pattern is pure HTML/CSS/SVG, no libraries.

## Tokens and color schemes

- Palette lives in CSS custom properties on `:root`: `--bg --surface --border --text --text-dim --accent` + semantic `--ok --warn --danger --info` (+ `-bg` variants).
- `@media (prefers-color-scheme: light)` redefines tokens only; components never hard-code colors.
- Diagram figures stay dark (`figure.diagram { background: #020617 }`) in both schemes so the SVG palette from `reference.md` keeps contrast.
- Semantic color (pills, diff, severity) is separate from the accent hue.
- Fonts: system stacks only (`--mono`, `--sans`). Never `<link>` web fonts.

## Type scale

- `html { font-size: 16px }` is the single knob; page text in `rem`.
- Minimums: body 14px, labels 11px, mono 12px. SVG labels keep px from `reference.md`.
- Headings get `text-wrap: balance`; paragraphs `max-width: 70ch`; uppercase labels get `letter-spacing`.

## Overflow protection

```css
.grid > *, .flex > * { min-width: 0; }
body { overflow-wrap: break-word; }
.table-wrap, .tree, pre { overflow-x: auto; }
```

Never `display: flex` directly on `<li>` when list markers matter.

## KPI cards

Summary first, detail later. Only numbers that drive a decision.

```html
<div class="cards">
  <div class="ve-card"><div class="kpi-label">Files changed</div><div class="kpi-value">12</div></div>
  <div class="ve-card"><div class="kpi-label">Open risks</div><div class="kpi-value">2</div></div>
</div>
```

## Data table + status pills

Use for 4+ rows or 3+ columns. Numbers right-aligned with `td.num` (tabular-nums).

```html
<div class="table-wrap"><table>
  <thead><tr><th>Area</th><th>Severity</th><th>Evidence</th></tr></thead>
  <tbody>
    <tr><td>Data model</td><td><span class="pill danger">high</span></td><td><code>app/x.py:42</code></td></tr>
  </tbody>
</table></div>
```

Pill classes: `ok`, `warn`, `danger`, `info`.

Sticky first column for very wide tables:

```css
th:first-child, td:first-child { position: sticky; left: 0; z-index: 1; background: var(--surface-solid); }
```

## File tree (diff colors)

Green = added, amber = modified, red strike = deleted. Wrap in `<details>` if > ~20 lines.

```html
<div class="tree">app/
├── <span class="add">new_file.py</span>
├── <span class="mod">changed.py</span>
└── <span class="del">removed.py</span></div>
```

## Before / after panels

```html
<div class="compare">
  <div class="before"><h3>Before</h3><pre><code>old_call(x)</code></pre></div>
  <div class="after"><h3>After</h3><pre><code>new_call(value=x)</code></pre></div>
</div>
```

Collapses to one column under 900px.

## Timeline / phases

`li.done` green dot, `li.blocked` red dot, default accent. Only use numbered/ordered layouts when order is real.

```html
<ol class="timeline">
  <li class="done"><strong>Phase 1</strong><div class="meta">no deps</div></li>
  <li><strong>Phase 2</strong><div class="meta">needs phase 1</div></li>
</ol>
```

## Collapsibles

Reference material (raw output, long code, full file lists) goes in `<details>`. Template auto-expands them on print.

```html
<details><summary>Full diff stat</summary><pre>...</pre></details>
```

## Callout and checklist

```html
<div class="callout">Decision needed: ...</div>
<ul class="checklist"><li class="done">Migration applied</li><li>Integration tests added</li></ul>
```

## Pure-SVG charts (replace Chart.js)

Sparkline:

```html
<svg viewBox="0 0 100 30" width="100" height="30">
  <polyline points="0,25 15,20 30,22 45,10 60,15 75,5 100,8" fill="none" stroke="var(--accent)" stroke-width="1.5"/>
</svg>
```

Horizontal bar chart (width = value / max * chart width):

```html
<svg viewBox="0 0 400 90" width="100%">
  <text x="0" y="18" fill="var(--text-dim)" font-size="11">api</text>
  <rect x="80" y="8" width="240" height="14" rx="3" fill="var(--info)"/>
  <text x="326" y="19" fill="var(--text-dim)" font-size="11">60%</text>
  <text x="0" y="48" fill="var(--text-dim)" font-size="11">tasks</text>
  <rect x="80" y="38" width="120" height="14" rx="3" fill="var(--warn)"/>
  <text x="206" y="49" fill="var(--text-dim)" font-size="11">30%</text>
</svg>
```

Progress bar:

```html
<div style="height:6px;background:var(--border);border-radius:3px"><div style="height:100%;width:72%;background:var(--ok);border-radius:3px"></div></div>
```

## Sticky TOC + scroll spy

Template ships `nav.toc` + IntersectionObserver. Use for 4+ sections; one `<a href="#id">` per `section[id]`. On narrow screens it becomes a horizontal sticky bar. Works on `file://`.

## Design judgment

- Treatment: reviews, plans, recaps = polished-utilitarian (hierarchy, spacing, no flashy hero).
- Structure encodes something true: numbers only when order matters, dividers only at real seams.
- Depth sparingly: primary sections elevated, reference material flat or collapsed.
- No continuous pulse/glow animations, no emoji section markers, no gradient heroes.
- Microcopy names things readers recognize; buttons say exactly what they do.
