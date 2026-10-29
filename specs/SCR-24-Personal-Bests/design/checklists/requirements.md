# Design Requirements Checklist: SCR-24 — Personal Bests

**Purpose**: Validate design specification completeness before handoff to engineering  
**Created**: 2026-09-13  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/7f74011d-61bf-4f48-b2d1-88ef016334b5

> ⚠️ **Blocking**: OQ-1 (PB metric definition) must be resolved before AC-3 can be implemented. Do not hand off to engineering until Decisions Log §3 is closed.

---

## Layout & Structure

- [ ] Screen type confirmed as pushed (overlay/detail tier) — NOT a root tab
- [ ] No navbar in any of the 4 states ✅ (confirmed across all artboards)
- [ ] Appbar padding `6px 20px 4px` (bottom 4px, not 10px) in all 4 states
- [ ] Back arrow present in all 4 states; `22×22; white; stroke-width:2; M15 18l-6-6 6-6`
- [ ] Title "Personal Bests" at overlay/detail tier `18px/800/.02em` in all 4 states
- [ ] `overflow-y:auto` only in Main state; not in Loading/Empty/Error

## Loading State

- [ ] 5 sk-rows rendered (not 4, not 3)
- [ ] sk-row: `card bg; border:1px solid border; border-radius:14px; padding:12px 14px; flex; align-items:center; gap:12px`
- [ ] sk-dot: `8×8; radius:50%; card-alt bg` — **static** (not animated)
- [ ] sk-line: `flex:1; height:14px; border-radius:6px` — **bg-position shimmer** (NOT translate shimmer)
- [ ] sk-badge: `56×38px; border-radius:10px; card-alt bg` — **static** (not animated)
- [ ] Shimmer variant: bg-position (`100%→0%`), not translateX — **same as SCR-20, not SCR-21/22/23**
- [ ] Shimmer: `linear-gradient(90deg, card-alt 25%, #35342f 37%, card-alt 63%); background-size:400% 100%; ease 1.4s`
- [ ] Content: `padding:18px 20px 28px; flex-col; gap:10px`
- [ ] No navbar ✅

## Empty State

- [ ] Content: `flex-col; align-items:center; justify-content:center; padding:0 32px 60px; text-align:center; gap:14px`
- [ ] empty-icon: `52×52; dim; stroke-width:1.4` — trophy SVG
  - `<path d="M8 21h8M12 17v4M6 3h12v4a6 6 0 0 1-12 0V3z"/>`
  - `<path d="M6 5H4a2 2 0 0 0 2 4M18 5h2a2 2 0 0 1-2 4"/>`
- [ ] empty-title: `16px/800` — "No personal bests yet"
- [ ] empty-sub: `13px/muted; line-height:1.5; max-width:250px` — "Complete a workout to start setting personal bests."
- [ ] **No CTA button** in empty state (contrast with SCR-23 empty which has "Start a Workout")
- [ ] No navbar ✅

## Main State — pb-card Structure

- [ ] pb-card: `flex; align-items:center; gap:12px; card bg; border:1px solid border; border-radius:14px; padding:12px 14px`
- [ ] type-dot: `8×8; radius:50%` — lime=weighted, cyan=time, muted=bodyweight
- [ ] pb-body: `flex:1 1 auto; flex-col; gap:2px`
- [ ] pb-name: **`14px/700; color:white`** (NOTE: 14px, not 13px; first 14px usage in system)
- [ ] pb-meta: `11px/muted` — date format "Set {Mon} {D}, {YYYY}" — OQ-3
- [ ] pb-badge: `card-alt bg; border:1px solid border; border-radius:10px; padding:8px 12px; text-align:center`
- [ ] pb-badge-value: `14px/800; color:white`
- [ ] pb-badge-label: `9px/dim; uppercase; letter-spacing:.03em; margin-top:1px` — production label TBD (OQ-2)
- [ ] pb-cards are **read-only** — no tap action, no chevron

## Main State — Layout & Design Note

- [ ] Content: `overflow-y:auto; padding:14px 20px 28px; flex-col; gap:10px`
- [ ] **Amber design-note banner (`.tbd-banner`) does NOT ship** — artboard annotation only
  - Colours `#2a2610`/`#d9c94a`/`#6b5f22` are not real app colours
- [ ] `overflow-y:auto` enables scroll for long lists
- [ ] No navbar ✅

## Error State

- [ ] err-card: `card bg; #5c3a3a border; border-radius:16px; padding:26px 20px; flex-col; align-items:center; gap:12px`
- [ ] err-icon: `40×40; danger (#ff6b6b); stroke-width:1.6` — alert-triangle SVG
- [ ] err-title: `16px/800` — **"Couldn't load your personal bests"** (differs from SCR-23 "…your stats")
- [ ] err-sub: `13px/muted; line-height:1.5` — "Something went wrong calculating this data.\nYour workout history is unaffected."
  - Note: SCR-24 says "this data" (not "your statistics" as in SCR-23) — confirm copy is intentionally different
- [ ] retry-btn: `lime bg; #131315; 800/13px; border-radius:10px; padding:11px 22px; margin-top:4px`
- [ ] Content: `flex-col; align-items:center; justify-content:center; padding:0 32px; text-align:center; gap:14px`
- [ ] **No navbar** ✅ (unlike SCR-23 error which has navbar — pushed screen has none)

## Shimmer Variant Confirmation

| State | Variant | Animation |
|-------|---------|-----------|
| SCR-24 Loading sk-line | **bg-position** (SCR-20 pattern) | `background-position: 100%→0%` |
| SCR-21/22/23 Loading | translate (SCR-21 pattern) | `translateX(-100%→100%)` |

SCR-24 uses the bg-position variant despite SCR-21/22/23 using translate. Confirm with designer whether this divergence is intentional or a design-note artefact.

## pb-card vs ex-card Comparison (SCR-23 vs SCR-24)

| Property | SCR-23 ex-card right col | SCR-24 pb-badge |
|----------|--------------------------|----------------|
| Background | none (transparent) | `card-alt` (#2a2a2c) |
| Border | none | `1px solid border` (#444933) |
| Border-radius | none | `10px` |
| Padding | none | `8px 12px` |
| Value size | `13px/800` | `14px/800` |
| Label size | `10px/dim` | `9px/dim` |
| Label tracking | not specified | `.03em` |
| Label transform | none | `uppercase` |

## Token / Component Gaps (flag for token PR)

- [ ] `font-size:14px` → `text.cardTitle` — **NEW token needed** (pb-name; first 14px in system)
- [ ] `letter-spacing:.03em` → `tracking.badgeLabel` — **NEW token** (pb-badge-label; distinct from `.06em` section-label)
- [ ] `font-size:9px` → `text.axisLabel` (SCR-22) — confirm shared token with pb-badge-label (same size, different context)
- [ ] `#35342f` → `color.shimmerMid` — established SCR-20; reused here ✅
- [ ] `#5c3a3a` → `color.dangerBorder` — established SCR-20; reused ✅
- [ ] `border-radius:10px` → `radius.dialogButton` — established; pb-badge reuses ✅

## Accessibility Checkpoints

- [ ] Back arrow: semantic label "Back" or "Go back to Statistics"
- [ ] pb-card: announced as one unit — name + type + date + value
- [ ] pb-badge-label `9px` — below readable threshold; use `semanticsLabel` override or exclude from a11y tree
- [ ] empty-icon: decorative — `excludeFromSemantics: true`
- [ ] err-icon: decorative — `excludeFromSemantics: true`
- [ ] Retry button: ~40px height below 44pt; add `minHeight: 44px` — OQ-10
- [ ] type-dot: colour-only; not sole differentiator (name and label provide independent context)
- [ ] Screen title announced on push: "Personal Bests"

## Open Questions (blocking build)

- [ ] **OQ-1** — PB metric definition DEFERRED (Decisions Log §3): which metric(s) count as a PB? **All of Main state is blocked on this.**
- [ ] **OQ-2** — Production badge label content (depends on OQ-1 resolution)
- [ ] **OQ-3** — pb-meta date format: "Set Aug 31, 2026" — locale-aware or fixed en-US?

## Open Questions (non-blocking)

- [ ] OQ-4 — Long pb-name: 1-line ellipsis or 2-line wrap?
- [ ] OQ-5 — Time badge value format: `01:10` vs `1:10` vs `1m 10s`?
- [ ] OQ-6 — Weighted badge units: `kg` fixed or localised to `lbs`?
- [ ] OQ-7 — PB update on new session: reactive stream or on-entry read?
- [ ] OQ-8 — 0-second timed PB: show `00:00`?
- [ ] OQ-9 — Very large badge value truncation strategy
- [ ] OQ-10 — Retry button 44pt height remediation
- [ ] OQ-11 — `9px` shared `text.axisLabel` token or separate `text.badgeLabel`?
- [ ] OQ-12 — `letter-spacing:.03em` new `tracking.badgeLabel` token confirmation
- [ ] OQ-13 — `font-size:14px` new `text.cardTitle` token confirmation
- [ ] OQ-14 — pb-card list sort order (alphabetical / date / type)?
- [ ] OQ-15 — Max records shown: all or capped?
- [ ] OQ-16 — SCR-24 shimmer variant (bg-position) vs SCR-21/22/23 (translate): intentional divergence?
- [ ] OQ-17 — Error copy: "this data" vs "your statistics" — intentionally different from SCR-23?

---

*OQ-1, OQ-2, and OQ-3 are blocking. All other OQs may be resolved during engineering without a spec revision.*
