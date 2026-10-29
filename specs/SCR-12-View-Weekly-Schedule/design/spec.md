# Design Specification: View Weekly Workout Schedule (SCR-12)

**Story**: US-SCR12 — View Weekly Workout Schedule  
**Version**: 1.0  
**Date**: 2026-09-12  
**Design reference**: https://claude.ai/code/artifact/197c0750-693e-409e-9034-d858cccfb0ff  
**Artboards**: `Main.dc.html` (Populated), `Empty.dc.html` (Empty State), `Loading.dc.html` (Skeleton Grid), `Error.dc.html` (Load Failure)  
**Status**: Draft — 8 open questions flagged (see §10)

---

## §1 Overview & Goal

### Problem

A user who has assigned workout plans to days of the week has no at-a-glance view of the current week's programme. Without a week view, they must browse individual plan cards or remember their schedule mentally — creating friction and reducing adherence. When today's scheduled workout exists, there is no direct launch path; the user must navigate to Plans, find the plan, and tap Start from there.

### User

App-unlocked user who has (or has not) assigned workout plans in the `schedule_entries` table. The user may be in a first-time-use state (no plans exist at all), an empty-schedule state (plans exist but none assigned), or a scheduled state (one or more days have an assignment).

### Goal

Present the full calendar week (Mon–Sun) as a single scrollable list where:
- Every day is visible at all times (no hidden days, no day-specific tabs)
- Today is visually distinguished and, when a plan is assigned, offers a single-tap **Start** action into SCR-15
- Days with non-today assignments show a quick-edit affordance into SCR-13
- Rest days are labelled clearly; unscheduled days do not appear as errors

### Success metric / outcome

- User can identify today's workout at a glance and start it with one tap (FR-4 / AC-4)
- User can see the full week's structure in one scroll (FR-3 / AC-3)
- No data loss or confusion: the error state explicitly states plans and history are unaffected (EC-1)

### App context

SCR-12 is one of six bottom-nav destinations. It occupies the **Schedule** tab (third slot). The screen is reachable directly from the bottom navigation bar and is part of the app's primary structure — it is not a modal or pushed route.

---

## §2 User Flow

### Entry points

| From | Trigger |
|------|---------|
| SCR-06 Home Dashboard | Tap the "Schedule" bottom-nav item |
| Any screen | Tap the "Schedule" bottom-nav item |

The bottom navigation is persistent across all primary screens (Home, Plans, Schedule, History, Progress, Stats). SCR-12 is thus reachable from anywhere in the main shell.

### Exit points

| Destination | Trigger |
|-------------|---------|
| SCR-13 Assign/Edit Schedule | Tap the edit (pencil) icon on any day row (non-today, scheduled or unscheduled) |
| SCR-13 Assign/Edit Schedule | Tap the "Schedule a plan" CTA in the empty state |
| SCR-15 Workout Pre-Start / Overview | Tap the "Start" button on today's scheduled row |
| Any other tab | Tap another bottom-nav item |

### State machine

```
App unlocked → Tap Schedule tab
        │
        ▼
[Loading — Skeleton Grid]
        │
  Read Drift successful?
   Yes ┤         No
       │          └──── [Schedule Load Failure]
       │                      │         │
       │                   Retry     (stay)
       │                      └──── [Loading]
       │
  Any day has an assignment?
    Yes ┤               No
        │                └──── [Empty State]
        ▼                           │
[Populated Weekly Schedule]     "Schedule a plan" → SCR-13
   Scheduled day (not today)      │
        └─ edit icon ─────────────► SCR-13
   Today's row (plan assigned)
        └─ Start ─────────────────► SCR-15
```

---

## §3 Screen-by-Screen Breakdown

### 3.0 Persistent chrome (all states)

**App bar** (no back button — this is a top-level tab destination):
```
padding: 6px 20px [bottom varies by state]
title: "Schedule"
font-size: 22px; font-weight: 800; letter-spacing: .02em; color: var(--white)
```

**Bottom navigation bar** (identical across all states):
```
height: auto; padding: 10px 14px 18px
background: var(--bg)  → #131315
border-top: 1px solid var(--border)  → #444933
display: flex; justify-content: space-between
```

6 nav items: Home, Plans, **Schedule** (active), History, Progress, Stats

Each nav item:
```
width: 52px; display: flex; flex-direction: column; align-items: center; gap: 4px
icon: 22×22 stroke SVG
label: 10px / 600 weight
default: color var(--dim) → #8a8f7a
active (Schedule tab): icon + label color var(--lime) → #c3f400
```

During **Loading state**, non-active nav items have `opacity: .5` — the Schedule item remains at full opacity with lime colour.

---

### 3.1 Loading State (`Loading.dc.html`)

**Artboard**: `Loading.dc.html`

The app bar renders with its full title "Schedule" (`padding: 6px 20px 16px`). The content area shows 7 skeleton rows — one per day of the week — matching the populated layout structure so the transition to populated is visually stable.

**Content area**:
```
padding: 0 20px 16px; display: flex; flex-direction: column; gap: 8px; overflow: hidden
```

**Skeleton row** (7× identical):
```
display: flex; align-items: center; gap: 12px
background: var(--card)  → #201f22
border: 1px solid var(--border)  → #444933
border-radius: 14px; padding: 12px 14px
```

Inside each skeleton row:
| Element | Spec |
|---------|------|
| Day badge placeholder | `width:44px; height:34px; border-radius:8px; background:var(--card-alt)` → `#2a2a2c` |
| Content shimmer | `flex:1; height:14px; border-radius:6px; background: linear-gradient(90deg, var(--card-alt) 25%, #35342f 37%, var(--card-alt) 63%); background-size:400% 100%; animation: shimmer 1.4s ease infinite` |

**Shimmer animation**:
```css
@keyframes shimmer { 0% { background-position: 100% 0; } 100% { background-position: 0 0; } }
```

The shimmer moves left-to-right at 1.4 s ease per cycle. Mid-tone: `#35342f` (non-token warm highlight between `--card` and `--card-alt`).

**Nav bar during loading**: same chrome; non-active items at `opacity: .5`.

---

### 3.2 Empty State (`Empty.dc.html`)

**Artboard**: `Empty.dc.html`

Shown when no day has a schedule assignment. This is the "configured but empty" first-use state — the user is unlocked and the app is functional, but has not yet used SCR-13 to assign any plans.

**App bar** (`padding: 6px 20px 0` — no bottom padding, tighter than populated):
- Title: "Schedule" — same type spec

**Content area** (centred layout):
```
flex: 1 1 auto; display: flex; flex-direction: column; align-items: center; justify-content: center
padding: 0 32px 60px; text-align: center; gap: 18px
```

| Element | Spec |
|---------|------|
| **Icon** | Calendar/grid SVG, `60×60`, `color: var(--dim)` → `#8a8f7a`, `stroke-width: 1.4` |
| **Title** | `"No workouts scheduled"` · `18px / 800` · `color: var(--white)` |
| **Subtitle** | `"Assign a workout plan to a day of the week to see it here."` · `14px / normal` · `color: var(--muted)` → `#c4c9ac` · `line-height: 1.5` · `max-width: 250px` |
| **CTA button** | `"Schedule a plan"` · `14px / 800` · `background: var(--lime)` · `color: #131315` · `border-radius: 12px` · `padding: 14px 24px` · `margin-top: 6px` |

**Nav bar**: normal (full opacity on all items; active Schedule tab is lime).

---

### 3.3 Populated Weekly Schedule (`Main.dc.html`)

**Artboard**: `Main.dc.html`

Shown when at least one day has a schedule assignment. All seven days are always shown — there is no filtering or collapsing of rest days.

**App bar** (`padding: 6px 20px 16px`):
- Title: "Schedule"

**Content area**:
```
flex: 1 1 auto; overflow-y: auto; padding: 0 20px 16px
display: flex; flex-direction: column; gap: 8px
```

Scrollable — with many exercise names, the list can exceed the viewport.

#### Day row — default (non-today)

```
display: flex; align-items: center; gap: 12px
background: var(--card)  → #201f22
border: 1px solid var(--border)  → #444933
border-radius: 14px; padding: 12px 14px
```

| Sub-element | Spec |
|-------------|------|
| **Day badge** | `width: 44px; flex: 0 0 auto; display: flex; flex-direction: column; align-items: center` |
| Day name | `11px / 700` · `color: var(--muted)` → `#c4c9ac` · `text-transform: uppercase` · `letter-spacing: .04em` |
| Day number | `16px / 800` · `color: var(--white)` · `margin-top: 2px` |
| **Plan name** (scheduled) | `14px / 700` · `color: var(--white)` |
| **Plan meta** (scheduled) | `11px / normal` · `color: var(--muted)` — value: **"Weekly"** for recurring assignments |
| **Rest label** (unscheduled) | `13px / normal` · `color: var(--dim)` → `#8a8f7a` · `font-style: italic` — value: **"Rest day"** |
| **Edit icon** | `16×16` pencil SVG · `color: var(--dim)` · `stroke-width: 1.8` · appears on every row (scheduled and rest) in non-today state |

#### Day row — today (highlighted)

```
border-color: var(--lime)  → #c3f400     ← overrides #444933
background: var(--card-alt)  → #2a2a2c   ← overrides #201f22
```

Today-specific type changes:
- Day name: `color: var(--lime)` (overrides muted)
- Day number: inherits white

Today row contents when plan is assigned:
- Plan name and meta rendered identically to a non-today scheduled row
- Plan meta value: **"Weekly · Today"** (comma separates recurrence + today marker)
- The pencil edit icon is **replaced** by the **Start button**

| Element | Spec |
|---------|------|
| **Start button** | `background: var(--lime)` · `color: #131315` · `font-weight: 800` · `font-size: 12px` · `border-radius: 9px` · `padding: 8px 14px` · `flex: 0 0 auto` |

> **OQ note**: The artboard shows today with a plan assigned. What renders in today's row when no plan is assigned for today? Presumably a rest-label + edit icon (same as non-today rest). See OQ-1.

**Nav bar**: full opacity; Schedule tab active (lime).

---

### 3.4 Schedule Load Failure (`Error.dc.html`)

**Artboard**: `Error.dc.html`

Shown when the Drift read for `schedule_entries` fails. The error card is centred in the available viewport between the app bar and the bottom nav.

**App bar** (`padding: 6px 20px 0`):
- Title: "Schedule"

**Content area**:
```
flex: 1 1 auto; display: flex; flex-direction: column; align-items: center; justify-content: center
padding: 0 32px; text-align: center; gap: 14px
```

**Error card**:
```
width: 100%; background: var(--card)  → #201f22
border: 1px solid #5c3a3a            ← non-token danger border
border-radius: 16px; padding: 26px 20px
display: flex; flex-direction: column; align-items: center; gap: 12px
```

| Element | Spec |
|---------|------|
| **Icon** | Warning triangle SVG · `40×40` · `color: var(--danger)` → `#ff6b6b` · `stroke-width: 1.6` |
| **Title** | `"Couldn't load your schedule"` · `16px / 800` · `color: var(--white)` |
| **Subtitle** | `"Something went wrong reading local data.\nYour plans and history are unaffected."` · `13px / normal` · `color: var(--muted)` · `line-height: 1.5` |
| **Retry button** | `"Retry"` · `13px / 800` · `background: var(--lime)` · `color: #131315` · `border-radius: 10px` · `padding: 11px 22px` · `margin-top: 4px` |

Error icon type: **warning triangle** (not X-in-circle as in SCR-10 Error/Not-Found). Triangular warning signals a transient/recoverable error, consistent with the Retry action. The X-in-circle pattern (SCR-10) signals permanent unavailability.

**Nav bar**: full opacity and standard colours (Schedule still active/lime — the user is still on the Schedule tab).

---

## §4 Interactions & Behavior

| # | Element | State | Interaction | Outcome |
|---|---------|-------|-------------|---------|
| I-1 | Schedule nav tab | Any | Tap (when already on Schedule) | No-op / scroll to top (OQ-2) |
| I-2 | Any other nav tab | Any | Tap | Navigate to that tab's root screen |
| I-3 | "Schedule a plan" CTA | Empty | Tap | Navigate to SCR-13 (Assign/Edit Schedule) |
| I-4 | Day row — non-today, scheduled | Populated | Tap edit icon | Navigate to SCR-13 for that day's assignment |
| I-5 | Day row — non-today, rest | Populated | Tap edit icon | Navigate to SCR-13 to assign a plan to that day |
| I-6 | Day row — non-today | Populated | Tap row body (not icon) | OQ-3 — likely navigates to SCR-13 or no-op |
| I-7 | Today row — plan assigned | Populated | Tap **Start** button | Navigate to SCR-15 (Workout Pre-Start/Overview) for today's plan |
| I-8 | Today row — rest day | Populated | Tap edit icon (OQ-1) | Navigate to SCR-13 to assign today |
| I-9 | **Retry** button | Error | Tap | Re-trigger Drift read; transition to Loading state, then to Populated or Empty on success |
| I-10 | Content scroll | Populated | Vertical swipe | Scroll day list; nav bar and app bar stay fixed |
| I-11 | Screen enters view | Any | Tab switch | Trigger fresh Drift read (OQ-4 — always refresh, or cache?) |

### Transitions

| From | To | Transition |
|------|----|-----------|
| Loading | Populated | Crossfade or instant swap — 7 skeleton rows map to 7 day rows, enabling a stable layout swap |
| Loading | Empty | Crossfade — skeleton collapses to centred empty state |
| Loading | Error | Crossfade — skeleton replaces with error card |
| Error → Retry | Loading | Error card fades; skeleton grid reappears |
| Any state | Tab switch | Standard Flutter bottom-nav transition (fade or slide per platform default) |

---

## §5 Edge Cases & Error Handling

| # | Scenario | Handling |
|---|---------|---------|
| EC-1 | Drift `schedule_entries` read throws exception | Display Schedule Load Failure state (§3.4); copy: "Couldn't load your schedule" + "Your plans and history are unaffected" |
| EC-2 | A `scheduleEntry` references a `planId` that no longer exists in `workout_plans` (broken reference, e.g. plan was deleted) | OQ-5 — show the day as Rest day, or show an error inline on that row? The user story does not specify this case. Recommendation: treat as unscheduled (show "Rest day") and silently log the orphaned entry |
| EC-3 | All 7 days are rest days (no assignments exist) | Display Empty State (§3.2) — same as zero assignments |
| EC-4 | Plan name is very long | Plan name in row should truncate with ellipsis on one line — row height is fixed; the plan-meta line takes the second line. OQ-6 — no artboard shows this; recommend `overflow: hidden; text-overflow: ellipsis; white-space: nowrap` on `.plan-name` |
| EC-5 | Today's date cannot be determined (clock edge case, system time unavailable) | OQ-7 — no today row highlighted; all rows render as non-today default |
| EC-6 | User returns to Schedule tab after completing today's workout | OQ-8 — Start button should remain visible (session history is separate); or should it change to a "Done" state? The user story only specifies FR-4 surfaces Start for today's scheduled workout; no completion state is specified |
| EC-7 | Multiple rapid Retry taps | Debounce — only one Drift read in flight at a time |
| EC-8 | App is in Loading state and user switches tabs | Loading continues in background; on return the result is shown (Populated, Empty, or Error) |

---

## §6 Responsive & Platform Considerations

### Device width

The layout uses fixed 20 px horizontal padding (content) and 14 px (nav bar), leaving:

| Band | Day row width | Notes |
|------|-------------|-------|
| 375 px (iPhone SE) | 335 px | Plan name has slightly less space; truncation risk increases |
| 390 px (baseline artboard) | 350 px | Design baseline |
| 430 px (Pro Max) | 390 px | More comfortable; no layout changes needed |
| Tablet (768 px+) | OQ: no artboard | Recommend `max-width: 500px` centred on tablet |

The day badge column is fixed at 44 px. The edit icon is 16 px. The Start button is `padding: 8px 14px` ≈ min ~80 px wide. The plan name + meta column is `flex: 1` and fills remaining width.

### iOS vs Android

- **Nav bar safe area**: The nav bar `padding-bottom: 18px` is likely not accounting for the iOS safe-area home indicator. Flutter's `SafeArea` or `MediaQuery.of(context).padding.bottom` should be applied to the nav bar's bottom padding at the implementation level. The artboard uses a fixed 18 px — confirm this is sufficient or whether it needs to grow on iPhone 14+/15 models.
- **List scroll physics**: On iOS, the day list should use bouncy scroll; on Android, overscroll glow. Both are Flutter defaults per platform.
- **Bottom nav system back**: Android system back from SCR-12 should exit the app (or go to SCR-06 Home — OQ on overall nav stack ownership).

### Orientation

ForgeApp is portrait-only. No landscape handling required.

---

## §7 Accessibility

### Touch targets

| Element | Visual size | Pass 44 pt? | Recommendation |
|---------|-------------|-------------|----------------|
| Edit icon (16×16) | 16 pt | ❌ | Wrap in 44×44 invisible tap target (`GestureDetector` with `HitTestBehavior.opaque`) |
| Start button (`8px 14px` pad, 12px text ≈ ~37px height) | ~37 pt | ❌ | Set `minHeight: 44` on the button |
| "Schedule a plan" CTA (`14px 24px` pad, 14px text ≈ ~46px height) | ~46 pt | ✅ | |
| Retry button (`11px 22px` pad, 13px text ≈ ~42px height) | ~42 pt | ❌ | Set `minHeight: 44` |
| Day row (full row area) | ~58 pt height (12+12 padding + ~34 content) | ✅ | Row body tap should be handled even if only the icon/button is the named target |

### Screen reader (VoiceOver / TalkBack)

| State | Announcement |
|-------|-------------|
| Loading | "Schedule. Loading." — or individual rows announce as "Loading, placeholder" |
| Empty | "No workouts scheduled. Assign a workout plan to a day of the week to see it here. Schedule a plan, button." |
| Populated — rest day | "Tuesday, 2, Rest day. Edit schedule, button." |
| Populated — scheduled non-today | "Monday, 1, Push Day — Upper Body, Weekly. Edit schedule, button." |
| Populated — today (plan assigned) | "Wednesday, 3, Pull Day — Back and Biceps, Weekly, Today. Start workout, button." |
| Error | "Couldn't load your schedule. Something went wrong reading local data. Your plans and history are unaffected. Retry, button." |

The lime border on the today row conveys today status visually — this must also be communicated semantically (e.g. via a `"Today"` semantic label or the plan-meta "Today" string read aloud).

### Colour contrast

| Pair | Values | Approx ratio | Pass AA? |
|------|--------|-------------|---------|
| "Schedule" title on bg | `--white` (#f5f6f1) on `--bg` (#131315) | ~14:1 | ✅ |
| Day number on card | `--white` on `#201f22` | ~11:1 | ✅ |
| Day name (muted) on card | `#c4c9ac` on `#201f22` | ~5.5:1 | ✅ |
| Day name (today, lime) on card-alt | `#c3f400` on `#2a2a2c` | ~9:1 | ✅ |
| Plan name on card | `--white` on `#201f22` | ~11:1 | ✅ |
| Plan meta (muted) on card | `#c4c9ac` on `#201f22` | ~5.5:1 | ✅ |
| Rest label (dim) on card | `#8a8f7a` on `#201f22` | ~3.0:1 | ⚠ — applies to non-essential italic label; passes AA Large |
| Start button text on lime | `#131315` on `#c3f400` | ~14:1 | ✅ |
| Edit icon (dim) on card | `#8a8f7a` on `#201f22` | ~3.0:1 | ⚠ — UI component (icon), not text; border context helps; flag for review |
| Error title on card | `--white` on `#201f22` | ~11:1 | ✅ |
| Error sub (muted) on card | `#c4c9ac` on `#201f22` | ~5.5:1 | ✅ |
| Retry button on lime | `#131315` on `#c3f400` | ~14:1 | ✅ |
| Empty-state sub (muted) on bg | `#c4c9ac` on `#131315` | ~6:1 | ✅ |

### Focus order (populated)

App bar title (decorative) → Day row 1 [day badge — decorative] → Plan name / Rest label (text) → Edit icon or Start button → Day row 2 … → Nav bar items

---

## §8 Component & Design System Mapping

### Reused patterns from prior screens

| Pattern | Source | SCR-12 usage |
|---------|--------|-------------|
| App bar (title-only, no back chevron) | SCR-08 Plans List | Identical: 22px/800, same padding, no icons |
| Bottom navigation bar | SCR-06 Home | Identical 6-item bar; Schedule is the active tab |
| Card chrome (card fill, 1px border, 14px radius) | SCR-08/10 exercise cards | Day row uses same values (14px vs 16px in exercise cards — slight difference, see OQ) |
| Shimmer skeleton | SCR-08 Loading, SCR-09 Saving, SCR-10 Loading | Same keyframe and colour ramp; SCR-12 uses 7 rows of badge + line |
| Lime primary CTA button (14px/800, 12px radius, 14px/24px padding) | SCR-08 empty state | Empty-state CTA matches; slight radius difference (12px here vs 14px elsewhere) |
| Error card (card fill, danger border `#5c3a3a`, 16px radius) | SCR-10 Error/Not-Found | Identical border spec; SCR-12 uses warning-triangle icon, SCR-10 uses X-in-circle |
| Lime Retry button | SCR-11 Delete Failure | Same intent (lime = safe/neutral action) |

### New components for SCR-12

| Component | Type | Rationale |
|-----------|------|-----------|
| `WeekScheduleList` | New widget | 7-item fixed list of `DayRow` widgets; drives Loading/Populated/Empty/Error state machine |
| `DayRow` | New widget | Flex row: day badge + plan content + trailing action (edit icon or Start button); highlights if today |
| `DayBadge` | New widget | Stacked day name + day number; lime colour when today |
| `WeekScheduleBloc` | New Bloc | States: `WeekScheduleLoading`, `WeekSchedulePopulated`, `WeekScheduleEmpty`, `WeekScheduleError`; events: `WeekScheduleRequested`, `WeekScheduleRetried` |
| `StartWorkoutButton` | New widget | Lime 12px/800 pill (`padding: 8px 14px; border-radius: 9px`); different from primary footer button (14px/800, full-height) |

### Token gaps / non-token values

| Gap | Value | Recommendation |
|-----|-------|---------------|
| Shimmer highlight | `#35342f` | Non-token warm mid-tone — same as SCR-08/10; acceptable as inline or adopt as `color.shimmerHighlight` |
| Error border | `#5c3a3a` | Already identified as `color.dangerBorder` in SCR-09/10/11 — tokenise now |

---

## §9 Acceptance Criteria Mapping

| AC / FR | Description | Covered by |
|---------|-------------|-----------|
| AC-1 / FR-1 / NFR-1 | Skeleton weekly grid shown while schedule data is loading | §3.1 — 7 skeleton rows, shimmer animation, "Schedule" title visible |
| AC-2 / FR-2 | Empty state with "Schedule a plan" CTA when no days have assignments | §3.2 — "No workouts scheduled" title, subtitle, lime CTA button |
| AC-3 / FR-3 | Populated week view showing which plans are on which days; recurring assignments visible | §3.3 — all 7 days shown; plan name + "Weekly" meta; rest days labelled |
| AC-4 / FR-4 | "Start" action for today's scheduled workout; selecting it goes to SCR-15 | §3.3 (today row) + §4 I-7 — lime Start button on today row; tap → SCR-15 |
| EC-1 | Schedule load failure shows error state with retry | §3.4 — error card with copy + lime Retry button; §4 I-9 — Retry re-triggers load |
| SEC-1 / SEC-2 | Screen requires app to be unlocked; schedule data not shown while locked | Not a UI design concern for SCR-12 itself — enforced by app-level lock gate before this screen is reachable. No lock UI designed here. |

---

## §10 Open Questions / Assumptions

| # | Question | Owner | Blocks build? | Working assumption |
|---|---------|-------|--------------|-------------------|
| OQ-1 | **Today row, no plan assigned**: What renders? The artboard only shows today with a plan. Does an unscheduled today show the rest label + edit icon (same as other rest days)? Or is there a different "Schedule today" affordance? | Design | No | Rest label + edit icon, same as non-today rest rows; no special today-unscheduled state |
| OQ-2 | **Tapping the active Schedule tab**: What happens when already on SCR-12? Scroll to top? No-op? Pop to root? | Engineering | No | Scroll-to-top (standard Flutter convention for bottom-nav re-tap) |
| OQ-3 | **Tapping the row body** (not the edit icon, not the Start button): Is the entire row tappable as a navigate-to-SCR-13 shortcut, or is only the icon tappable? | Design | No | Only the edit icon is the tap target; row body is non-interactive (edit icon already gives 16px affordance, which needs a 44pt hit area wrapper) |
| OQ-4 | **Data freshness**: When the user navigates back to SCR-12 from SCR-13 (after editing a schedule), does SCR-12 always re-read Drift, or does it show cached data? | Engineering | **Yes** — data consistency | Always re-read on `initState`/`onResume`; this ensures a plan assigned in SCR-13 shows immediately on return |
| OQ-5 | **Broken plan reference**: A `scheduleEntry` points to a deleted `planId`. What does the day row show? | Engineering | No | Treat as unscheduled — show "Rest day" label and silently remove the orphaned entry |
| OQ-6 | **Long plan name**: No artboard shows truncation. What is the truncation rule for `.plan-name`? | Design | No | Single-line truncation with ellipsis (`overflow: ellipsis`); plan meta takes the second line |
| OQ-7 | **Plan meta string format**: The artboard shows "Weekly" for recurring and "Weekly · Today" for today. Is "Weekly" the only recurrence type? Are there "Every 2 weeks" or similar patterns? The user story mentions "recurring assignments" but the data model may only support "weekly" (Decisions Log §4). | PM / Engineering | No | Weekly is the only recurrence type per Decisions Log §4; meta string is always "Weekly" |
| OQ-8 | **Post-completion state**: If the user completes today's workout and returns to SCR-12, does the Start button remain, or change to indicate completion (e.g. "Done" or a checkmark)? The user story specifies FR-4 as surfacing a Start action; no completion state is specified. | PM / Design | No | Start button remains unchanged — completion is tracked in History, not reflected on the schedule view |

### Assumptions already made

- **A-1**: The day list is always Mon–Sun, exactly 7 rows, fixed order. The artboard confirms this (Mon 1, Tue 2, Wed 3, Thu 4, Fri 5, Sat 6, Sun 7). Days of the month are shown as single digits (1–7 in the artboard) — in production, these should be the actual current calendar dates for the week.
- **A-2**: "Weekly" recurrence is the only assignment type (per Decisions Log §4 — one plan per day maximum, weekly cadence).
- **A-3**: The edit icon appears on every non-today row, both scheduled and unscheduled. Tapping it navigates to SCR-13 where the user can assign or change that day's plan. This is an illustrative affordance from the artboard — not explicitly specified in the Inventory beyond "navigation to SCR-13."
- **A-4**: The artboard date numbers (1–7) are placeholder values. In production, each row shows the actual calendar date for that day of the current week (Mon = actual Monday date, etc.).
- **A-5**: SCR-12 does not have a "no plans exist" pre-empty state. If the user has no plans in `workout_plans`, the schedule will simply be empty (all rest days → empty state). There is no special "create a plan first" branching on SCR-12; SCR-13 handles that guidance.
