# Design Specification: SCR-23 — Statistics Dashboard

**Story ID**: US-SCR23  
**Feature**: View aggregated workout statistics  
**Priority**: Medium  
**Created**: 2026-09-13  
**Artboard reference**: https://claude.ai/code/artifact/945dda3f-7b79-46bc-8be8-6ea87738478f  
**Artboards**: Loading.dc.html · Empty.dc.html · Main.dc.html · Error.dc.html  

---

## 1 · Overview & Goal

### Problem
A user who has completed workouts has no single place to see their overall training summary — total sessions, cumulative volume lifted, hours invested, and how they're doing across individual exercises. The Stats screen aggregates Drift history into a scannable dashboard.

### User
An app-unlocked ForgeApp user who wants a high-level view of their completed workout activity. They do not need to navigate history one session at a time; they want summary numbers. A first-time user with no completed workouts gets an empty-state prompt to start training.

### Goal
Surface four aggregate statistics (workouts completed, total volume, total duration, average duration) and a per-exercise breakdown (session count, best performance value) from local Drift data. Provide a direct entry point to the Personal Bests screen (SCR-24).

### Success metric
- AC-1: Loading skeleton while statistics are being calculated.
- AC-2: Empty state with zeroed/placeholder stat tiles and prompt when no valid completed workouts exist.
- AC-3: Populated stat tiles and exercise breakdown when valid history exists.
- AC-4: Recalculated statistics (no stale values) when a workout record is edited or deleted.
- EC-1: Error state with Retry on Drift read/calculation failure.

### App context
**Fully offline, local-only.** Statistics are calculated from the `workout_sessions` table. No network calls; no connectivity failure mode. FR-6 / NFR-3 (offline state) were removed 2026-09-05. The `workout_plans` and `exercises` tables may be consulted to resolve exercise names and types for the breakdown.

**Security constraints (inviolable)**:
- No network calls. No REST/GraphQL/gRPC client.
- Drift is the single source of truth.
- No Git/GitHub operations from automation.
- No new dependencies outside the ADR-030 governed set.
- App must be unlocked (SR-1) before stats data is accessible.

### Functional requirements
- **FR-1**: Show skeleton while statistics are being calculated (NFR-1, AC-1).
- **FR-2**: Show empty state (zeroed tiles + prompt) when no valid completed workouts exist (AC-2).
- **FR-3**: Show populated statistics — 4 aggregate tiles + exercise breakdown + Personal Bests link — when valid history exists (AC-3).
- **FR-4**: Recalculate from current valid records; never display stale values (AC-4, NFR-2).
- **FR-5**: Show error state with Retry on Drift read/calculation failure (EC-1).

---

## 2 · User Flow

### Entry
- **Primary**: Stats tab (6th of 6 in bottom navbar) from any root-tab screen.

### Exit
- **Tab switch**: any of the 5 other bottom-navbar tabs (Home, Plans, Schedule, History, Progress). Navbar present in all 4 states.
- **SCR-24 (Personal Bests)**: tapping the "Personal Bests" row in the Main state pushes to SCR-24.
- **Workout Start (Empty state CTA)**: tapping "Start a Workout" navigates to the workout-start flow — OQ-1 (see §10).

### State machine
```
[Entry via Stats tab]
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
  │ EMPTY │          │   ERROR   │◄─ Retry ─┐
  │(no    │          └─────┬─────┘          │
  │ data) │                └────────────────┘
  └───────┘
  ┌───────┐
  │ MAIN  │  Populated dashboard
  └───────┘
```

**Transitions**:
- Loading → Main: if valid completed workouts exist.
- Loading → Empty: if no valid completed workouts exist.
- Loading → Error: if Drift read/calculation throws.
- Error → Loading → (Main/Empty): on Retry.
- Main → Loading → (Main/Empty): on AC-4 — when a workout is edited/deleted (triggered on next entry or by reactive data subscription).

### Navigation pattern
Root-tab screen. Bottom navbar persistent in all states. Stats tab (6th) is active. Tapping "Personal Bests" pushes SCR-24 onto the stack (back arrow returns to Stats).

---

## 3 · Screen-by-Screen Breakdown

### Shared chrome (all states)

**Status bar** — `height:28px; flex:0 0 auto`

**Appbar** — `padding:6px 20px 10px; flex:0 0 auto`
- Title: `font-size:22px; font-weight:800; letter-spacing:.02em` — **"Stats"**
- Root-tab title tier: `22px/800/.02em` — same as SCR-20 "History", SCR-22 "Progress". No back arrow, no trailing icons.

**Bottom navbar** — `flex:0 0 auto; display:flex; align-items:center; justify-content:space-between; padding:10px 14px 18px; border-top:1px solid var(--border); background:var(--bg)`
- 6 tabs; Stats (6th) is active.
- Loading: inactive navitem has `opacity:.5` (same pattern as SCR-22 Loading)
- Other states: no opacity modifier on inactive navitems
- Active: `opacity:1; icon color:var(--lime); label color:var(--lime)`
- Inactive: `color:var(--dim); font-weight:600`

| Tab | Icon SVG | Label |
|-----|----------|-------|
| Home (1) | `M4 11l8-7 8 7 / M6 10v9h12v-9` | Home |
| Plans (2) | `M4 7h16 / M4 12h16 / M4 17h10` | Plans |
| Schedule (3) | `rect x4 y5 w16 h15 rx2 / M4 10h16 / M8 3v4 / M16 3v4` | Schedule |
| History (4) | `circle cx12 cy12 r8 / M12 8v4l3 2` | History |
| Progress (5) | `M4 17l5-5 4 3 7-8 / M15 7h5v5` | Progress |
| **Stats (6)** | `M5 20V10 / M12 20V4 / M19 20v-7` | **Stats** |

---

### State A · Loading

**Purpose**: Prevent blank-screen flash during Drift calculation. Skeleton mirrors the exact layout of the Main state (4 stat tiles + 3 exercise card rows).

**Content area** — `flex:1 1 auto; padding:0 20px 12px; display:flex; flex-direction:column; gap:16px` (no `overflow-y:auto`)

**Shimmer variant**: Translate-based — `::after { background:linear-gradient(90deg, transparent, rgba(255,255,255,.06), transparent); animation:shimmer 1.4s infinite; transform:translateX(-100%)→translateX(100%) }` (same as SCR-21/22)

**Skeleton layout** (top to bottom):

| Element | CSS | Mirrors |
|---------|-----|---------|
| `.stat-grid` | `display:grid; grid-template-columns:1fr 1fr; gap:10px` | stat tile grid |
| `.sk-stat` ×4 | `height:88px; border-radius:14px` | 4 stat tiles |
| `.sk-row` ×3 | `height:56px; border-radius:14px` | 3 exercise card rows |

> **Skeleton geometry rationale**: `sk-stat` at `height:88px` mirrors `stat-box: padding:14px + gap:6px + 28px icon-wrap + 6px gap + ~24px value + 6px gap + ~14px label + 14px padding = ~88px`. `sk-row` at `height:56px` mirrors `ex-card: padding:12px + 8px dot height + 2×12px padding = ~56px`.
>
> **3 sk-rows**: The artboard shows exactly 3 exercise rows; skeleton shows 3 rows as a hint. Production implementation may show a configurable count based on actual exercise catalogue size.
>
> **Navbar `opacity:.5`**: Only in Loading state (explicit in Loading CSS; absent in Empty/Main/Error). Consistent with SCR-22 Loading.

---

### State B · Empty (No valid completed workouts)

**Purpose**: Show zeroed/dimmed stat tiles to establish the grid layout, explain there are no stats yet, and provide a direct CTA to start training.

**Content area** — `flex:1 1 auto; padding:0 20px 12px; display:flex; flex-direction:column; gap:16px`

**Stat tile grid** — `display:grid; grid-template-columns:1fr 1fr; gap:10px` (same as Main)

**Empty stat box — `.stat-box`** (dimmed):
`background:var(--card); border:1px solid var(--border); border-radius:14px; padding:14px; display:flex; flex-direction:column; gap:6px; **opacity:.55**`

| Sub-element | CSS | Empty-state style |
|-------------|-----|-------------------|
| `.stat-icon-wrap` | `width:28px; height:28px; border-radius:8px; background:var(--card-alt)` | icon colour: `dim` (not lime) |
| `.stat-icon` | `width:15px; height:15px; color:var(--dim)` | dim icons |
| `.stat-value` | `font-size:19px; font-weight:800; color:var(--dim)` | zeroed/placeholder values |
| `.stat-label` | `font-size:11px; color:var(--muted)` | same labels as Main |

**Empty stat tile values**:
| Tile | Icon SVG | Zeroed value |
|------|----------|-------------|
| Workouts Completed | Checkmark `M20 6L9 17l-5-5` | `0` |
| Total Volume | Barbell `M6 3v18M18 3v18M3 8h6M15 8h6M3 16h6M15 16h6` | `0 kg` |
| Total Duration | Clock `circle cx12 cy12 r8 / M12 8v4l3 2` | `0h 0m` |
| Avg. Duration | Trend-up `M4 17l5-5 4 3 7-8 / M15 7h5v5` | `—` (em dash) |

> **Empty tile differentiation from Main**: Two visual signals distinguish Empty tiles from real-data tiles: (1) `opacity:.55` on the entire stat-box; (2) icon colour `dim` instead of `lime`. The values `0`, `0 kg`, `0h 0m`, `—` are placeholders — they represent "no data" not zeroed actuals.

> **Avg. Duration: `—` not `0`**: Average of zero sessions is mathematically undefined, not zero. The em dash `—` (U+2014) communicates N/A without requiring a calculation. Total Volume and Duration can legitimately be `0` for zero sessions.

**Prompt wrap — `.prompt-wrap`**:
`display:flex; flex-direction:column; align-items:center; text-align:center; gap:14px; padding:24px 12px`

| Element | CSS | Copy |
|---------|-----|------|
| `.prompt-icon` | `width:44px; height:44px; color:var(--dim)` | Bar-chart icon (Stats icon, `M5 20V10M12 20V4M19 20v-7`, stroke-width:1.4) |
| `.prompt-title` | `font-size:16px; font-weight:800` | **"No stats yet"** |
| `.prompt-sub` | `font-size:13px; color:var(--muted); line-height:1.5; max-width:250px` | "Complete a workout to start building your statistics." |
| `.cta-btn` | `margin-top:2px; background:var(--lime); color:#131315; font-weight:800; font-size:13px; border-radius:10px; padding:12px 22px` | **"Start a Workout"** |

> **`prompt-wrap` vs `empty-wrap` (SCR-22)**: In SCR-22, the empty wrap used `flex:1 1 auto; justify-content:center; padding-bottom:60px` to centre vertically within remaining space. Here, `prompt-wrap` uses fixed `padding:24px 12px` and sits below the stat grid in normal flex flow — it is not vertically centred in the viewport.

> **CTA button padding**: `12px 22px` (vs Retry button's `11px 22px`; vs SCR-22 chips' `8px 14px`). The extra vertical padding makes this the tallest interactive element at ~40px rendered height — still borderline 44pt (OQ-2).

> **"Exercise Breakdown" and "Records" sections**: NOT shown in Empty state. They appear only in Main state when valid history exists.

---

### State C · Main (Populated statistics)

**Purpose**: Display aggregate workout statistics, a per-exercise breakdown of session counts and best performance values, and a navigable link to Personal Bests (SCR-24).

**Content area** — `flex:1 1 auto; overflow-y:auto; padding:0 20px 12px; display:flex; flex-direction:column; gap:16px`

#### Stat tile grid — `.stat-grid`
`display:grid; grid-template-columns:1fr 1fr; gap:10px`

**Stat box — `.stat-box`** (populated, no opacity modifier):
`background:var(--card); border:1px solid var(--border); border-radius:14px; padding:14px; display:flex; flex-direction:column; gap:6px`

| Sub-element | CSS | Main-state style |
|-------------|-----|-----------------|
| `.stat-icon-wrap` | `width:28px; height:28px; border-radius:8px; background:var(--card-alt); display:flex; align-items:center; justify-content:center` | lime icons |
| `.stat-icon` | `width:15px; height:15px; color:var(--lime)` | lime in Main vs dim in Empty |
| `.stat-value` | `font-size:19px; font-weight:800` | white text (default) |
| `.stat-label` | `font-size:11px; color:var(--muted)` | same labels as Empty |

**Populated stat tile examples**:
| Tile | Icon SVG | Example value | Label |
|------|----------|--------------|-------|
| Workouts Completed | `M20 6L9 17l-5-5` (check) | `27` | Workouts Completed |
| Total Volume | barbell | `48,320 kg` | Total Volume |
| Total Duration | clock | `17h 24m` | Total Duration |
| Avg. Duration | trend-up | `42 min` | Avg. Duration |

**Value formats**:
| Metric | Format rule | Example |
|--------|-------------|---------|
| Workouts Completed | Integer, no unit | `27` |
| Total Volume | `{N} kg` with comma thousands-separator | `48,320 kg` |
| Total Duration | `{N}h {N}m` (no leading zeros on hours) | `17h 24m` |
| Avg. Duration | `{N} min` (no hours if <60 min) | `42 min` |

> **Avg. Duration format for ≥60 min**: If average exceeds 59 minutes, format as `{N}h {N}m`. OQ-3 — confirm exact format for values near/above 1 hour.

> **stat-value at 19px**: new font size in the system. Previous stat-values were `18px` (SCR-21) and `15px` (SCR-22). `19px` is between them — the icon-wrap is a new element that takes space in the tile, so the value is slightly smaller than the SCR-21 stat tiles but bigger than the SCR-22 compact tiles.

#### Section label — `.section-label`
`font-size:12px; font-weight:800; text-transform:uppercase; letter-spacing:.06em; color:var(--dim); margin-top:2px`
Same component as SCR-21/22, same CSS.

**Two section labels in Main**:
1. **"Exercise Breakdown"** — above exercise cards
2. **"Records"** — above Personal Bests link row

#### Exercise breakdown cards — `.ex-card`

`display:flex; align-items:center; gap:12px; background:var(--card); border:1px solid var(--border); border-radius:14px; padding:12px 14px`

| Sub-element | CSS |
|-------------|-----|
| `.type-dot` | `width:8px; height:8px; border-radius:50%; flex:0 0 auto` |
| `.type-dot.weighted` | `background:var(--lime)` |
| `.type-dot.time` | `background:var(--cyan)` |
| `.type-dot.bodyweight` | `background:var(--muted)` |
| `.ex-body` | `flex:1 1 auto; display:flex; flex-direction:column; gap:2px` |
| `.ex-name` | `font-size:13px; font-weight:700` |
| `.ex-meta` | `font-size:11px; color:var(--muted)` |
| `.ex-right` | `text-align:right` |
| `.ex-right-value` | `font-size:13px; font-weight:800` |
| `.ex-right-label` | `font-size:10px; color:var(--dim)` |

**Artboard exercise examples**:
| Exercise | Dot | Name | Meta | Right value | Right label |
|----------|-----|------|------|-------------|-------------|
| Barbell Bench Press | weighted (lime) | Barbell Bench Press | 18 sessions | 65 kg | Best weight |
| Seated Shoulder Press | weighted (lime) | Seated Shoulder Press | 14 sessions | 20 kg | Best weight |
| Plank Hold | time (cyan) | Plank Hold | 12 sessions | 01:10 | Best time |

> **Type dot**: Same 8×8 dot component established in SCR-09/10/15/16/19/21/22. The dot reads the exercise type from the `exercises` table — `weighted` → lime; `time` → cyan; `bodyweight` → muted.

> **Best value format per type**:
> - `weighted`: `"{N} kg"` — best weight lifted in any single set
> - `time`: `"{MM:SS}"` — best time achieved in any single set
> - `bodyweight`: label is `"Best reps"`, value is `"{N}"` — not shown in artboard; assumed from type-system logic (OQ-4)

> **Exercise ordering in breakdown**: Not specified. Artboard shows 3 exercises ordered by session count descending. OQ-5 — confirm ordering rule.

> **ex-right-value format for time**: `01:10` — `MM:SS` with leading zero on minutes. Confirm this format (vs `1:10`) for values under 1 minute (OQ-6).

> **Exercise cards are read-only** in this view — no tap action to drill down. No disclosure indicator. The stat is a summary; the History tab handles per-session drill-down.

#### Personal Bests link — `.pb-link`

`display:flex; align-items:center; justify-content:space-between; background:var(--card); border:1px solid var(--border); border-radius:14px; padding:14px`

| Sub-element | CSS | Content |
|-------------|-----|---------|
| `.pb-left` | `display:flex; align-items:center; gap:10px` | — |
| `.pb-icon-wrap` | `width:32px; height:32px; border-radius:8px; background:#1e2a12` | success fill |
| `.pb-icon` | `width:16px; height:16px; color:var(--lime)` | Trophy SVG (see below) |
| `.pb-title` | `font-size:13px; font-weight:700` | "Personal Bests" |
| `.pb-sub` | `font-size:11px; color:var(--muted)` | "Your all-time top performances" |
| `.chev` | `width:16px; height:16px; color:var(--dim)` | Chevron right `M9 18l6-6-6-6` |

**Trophy icon SVG** (stroke-width:2):
```svg
<path d="M8 21h8"/>
<path d="M12 17v4"/>
<path d="M6 3h12v4a6 6 0 0 1-12 0V3z"/>
<path d="M6 5H4a2 2 0 0 0 2 4"/>
<path d="M18 5h2a2 2 0 0 1-2 4"/>
```

> **pb-icon-wrap background**: `#1e2a12` — same `color.successFill` token established in SCR-21 (`#1e2a12` identified in prior specs). Not a new token.

> **pb-link is interactive (tappable)**: The chevron indicates navigation. Tapping pushes to SCR-24 (Personal Bests). The entire row is the tap target.

> **pb-link shown only in Main**: Not visible in Empty or Error. If no valid history exists, there are no Personal Bests to show.

---

### State D · Error

**Purpose**: Communicate that the Drift read or calculation failed; allow Retry without leaving the screen.

**Content area** — `flex:1 1 auto; display:flex; flex-direction:column; align-items:center; justify-content:center; padding:0 32px; text-align:center; gap:14px`

**Error card** — `.err-card`:
`width:100%; background:var(--card); border:1px solid #5c3a3a; border-radius:16px; padding:26px 20px; display:flex; flex-direction:column; align-items:center; gap:12px`

| Element | CSS | Copy |
|---------|-----|------|
| `.err-icon` | `width:40px; height:40px; color:var(--danger)` | Sharp alert-triangle |
| `.err-title` | `font-size:16px; font-weight:800` | **"Couldn't load your stats"** |
| `.err-sub` | `font-size:13px; color:var(--muted); line-height:1.5` | "Something went wrong calculating your statistics.\nYour workout history is unaffected." |
| `.retry-btn` | `margin-top:4px; background:var(--lime); color:#131315; font-weight:800; font-size:13px; border-radius:10px; padding:11px 22px` | "Retry" |

**Alert-triangle SVG** (sharp variant — same as SCR-20/21/22/23):
```svg
<path d="M12 3l10 18H2L12 3z"/>
<path d="M12 10v4"/>
<circle cx="12" cy="17" r="0.6" fill="currentColor"/>
stroke-width:1.6
```

> **Error copy distinction from SCR-22 and SCR-21**:
> - SCR-21: "Couldn't load this workout" / "reading local data."
> - SCR-22: "Couldn't load your progress" / "reading local data."
> - SCR-23: "Couldn't load your stats" / "calculating your statistics."
>
> The second line varies: "reading local data" (SCR-21/22) vs "calculating your statistics" (SCR-23) — calculation failure is the explicit error mode here, not just a read failure. The reassurance line ("Your workout history is unaffected.") is consistent across all three.

> **Navbar in Error**: present and interactive. Root-tab screen; user can switch tabs without Retrying.

---

## 4 · Interactions & Behaviour

| # | Trigger | Response | Notes |
|---|---------|----------|-------|
| 1 | Screen entered via Stats tab | Show Loading; begin Drift read + calculation | Immediate |
| 2 | Calculation succeeds, valid history | Loading → Main | No animation specified; instant swap |
| 3 | Calculation succeeds, no valid history | Loading → Empty | Instant swap |
| 4 | Calculation fails | Loading → Error | Instant swap |
| 5 | Tap Retry (Error state) | Error → Loading; re-trigger calculation | Guard against double-tap |
| 6 | Tap "Start a Workout" (Empty CTA) | Navigate to workout-start flow | OQ-1: confirm target screen |
| 7 | Tap "Personal Bests" row (Main) | Push SCR-24 (Personal Bests) | Tap the entire `pb-link` row |
| 8 | Tap navbar tab (any state) | Switch to selected root-tab screen | Standard root-tab switch |
| 9 | Scroll content (Main state) | `overflow-y:auto` — vertical scroll | Appbar + navbar stay fixed |
| 10 | Tap stat tile (Empty or Main) | No action — stat tiles are read-only | No tap affordance; no disclosure |
| 11 | Tap exercise card (Main) | No action — read-only | Same; no drill-down in current scope |
| 12 | Workout edited/deleted (background) | Recalculate — transition to Loading then Main/Empty | AC-4; may be a reactive subscription or triggered on next screen entry |

**No transitions/animations specified** beyond the existing shimmer animation on skeleton elements. All state swaps are instant.

---

## 5 · Edge Cases & Error Handling

| # | Scenario | Behaviour |
|---|----------|-----------|
| EC-1 | Drift read/calculation throws | Show Error state with Retry |
| EC-2 | Zero completed workouts | Show Empty state: dimmed tiles with `0`, `0 kg`, `0h 0m`, `—`; prompt wrap |
| EC-3 | Only partially completed sessions | Sessions that don't meet validity threshold are excluded silently (FR-4/NFR-2); only count valid records |
| EC-4 | All sessions for one exercise are invalid | That exercise does not appear in the breakdown |
| EC-5 | No exercises in breakdown (all excluded) | "Exercise Breakdown" section-label shown with no cards, or section hidden entirely — OQ-7 |
| EC-6 | Exercise breakdown contains very many exercises | `overflow-y:auto` on content handles scroll; all exercises listed |
| EC-7 | Total Volume exceeds display width | Value wraps inside stat tile or uses K/M suffix — OQ-8 |
| EC-8 | Avg. Duration ≥ 60 min | Display as `{N}h {N}m` — OQ-3 |
| EC-9 | Total Duration ≥ 24h | Display as `{N}h {N}m` (e.g., `168h 0m`) — no day conversion expected |
| EC-10 | Exercise name too long for ex-card | `ex-name` truncates with ellipsis — OQ-9 |
| EC-11 | Retry after Error succeeds | Error → Loading → Main or Empty |
| EC-12 | AC-4: workout deleted while Stats is visible | Recalculate; if reactive — update in place via loading state; if on-entry — stale until re-entry |
| EC-13 | Workouts Completed = 1 (singular unit) | "27" vs "1" — no unit label shown (label is always "Workouts Completed"), so no pluralization concern in tile |
| EC-14 | Best weight = 0 kg (bodyweight exercise logged with weight) | Show "0 kg" with label "Best weight" — OQ-4 |

---

## 6 · Responsive & Platform Considerations

**Device widths**:
- Artboard: 390 × 844px (iPhone 14 reference).
- `grid-template-columns:1fr 1fr` adapts naturally — tiles share available width. On 375px (SE) tiles are ~182px each; on 430px (Pro Max) ~202px each.
- `ex-card` and `pb-link` are full-width block elements — no width issues.
- Text values that are long (e.g. `48,320 kg`) should fit within a 190px tile at 19px/800; at extreme widths (e.g. `1,234,567 kg`) truncation or wrapping may occur — OQ-8.

**Orientation**: Portrait only (ForgeApp global constraint).

**Safe area**: Navbar `padding:10px 14px 18px` handles home indicator. Content `padding-bottom:12px` provides visual air; stat tiles nearest the nav are not hidden.

**iOS vs Android**:
- Back gesture: not applicable on a root-tab screen. On Android, system back from a root tab exits the app.
- The pb-link push to SCR-24 uses standard navigation stack (AppBar back arrow on SCR-24).
- Haptics on tap: not specified; follow system conventions.

---

## 7 · Accessibility

### Touch targets

| Target | Artboard size | 44pt compliant? |
|--------|--------------|----------------|
| Stat tile (read-only) | ~190×88px | ✅ (non-interactive) |
| CTA "Start a Workout" | ~134×40px | ❌ Height ~40px; increase padding to `14px 22px` for compliance |
| Personal Bests row | full-width × 66px | ✅ (padding:14px × 2 + content ~38px ≈ 66px) |
| Retry button | ~115×40px | ❌ Slightly under 44pt; increase padding to `13px 22px` |
| Nav tab items | 52×~46px | ✅ |

### Colour contrast

| Pair | Foreground | Background | Ratio (approx) | AA (4.5:1)? |
|------|-----------|------------|-----------------|-------------|
| "Stats" title white on bg | #f5f6f1 | #131315 | ~20:1 | ✅ |
| stat-value white on card | #f5f6f1 | #201f22 | ~18:1 | ✅ |
| stat-label muted on card | #c4c9ac | #201f22 | ~9:1 | ✅ |
| stat-icon lime on card-alt | #c3f400 | #2a2a2c | ~11:1 | ✅ |
| stat-icon dim on card-alt (empty) | #8a8f7a | #2a2a2c | ~4.2:1 | ❌ at 15px; passes large-text at icon |
| stat-value dim (empty) | #8a8f7a | #201f22 | ~4.4:1 | ❌ at 19px bold — passes large-text (14px+ bold threshold) |
| Empty opacity .55 — all above degraded by 45% | — | — | All fail | Systemic; `opacity:.55` is a known accessibility issue for empty states using this pattern |
| section-label dim on bg | #8a8f7a | #131315 | ~4.4:1 | ❌ 12px/800 — passes large-text |
| ex-name white on card | #f5f6f1 | #201f22 | ~18:1 | ✅ |
| ex-meta muted on card | #c4c9ac | #201f22 | ~9:1 | ✅ |
| ex-right-value white on card | #f5f6f1 | #201f22 | ~18:1 | ✅ |
| ex-right-label dim on card | #8a8f7a | #201f22 | ~4.2:1 | ❌ at 10px — systemic dim issue |
| pb-title white on card | #f5f6f1 | #201f22 | ~18:1 | ✅ |
| pb-sub muted on card | #c4c9ac | #201f22 | ~9:1 | ✅ |
| chevron dim on card | #8a8f7a | #201f22 | ~4.2:1 | ❌ decorative |
| lime icon on successFill (#1e2a12) | #c3f400 | #1e2a12 | ~14:1 | ✅ |
| CTA text #131315 on lime | #131315 | #c3f400 | ~17:1 | ✅ |
| err-title white on card | #f5f6f1 | #201f22 | ~18:1 | ✅ |
| err-sub muted on card | #c4c9ac | #201f22 | ~9:1 | ✅ |

> **Empty state `opacity:.55`**: Applying opacity to the entire stat-box degrades all colours inside — a WCAG-compliant tile in Main becomes non-compliant in Empty at reduced opacity. The dim-icons + dim-values approach communicates emptiness without opacity; consider removing `opacity:.55` and relying on colour alone. OQ-10 (design decision).

### Semantic roles

| Element | Flutter widget / semantic |
|---------|--------------------------|
| Screen title "Stats" | `AppBar.title` + `Semantics(header: true)` |
| Stat tiles (read-only) | `Semantics(label: '{LABEL}: {VALUE}')` e.g. "Workouts Completed: 27" |
| Empty stat tiles | `Semantics(label: '{LABEL}: no data yet')` |
| "Exercise Breakdown" label | `Semantics(header: true)` |
| Exercise card (read-only) | `Semantics(label: '{name}, {meta}, {right-label}: {right-value}')` |
| "Records" label | `Semantics(header: true)` |
| Personal Bests link | `InkWell` / `GestureDetector` + `Semantics(label: 'Personal Bests — Your all-time top performances', button: true)` |
| Chevron | `Semantics(excludeSemantics: true)` |
| prompt-icon | `Semantics(excludeSemantics: true)` |
| prompt-title | `Text` — primary empty message |
| CTA "Start a Workout" | `ElevatedButton` + `Semantics(label: 'Start a Workout')` |
| Skeleton | `Semantics(label: 'Loading statistics', excludeSemantics: true)` on container |
| Error card | `Semantics(liveRegion: true)` if shown after Loading |
| Retry | `ElevatedButton` + `Semantics(label: 'Retry loading stats')` |

### Focus management
- Screen entry: focus on first interactive element. In Loading/Empty/Main, start on "Stats" heading or first stat tile. In Error, focus on Retry button.
- In Main, tab order: stat grid → "Exercise Breakdown" → exercise cards (not interactive, but announced) → "Records" → Personal Bests link.
- Personal Bests push: on back, focus returns to Personal Bests row.

---

## 8 · Component & Design System Mapping

### Existing components (re-used)

| Component | Usage in SCR-23 |
|-----------|----------------|
| Root-tab appbar (`22px/800/.02em`) | "Stats" title — same tier as SCR-20/22 |
| Bottom navbar (6-tab) | Stats (6th) active; same as SCR-20/22 |
| Translate-shimmer skeleton | Loading skeleton — same `::after` translateX 1.4s pattern as SCR-21/22 |
| Error card (`err-card`) | `card; #5c3a3a border; radius:16px; padding:26px 20px` — same as SCR-20/21/22 |
| Sharp alert-triangle | `M12 3l10 18H2L12 3z; stroke-width:1.6` — same as SCR-20/21/22 |
| Retry button (inline) | `lime bg; #131315; 800/13px; radius:10px; padding:11px 22px` — same as SCR-20/21/22 |
| `section-label` | `12px/800/uppercase/.06em/dim; margin-top:2px` — same as SCR-21/22 |
| `type-dot` | `8×8; border-radius:50%; lime/cyan/muted` — same as SCR-09/10/15/16/19/21 |
| `ex-card` layout | `card bg; border; radius:14px; padding:12px 14px; flex; gap:12px` — same pattern as SCR-21 exercise cards |
| `#1e2a12` (successFill) | `pb-icon-wrap` background — previously seen in SCR-21/22 |

### New components / patterns (SCR-23 first occurrences)

| Component | Description | Key CSS |
|-----------|-------------|---------|
| `stat-grid` | 2-column responsive grid for stat tiles | `display:grid; grid-template-columns:1fr 1fr; gap:10px` |
| `stat-box` (Stats variant) | Stat tile with icon-wrap, value, label | `card; border; radius:14px; padding:14px; flex-col; gap:6px` |
| `stat-icon-wrap` | Icon container within stat tile | `28×28; radius:8px; card-alt bg; flex center` |
| `stat-icon` | Icon within icon-wrap | `15×15; color:lime (Main) / dim (Empty)` |
| `stat-value` (19px) | Primary value text in stat tile | `19px/800` — new font size in system |
| `stat-label` (11px) | Sub-label in stat tile | `11px/muted` |
| `ex-meta` | Session count meta line in exercise card | `11px/muted` — "N sessions" |
| `ex-right` + `ex-right-value` + `ex-right-label` | Right-aligned best-value display in exercise card | `13px/800 value; 10px/dim label; text-align:right` |
| `pb-link` | Navigable "Personal Bests" entry row | `card; border; radius:14px; padding:14px; flex; justify-content:space-between` |
| `pb-icon-wrap` | Trophy icon container in pb-link | `32×32; radius:8px; #1e2a12 bg` |
| `pb-icon` | Trophy SVG in pb-link | `16×16; lime` |
| `pb-title` + `pb-sub` | Personal Bests title and subtitle | `13px/700; 11px/muted` |
| `chev` | Navigation disclosure chevron | `16×16; dim; M9 18l6-6-6-6` |
| `prompt-wrap` | Empty-state prompt area below dimmed stat grid | `flex-col; center; gap:14px; padding:24px 12px` |
| `prompt-icon` | Illustrative icon in prompt | `44×44; dim; bar-chart icon` |
| `prompt-title` | Empty-state primary message | `16px/800` |
| `prompt-sub` | Empty-state secondary message | `13px/muted; line-height:1.5; max-width:250px` |
| `cta-btn` | Primary action button in empty state | `lime bg; #131315; 800/13px; radius:10px; padding:12px 22px` |

### Token gaps

| Raw value | Proposed token | Occurrences |
|-----------|---------------|-------------|
| `font-size:19px` | `text.statValue` | stat-value in SCR-23 (new size, between SCR-21's 18px and a hypothetical 20px) |
| `font-size:11px` | `text.meta` | stat-label, ex-meta, pb-sub — recurs across new components |
| `font-size:10px` | `text.microLabel` | ex-right-label (previously `text.axisLabel` at 9px was distinct; 10px is shared with navitem label and prior stat-labels) |
| `border-radius:8px` | `radius.iconWrap` | stat-icon-wrap, pb-icon-wrap (8px icon containers) |
| `border-radius:10px` | `radius.dialogButton` | cta-btn, retry-btn (established in SCR-20/21/22) |
| `font-weight:600` | `weight.medium` | navitem labels (ongoing) |
| `rgba(255,255,255,.06)` | `color.shimmerSheen` | Loading shimmer (third occurrence, same as SCR-21/22) |
| `#1e2a12` | `color.successFill` | pb-icon-wrap (established in SCR-21) |

---

## 9 · Acceptance Criteria Mapping

| Criterion | Source | Verification |
|-----------|--------|-------------|
| AC-1: Skeleton while loading | NFR-1, FR-1 | Loading state shows `stat-grid` with 4 `sk-stat` (88px) + 3 `sk-row` (56px) with translate-shimmer; shown until calculation completes |
| AC-2: Empty state with zeroed stats + prompt | FR-2, AC-2 | Empty state shows 4 dimmed stat tiles (0, 0 kg, 0h 0m, —) at opacity:.55; `prompt-wrap` with "No stats yet" + sub-text + "Start a Workout" CTA |
| AC-3: Display stats — workouts, volume, duration, exercise breakdown | FR-2, FR-3, AC-3 | Main state shows 4 stat tiles (real values); "Exercise Breakdown" section with exercise cards; "Records" section with pb-link |
| AC-4: Recalculate on record edit/delete | FR-4, NFR-2, AC-4 | Data-layer behaviour: triggered on workout change; screen returns to Loading state then reflects new values in Main/Empty |
| EC-1: Error state with retry | FR-5, EC-1 | Error card with "Couldn't load your stats"; Retry button; navbar present |

---

## 10 · Open Questions / Assumptions

| # | Question | Owner | Build-blocker? | Assumption held |
|---|----------|-------|---------------|----------------|
| OQ-1 | "Start a Workout" CTA in Empty state: which screen does it navigate to? The Workout Start flow is not explicitly documented as a nav target from SCR-23. | Design/PM | **Yes** | Navigates to the Plans screen (SCR-08) or the first step in FLOW-07 Workout Execution; confirm exact target |
| OQ-2 | CTA "Start a Workout" at `padding:12px 22px` renders ~40px height — below 44pt. Increase to `14px 22px`? | Design | No | Artboard as-is; flag for remediation |
| OQ-3 | Avg. Duration format when ≥60 min: `"1h 12m"` or `"72 min"` or `"1:12h"`? | Design/Engineering | **Yes** | `"{N}h {N}m"` consistent with Total Duration format |
| OQ-4 | Bodyweight exercise right-column: "Best reps" with an integer value? Or no right column? | Design/Engineering | **Yes** | `ex-right-value = "{N}"`, `ex-right-label = "Best reps"` — consistent with type-system; artboard only shows weighted and time |
| OQ-5 | Exercise breakdown ordering: by session count desc, alphabetical, or last-used? | Design/PM | **Yes** | Session count descending (artboard order) |
| OQ-6 | Time best value format: `01:10` (leading zero on minutes) vs `1:10` vs `1m 10s`? | Design | No | `MM:SS` with leading zeros (artboard literal value) |
| OQ-7 | If all exercises are excluded from breakdown (all invalid), is the "Exercise Breakdown" section-label hidden or shown with empty space? | Design/Engineering | No | Section hidden when list is empty |
| OQ-8 | Very large Total Volume (e.g., `1,234,567 kg`) — does stat-value overflow or get truncated/abbreviated? | Engineering | No | Value wraps to two lines within tile; no K/M suffix unless decided by Engineering |
| OQ-9 | Long exercise name truncation: ellipsis at 1 or 2 lines? | Design | No | Single line with ellipsis (`overflow:hidden; text-overflow:ellipsis; white-space:nowrap`) |
| OQ-10 | `opacity:.55` on empty stat tiles — accessibility concern (degrades all colour contrast). Replace with colour-only differentiation? | Design | No | Artboard as-is; flag for remediation; dim icons + dim values may be sufficient without opacity |
| OQ-11 | Stat-value font-size `19px` — should this be a new token? Or align to an existing size (18px, 20px)? | Design/Tokens | No | `text.statValue: 19px` as new token; confirm with design |
| OQ-12 | Is the "Records" section always shown in Main, even if no valid workouts have set a personal best? | Design/Engineering | **Yes** | Always shown when valid history exists (pb-link links to SCR-24 which handles its own empty state) |
| OQ-13 | AC-4 reactivity: is recalculation triggered by a reactive stream (live update on data change) or on screen re-entry? | Engineering | **Yes** | Depends on Drift reactive capability; confirm with Engineering — artboard scope note says no distinct visual state for recalculation |
| OQ-14 | "Total Volume" definition: sum of (weight × reps) across all valid non-skipped sets? Same definition as SCR-22 volume? | Engineering/PM | **Yes** | All valid non-skipped sets × weight × reps. Confirm alignment with SCR-22 OQ-5 resolution |
| OQ-15 | Error copy: "Something went wrong calculating your statistics." — is "calculating" correct, or should it read "reading" (since it could be a Drift read failure, not a calculation error)? | Design/PM | No | Artboard copy governs; "calculating" is intentionally distinct from SCR-21/22 "reading" |
