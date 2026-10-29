# Design Specification: SCR-22 — Progress Comparison

**Story ID**: US-SCR-22  
**Feature**: Compare workout performance across sessions per exercise  
**Priority**: High  
**Created**: 2026-09-13  
**Artboard reference**: https://claude.ai/code/artifact/0ae60956-1108-4f9f-b702-becad824cb17  
**Artboards**: Loading.dc.html · Empty.dc.html · Main.dc.html · Error.dc.html  

---

## 1 · Overview & Goal

### Problem
A user who has completed multiple workouts has no way to see whether their performance — how much they lifted, how many reps, total volume — is improving over time. The Progress screen gives them a per-exercise trend view calculated entirely from local Drift history.

### User
An app-unlocked ForgeApp user reviewing their training progress. They have completed at least two valid sessions for one exercise to see populated data; otherwise the screen shows an empty state for that exercise while still allowing them to select others.

### Goal
Surface an exercise-by-exercise performance trend from completed local workout sessions. The chart is the primary deliverable; the stat tiles below it quantify the latest session's performance relative to the previous one.

### Success metric
- AC-1: Skeleton shown while calculation is in progress.
- AC-2: Empty state "Complete a few more workouts to see your progress" shown when fewer than two valid sessions exist for the selected exercise.
- AC-3: Populated chart and stat tiles shown when sufficient history exists.
- AC-4: Invalid/incomplete sessions silently excluded from the calculation (no gap or error in the chart).
- EC-1: Error state with Retry on Drift read/calculation failure.

### App context
**Fully offline, local-only.** Progress is calculated from the `workout_sessions` table. No network calls; no connectivity failure mode. Progress data is computed in the app layer (Dart/Flutter isolate or compute call) by aggregating per-exercise performance records from the session snapshot. FR-6 / NFR-4 (offline state) were removed 2026-09-05 — not applicable.

**Security constraints (inviolable)**:
- No network calls. No REST/GraphQL/gRPC client.
- Drift is the single source of truth.
- No Git/GitHub operations from automation.
- No new dependencies outside the ADR-030 governed set.
- App must be unlocked (SEC-1) before progress data is accessible.

### Functional requirements
- **FR-1**: Show skeleton while progress data is being calculated/fetched.
- **FR-2**: Show empty state when fewer than two valid completed sessions exist for the selected exercise.
- **FR-3**: Show comparison view (line chart + stat tiles) when sufficient valid history exists.
- **FR-4**: Silently exclude incomplete/invalid sessions from the calculation (no gap, no error representation for excluded sessions).
- **FR-5**: Show error state with Retry on Drift read/calculation failure.

---

## 2 · User Flow

### Entry
- **Primary**: Progress tab (5th of 6 in bottom navbar) from any root-tab screen (SCR-06 Home, SCR-20 History, SCR-22 Progress, etc.). Direct tap on the Progress navitem.

### Exit
- **Tab switch**: any of the 5 other bottom-navbar tabs (Home, Plans, Schedule, History, Stats). The navbar is present in all states including Error.
- **No push navigation exits** are defined. Progress is a terminal root-tab screen; tapping exercises or stat tiles does not navigate away (read-only view).

### State machine
```
[Entry via Progress tab]
         │
         ▼
  ┌──────────────┐
  │   LOADING    │  Drift read + calculation in progress
  └──────┬───────┘
         │
     ┌───┴─────────────────┐
     │                     │
     ▼                     ▼
  ┌───────┐          ┌───────────┐
  │ MAIN  │          │   ERROR   │◄─ Retry ─┐
  └───┬───┘          └─────┬─────┘          │
      │                    └────────────────┘
      │
  [Selected exercise chip changes]
      │
      ├─────────────────────┐
      │                     │
      ▼                     ▼
  ┌───────┐          ┌───────────┐
  │ MAIN  │          │   EMPTY   │
  │(chart)│          │(per-exer.)│
  └───────┘          └───────────┘
```

**Key flow distinction**: Main and Empty are **per-exercise sub-states within the populated view**, not top-level screen states. After the initial Drift calculation succeeds, the chip selector is always visible. Tapping a chip for an exercise with insufficient data shows Empty; tapping one with sufficient data shows Main (chart + stats). Error replaces the entire content when the calculation fails outright.

**Initial exercise selected**: The first chip in the row (by default) is selected on screen entry. If that exercise has sufficient data, Main is shown; if not, Empty.

### Navigation pattern
Root-tab screen. Bottom navbar persistent in all states. No push navigation from this screen in the current scope.

---

## 3 · Screen-by-Screen Breakdown

### Shared chrome (all states)

**Status bar** — `height:28px; flex:0 0 auto`

**Appbar** — `padding:6px 20px 10px; flex:0 0 auto`
- Title: `font-size:22px; font-weight:800; letter-spacing:.02em` — **"Progress"**
- **Root-tab title tier**: `22px/800/.02em` — same as SCR-20 "History". No back arrow, no trailing icons.

**Bottom navbar** — `flex:0 0 auto; display:flex; align-items:center; justify-content:space-between; padding:10px 14px 18px; border-top:1px solid var(--border); background:var(--bg)`
- 6 tabs; Progress (5th) is active.
- Inactive navitem: `opacity:.5` (Loading artboard) / `color:var(--dim)` (other states)
- Active navitem: `opacity:1; icon color:var(--lime); label color:var(--lime)`
- Label: `font-size:10px; color:var(--dim→lime); font-weight:600`
- Icon: `22×22px; stroke-width:1.8`

| Tab | Icon SVG | Label |
|-----|----------|-------|
| Home (1) | `M4 11l8-7 8 7 / M6 10v9h12v-9` | Home |
| Plans (2) | `M4 7h16 / M4 12h16 / M4 17h10` | Plans |
| Schedule (3) | `rect x4 y5 w16 h15 rx2 / M4 10h16 / M8 3v4 / M16 3v4` | Schedule |
| History (4) | `circle cx12 cy12 r8 / M12 8v4l3 2` | History |
| **Progress (5)** | `M4 17l5-5 4 3 7-8 / M15 7h5v5` | **Progress** |
| Stats (6) | `M5 20V10 / M12 20V4 / M19 20v-7` | Stats |

---

### State A · Loading

**Purpose**: Prevent empty-screen flash while Drift read and calculation are in progress. Skeleton mirrors the exact layout of the Main state.

**Content area** — `flex:1 1 auto; padding:0 20px 12px; display:flex; flex-direction:column; gap:16px` (no `overflow-y:auto` during loading)

**Shimmer variant**: Translate-based (same as SCR-21) — `::after { background:linear-gradient(90deg, transparent, rgba(255,255,255,.06), transparent); animation:shimmer 1.4s infinite; transform:translateX(-100%)→translateX(100%) }`

**Skeleton layout** (top to bottom):

| Element | CSS | Mirrors |
|---------|-----|---------|
| `.chip-row` | `display:flex; gap:8px` | chip selector row |
| `.sk-chip` ×3 | `width:84px; height:32px; border-radius:20px` | exercise chips |
| `.chart-card` | `background:var(--card); border:1px solid var(--border); border-radius:16px; padding:16px` | real chart card |
| `.sk-chart` | `width:100%; height:150px; border-radius:10px` | SVG chart canvas |
| `.stat-row` | `display:flex; gap:10px` | stat tile row |
| `.sk-stat` ×3 | `flex:1; height:66px; border-radius:14px` | stat boxes |

> **Skeleton geometry**: `sk-chip` at `84×32` mirrors the widest chip ("Bench Press" is ~84px wide at 12px/700 + 14px×2 padding). `sk-chart` at `height:150px` mirrors the SVG height exactly. `sk-stat` at `height:66px` mirrors a `stat-box` with `padding:12px` + 9px label + 4px margin + 15px value + 2px margin + 10px delta + 12px padding bottom ≈ 64–68px — close enough. The three skeleton chips hint at the chip row depth without revealing exercise names.

---

### State B · Empty (Insufficient history for selected exercise)

**Purpose**: Explain that the selected exercise lacks enough history, while leaving the chip row interactive so the user can select a different exercise that may have sufficient data.

**Content area** — `flex:1 1 auto; padding:0 20px; display:flex; flex-direction:column; gap:16px` (no `overflow-y:auto`)

**Chip row** — visible and interactive with real chips (not skeletons):
- Active chip: `background:var(--lime); color:#131315; border-color:var(--lime); border-radius:20px; padding:8px 14px; font-size:12px; font-weight:700`
- Inactive chip: `background:var(--card-alt); border:1px solid var(--border); border-radius:20px; padding:8px 14px; font-size:12px; font-weight:700; color:var(--muted)`
- Artboard examples: "Overhead Press" (active) · "Push-Ups" (inactive)

**Empty wrap** — `flex:1 1 auto; display:flex; flex-direction:column; align-items:center; justify-content:center; text-align:center; gap:14px; padding-bottom:60px`

| Element | CSS | Copy |
|---------|-----|------|
| `.empty-icon` | `width:52px; height:52px; color:var(--dim)` | Trend-up chart SVG (see below) |
| `.empty-title` | `font-size:16px; font-weight:800` | "Not enough data yet" |
| `.empty-sub` | `font-size:13px; color:var(--muted); line-height:1.5; max-width:250px` | "Complete a few more workouts to see your progress." |

**Empty icon SVG** (trend-up/progress chart icon — same icon as the Progress tab):
```svg
<path d="M4 17l5-5 4 3 7-8"/>
<path d="M15 7h5v5"/>
stroke-width:1.4; fill:none
```

> **Copy note — AC-2 alignment**: AC-2 specifies the exact copy as "Complete a few more workouts to see your progress" (no period). The artboard shows this text as the **sub-text** (`.empty-sub`), not the title. The artboard also adds a period not present in the AC. The artboard copy governs layout; the AC copy governs the semantic text of the sub-element. The artboard's period is an artboard addition (OQ-2 — confirm with PM/Design).

> **Empty `padding-bottom:60px`**: Same 60px bottom offset as SCR-20 and SCR-21 empty/error states — centres content in the space above the navbar rather than the full viewport. Consistent pattern.

> **State scope**: This is a **per-exercise empty state** — it applies only to the selected chip, not the whole screen. The chip row remains interactive. A user can tap a different exercise chip and see Main state for that exercise.

---

### State C · Main (Populated — chart + stats)

**Purpose**: Display a weight-trend line chart for the selected exercise across valid sessions, with a stat tile row summarising the latest session's performance vs the previous.

**Content area** — `flex:1 1 auto; overflow-y:auto; padding:0 20px 12px; display:flex; flex-direction:column; gap:16px`

#### Chip selector row — `.chip-row`
`display:flex; gap:8px; overflow-x:auto; padding-bottom:2px`

- Chips: `flex:0 0 auto` (prevents chips from shrinking — essential for horizontal scroll)
- Active: `background:var(--lime); color:#131315; border-color:var(--lime); border-radius:20px; padding:8px 14px; font-size:12px; font-weight:700`
- Inactive: `background:var(--card-alt); border:1px solid var(--border); border-radius:20px; padding:8px 14px; font-size:12px; font-weight:700; color:var(--muted)`
- Artboard examples: **Bench Press** (active) · Shoulder Press · Push-Ups · Plank Hold

> **Chip row horizontal scroll**: `overflow-x:auto; padding-bottom:2px`. The 2px padding-bottom prevents the chip border from being clipped by the scroll container. When there are more exercises than fit on screen (e.g. 4+ chips at 390px), the row scrolls. `flex:0 0 auto` on each chip preserves their intrinsic width.

#### Chart card — `.chart-card`
`background:var(--card); border:1px solid var(--border); border-radius:16px; padding:16px; display:flex; flex-direction:column; gap:10px`

**Chart header — `.chart-head`**:
`display:flex; align-items:baseline; justify-content:space-between`

| Element | CSS | Example copy |
|---------|-----|-------------|
| `.chart-title` | `font-size:13px; font-weight:800; color:var(--muted)` | "Barbell Bench Press — Weight" |
| `.chart-metric` | `font-size:11px; font-weight:700; color:var(--lime)` | "▲ 8 kg over 6 sessions" |

**Chart title format**: `"{Exercise full name} — {Metric}"` e.g. "Barbell Bench Press — Weight". The `—` is an em-dash U+2014 (or visual equivalent in the artboard).

**Chart metric format**: `"▲ {delta} {unit} over {N} sessions"` — uses ▲ (U+25B2) as the positive trend indicator; colour lime.

**SVG chart canvas**:
`width:100%; height:150; viewBox:0 0 320 150; preserveAspectRatio:none`

**Grid lines — `.grid-line`**:
`stroke:#33332f; stroke-width:1`
- 3 horizontal grid lines at y=20, y=70, y=120

**Axis labels — `.axis-label`**:
`font-size:9px; fill:#8a8f7a; font-family:'Helvetica Neue', Arial, sans-serif`
- Y-axis (left): "65kg", "60kg", "55kg" at y=16, 66, 116
- X-axis (bottom): "Jul 28", "Aug 18", "Sep 7" at y=146 (first, middle, last data points)
- Date format: `"Mon D"` (abbreviated 3-letter month + day without leading zero)

**Trend line — `.trend-line`**:
`stroke:#c3f400; stroke-width:2; fill:none; stroke-linecap:round; stroke-linejoin:round`

**Regular data dots — `.trend-dot`**:
`fill:#c3f400; stroke:#201f22; stroke-width:2; r:4`
- Lime-filled, card-coloured border ring

**Current/latest dot — `.trend-dot.current`**:
`fill:#f5f6f1; stroke:#c3f400; stroke-width:2.5; r:5`
- White-filled, lime ring, larger radius (5 vs 4) — visually emphasises the most recent data point
- Applied to the **last** (rightmost) data point

**Artboard chart data** (Bench Press, 6 sessions):
| Session | Approx date | SVG coords | Weight (implied) |
|---------|------------|------------|-----------------|
| 1 (oldest) | ~Jul 28 | (30, 110) | ~55kg |
| 2 | — | (90, 100) | ~57kg |
| 3 | — | (150, 85) | ~59kg |
| 4 | — | (210, 70) | ~61kg |
| 5 | — | (270, 55) | ~63kg |
| 6 (latest) | Sep 7 | (310, 40) | ~65kg |

> The chart uses proportional Y-coordinates. `y=40` maps to 65kg (highest), `y=120` maps to 55kg (lowest). Y-axis range in this example: 55–65kg (10kg span shown across 100px of usable height).

#### Section label — `.section-label`
`font-size:12px; font-weight:800; text-transform:uppercase; letter-spacing:.06em; color:var(--dim); margin-top:2px`
Copy: **"Latest Session"**

> Same component as SCR-21's `section-label` — same font, same uppercase, same `letter-spacing:.06em`. One difference: `margin-top:2px` here vs `margin-top:4px` in SCR-21. This is context-specific spacing (SCR-22 sits directly in a flex gap, SCR-21 had slightly more visual air needed).

#### Stat row — `.stat-row`
`display:flex; gap:10px`

**Stat box — `.stat-box`**:
`flex:1; background:var(--card); border:1px solid var(--border); border-radius:14px; padding:12px; text-align:center`

| Sub-element | CSS | Example values |
|-------------|-----|----------------|
| `.stat-label` | `font-size:9px; color:var(--dim); text-transform:uppercase; letter-spacing:.04em; font-weight:700` | "TOP WEIGHT" · "BEST REPS" · "VOLUME" |
| `.stat-value` | `font-size:15px; font-weight:800; margin-top:4px` | "65 kg" · "8" · "1,820 kg" |
| `.stat-delta` | `font-size:10px; color:var(--lime); font-weight:700; margin-top:2px` | "+5 kg" · "+1" · "+140 kg" |

**Stat tiles for Bench Press latest session**:
| Tile | Label | Value | Delta |
|------|-------|-------|-------|
| 1 | Top Weight | 65 kg | +5 kg |
| 2 | Best Reps | 8 | +1 |
| 3 | Volume | 1,820 kg | +140 kg |

> **SCR-22 stat box vs SCR-21 stat box**: SCR-22 uses `padding:12px` (vs 14px), `font-size:9px` stat-label (vs 10px), `font-size:15px` stat-value (vs 18px). The smaller type accommodates the `stat-delta` row below without making the tile too tall. The `stat-delta` element is unique to SCR-22 — SCR-21 had no delta display.

> **Volume calculation**: Volume = total weight × total reps across all sets. "1,820 kg" with comma thousands-separator. Exact formula (all sets vs. best set, inclusion of skipped sets) is unspecified — see OQ-5.

> **Positive delta only**: The artboard shows only positive deltas (lime colour). Negative delta colour and format are unspecified — see OQ-6.

---

### State D · Error

**Purpose**: Communicate a Drift read or calculation failure; let the user retry without leaving the screen.

**Content area** — `flex:1 1 auto; display:flex; flex-direction:column; align-items:center; justify-content:center; padding:0 32px; text-align:center; gap:14px`

**Error card — `.err-card`**:
`width:100%; background:var(--card); border:1px solid #5c3a3a; border-radius:16px; padding:26px 20px; display:flex; flex-direction:column; align-items:center; gap:12px`

| Element | CSS | Copy |
|---------|-----|------|
| `.err-icon` | `width:40px; height:40px; color:var(--danger)` | Sharp alert-triangle (see below) |
| `.err-title` | `font-size:16px; font-weight:800` | "Couldn't load your progress" |
| `.err-sub` | `font-size:13px; color:var(--muted); line-height:1.5` | "Something went wrong reading local data.\nYour workout history is unaffected." |
| `.retry-btn` | `margin-top:4px; background:var(--lime); color:#131315; font-weight:800; font-size:13px; border-radius:10px; padding:11px 22px` | "Retry" |

**Alert-triangle SVG** (sharp variant — same as SCR-20, SCR-21):
```svg
<path d="M12 3l10 18H2L12 3z"/>
<path d="M12 10v4"/>
<circle cx="12" cy="17" r="0.6" fill="currentColor"/>
stroke-width:1.6; fill:none
```

> **Error has navbar**: Unlike SCR-21 (a pushed detail screen), SCR-22 is a root-tab screen. The navbar is present in Error state, allowing the user to switch tabs without Retrying.

> **Error copy comparison**:
> - SCR-21: "Couldn't load this workout" / "Your workout history is unaffected."
> - SCR-22: "Couldn't load your progress" / "Your workout history is unaffected."
>
> Same reassurance line — calms fear that the underlying data is lost; only the calculated progress view failed.

---

## 4 · Interactions & Behaviour

| # | Trigger | Response | Notes |
|---|---------|----------|-------|
| 1 | Screen entered via Progress tab | Show Loading state; begin Drift read + calculation | Immediate; no delay threshold |
| 2 | Calculation succeeds | Transition Loading → Main/Empty (depending on selected exercise data sufficiency) | No animation specified; instant swap |
| 3 | Calculation fails | Transition Loading → Error | No delay |
| 4 | Tap inactive chip | Active chip changes; chart/stats update to the tapped exercise | If newly selected exercise has <2 valid sessions, show Empty; else Main |
| 5 | Tap active chip | No-op | Chip is already selected |
| 6 | Horizontal scroll chip row | Reveals chips beyond visible width | `overflow-x:auto` on chip-row; `flex:0 0 auto` keeps chips full-width |
| 7 | Tap Retry (Error state) | Transition Error → Loading; re-trigger Drift read + calculation | Guard against double-tap |
| 8 | Scroll content (Main state) | `overflow-y:auto` — vertical scroll for content below the visible area | Appbar + navbar stay fixed |
| 9 | Tap navbar tab (any state) | Switch to the selected root-tab screen | Standard root-tab switch |
| 10 | Tap stat tile (Main state) | No action — stat tiles are read-only | No tap affordance |
| 11 | Tap chart canvas area (Main state) | No action in current scope | Chart is read-only; tooltip/scrub interaction not specified (OQ-7) |

**Chip selection transition**: No animation specified; instant content swap between Empty and Main when a chip is selected.

**Chip row initial state on screen entry**: During Loading, 3 skeleton chips are shown. After calculation, the first chip in the exercise list is selected by default (OQ-3 — confirm ordering).

---

## 5 · Edge Cases & Error Handling

| # | Scenario | Behaviour |
|---|----------|-----------|
| EC-1 | Drift read/calculation throws exception | Show Error state with Retry |
| EC-2 | All exercises have <2 valid sessions | Loading completes → chip row shows all exercises → all chips show Empty state when selected. No "no data" overlay; the chip row + per-exercise empty is the correct representation |
| EC-3 | Only 1 exercise in the plan | Chip row shows 1 chip; selecting it may show Main or Empty depending on session count |
| EC-4 | Invalid/incomplete session in history | Silently excluded from chart (FR-4/NFR-2); no gap rendered in the trend line; chart appears continuous |
| EC-5 | All sessions for a given exercise are invalid/incomplete | Falls back to Empty state for that exercise (effectively <2 valid sessions) |
| EC-6 | Very long exercise name in chip | Chip text truncates or chip grows; `overflow-x:auto` on chip row accommodates width — OQ-4 |
| EC-7 | Very large session count (50+ sessions for one exercise) | Chart displays all valid sessions across the SVG viewport; density and legibility at scale — OQ-7 |
| EC-8 | Sessions span multiple years | X-axis date labels should include year for cross-year data — OQ-8 |
| EC-9 | Calculation produces negative delta (performance regression) | Delta format and colour for negative values unspecified — OQ-6 |
| EC-10 | Retry succeeds after prior Error | Replace Error state with Loading → Main/Empty transition |
| EC-11 | Screen entered with zero completed sessions | No exercises appear in chip row; screen shows an all-exercises empty state — OQ-9 |

---

## 6 · Responsive & Platform Considerations

**Device widths**:
- Artboard: 390 × 844px (iPhone 14 reference).
- Narrower (375px, iPhone SE): Chart SVG scales with `width:100%` and `preserveAspectRatio:none` — stretchable. Chips at `padding:8px 14px` may cause the chip row to overflow earlier, triggering horizontal scroll sooner.
- Wider (430px, Pro Max): SVG chart fills wider; stat boxes expand; more chips may fit without scrolling.

**Chart SVG scaling**: `preserveAspectRatio:none` — the chart fills its container width and height exactly. On very narrow screens, data point labels (axis labels at `font-size:9px`) remain at a fixed artboard-relative position and may overlap if the viewBox is scaled non-uniformly. OQ-10.

**Orientation**: Portrait only (ForgeApp global constraint).

**Safe area**: Bottom navbar covers the home indicator. `padding:10px 14px 18px` on navbar accounts for the standard iOS home indicator (18px matches the home indicator height). Content `padding-bottom:12px` (Main/Loading) or `padding-bottom:60px` (Empty) does not add further safe-area offset — the navbar itself handles it.

**Platform-specific**:
- iOS: Swipe-from-left-edge is not applicable (this is a root tab, not a pushed screen).
- Android: System back from a root tab exits the app or returns to the launcher — standard Android behaviour.
- Chip row horizontal scroll: on iOS the scroll has momentum; on Android it may scroll without momentum (default Flutter ListView/ScrollView behaviour).

---

## 7 · Accessibility

### Touch targets

| Target | Artboard size | 44pt compliant? |
|--------|--------------|----------------|
| Exercise chip | ~84×32px (artboard) | ❌ Height 32px below 44pt — increase to min `padding:14px 14px` or wrap in 44pt `GestureDetector` hit area |
| Retry button | ~115×40px | ❌ Slightly under 44pt height — increase to `padding:13px 22px` |
| Nav tab items | 52×(22icon+4gap+10label)≈52×46px | ✅ |
| Stat tiles (read-only) | N/A | N/A — not interactive |

### Colour contrast

| Pair | Foreground | Background | Ratio (approx) | AA (4.5:1)? |
|------|-----------|------------|-----------------|-------------|
| Appbar "Progress" white on bg | #f5f6f1 | #131315 | ~20:1 | ✅ |
| chart-title muted on card | #c4c9ac | #201f22 | ~9:1 | ✅ |
| chart-metric lime on card | #c3f400 | #201f22 | ~12:1 | ✅ |
| axis-label dim on card | #8a8f7a | #201f22 | ~4.2:1 | ❌ at 9px — systemic dim issue; 9px fails even large-text exception (18px bold threshold) |
| stat-label dim on card | #8a8f7a | #201f22 | ~4.2:1 | ❌ at 9px — same; worse than SCR-21's 10px |
| stat-value white on card | #f5f6f1 | #201f22 | ~18:1 | ✅ |
| stat-delta lime on card | #c3f400 | #201f22 | ~12:1 | ✅ |
| section-label dim on bg | #8a8f7a | #131315 | ~4.4:1 | ❌ at 12px/800 — systemic; passes large-text (3:1 min) at 12px bold ≥14px bold threshold is borderline |
| active chip #131315 on lime | #131315 | #c3f400 | ~17:1 | ✅ |
| inactive chip muted on card-alt | #c4c9ac | #2a2a2c | ~8:1 | ✅ |
| empty-title white on bg | #f5f6f1 | #131315 | ~20:1 | ✅ |
| empty-sub muted on bg | #c4c9ac | #131315 | ~10:1 | ✅ |
| err-title white on card | #f5f6f1 | #201f22 | ~18:1 | ✅ |
| err-sub muted on card | #c4c9ac | #201f22 | ~9:1 | ✅ |
| retry lime bg / dark text | #131315 | #c3f400 | ~17:1 | ✅ |
| grid-line on card bg | #33332f | #201f22 | ~1.3:1 | N/A — decorative structural element, not text |

> **Axis label at 9px**: This is the smallest text in the system so far (previous minimum was 10px on stat-labels in SCR-20/21). At `9px`, WCAG AA is not achievable with `dim` colour without a dedicated higher-contrast token. Either raise to 10px or use `white` at reduced opacity. OQ-11.

### Semantic roles

| Element | Flutter widget / semantic |
|---------|--------------------------|
| Screen title "Progress" | `AppBar.title` / `Semantics(header: true)` |
| Chip selector (chip row) | `SingleChildScrollView(scrollDirection:Axis.horizontal)` + `Row`; each chip: `GestureDetector` with `Semantics(label: '{exercise name}', button: true, selected: true/false)` |
| Active chip | `Semantics(selected: true)` |
| Chart card | `Semantics(label: '{exercise name} weight trend, {N} sessions, {delta}')` |
| Chart SVG | `ExcludeSemantics` or `Semantics(label: 'Weight trend chart for {exercise}')` — SVG data point semantics not necessary at this stage |
| section-label "Latest Session" | `Semantics(header: true)` |
| stat-box | `Semantics(label: '{LABEL}: {VALUE}, {DELTA}')` e.g. "Top Weight: 65 kg, plus 5 kg" |
| Empty icon | `Semantics(excludeSemantics: true)` — decorative |
| empty-title | `Text` — primary message |
| empty-sub | `Text` |
| err-card | `Semantics(liveRegion: true)` if shown after Loading |
| retry-btn | `ElevatedButton` + `Semantics(label: 'Retry loading progress')` |
| Skeleton elements | Container-level `Semantics(label: 'Loading progress data', excludeSemantics: true)` |

### Focus management
- On screen entry: focus on the first chip (or chip-row container).
- On chip tap: focus stays on the selected chip; chart/empty updates in place.
- On Retry: focus returns to Retry button after reload resolves.
- VoiceOver/TalkBack should announce chip row as a horizontal scrolling selector, not a list.

---

## 8 · Component & Design System Mapping

### Existing components (re-used)

| Component | Usage in SCR-22 |
|-----------|----------------|
| Root-tab appbar (`22px/800/.02em`) | "Progress" title — same tier as SCR-20 |
| Bottom navbar (6-tab) | Progress (5th) active; same as SCR-20 |
| Translate-shimmer skeleton | Loading skeleton — same `::after` translateX pattern as SCR-21 |
| Error card (`err-card`) | `card; #5c3a3a border; border-radius:16px; padding:26px 20px` — same as SCR-20/21 |
| Sharp alert-triangle | `M12 3l10 18H2L12 3z; stroke-width:1.6` — same as SCR-20/21 |
| Retry button (inline) | `lime bg; #131315 text; 800/13px; radius:10px; padding:11px 22px` — same as SCR-20/21 |
| `section-label` | `12px/800/uppercase/.06em/dim; margin-top:2px` — same component as SCR-21, 2px vs 4px margin variation |
| `stat-box` | Same geometry family as SCR-21/19 — smaller type here to accommodate delta row |

### New components / patterns

| Component | Description | Key CSS |
|-----------|-------------|---------|
| `exercise-chip` | Horizontal-scrolling exercise selector chip | `flex:0 0 auto; card-alt/lime bg; radius:20px; padding:8px 14px; 12px/700` — active: lime bg + #131315 text |
| `chip-row` (scrollable) | Horizontally scrollable chip container | `display:flex; gap:8px; overflow-x:auto; padding-bottom:2px` |
| `chart-card` | Card container for chart + header | `card; border; radius:16px; padding:16px; flex-col; gap:10px` |
| `chart-head` | Title + metric summary row above chart | `flex; align-items:baseline; justify-content:space-between` |
| `chart-title` | "{Exercise} — {Metric}" sub-label | `13px/800/muted` |
| `chart-metric` | "▲ N unit over N sessions" trend summary | `11px/700/lime` |
| `trend-line` | SVG polyline for weight-over-sessions | `stroke:lime; 2px; rounded linecap/linejoin` |
| `trend-dot` | Regular session data point | `r:4; lime fill; card stroke; stroke-width:2` |
| `trend-dot.current` | Most recent session emphasis dot | `r:5; white fill; lime stroke; stroke-width:2.5` |
| `grid-line` | Horizontal chart grid rule | `stroke:#33332f; stroke-width:1` |
| `axis-label` | Y-axis weight labels + X-axis date labels | `font-size:9px; fill:dim (#8a8f7a)` |
| `stat-delta` | Per-metric delta vs prior session | `10px/700/lime; margin-top:2px` — new element (not in SCR-19/21 stat tiles) |
| `empty-icon` (progress) | Trend-up chart icon as empty state illustration | `52×52; dim; stroke-width:1.4` — uses Progress tab icon |

### Token gaps

| Raw value | Proposed token | Occurrences |
|-----------|---------------|-------------|
| `#33332f` | `color.chartGrid` | Chart grid lines (first occurrence) |
| `▲` U+25B2 | `icon.trendUp` | chart-metric positive indicator |
| `font-size:9px` | `text.axisLabel` | axis-label, stat-label (chart context) — smallest text in system |
| `border-radius:20px` | `radius.chip` | exercise chip radius (first occurrence) |
| `font-size:11px` | `text.chartMetric` | chart-metric (new; 11px sits between `text.caption:10px` and `text.small:12px`) |
| `rgba(255,255,255,.06)` | `color.shimmerSheen` | (same as SCR-21 — second occurrence) |
| `font-weight:600` | `weight.medium` | navitem label (same as SCR-20/21 — multiple occurrences) |

---

## 9 · Acceptance Criteria Mapping

| Criterion | Source | Verification |
|-----------|--------|-------------|
| AC-1: Skeleton shown while loading | FR-1 | Loading state with chip-row skeleton + chart skeleton + stat-row skeleton visible from screen entry until calculation completes |
| AC-2: Empty state for exercise with <2 valid sessions | FR-2 | Chip selector visible and interactive; empty-wrap shown with "Not enough data yet" title + "Complete a few more workouts to see your progress." sub |
| AC-3: Populated comparison view for sufficient history | FR-3 | Chart card with trend line + data dots + axis labels; section-label "Latest Session"; 3 stat tiles with label/value/delta |
| AC-4: Invalid/incomplete sessions excluded silently | FR-4, NFR-1, NFR-2 | Chart trend line appears continuous (no gap); no visual error indicator for excluded sessions; data-layer only |
| EC-1: Error state with Retry on load/calculation failure | FR-5, NFR-3 | Error card with "Couldn't load your progress"; Retry button; navbar present |

---

## 10 · Open Questions / Assumptions

| # | Question | Owner | Build-blocker? | Assumption held |
|---|----------|-------|---------------|----------------|
| OQ-1 | Empty state two-level copy: "Not enough data yet" (title) + "Complete a few more workouts to see your progress." (sub) — AC-2 lists only the sub copy. Is the title correct? | Design/PM | No | Both lines as artboard; AC-2 met via sub-text |
| OQ-2 | Period in empty-sub copy: artboard has period; AC-2 does not. Canonical? | Design/PM | No | Artboard governs; period is intentional |
| OQ-3 | Initial chip selected on screen entry: first chip in alphabetical order, or frequency-of-use, or most recent exercise? | Design/Engineering | **Yes** | First chip in the order exercises appear in the workout_sessions data; confirm ordering rule |
| OQ-4 | Long exercise names in chips: truncate with ellipsis or wrap? | Design | No | Chips use `flex:0 0 auto` — chip grows to fit name; no truncation; `overflow-x:auto` on chip-row handles overflow |
| OQ-5 | Volume calculation: all sets × weight, or best-set only? Skipped sets included/excluded? | Engineering/PM | **Yes** | All valid (non-skipped) sets × weight × reps. Confirm with PM before implementation |
| OQ-6 | Negative delta: colour and format? Only lime `+` shown in artboard. | Design | No | Negative: `color:var(--danger)` (#ff6b6b) with `−` prefix (mirror SCR-19 pattern for negative values if any); confirm |
| OQ-7 | Chart interactivity: no tooltip/scrub in artboard. Add on tap/drag? | Design/PM | No | No chart interaction in v1; chart is read-only SVG |
| OQ-8 | X-axis date format for cross-year sessions: "Jul 28" format omits year. | Design/Engineering | No | For sessions within current year: "Mon D"; for prior year: "Mon D YYYY" or add year in chart-title |
| OQ-9 | Zero completed sessions overall: what is shown? Chip row empty? | Design/Engineering | No | Assumption: chip row is populated from exercises in the user's workout plans; if no sessions and no plans, show a global empty state (no chips) — confirm |
| OQ-10 | SVG `preserveAspectRatio:none` at different widths: axis label positions are fixed pixel offsets in viewBox. Do they need to be relative? | Engineering | No | Use relative positioning (percentage-based x attributes on text elements) for production implementation |
| OQ-11 | Axis labels at 9px with `dim` colour: confirm as intentional or increase to 10px/white? | Design | No | Intentional at 9px; if WCAG remediation required, raise to 10px |
| OQ-12 | Loading skeleton shows 3 chip skeletons. Is this always 3 or viewport-based? | Engineering | No | Fixed 3; reasonable hint for most workout plans |
| OQ-13 | Chart metric "▲ 8 kg over 6 sessions" — what is "over 6 sessions"? Count of all valid sessions, or count of sessions used in the chart? | Engineering/PM | **Yes** | Count of valid sessions used in the chart (i.e. sessions after invalid exclusion). Confirm |
| OQ-14 | Metrics shown (Top Weight / Best Reps / Volume) — are these always all three, or only the applicable ones (e.g. time-based exercises show Duration instead of Weight)? | Design/PM | **Yes** | For time-based exercises (type-dot=cyan): replace with Duration/Best Reps/Volume as applicable. AC-3 says "weight, reps, volume, and duration where applicable". Confirm exact substitution rules |
