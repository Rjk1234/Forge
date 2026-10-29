# Design Specification — SCR-07: Browse & Select Exercises

**Version:** 1.0  
**Date:** 2026-09-11  
**User Story:** US-SCR-07  
**Design Reference:** [ForgeApp Exercise Catalogue](https://claude.ai/code/artifact/6fd5576a-d64c-4f80-aa30-4a5b79b37c20) — 5 artboards: `Main.dc.html`, `PickerMode.dc.html`, `Empty.dc.html`, `Loading.dc.html`, `Error.dc.html`  
**Figma File:** `fileKey=0oxHvmnCM27XHqmEZjojtb` (cross-reference; canvas artboards are the primary design source for this spec)

---

## §1 — Overview & Goal

### Problem Being Solved

Users need to browse a fixed, developer-seeded exercise catalogue both for discovery and for building workout plans. Without a catalogue screen, there is no way to find available exercises, understand their types, or add them to plans during plan editing.

### User

A user with the app unlocked, operating in one of two contexts:

- **Browse mode:** Exploring the catalogue out of curiosity or to plan future workouts (entry from SCR-06 Home Dashboard or the Plans section).
- **Picker mode:** Actively building or editing a workout plan on SCR-09 and needing to add one or more exercises.

### Primary Success Metric

- The user can find an exercise by name (search) or category (filter chip) within two interactions from entering the screen.
- In picker mode, the exercise is added to the in-progress plan immediately on tap with no additional confirmation step required (AC-4).

### Constraints

- The catalogue is **read-only developer-seeded Drift data** — no network call, no user-created exercises, no edit or delete.
- This is a **secondary screen** (not a root tab) — no bottom navigation bar is present.
- The screen supports two distinct **modes** (browse vs. picker) that share the same layout chrome but differ in the trailing affordance on each exercise row and in the presence of a picker-context banner.

---

## §2 — User Flow

### 2.1 Entry Points

| Entry | Mode | How |
|---|---|---|
| SCR-06 Home Dashboard → Quick Links → Plans tile | Browse | User taps the "Plans" quick-link tile; navigates to SCR-08 and then opens the catalogue from there. Alternatively, if a direct "Browse Exercises" shortcut exists on SCR-06. |
| SCR-09 Create/Edit Workout Plan → "Add exercise" action | **Picker** | User taps the add-exercise affordance inside SCR-09; SCR-07 is pushed with picker mode active and the destination plan name injected into the picker banner. |

> **OQ-1 (Open Question):** The user story and inventory both list SCR-06 as a browse-mode entry point, but the SCR-06 design canvas (artboards) shows no explicit "Browse Exercises" tile — the Quick Links grid only shows Plans, Schedule, History, Progress, and Stats. Confirm whether SCR-07 is reachable from the Plans tab (SCR-08) or if there is another path from SCR-06.

### 2.2 Full State Branching

```
User enters SCR-07
         │
         ├─► [Catalogue loading from the database]
         │          │
         │          ├─► Loading state (skeleton)    UC-SCR07-01
         │          │
         │          ├─► Load failure
         │          │        └─► Error state + Retry button    UC-SCR07-06
         │          │                   │
         │          │                   └─► User taps Retry → Loading state (loop)
         │          │
         │          └─► Load success
         │                   │
         │                   └─► Populated state (default: "All" chip active)    UC-SCR07-02
         │                              │
         │                              ├─► User types in search field
         │                              │          │
         │                              │          ├─► Results found → filtered list
         │                              │          └─► No results → Empty state    UC-SCR07-03
         │                              │
         │                              ├─► User taps filter chip
         │                              │          │
         │                              │          ├─► Exercises of that type exist → filtered list
         │                              │          └─► No exercises of that type → Empty state
         │                              │
         │                              ├─► BROWSE MODE: user taps exercise row
         │                              │          └─► [OQ-2: behaviour undefined — see §10]
         │                              │
         │                              └─► PICKER MODE: user taps "+" on exercise row
         │                                         │
         │                                         ├─► Exercise ID validated against catalogue
         │                                         │          │
         │                                         │          ├─► Valid → exercise added to in-progress plan
         │                                         │          │          └─► Navigate back to SCR-09    UC-SCR07-04
         │                                         │          │
         │                                         │          └─► Invalid reference → selection rejected    UC-SCR07-05
         │                                         │                     (defensive; not a normal user path)
         │                                         │
         │                                         └─► User taps Back (no exercise selected)
         │                                                    └─► Navigate back to SCR-09
         │
         └─► User taps Back (any state)
                    └─► Navigate back to caller (SCR-09 in picker mode, previous screen in browse mode)
```

### 2.3 Exit Points

| Exit | Condition |
|---|---|
| Back to SCR-09 | Picker mode — exercise successfully added OR user backs out without selecting |
| Back to previous screen | Browse mode — user taps back icon |
| Retry loop | Error state — user taps Retry, loops to Loading |

---

## §3 — Screen-by-Screen Breakdown

All artboards share a 390 × 844 px phone frame. Design tokens used throughout:

| Token | Value |
|---|---|
| `color.bg` | `#131315` |
| `color.card` | `#201f22` |
| `color.cardAlt` | `#2a2a2c` |
| `color.border` | `#444933` |
| `color.lime` | `#c3f400` |
| `color.muted` | `#c4c9ac` |
| `color.white` | `#f5f6f1` |
| `color.dim` | `#8a8f7a` |
| `color.cyan` | `#7df4ff` |
| `color.danger` | `#ff6b6b` |
| `color.dangerBorder` | `#5c3a3a` |

---

### 3.1 Shared Chrome (All States)

**Present in all five states unless otherwise noted.**

| Element | Spec |
|---|---|
| Background | `color.bg` (#131315) |
| Status bar | 28 px height, system-rendered |
| App bar | `flex-row`, `align-items: center`, `gap: 14px`, `padding: 6px 20px 14px` |
| Back icon | Chevron-left, 20 × 20 px, `color.white` (#f5f6f1); `stroke-width: 2` |
| Screen title | "Exercise Catalogue", 17 px / 800, `letter-spacing: 0.02em`, `color.white` |
| Bottom nav | **Absent** — SCR-07 is a secondary screen, not a root tab |

---

### 3.2 State A — Loading (Skeleton)

**Artboard:** `Loading.dc.html`  
**Trigger:** UC-SCR07-01 — catalogue data has not yet resolved from the database.

#### Layout

```
Status bar (28px)
App bar: [← back] Exercise Catalogue
Search bar (placeholder visible, not interactive)
Filter chips area (4 skeleton pills)
─────────────────
Skeleton exercise list (6 items)
```

#### Search Bar (Loading)

Same chrome as Populated state. Search field is non-interactive during loading (no focus, no keyboard).

#### Filter Chips — Skeleton

Four pills: `56 × 26 px`, `border-radius: 20px`, `background: color.card` (#201f22). No text, no active chip — the chips are skeletal placeholders.

#### Exercise Rows — Skeleton

Six skeleton items stacked with `gap: 10px`, `padding: 0 20px 20px`:

| Element | Spec |
|---|---|
| Row container | `color.card` bg, `1px solid color.border`, `border-radius: 14px`, `padding: 14px 16px` |
| Title line | 60% width, 15 px height, `border-radius: 6px`, shimmer gradient |
| Sub line | 35% width, 11 px height, `border-radius: 6px`, shimmer gradient |
| Shimmer | `linear-gradient(90deg, #2a2a2c 25%, #35342f 37%, #2a2a2c 63%)`, `background-size: 400% 100%`, `animation: 1.4s ease infinite` |

---

### 3.3 State B — Populated, Browse Mode

**Artboard:** `Main.dc.html`  
**Trigger:** UC-SCR07-02 — catalogue loaded; entered from SCR-06 or SCR-08 (not from SCR-09).

#### Layout

```
Status bar (28px)
App bar: [← back] Exercise Catalogue
Search bar
Filter chips: [All ✓] [Weighted] [Time-based] [Bodyweight]
─────────────────
Scrollable exercise list
  ┌──────────────────────────────────┐
  │ Exercise Name          15px/700  │
  │ ● Type label           11px/600  │     ›
  └──────────────────────────────────┘
  ...
```

#### Search Bar

| Element | Spec |
|---|---|
| Container | `color.card` fill, `1px solid color.border`, `border-radius: 12px`, `padding: 11px 14px` |
| Search icon | Magnifier SVG, 18 × 18 px, `color.dim` (#8a8f7a) |
| Placeholder | "Search exercises", 14 px, `color.dim` |

#### Filter Chips

| State | Background | Text color | Border |
|---|---|---|---|
| Inactive | `color.card` (#201f22) | `color.muted` (#c4c9ac) | `color.border` (#444933) |
| Active | `color.lime` (#c3f400) | `color.bg` (#131315) | `color.lime` (#c3f400) |

Spec: `font-size: 12px`, `font-weight: 700`, `padding: 7px 14px`, `border-radius: 20px`, `flex: 0 0 auto` (no shrink). Default active chip: **"All"**.

Four chips in order: "All" · "Weighted" · "Time-based" · "Bodyweight"

#### Exercise Row (Browse Mode)

| Element | Spec |
|---|---|
| Container | `color.card` fill, `1px solid color.border`, `border-radius: 14px`, `padding: 14px 16px` |
| Layout | `flex-row`, `align-items: center`, `justify-content: space-between`, `gap: 12px` |
| Exercise name | 15 px / 700, `color.white` (#f5f6f1) |
| Type row | `flex-row`, `align-items: center`, `gap: 6px`, 11 px / 600, `color.muted` (#c4c9ac) |
| Type dot | 7 × 7 px circle |
| · Weighted dot | `color.cyan` (#7df4ff) |
| · Time-based dot | `color.lime` (#c3f400) |
| · Bodyweight dot | `color.muted` (#c4c9ac) |
| Trailing icon (browse) | Chevron-right, 16 × 16 px, `color.dim` (#8a8f7a) |

Type labels (from Decisions Log §5): "Weighted" · "Time-based" · "Bodyweight"

**Sample exercises shown in artboard** (illustrative; actual seed data governs):  
Barbell Bench Press (Weighted) · Push-Up (Bodyweight) · Plank (Time-based) · Barbell Squat (Weighted) · Pull-Up (Bodyweight) · Mountain Climbers (Time-based) · Deadlift (Weighted) · Lunges (Bodyweight)

#### List Layout

`padding: 0 20px 20px`, `gap: 10px`, `overflow-y: auto`, `flex: 1 1 auto`

---

### 3.4 State C — Populated, Picker Mode

**Artboard:** `PickerMode.dc.html`  
**Trigger:** UC-SCR07-04 precondition — SCR-09 pushes SCR-07 with picker mode active and the in-progress plan name as a parameter.

**Difference from Browse Mode:** One additional element (picker banner) and a different trailing affordance per row.

#### Picker Banner

Sits between the app bar and the search bar.

| Element | Spec |
|---|---|
| Container | `margin: 0 20px 14px`, `color.cardAlt` (#2a2a2c) fill, `1px solid color.border` (#444933), `border-radius: 12px`, `padding: 10px 14px` |
| Layout | `flex-row`, `align-items: center`, `gap: 10px` |
| Icon | Lines/list SVG, 16 × 16 px, `color.cyan` (#7df4ff) |
| Copy | "Adding an exercise to **[Plan Name]**" |
| Copy style | 12 px, `color.muted`; plan name is bold (`font-weight: 700`) `color.white` |

#### Exercise Row (Picker Mode)

Same as Browse Mode except:

| Element | Spec |
|---|---|
| Trailing affordance | Circular "+" add button instead of chevron |
| Add button | 28 × 28 px circle, `color.lime` (#c3f400) fill, `color.bg` (#131315) icon |
| Plus icon | 16 × 16 px, `stroke-width: 2.4` |

On tap: exercise is immediately added to the in-progress plan (no confirmation dialog). Screen navigates back to SCR-09.

---

### 3.5 State D — No Search Results (Empty)

**Artboard:** `Empty.dc.html`  
**Trigger:** UC-SCR07-03 — user's search query or active filter chip returns zero matching exercises.

#### Search Bar (Active Query State)

| Element | Spec |
|---|---|
| Container border | `1px solid color.lime` (#c3f400) — replaces default `color.border` |
| Search icon | `color.lime` (#c3f400) — replaces default `color.dim` |
| Query text | User-typed text, 14 px, `color.white` (#f5f6f1) — replaces placeholder |

Filter chips row remains visible and interactive (unchanged spec).

#### Empty State Content Area

`flex: 1 1 auto`, `display: flex`, `flex-direction: column`, `align-items: center`, `justify-content: center`, `padding: 0 32px 80px`, `gap: 14px`, `text-align: center`

| Element | Spec |
|---|---|
| Icon | Magnifier-with-minus SVG, 52 × 52 px, `color.dim` (#8a8f7a), `stroke-width: 1.4` |
| Title | "No exercises match your search", 16 px / 800, `color.white` |
| Subtitle | "Try a different name or clear the filter.", 13 px, `color.muted` (#c4c9ac) |

No CTA button — the user resolves the state by modifying the search text or tapping a different filter chip.

---

### 3.6 State E — Error (Catalogue Load Failure)

**Artboard:** `Error.dc.html`  
**Trigger:** UC-SCR07-06 — database read fails when attempting to load the exercise catalogue.

The search bar and filter chip row are **absent** in this state (no data to search or filter).

#### Error Content Area

`flex: 1 1 auto`, centered column, `padding: 0 32px`, `gap: 14px`

#### Error Card

| Element | Spec |
|---|---|
| Container | 100% width, `color.card` (#201f22) fill, `1px solid #5c3a3a` (danger border), `border-radius: 16px`, `padding: 26px 20px` |
| Layout | `flex-direction: column`, `align-items: center`, `gap: 12px` |
| Warning icon | Triangle-exclamation SVG, 40 × 40 px, `color.danger` (#ff6b6b), `stroke-width: 1.6` |
| Title | "Couldn't load the exercise catalogue", 16 px / 800, `color.white` |
| Body | "Something went wrong reading local data.\nYour plans and history are unaffected.", 13 px, `color.muted`, `line-height: 1.5` |
| Retry button | `color.lime` (#c3f400) fill, `color.bg` (#131315) text, 13 px / 800, `border-radius: 10px`, `padding: 11px 22px` |

---

## §4 — Interactions & Behavior

### 4.1 Tappable Elements

| # | Element | Mode | Action |
|---|---|---|---|
| 1 | Back icon | Both | Pop screen. In picker mode → back to SCR-09 (no exercise added). In browse mode → back to caller. |
| 2 | Search field | Both | Focus field → system keyboard appears from bottom. Live-filters list as user types. |
| 3 | "All" filter chip | Both | Tap → show all exercises. Deactivates other active chip. |
| 4 | "Weighted" filter chip | Both | Tap → filter list to weighted exercises only. Activates chip, deactivates previous. |
| 5 | "Time-based" filter chip | Both | Tap → filter list to time-based exercises only. |
| 6 | "Bodyweight" filter chip | Both | Tap → filter list to bodyweight exercises only. |
| 7 | Exercise row (browse mode) | Browse | Tap → **[OQ-2: undefined — see §10]** |
| 8 | "+" add button (picker mode) | Picker | Tap → validates exercise ID, adds to plan, navigates back to SCR-09. |
| 9 | Retry button | Both (error) | Tap → re-triggers catalogue load, returns to Loading state. |
| 10 | Filter chip + empty result | Both | Produces Empty state (§3.5). |

**Total confirmed interactive elements: 9 (+ 1 per exercise row in the list)**

### 4.2 Search Behavior

- **Matching:** Case-insensitive substring match on exercise name.
- **Scope:** Applies to the currently selected type filter — searching while "Weighted" is active searches only within weighted exercises.
- **Live filtering:** Results update on every keystroke (no debounce threshold specified — use standard 300 ms debounce as a reasonable default; see OQ-3).
- **Clear:** Clearing the search text field restores the full list for the active filter.

### 4.3 Filter Chip Behavior

- Only one chip is active at a time; tapping a chip deactivates the previously active one.
- Default active chip on screen entry: **"All"**.
- If search text is present when a chip is tapped, the filter applies on top of the existing search query.

### 4.4 Picker Mode — Add Exercise

1. User taps "+" button on an exercise row.
2. System validates the exercise `exerciseId` exists in the Drift `exercises` table.
3. On success: exercise is appended to the current plan's exercise list in-memory (not yet persisted — persisted when user saves the plan on SCR-09).
4. Screen immediately pops back to SCR-09. SCR-09 shows the newly added exercise in the plan's exercise list.
5. On failure (UC-SCR07-05, defensive): selection is silently rejected. The exercise is not added. **OQ-4: confirm whether a snackbar/toast should appear for rejected selections.**

### 4.5 Transitions & Animations

| Transition | Spec |
|---|---|
| Browse mode enter (from SCR-06 / SCR-08) | Standard slide-in from right, ~300 ms |
| Picker mode enter (from SCR-09) | Standard slide-in from right (same screen, different mode), ~300 ms |
| Back / exit (either mode) | Slide-out to right (reverse of entry), ~300 ms |
| Loading → Populated | Skeleton rows cross-fade to real rows; filter chips become interactive simultaneously; ~200 ms fade |
| Loading → Error | Skeleton fades out, error card fades in; ~200 ms |
| Search input: list updates | Immediate on debounce (no transition animation needed) |
| Filter chip tap | Active chip: background/text/border color transitions in ~100 ms |

### 4.6 Keyboard Handling

- Tapping the search field raises the system keyboard.
- The exercise list area shrinks to the remaining viewport above the keyboard (`resizeToAvoidBottomInset` or equivalent).
- Filter chips row remains visible above the list and below the search field regardless of keyboard state.
- Tapping outside the search field (on a chip or a list row) dismisses the keyboard.

### 4.7 Feedback Mechanisms

- **Adding an exercise (picker mode):** No confirmation dialog — immediate add and pop. SCR-09 is responsible for showing the updated exercise list as feedback.
- **No snackbar on success** is specified in the user story. Confirm with PM (OQ-4).
- **Retry button in error state:** No loading spinner inside the button — the screen transitions to the full Loading (skeleton) state.

---

## §5 — Edge Cases & Error Handling

### 5.1 Catalogue Load Failure (EC-2 / UC-SCR07-06)

**Trigger:** Drift `exercises` table read throws an exception during catalogue load.

**Behaviour:**
- Screen transitions from Loading to Error state (State E).
- Error card with exact copy: "Couldn't load the exercise catalogue" / "Something went wrong reading local data.\nYour plans and history are unaffected."
- Retry button retriggers catalogue load → returns to Loading state.
- App bar (title + back icon) remains visible so user can exit.
- In picker mode: back icon still navigates to SCR-09 even in error state.

### 5.2 No Search Results (UC-SCR07-03)

**Trigger:** Search query or filter chip yields zero matching exercises.

**Behaviour:** State D (Empty). Search field shows lime border and icon. Filter chips stay interactive — user can clear the filter to get results back.

**Microcopy:**
- Title: "No exercises match your search" (verbatim from user story and artboard)
- Subtitle: "Try a different name or clear the filter."

**Note:** This is a "no results" empty state, not a "first-time-use" empty state. The catalogue is never truly empty (it is developer-seeded; EC-3 below covers the edge case where it might be).

### 5.3 Catalogue Has Zero Exercises (Edge)

The exercise catalogue is developer-seeded; it should never be empty after app launch. However, if `exercises` returns 0 records (e.g., seed did not run):

**Proposed behaviour (OQ-5: confirm with engineering):** Treat it identically to State D (No Search Results) with no active search term. The empty state message ("No exercises match your search") is misleading in this case — confirm whether a distinct "Catalogue is empty" message is needed.

### 5.4 Invalid Exercise Reference (EC-1 / UC-SCR07-05)

**Trigger:** In picker mode, the exercise the user attempts to add has an `exerciseId` that is not present in the Drift `exercises` table. This is a defensive scenario — it would only occur due to a stale in-memory state or a data-integrity bug.

**Behaviour:** Selection is silently rejected; the exercise is not added to the plan. No navigation occurs. **OQ-4: whether a toast or snackbar is shown for this case.**

### 5.5 Picker Mode — Adding a Duplicate Exercise

**Trigger:** User taps "+" on an exercise already in the in-progress plan.

**Behaviour: undefined in user story (OQ-6).** Proposed default: allow the duplicate (exercise can appear twice with different targets); confirm with PM.

### 5.6 Large Search Input

No max character limit is specified for the search field. If the input is very long, the text scrolls horizontally within the single-line field. The field does not wrap.

### 5.7 Very Long Exercise Name

Exercise names are seeded by the developer — no known max length. If a name exceeds one line, it should truncate with an ellipsis (`overflow: ellipsis`) to preserve the 2-line row height. **OQ-7: confirm max line count for exercise names in the design system (1 line vs. 2 lines).**

### 5.8 Rapid Filter Chip Taps

If the user taps chips in rapid succession, only the last chip's filter applies. No debounce needed — filter is synchronous in-memory.

### 5.9 Picker Mode — Back Without Selecting

If the user opens picker mode, searches, and then taps back without tapping any "+" button, they return to SCR-09 with the plan unchanged. No confirmation dialog is needed (no destructive action occurred).

---

## §6 — Responsive & Platform Considerations

### 6.1 Device Sizes

| Device band | Behaviour |
|---|---|
| Small phone (≤375 pt wide, e.g. iPhone SE) | Filter chips row scrolls horizontally (`overflow-x: auto`) — all 4 chips remain accessible. Exercise rows are narrower; name and type label may wrap if very long — see OQ-7. |
| Standard phone (390 pt, design baseline) | Matches artboard exactly. |
| Large phone (≥428 pt, e.g. iPhone Pro Max) | List rows wider; chips have more horizontal space. No layout changes needed — flex-based layout adapts. |
| Tablet | Not in scope for ForgeApp v1.0; phone-only. |

### 6.2 iOS vs. Android

| Concern | iOS | Android |
|---|---|---|
| Back navigation | App bar back icon (as designed). No swipe-back conflicts — list scroll is vertical, not horizontal. | System back gesture / back button pops the screen. Same effect as tapping the app bar back icon. |
| Keyboard behaviour | Keyboard raises from bottom; `resizeToAvoidBottomInset` shrinks list area. | Identical behaviour. |
| Status bar | System-rendered, 28 px safe area. | System-rendered; safe area height varies. Use `SafeArea` widget. |
| Haptics | Not specified (no confirm/add dialog). | N/A. |

### 6.3 Orientation

The screen is **portrait-only** for ForgeApp v1.0. No landscape-specific layout is required.

---

## §7 — Accessibility

### 7.1 Touch Targets

| Element | Artboard size | Meets 44 pt minimum? |
|---|---|---|
| Back icon (app bar) | 20 × 20 px drawn; tap zone must be padded to 44 × 44 pt | ⚠️ Drawn icon is small — extend tap area with padding |
| Search field | Full row, ~350 pt wide × 44 pt height (11+14+11+8 container) | ✅ |
| Filter chips | 7+14+7 = 28 pt height — **below 44 pt** | ⚠️ **OQ-8: padding needed** |
| Exercise row (browse) | 14+15+6+11+14 = ~60 pt total | ✅ |
| "+" add button (picker) | 28 × 28 px drawn — **below 44 pt** | ⚠️ Extend tap area with invisible padding to 44 × 44 pt |
| Retry button | 11+line+11 = ~35 pt height — **below 44 pt** | ⚠️ Increase vertical padding to meet 44 pt |

### 7.2 Color Contrast

| Pair | Ratio | WCAG |
|---|---|---|
| Exercise name (#f5f6f1) on card bg (#201f22) | ≈ 14:1 | ✅ AAA |
| Type label (#c4c9ac) on card bg (#201f22) | ≈ 5.8:1 | ✅ AA |
| Active chip text (#131315) on lime (#c3f400) | ≈ 14:1 | ✅ AAA |
| Inactive chip text (#c4c9ac) on card bg (#201f22) | ≈ 5.8:1 | ✅ AA |
| Placeholder text (#8a8f7a) on card bg (#201f22) | ≈ 3.1:1 | ⚠️ Below AA for normal text — acceptable at POC scope; flag for future |
| Error title (#f5f6f1) on card bg (#201f22) | ≈ 14:1 | ✅ AAA |
| Retry btn text (#131315) on lime (#c3f400) | ≈ 14:1 | ✅ AAA |

### 7.3 Focus Order (Keyboard / Switch Navigation)

Per screen state:

**Populated / Empty states:**
1. Back icon
2. Search field
3. Filter chips (left to right: All → Weighted → Time-based → Bodyweight)
4. Exercise rows (top to bottom in visible list)
   - Browse mode: each row focusable, activates on select
   - Picker mode: "+" button on each row is the focusable target

**Error state:**
1. Back icon
2. Retry button

**Loading state:** No interactive elements (skeleton is not focusable).

### 7.4 Screen Reader Labels

| Element | Semantic label |
|---|---|
| Back icon | "Back" (or "Close" in picker mode — OQ-9) |
| Search field | "Search exercises" (matches placeholder) |
| "All" chip | "Filter: All" (or "Filter: All, selected" when active) |
| "Weighted" chip | "Filter: Weighted" |
| "Time-based" chip | "Filter: Time-based" |
| "Bodyweight" chip | "Filter: Bodyweight" |
| Exercise row (browse) | "[Exercise Name], [Type]" |
| "+" add button (picker) | "Add [Exercise Name] to plan" |
| Error retry button | "Retry loading exercise catalogue" |
| Picker banner | "Adding an exercise to [Plan Name]" (read once on entry) |

### 7.5 Shimmer Accessibility

Skeleton loading animation should be non-animated for users who have enabled "Reduce Motion" (`prefers-reduced-motion`). Replace the shimmer with a static, muted placeholder background instead.

---

## §8 — Component & Design System Mapping

### 8.1 Reused Design System Components

| Component | Usage in SCR-07 | Token refs |
|---|---|---|
| **App bar / back-navigation bar** | Screen title "Exercise Catalogue" + back icon | `color.white`, 17 px/800, `color.bg` bg |
| **Search field** | Search exercises; lime border in active/query state | `color.card`, `color.border`, `color.dim` (placeholder), `color.lime` (active border/icon) |
| **Filter chip** | "All / Weighted / Time-based / Bodyweight" — same spec as other filter chips in the DS | 12 px/700, `color.card` / `color.lime`, `color.border` / `color.lime`, 20 px radius |
| **Exercise row card** | List item — name + type dot + trailing affordance | `color.card`, `color.border`, 14 px radius |
| **Skeleton row** | Loading state | `color.card`, shimmer gradient (`#2a2a2c` / `#35342f`), 1.4 s animation |
| **Error card** | Catalogue load failure | `color.card`, `color.dangerBorder` (#5c3a3a), 16 px radius |
| **Primary button (lime)** | Retry button | `color.lime` fill, `color.bg` text, 10 px radius |
| **Empty state illustration area** | No-search-results view | Centred column, 52 px icon, 16/13 px text |

### 8.2 New / Modified Components

| Component | Why new | Notes |
|---|---|---|
| **Picker mode banner** | Not present in any other current screen; unique to SCR-07 picker mode | `color.cardAlt` fill, `color.cyan` icon, 12 px muted text + bold white plan name, 12 px radius. Should be extracted as a reusable `ContextBanner` if picker mode appears elsewhere. |
| **Exercise type dot** | Specific 3-variant colour-coding (cyan / lime / muted) per Decisions Log §5 | Weighted = `color.cyan` · Time-based = `color.lime` · Bodyweight = `color.muted`. A 7 × 7 px filled circle; may be used on other exercise-related screens (SCR-09, SCR-16, etc.). |
| **Circular "+" add button (picker mode)** | Browse mode uses a standard chevron; picker mode needs an add affordance | 28 × 28 px lime circle with `+` icon. Different from the standard primary button. Reusable for any inline "add to list" action. |
| **Skeleton filter chip** | Filter chip skeleton not previously defined | 56 × 26 px, 20 px radius, `color.card` fill. Part of the loading skeleton pattern. |

---

## §9 — Acceptance Criteria Mapping

| AC | Criterion | Screen state / interaction that satisfies it |
|---|---|---|
| **AC-1** — Skeleton list shown while loading | §3.2 (Loading state) — 6 skeleton rows with shimmer animation, 4 skeleton filter chips. Search bar is visible but non-interactive. | UC-SCR07-01 |
| **AC-2** — Populated list, searchable | §3.3 (Browse mode) — exercise rows with name, type dot, type label; search field live-filters; filter chips narrow by type. | UC-SCR07-02 |
| **AC-3** — "No exercises match your search" shown when filter/search returns zero results | §3.5 (Empty state) — exact microcopy "No exercises match your search" + subtitle "Try a different name or clear the filter." Lime border on search field signals active query. | UC-SCR07-03 |
| **AC-4** — Exercise selected in picker mode is added to in-progress plan | §3.4 (Picker mode) — "+" add button appends exercise to plan; screen pops to SCR-09. §4.4 describes add flow including ID validation. | UC-SCR07-04 |

**Edge case coverage (not in ACs but in user story §9):**

| EC | Coverage |
|---|---|
| **EC-1** Invalid exercise reference (UC-SCR07-05) | §4.4 — ID validated before add; rejected silently if not in catalogue. §5.4 documents behaviour. |
| **EC-2** Catalogue load failure (UC-SCR07-06) | §3.6 (Error state) — full error card with exact copy; Retry loops to Loading. |

---

## §10 — Open Questions / Assumptions

| # | Question | Owner | Impact | Proposed default |
|---|---|---|---|---|
| **OQ-1** | How does a user reach SCR-07 in browse mode from SCR-06? The SCR-06 artboard shows no "Browse Exercises" tile; only Plans / Schedule / History / Progress / Stats are shown in Quick Links. Is browse mode only reachable from SCR-08 (Plans list)? | PM / Designer | **Navigation gap** — blocks browse-mode entry point definition | Assume browse entry is via SCR-08 (Plans) → "Browse exercises" action until confirmed |
| **OQ-2** | In browse mode, what happens when a user taps an exercise row (chevron-right affordance)? No detail screen (e.g. SCR-07b) is defined in the inventory. Is the chevron purely decorative, or does it navigate somewhere? | PM | Blocks browse-mode row tap behaviour | Assume no navigation in browse mode for now; row is read-only; chevron may be decorative (OQ-2 must be resolved before implementation) |
| **OQ-3** | What debounce delay should be used for live search filtering? | Engineering | Minor — UX polish | Use 300 ms as standard default |
| **OQ-4** | Should a snackbar / toast appear (a) when an exercise is successfully added in picker mode, or (b) when a selection is rejected (UC-SCR07-05)? | PM / Designer | Affects feedback model | (a) No toast — SCR-09's updated list provides feedback; (b) silent rejection or brief snackbar "Exercise not found" — confirm |
| **OQ-5** | What should the screen show if the exercise catalogue table is empty (e.g., seed didn't run)? The current Empty-state copy ("No exercises match your search") is misleading with no search term active. | Engineering / PM | Minimal — edge case at POC scope | Use existing Empty state as-is; add a distinct "No exercises in catalogue" message if seed reliability is a concern |
| **OQ-6** | Should the "+" button in picker mode allow adding a duplicate exercise (one already in the in-progress plan)? | PM | Affects plan editing model | Allow duplicates — user may want the same exercise twice with different targets |
| **OQ-7** | What is the max number of text lines for exercise names in a row? If a name exceeds one line, should it wrap or truncate? | Designer | Layout integrity | Truncate at 1 line with ellipsis |
| **OQ-8** | Filter chips have a drawn height of ~28 pt, below the 44 pt minimum touch target. Should the implementation pad the tap area or increase chip padding? | Designer / Engineering | Accessibility compliance | Increase vertical padding to achieve 44 pt tap height while keeping visual size unchanged via an invisible tap zone |
| **OQ-9** | Should the back icon's accessibility label be "Back" (browse mode) or "Cancel" / "Close" (picker mode) to reflect the dismissal intent? | Designer / PM | Accessibility — VoiceOver users | Use "Back" for consistency; "Close" if the picker is presented modally |
| **OQ-10** | Is picker mode pushed as a standard screen (slide-in) or presented as a modal sheet (slide-up)? The user story and artboard both show a standard app bar with back icon, suggesting a push. | Engineering | Navigation stack and back gesture behaviour | Assume standard push navigation (slide-in) matching artboard |
