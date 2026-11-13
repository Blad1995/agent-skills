# HTML Diagrams — SVG patterns

## Architecture (C4-style boxes)

**Service box:**

```svg
<rect x="X" y="Y" width="140" height="60" rx="6" fill="#0f172a"/>
<rect x="X" y="Y" width="140" height="60" rx="6" fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1.5"/>
<text x="X+70" y="Y+24" fill="white" font-size="11" font-weight="600" text-anchor="middle">Service Name</text>
<text x="X+70" y="Y+40" fill="#94a3b8" font-size="9" text-anchor="middle">role / port</text>
```

**Region boundary:**

```svg
<rect x="X" y="Y" width="W" height="H" rx="12" fill="none" stroke="#fbbf24" stroke-width="1.5" stroke-dasharray="8,4"/>
<text x="X+12" y="Y+18" fill="#fbbf24" font-size="9">AWS Region: eu-west-1</text>
```

**Connection:**

```svg
<line x1="..." y1="..." x2="..." y2="..." stroke="#64748b" stroke-width="1.5" marker-end="url(#arrowhead)"/>
```

---

## Process / workflow

Layout: **top-to-bottom** (portrait) or **left-to-right** (wide flows). Standard step: 160×56; decision diamond: 100×56 center.

**Process step (rectangle):**

```svg
<rect x="X" y="Y" width="160" height="56" rx="6" fill="#0f172a"/>
<rect x="X" y="Y" width="160" height="56" rx="6" fill="rgba(30, 58, 138, 0.4)" stroke="#60a5fa" stroke-width="1.5"/>
<text x="X+80" y="Y+32" fill="white" font-size="11" font-weight="600" text-anchor="middle">Validate input</text>
```

**Decision (diamond via polygon):**

```svg
<polygon points="cx,cy-28 cx+50,cy cx,cy+28 cx-50,cy" fill="rgba(113, 63, 18, 0.4)" stroke="#fbbf24" stroke-width="1.5"/>
<text x="cx" y="cy+4" fill="white" font-size="10" text-anchor="middle">Eligible?</text>
```

**Start / end:**

```svg
<!-- start -->
<ellipse cx="cx" cy="cy" rx="48" ry="24" fill="rgba(6, 78, 59, 0.5)" stroke="#34d399" stroke-width="1.5"/>
<!-- end (error) -->
<ellipse cx="cx" cy="cy" rx="48" ry="24" fill="rgba(127, 29, 29, 0.4)" stroke="#f87171" stroke-width="1.5"/>
```

**Vertical connector with label:**

```svg
<line x1="cx" y1="y1" x2="cx" y2="y2" stroke="#64748b" stroke-width="1.5" marker-end="url(#arrowhead)"/>
<text x="cx+8" y="(y1+y2)/2" fill="#94a3b8" font-size="8">yes</text>
```

**Parallel fork** (optional): two arrows from one step to two boxes at the same Y band; join with a merge step below.

Spacing: step bottom + 40px = next step top. Decision branches need **horizontal spread** (±120px) before rejoining.

---

## Sequence diagram

- **Lifelines:** vertical dashed `#334155`, `stroke-dasharray="4,4"`, from actor box bottom to diagram bottom.
- **Actors:** 100×48 boxes at top; label centered.
- **Messages:** horizontal lines with `marker-end`; solid = sync, dashed = async.
- **Self-call:** small rect loop on one lifeline.
- **Activation:** narrow filled `#1e293b` bar on lifeline between message Y values.

```svg
<!-- actor -->
<rect x="X" y="40" width="100" height="48" rx="6" fill="rgba(30, 41, 59, 0.5)" stroke="#94a3b8" stroke-width="1.5"/>
<text x="X+50" y="68" fill="white" font-size="10" text-anchor="middle">API</text>
<!-- lifeline -->
<line x1="X+50" y1="88" x2="X+50" y2="500" stroke="#334155" stroke-dasharray="4,4"/>
<!-- message A -> B at y=120 -->
<line x1="xA" y1="120" x2="xB" y2="120" stroke="#64748b" marker-end="url(#arrowhead)"/>
<text x="(xA+xB)/2" y="112" fill="#94a3b8" font-size="8" text-anchor="middle">POST /fulfill</text>
```

Increase `viewBox` height with message count (~40px per message).

---

## State machine

- **States:** rounded rects `rx="10"`, blue fill for normal, green for terminal success, red for terminal failure.
- **Transitions:** curved paths or straight lines with `marker-end`; label at midpoint.

```svg
<rect x="X" y="Y" width="120" height="44" rx="10" fill="rgba(30, 58, 138, 0.4)" stroke="#60a5fa" stroke-width="1.5"/>
<text x="X+60" y="Y+26" fill="white" font-size="10" text-anchor="middle">processing</text>
```

Place states in a rough circle or layered rows; avoid crossing arrows when possible.

---

## Swimlanes (process + ownership)

Draw lane backgrounds first (full width, alternating `rgba(15,23,42,0.3)`), lane title rotated or left-aligned at top. Steps stay inside lane X bounds (padding 24px).

```svg
<rect x="40" y="80" width="920" height="140" fill="rgba(15, 23, 42, 0.3)" stroke="#1e293b"/>
<text x="52" y="100" fill="#64748b" font-size="9">API Backend</text>
```

---

## Legend block

Place at `y = max_boundary_bottom + 20`. Two-column grid of small swatches + labels (8px text).

```svg
<rect x="60" y="520" width="14" height="14" rx="3" fill="rgba(6, 78, 59, 0.4)" stroke="#34d399"/>
<text x="82" y="531" fill="#94a3b8" font-size="8">Backend service</text>
```

---

## viewBox sizing

| Diagram | Starting size | Grow when |
|---------|---------------|-----------|
| Architecture | 1000 × 680 | More regions/layers |
| Process (vertical) | 800 × 900+ | +80px per step |
| Sequence | 1000 × 120 + 40×messages | More actors/messages |
| State | 900 × 500 | More states |

Always re-check legend and cards fit inside `report-container` without clipping.
