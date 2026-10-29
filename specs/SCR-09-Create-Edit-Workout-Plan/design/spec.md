# Design Specification: Create / Edit Workout Plan (SCR-09)

**User Story:** US-SCR09  
**Feature:** Workout Plan Management  
**Priority:** High | Story Points: 8  
**Design Reference:** [Claude Design Canvas — ForgeApp Create Edit Plan](https://claude.ai/code/artifact/e721de73-e7db-431b-99f7-ea8df4e2216b) (6 artboards: Main.dc.html, CreateMode.dc.html, ValidationErrors.dc.html, SavingLoading.dc.html, SaveFailure.dc.html, DiscardConfirm.dc.html)  
**Created:** 2026-09-11  
**Status:** Draft — pending OQ resolution before build

---

## §1 — Overview & Goal

### Problem Being Solved

A user who wants to train needs a way to define exactly what they will do: name the plan, pick their exercises from the catalogue, and set per-exercise targets appropriate to each exercise's type (sets + reps + weight for barbell lifts; sets + duration for held or timed movements; sets + reps for bodyweight movements). Without this screen, plans in `workout_plans` can never be created or updated.

### User Goal

"Let me build or update a workout plan by naming it, picking exercises, and dialling in the sets, reps, weight, or duration for each one — then save it so I can use it in a session."

### Dual-Mode Operation

SCR-09 operates in two named modes that share a single screen design:

| Mode | App bar title | Name field state | Exercise list | Save button |
|---|---|---|---|---|
| **Create** | "New Workout Plan" | Empty — placeholder "e.g., Push Day" | Empty (no exercises yet) | Disabled (dim) |
| **Edit** | "Edit Workout Plan" | Pre-filled with existing name | Pre-filled with exercises and targets | Active (lime) when valid |

### Business Context

SCR-09 is a secondary screen (no bottom nav). It is reached from SCR-08 (Plans List) or SCR-10 (Plan Detail). On successful save it routes to SCR-10 with the updated plan data. The app is fully offline; "save" means a database write — there is no network call.

### Success Metrics

| Metric | Target |
|---|---|
| Reaching a valid saveable state from a blank create form | Able to name + add ≥1 exercise + fill targets → "Save Plan" turns lime |
| Inline validation feedback | Appears at the moment save is attempted, not on every keystroke |
| Save latency (database write) | Spinner visible; user not left on a frozen screen |
| Unsaved-changes protection | Back/swipe triggers discard confirmation without data loss |

---

## §2 — User Flow

### Entry Points

| Entry | Trigger | Pre-condition | Mode |
|---|---|---|---|
| SCR-08 "+" FAB or "Create a workout plan" CTA | Tap | App unlocked | **Create** — blank form |
| SCR-08 plan card row | Tap (if SCR-08 is also the route to edit — see OQ-1) | App unlocked, plan exists | **Edit** — pre-filled |
| SCR-10 Plan Detail edit action | Tap edit button/action | App unlocked, plan loaded | **Edit** — pre-filled |

### State Machine

```
Entry (Create mode)                Entry (Edit mode)
         │                                  │
         ▼                                  ▼
[Create Mode — Blank form]       [Edit Mode — Pre-filled form]
         │                                  │
         │ ◄──────────────────────────────────┤
         │                                  │
         ▼                                  ▼
[Form in progress] ─── user taps back / swipe ──► [Unsaved changes?]
         │                                              │
         │                              no unsaved ─────┤──► SCR-08
         │                                              │
         │                              yes unsaved ────┤──► [Discard confirmation dialog]
         │                                              │        │
         │                                  ┌── Keep Editing ────┤
         │                                  │                    │
         │                                  │         Discard ───┤──► SCR-08
         │                                  │
         ▼
[User taps Save Plan]
         │
         ├─── Validation fails ───► [Inline validation errors shown on form]
         │                          Save button stays dim; user corrects errors
         │
         ├─── Validation passes ──► [Saving state — spinner, form locked, opacity 0.45]
                                            │
                                            ├─── database write succeeds ──► SCR-10 (Plan Detail)
                                            │
                                            └─── database write fails ──────► [Save Failure banner]
                                                                               │
                                                                      Retry Save ──► [Saving state again]
```

### Exit Points

| Action | Destination |
|---|---|
| Save succeeds | SCR-10 — Plan Detail (with planId of the saved plan) |
| User taps Discard in confirmation dialog | SCR-08 — Workout Plans List |
| User taps "Add Exercise" | SCR-07 — Exercise Catalogue (Picker mode) |

### Use Cases Covered

| UC | Description |
|---|---|
| UC-SCR09-01 | Create mode — blank form displayed |
| UC-SCR09-02 | Edit mode — pre-filled form displayed |
| UC-SCR09-03 | Blank/whitespace plan name blocked |
| UC-SCR09-04 | Invalid exercise reference blocked |
| UC-SCR09-05 | Non-positive sets/reps blocked |
| UC-SCR09-06 | Non-positive weight blocked (weighted only) |
| UC-SCR09-07 | Non-positive duration blocked (time-based only) |
| UC-SCR09-08 | Save loading state |
| UC-SCR09-09 | Save success → SCR-10 |
| UC-SCR09-10 | Save failure — error state with retry |
| UC-SCR09-11 | Local write failure — in-memory edits preserved |
| UC-SCR09-12 | Unsaved-changes guard — discard confirmation |

---

## §3 — Screen-by-Screen Breakdown

All measurements taken from 390 × 844 pt reference frame. SCR-09 is a **secondary screen** — no bottom navigation bar on any state.

---

### 3.1 — Shared Chrome (all states)

**Status bar:** 28 pt height, OS-rendered.

**App bar:**
- Layout: flex row, gap 14 pt, padding 6 pt top / 20 pt horizontal / 14 pt bottom  
  _(Exception: SaveFailure uses 10 pt bottom to make room for the banner below)_
- Back icon: 20 × 20 pt, white in all states except Saving (dim during lock)
- Title: 17 pt / 800 / letter-spacing 0.02 em — "New Workout Plan" (create) or "Edit Workout Plan" (edit, validation errors, saving, save failure, discard confirm); dim during saving

**Sticky footer:**
- Padding: 14 pt top / 20 pt horizontal / 20 pt bottom  
- Top border: 1 pt solid `color.border` (#444933)
- Primary action button (see each state for variant)

---

### 3.2 — Create Mode (blank) — `CreateMode.dc.html`

**App bar title:** "New Workout Plan"

**Plan Name field:**
- Label: "PLAN NAME" — 11 pt / 700 / letter-spacing 0.08 em / `color.dim` (#8a8f7a) / text-transform uppercase / margin-bottom 8 pt
- Input: `color.card` fill (#201f22), 1 pt solid `color.border` (#444933), border-radius 12 pt, padding 13 pt vertical / 14 pt horizontal
  - Placeholder: "e.g., Push Day" — 16 pt / **600** / `color.dim` (#8a8f7a) — lighter weight + dim color distinguishes placeholder from real text

**Exercise area (empty state):**
- "Add Exercise" button immediately below the plan name field:
  - Border: 1.5 pt dashed `color.border` (#444933)
  - Border-radius: 14 pt
  - Padding: **16 pt** (slightly larger than populated state's 14 pt)
  - Layout: flex center, gap 8 pt
  - Plus icon: 16 × 16 pt, `color.lime`
  - Label: "Add Exercise" — 14 pt / 700 / `color.lime`
- Below the add button: empty exercises well
  - Layout: flex column, align-items center, justify-content center, gap 14 pt, padding 40 pt vertical / 20 pt horizontal
  - Empty icon: 44 × 44 pt, `color.dim` (#8a8f7a) — horizontal-lines list icon
  - Label: "No exercises added yet" — 14 pt / 600 / `color.muted` (#c4c9ac)

**Save button (disabled state):**
- Fill: `color.cardAlt` (#2a2a2c)
- Text: `color.dim` (#8a8f7a), 15 pt / 800
- Label: "Save Plan"
- Not tappable — visually and functionally disabled
- No lime — signals the form is not yet complete

---

### 3.3 — Edit Mode (populated) — `Main.dc.html`

**App bar title:** "Edit Workout Plan"

**Plan Name field:**
- Label: same as create mode
- Input: same shell but **16 pt / 700 / `color.white`** (real text, not placeholder) — e.g., "Push Day — Upper Body"

**Exercises section:**
- Section label: "EXERCISES" — same label style, margin-bottom 10 pt (combined with the section-row spacer)
- Exercise list: flex column, gap 10 pt

**Exercise card (shared structure):**
- Fill: `color.card` (#201f22)
- Border: 1 pt solid `color.border` (#444933)
- Border-radius: 16 pt
- Padding: 14 pt vertical / 16 pt horizontal
- Internal layout: flex column, gap 12 pt

  **Header row** (flex, align-items center, space-between):
  - Left: flex column, gap 4 pt
    - Name: 15 pt / 700 / `color.white`
    - Type badge: flex row, gap 6 pt, 11 pt / 600 / `color.muted` — `<dot> <type label>`
      - Dot: 7 × 7 pt circle — Weighted = `color.cyan` (#7df4ff) / Time-based = `color.lime` (#c3f400) / Bodyweight = `color.muted` (#c4c9ac)
  - Right: Remove (×) button
    - Size: 26 × 26 pt circular
    - Fill: `color.cardAlt` (#2a2a2c)
    - × icon: 13 × 13 pt, `color.dim` (#8a8f7a)

**Field grids per exercise type (FR-4a):**

Each cell (`.field-box`):
- Fill: `color.cardAlt` (#2a2a2c)
- Border: 1 pt solid `color.border` (#444933)
- Border-radius: 10 pt
- Padding: 8 pt vertical / 6 pt horizontal
- Text-align: center
- Value (`fval`): 14 pt / 800 / `color.white`
- Label (`flabel`): 10 pt / `color.muted` / margin-top 2 pt

**Weighted exercise layout** (Barbell Bench Press example):

```
Row 1:  [ Sets ]  [ Reps ]  [ Weight ]   ← grid-template-columns: 1fr 1fr 1fr
Row 2:  [           Rest           ]     ← grid-template-columns: 1fr (full width)
```
- Rest renders as its own grid with `grid-template-columns: 1fr`, gap 8 pt — the single cell stretches full width

**Time-based exercise layout** (Plank example):

```
Row 1:  [ Sets ]  [ Duration ]  [ Rest ]   ← grid-template-columns: 1fr 1fr 1fr
```
- Duration displayed as `mm:ss` (e.g., "00:45")
- No reps field, no weight field

**Bodyweight exercise layout** (Push-Up example):

```
Row 1:  [ Sets ]  [ Reps ]  [ Rest ]   ← grid-template-columns: 1fr 1fr 1fr
```
- No weight field
- Rest is in the same row as Sets and Reps (not on a separate full-width row)

**Sample populated artboard data:**

| Exercise | Type | Field values |
|---|---|---|
| Barbell Bench Press | Weighted | Sets: 4, Reps: 8, Weight: 60 kg · Rest: 90s |
| Plank | Time-based | Sets: 3, Duration: 00:45, Rest: 60s |
| Push-Up | Bodyweight | Sets: 3, Reps: 15, Rest: 60s |

**"Add Exercise" button** (populated state):
- Identical to create mode but padding **14 pt** (slightly smaller since there's content above)
- Always visible at the bottom of the exercise list, above the footer

**Save button (active state):**
- Fill: `color.lime` (#c3f400)
- Text: #131315 (bg), 15 pt / 800
- Label: "Save Plan"
- Enabled and tappable

---

### 3.4 — Validation Errors State — `ValidationErrors.dc.html`

**When shown:** User taps "Save Plan" with one or more invalid fields. The save is blocked; errors appear inline without leaving the screen.

**App bar:** Same as edit mode (title "Edit Workout Plan")

**Plan Name field — blank/whitespace error:**
- Input border: **1.5 pt solid `color.danger`** (#ff6b6b) — thicker + danger colour
- Input text: `color.dim` (#8a8f7a) — content is blank or whitespace
- **Error message below input:** "Plan name can't be blank." — 12 pt / 600 / `color.danger` / margin-top 6 pt

**Field box — invalid value:**
- `.field-box.err` border: `color.danger` (#ff6b6b)
- `.field-box.err .fval` colour: `color.danger` (#ff6b6b)

**Exercise card error — below the field grid:**
- `.field-error` (per card): 12 pt / 600 / `color.danger` / margin-top 6 pt
- Combines multiple field errors in one line per card

**Error copy from artboard:**

| Field | Error message |
|---|---|
| Plan name (blank) | "Plan name can't be blank." |
| Reps = 0 (weighted) | "Reps must be greater than 0. Weight must be greater than 0." (combined) |
| Weight = 0 kg (weighted) | _(combined with reps error above)_ |
| Duration = 00:00 (time-based) | "Duration must be greater than 00:00." |

**Save button (blocked state):**
- Fill: `color.cardAlt` (#2a2a2c) — same as disabled create state
- Text: `color.dim` (#8a8f7a) — "Save Plan"
- Not tappable while errors exist

---

### 3.5 — Saving (Loading) State — `SavingLoading.dc.html`

**When shown:** Immediately after "Save Plan" is tapped with valid data, while the database write is in flight.

**App bar:** Back icon and title both use **`color.dim`** (#8a8f7a) — visually locked, back navigation is disabled during save

**Content area:**
- `opacity: 0.45`
- `pointer-events: none` — the entire form is non-interactive
- Form content remains visible (user can see what is being saved)

**Save button (saving state):**
- Fill: `color.lime` (#c3f400) — same as active
- Text: #131315, 15 pt / 800
- Layout: flex center, gap 10 pt; padding **14 pt** (slightly less)
- **Spinner:** 18 × 18 pt circular; border 2.5 pt solid `rgba(19,19,21,.25)` all sides; border-top-color #131315; animation `spin 0.8s linear infinite`
- Label: "Saving…" (with ellipsis)

---

### 3.6 — Save Failure State — `SaveFailure.dc.html`

**When shown:** Database write throws an exception. In-progress edits are preserved in memory (NFR-3).

**App bar:** Normal (white icon + white title); padding bottom **10 pt** (reduced to give room to the banner)

**Save failure banner** (between app bar and scrollable content):
- Margin: 0 20 pt 12 pt (20 pt horizontal, 12 pt below)
- Fill: `#2a1f1f` (dark red tint — not a named token, specific to this component)
- Border: 1 pt solid `#5c3a3a` (`color.dangerBorder`)
- Border-radius: 12 pt
- Padding: 12 pt vertical / 14 pt horizontal
- Layout: flex row, align-items flex-start, gap 10 pt
- Warning icon: 18 × 18 pt, `color.danger` (#ff6b6b), margin-top 1 pt (optical alignment)
- Banner text:
  - Bold line: "Couldn't save your changes" — `display:block`, 13 pt / white / margin-bottom 2 pt
  - Body: "Something went wrong writing to local storage. Your edits below are kept — tap Retry to try again." — 12 pt / `color.muted` / line-height 1.4

**Content area:** Normal (form is fully editable and interactive); the user's edits from the failed save are still visible and can be modified before retrying

**Footer button — Retry Save:**
- Fill: `color.lime` (#c3f400)
- Text: #131315, 15 pt / 800
- Label: **"Retry Save"** (not "Save Plan")
- Full width, border-radius 12 pt, padding 15 pt

---

### 3.7 — Discard Changes Confirmation — `DiscardConfirm.dc.html`

**When shown:** User taps the back icon or triggers a back gesture while the form has unsaved changes.

**Underlying screen:** The form content remains visible behind the scrim (user can see they have changes).

**Scrim:** `position:absolute; inset:0; background:rgba(10,10,10,.6)` — full-screen dark overlay; flex center with horizontal padding 30 pt

**Dialog card:**
- Width: 100% (within 30 pt horizontal scrim padding → effective width 330 pt on 390 pt screen)
- Fill: `color.card` (#201f22)
- Border: 1 pt solid `color.border` (#444933)
- Border-radius: 18 pt
- Padding: 24 pt vertical / 20 pt horizontal
- Layout: flex column, align-items center, text-align center, gap 10 pt

  **Icon:** 34 × 34 pt, `color.lime` (#c3f400) — circle-with-exclamation (info circle), stroke-width 1.6 pt; margin-bottom 2 pt  
  **Title:** "Discard changes?" — 16 pt / 800 / `color.white`  
  **Subtitle:** "You have unsaved changes to this workout plan. Leaving now will discard them." — 13 pt / `color.muted` / line-height 1.5  
  **Actions row:** flex, gap 10 pt, width 100%, margin-top 10 pt

  | Button | Label | Fill | Text | Border |
  |---|---|---|---|---|
  | Left — Discard | "Discard" | `color.cardAlt` (#2a2a2c) | `color.white`, 13 pt/800 | 1 pt solid `color.border` (#444933) |
  | Right — Keep Editing | "Keep Editing" | `color.lime` (#c3f400) | #131315, 13 pt/800 | None |

  Both buttons: flex:1, border-radius 10 pt, padding 12 pt vertical.

  **Button semantics:** "Keep Editing" is the primary/safe action (lime); "Discard" is the destructive action (dim fill, white text). This deliberately places the destructive action on the left and the safe action on the right — matches iOS and Material conventions.

---

## §4 — Interactions & Behavior

### 4.1 — Plan Name Field

- **Tap:** Opens keyboard; cursor placed at end of existing text (edit mode) or beginning of empty field (create mode)  
- **Input:** Real-time character entry; no inline validation on keystroke — validation runs only on save attempt  
- **Placeholder appearance:** 16 pt / 600 / `color.dim` — visually lighter than entered text (16 pt / 700 / `color.white`)  
- **Clear:** No explicit clear button shown in artboards — platform default (select-all + delete)

### 4.2 — Field Boxes (Sets, Reps, Weight, Duration, Rest)

- **Tap:** Opens numeric keyboard (or mm:ss keyboard for Duration — see OQ-2)  
- **Input type:**
  - Sets: positive integer
  - Reps: positive integer (weighted / bodyweight only)
  - Weight: positive decimal with unit suffix "kg" (weighted only) — see OQ-3 for unit handling
  - Duration: mm:ss format (time-based only) — stored as total seconds internally
  - Rest: integer or seconds suffix "s" — see OQ-4 for rest display format
- **Validation:** On save-attempt only — not on blur  
- **Error state:** Border switches to danger, value text switches to danger; error message appears below the card

### 4.3 — Remove (×) Button on Exercise Card

- **Tap:** Removes the exercise card from the list  
- **Confirmation:** No confirmation dialog for individual exercise removal (not specified in artboards)  
- **Effect on save button:** If removing the last exercise, save button may become disabled — see OQ-5

### 4.4 — "Add Exercise" Button

- **Tap:** Navigates to **SCR-07 (Exercise Catalogue) in Picker mode**, passing the plan's planId (create: tentative; edit: existing)  
- **Return from SCR-07:** The selected exercise is added to the exercise list with a new exercise card  
- **Default target values for new exercise:** Sets default (see OQ-6), Reps/Duration/Weight blank or default  
- **Always visible:** Shown at the bottom of the exercise list in both states; present even when the list has items

### 4.5 — Save Plan Button

**State machine:**

| Condition | Button state | Visual |
|---|---|---|
| Form has no exercises (create, blank) | Disabled | `color.cardAlt` fill, `color.dim` text |
| Form has validation errors | Blocked | `color.cardAlt` fill, `color.dim` text |
| Form is valid | Active | `color.lime` fill, #131315 text |
| Save in progress | Saving | `color.lime` fill + spinner + "Saving…" text |
| Save failed | Retrying | Becomes "Retry Save" lime button |

- **Tap (active):** Runs all validation. If passes: transitions to Saving state → database write → SCR-10 or SaveFailure. If fails: shows inline errors, button goes to blocked state
- **Tap (disabled/blocked):** No response  
- **Tap (saving):** No response (pointer-events:none on form)

### 4.6 — "Retry Save" Button (save failure state)

- **Tap:** Re-attempts the database write with the current in-memory form data (no validation re-run needed — the data was already valid when the first attempt was made)  
- **Transition:** Returns to Saving state (spinner, form locked)

### 4.7 — Back Navigation (all states)

| Form state | Action |
|---|---|
| No unsaved changes (clean) | Navigate back to SCR-08 without dialog |
| Unsaved changes present | Show discard confirmation dialog |
| Saving in progress | Back navigation disabled (back icon + swipe gesture disabled; back icon appears dim) |

### 4.8 — Discard Dialog Actions

- **"Keep Editing":** Dismiss dialog; return to form in its current state — no changes lost  
- **"Discard":** Dismiss dialog and navigate back to SCR-08; all form changes are discarded (not saved to the database)  
- **Tapping scrim outside dialog:** Behaviour undefined in artboard — assume: same as "Keep Editing" (safe dismissal) — see OQ-7

### 4.9 — Transitions and Animations

| Transition | Type |
|---|---|
| Entry into SCR-09 (from SCR-08 or SCR-10) | Push slide left |
| Save success → SCR-10 | Push slide left (replace stack — no back to SCR-09) |
| Discard → SCR-08 | Pop slide right |
| Save button → Saving state | In-place: lime fills + spinner fades in; form dims (`opacity 0.45`) |
| Saving → Save Failure | In-place: spinner removed; "Retry Save" label; form un-dims; banner slides in from top |
| Back tap → Discard dialog | Scrim fades in with dialog scale-up from center |
| Dialog dismiss ("Keep Editing") | Scrim fades out, dialog scale-down |
| Adding exercise card (return from SCR-07) | New card slides in at the bottom of the exercise list |
| Removing exercise card | Card fades/slides out; list items above/below reflow |

### 4.10 — Keyboard Behaviour

- Plan name field: text keyboard; return/done dismisses keyboard  
- Numeric fields: numeric keyboard; tapping outside or Done dismisses  
- Bottom footer is fixed and always visible when keyboard is up (form scrolls up behind footer)  
- Duration field: see OQ-2 — mm:ss may need a custom input or masked text field

---

## §5 — Edge Cases & Error Handling

### EC-1 — Blank / Whitespace Plan Name

**Trigger:** Save tapped; plan name is empty or whitespace-only  
**Visual:** Input border → 1.5 pt danger (#ff6b6b); error below: "Plan name can't be blank."  
**Save button:** Blocked (dim); remains blocked until name has non-whitespace content  
**Recovery:** User types valid name → error clears → save button becomes active if all other fields pass

### EC-2 — Invalid Exercise Reference

**Trigger:** An `exerciseId` in the plan's exercise list no longer exists in the `exercises` table  
**Display:** The artboard does not show a specific UI for invalid exercise reference mid-edit (this scenario is most likely to appear at save time if a previously valid reference is orphaned). Per FR-6, the save must be blocked.  
**Assumed behaviour:** Show an error banner or flag the specific card as invalid — see OQ-8

### EC-3 — Non-Positive Sets / Reps

**Trigger:** Save tapped; sets or reps value is 0 or negative  
**Visual:** `.field-box.err` — danger border + danger value text; field-error below card: "Reps must be greater than 0."  
**Note:** Sets validation not explicitly shown in the error artboard but FR-7 requires it — assume same treatment

### EC-4 — Non-Positive Weight (weighted exercises only)

**Trigger:** Save tapped; weight = 0 or negative for a weighted exercise  
**Visual:** `.field-box.err` on Weight cell; combined error: "Reps must be greater than 0. Weight must be greater than 0." (if both are invalid)  
**No weight field exists** for time-based or bodyweight exercises — this validation only runs when the exercise card has a Weight cell

### EC-5 — Non-Positive Duration (time-based only)

**Trigger:** Save tapped; duration = 00:00 for a time-based exercise  
**Visual:** `.field-box.err` on Duration cell; error below card: "Duration must be greater than 00:00."  
**Valid threshold:** Any value > 00:00 (stored as seconds > 0)

### EC-6 — Database Write Failure on Save

**Trigger:** The database write fails during the Saving state  
**Display:** Save Failure state (§3.6) — banner appears, form content preserved, "Retry Save" button replaces spinner  
**Not a duplicate:** The failed write must not have committed a partial record — retry re-attempts the same write without creating a duplicate

### EC-7 — Repeated Retry Failures

**Trigger:** Retry Save also fails  
**Display:** Same Save Failure banner; "Retry Save" button still present  
**No escalation UI defined** in artboards — error copy stays the same

### EC-8 — Empty Exercise List Save Attempt

**Trigger:** User somehow reaches a state with a valid plan name but zero exercises, then taps Save  
**Display:** Not defined in artboard — user story does not explicitly require ≥1 exercise. See OQ-5  
**Assumed:** Save button is disabled (dim) when exercise list is empty (matching the Create Mode artboard where save is dim before any exercises are added)

### EC-9 — Very Long Plan Name

**Trigger:** User types a plan name that exceeds the field width  
**Display:** Input field scrolls horizontally within the rounded rect; no wrapping  
**Max characters:** Not specified — see OQ-9

### EC-10 — All Exercises Removed (edit mode)

**Trigger:** User removes all exercises from a previously-populated plan  
**Display:** "No exercises added yet" empty well appears; save button dims — same as create mode empty state  
**Note:** This creates a meaningful empty-plan state in edit mode that matches the create-mode empty state

---

## §6 — Responsive & Platform Considerations

### Device Size Bands

| Band | Width | Effect |
|---|---|---|
| Small (iPhone SE) | 375 pt | Plan name input and field boxes slightly narrower; dialog effective width 315 pt (30 pt scrim padding each side); exercise card still 3-column on small screen — may be tight |
| Reference (iPhone 14/15) | 390 pt | Artboard reference size — no adjustment |
| Large (Plus/Max, 430 pt) | 430 pt | Field boxes and cards stretch; content area wider; plan name field more comfortable |

### iOS

- **Back gesture:** iOS swipe-from-left-edge triggers back navigation → unsaved-changes guard fires → discard dialog appears
- **Keyboard avoidance:** Footer "Save Plan" button must stay visible above the keyboard; content area scrolls up
- **Swipe-to-dismiss (modal):** If SCR-09 is presented modally, vertical swipe-down should be guarded the same as back navigation — see OQ-10
- **Home indicator:** Footer bottom padding 20 pt is designed to clear the home indicator

### Android

- **System back button / gesture:** Same guard as iOS — triggers unsaved-changes dialog
- **Keyboard:** IME appears from bottom; same footer-pinned layout applies
- **Portrait-only:** Consistent with rest of app — landscape not specified

### Keyboard Present

When the keyboard is open:
- The footer (`Save Plan` / `Retry Save`) must remain pinned above the keyboard — use `resizeToAvoidBottomInset` or equivalent
- The content area (form) scrolls independently behind the footer
- Filter chips and exercise list scroll freely

---

## §7 — Accessibility

### Touch Target Audit

| Element | Size | Meets 44 pt? |
|---|---|---|
| Plan name input (full width) | Full width × 13+13+16 ≈ 42 pt tall | ⚠️ 2 pt short — increase vertical padding to 14 pt each side |
| Field box (Sets/Reps/etc.) | ~(350/3 − 16) ≈ 100 pt wide × 8+8+14+10 = 40 pt tall | ⚠️ 4 pt short — use `minimumSize` or increase padding to 11 pt |
| Remove (×) button | 26 × 26 pt | ⚠️ 18 pt short — use `GestureDetector` with at least 44 × 44 pt hit area |
| "Add Exercise" dashed button | Full width × 14+14+16 = 44 pt | ✅ |
| Save / Retry Save button | Full width × 15+15+15 = 45 pt | ✅ |
| Discard dialog buttons | flex:1 × 12+12+13 = 37 pt tall | ⚠️ 7 pt short — increase dialog button padding to 15-16 pt |
| Back icon (app bar) | 20 × 20 pt | ⚠️ Extend touch area to 44 × 44 pt via padding / hit-test slop |

### Contrast

| Pair | Ratio | Meets WCAG AA? |
|---|---|---|
| `color.white` (#f5f6f1) on `color.card` (#201f22) — plan name, exercise name | ~12:1 | ✅ |
| `color.white` (#f5f6f1) on `color.cardAlt` (#2a2a2c) — field values | ~11:1 | ✅ |
| `color.muted` (#c4c9ac) on `color.cardAlt` (#2a2a2c) — field labels | ~6.5:1 | ✅ |
| `color.dim` (#8a8f7a) on `color.bg` (#131315) — disabled save text | ~4.5:1 | ✅ (borderline AA for 15 pt bold) |
| `color.danger` (#ff6b6b) on `color.card` (#201f22) — error text/border | ~3.5:1 | ⚠️ Decorative border only — error text must accompany it; error text pair OK |
| `color.danger` (#ff6b6b) on `color.bg` (#131315) — error message text | ~4.7:1 | ✅ |
| #131315 on `color.lime` (#c3f400) — save button text | ~12:1 | ✅ |
| `color.muted` on #2a1f1f banner background | ~6:1 | ✅ |

### Screen Reader Labels

| Element | Semantic label |
|---|---|
| "PLAN NAME" label + input | Label "Plan name", role: text input |
| Plan name error | Live region: "Plan name can't be blank." announced on validation |
| "EXERCISES" section heading | Heading level 2 |
| Exercise card | Group: "Barbell Bench Press, Weighted" |
| Sets field box | "Sets, [value]" |
| Reps field box | "Reps, [value]" |
| Weight field box | "Weight, [value] kg" |
| Duration field box | "Duration, [mm:ss]" |
| Rest field box | "Rest, [value] seconds" |
| Remove button | "Remove Barbell Bench Press" (include exercise name) |
| "Add Exercise" button | Button — "Add exercise to plan" |
| Save Plan button (active) | Button — "Save plan" |
| Save Plan button (disabled) | Button, greyed — "Save plan, unavailable" |
| "Saving…" state | Live region: "Saving plan…" |
| Save failure banner | Live region: "Error: Couldn't save your changes. Something went wrong writing to local storage." |
| Retry Save button | Button — "Retry saving plan" |
| Discard dialog | Modal — announce on appear: "Discard changes? You have unsaved changes to this workout plan." |
| Discard button | Button — "Discard changes" |
| Keep Editing button | Button — "Keep editing" |

### Focus Order

**Edit/Create mode:** App bar back button → Plan name input → [Each exercise card: exercise group → Sets → Reps/Duration → Weight (weighted only) → Rest → Remove button] → Add Exercise button → Save Plan button

**Validation error state:** Same order; error messages read immediately after their associated field/card

**Saving state:** Focus trapped; no interactive elements

**Save failure state:** App bar back → failure banner (read as live region) → Plan name input → [exercise cards…] → Add Exercise → Retry Save button

**Discard dialog:** Focus moves to dialog; Discard button → Keep Editing button; focus returns to form on dismiss

---

## §8 — Component & Design System Mapping

### Reused Components

| Component | Where used in SCR-09 | Precedent |
|---|---|---|
| Secondary app bar (back icon + title, no FAB) | All states | SCR-07 (Exercise Catalogue) — same layout, same measurements |
| Field label ("PLAN NAME", "EXERCISES") | Plan name section + exercises section | New typographic style: 11 pt/700/uppercase/dim/0.08em tracking — not seen in SCR-07/08 |
| Exercise type dot (7 × 7 pt) | Exercise card type badge | SCR-07 exercise rows — same dot system (cyan/lime/muted) |
| Dashed "Add Exercise" row | Exercise-less state + populated list bottom | New — no dashed-border affordance in prior screens |
| `color.cardAlt` field box | Target input cells | New — the cell tray pattern within cards |
| Lime full-width button | Save Plan / Retry Save | Matches SCR-08 empty state CTA and SCR-07 error Retry button |
| Error card / banner with #5c3a3a border | Save failure banner | SCR-07 error card uses same border — banner here is a strip variant, not a centred card |
| Modal scrim + dialog | Discard confirmation | New dialog shape — not used in SCR-07 or SCR-08 |
| Spinner (18 × 18 pt, border-top animation) | Saving state save button | New component for this screen |
| Dimmed form overlay (opacity 0.45) | Saving state content | New — opacity-based lock pattern |

### New / Modified Components

| Component | Type | Rationale |
|---|---|---|
| **Exercise card** | New | Composite card: header (name + type dot + remove btn) + conditional target field grids. Three layout variants (weighted / time-based / bodyweight) driven by exercise type flag. Candidate for `ExercisePlanCard` widget with `exerciseType` parameter. |
| **Target field box** | New | `cardAlt` background with `fval` + `flabel` inside a 10 pt radius box. Has an error variant (danger border + danger value text). Candidate for `TargetFieldBox` widget. |
| **Dashed "Add Exercise" button** | New | 1.5 pt dashed border affordance — distinct from solid-border lime FAB in SCR-08. Candidate for `DashedActionButton`. |
| **Save failure banner** | New variant | Inline banner within the screen (not a modal card). Uses #2a1f1f fill + #5c3a3a border — extends the danger pattern. Candidate for `InlineErrorBanner`. |
| **Discard confirmation dialog** | New | Two-button modal with scrim. `Keep Editing` (lime, right) is the primary action; `Discard` (dim, left) is destructive — this button order is intentional. Candidate for `DiscardChangesDialog`. |
| **Spinning save button** | New state | Lime button with inline spinner replacing icon. Reuses the button shell but adds animated border-top-color circle inside. |

---

## §9 — Acceptance Criteria Mapping

| AC / EC from user story | Design element that satisfies it | Spec section |
|---|---|---|
| **AC-1** — Create mode: blank name, empty list, "Add exercise" action shown | CreateMode artboard: placeholder input, "Add Exercise" dashed button, "No exercises added yet" empty well | §3.2 |
| **AC-2** — Edit mode: fields pre-filled with existing plan data | Main artboard: 16 pt/700 white name input, exercise cards with populated targets | §3.3 |
| **AC-3** — Save: valid plan → database write → route to SCR-10 | Save button active state → Saving state → success transition to SCR-10 | §4.5, §4.9 |
| **AC-4** — Leave with unsaved changes: discard confirmation shown | DiscardConfirm artboard: scrim + dialog with "Discard" / "Keep Editing" | §3.7, §4.7, §4.8 |
| **EC-1** — Blank/whitespace name → inline error + save blocked | ValidationErrors artboard: danger border, "Plan name can't be blank." error, dim save button | §3.4, §5 EC-1 |
| **EC-2** — Invalid exercise reference → save blocked | Flagged as OQ-8 — not shown in artboards; save must be blocked | §5 EC-2 |
| **EC-3** — Non-positive sets/reps → inline field error | ValidationErrors artboard: `.field-box.err` + "Reps must be greater than 0." | §3.4, §5 EC-3 |
| **EC-4** — Non-positive weight (weighted) → inline error | ValidationErrors artboard: weight cell danger + combined error message | §3.4, §5 EC-4 |
| **EC-5** — Non-positive duration (time-based) → inline error | ValidationErrors artboard: duration cell danger + "Duration must be greater than 00:00." | §3.4, §5 EC-5 |
| **EC-6** — Save loading state shown during write | SavingLoading artboard: spinner + "Saving…" + form dimmed + back disabled | §3.5, §4.5 |
| **EC-7** — Save failure → error state + retry + no duplicate | SaveFailure artboard: banner + "Retry Save" button + form preserved | §3.6, §5 EC-6 |
| **EC-8** — Local write failure → in-memory edits preserved | SaveFailure artboard: form is fully intact and editable behind the banner (NFR-3) | §3.6 |

### FR Coverage

| FR | Covered by design? | Section |
|---|---|---|
| FR-1 — Create mode: blank name + empty list + "Add exercise" | ✅ | §3.2 |
| FR-2 — Edit mode: pre-fill existing data | ✅ | §3.3 |
| FR-3 — Add exercises via Exercise Catalogue | ✅ — "Add Exercise" → SCR-07 picker mode | §4.4 |
| FR-4 / FR-4a — Per-exercise target fields by type flag | ✅ — 3 distinct field grid layouts in §3.3 | §3.3 |
| FR-5 — Blank/whitespace name blocks save | ✅ | §3.4, §5 EC-1 |
| FR-6 — Invalid exercise reference blocked | ⚠️ OQ-8 — design not shown | §5 EC-2, §10 OQ-8 |
| FR-7 — Non-positive sets/reps blocked | ✅ | §3.4, §5 EC-3 |
| FR-8 — Non-positive weight (weighted) blocked | ✅ | §3.4, §5 EC-4 |
| FR-9 — Duration mm:ss, non-positive blocked | ✅ display format; OQ-2 for input mechanism | §3.3, §3.4, §5 EC-5 |
| FR-10 — Valid save → SCR-10 | ✅ | §4.5, §4.9 |

---

## §10 — Open Questions / Assumptions

| # | Question | Owner | Blocks build? | Working assumption |
|---|---|---|---|---|
| **OQ-1** | **Entry point for edit mode:** SCR-08 plan card tap → SCR-10 first, then edit from there? Or does SCR-08 go directly to SCR-09? The user story lists SCR-10 as the plan-detail exit, but it's ambiguous whether SCR-08 rows navigate to SCR-10 or SCR-09. | Product | **Yes** — affects navigation stack | Assume: SCR-08 → SCR-10 (plan detail) → edit action within SCR-10 → SCR-09 (edit mode). SCR-08 does not navigate directly to SCR-09. |
| **OQ-2** | **Duration input mechanism for time-based exercises:** The artboard shows `mm:ss` as the displayed format but doesn't show how the user enters it. Options: (a) free-text masked input ("00:45"), (b) two separate integer fields (min + sec), (c) a wheel/spinner picker. | Design / Tech Lead | **Yes** — input widget decision | Assume: masked text input showing `mm:ss` with numeric keyboard; leading-zeros enforced; cursor behaviour specified separately |
| **OQ-3** | **Weight unit and decimal:** Is weight always "kg"? Is a decimal value supported (e.g., 67.5 kg)? Is the unit suffix part of the stored value or appended at display time? | Product / Tech Lead | Yes — data model | Assume: kg only for V1; decimal allowed (one decimal place); unit suffix is display-only, value stored as numeric |
| **OQ-4** | **Rest format:** The artboard shows "90s" and "60s" — is rest always stored as an integer number of seconds and displayed with an "s" suffix? Or does the display convert to "1:30" for values ≥ 60s? | Design | Minor | Assume: displayed as plain integer + "s" (e.g., "90s") regardless of value |
| **OQ-5** | **Empty exercise list rule:** The Create Mode artboard shows the Save button as disabled (dim). Is saving blocked entirely when the exercise list is empty, or can a plan be saved with no exercises (just a name)? | Product | Yes — save validation | Assume: save is blocked when exercise list is empty — the disabled save button in CreateMode confirms this |
| **OQ-6** | **Default values for a newly-added exercise:** When a user adds an exercise from SCR-07, what are the initial values for Sets, Reps/Duration, Weight, and Rest? Zero? Blank? A sensible preset? | Product | Minor — UX | Assume: all target fields default to 0 (shown in error state artboard as "0" and "0 kg") — user must fill them in |
| **OQ-7** | **Tapping the scrim behind the discard dialog:** Does tapping the scrim dismiss the dialog (same as "Keep Editing") or have no effect? | Design | Minor | Assume: tap on scrim = "Keep Editing" (safe dismiss), consistent with iOS modal sheet and Material dialog conventions |
| **OQ-8** | **Invalid exercise reference UI:** FR-6 requires blocking save on an invalid exerciseId, but no artboard shows how this is surfaced. Is the card shown with an error state, or a banner, or something else? | Design | **Yes** — UI missing from reference | Assume: display an error below the exercise card similar to field errors: "This exercise is no longer available." Mark the card with a danger border. |
| **OQ-9** | **Plan name max character limit:** Not specified. A very long name could overflow UI at SCR-08 plan list rows and SCR-10 headers. | Product | Minor | Assume: 100 characters max; enforced at input level (keyboard `maxLength`) |
| **OQ-10** | **SCR-09 presentation style (push vs. modal):** Per the dependency note in the user story, SCR-09 is entered from SCR-08 or SCR-10. Is it pushed (slide) or presented modally (sheet)? This affects swipe-to-dismiss guard behaviour on iOS. | Design / Product | **Yes** — back gesture behaviour | Assume: pushed (slide left), consistent with SCR-07's precedent for secondary screens. If modal: swipe-down must also trigger unsaved-changes guard. |
| **OQ-11** | **"Add Exercise" while in Saving or Save Failure state:** Can the user add an exercise while the banner is shown (Save Failure)? The form is editable in that state, so presumably yes — but adding an exercise would clear the failure state? | Design / Tech Lead | Minor | Assume: form is fully editable in Save Failure state; adding an exercise does not re-enable the "Retry Save" label — user must save again via the Retry Save button |
| **OQ-12** | **Sets field in validation errors artboard:** The ValidationErrors artboard shows an exercise card with Reps (err) / Weight (err) / Rest in a 3-column grid — Sets is missing from the error example. Is Sets validation required? How is it surfaced? | Design | Minor | Assume: Sets = 0 is also an error, shown with `.field-box.err` on the Sets cell; error message below card: "Sets must be greater than 0." |
