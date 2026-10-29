# Design Specification: SCR-16 — Active Workout — Exercise & Set Logging

**Story ID**: US-SCR16  
**Priority**: High | **Points**: 8  
**Created**: 2026-09-13  
**Design reference**: https://claude.ai/code/artifact/c07e56bd-be35-430e-9d95-299de1058efd  
**Artboards**: Main.dc.html · Validation.dc.html · TimeBased.dc.html · Paused.dc.html

---

## 1. Overview & Goal

### Problem
The user has reviewed their plan on SCR-15 and tapped Begin Workout. They now need to work through each exercise and set, entering actual performance against the plan's targets, with clear feedback when entries are invalid and a safe way to pause or cancel without losing already-logged data.

### User
Any ForgeApp user actively performing a workout session that was started from SCR-15.

### Goal
Enable the user to log actual reps/weight/duration per set for each exercise in the plan, advancing through the workout automatically as sets are completed, and finish with a completed session record written to Drift — or cancel cleanly with no data saved.

### Success metric
User can complete a workout (log at least one set, tap Finish) and arrive at SCR-19 with a persisted record. Validation prevents invalid data from being logged silently. Cancel routes to SCR-18 with no data persisted.

### App context
ForgeApp is fully offline. All execution state is held in local in-memory state during the session — not persisted per-action. The completed record is written to Drift only when the user taps Finish (and at least one set has been logged). If the app is killed or crashes before Finish, the session is discarded (no partial record — same as Cancel). App-backgrounded timer behaviour is **DEFERRED** per Decisions Log §6b; no specific behaviour is specified or depicted in the artboards.

### Completion criterion (Decisions Log §1)
A session counts as completed when:
1. At least one set of at least one exercise has been logged, **AND**
2. The user explicitly taps Finish/Done (the final "Complete Set" on the last set acts as the Finish trigger in the artboard; the precise Finish gesture is documented as OQ-4).

Zero sets logged + Finish = same as Cancel (discard, nothing saved).

---

## 2. User Flow

### Entry point
- **SCR-15 (Workout Pre-Start)**: user taps "Begin Workout" → push SCR-16.

### Exit points
| Action | Destination |
|--------|-------------|
| Cancel (confirmed) | → SCR-18 (Cancel Workout Confirmation) → discard |
| Complete Set (last set, ≥1 set logged) | → SCR-19 (Workout Summary / Completion) |
| Pause → Resume | Stay on SCR-16 (Paused state → Active) |
| Skip item | Stay on SCR-16, advance to next item |
| OS back gesture / hardware back | Same as Cancel → SCR-18 (OQ-5) |

### State machine

```
Entry from SCR-15
        │
        ▼
[A] ACTIVE — Log Set (Weighted / Bodyweight / Time-based)
 │  │  │
 │  │  └─ Validation error on field? → Stay in A with [B] Validation overlay
 │  │      └─ Error resolved → back to A (Complete Set re-enabled)
 │  │
 │  ├─ Skip ──────────────────────────────────────────────┐
 │  │                                                     │
 │  ├─ Pause ──────────────────────────────────────────► [C] PAUSED overlay
 │  │                                                     │
 │  │                                               Resume ▼
 │  │                                           Back to [A] ACTIVE
 │  │
 │  ├─ Complete Set (valid, NOT last set/exercise) → advance to next set/exercise in [A]
 │  │
 │  ├─ Complete Set (valid, last set, ≥1 set logged) → SCR-19
 │  │
 │  └─ Cancel ──────────────────────────────────────────► SCR-18 (confirm)
 │                                                        │
 │                                                  Confirm discard → app discards session
 │                                                  Go back → return to [A]
 └─ Skip (mark item skipped, advance)
```

### Progress model
- **Exercise progress**: shown via the top progress bar (lime fill, proportional to exercises completed or in progress) and the "Exercise N of M" label.
- **Set progress**: shown via the pill-dot row below the exercise name (done = lime, current = white, upcoming = card-alt).

Both dimensions are always visible simultaneously, so the user always knows where they are in the overall workout and within the current exercise.

---

## 3. Screen-by-Screen Breakdown

### Shared structure (all states)

**Viewport**: 390×844px; `background:#131315`; `color:#f5f6f1`; `font-family:'Helvetica Neue', Arial, sans-serif`

**App bar** (`padding:6px 20px 4px; display:flex; align-items:center; justify-content:space-between`):
- Title: "ACTIVE WORKOUT" — `font-size:15px; font-weight:800; color:#c4c9ac` — ALL CAPS, MUTED colour.
  > This is a deliberate departure from all prior screens (which use mixed-case titles in white). The ALL CAPS muted treatment communicates ambient status ("you are in a workout") rather than a navigable page title. No back chevron is present; Cancel is the only explicit exit.
- Cancel link: `font-size:13px; font-weight:700; color:#ff6b6b` — danger red, right-aligned

**Progress section** (`.progress-wrap`, `padding:10px 20px 4px`):
- Progress label row: `display:flex; justify-content:space-between; font-size:11px; color:#8a8f7a; font-weight:700; margin-bottom:6px`
  - Left: Plan name (e.g. "Push Day — Upper Body")
  - Right: "Exercise N of M" (e.g. "Exercise 2 of 5")
- Progress track: `height:6px; background:#2a2a2c; border-radius:4px; overflow:hidden`
- Progress fill: `height:100%; background:#c3f400; border-radius:4px` — width proportional to exercise progress

---

### State A — Active (Log Set)

**When**: App opens to this state (from SCR-15). Persists between sets and exercises as the user progresses.

**App bar**: Title `color:#c4c9ac` (muted); Cancel `color:#ff6b6b` — both normal.

**Progress wrap**: Normal (lime fill, no opacity reduction).

**Content** (`flex:1 1 auto; padding:18px 20px 0; gap:16px`):

**Exercise header block**:
```
ex-head (gap:8px; align-items:center):
  type-dot (9×9; 50% radius) + type-label (11px/700/dim/uppercase/.04em)
ex-name: 22px/800; margin-top:2px
ex-sub: 12px/muted; margin-top:2px — "Set N of M"
set-dots (gap:8px; margin-top:4px):
  each dot: width:26px; height:6px; border-radius:3px
```

Type dot colours:
| Type | Dot colour |
|------|-----------|
| Weighted | `#c3f400` (lime) |
| Time-based | `#7df4ff` (cyan) |
| Bodyweight | `#c4c9ac` (muted) — *inferred from SCR-09/10/15 pattern; not shown separately in artboard* |

Set dot colours:
| State | Background |
|-------|-----------|
| Done | `#c3f400` (lime) |
| Current | `#f5f6f1` (white) |
| Upcoming | `#2a2a2c` (card-alt) |

**Entry card** (`.entry-card`):
```css
background:#201f22; border:1px solid #444933; border-radius:16px;
padding:18px; display:flex; flex-direction:column; gap:14px;
```
- Entry title: `font-size:12px; font-weight:800; color:#8a8f7a; text-transform:uppercase; letter-spacing:.05em` — "LOG THIS SET"
- Target row: `font-size:12px; color:#c4c9ac` — e.g. "Target: 8 reps · 60 kg" or "Target: 00:45"

**Field layout — Weighted (2-column)**:
```css
.field-row { display:flex; gap:12px; }
.field { flex:1; display:flex; flex-direction:column; gap:6px; }
```
Fields: Reps + Weight (kg)

**Field layout — Time-based (1-column, full width)**:
```css
.field { display:flex; flex-direction:column; gap:6px; }
```
Field: Duration (mm:ss)

**Field layout — Bodyweight (1-column or 2-column, Reps only)**:
Not separately mocked; per §10 of the user story, it is a strict subset of the weighted layout with the weight field omitted. Implementation: single-field layout matching time-based, or field-row with one field. Recommend 2-column grid with Reps in the left cell and right cell empty/absent (OQ-1).

**Field label**: `font-size:11px; font-weight:700; color:#8a8f7a; text-transform:uppercase; letter-spacing:.04em`
- Labels: "Reps", "Weight (kg)", "Duration (mm:ss)"

**Field input (valid)**:
```css
background:#2a2a2c; border:1px solid #444933; border-radius:12px;
padding:14px; font-size:20px; font-weight:800; text-align:center; color:#f5f6f1;
```
Pre-filled with plan target value (e.g. "8", "60", "00:45").

**Actions row** (`.actions-row`, `display:flex; gap:10px; padding:18px 20px 0`):
- Skip button: `flex:1; border-radius:12px; padding:14px; 800/13px; background:#2a2a2c; color:#c4c9ac; border:1px solid #444933` — muted text signals secondary/passive
- Pause button: `flex:1; border-radius:12px; padding:14px; 800/13px; background:#2a2a2c; color:#f5f6f1; border:1px solid #444933` — white text signals actionable but not primary

**Footer** (`padding:14px 20px 22px`):

Complete Set button (valid, enabled):
```css
width:100%; background:#c3f400; color:#131315;
border-radius:14px; padding:16px; text-align:center; font-weight:800; font-size:15px;
```

---

### State B — Validation Error

**When**: User attempts to complete a set with one or more invalid field values (non-positive reps, negative weight, or negative duration).

**All structure above remains unchanged** except:

**Field input (invalid)**:
```css
border-color:#ff6b6b; background:#2a1f1f; color:#ff6b6b;
```
(All other field-input properties unchanged.)

**Field error** (below input, `.field-error`):
```css
font-size:11px; color:#ff6b6b; font-weight:600;
```
Error messages (verbatim from artboard):
| Field | Trigger | Message |
|-------|---------|---------|
| Reps | value ≤ 0 | "Enter a rep count greater than 0." |
| Weight (kg) | value < 0 | "Weight can't be negative." |
| Duration (mm:ss) | value < 0 | "Duration can't be negative." |

**Complete Set button (disabled)**:
```css
background:#2a2a2c; color:#8a8f7a; border:1px solid #444933; border-radius:14px;
padding:16px; font-weight:800; font-size:15px; width:100%;
```
Disabled state matches SCR-13's disabled Save button style exactly.

**Multiple-field validation**: Both Reps and Weight fields can be invalid simultaneously (shown in Validation.dc.html artboard). Each field shows its own error independently below its input.

**Validation timing**: Errors are shown when the user attempts to tap Complete Set with invalid values (on-attempt, not on blur/change). When the user then edits a field, the error for that field clears as soon as it becomes valid (inline, real-time as they type).

---

### State C — Paused

**When**: User taps Pause. A panel appears over the dimmed workout content.

**App bar** (changes from State A):
- Title "ACTIVE WORKOUT": `color:var(--dim)` (#8a8f7a) — further dimmed (was muted #c4c9ac in active)
- Cancel link: `color:#ff6b6b; opacity:.5` — danger red but half-opacity; visible but subdued

**Progress wrap** (`opacity:.5` — entire section half-opacity):
- Progress fill: `background:var(--dim)` (#8a8f7a) — NOT lime; desaturated to indicate no active progression

**Content** (`opacity:.35; filter:grayscale(.4)`):
- Exercise header still rendered; entry card rendered as a fixed-height placeholder (`height:96px`)
- Type dot: `background:var(--dim)` — desaturated regardless of exercise type
- Content is fully non-interactive (pointer-events blocked by the overlay)

**Scrim** (`.scrim`):
```css
position:absolute; inset:0; display:flex; align-items:center; justify-content:center; padding:0 30px;
```
> **Critical**: NO background on the scrim. The underlying content (dimmed and greyscaled) is visible through the overlay. This is distinct from SCR-11/SCR-14's modal scrims which used `rgba(10,10,10,0.62)`. The Pause state uses content dimming (`opacity` + `grayscale`) rather than a dark overlay.

**Pause panel** (`.pause-panel`):
```css
width:100%; background:#201f22; border:1px solid #444933; border-radius:18px;
padding:26px 22px; display:flex; flex-direction:column; align-items:center;
text-align:center; gap:12px;
```

**Pause icon wrapper** (`.pause-icon-wrap`):
```css
width:56px; height:56px; border-radius:50%; background:#2a2a2c;
display:flex; align-items:center; justify-content:center;
```

**Pause icon** (`.pause-icon`, `width:24px; height:24px; color:#c3f400`):
Lime pause symbol — two filled rectangles:
```svg
<rect x="6" y="5" width="4" height="14" rx="1"/>
<rect x="14" y="5" width="4" height="14" rx="1"/>
```

**Pause title**: `font-size:17px; font-weight:800` — "Workout Paused"

**Pause sub**: `font-size:13px; color:#c4c9ac; line-height:1.5` — "Your progress is held locally. Resume when you're ready."

**Pause timer**: `font-size:13px; color:#8a8f7a; font-weight:700; letter-spacing:.02em` — "Paused at HH:MM:SS" format (e.g. "Paused at 00:14:22")

**Resume button**:
```css
width:100%; background:#c3f400; color:#131315; border-radius:12px;
padding:14px; text-align:center; font-weight:800; font-size:14px; margin-top:4px;
```
Note: Resume button uses `border-radius:12px; padding:14px; font-size:14px` — slightly smaller than the Complete Set button (`14px radius; 16px padding; 15px font-size`). First instance of a second-tier CTA size in a non-dialog footer context.

---

## 4. Interactions & Behavior

| Element | State | Interaction | Result |
|---------|-------|-------------|--------|
| Cancel link | A, B | Tap | Push SCR-18; session holds in memory until confirmed/cancelled |
| Cancel link | C (Paused) | Tap | Available at `opacity:.5`; behaviour same as State A (OQ-6) |
| Skip | A | Tap | Mark current item as skipped; advance to next set or exercise; skip does not log any value |
| Pause | A | Tap | Transition to State C; execution state = PAUSED; timer held locally |
| Resume | C | Tap | Dismiss pause panel; return to State A; execution state = ACTIVE |
| Complete Set (valid) | A | Tap | Validate fields; if valid and not last item → advance to next set/exercise; if valid and last item with ≥1 set logged → push SCR-19 |
| Complete Set (invalid) | A | Tap | Trigger validation display (State B); do not advance |
| Field input | A, B | Edit | Number keyboard; edit clears field's own error in real-time once valid |
| Progress bar | A | — | Read-only; updates after each exercise completes |
| Set dots | A | — | Read-only; update as sets are completed (done → lime) or skipped |
| OS back gesture | A, B, C | Swipe right / hardware back | Treated as Cancel → SCR-18 (OQ-5) |

### Transition notes
- **A → C (Pause)**: content fades to `opacity:0.35` + `grayscale(0.4)` simultaneously as the pause panel slides/fades in. No explicit animation duration specified in artboard; recommend 200ms ease-out.
- **C → A (Resume)**: reverse — panel dismisses, content fades back to full opacity/colour. Recommend 200ms ease-in.
- **Set advance**: when Complete Set is tapped and valid, the exercise header and entry card update to show the next set. If moving to the next exercise, the type dot, name, sub, and dots row all update. Progress bar fill width updates proportionally.
- **State A → B**: no transition animation; the error messages appear inline below the field immediately on Complete Set tap.

### Input pre-fill behaviour
Fields are pre-filled with the plan's target values when a new set begins. The user can edit these before tapping Complete Set. Pre-fill is a convenience; the actual logged value is whatever is in the field at the time of Complete Set.

---

## 5. Edge Cases & Error Handling

| ID | Scenario | Handling |
|----|---------|---------|
| EC-1 | Non-positive reps value (0 or negative) | Inline error below Reps field: "Enter a rep count greater than 0."; Complete Set disabled |
| EC-2 | Negative weight value | Inline error below Weight field: "Weight can't be negative."; Complete Set disabled |
| EC-3 | Negative duration value | Inline error below Duration field: "Duration can't be negative."; Complete Set disabled |
| EC-4 | Both reps and weight invalid simultaneously | Both errors shown independently; Complete Set disabled until both are valid |
| EC-5 | App killed / crashed mid-workout | Session not saved; no entry appears in history; previously completed records unaffected (NFR-2, NFR-3) |
| EC-6 | User taps Finish/Done with zero sets logged | Treated as Cancel: no Drift write, no SCR-19; per Decisions Log §1 (implementation detail: the "Complete Set" on the last set acts as the Finish trigger, so reaching that tap inherently means ≥1 set has been logged — OQ-4) |
| EC-7 | User skips all sets of all exercises (zero logged) | Session remains discardable; Finish would be treated as Cancel; Cancel → SCR-18 → discard |
| EC-8 | Single-exercise, single-set plan | Progress bar shows "Exercise 1 of 1"; one set dot (current). After completing, → SCR-19 if ≥1 set logged |
| EC-9 | App backgrounded mid-workout | Timer/state behaviour is **DEFERRED** per Decisions Log §6b; no specific behaviour specified |
| EC-10 | User edits a field to valid after seeing error | Error for that field clears in real-time; Complete Set re-enables once all fields valid |
| EC-11 | Large number of sets (e.g. 10 sets) | Set dot row wraps or overflow-scrolls; 26px × 10 + 8px × 9 = 332px — fits within 350px available width with 20px padding each side at 390px viewport; edge case at 15+ sets (OQ-7) |
| EC-12 | Very long exercise name (>25 chars) | ex-name at 22px/800 wraps; ex-sub and set-dots sit below without constraint; entry card below accommodates naturally |

---

## 6. Responsive & Platform Considerations

### Device width bands

| Band | Width | Behaviour |
|------|-------|-----------|
| Small (SE / compact) | 375px | Field inputs 14px padding: 2-column field-row at (375-40-12)/2 = 161.5px each — comfortable at 20px/800 font. Set dots at 26px × N + 8px × (N-1) — fits up to ~10 sets |
| Standard | 390–430px | Artboard baseline |
| Large (Pro Max+) | 430px+ | No max-width cap specified; all elements expand to fill (OQ-8) |

### iOS / Android
- **iOS**: No back chevron — Cancel is the only nav affordance. OS swipe-right from left edge should route to SCR-18 (Cancel), not pop the route directly (OQ-5).
- **Android**: Hardware/gesture back should route to SCR-18, not pop directly.
- **Keyboard**: Numeric keyboard appears when a field input is tapped. The entry card must remain visible above the keyboard — implementation should scroll/pan content up when the keyboard appears.
- **Portrait only**: SCR-16 is portrait-only.

### Keyboard management
The entry card is the critical focusable region. When the keyboard opens, the entry card and actions row must remain visible. If the phone height minus keyboard height leaves insufficient room, the content area scrolls to keep the focused field visible. The Complete Set footer button must remain accessible (may require scrolling or sticky-footer treatment when keyboard is open).

---

## 7. Accessibility

### Touch targets
| Element | Nominal size | Status |
|---------|-------------|--------|
| Cancel link (13px text) | Tap target depends on Flutter hit-area; text alone is ~44pt wide but height is ~20pt | ⚠️ Ensure minimum 44×44 hit area via padding/InkWell |
| Skip button (`padding:14px`) | ~42pt height | ⚠️ borderline; recommend `padding:15px` |
| Pause button (`padding:14px`) | ~42pt height | ⚠️ same |
| Complete Set (`padding:16px`) | ~48pt height | ✅ |
| Resume (`padding:14px`) | ~42pt height | ⚠️ same as Skip/Pause |
| Field inputs (`padding:14px`) | ~48pt height at 20px font | ✅ |

### Colour contrast
| Text | Background | Ratio (est.) | Status |
|------|-----------|-------------|--------|
| "ACTIVE WORKOUT" (#c4c9ac / 15px 800) | #131315 | ~7.2:1 | ✅ |
| Cancel (#ff6b6b / 13px 700) | #131315 | ~4.3:1 | ⚠️ just below 4.5:1 AA; passes APCA; Design intent (danger red is communicative) |
| Plan name (#8a8f7a / 11px 700) | #131315 | ~3.8:1 | ⚠️ decorative/ambient label |
| "Exercise N of M" (#8a8f7a / 11px 700) | #131315 | ~3.8:1 | ⚠️ same |
| Type label (#8a8f7a / 11px 700) | #131315 | ~3.8:1 | ⚠️ secondary to type dot |
| Exercise name (#f5f6f1 / 22px 800) | #131315 | ~16:1 | ✅ |
| ex-sub (#c4c9ac / 12px) | #131315 | ~7.2:1 | ✅ |
| Entry title (#8a8f7a / 12px 800) | #201f22 | ~3.3:1 | ⚠️ section label; Design intent |
| Target row (#c4c9ac / 12px) | #201f22 | ~6.5:1 | ✅ |
| Field label (#8a8f7a / 11px 700) | #201f22 | ~3.3:1 | ⚠️ same as entry title |
| Field value (#f5f6f1 / 20px 800) | #2a2a2c | ~14.5:1 | ✅ |
| Skip (#c4c9ac / 13px 800) | #2a2a2c | ~6.2:1 | ✅ |
| Pause (#f5f6f1 / 13px 800) | #2a2a2c | ~14.5:1 | ✅ |
| Complete Set (#131315 / 15px 800) | #c3f400 | ~13.1:1 | ✅ |
| Field value invalid (#ff6b6b / 20px 800) | #2a1f1f | ~5.4:1 | ✅ |
| Error message (#ff6b6b / 11px 600) | #201f22 | ~4.7:1 | ✅ passes AA for normal |
| "Workout Paused" (#f5f6f1 / 17px 800) | #201f22 | ~15.5:1 | ✅ |
| pause-sub (#c4c9ac / 13px) | #201f22 | ~6.5:1 | ✅ |
| pause-timer (#8a8f7a / 13px 700) | #201f22 | ~3.3:1 | ⚠️ ambient/secondary |
| Resume (#131315 / 14px 800) | #c3f400 | ~13.1:1 | ✅ |

### Semantics
- **Screen identity**: "ACTIVE WORKOUT" header should be announced as a page title on route push ("Active Workout") — the ALL CAPS rendering is visual only.
- **Progress bar**: liveRegion announcement on exercise advance: e.g. "Exercise 3 of 5". The progress track itself is not an interactive element.
- **Exercise name**: announce as a heading when it changes (exercise advance or initial load).
- **Set dots**: announce current set position as text equivalent of the visual dot row, e.g. "Set 2 of 4 — 1 done". Visual dot colours are decorative.
- **Entry fields**: labelled via field-label; value pre-filled from plan. Announce as numeric input.
- **Validation errors**: liveRegion.polite on error appearance below each field; do not announce the valid-field state.
- **Pause panel**: when Pause is triggered, announce "Workout paused. Resume when ready." Focus moves to the Resume button.
- **Resume**: on Resume tap, announce "Workout resumed." Focus returns to the first field in the entry card.
- **Cancel link**: explicit button semantics; announce as "Cancel workout".

---

## 8. Component & Design System Mapping

| Component | Usage in SCR-16 | Token / Value |
|-----------|----------------|--------------|
| WorkoutAppBar | All states | 15px/800 ALL CAPS muted title; danger Cancel link right-aligned; NO back chevron |
| ExerciseProgressBar | All states A/B | lime fill proportional to exercise count; track card-alt; height:6px |
| ExerciseProgressLabel | All states A/B | plan name (left) + "Exercise N of M" (right); 11px/700/dim |
| TypeDot | States A/B | 9×9 circle; lime/cyan/muted by type |
| TypeLabel | States A/B | 11px/700/dim/uppercase |
| ExerciseName | States A/B | 22px/800 |
| SetSubLabel | States A/B | 12px/muted "Set N of M" |
| SetProgressDots | States A/B | 26×6px pills; done=lime, current=white, upcoming=card-alt; gap:8px |
| EntryCard | States A/B | 16px radius; card fill; 1px border; padding:18px; gap:14px |
| EntryCardTitle | States A/B | 12px/800/dim/uppercase/.05em "LOG THIS SET" |
| TargetRow | States A/B | 12px/muted |
| FieldInput | State A (valid) | card-alt fill; 1px border; 12px radius; padding:14px; 20px/800/center |
| FieldInput.invalid | State B | border:#ff6b6b; bg:#2a1f1f; color:#ff6b6b |
| FieldError | State B | 11px/600/#ff6b6b — below input |
| SkipButton | States A/B | card-alt fill; muted text; 1px border; 12px radius; 14px padding; 800/13px |
| PauseButton | States A/B | card-alt fill; white text; 1px border; 12px radius; 14px padding; 800/13px |
| CompleteSetButton | State A (enabled) | lime fill; #131315; 14px radius; padding:16px; 800/15px |
| CompleteSetButton.disabled | State B | card-alt fill; dim text; 1px border (same as SCR-13 disabled Save) |
| PausedOverlay | State C | No scrim background; content dimmed opacity:.35 + grayscale:.4 |
| PausePanel | State C | card fill; 1px border; 18px radius; padding:26px 22px; gap:12px; centred |
| PauseIconWrap | State C | 56×56; 50% radius; card-alt fill |
| PauseIcon | State C | 24×24; lime; filled pause rects |
| PauseTitle | State C | 17px/800/white |
| PauseSub | State C | 13px/muted/line-height:1.5 |
| PauseTimer | State C | 13px/700/dim/letter-spacing:.02em |
| ResumeButton | State C | lime fill; #131315; 12px radius; padding:14px; 800/14px; margin-top:4px |

### New components / new patterns

| New pattern | Why new | Notes |
|-------------|---------|-------|
| WorkoutAppBar (ALL CAPS, muted title, no back) | No prior screen uses ALL CAPS title, muted colour, or removes the back chevron in favour of a Cancel link | Document as a distinct variant of AppBar for active-session screens |
| SetProgressDots (pill row) | First pill/dot progress indicator — SCR-15 showed a static list; SCR-16 is the first screen with live set-level progress | 26×6px pills; not circular dots |
| ExerciseProgressBar (inline, not footer) | Progress bars in prior screens were field-level; this is a workout-level bar immediately below the app bar | Different semantic level from field-progress |
| PausedOverlay (no-scrim dim) | SCR-11/14 used dark scrims; SCR-16 Pause uses opacity+grayscale content dimming with no overlay colour | Three distinct overlay techniques now exist in the system: dark scrim (modal dialogs), transparent panel (Pause), no overlay (route-level states) |
| FieldInput.invalid (inline input colour) | First instance of an invalid field colouring the input value text danger red, not just the border | Prior error patterns used red borders but neutral-coloured text inside |
| PauseTimer ("Paused at HH:MM:SS") | First live timer/timestamp display in the design system | Format: HH:MM:SS; colour: dim (#8a8f7a) |

### Token gaps
- `#2a1f1f` (danger fill): still not tokenised; now appears on SCR-11, SCR-12, SCR-13, SCR-14, SCR-16.
- Scrim-less overlay pattern for Pause is not documented as a design system primitive.

### Reused from prior screens
- Type dot (lime/cyan/muted) + TypeLabel from SCR-09/10/15
- Disabled button style (card-alt/dim/border) from SCR-13
- PausePanel border-radius 18px from SCR-14 dialog
- EntryCard pattern (card fill, 1px border, 16px radius) — new 16px radius (prior max was 14px on SCR-15 exercise cards; OQ-2)

---

## 9. Acceptance Criteria Mapping

| AC / FR / EC / NFR | Spec location | Status |
|-------------------|--------------|--------|
| AC-1: SCR-16 opens showing first exercise/set, state = ACTIVE | §3 State A — exercise header, entry card, set dots | ✅ |
| AC-2: Valid set completion advances to next set/exercise | §4 Interactions — Complete Set valid | ✅ |
| AC-3: Skip marks item skipped, excludes from completion logic | §4 Interactions — Skip | ✅ specified; OQ-3 (visual treatment of skipped items) |
| AC-4: Pause → state = PAUSED, timer held locally | §3 State C | ✅ |
| AC-5: Cancel → SCR-18 → discard session (no partial save) | §4 Cancel link; §2 exit points | ✅ |
| AC-6: Finish with ≥1 logged set → save + SCR-19 | §2 state machine (Complete Set last item); §1 completion criterion | ✅ OQ-4 for exact Finish trigger |
| AC-6a: Finish with 0 logged sets → same as Cancel | §5 EC-6; §1 completion criterion | ✅ |
| FR-1: Display first exercise/set on start, state = ACTIVE | §3 State A | ✅ |
| FR-2: Non-positive reps → inline error, block complete | §3 State B; §5 EC-1 | ✅ |
| FR-3: Negative weight → inline error | §3 State B; §5 EC-2 | ✅ |
| FR-4: Negative duration → inline error | §3 State B (TimeBased artboard); §5 EC-3 | ✅ |
| FR-5: Valid complete → advance | §4 Interactions | ✅ |
| FR-6: Skip → mark skipped, exclude from completion | §4 Interactions; OQ-3 | ✅ (visual treatment OQ-3) |
| FR-7: Pause → PAUSED, timer held locally | §3 State C; §4 Interactions | ✅ |
| FR-8: Cancel → SCR-18 | §4 Interactions | ✅ |
| FR-9: Finish (≥1 set) → write to Drift, route SCR-19; Finish (0 sets) → Cancel | §1 completion criterion; §4; §5 EC-6 | ✅ OQ-4 |
| NFR-1: Execution + timer in local in-memory state | §1 App context | ✅ |
| NFR-2: App kill/crash → no completed record | §5 EC-5 | ✅ |
| NFR-3: Previously completed sessions unaffected | §5 EC-5 | ✅ |
| EC-1–EC-3: Inline validation for all three field types | §3 State B | ✅ |
| EC-4: App-backgrounded timer — DEFERRED | §5 EC-9 | ✅ noted as deferred |
| SEC-1: App must be unlocked | Not depicted; app-level gate | ✅ noted as app-level |

---

## 10. Open Questions / Assumptions

| # | Question | Owner | Build-block? | Assumption held |
|---|---------|-------|-------------|----------------|
| OQ-1 | Bodyweight exercise field layout: single full-width Reps field, or a 2-column field-row with the right cell empty/absent? The user story notes bodyweight is a "strict subset of weighted with weight field omitted" — does the layout collapse to 1-column or retain 2-column with an empty right cell? | Design | Minor | Assumption: single-field layout (1-column, full width), same as time-based Duration |
| OQ-2 | Entry card `border-radius:16px` — this is a new value. Prior exercise cards (SCR-15) used 14px; form field borders used 12px; dialog card (SCR-14) used 18px. Is 16px the canonical value for entry/log cards specifically? | Design | No | Assumption: yes, 16px is intentional for interactive entry cards |
| OQ-3 | Skipped sets/exercises — what is the visual treatment? Does the set dot for a skipped set get a distinct colour (e.g. dim, cross-hatched)? Does "Skip" on a set advance to the next set within the same exercise, or skip the entire exercise? | Design / Engineering | **Yes** — affects set-dot design and skip logic | Assumption: skipped set dot = dim (#8a8f7a); Skip on a set advances to the next set within the exercise; Skip on the last set of an exercise advances to the next exercise |
| OQ-4 | Finish trigger: the artboard only shows "Complete Set" as the primary CTA. Is there a separate "Finish Workout" / "Done" button that appears after the last set is completed, or does tapping "Complete Set" on the last set of the last exercise act as the Finish trigger and immediately navigate to SCR-19? | Design / PM | **Yes** — routing and session-completion logic | Assumption: "Complete Set" on the last set of the last exercise (or after last logged item if prior exercises were skipped) acts as the Finish trigger and routes to SCR-19 |
| OQ-5 | OS back gesture / hardware back: should it route to SCR-18 (Cancel confirmation) or pop the route directly? Popping directly would discard the session silently. Routing to SCR-18 is safer. | Engineering / Design | **Yes** — behaviour differs between direct pop and Cancel confirmation | Assumption: OS back = Cancel → SCR-18 |
| OQ-6 | Can the Cancel link be tapped in the Paused state (State C)? The artboard shows `opacity:.5` which visually implies disabled, but opacity alone does not block interaction in Flutter. | Engineering / Design | Minor | Assumption: Cancel is tappable in Paused state at reduced opacity; tapping it routes to SCR-18 same as in State A |
| OQ-7 | Set progress dots at high set counts (e.g. 15+ sets): does the dot row wrap to a second line, truncate with an overflow indicator, or scroll horizontally? | Design | Minor | Assumption: dot row wraps to a second line |
| OQ-8 | No max-width cap on content for large screens / tablets | Design / Engineering | No | Assumption: elements expand to fill; revisit at tablet scope |
| OQ-9 | Validation timing: errors shown on Complete Set tap (on-attempt) and cleared in real-time as the user corrects the field. Is there also blur-time validation (show error when user leaves a field without a valid value)? | Design | Minor | Assumption: on-attempt only; no blur-time validation |
| OQ-10 | "Paused at HH:MM:SS" — is this the elapsed workout time at the moment of pause, or wall-clock time? | PM / Engineering | Minor | Assumption: elapsed workout time (running since Begin Workout was tapped in SCR-15) |

### Explicit assumptions
1. Fields are pre-filled with plan target values when a new set begins (convenience pre-fill, user can override).
2. The Skip button is always visible regardless of whether the item is "applicable" for skipping per the SRS/SDS definition (the user story §10 notes that exact applicability is unspecified; the artboard always shows Skip).
3. The Pause button is always visible and functional (same rationale as Skip).
4. Complete Set CTA is statically labelled "Complete Set" for every set; there is no "Finish Workout" variant label even on the last set.
5. The session's elapsed time begins counting when SCR-16 is entered (Begin Workout tapped on SCR-15).
6. When the workout transitions from one exercise to the next, the progress bar width updates proportionally (e.g. 2 of 5 complete = 40% fill, not 38% as shown in the artboard — the artboard value is illustrative, not exact).
