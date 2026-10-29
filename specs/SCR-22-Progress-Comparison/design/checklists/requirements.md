# Design Requirements Checklist: SCR-22 — Progress Comparison

**Purpose**: Validate design specification completeness before handoff to engineering  
**Created**: 2026-09-13  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/0ae60956-1108-4f9f-b702-becad824cb17  

---

## Layout & Structure

- [ ] All 4 states documented (Loading, Empty, Main, Error)
- [ ] Navbar present in all 4 states confirmed ✅ (root-tab screen)
- [ ] Content area flex model specified for each state
- [ ] `overflow-y:auto` in Main state only (not Loading/Empty/Error)
- [ ] Appbar padding (`6px 20px 10px`) matches all 4 artboards
- [ ] Root-tab title tier (`22px/800/.02em`) applied to "Progress"

## Skeleton / Loading State

- [ ] Translate-shimmer variant specified (translateX -100%→100%, 1.4s infinite)
- [ ] Shimmer base colour `card-alt` (#2a2a2c)
- [ ] Shimmer sheen: `rgba(255,255,255,.06)` (token: `color.shimmerSheen`)
- [ ] 3 skeleton chips: `84×32px; border-radius:20px`
- [ ] Skeleton chart: `100%×150px; border-radius:10px` inside chart-card
- [ ] chart-card in loading: `card bg; border; radius:16px; padding:16px`
- [ ] 3 skeleton stats: `flex:1; height:66px; border-radius:14px`
- [ ] Loading navbar uses `opacity:.5` on inactive navitems

## Chip Selector

- [ ] Chip row `overflow-x:auto; padding-bottom:2px` in Main state
- [ ] Chips `flex:0 0 auto` in Main state (no shrink for scroll)
- [ ] Chip row `display:flex; gap:8px` (no overflow in Loading/Empty)
- [ ] Active chip: `lime bg; #131315 text; lime border; radius:20px; padding:8px 14px; 12px/700`
- [ ] Inactive chip: `card-alt bg; border; muted text; radius:20px; padding:8px 14px; 12px/700`
- [ ] Chip selector visible and interactive in Empty state (not skeletonised)

## Chart Card

- [ ] chart-card: `card bg; border; radius:16px; padding:16px; flex-col; gap:10px`
- [ ] chart-head: `flex; align-items:baseline; justify-content:space-between`
- [ ] chart-title: `13px/800/muted`; format: `"{Exercise} — {Metric}"`
- [ ] chart-metric: `11px/700/lime`; format: `"▲ {N} {unit} over {N} sessions"`
- [ ] SVG: `width:100%; height:150; viewBox:0 0 320 150; preserveAspectRatio:none`
- [ ] Grid lines: `stroke:#33332f; stroke-width:1` (3 horizontal lines at y=20/70/120) — token: `color.chartGrid`
- [ ] Axis labels: `font-size:9px; fill:#8a8f7a` (dim token)
- [ ] Y-axis labels at y=16/66/116 (left-aligned)
- [ ] X-axis labels at y=146 (first, middle, last data points)
- [ ] X-axis date format: abbreviated month + day (`"Jul 28"`)
- [ ] Trend line: `stroke:lime; stroke-width:2; fill:none; rounded linecap/linejoin`
- [ ] Regular dots: `r:4; fill:lime; stroke:card; stroke-width:2`
- [ ] Current (latest) dot: `r:5; fill:white; stroke:lime; stroke-width:2.5`

## Stat Row (Main State)

- [ ] section-label: `12px/800/uppercase/.06em/dim; margin-top:2px`
- [ ] Copy: "Latest Session"
- [ ] stat-row: `display:flex; gap:10px`
- [ ] stat-box: `flex:1; card bg; border; radius:14px; padding:12px; text-align:center`
- [ ] stat-label: `9px/700/uppercase/.04em/dim`
- [ ] stat-value: `15px/800; margin-top:4px`
- [ ] stat-delta: `10px/700/lime; margin-top:2px` — **new component, not in SCR-19/21**
- [ ] Stat tile labels: "TOP WEIGHT" · "BEST REPS" · "VOLUME"
- [ ] Volume uses comma thousands-separator (`1,820 kg`)
- [ ] stat-tiles are read-only (no tap interaction)

## Empty State

- [ ] empty-wrap: `flex:1 1 auto; flex-col; center; gap:14px; padding-bottom:60px`
- [ ] empty-icon: `52×52; dim; trend-up SVG; stroke-width:1.4`
- [ ] empty-title: `16px/800` — **"Not enough data yet"** (NOT the AC-2 copy)
- [ ] empty-sub: `13px/muted; line-height:1.5; max-width:250px` — **"Complete a few more workouts to see your progress."** (AC-2 copy with period)
- [ ] Chip row shown above empty-wrap (per-exercise empty, not full-screen)
- [ ] content padding: `0 20px` (no bottom padding — empty-wrap handles spacing)
- [ ] Empty state navbar has no `opacity:.5` on inactive items (matches Main)

## Error State

- [ ] error card: `card bg; #5c3a3a border; radius:16px; padding:26px 20px; gap:12px`
- [ ] err-icon: `40×40; danger (#ff6b6b); sharp alert-triangle`
- [ ] Sharp triangle: `M12 3l10 18H2L12 3z; stroke-width:1.6`
- [ ] err-title: `16px/800` — "Couldn't load your progress"
- [ ] err-sub: `13px/muted; line-height:1.5` — "Something went wrong reading local data.\nYour workout history is unaffected."
- [ ] retry-btn: `lime bg; #131315 text; 800/13px; radius:10px; padding:11px 22px; margin-top:4px`
- [ ] content: `flex-col; align-items:center; justify-content:center; padding:0 32px; gap:14px`
- [ ] Navbar present in Error state ✅ (root-tab — unlike SCR-21 which has no navbar)

## Navbar (all states)

- [ ] 6 tabs: Home, Plans, Schedule, History, Progress, Stats
- [ ] Progress (5th) active in all 4 states
- [ ] Active: `opacity:1; lime icon; lime label`
- [ ] Inactive: `opacity:.5` (Loading) / no opacity modifier (other states) — verify consistency with engineering
- [ ] navbar padding: `10px 14px 18px`
- [ ] Icon size: `22×22; stroke-width:1.8`
- [ ] Label: `10px/600/dim→lime`
- [ ] All 6 SVG paths documented in spec §3 Shared Chrome

## Token / Component Gaps (flag for design token PR)

- [ ] `#33332f` → `color.chartGrid` — **new token needed**
- [ ] `border-radius:20px` → `radius.chip` — **new token needed**
- [ ] `font-size:9px` → `text.axisLabel` — **new token needed (smallest text in system)**
- [ ] `font-size:11px` → `text.chartMetric` — **new token needed**
- [ ] `rgba(255,255,255,.06)` → `color.shimmerSheen` — (confirmed SCR-21, second occurrence)
- [ ] `font-weight:600` → `weight.medium` — (ongoing, multiple occurrences)

## Accessibility Checkpoints

- [ ] Chip touch target at 32px height — below 44pt; mitigation documented (OQ in spec)
- [ ] Retry button at ~40px height — below 44pt; mitigation documented
- [ ] Axis labels at 9px — WCAG AA failure at dim colour; documented as OQ-11
- [ ] VoiceOver semantics specified for chip selector (selected state)
- [ ] Chart SVG accessibility label documented
- [ ] stat-box semantic label includes delta value

## Responsive

- [ ] Chart SVG `preserveAspectRatio:none` — stretches to container width
- [ ] Chip row `overflow-x:auto` handles narrow viewports
- [ ] Stat row `display:flex; gap:10px` — tiles share available width equally

## Open Questions (blocking build)

- [ ] **OQ-3** — Initial chip selection order (alphabetical? frequency? most recent?) — **Engineering/PM must confirm before implementing chip default**
- [ ] **OQ-5** — Volume calculation: all valid sets × weight × reps? Confirm with PM
- [ ] **OQ-13** — "over N sessions" count: valid sessions only vs all sessions?
- [ ] **OQ-14** — Time-based exercise metric substitution (Duration instead of Weight/Volume)?

## Open Questions (non-blocking)

- [ ] OQ-1 — Empty state two-level copy (title + sub vs AC-2's single string)
- [ ] OQ-2 — Period in empty-sub (artboard has it; AC-2 doesn't)
- [ ] OQ-4 — Long exercise name chip: truncate or grow?
- [ ] OQ-6 — Negative delta: colour (danger?) and format (− prefix?)
- [ ] OQ-7 — Chart read-only in v1? No tooltip/scrub?
- [ ] OQ-8 — Cross-year X-axis date format
- [ ] OQ-9 — Zero completed sessions overall: global empty state?
- [ ] OQ-10 — SVG axis label position: fixed pixel vs. relative for production
- [ ] OQ-11 — 9px axis labels at dim: intentional or WCAG remediation needed?
- [ ] OQ-12 — Loading skeleton chip count: always 3?

---

*All blocking OQs (OQ-3, OQ-5, OQ-13, OQ-14) must be resolved before engineering picks up this story.*
