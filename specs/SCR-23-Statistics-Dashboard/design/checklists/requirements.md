# Design Requirements Checklist: SCR-23 — Statistics Dashboard

**Purpose**: Validate design specification completeness before handoff to engineering  
**Created**: 2026-09-13  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/945dda3f-7b79-46bc-8be8-6ea87738478f  

---

## Layout & Structure

- [ ] All 4 states documented (Loading, Empty, Main, Error)
- [ ] Navbar present in all 4 states confirmed ✅ (root-tab screen)
- [ ] Content area flex model specified for each state
- [ ] `overflow-y:auto` in Main state only (not Loading/Empty/Error)
- [ ] Appbar padding `6px 20px 10px` matches all 4 artboards
- [ ] Root-tab title tier `22px/800/.02em` applied to "Stats"
- [ ] `stat-grid: display:grid; grid-template-columns:1fr 1fr; gap:10px` in Loading, Empty, Main

## Loading State

- [ ] Translate-shimmer: translateX -100%→100%, 1.4s infinite
- [ ] Shimmer base: `card-alt` (#2a2a2c); sheen: `rgba(255,255,255,.06)`
- [ ] 4 `sk-stat`: `height:88px; border-radius:14px` in 2-col grid
- [ ] 3 `sk-row`: `height:56px; border-radius:14px` (full width)
- [ ] Loading navbar: `opacity:.5` on inactive navitems

## Empty State — Stat Tiles

- [ ] stat-box: `card bg; border; radius:14px; padding:14px; flex-col; gap:6px; **opacity:.55**`
- [ ] stat-icon-wrap: `28×28; radius:8px; card-alt bg`
- [ ] stat-icon: `15×15; color:var(--dim)` — **dim** in empty (not lime)
- [ ] stat-value: `19px/800; color:var(--dim)` — dim text
- [ ] stat-label: `11px/muted`
- [ ] Zeroed values: `0` / `0 kg` / `0h 0m` / `—` (em dash for Avg. Duration)
- [ ] Avg. Duration uses `—` not `0` (undefined when no sessions)

## Empty State — Prompt Wrap

- [ ] prompt-wrap: `flex-col; align-items:center; text-align:center; gap:14px; padding:24px 12px`
- [ ] prompt-icon: `44×44; dim; bar-chart SVG (M5 20V10M12 20V4M19 20v-7); stroke-width:1.4`
- [ ] prompt-title: `16px/800` — **"No stats yet"**
- [ ] prompt-sub: `13px/muted; line-height:1.5; max-width:250px` — "Complete a workout to start building your statistics."
- [ ] cta-btn: `lime bg; #131315; 800/13px; radius:10px; padding:12px 22px; margin-top:2px` — **"Start a Workout"**
- [ ] Exercise Breakdown and Records sections **NOT shown** in Empty state
- [ ] Empty navbar has no `opacity:.5` on inactive navitems (unlike Loading)

## Main State — Stat Tiles

- [ ] stat-box: same geometry as empty but **no `opacity` modifier**
- [ ] stat-icon: `color:var(--lime)` — lime in Main (vs dim in empty)
- [ ] stat-value: `19px/800` — white text (default), no colour override
- [ ] Tile 1: checkmark icon `M20 6L9 17l-5-5`; label "Workouts Completed"; value integer
- [ ] Tile 2: barbell icon; label "Total Volume"; value `{N,NNN} kg` with thousands comma
- [ ] Tile 3: clock icon; label "Total Duration"; value `{N}h {N}m`
- [ ] Tile 4: trend-up icon; label "Avg. Duration"; value `{N} min` (or `{N}h {N}m` if ≥60 min — OQ-3)
- [ ] All stat icons `stroke-width:2`

## Main State — Exercise Breakdown

- [ ] section-label: `12px/800/uppercase/.06em/dim; margin-top:2px` — **"Exercise Breakdown"**
- [ ] ex-card: `card bg; border; radius:14px; padding:12px 14px; flex; align-items:center; gap:12px`
- [ ] type-dot: `8×8; radius:50%` — lime=weighted, cyan=time, muted=bodyweight
- [ ] ex-name: `13px/700`
- [ ] ex-meta: `11px/muted` — "{N} sessions"
- [ ] ex-right-value: `13px/800; text-align:right` — "65 kg" / "01:10" / "{N}"
- [ ] ex-right-label: `10px/dim; text-align:right` — "Best weight" / "Best time" / "Best reps"
- [ ] Exercise cards are **read-only** (no tap action, no disclosure chevron)

## Main State — Records / Personal Bests Link

- [ ] section-label: `12px/800/uppercase/.06em/dim; margin-top:2px` — **"Records"**
- [ ] pb-link: `card bg; border; radius:14px; padding:14px; flex; align-items:center; justify-content:space-between`
- [ ] pb-icon-wrap: `32×32; radius:8px; background:#1e2a12` (successFill — existing token)
- [ ] pb-icon: `16×16; lime` — trophy SVG (`M8 21h8 / M12 17v4 / M6 3h12v4...`); stroke-width:2
- [ ] pb-title: `13px/700` — "Personal Bests"
- [ ] pb-sub: `11px/muted` — "Your all-time top performances"
- [ ] chev: `16×16; dim` — `M9 18l6-6-6-6`
- [ ] pb-link is **interactive** — taps push to SCR-24
- [ ] pb-link shown **only in Main** (not Empty, not Error)

## Error State

- [ ] err-card: `card bg; #5c3a3a border; radius:16px; padding:26px 20px; gap:12px`
- [ ] err-icon: `40×40; danger (#ff6b6b); sharp alert-triangle; stroke-width:1.6`
- [ ] err-title: `16px/800` — **"Couldn't load your stats"**
- [ ] err-sub: `13px/muted; line-height:1.5` — "Something went wrong calculating your statistics.\nYour workout history is unaffected."
- [ ] retry-btn: `lime bg; #131315; 800/13px; radius:10px; padding:11px 22px; margin-top:4px`
- [ ] content: `flex-col; center; padding:0 32px; gap:14px`
- [ ] Navbar present in Error ✅

## Navbar (all states)

- [ ] 6 tabs: Home, Plans, Schedule, History, Progress, Stats
- [ ] Stats (6th) active in all 4 states
- [ ] Active: lime icon + lime label; `opacity:1`
- [ ] Inactive: dim icon + dim label; `opacity:.5` only in Loading, none in other states
- [ ] navbar padding: `10px 14px 18px`
- [ ] Icon: `22×22; stroke-width:1.8`
- [ ] Label: `10px/600`

## Stat Box Comparison: SCR-23 vs SCR-22

| Property | SCR-22 stat-box | SCR-23 stat-box |
|----------|----------------|----------------|
| padding | 12px | 14px |
| stat-label size | 9px | 11px |
| stat-value size | 15px | 19px |
| has icon-wrap | ❌ | ✅ (28×28; radius:8px) |
| has delta row | ✅ (stat-delta) | ❌ |
| grid layout | flex row | 2-col CSS grid |

## Token / Component Gaps (flag for token PR)

- [ ] `font-size:19px` → `text.statValue` — **new token needed**
- [ ] `font-size:11px` → `text.meta` — new token (recurs: stat-label, ex-meta, pb-sub)
- [ ] `border-radius:8px` → `radius.iconWrap` — new token (stat-icon-wrap, pb-icon-wrap)
- [ ] `rgba(255,255,255,.06)` → `color.shimmerSheen` — (third occurrence, same as SCR-21/22)
- [ ] `font-weight:600` → `weight.medium` — (ongoing)
- [ ] `#1e2a12` → `color.successFill` — (established in SCR-21; pb-icon-wrap reuses it)

## Accessibility Checkpoints

- [ ] CTA "Start a Workout" at ~40px height — below 44pt; OQ-2
- [ ] Retry button at ~40px height — below 44pt
- [ ] `opacity:.55` on empty stat tiles degrades colour contrast — OQ-10
- [ ] stat-icon dim on card-alt at 15×15 (non-text, icon) — decorative; WCAG non-text contrast 3:1 minimum applies
- [ ] ex-right-label at 10px/dim — borderline at 10px; passes large-text
- [ ] Personal Bests row semantic label includes both title and subtitle
- [ ] Exercise cards announced with full label (name + sessions + best value)

## Open Questions (blocking build)

- [ ] **OQ-1** — "Start a Workout" target screen — **Engineering/PM must confirm before implementing CTA navigation**
- [ ] **OQ-3** — Avg. Duration ≥60 min format: `{N}h {N}m` or `{N} min`?
- [ ] **OQ-4** — Bodyweight exercise right-column format ("Best reps" + integer)?
- [ ] **OQ-5** — Exercise breakdown sort order (session count desc assumed)?
- [ ] **OQ-12** — "Records" section always shown in Main (even before any PBs set)?
- [ ] **OQ-13** — AC-4 reactivity: reactive stream vs on-entry recalculation?
- [ ] **OQ-14** — Total Volume formula: same as SCR-22 OQ-5 resolution?

## Open Questions (non-blocking)

- [ ] OQ-2 — CTA height 44pt remediation
- [ ] OQ-6 — Time best value: `01:10` vs `1:10` vs `1m 10s`
- [ ] OQ-7 — Empty exercise breakdown: hide section-label or show empty?
- [ ] OQ-8 — Very large volume truncation
- [ ] OQ-9 — Long exercise name: 1-line or 2-line truncation?
- [ ] OQ-10 — `opacity:.55` accessibility remediation
- [ ] OQ-11 — `19px` as new token vs align to existing size
- [ ] OQ-15 — Error copy: "calculating" vs "reading"

---

*All blocking OQs must be resolved before engineering picks up this story.*
