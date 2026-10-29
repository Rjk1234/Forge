# Design Specification — SCR-06 Home Dashboard

**Story ID**: US-SCR-06  
**Flow**: FLOW-02 — Home / Navigation Shell  
**Status**: Draft  
**Created**: 2026-09-10  
**Design System Source**: `Doc/DESIGN-SYSTEM.md` · `Doc/Design/DESIGN-SYSTEM.md`  
**User Story Source**: `Doc/UserStories/SCR-06-Home-Dashboard.md`  
**Inventory Source**: `Doc/Screen_Flow_Use_Case_Inventory_v1.1.1.md` §4  
**Design Reference (Canvas)**: [ForgeApp Home Dashboard](https://claude.ai/code/artifact/c449041f-bab6-4dbc-b30e-1f3b6e1304f5) — 5 artboards: `Main.dc.html`, `NoWorkoutToday.dc.html`, `Empty.dc.html`, `Loading.dc.html`, `Error.dc.html`

> **Figma note**: The user story references `fileKey=0oxHvmnCM27XHqmEZjojtb`. No Figma frame URL was provided for this spec. All component and token values below are sourced from `Doc/DESIGN-SYSTEM.md` and the Claude Design canvas artboards listed above. Cross-check against the Figma frame named **`SCR-06/Home Dashboard`** when a file link is available.

---

## 1. Overview & Goal

### Problem Being Solved

After logging in, the user needs an immediate answer to two questions: "What should I do today?" and "Where do I go next?" SCR-06 is the persistent tab root that answers both — it surfaces today's scheduled workout (if any) and provides one-tap navigation to every major area of the app. Without it, the user would have to remember which tab to visit after every login and would have no at-a-glance picture of their day.

### Who the User Is

A single local user who has successfully passed the static login check (SCR-03 or SCR-01 with stored lock state = UNLOCKED). This screen is not reachable when locked. There are no roles, no permission tiers, and no multi-user concept.

### Primary Success Metric / Outcome

> The user reaches SCR-06 and, within 3 seconds, either taps "Start workout" (when one is scheduled today) or navigates to their intended destination tab — all from a single screen, with no hunting.

Secondary: A first-time user sees a clear onboarding call-to-action and knows exactly what to do next.

---

## 2. User Flow

### Entry Points

| Entry | Condition | Origin |
|---|---|---|
| Post-login | Credentials matched on SCR-03 | SCR-03 — Login |
| Already unlocked | Lock flag = UNLOCKED on cold launch | SCR-01 — Splash |
| Post-logout navigation (return to home) | User taps Home tab from any other root tab | Bottom navigation bar |
| Post-workout | Workout cancelled (confirmed discard) | SCR-18 — Cancel Confirmation |
| Back from a sub-screen | User completes or backs out of any non-root screen | Any non-root screen (SCR-09 → SCR-08 → SCR-06, etc.) |

There is no deep link, push notification, or QR entry path.

### Step-by-Step Flow (All Paths)

```
[Login succeeds / App already unlocked]
         │
         ▼
   SCR-06 HOME DASHBOARD
   (database read begins immediately on mount)
         │
    ┌────┴──────────────────────────────────────┐
    │  database read                               │
    ├─ In flight ──────────────────────────► LOADING state
    │  (spinner + "Loading your dashboard…")   │
    │                                          │ (read completes)
    │                                          ▼
    │                              ┌───────────────────────┐
    │                              │  database read succeeded   │
    │                              ├───────────────────────┤
    │                              │ No plans/schedule/     │
    │                              │ history data           │
    │                              │ ──────────────────► EMPTY state
    │                              │                    (CTA: "Create first plan")
    │                              │                          │ tap CTA
    │                              │                          ▼ SCR-09 (Create Plan)
    │                              │                    
    │                              │ Has data, today has      │
    │                              │ scheduled workout        │
    │                              │ ──────────────────► POPULATED state
    │                              │                    (Today's Workout card + Quick Links)
    │                              │                          │
    │                              │ Has data, no workout     │
    │                              │ today                    │
    │                              │ ──────────────────► NO WORKOUT TODAY state
    │                              │                    (Rest day card + Quick Links)
    │                              │
    │                              │ database read failed         │
    │                              └──────────────────────────► ERROR state
    │                                                    (error card + Retry + nav usable)
    │
    └─ Nav tabs always visible (except during Loading: dimmed)
```

### Exit Points from SCR-06

| Destination | Trigger |
|---|---|
| SCR-08 — Workout Plans List | Tap "Plans" nav tab or Quick Link |
| SCR-12 — Weekly Schedule | Tap "Schedule" nav tab or Quick Link |
| SCR-15 — Workout Pre-Start | Tap on today's workout card (Populated state) |
| SCR-20 — Workout History List | Tap "History" nav tab or Quick Link |
| SCR-22 — Progress Comparison | Tap "Progress" nav tab or Quick Link |
| SCR-23 — Statistics Dashboard | Tap "Stats" nav tab or Quick Link |
| SCR-09 — Create Plan | Tap CTA in Empty state |
| SCR-25 — Profile / Account | (Via Profile icon if provided — see §10 OQ-2) |
| SCR-01 — Splash | After logout confirmation (SCR-26) |

---

## 3. Screen-by-Screen Breakdown

SCR-06 is a single screen with five distinct UI states. All five states share the same page chrome: header, bottom navigation bar, and screen background.

---

### 3.0 Shared Chrome (All States)

#### Screen Structure

```
┌─────────────────────────────────────┐  390 × 844 px artboard
│ Status bar (28px safe area top)     │
├─────────────────────────────────────┤
│ HEADER (8px 20px 18px padding)      │
│   "Welcome back"    ← greeting      │
│   "FORGE"           ← app name      │
├─────────────────────────────────────┤
│                                     │
│   CONTENT AREA  (flex:1, scroll)    │
│   padding: 0 20px 16px              │
│   gap: 18px between sections        │
│                                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│ BOTTOM NAV BAR (fixed, 10/14/18px)  │
│  Home · Plans · Schedule · History  │
│  · Progress · Stats                 │
└─────────────────────────────────────┘
```

#### Header Tokens

| Element | Value |
|---|---|
| Screen background | `color.bg` `#131315` |
| Header padding | `8px 20px 18px` |
| Greeting text | "Welcome back" — 13px/normal, `color.textMuted` `#c4c9ac`, letter-spacing 0.04em |
| App name | "FORGE" — 22px/800, `color.white` `#f5f6f1`, letter-spacing 0.06em; "GE" in `color.lime` `#c3f400` |

#### Bottom Navigation Bar Tokens

The 6-tab bar is always visible and is the primary navigation mechanism. It uses the Design System's **Bottom navigation (root tabs only)** pattern.

| Element | Value |
|---|---|
| Bar fill | `color.bg` `#131315` |
| Top border | 1px solid `color.border` `#444933` |
| Padding | `10px 14px 18px` (bottom accounts for safe-area home indicator) |
| Tab item width | 52px |
| Icon size | 22 × 22px, line stroke 1.8px, no fill |
| Active icon color | `color.lime` `#c3f400` |
| Inactive icon color | `color.textDim` `#8a8f7a` |
| Tab label | 10px/600 |
| Active label color | `color.lime` `#c3f400` |
| Inactive label color | `color.textDim` `#8a8f7a` |
| Gap between icon and label | 4px |

**Tab order and icons** (left → right):

| Tab | Icon description | Destination |
|---|---|---|
| Home | House outline (path d="M4 11l8-7 8 7" + "M6 10v9h12v-9") | SCR-06 (current) |
| Plans | List lines (path d="M4 7h16M4 12h16M4 17h10") | SCR-08 |
| Schedule | Calendar (rect + grid lines) | SCR-12 |
| History | Clock circle | SCR-20 |
| Progress | Trend/chart | SCR-22 |
| Stats | Bar chart | SCR-23 |

Home tab is always the active tab while on SCR-06.

---

### 3.1 State — Loading · UC-SCR06-02

**Trigger**: Immediately on screen mount, before database read completes.

**Reference artboard**: `Loading.dc.html`

**What the user sees:**
- Header (greeting + app name) visible
- Content area: vertically centered spinner + loading text
- Bottom nav bar visible but all non-Home tabs dimmed to 50% opacity (tabs are not interactive during loading)

**Component specs:**

| Element | Value |
|---|---|
| Spinner | 36 × 36px circle, 3px border; `color.cardAlt` `#2a2a2c` base color, `color.lime` top segment; 360° CSS rotation animation, 0.9s linear infinite |
| Loading text | "Loading your dashboard…" — 13px/normal, `color.textMuted`, letter-spacing 0.02em |
| Gap between spinner and text | 14px |
| Nav tab opacity (non-Home) | 0.5 |

**Behavior note**: The Design System pattern is skeleton blocks. This screen uses a spinner per FR-2 / NFR-1 (2026-09-05 simplification — skeleton was explicitly replaced with a simple loading indicator). See §10 OQ-1.

---

### 3.2 State — Empty (First-Use / No Data) · UC-SCR06-01

**Trigger**: database read succeeded AND no plans, schedule entries, or workout history exist.

**Reference artboard**: `Empty.dc.html`

**What the user sees:**
- Header visible
- Content area: full-height centered layout (flexbox column, align center, justify center), no today's card, no quick links
- Dumbbell/barbell icon (large, dim)
- "No workouts yet" headline
- Supporting copy
- Lime CTA button: "Create your first workout plan"
- Bottom nav present and interactive

**Component specs:**

| Element | Value |
|---|---|
| Empty icon | 64 × 64px dumbbell SVG outline, `color.textDim` `#8a8f7a` |
| Title | "No workouts yet" — 19px/800, `color.white` |
| Sub-copy | "Create your first workout plan to start tracking your training here." — 14px/normal, `color.textMuted`, line-height 1.5, max-width 260px, text-centered |
| Gap between elements | 18px |
| CTA button | Lime fill `#c3f400`, `color.bg` text `#131315`, 14px/800, 12px border-radius, 14px top/bottom + 26px left/right padding |
| CTA label | **"Create your first workout plan"** |
| Content vertical offset | Shifted upward from true center by ~60px bottom padding to feel upper-center |

**CTA tap behavior**: Routes to SCR-09 — Create / Edit Workout Plan. See §10 OQ-3 for whether this navigates via the Plans tab (maintaining tab state) or as a modal push.

**Distinction from "no results" states**: This is the first-time use empty state — the user has never created any content. It is distinct from a filter returning no results (which does not apply to Home) and from the Error state (database read succeeded, there is just no data).

---

### 3.3 State — Populated, Today's Workout Scheduled · UC-SCR06-03 (variant A)

**Trigger**: database read succeeded AND at least one of {plans, schedule, history} exists AND today's weekday has an assigned plan in the schedule.

**Reference artboard**: `Main.dc.html`

**What the user sees:**
- Header visible
- Today's Workout card (filled, non-dashed border) with plan name, exercise summary chips, and "SCHEDULED" tag
- Quick Links grid below
- Bottom nav

**Today's Workout Card:**

| Element | Value |
|---|---|
| Card fill | `color.card` `#201f22` |
| Card border | 1px solid `color.border` `#444933` |
| Card corner radius | 16px |
| Card padding | 18px |
| Card internal gap | 10px |
| Section label (top-left) | "TODAY'S WORKOUT" — 11px/700, `color.textDim`, uppercase, letter-spacing 0.12em |
| Scheduled tag (top-right) | "SCHEDULED" — 10px/700, letter-spacing 0.08em, `color.bg` text on `color.lime` fill, 20px border-radius, padding 4px 9px |
| Plan name | Plan's name string — 19px/800, `color.white`, margin-top 6px |
| Meta row | "{N} exercises · {type description}" — 13px, `color.textMuted`; dot separator (3px circle, `color.textDim`) |
| Exercise chip row | Flex row, 8px gap, margin-top 4px |
| Each exercise chip | `color.cardAlt` `#2a2a2c` fill, 1px `color.border` border, 10px radius, 8px/6px padding, flex:1, centered |
| Chip value (b) | 13px/700, `color.white` |
| Chip label | 11px/normal, `color.textMuted` |

**Exercise chips (3 chips):**
1. **"{N} Exercises"** — total exercise count for the plan
2. **"{Primary type}"** — the dominant exercise type in the plan (e.g. "Weighted", "Bodyweight")
3. **"{N}s Rest / set"** — representative rest period (e.g. "90s")

**Data mapping:**

| Chip | Data source | Format |
|---|---|---|
| Exercise count | `WorkoutPlanRecord.planExercises.length` | Integer, e.g. "6" |
| Primary type | Most frequent `ExerciseType` in the plan's exercises | "Weighted" / "Bodyweight" / "Time-based" |
| Rest period | Representative rest period (see §10 OQ-4) | "{N}s" where N is seconds |

**Tap behavior on Today's Workout card**: Routes to SCR-15 — Workout Pre-Start Overview for the scheduled plan.

---

### 3.4 State — Populated, No Workout Today · UC-SCR06-03 (variant B)

**Trigger**: database read succeeded AND data exists BUT today's weekday has no plan assigned in the schedule.

**Reference artboard**: `NoWorkoutToday.dc.html`

**What the user sees:**
- Header visible
- Today card: same dimensions as variant A but dashed border and rest-day content (no tap target)
- Quick Links grid
- Bottom nav

**Rest Day Card:**

| Element | Value |
|---|---|
| Card fill | `color.card` `#201f22` |
| Card border | 1px **dashed** `color.border` `#444933` (distinguishes from scheduled card) |
| Card corner radius | 16px |
| Card padding | 22px 18px |
| Card layout | Flex column, align center, text-center, 8px gap |
| Rest icon | 30 × 30px circle-minus SVG, `color.textDim` `#8a8f7a` |
| Title | "No workout scheduled for today" — 16px/700, `color.white` |
| Sub-copy | "Enjoy your rest day, or check Schedule to add one." — 13px, `color.textMuted`, line-height 1.4 |

**Tap behavior**: No tap action on the rest-day card itself. The "check Schedule" phrase is informational — it is NOT a tappable link within the card (use the Schedule nav tab or Quick Link instead).

---

### 3.5 State — Error · UC-SCR06-04

**Trigger**: database read fails (SDS-ERR-5 — local storage read failure).

**Reference artboard**: `Error.dc.html`

**What the user sees:**
- Header visible
- Content area: centered, full-width error card
- Bottom nav present and **fully interactive** (navigation shell must remain usable — NFR-2)

**Error Card:**

| Element | Value |
|---|---|
| Card fill | `color.card` `#201f22` |
| Card border | 1px solid `color.dangerBorder` `#5c3a3a` |
| Card corner radius | 16px |
| Card padding | 26px top/bottom, 20px left/right |
| Card layout | Flex column, align center, gap 12px |
| Error icon | 40 × 40px warning triangle SVG (exclamation, dot), `color.danger` `#ff6b6b` |
| Error title | **"Couldn't load your dashboard"** — 16px/800, `color.white` |
| Error sub-copy | **"Something went wrong reading your local data.**<br>**Your plans and history are safe."** — 13px, `color.textMuted`, line-height 1.5 |
| Retry button | Lime fill `#c3f400`, `color.bg` text `#131315`, 13px/800, 10px radius, 11px top/bottom + 22px left/right padding, label **"Retry"** |

**Retry behavior**: Re-triggers the database read. Returns to Loading state → then resolves to Empty, Populated, or Error again.

**Critical constraint**: The bottom nav bar tabs MUST remain tappable during the Error state. The user must be able to navigate to Plans, Schedule, etc. even if the Home content area failed to load.

---

### 3.6 Quick Links Section (Populated & No-Workout-Today States)

Both populated states show the Quick Links section below the today's workout/rest card.

**Reference artboard**: `Main.dc.html` quick links section

| Element | Value |
|---|---|
| Section label | "QUICK LINKS" — 11px/700, `color.textDim`, uppercase, letter-spacing 0.12em, margin-bottom 10px |
| Grid | 3-column CSS grid, 10px gap |
| Each tile | `color.card` `#201f22` fill, 1px solid `color.border` border, 14px radius, 14px top/bottom + 8px left/right padding, flex column, align center, gap 8px |
| Icon | 22 × 22px line icon, `color.cyan` `#7df4ff`, stroke 1.8px, no fill |
| Label | 12px/600, `color.white` |

**Quick Link tiles (5 items in 3-col grid):**

| Position | Label | Icon | Destination |
|---|---|---|---|
| Row 1, Col 1 | Plans | List lines | SCR-08 — Workout Plans List |
| Row 1, Col 2 | Schedule | Calendar | SCR-12 — Weekly Schedule |
| Row 1, Col 3 | History | Clock circle | SCR-20 — Workout History List |
| Row 2, Col 1 | Progress | Trend / chart | SCR-22 — Progress Comparison |
| Row 2, Col 2 | Stats | Bar chart | SCR-23 — Statistics Dashboard |
| Row 2, Col 3 | — | (empty cell) | No tile — grid leaves this empty |

**Grid behavior**: With 5 items in a 3-column grid, the 6th cell is empty. The fifth tile (Stats, position Row 2 Col 2) does not stretch — it occupies one cell, leaving the third column of row 2 visually blank. This is the designed layout from the artboard; no special treatment for the empty cell is needed.

> **Figma cross-check**: Verify that the icon used for "Progress" and "Stats" are visually distinct (they are similar domains). The artboard uses a trend-line icon for Progress and a vertical-bar chart for Stats.

---

### 3.7 Content and Microcopy Summary

| Element | Copy | State |
|---|---|---|
| Greeting | "Welcome back" | All |
| App name | "FORGE" (GE in lime) | All |
| Loading text | "Loading your dashboard…" | Loading |
| Empty title | "No workouts yet" | Empty |
| Empty sub | "Create your first workout plan to start tracking your training here." | Empty |
| Empty CTA | "Create your first workout plan" | Empty |
| Today's card section label | "TODAY'S WORKOUT" | Populated (scheduled) |
| Scheduled tag | "SCHEDULED" | Populated (scheduled) |
| Rest day title | "No workout scheduled for today" | Populated (no workout) |
| Rest day sub | "Enjoy your rest day, or check Schedule to add one." | Populated (no workout) |
| Error title | "Couldn't load your dashboard" | Error |
| Error sub | "Something went wrong reading your local data.\nYour plans and history are safe." | Error |
| Retry button | "Retry" | Error |
| Quick links label | "QUICK LINKS" | Populated (both) |

---

### 3.8 Data Requirements

| Data item | Source | Format |
|---|---|---|
| Today's scheduled plan | `schedule_entries` table — look up weekday (1–7, where 1 = Monday) matching today's `DateTime.now().weekday` | String plan name |
| Plan's exercise count | `WorkoutPlanRecord.planExercises.length` | Integer |
| Plan's primary exercise type | Frequency count of `ExerciseType` values across `planExercises` | "Weighted" / "Bodyweight" / "Time-based" |
| Plan's rest period | Representative `restPeriodSec` value from plan exercises (see §10 OQ-4) | "{N}s" — seconds as integer, no decimal |
| "Has any data" check | Any entry in `workout_plans` OR `schedule_entries` OR `workout_sessions` table | Boolean gate for Empty vs Populated |

**Weekday mapping**: Dart's `DateTime.weekday` returns 1=Monday through 7=Sunday. The `schedule_entries` table keys match this scheme (per `ScheduleEntryRecord`).

**Date formatting**: No dates are displayed on SCR-06. The today's workout card does NOT show the date — only plan name and summary.

**No truncation rules needed** for this screen: plan names are short strings (user-authored); no truncation boundary is defined. If a plan name exceeds the card width, standard text overflow (ellipsis) applies.

---

## 4. Interactions & Behavior

### 4.1 Tappable / Interactive Elements

| Element | State(s) | Gesture | Behavior |
|---|---|---|---|
| Today's Workout card | Populated (scheduled) | Tap | Navigate to SCR-15 — Workout Pre-Start for the scheduled plan |
| Rest-day card | Populated (no workout) | Tap | No action (card is informational only, no tap behavior) |
| "Create your first workout plan" CTA | Empty | Tap | Navigate to SCR-09 — Create Workout Plan |
| "Retry" button | Error | Tap | Re-trigger database read → return to Loading state |
| Quick Link tile — Plans | Populated | Tap | Navigate to SCR-08 (Plans tab activates) |
| Quick Link tile — Schedule | Populated | Tap | Navigate to SCR-12 (Schedule tab activates) |
| Quick Link tile — History | Populated | Tap | Navigate to SCR-20 (History tab activates) |
| Quick Link tile — Progress | Populated | Tap | Navigate to SCR-22 (Progress tab activates) |
| Quick Link tile — Stats | Populated | Tap | Navigate to SCR-23 (Stats tab activates) |
| Bottom nav — Home | All | Tap | Scroll content to top (already on this screen) |
| Bottom nav — Plans | All (except Loading: dimmed) | Tap | Navigate to SCR-08 |
| Bottom nav — Schedule | All (except Loading: dimmed) | Tap | Navigate to SCR-12 |
| Bottom nav — History | All (except Loading: dimmed) | Tap | Navigate to SCR-20 |
| Bottom nav — Progress | All (except Loading: dimmed) | Tap | Navigate to SCR-22 |
| Bottom nav — Stats | All (except Loading: dimmed) | Tap | Navigate to SCR-23 |

**Long-press, swipe, drag**: No gesture interactions beyond tap on this screen. Pull-to-refresh is not defined (no network; Retry button handles error recovery).

### 4.2 Transitions & Animations

| Transition | Type | Duration | Notes |
|---|---|---|---|
| SCR-03 → SCR-06 (post-login) | Slide-up | ~300ms, ease-out | Conveys unlocking/opening the app |
| SCR-01 → SCR-06 (already unlocked) | Fade | ~250ms | Splash exit |
| Loading → any state | Fade out spinner, fade in content | ~200ms | Smooth reveal |
| Quick Link tap → sub-screen | Slide left (standard push) | ~300ms | Matches system nav convention |
| Tab switch → sub-screen root tab | Cross-fade or no animation | ~200ms | Matches design system tab pattern |
| Error → Loading (retry) | Fade error card, spinner appears | ~200ms | Same as initial load entrance |

**Spinner animation**: 360° CSS rotation, 0.9s linear infinite (`animation: spin 0.9s linear infinite`). Starts immediately on mount.

### 4.3 Form Validation

Not applicable. SCR-06 has no form fields or user input.

### 4.4 Feedback Mechanisms

| Mechanism | When | Notes |
|---|---|---|
| Loading spinner | While database read in flight | Replaces content area entirely during loading |
| Error card | Database read fails | Replaces content area; nav bar stays |
| Retry button | Error state | Re-triggers load, transitions back to loading |
| No toast / snackbar | — | SCR-06 does not emit toasts; navigation success is self-evident |
| No haptics | — | No haptic feedback defined in the design system for this screen |
| No confirmation dialogs | — | No destructive actions on this screen |

---

## 5. Edge Cases & Error Handling

### 5.1 Network / Server Errors

**Not applicable.** The app is fully offline. All data reads are local database reads. There is no server, no API timeout, and no connectivity state to manage on this screen.

### 5.2 Empty States

| Scenario | State shown | Notes |
|---|---|---|
| True first use — no plans, no schedule, no history | **Empty (§3.2)** | CTA navigates to Create Plan |
| User has plans/history but no schedule today | **Populated — No Workout (§3.4)** | Rest day card; Quick Links still visible |
| User had data, deleted everything | Same as first use — no data → **Empty** | System cannot distinguish "never had data" from "had and deleted all" — both show Empty |
| User has schedule but it references a deleted plan | **Populated — No Workout** (treat as no valid schedule entry) or show plan name that still exists in plans table | See §10 OQ-5 |

### 5.3 Permission-Denied Scenarios

**Not applicable.** SCR-06 does not request camera, location, notifications, or any runtime permission.

### 5.4 Boundary Conditions

| Condition | Behavior |
|---|---|
| Plan name is very long | Single-line ellipsis truncation in the today's workout card title |
| Exercise count = 0 | Should not be possible (plans require at least one exercise); if it occurs, show "0 Exercises" — do not crash |
| All exercises are the same type | Primary type chip shows that type |
| Mixed types with no majority | Pick any type; implementation choice — see §10 OQ-4 |
| Multiple plans scheduled on same day | **Not possible** — one plan per weekday is the constraint (SDS/Inventory: "maximum of one plan per weekday") |
| Database read succeeds but returns partial data | Treat as Populated with what is available — do not show Empty unless truly no data in any of the three tables |
| Database read for today's schedule succeeds but plan lookup fails | Show Populated — No Workout state (treat missing plan as no scheduled workout) |
| Content area taller than viewport | Content area is `overflow-y: auto` (scrollable) — today's card + quick links section should fit on any target phone without scrolling in the Populated states, but scroll is available if needed |
| App backgrounded and resumed | Re-read from the database on resume to ensure today's date is current (a backgrounded app spanning midnight must re-evaluate today's weekday) |

---

## 6. Responsive & Platform Considerations

### 6.1 Device Sizes

Artboard dimensions: 390 × 844px (iPhone 14 standard — the primary design target).

| Device | Handling |
|---|---|
| Small phone (≤ 375px width, e.g. iPhone SE 375×667px) | Content collapses vertically. The quick links grid (3 cols × 10px gap × 14px padding tiles) should remain intact. Total grid width at 375px with 20px side padding = 335px → 3 tiles at ~105px each — still legible. Verify chip text does not overflow. |
| Standard phone (375–430px) | Primary target — artboard dimensions |
| Large phone (> 430px, e.g. 430px Pro Max) | Tiles and cards fill additional width naturally; no max-width constraint is specified in the artboard |
| Tablet / iPad | **Out of scope** (ADR-022) |

### 6.2 Orientation

**Portrait is the primary and tested orientation.** Landscape is not supported for this POC. If the user rotates:
- The 6-tab bottom nav may become cramped horizontally
- No landscape layout is designed; this is a known POC scope limitation

### 6.3 iOS vs Android

| Concern | iOS | Android |
|---|---|---|
| Safe areas | Respect top notch/Dynamic Island (status bar 28px in artboard) and bottom home indicator (18px bottom nav padding accounts for this) | Respect punch-hole camera (status bar) and gesture navigation bar |
| Back gesture | Not applicable — SCR-06 is the root; no back destination | Android system back: no-op or soft-exit prompt (see §10 OQ-6) |
| Tab bar appearance | Native iOS tab bars are slightly different from the custom design system bar — this app uses a custom bar (not `CupertinoTabBar`), so appearance is consistent across platforms | Same custom implementation |
| Bottom navigation padding | 18px bottom padding accounts for iOS home indicator; Android may need less if using 3-button nav — implement with `MediaQuery.padding.bottom` | Same safe-area API |

### 6.4 Keyboard

No text input on this screen — keyboard is never shown.

---

## 7. Accessibility

> Full WCAG 2.1 AA certification is out of scope for this POC (ADR-028). The following are expected baseline behaviors.

### 7.1 Touch Target Sizes

| Element | Touch target | Spec |
|---|---|---|
| Today's Workout card | Full card width × min 44pt height | Card is ~130px tall — well above minimum |
| Quick Link tile | ~105 × 66px (at 390px width) | Width meets minimum; height ≥ 44pt |
| Bottom nav tab | 52px wide × full bar height (~62px) | Meets minimum |
| CTA button (Empty) | Full width of content minus 64px padding | Height is 14+14+lineheight ≈ 48px — meets minimum |
| Retry button (Error) | 11+11+13px ≈ 35px height | Below 44pt — should be increased to min 44pt. See §10 OQ-7 |

### 7.2 Color Contrast

| Pair | Hex values | Approx ratio | Status |
|---|---|---|---|
| App name on bg | `#f5f6f1` on `#131315` | ~18:1 | ✅ Passes AAA |
| "GE" lime on bg | `#c3f400` on `#131315` | ~11:1 | ✅ Passes AAA |
| Section labels (dim) on bg | `#8a8f7a` on `#131315` | ~4.0:1 | ⚠️ Passes AA for large text (11px/700 uppercase qualifies); marginal for normal text |
| Muted text on bg | `#c4c9ac` on `#131315` | ~8.4:1 | ✅ Passes AA |
| Quick link labels on card | `#f5f6f1` on `#201f22` | ~14:1 | ✅ Passes AAA |
| Cyan icons (Quick Links) | `#7df4ff` — decorative icons (non-text) | Decorative | N/A for text contrast |
| Error title on card | `#f5f6f1` on `#201f22` | ~14:1 | ✅ Passes AA |
| Retry button text on lime | `#131315` on `#c3f400` | ~14:1 | ✅ Passes AAA |
| Danger text on card | `#ff6b6b` on `#201f22` | ~5.2:1 | ✅ Passes AA |

### 7.3 Focus Order (Screen Reader / Switch Navigation)

**Loading state**: heading → spinner (announced as "Loading your dashboard…")

**Empty state**: heading → empty title → empty sub-copy → CTA button → nav tabs (Home → Plans → Schedule → History → Progress → Stats)

**Populated — Scheduled**: heading → "TODAY'S WORKOUT" section → today's card (tappable) → "QUICK LINKS" section → tile: Plans → Schedule → History → Progress → Stats → nav tabs

**Populated — No Workout**: heading → "TODAY'S WORKOUT" section → rest day card (informational, read-only) → "QUICK LINKS" → tiles → nav tabs

**Error state**: heading → error icon → error title → error sub-copy → Retry button → nav tabs

### 7.4 Semantic Labels for Screen Readers

| Element | Semantic role / label |
|---|---|
| Today's Workout card | Button — "Today's workout: {plan name}, {N} exercises, {type}" |
| Rest-day card | Static region — "No workout scheduled for today. Enjoy your rest day." |
| Quick Link tile | Button — "{Label}" (e.g. "Plans", "Schedule") |
| Bottom nav tab | Tab — "{Label}" with selected state on Home |
| CTA button | Button — "Create your first workout plan" |
| Retry button | Button — "Retry loading dashboard" |
| Loading spinner | Activity indicator — "Loading your dashboard" |

---

## 8. Component & Design System Mapping

> Source: `Doc/DESIGN-SYSTEM.md`. Cross-check with Figma frame `SCR-06/Home Dashboard` when file is linked.

### 8.1 Reused Components

| Component | Design System definition | Usage on SCR-06 |
|---|---|---|
| **Bottom navigation bar (root tabs)** | Fixed 6-tab bar — Home, Plans, Schedule, History, Progress, Stats. Used only on root-tab screens. | Primary navigation chrome on all states |
| **Card / row** | 16px radius, `color.card` fill, 1px `color.border` border | Today's Workout card (Populated state) |
| **Error / retry card** | `color.dangerBg` fill, `color.dangerBorder` border, 12–16px radius, warning icon + `color.danger` text, retry button (lime) | Error state content card |
| **Primary button** | Lime fill, dark text, 10px radius, full-width or sized | Empty state CTA, Error state Retry button |
| **Section label** | 11px/700, uppercase, `color.textDim`, letter-spacing .05–.06em | "TODAY'S WORKOUT", "QUICK LINKS" section headers |
| **Typography: Page Title** | 22px/800 | App name "FORGE" |
| **Typography: Body Regular** | 13px/600, muted | Greeting, rest-day sub, loading text, error sub-copy |
| **Typography: Body Strong** | 13–14px/700 | Today's plan name, chip values |
| **Loading (spinner variant)** | Per FR-2 / NFR-1 simplification, a spinner is used (not the skeleton-block Design System default) — this is an approved divergence from the Design System's standard loading pattern | Loading state content |

### 8.2 New / Modified Components

| Component | Notes | Rationale |
|---|---|---|
| **Today's Workout card** | Bespoke card with section label, lime "SCHEDULED" tag, 19px plan name, meta row with dot separator, and 3-chip summary row | The Design System's generic card/row component (title + sub) doesn't accommodate this specific summary layout. This card is unique to SCR-06 and SCR-15. If it appears on SCR-15 too, extract as a reusable component at that point. |
| **Rest-day card** | Same dimensions as Today's card but dashed border, centered icon + text layout | Dashed border is a visual cue that no action is scheduled. No existing component uses dashed borders — this is new. |
| **Quick Link tile** | Card-style tile with centered cyan icon + label in a 3-col grid | Smaller than a standard card; centered layout with cyan icon (not the standard card title+sub layout). New component type for SCR-06. |
| **Exercise summary chips** | Inline chips inside the Today's Workout card | These are not the filter chips from the Design System (which use pill radius and lime/muted states). These are summary-display chips with card-alt fill in a fixed layout. New component, not reused from filter chips. |
| **6-tab spinner loading variant** | Spinner with dimmed non-active nav tabs | The Design System loading pattern uses skeleton blocks. The spinner is approved per user story FR-2 simplification. |

### 8.3 Component Notes

- **Cyan (#7df4ff) on Quick Link icons**: The Design System marks cyan as reserved for time-based exercise-type indicator dots. Using it on Quick Link icons here is a deliberate design choice made in the artboard. Flag for designer confirmation — see §10 OQ-8.
- **"GE" lime in the app name**: The wordmark treatment ("FOR" + "GE" in lime) is specific to the login/home header branding. This establishes the lime as the brand accent, consistent with the Design System's primary action token.

---

## 9. Acceptance Criteria Mapping

| AC from User Story | Screen state / design section satisfying it |
|---|---|
| **AC-1** — No data → onboarding empty state prompting "Create your first workout plan" | §3.2 Empty State — dumbbell icon + "No workouts yet" + CTA button with exact copy "Create your first workout plan" (UC-SCR06-01) |
| **AC-2** — While loading → simple loading indicator | §3.1 Loading State — lime spinner centered in content area, label "Loading your dashboard…" (UC-SCR06-02) |
| **AC-3** — Has data → today's scheduled workout (if any) + quick links to Plans / Schedule / History / Progress / Stats | §3.3 Populated (scheduled) — Today's Workout card + §3.6 Quick Links grid with all 5 destinations; §3.4 Populated (no workout) — rest day card + same Quick Links (UC-SCR06-03) |
| **AC-4** — Data load failure → error state with retry + nav shell stays usable | §3.5 Error State — error card with "Couldn't load your dashboard" + Retry button; §4.1 confirms nav tabs remain tappable (UC-SCR06-04; NFR-2) |

---

## 10. Open Questions / Assumptions

### Assumptions Made

| # | Assumption | Basis |
|---|---|---|
| A-1 | "Has data" check reads all three tables (plans, schedule, history). If ANY table has content, show Populated state — not Empty. | User story: "no plans, schedule, or history exist" → Empty. Conversely, any content → Populated. |
| A-2 | Today's workout lookup uses Dart's `DateTime.now().weekday` (1=Mon, 7=Sun) matched to `ScheduleEntryRecord.weekday`. | Inventory + Drift data model; no time-zone logic is required for local-only data. |
| A-3 | The today's workout card is tappable and routes to SCR-15 (Workout Pre-Start). The card has no secondary action (e.g. no "dismiss" or "skip" button on the card itself). | User story FR-3 + Inventory — the card shows today's workout; SCR-15 is the pre-start screen. No dismiss behavior is specified. |
| A-4 | The "primary type" chip shows the most frequent `ExerciseType` among the plan's exercises. If there is a tie, show the first type in the order: weighted > bodyweight > time-based. | No spec exists for this — engineering choice documented as assumption. |
| A-5 | The "rest period" chip shows the most common `restPeriodSec` across the plan's exercises (mode). If no common value, show the first exercise's rest period. | Same rationale as A-4. |
| A-6 | Tapping a Quick Link tile navigates to the corresponding root tab exactly as if the user tapped the bottom nav tab — the destination becomes the active root screen. | The Quick Links duplicate the tab bar; routing behavior must be identical. |
| A-7 | On app resume from background spanning midnight, the screen re-reads the schedule to reflect the new day's workout (or lack thereof). No explicit "day changed" notification is needed. | Standard app lifecycle: `WidgetsBindingObserver.didChangeAppLifecycleState` → resumed → re-trigger database read. |
| A-8 | The bottom nav tabs are not interactive during the Loading state (50% opacity). This prevents navigation to a sub-feature before the home data load completes. | Loading artboard shows 0.5 opacity on non-Home tabs. |

### Open Questions

| # | Question | Impact if unresolved | Owner |
|---|---|---|---|
| **OQ-1** | The Design System defines **skeleton blocks** as the standard loading pattern; FR-2/NFR-1 specifies a **spinner** instead. Is this divergence permanently approved, or should skeleton loading be implemented when the feature is built? | Affects implementation and may affect the Design System documentation | PM / designer |
| **OQ-2** | Is there a Profile/Account access point on SCR-06 (e.g. avatar or gear icon in the header)? The user story and artboard do not show one, but SCR-25 (Profile) and SCR-26 (Logout) exist and must be reachable. The artboard does not show a profile button in the header or nav bar. | If Profile is only reachable via a path not shown on SCR-06, that path must be designed | PM / designer |
| **OQ-3** | When the user taps "Create your first workout plan" in the Empty state, does it navigate as a modal sheet (over SCR-06) or does it activate the Plans tab and push SCR-09 from there? | Navigation stack affects back-button behavior | Engineering / PM |
| **OQ-4** | The "Rest / set" chip shows a representative rest period from the plan. Which exercise's rest period should be used — the mode (most common), the first exercise's, or an average? | Minor display decision; needs a deterministic rule before implementation | Engineering |
| **OQ-5** | If a schedule entry's `planId` references a plan that has since been deleted, how should the today's workout card behave? Show the plan name from the schedule entry's cached `planName`? Show the No Workout state? | Data integrity edge case — needs a defined behavior | Engineering |
| **OQ-6** | On Android, what does the system back gesture do from SCR-06? Options: (a) do nothing, (b) prompt "Exit app?", (c) minimize the app. | Android UX convention; no behavior is defined in the user story | Engineering / PM |
| **OQ-7** | The Retry button's height (~35px including padding) is below the 44pt accessibility minimum. Should padding be increased to 13px top/bottom (giving ~39px) or the button made taller? | Accessibility baseline | Designer |
| **OQ-8** | The Quick Link tile icons use `color.cyan` (`#7df4ff`), which the Design System marks as **reserved for time-based exercise-type indicator dots only**. Is this an approved exception to the reserved-color rule, or should the icons use `color.white` or `color.lime` instead? | Affects Design System governance | Designer |
| **OQ-9** | Does the greeting "Welcome back" change based on time of day (e.g. "Good morning", "Good evening")? The artboard shows a static "Welcome back". | Minor UX decision | PM |
| **OQ-10** | Should the today's workout card show a section label "TODAY'S WORKOUT" in all populated sub-states (both scheduled and rest day)? Or should the rest-day card omit the section label? The artboard for NoWorkoutToday doesn't show a separate section label above the card — the card itself contains the message. | Layout consistency | Designer |
