# Design Specification: Plan Detail (SCR-10)

**Story**: SCR-10-Plan-Detail  
**Version**: 1.0  
**Date**: 2026-09-11  
**Design reference**: https://claude.ai/code/artifact/c6bc9b70-dea9-4664-ba32-eaa0016dc478  
**Artboards**: `Main.dc.html` (Populated), `Loading.dc.html` (Skeleton), `ErrorNotFound.dc.html` (Error/Not-Found)  
**Status**: Draft — 3 open questions flagged (see §10)

---

## §1 Overview & Goal

### Problem

After a user taps a plan on the Plans list (SCR-08), or is redirected from the Create/Edit screen (SCR-09) following a successful save, they need a dedicated read-only view that presents the complete workout plan: its name, exercise count, and every exercise's target parameters. From this view they must also be able to reach all downstream actions — editing the plan, deleting it, scheduling it, or starting a session.

### Goal

Provide a fast, scannable Plan Detail screen that:

1. Displays plan name, exercise count, and all exercise target fields in a read-only layout.
2. Offers clear access to four downstream actions: Edit, Delete, Schedule, and Start Workout.
3. Handles loading latency with a skeleton UI that mirrors the populated layout.
4. Handles plan-not-found and database read errors with a clear, recovery-oriented error state.

### Business context

ForgeApp is fully offline; Drift is the only data source. No network call is ever made from this screen. All exercise data (exerciseId → name, type) is resolved from `exercises`. All plan data is read from `workout_plans`.

### Success metric

A user who taps a plan card on SCR-08 can read all target values for all exercises within 2 seconds, with no loading flash if Drift returns data quickly enough to skip the skeleton.

---

## §2 User Flow

### Entry points

| From | Trigger | Data passed |
|------|---------|-------------|
| SCR-08 Plan List | Tap plan card | `planId` |
| SCR-09 Create/Edit | Successful save (redirect) | `planId` of newly saved / updated plan |

### State machine

```
Entry (planId) ──────────► [Loading / Skeleton]
                                   │
                    ┌──────────────┼──────────────────┐
                    ▼                                  ▼
           database read success                  database read fail / planId missing
                    │                                  │
                    ▼                                  ▼
          [Populated — Plan Detail]         [Error / Not-Found]
            │        │       │       │           │         │
           Edit    Delete  Start   Schedule   Back btn  Back chevron
            │        │     Workout    │           │         │
            ▼        ▼       ▼        ▼           └────┬────┘
          SCR-09   SCR-11  SCR-15  SCR-13              ▼
                                                     SCR-08
```

### Exit points

| Destination | Trigger | State |
|------------|---------|-------|
| SCR-09 (Edit) | Edit icon button | Populated |
| SCR-11 (Delete confirm) | Delete icon button | Populated |
| SCR-15 (Active Workout) | "Start Workout" button | Populated |
| SCR-13 (Schedule) | "Schedule" button | Populated |
| SCR-08 (Plans List) | Back chevron (any state) | Any |
| SCR-08 (Plans List) | "Back to Plans" button | Error/Not-Found |

---

## §3 Screen-by-Screen Breakdown

### 3.0 Shared chrome

**Status bar**: 28 px tall, flex:0 0 auto. Appears in all three states.

---

### 3.1 Loading — Skeleton State (`Loading.dc.html`)

The skeleton is shown immediately while the database read is in flight. It mirrors the populated layout so the transition is smooth.

#### App bar

- `display:flex; align-items:center; justify-content:space-between; padding:6px 20px 4px; flex:0 0 auto`
- **Left**: back chevron SVG, 20×20 px, `color:var(--white)` — real, not skeleton (tappable to cancel load and go back)
- **Right**: two skeleton icon placeholders with `display:flex; gap:8px`
  - Each: `width:34px; height:34px; border-radius:10px; background:var(--card)` — no SVG inside

#### Title block

- `padding:10px 20px 16px; flex:0 0 auto; display:flex; flex-direction:column; gap:8px`
- **Title skeleton**: `height:20px; width:70%; border-radius:6px;` shimmer gradient
- **Meta skeleton**: `height:12px; width:35%; border-radius:6px;` shimmer gradient
- **Shimmer**: `background:linear-gradient(90deg, #2a2a2c 25%, #35342f 37%, #2a2a2c 63%); background-size:400% 100%; animation:shimmer 1.4s ease infinite`
  - `@keyframes shimmer { 0%{background-position:100% 0} 100%{background-position:0 0} }`

#### Content

- `flex:1 1 auto; overflow:hidden; padding:0 20px 16px; display:flex; flex-direction:column; gap:10px`
- **Skeleton exercise cards** (3 shown regardless of actual count — OQ-4):
  - `background:var(--card); border:1px solid var(--border); border-radius:16px; padding:16px; display:flex; flex-direction:column; gap:10px`
  - sk-title: `height:15px; width:55%; border-radius:6px;` shimmer
  - sk-sub: `height:11px; width:30%; border-radius:6px;` shimmer

#### Footer

- `flex:0 0 auto; padding:14px 20px 20px; border-top:1px solid var(--border); display:flex; gap:10px`
- **Two skeleton buttons**: each `flex:1; height:48px; border-radius:12px; background:var(--card)` — no labels

---

### 3.2 Populated — Plan Detail (`Main.dc.html`)

#### App bar

- `display:flex; align-items:center; justify-content:space-between; padding:6px 20px 4px; flex:0 0 auto`
- **Left group** (`display:flex; align-items:center; gap:14px`):
  - Back chevron: `width:20px; height:20px; color:var(--white)` — navigates to SCR-08
- **Right group** (`display:flex; gap:8px`):
  - **Edit button**: `width:34px; height:34px; border-radius:10px; background:var(--card)` — pencil SVG `width:17px; height:17px; color:var(--muted)` — navigates to SCR-09
  - **Delete button**: `width:34px; height:34px; border-radius:10px; background:var(--card)` — trash SVG `width:17px; height:17px; color:#ff6b6b` (danger) — navigates to SCR-11

#### Title block

- `padding:10px 20px 16px; flex:0 0 auto`
- **Plan name**: `font-size:22px; font-weight:800; color:var(--white)` — e.g. "Push Day — Upper Body"
- **Exercise count**: `font-size:13px; color:var(--muted); margin-top:6px` — e.g. "3 exercises"

#### Content area

- `flex:1 1 auto; overflow-y:auto; padding:0 20px 16px; display:flex; flex-direction:column; gap:10px`

**Section label**:
- `font-size:11px; font-weight:700; letter-spacing:.12em; color:var(--dim); text-transform:uppercase; margin-bottom:2px`
- Text: "EXERCISES"

**Exercise cards** (one per exercise in plan order):

Card chrome:
- `background:var(--card); border:1px solid var(--border); border-radius:16px; padding:14px 16px; display:flex; flex-direction:column; gap:12px`

Header row:
- Exercise name: `font-size:15px; font-weight:700; color:var(--white)`
- Type row: `display:flex; align-items:center; gap:6px; font-size:11px; color:var(--muted); font-weight:600; margin-top:4px`
  - Type dot: `width:7px; height:7px; border-radius:50%` — color by type:
    - **Weighted** → `background:#7df4ff` (cyan)
    - **Time-based** → `background:#c3f400` (lime)
    - **Bodyweight** → `background:#c4c9ac` (muted)
  - Type label: "Weighted" / "Time-based" / "Bodyweight"

**Field layout by exercise type** (all field boxes are read-only):

*Field box spec* (same across all types):
- `background:var(--card-alt); border:1px solid var(--border); border-radius:10px; padding:8px 6px; text-align:center`
- `.fval`: `font-size:14px; font-weight:800; color:var(--white)`
- `.flabel`: `font-size:10px; color:var(--muted); margin-top:2px`

**Weighted** (e.g. Barbell Bench Press: 4 Sets / 8 Reps / 60 kg / 90s rest):
```
Row 1: display:grid; grid-template-columns:repeat(3,1fr); gap:8px
  [Sets: 4] [Reps: 8] [Weight: 60 kg]

Row 2: display:grid; grid-template-columns:1fr; gap:8px
  [Rest: 90s]  ← full width
```

**Time-based** (e.g. Plank: 3 Sets / 00:45 / 60s rest):
```
Single row: display:grid; grid-template-columns:repeat(3,1fr); gap:8px
  [Sets: 3] [Duration: 00:45] [Rest: 60s]
```

**Bodyweight** (e.g. Push-Up: 3 Sets / 15 Reps / 60s rest):
```
Single row: display:grid; grid-template-columns:repeat(3,1fr); gap:8px
  [Sets: 3] [Reps: 15] [Rest: 60s]
```

Value display formats:
- **Rest**: integer seconds displayed as `"Ns"` — e.g. `"90s"`, `"60s"`
- **Weight**: integer kg displayed as `"N kg"` — e.g. `"60 kg"` (space + lowercase kg)
- **Duration**: mm:ss — e.g. `"00:45"`
- **Sets / Reps**: plain integer — e.g. `"4"`, `"15"`

#### Footer

- `flex:0 0 auto; padding:14px 20px 20px; border-top:1px solid var(--border); display:flex; gap:10px`
- **Schedule button** (secondary): `flex:1; border-radius:12px; padding:15px; text-align:center; font-weight:800; font-size:14px; background:var(--card); border:1px solid var(--border); color:var(--white)` → "Schedule"
- **Start Workout button** (primary): `flex:1; border-radius:12px; padding:15px; text-align:center; font-weight:800; font-size:14px; background:var(--lime); color:#131315` → "Start Workout"

---

### 3.3 Error / Not-Found State (`ErrorNotFound.dc.html`)

Covers two cases with a single UI: (a) database read throws exception, (b) `planId` not found in `workout_plans`. No retry — the action is to return to the plan list.

#### App bar

- `display:flex; align-items:center; padding:6px 20px 0; flex:0 0 auto` — **no bottom padding**
- Back chevron only: `width:20px; height:20px; color:var(--white)` — NO edit/delete icon buttons

#### Content

- `flex:1 1 auto; display:flex; flex-direction:column; align-items:center; justify-content:center; padding:0 32px; text-align:center; gap:14px`

**Error card**:
- `width:100%; background:var(--card); border:1px solid #5c3a3a; border-radius:16px; padding:26px 20px; display:flex; flex-direction:column; align-items:center; gap:12px`

Contents:
- **Icon**: `width:40px; height:40px; color:#ff6b6b (danger)` — X-in-circle SVG (crossed lines inside circle, `stroke-width:1.6`) — signals "gone/unavailable", distinct from SCR-08's warning triangle
- **Title**: `font-size:16px; font-weight:800; color:var(--white)` — **"This plan is no longer available"**
- **Body**: `font-size:13px; color:var(--muted); line-height:1.5` — **"It may have been deleted, or something went wrong reading local data."**
- **Button**: `background:var(--lime); color:#131315; font-weight:800; font-size:13px; border-radius:10px; padding:11px 24px; margin-top:4px` — **"Back to Plans"**

#### Footer

None — the error state has no footer.

---

## §4 Interactions & Behavior

| # | Element | Interaction | Outcome |
|---|---------|-------------|---------|
| I-1 | Back chevron (all states) | Tap | Pop to SCR-08 |
| I-2 | Edit icon button (populated) | Tap | Push SCR-09 in edit mode; pass `planId` |
| I-3 | Delete icon button (populated) | Tap | Navigate to SCR-11; pass `planId` |
| I-4 | "Start Workout" button (populated) | Tap | Navigate to SCR-15; pass `planId` |
| I-5 | "Schedule" button (populated) | Tap | Navigate to SCR-13; pass `planId` |
| I-6 | "Back to Plans" button (error) | Tap | Pop to SCR-08 |
| I-7 | Exercise list (populated) | Scroll | `content` area scrolls; app bar, title block, and footer remain fixed |
| I-8 | Back chevron (loading) | Tap | Cancel database read; pop to SCR-08 |

**Read-only constraint**: No element within an exercise card is interactive. Field boxes are display-only — no tap, edit, or focus handling.

**Loading transition**: The skeleton shows immediately. When the database read completes, the skeleton animates out and the populated layout fades or replaces it. If the read completes before the skeleton renders (sub-frame), the skeleton is skipped and the populated view is shown directly.

**Error branching**: Both "plan deleted" and "read failure" resolve to the same Error/Not-Found state with identical copy. The distinction between the two causes is intentionally hidden from the user — recovery action is the same in both cases.

---

## §5 Edge Cases & Error Handling

| # | Scenario | Handling |
|---|---------|---------|
| EC-1 | `planId` not found in `workout_plans` | Show Error/Not-Found state immediately (no retry) |
| EC-2 | Drift `workout_plans` read throws exception | Show Error/Not-Found state |
| EC-3 | Exercise ID in plan not found in `exercises` | OQ-1 — no artboard; see §10 |
| EC-4 | Plan has 0 exercises | Content area shows section label "EXERCISES" with no exercise cards below; footer remains visible; Start Workout behaviour — OQ-3 |
| EC-5 | Very long plan name | Wraps within title block (no `overflow:hidden` or line clamp in artboard); OQ-2 |
| EC-6 | Large number of exercises | Exercise list scrolls within `content` area; footer and app bar remain fixed |
| EC-7 | User taps Delete → reaches SCR-11 → deletion confirmed | SCR-11 is responsible for popping SCR-10 (see OQ-6 in §10) |
| EC-8 | User taps Delete → reaches SCR-11 → cancels | Returns to SCR-10 Populated; plan unchanged |
| EC-9 | Plan edited in SCR-09 and returned → stale data risk | SCR-10 should re-read from the database on `resume`/`pop` from child screens (OQ-5) |
| EC-10 | `exercises` table unavailable | Fall back to Error/Not-Found (exercise names unresolvable) |

---

## §6 Responsive & Platform Considerations

### Device size

| Band | Behaviour |
|------|-----------|
| 390 px (artboard baseline) | Exact spec dimensions |
| Larger (414–430 px, Android XL) | Content area and footer gain width; field grids widen proportionally; title and meta grow in horizontal space |
| Smaller (375 px iPhone SE) | No layout breakpoints; exercise list scrolls sooner; footer always fixed |

### iOS

- Left-edge swipe-to-go-back works as Back chevron (I-1 / I-8)
- No scrims or overlays on this screen; no swipe-to-dismiss guard needed

### Android

- System back button = Back chevron (pops to SCR-08)
- Delete icon uses danger red; no long-press context menu expected on icon buttons

### Skeleton count

The artboard shows 3 skeleton exercise cards. The actual count shown should match the plan's stored exercise count where available, or default to 3 if the count is not yet known before the database read (OQ-4).

---

## §7 Accessibility

### Touch targets

| Element | Visual size | Minimum 44 pt? | Note |
|---------|-------------|----------------|------|
| Back chevron | 20×20 px | ❌ | Needs invisible tap area or `GestureDetector` with larger hit test |
| Edit icon button | 34×34 px | ❌ | 10 pt shy; hit test expansion recommended |
| Delete icon button | 34×34 px | ❌ | Same; also needs destructive semantics label |
| "Start Workout" button | ~170×48 px | ✅ | |
| "Schedule" button | ~170×48 px | ✅ | |
| "Back to Plans" button | ~100×36 px | ❌ (36 px tall) | Wrap in sufficient vertical padding |

### Screen reader labels

| Element | Label | State |
|---------|-------|-------|
| Back chevron | "Back" | All |
| Edit icon button | "Edit plan" | Populated |
| Delete icon button | "Delete plan" (destructive trait) | Populated |
| "Start Workout" | "Start workout" | Populated |
| "Schedule" | "Schedule plan" | Populated |
| Exercise card | Group: "{exercise name}, {type}" | Populated |
| Field box — Sets | "N sets" | Populated |
| Field box — Reps | "N reps" | Populated |
| Field box — Weight | "N kg weight" | Populated |
| Field box — Rest | "Ns rest" | Populated |
| Field box — Duration | "mm:ss duration" | Populated |
| "Back to Plans" | "Back to Plans" | Error/Not-Found |
| Loading screen | "Loading plan details" (live region) | Loading |
| Error card | "Plan not available: This plan is no longer available." (focus trap or live region) | Error/Not-Found |

### Contrast

| Pair | Tokens | Approx ratio | Pass AA? |
|------|--------|-------------|---------|
| Plan title on bg | `--white` (#f5f6f1) on `--bg` (#131315) | ~15:1 | ✅ |
| Muted text on bg | `--muted` (#c4c9ac) on `--bg` (#131315) | ~8:1 | ✅ |
| fval on card-alt | `--white` on `#2a2a2c` | ~12:1 | ✅ |
| flabel on card-alt | `--muted` on `#2a2a2c` | ~6:1 | ✅ |
| Start Workout label | `#131315` on `--lime` (#c3f400) | ~14:1 | ✅ |
| Schedule label | `--white` on `--card` (#201f22) | ~11:1 | ✅ |
| Delete icon | `#ff6b6b` on `--card` (#201f22) | ~3.5:1 | ⚠ Icon-only; acceptable for decorative icon if label is accessible |
| Back to Plans label | `#131315` on `--lime` (#c3f400) | ~14:1 | ✅ |
| Error body on card | `--muted` on `--card` (#201f22) | ~5.5:1 | ✅ |

### Focus order (populated)

Back → Edit → Delete → [Exercise cards — read-only, skip or navigate within] → Schedule → Start Workout

---

## §8 Component & Design System Mapping

### Reused components

| Component | Source screen | SCR-10 usage | Notes |
|-----------|--------------|-------------|-------|
| `ForgeAppBar` | SCR-08, SCR-09 | Variant with back + dual icon buttons in right cluster | New: right icon button with danger SVG color |
| `ExercisePlanCard` (read-only) | SCR-09 (editable) | Same visual; no remove button, no editable field boxes | New `readOnly: true` mode |
| `FieldBox` | SCR-09 | Read-only display of exercise targets | No `TextEditingController`, no tap handling |
| `FieldGrid` | SCR-09 | 3-col layout + 1-col rest row for weighted | Same `gridTemplateColumns` logic |
| `TypeDot` | SCR-09 | Color-coded dot by exercise type | Confirms 3-color spec: cyan/lime/muted |
| `ForgeFooter` | New in SCR-10 | 2-button footer: secondary + primary | May be generalized from existing footer patterns |

### New / modified components

| Component | Type | Purpose |
|-----------|------|---------|
| `PlanDetailPage` | New screen | Root widget for SCR-10; houses Bloc + layout |
| `PlanDetailBloc` | New Bloc | States: `PlanDetailLoading`, `PlanDetailLoaded`, `PlanDetailNotFound` |
| `PlanTitleBlock` | New widget | Renders plan name (22px/800) + exercise count (13px muted) |
| `SectionLabel` | New or extract | All-caps dim label; 11px/700, letter-spacing:.12em; may be shared with other screens |
| `PlanDetailSkeleton` | New widget | Full-screen skeleton: 2 shimmer title lines + N shimmer exercise cards + 2 skeleton footer buttons |
| `PlanNotAvailableCard` | New widget | X-in-circle error card; distinct from `CouldntLoadCard` (SCR-08 uses warning triangle + retry) |

### Token usage

All tokens pulled from the single dark-theme variable set:

| Token | Value | Usage |
|-------|-------|-------|
| `color.bg` | `#131315` | Screen background |
| `color.card` | `#201f22` | Exercise card fill, footer secondary button, skeleton icon buttons |
| `color.cardAlt` | `#2a2a2c` | Field box fill, shimmer gradient base |
| `color.border` | `#444933` | Card borders, footer separator, field box borders |
| `color.lime` | `#c3f400` | Start Workout button, time-based type dot, "Back to Plans" button |
| `color.muted` | `#c4c9ac` | Plan meta, type label, flabel, error body, bodyweight type dot |
| `color.white` | `#f5f6f1` | Plan name, exercise names, fval, Schedule button label |
| `color.dim` | `#8a8f7a` | Section label, edit icon SVG |
| `color.cyan` | `#7df4ff` | Weighted type dot |
| `color.danger` | `#ff6b6b` | Delete icon SVG, error card icon |
| `#5c3a3a` | (no token name) | Error card border — same non-token value as SCR-08/09 error |

---

## §9 Acceptance Criteria Mapping

### From SCR-10 user story

| AC / FR | Description | Covered by |
|---------|-------------|-----------|
| FR-1 (Loading) | Skeleton shown while database read is in flight | §3.1 full spec |
| FR-2 (Populated) | Plan name, exercise count, all exercise targets displayed read-only | §3.2 full spec |
| FR-3 (Edit) | Edit icon button navigates to SCR-09 with planId | §4 I-2, §3.2 app bar |
| FR-4 (Delete) | Delete icon button navigates to SCR-11 with planId | §4 I-3, §3.2 app bar |
| FR-5 (Start Workout) | "Start Workout" button navigates to SCR-15 with planId | §4 I-4, §3.2 footer |
| FR-6 (Schedule) | "Schedule" button navigates to SCR-13 with planId | §4 I-5, §3.2 footer |
| FR-7 (Error/Not-Found) | Error/Not-Found state shown on read failure or planId missing | §3.3 full spec |
| FR-7 (Recovery) | "Back to Plans" in error state pops to SCR-08 | §4 I-6 |

### Explicit ACs from story

| AC | Description | Pass condition |
|----|-------------|---------------|
| AC-1 | Plan name and all exercises visible from plan detail | §3.2 title block + exercise cards spec |
| AC-2 | Edit navigates to SCR-09 in edit mode | §4 I-2 |
| AC-3 | Delete navigates to SCR-11 | §4 I-3 |
| AC-4 | Start Workout navigates to SCR-15 | §4 I-4 |
| AC-5 | Schedule navigates to SCR-13 | §4 I-5 |
| AC-6 | Error state shown for read failure and missing plan | §3.3; both causes → same UI |
| AC-7 | "Back to Plans" from error returns to SCR-08 | §4 I-6 |

---

## §10 Open Questions / Assumptions

| # | Question | Owner | Blocks build? | Working assumption |
|---|---------|-------|--------------|-------------------|
| OQ-1 | If an `exerciseId` in `workout_plans` cannot be resolved in `exercises` (exercise was deleted), what does the exercise card show? A placeholder name, an error inline, or is the exercise silently omitted? | Design / PM | **Yes** — FR-2, FR-5 | Show a placeholder card: "Exercise unavailable" in dim text; do not block Start Workout for now |
| OQ-2 | Long plan name: does it wrap to multiple lines in the title block (no `line-clamp` in artboard) or is it clamped to 1 line with ellipsis? | Design | No | Allow wrapping to 2 lines max; ellipsis on overflow if longer |
| OQ-3 | Empty plan (0 exercises): is "Start Workout" disabled? No artboard for this state. | Design / PM | **Yes** — FR-5 | Disable "Start Workout" with reduced opacity; show no exercise cards, only "EXERCISES" section label |
| OQ-4 | How many skeleton exercise cards should the loading state show? Artboard shows 3. Should it use the stored exercise count (from plan metadata) or always show 3? | Engineering | No | Always show 3 skeleton cards; a stored count is not yet available before the database read completes |
| OQ-5 | When the user returns from SCR-09 (Edit) or SCR-11 (Delete cancel), does SCR-10 re-read from the database to refresh? | Engineering | No | Yes — re-trigger database read on `resume` to reflect any changes made in child screen |
| OQ-6 | After deletion confirmed in SCR-11: is SCR-10 popped from the stack, or does it first transition to the Error/Not-Found state before popping? | Navigation / PM | No | SCR-11 pops its own screen AND SCR-10, landing on SCR-08; SCR-10 is not shown post-deletion |
| OQ-7 | SCR-10 presentation style: pushed onto nav stack from SCR-08, or presented modally? Affects iOS back-swipe behaviour and transition animation. | Design / Engineering | No | Pushed (not modal); consistent with SCR-09 |
| OQ-8 | Type dot colours confirmed: weighted → cyan (#7df4ff), time-based → lime (#c3f400), bodyweight → muted (#c4c9ac). Does SCR-09's exercise card also use this 3-colour coding in the type row, or was that only white/muted? | Design | No | This spec confirms the 3-colour dot from SCR-10 Main artboard; SCR-09 spec should be updated to match |
| OQ-9 | "N exercises" count: does it reflect `plan.exerciseIds.length` (raw count including broken refs), or only successfully-resolved exercises? | Engineering | No | Use raw `plan.exerciseIds.length` for simplicity; placeholder card handles the broken-ref display |

### Assumptions already made

- **A-1**: The type dot in SCR-09 exercise cards should also use the 3-colour coding from SCR-10 (cyan/lime/muted). SCR-09 spec will need a minor update when OQ-8 is resolved.
- **A-2**: `#5c3a3a` (error card border) is the same non-token colour used in SCR-08 and SCR-09 error surfaces. It should be adopted as `color.dangerBorder` in the design token set.
- **A-3**: The footer "Start Workout" button is always visible (not conditionally hidden), even for a plan with 0 exercises. Disabled state covers this case (OQ-3).
- **A-4**: SCR-10 does not implement a "Not-Found" retry because both error causes (deleted plan and read failure) share the same single recovery path: return to SCR-08. Unlike SCR-08's transient read error (which can be retried), a missing planId is permanent.
