# Design Specification: SCR-21 — Workout History Detail

**Story ID**: US-SCR-21  
**Feature**: View full recorded detail of a completed workout session  
**Priority**: High  
**Created**: 2026-09-13  
**Artboard reference**: https://claude.ai/code/artifact/583b36ed-081c-470a-be28-43d80647e3b6  
**Artboards**: Loading.dc.html · Main.dc.html · Error.dc.html  

---

## 1 · Overview & Goal

### Problem
After viewing the history list (SCR-20), a user taps a session row and needs to see the complete recorded performance for that workout — every exercise, every set, every rep count, weight, or duration — exactly as it was logged. This is the canonical read-only record of what was done.

### User
A ForgeApp user reviewing their training history to assess progress, verify what they lifted, or understand how a session went.

### Goal
Render the full, immutable snapshot of a completed workout session. The display must be faithful to the recorded data — not to the current workout plan, which may have changed since the session was logged.

### Success metric
- AC-1: Loading state shown during data read (no flash of empty or error).
- AC-2: Loaded state shows the session date/time, per-exercise set details (reps/weight/duration), and summary stats.
- AC-3: If the workout plan has since been edited or deleted, the recorded performance still shows exactly as captured at save time.
- EC-1: Load failure triggers the error state with a Retry button.

### App context
ForgeApp is **fully offline, local-only** (no network calls). Workout session data lives in the `workout_sessions` table as a snapshot written at completion time. The detail screen reads that snapshot directly; no plan data is fetched or merged at display time.

**Security constraints (inviolable)**:
- No network calls. No REST/GraphQL/gRPC client.
- Drift is the single source of truth.
- No Git/GitHub operations from automation.
- No new dependencies outside ADR-030 governed set.

### Functional requirements
- **FR-1**: Show a skeleton loading state while session detail is being read from Drift.
- **FR-2**: Show full recorded detail: date/time of session, per-exercise sets with reps/weight/duration as applicable, and session summary stats (duration, exercise count, set count).
- **FR-3** (Historical integrity): Show original recorded performance even if the parent plan or exercises have since been edited or deleted.
- **NFR-1**: Recorded performance is stored as an independent snapshot in `workout_sessions`; no join to `workout_plans` is needed or permitted for display.
- **NFR-2**: A distinct error state with retry must be shown on Drift read failure (not empty state, not a partial render).

---

## 2 · User Flow

### Entry
- **Only entry**: SCR-20 (Workout History List) — user taps a history row. Pushed navigation (slide left, iOS/Android standard).

### Exit
- **Only exit**: Back navigation to SCR-20 (slide right). No other exits defined for this screen.
  - Back arrow in appbar.
  - Android system back gesture / hardware back.

### State machine
```
[Entry from SCR-20]
        │
        ▼
  ┌─────────────┐
  │   LOADING   │  Drift read in progress
  └──────┬──────┘
         │
     ┌───┴───────────────┐
     │                   │
     ▼                   ▼
  ┌──────┐          ┌─────────┐
  │ MAIN │          │  ERROR  │◄─ Retry ─┐
  └──────┘          └────┬────┘          │
                         │               │
                         └───────────────┘
```

- Loading → Main: Drift read succeeds.
- Loading → Error: Drift read fails.
- Error → Loading (retry): User taps Retry; triggers a fresh Drift read.
- Main is a terminal state (read-only; no actions that change state).

### Navigation pattern
Push navigation (no bottom navbar on this screen — it is not a root tab).

---

## 3 · Screen-by-Screen Breakdown

### Shared chrome (all states)

**Status bar** — `height:28px; flex:0 0 auto` (system status bar placeholder).

**Appbar** — `padding:6px 20px 4px; flex:0 0 auto; display:flex; align-items:center; gap:12px`
- Back arrow icon: `width:22px; height:22px; stroke-width:2; path d="M15 18l-6-6 6-6"` (chevron-left)
  - Color: `color:var(--dim)` in Loading; `color:var(--white)` in Main and Error.
- Appbar title: `font-size:18px; font-weight:800; letter-spacing:.02em`
  - Copy: **"Workout Detail"** (all states)
  - Color: `color:var(--dim)` in Loading; inherits `color:var(--white)` in Main and Error.
  - **Title tier**: Overlay/detail screen tier — `18px/800/.02em` — consistent with SCR-17, SCR-18, SCR-19. Distinct from root-tab tier `22px/800/.02em` used on SCR-20 "History".

> **Design note — Loading state appbar dimming**: Both the back arrow and the appbar title carry `color:var(--dim)` during Loading. This is a new pattern: the entire appbar is visually quieted while no content is available to name. Compare with SCR-20 Loading which kept the title white (the screen's identity as "History" was already known). SCR-21's loading state has no identity to show beyond the placeholder title.

---

### State A · Loading

**Purpose**: Communicate that data is being fetched; prevent empty-screen flash.

**Content area** — `flex:1 1 auto; padding:14px 20px 28px; display:flex; flex-direction:column; gap:16px`

**Shimmer approach** (different from SCR-20):
- Base: `.sk { background:var(--card-alt); border-radius:8px; position:relative; overflow:hidden; }`
- Shimmer overlay via `::after` pseudo-element:
  ```css
  .sk::after {
    content:""; position:absolute; inset:0;
    background: linear-gradient(90deg, transparent, rgba(255,255,255,.06), transparent);
    animation: shimmer 1.4s infinite;
  }
  @keyframes shimmer {
    0%  { transform: translateX(-100%); }
    100%{ transform: translateX(100%);  }
  }
  ```
  > **Implementation note**: SCR-21 uses a **translate-based shimmer** (moving a semi-transparent white overlay). SCR-20 used a **background-position-based shimmer** (`linear-gradient` with `background-size:400%`). Both are 1.4s. The translate approach is lighter — a single colour `card-alt` base with a `rgba(255,255,255,.06)` sweep — whereas SCR-20's approach embeds the midpoint colour `#35342f` into the gradient. Document both variants in the component library under "Skeleton / Shimmer".

**Skeleton layout** (top to bottom within content):

| Element | Class | CSS |
|---------|-------|-----|
| Title bar skeleton | `.sk.sk-title` | `width:70%; height:22px; border-radius:6px` |
| Sub-title skeleton | `.sk.sk-sub` | `width:45%; height:12px; margin-top:8px; border-radius:6px` |
| Stat row | `.stat-row` | `display:flex; gap:10px` |
| Stat box ×3 | `.sk.sk-stat` | `flex:1; height:58px; border-radius:14px` |
| Exercise card (×3) | `.sk-card` | `background:var(--card); border:1px solid var(--border); border-radius:14px; padding:14px; display:flex; flex-direction:column; gap:10px` |
| — Card head | `.sk.sk-head` | `width:60%; height:14px; border-radius:6px` |
| — Pill row | `.sk-row-line` | `display:flex; gap:8px` |
| — Pills | `.sk.sk-pill` | `width:56px; height:24px; border-radius:8px` |

Exercise card pill counts (bottom to top in artboard): card 1 → 3 pills; card 2 → 2 pills; card 3 → 3 pills.

> **Skeleton geometry intent**: `sk-title` at `height:22px` mirrors the real `hero-name: font-size:22px`. `sk-sub` at `height:12px` mirrors `hero-meta: font-size:12px`. `sk-stat` at `height:58px` mirrors the `stat-box` card (padding:14px top + 10px label + 4px margin + 18px value + 14px padding bottom ≈ 60px; 58px is close). `sk-pill` at `24px height` mirrors the real `set-pill: padding:4px 8px; font-size:11px` (~24px tall). Skeleton geometry accurately signals what will appear.

---

### State B · Main (Populated)

**Purpose**: Show the full recorded session detail.

**Content area** — `flex:1 1 auto; overflow-y:auto; padding:14px 20px 28px; display:flex; flex-direction:column; gap:16px`

#### Hero section — `.hero`
`display:flex; flex-direction:column; gap:4px`

| Element | CSS | Example copy |
|---------|-----|-------------|
| `.hero-name` | `font-size:22px; font-weight:800` | "Push Day — Upper Body" |
| `.hero-meta` | `font-size:12px; color:var(--muted)` | "Mon, Sep 7, 2026 · 6:42 PM" |

Date/time format: `"Ddd, Mon D, YYYY · H:MM AM/PM"` — abbreviated DOW, abbreviated month, no leading zero on day, full year, middle dot U+00B7, 12-hour time.
> Example: "Mon, Sep 7, 2026 · 6:42 PM"

#### Stat row — `.stat-row`
`display:flex; gap:10px`

Three equal-width stat boxes:

| Slot | Label | Example value |
|------|-------|--------------|
| Duration | "DURATION" | "38 min" |
| Exercises | "EXERCISES" | "5" |
| Sets Logged | "SETS LOGGED" | "14" |

**Stat box** — `.stat-box`:
`flex:1; background:var(--card); border:1px solid var(--border); border-radius:14px; padding:14px; text-align:center`

| Sub-element | CSS |
|-------------|-----|
| `.stat-label` | `font-size:10px; color:var(--dim); text-transform:uppercase; letter-spacing:.04em; font-weight:700` |
| `.stat-value` | `font-size:18px; font-weight:800; margin-top:4px` |

> **stat-box vs SCR-19 comparison**: SCR-19 used `background:var(--card-alt)` for stat boxes; SCR-21 uses `background:var(--card)`. Both have the same border, border-radius, and padding. The lighter card background in SCR-21 may reflect that the session summary (SCR-19) is a transient completion moment warranting a slightly elevated surface, while the history detail (SCR-21) is a calmer, read-only review context. Document as intentional.

#### Section label — `.section-label`
`font-size:12px; font-weight:800; text-transform:uppercase; letter-spacing:.06em; color:var(--dim); margin-top:4px`
Copy: **"Performance"**

> New component: a section heading that separates the summary stat-row from the per-exercise performance cards. No border/divider — purely typographic separation plus the `gap:16px` flex gap above and the `margin-top:4px` on the label itself.

#### Exercise cards — `.ex-card` (one per exercise, in logged order)
`background:var(--card); border:1px solid var(--border); border-radius:14px; padding:12px 14px; display:flex; flex-direction:column; gap:8px`

**Card header — `.ex-head`**:
`display:flex; align-items:center; gap:8px`

| Element | CSS |
|---------|-----|
| `.type-dot` | `width:8px; height:8px; border-radius:50%; flex:0 0 auto` |
| `.type-dot.weighted` | `background:var(--lime)` (#c3f400) |
| `.type-dot.time` | `background:var(--cyan)` (#7df4ff) |
| `.type-dot.bodyweight` | `background:var(--muted)` (#c4c9ac) |
| `.ex-name` | `font-size:13px; font-weight:700; flex:1` |
| `.set-tag` | `font-size:10px; color:var(--dim); font-weight:700` — "N sets" |

**Set list — `.set-list`**:
`display:flex; flex-wrap:wrap; gap:6px`

**Set pill — `.set-pill`**:
`background:var(--card-alt); border:1px solid var(--border); border-radius:8px; padding:4px 8px; font-size:11px; font-weight:700`

**Skipped pill variant — `.set-pill.skipped`**:
`color:var(--dim); text-decoration:line-through; font-weight:600` — copy: "Skipped"

**Artboard exercise data**:

| # | Exercise | Type | Set tag | Set pills |
|---|----------|------|---------|-----------|
| 1 | Barbell Bench Press | weighted | "4 sets" | 8×60kg · 8×60kg · 7×60kg · 6×60kg |
| 2 | Seated Shoulder Press | weighted | "3 sets" | 10×18kg · 9×18kg · Skipped (skipped) |
| 3 | Push-Ups | bodyweight | "3 sets" | 15 reps · 14 reps · 12 reps |
| 4 | Plank Hold | time | "3 sets" | 00:45 · 00:42 · 00:38 |
| 5 | Triceps Pushdown | weighted | "3 sets" | 12×25kg · 12×25kg · 10×25kg |

**Set pill format by exercise type**:
- Weighted: `{reps}×{weight}` e.g. "8×60kg"
- Bodyweight: `{reps} reps` e.g. "15 reps"
- Time: `MM:SS` e.g. "00:45"
- Skipped: "Skipped" (dim, line-through, weight:600)

**No footer / no action buttons** — the screen has no CTA bar. The only navigation is the back arrow in the appbar.

---

### State C · Error

**Purpose**: Communicate that session data could not be read, offer Retry, and reassure the user that their history as a whole is intact.

**Content area** — `flex:1 1 auto; display:flex; flex-direction:column; align-items:center; justify-content:center; padding:0 32px; text-align:center; gap:14px`

**Error card — `.err-card`**:
`width:100%; background:var(--card); border:1px solid #5c3a3a; border-radius:16px; padding:26px 20px; display:flex; flex-direction:column; align-items:center; gap:12px`

| Element | CSS | Copy / SVG |
|---------|-----|-----------|
| `.err-icon` | `width:40px; height:40px; color:var(--danger)` | Sharp alert-triangle (see below) |
| `.err-title` | `font-size:16px; font-weight:800` | "Couldn't load this workout" |
| `.err-sub` | `font-size:13px; color:var(--muted); line-height:1.5` | "Something went wrong reading local data.\nYour workout history is unaffected." |
| `.retry-btn` | `margin-top:4px; background:var(--lime); color:#131315; font-weight:800; font-size:13px; border-radius:10px; padding:11px 22px` | "Retry" |

**Alert-triangle SVG** (sharp variant — same as SCR-20 error):
```svg
<path d="M12 3l10 18H2L12 3z"/>
<path d="M12 10v4"/>
<circle cx="12" cy="17" r="0.6" fill="currentColor"/>
```
`stroke-width:1.6; fill:none` — sharp (straight sides), informational/technical error context.

> **Error copy comparison**:
> - SCR-20: "Couldn't load your history" / "Your plans and schedule are unaffected."
> - SCR-21: "Couldn't load this workout" / "Your workout history is unaffected."
>
> SCR-21's reassurance line explicitly names "Your workout history" — addressing the user's likely fear that the specific session they cannot see may be permanently lost. It clarifies that the whole history is accessible; only this detail view failed to load.

> **Error content padding**: `0 32px` (no bottom padding). SCR-21 has no navbar, so no bottom offset is needed for content centring (unlike SCR-20's `0 32px 60px` which offset for the nav bar height).

---

## 4 · Interactions & Behaviour

| # | Trigger | Response | Notes |
|---|---------|----------|-------|
| 1 | Screen entered from SCR-20 | Show Loading state; begin Drift read of session record | Immediate; no delay threshold |
| 2 | Drift read succeeds | Transition Loading → Main | No animation specified; instant swap |
| 3 | Drift read fails | Transition Loading → Error | No delay; show error immediately on failure |
| 4 | Tap Retry button (Error state) | Transition Error → Loading; re-trigger Drift read | Button re-entrant guard recommended |
| 5 | Tap back arrow (any state) | Pop screen; return to SCR-20 | Standard navigation pop |
| 6 | Android system back (any state) | Pop screen; return to SCR-20 | Same as #5 |
| 7 | Scroll content (Main state) | `overflow-y:auto` — scrollable content list | Appbar remains fixed (not in scroll container) |
| 8 | Tap set pill (Main state) | No action — pills are read-only display | No tap affordance on pills |
| 9 | App backgrounded during Loading | Loading state persists; Drift read continues in isolate | Behaviour determined by Flutter lifecycle; no special artboard state |
| 10 | Retry while Retry already in progress | Debounce; second tap ignored until read resolves | Guard against double-tap |

**Transition animation**: Push navigation (SCR-20 → SCR-21 slide-in from right). Pop (slide back to left) on back. No transition animation specified between Loading/Main/Error sub-states — use instant widget swap.

---

## 5 · Edge Cases & Error Handling

| # | Scenario | Behaviour |
|---|----------|-----------|
| EC-1 | Drift read throws exception or returns null | Show Error state with Retry |
| EC-2 | Session record exists but is partially corrupt (some exercises missing data) | Show whatever was successfully read; omit corrupt exercise cards; OQ-1 |
| EC-3 | Session references an exercise ID that no longer exists in `exercises` | Show exercise name as recorded in the snapshot (not the catalogue name); historical integrity per FR-3/NFR-1 |
| EC-4 | Session references a workout plan that has been deleted | Same as EC-3; snapshot is self-contained |
| EC-5 | Session has zero exercises (e.g. saved empty) | Show stat-row (0 exercises, 0 sets); section-label "Performance" with no cards below |
| EC-6 | Very long exercise name | `ex-name: flex:1` wraps — card height grows; set-list still renders below |
| EC-7 | Session with many exercises (20+) | `overflow-y:auto` scrolls; no pagination (v1) |
| EC-8 | Session with many sets per exercise (e.g. 15+) | `set-list: flex-wrap:wrap` wraps pills; card height grows |
| EC-9 | Retry succeeds after earlier failure | Replace Error state with Main state; no intermediate Loading flash required (acceptable if Drift read is fast) |
| EC-10 | User exits (back) while Loading | Pop without waiting; cancel pending read in the cubit |

---

## 6 · Responsive & Platform Considerations

**Device widths**:
- Artboard: 390 × 844px (iPhone 14 / mid-size reference).
- Narrower (375px, iPhone SE): `hero-name` at 22px may wrap if name is long; `stat-row gap:10px` will compress stat boxes; acceptable.
- Wider (430px, Pro Max): `ex-card` and `stat-box` expand; `set-list` wraps later; `hero-name` is less likely to wrap.

**Orientation**: Portrait only (ForgeApp global constraint).

**Safe area**: No navbar on this screen. Bottom safe area inset is covered by `padding-bottom:28px` in the content area (`padding:14px 20px 28px`). Confirm this is sufficient for home-indicator devices (≥34pt safe area on iPhone 14+). OQ-2.

**Back gesture**:
- iOS: Swipe-from-left-edge dismisses the pushed screen back to SCR-20 (standard push nav).
- Android: System back gesture / hardware back button pops the screen.

**Appbar layout**: `display:flex; align-items:center; gap:12px` — back arrow left-aligned, title immediately right. No trailing icons/buttons.

---

## 7 · Accessibility

### Touch targets

| Target | Artboard size | 44pt compliant? |
|--------|--------------|----------------|
| Back arrow (appbar) | 22×22px | ❌ Below 44pt — apply `GestureDetector` min hit area of 44×44 or wrap in `IconButton` with padding |
| Retry button | ~115×40px (padding:11px 22px + font) | ✅ Height ≥44pt; width far exceeds |
| Set pills | ~auto×24px | ✅/N/A — read-only, not interactive |

### Colour contrast

| Pair | Foreground | Background | Ratio (approx) | AA (4.5:1)? |
|------|-----------|------------|-----------------|-------------|
| hero-name white on bg | #f5f6f1 | #131315 | ~20:1 | ✅ |
| hero-meta muted on bg | #c4c9ac | #131315 | ~10:1 | ✅ |
| stat-value white on card | #f5f6f1 | #201f22 | ~18:1 | ✅ |
| stat-label dim on card | #8a8f7a | #201f22 | ~4.2:1 | ❌ at 10px/700 — systemic dim issue |
| ex-name white on card | #f5f6f1 | #201f22 | ~18:1 | ✅ |
| set-tag dim on card | #8a8f7a | #201f22 | ~4.2:1 | ❌ at 10px/700 — systemic dim issue |
| section-label dim on bg | #8a8f7a | #131315 | ~4.4:1 | ❌ at 12px/800 — systemic dim issue |
| set-pill white on card-alt | #f5f6f1 | #2a2a2c | ~16:1 | ✅ |
| skipped pill dim on card-alt | #8a8f7a | #2a2a2c | ~3.7:1 | ❌ at 11px/600 — intentional dim (struck-through, decorative) — may be acceptable as non-informational |
| err-title white on card | #f5f6f1 | #201f22 | ~18:1 | ✅ |
| err-sub muted on card | #c4c9ac | #201f22 | ~9:1 | ✅ |
| retry-btn bg on lime | #131315 | #c3f400 | ~17:1 | ✅ |
| appbar-title dim on bg (Loading) | #8a8f7a | #131315 | ~4.4:1 | ❌ at 18px/800 — `18px` qualifies as large text; large-text threshold is 3:1; **passes** at 18px bold |

> **Contrast notes**: `stat-label` and `set-tag` at 10px/700 fail AA (4.5:1) by a narrow margin — same systemic `dim` issue flagged in SCR-17 through SCR-20. `skipped` pill intentionally uses dim + strikethrough to communicate "not done"; the colour is decorative, not informational (the strikethrough carries the semantic meaning). Loading appbar-title in dim passes at large-text threshold (18px bold).

### Semantic roles

| Element | Flutter widget / semantic |
|---------|--------------------------|
| Appbar back button | `IconButton` with `Semantics(label: 'Back')` |
| Screen title "Workout Detail" | `Semantics(header: true)` or `AppBar.title` |
| hero-name | `Text` — may want `Semantics(header: true)` as page heading |
| hero-meta | `Text` |
| stat-row | `Row` — each stat-box: `Semantics(label: '{LABEL}: {VALUE}')` e.g. "Duration: 38 min" |
| section-label "Performance" | `Text` — `Semantics(header: true)` as sub-heading |
| ex-card | `Semantics(label: '{exercise name}, {type}, {N} sets')` |
| set-pill | `Semantics(label: '{pill content}')` |
| set-pill.skipped | `Semantics(label: 'Skipped', hint: 'Set was skipped')` |
| err-card | `Semantics(liveRegion: true)` if shown after Loading |
| retry-btn | `ElevatedButton` with `Semantics(label: 'Retry loading workout detail')` |
| Skeleton elements (Loading) | `Semantics(excludeSemantics: true)` or label "Loading workout detail" at container level |

### Focus management
- On entry, focus should land on the appbar title or first meaningful content.
- On Retry tap in Error state, focus should return to the retry button (or the error card) after reload completes/fails.
- Skeleton: announce "Loading workout detail" to screen reader; suppress individual skeleton elements.

---

## 8 · Component & Design System Mapping

### Existing components (re-used)

| Component | Usage in SCR-21 |
|-----------|----------------|
| `AppBar` (back + title) | Standard overlay/detail screen appbar; `18px/800/.02em`; back chevron `22×22` |
| `type-dot` (8px circle) | Exercise type indicator — weighted=lime, time=cyan, bodyweight=muted |
| `set-pill` (card-alt bubble) | Set performance display; `card-alt; border; border-radius:8px; padding:4px 8px; 11px/700` |
| `set-pill.skipped` | Dim + line-through + weight:600 — first appearance in history screen |
| `error card` (err-card) | `card; dangerBorder #5c3a3a; border-radius:16px; padding:26px 20px`; same as SCR-20 |
| `sharp alert-triangle` | `M12 3l10 18H2L12 3z; stroke-width:1.6` — same as SCR-20 error |
| `retry-btn` (inline) | `lime bg; #131315 text; 800/13px; border-radius:10px; padding:11px 22px` — same as SCR-20 |
| `stat-row` / `stat-box` | 3-column stat summary — compare SCR-19 (card-alt bg) vs SCR-21 (card bg); same geometry |

### New components / patterns

| Component | Description | Key CSS |
|-----------|-------------|---------|
| `translate-shimmer` skeleton | Shimmer via `::after` translate sweep (different from SCR-20's background-position shimmer) | `transform:translateX(-100%)→translateX(100%); 1.4s infinite; rgba(255,255,255,.06) sweep` |
| `hero-name` | Workout name as large primary label | `22px/800` |
| `hero-meta` | Date/time sub-label under name | `12px/muted` |
| `section-label` | Section heading separating summary from performance | `12px/800/uppercase/.06em/dim; margin-top:4px` |
| `ex-card` | Per-exercise card containing head (dot + name + set-tag) and set-list | `card; border; border-radius:14px; padding:12px 14px; gap:8px` |
| `ex-head` | Exercise card header row | `flex; align-items:center; gap:8px` |
| `set-tag` | "N sets" count label in ex-head | `10px/700/dim` |
| `set-list` | Wrapping flex row of set pills | `flex; flex-wrap:wrap; gap:6px` |
| `appbar-dim` state | Loading: both back icon and title rendered in `dim` color | Loading-state appbar variant — first occurrence |

### Token gaps

| Raw value | Proposed token | Occurrences |
|-----------|---------------|-------------|
| `rgba(255,255,255,.06)` | `color.shimmerSheen` | SCR-21 Loading shimmer overlay |
| `font-weight:600` | `weight.medium` | `set-pill.skipped` (2nd+ occurrence; first was SCR-19) |
| `border-radius:8px` | `radius.pill` | `set-pill`, `sk-pill` (same as SCR-19) |
| `border-radius:10px` | `radius.dialogButton` | `retry-btn` (same as SCR-20) |
| `letter-spacing:.06em` | `tracking.sectionLabel` | `section-label` (new value; `.04em` was stat-label) |

### Updated token inventory
Existing non-token values previously identified (SCR-19/20) — unchanged:
- `#1e2a12` → `color.successFill`
- `rgba(196,201,172,.25)` → `color.spinnerTrack`
- `#35342f` → `color.shimmerMid`
- `linear-gradient(180deg, rgba(19,19,21,0) 0%, var(--bg) 40%)` → `color.footerFade`

---

## 9 · Acceptance Criteria Mapping

| Criterion | Source | Verification |
|-----------|--------|-------------|
| AC-1: Skeleton shown while loading | FR-1 | Loading state visible on screen entry; transitions away when Drift read completes |
| AC-2: Full detail shown after load | FR-2 | hero-name, hero-meta, stat-row (Duration / Exercises / Sets Logged), section-label "Performance", all exercise cards with type-dot + name + set-tag + set pills |
| AC-3: Plan edits/deletions don't alter displayed data | FR-3, NFR-1 | Data read from `workout_sessions` snapshot; no read from `workout_plans` at display time; verify with plan-edit regression test |
| EC-1: Load failure → error state | NFR-2 | Drift exception → Error state shows (not empty, not partial); Retry button present |
| Back navigation → SCR-20 | User story exit | Back arrow and system back both pop to SCR-20 |

---

## 10 · Open Questions / Assumptions

| # | Question | Owner | Build-blocker? | Assumption held |
|---|----------|-------|---------------|----------------|
| OQ-1 | Partial session data (corrupt exercise entries): silently omit or show error? | Engineering/PM | **Yes** | Silently omit corrupt entries; show what loaded. If entire record is unreadable, show Error state. |
| OQ-2 | Bottom safe area: `padding-bottom:28px` sufficient for home-indicator iPhones (≥34pt)? | Engineering | **Yes** | Confirm; may need `MediaQuery.of(context).padding.bottom` + 14px for safe area devices |
| OQ-3 | Duration stat: displayed as "38 min" — is this rounded to the nearest minute or truncated? | Engineering/Design | No | Rounded to nearest minute |
| OQ-4 | Set pill date format for time exercises: "00:45" — MM:SS or is HH:MM:SS used for >1 min? | Design/Engineering | No | MM:SS for ≤59:59; upgrade to H:MM:SS for longer durations |
| OQ-5 | Weighted exercise pill format: "8×60kg" — always kg? What about lb users? | PM/Engineering | No | Display as stored (kg); unit preference localisation is out of scope v1 |
| OQ-6 | Is "Sets Logged" the count of completed sets only (excluding skipped) or total set slots? | PM | No | Total logged set slots including skipped |
| OQ-7 | Scroll position on re-entry after navigating to a sub-screen (none defined, but future-proofing): preserved or reset? | Engineering | No | Reset to top (no sub-screens currently exit here) |
| OQ-8 | Loading state: appbar dim colour (`dim`) — is this a deliberate design decision or oversight? | Design | No | Deliberate — appbar reflects the "unknown" state when session identity is not yet confirmed; document as `appbar-dim` variant |
| OQ-9 | translate-shimmer vs background-position-shimmer: which variant is canonical for new skeleton screens? | Design/Engineering | No | Both documented; decide canonical variant in skeleton component sprint |
| OQ-10 | section-label "Performance" — always shown even if zero exercises? | Design | No | Always shown (consistent structure even for edge case zero-exercise sessions) |
| OQ-11 | Retry button touch target: ~40px height (padding:11px + 13px font + 11px = ~40px) — meets 44pt? | Design | No | Slightly under; increase retry-btn to `padding:13px 22px` |
