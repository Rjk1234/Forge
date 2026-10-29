# Design Specification: SCR-13 — Assign / Edit Schedule

**Screen ID**: SCR-13  
**User Story**: US-SCR13  
**Priority**: High · 3 story points  
**Created**: 2026-09-12  
**Artboard reference**: https://claude.ai/code/artifact/6f1d9550-c79a-4ae8-a2de-f8f45d9f362a  
**Artboards**: Main.dc.html · EditMode.dc.html · ConflictError.dc.html · InvalidPlan.dc.html · SavingLoading.dc.html · SaveFailure.dc.html

---

## 1. Overview & Goal

SCR-13 is a pushed route that lets a user assign a workout plan to one or more days of the week (**New Schedule**) or modify an existing weekly schedule assignment (**Edit Schedule**). It is the only screen in ForgeApp where `schedule_entries` records are created or modified.

**User**: Anyone who wants to establish or adjust when a workout plan repeats during the week.

**Goal**: Complete a valid day selection, write the schedule entry to Drift, and return the user to SCR-12 with an accurate, up-to-date view of their week.

**Success metric**: User can assign a plan to at least one conflict-free day and be returned to SCR-12 with the updated schedule reflected immediately.

**App context**: ForgeApp is fully offline. All data lives in Drift. The save operation is a local Drift write to the `schedule_entries` table. No network calls occur. The bottom nav bar is **not** visible on this screen — it is a full pushed route.

---

## 2. User Flow

### Entry points

| Source | Mode | Pre-fill |
|--------|------|---------|
| SCR-10 (Plan Detail) → Schedule action | New | Plan pre-selected from context; days all blank |
| SCR-12 (Weekly Schedule) → edit icon on a plan row | Edit | Plan + days pre-filled from scheduleEntry |
| SCR-12 (Weekly Schedule) → "Schedule a plan" CTA (empty state) | New | Plan pre-selected (most recent / picker); days all blank |

### State machine

```
[Entry]
  └─ mode = New or Edit?
        ├─ New  → [A: New Schedule] (blank chips, Save disabled)
        └─ Edit → is plan still valid?
                    ├─ Yes → [B: Edit Schedule] (chips pre-filled, Save enabled)
                    └─ No  → [D: Invalid Plan]  (banner replaces selector, chips dimmed, Save disabled)

[A: New Schedule] / [B: Edit Schedule]
  ├─ Tap unselected chip
  │     ├─ no conflict → chip selected (lime); helper text updates; re-evaluate Save
  │     └─ conflicts existing entry → chip shows conflict style; field error; Save disabled
  ├─ Tap selected chip → chip deselected; helper text updates; re-evaluate Save
  ├─ Tap conflicting chip (to deselect) → chip clears conflict; field error clears if none remain
  ├─ Tap plan selector → opens plan picker (out of scope); on return re-enter [A] or [B]
  └─ Tap Save (enabled)
          └─ [E: Saving]
                  ├─ Drift write succeeds → pop to SCR-12
                  └─ Drift write fails    → [F: Save Failure]

[D: Invalid Plan]
  └─ Tap plan banner → opens plan picker; on valid selection → [A: New Schedule] with new plan

[F: Save Failure]
  └─ Tap "Retry Save" → [E: Saving] (same form values)

[Any state, any time]
  └─ Tap back icon (when not saving) → pop to SCR-12; no write occurs
```

### Exit points

| Destination | Trigger |
|-------------|---------|
| SCR-12 (no change) | Back tapped |
| SCR-12 (updated) | Drift write succeeds |

---

## 3. Screen-by-Screen Breakdown

### Shared layout

**Status bar**: 28px placeholder (`flex:0 0 auto`).

**App bar**: `display:flex; align-items:center; gap:14px; padding:6px 20px 14px; flex:0 0 auto`  
Back icon: `width:20px; height:20px; stroke-width:2`  
Title: `font-size:17px; font-weight:800; letter-spacing:.02em`

**Content area**: `flex:1 1 auto; padding:0 20px 16px; display:flex; flex-direction:column; gap:20px`

**Field label style** (all three section labels):  
`font-size:11px; font-weight:700; text-transform:uppercase; color:#8a8f7a; letter-spacing:.08em; margin-bottom:8px`

**Footer**: `flex:0 0 auto; border-top:1px solid #444933; padding:14px 20px 20px`

---

### 3.1 State A — New Schedule (Blank)

**Trigger**: Entered from SCR-10 or SCR-12 empty-state CTA.

**App bar**:

| Element | Value |
|---------|-------|
| Back icon | `color:#f5f6f1` (white) |
| Title | "New Schedule" · `#f5f6f1` |

**Content**:

**WORKOUT PLAN field**

| Element | CSS |
|---------|-----|
| Selector card | `background:#201f22; border:1px solid #444933; border-radius:12px; padding:13px 14px; display:flex; align-items:center; justify-content:space-between` |
| Plan name | `font-size:15px; font-weight:700; color:#f5f6f1` |
| Chevron | `width:16px; height:16px; color:#8a8f7a; stroke-width:2` |

**DAYS field**

| Element | CSS |
|---------|-----|
| Chip row | `display:flex; gap:8px; justify-content:space-between` |
| Each chip (7 — M T W T F S S) | `flex:1; aspect-ratio:1; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:13px; font-weight:800` |
| Chip — unselected | `background:#201f22; border:1px solid #444933; color:#c4c9ac` |
| Helper text | "Select at least one day to schedule this plan." · `font-size:12px; color:#8a8f7a; margin-top:8px` |

**RECURRENCE field**

| Element | CSS |
|---------|-----|
| Row card | `background:#201f22; border:1px solid #444933; border-radius:12px; padding:13px 14px; display:flex; align-items:center; justify-content:space-between` |
| Primary text | "Repeats weekly" · `font-size:14px; font-weight:700; color:#f5f6f1` |
| Sub text | "Only weekly recurrence is supported" · `font-size:11px; color:#8a8f7a` |
| Toggle | `width:40px; height:22px; border-radius:12px; background:#c3f400; opacity:0.5` (locked — dimmed to signal non-interactivity in New state) |
| Toggle knob | `position:absolute; top:2px; right:2px; width:18px; height:18px; border-radius:50%; background:#131315` (knob at right = ON) |

**Footer — Save button (DISABLED)**:

| Element | Value |
|---------|-------|
| Background | `#2a2a2c` (card-alt) |
| Text | `#8a8f7a` (dim) |
| Label | "Save Schedule" |
| Font | `weight:800; font-size:15px` |
| Shape | `border-radius:12px; padding:15px; width:100%` |

---

### 3.2 State B — Edit Schedule (Pre-filled)

**Trigger**: Entered from SCR-12 edit icon on a schedule row with a valid plan reference.

**App bar**:

| Element | Value |
|---------|-------|
| Back icon | `color:#f5f6f1` (white) |
| Title | "Edit Schedule" · `#f5f6f1` |

**Differences from State A**:

| Element | State A — New | State B — Edit |
|---------|---------------|----------------|
| App bar title | "New Schedule" | "Edit Schedule" |
| Day chips | All unselected | Pre-filled from `scheduleEntry.days` |
| Helper text | "Select at least one day to schedule this plan." | "Scheduled on [Day name list]." e.g. "Scheduled on Monday, Wednesday, Friday." |
| Recurrence toggle | `opacity:0.5` (dimmed) | `opacity:1.0` (full — reflects established weekly cadence) |
| Save button | Disabled (card-alt/dim) | **Enabled** (lime/dark) |

**Chip — selected state**:

| Element | Value |
|---------|-------|
| Background | `#c3f400` (lime) |
| Border | `1px solid #c3f400` |
| Text | `#131315` |

**Footer — Save button (ENABLED)**:

| Element | Value |
|---------|-------|
| Background | `#c3f400` (lime) |
| Text | `#131315` |
| Label | "Save Schedule" |
| Font | `weight:800; font-size:15px` |
| Shape | `border-radius:12px; padding:15px; width:100%` |

---

### 3.3 State C — Conflict Error

**Trigger**: User taps a day chip whose weekday already has a different plan in `schedule_entries`.

All elements from State A or B are retained; only the affected chip and sub-field area change.

**Chip — conflict state** (new visual state, no prior artboard precedent):

| Element | Value |
|---------|-------|
| Background | `#2a1f1f` (non-token danger fill) |
| Border | `1px solid #ff6b6b` |
| Text | `#ff6b6b` |

**Field error** (replaces helper text):

| Element | Value |
|---------|-------|
| Text | `"[Day name] already has "[Conflicting Plan Name]" scheduled. Only one plan per day is allowed."` |
| Style | `font-size:12px; font-weight:600; color:#ff6b6b; margin-top:8px` |
| Example | `Wednesday already has "Pull Day — Back & Biceps" scheduled. Only one plan per day is allowed.` |

**Footer — Save button**: Reverts to **disabled** (card-alt/dim) whenever any conflict chip is present. Returns to enabled when all conflict chips are deselected.

**Tri-state chips**: Each chip independently occupies one of three states — unselected (default), selected (lime), or conflict (red). Multiple chips can show conflict style simultaneously if multiple conflicting days are tapped.

---

### 3.4 State D — Invalid Plan

**Trigger**: A `scheduleEntry` being edited references a plan key that no longer exists in the `workout_plans` table.  
*This state is only reachable in Edit mode — a newly selected plan is always valid at the moment of selection.*

**App bar**: "Edit Schedule" (Edit context only).

**WORKOUT PLAN field** — plan selector **replaced** by warning banner:

| Element | CSS |
|---------|-----|
| Banner container | `background:#2a1f1f; border:1.5px solid #ff6b6b; border-radius:12px; padding:13px 14px; display:flex; align-items:flex-start; gap:10px` |
| Warning icon | `width:18px; height:18px; color:#ff6b6b; stroke-width:1.8; flex:0 0 auto; margin-top:1px` — warning triangle |
| Bold line | "This plan is no longer available" · `color:#f5f6f1; font-size:13px; display:block; margin-bottom:2px` |
| Sub line | "It may have been deleted. Choose a different plan to schedule." · `color:#c4c9ac; font-size:12px; line-height:1.4` |

**DAYS field** — dimmed:

| Element | CSS |
|---------|-----|
| Day row | `opacity:0.4; pointer-events:none` |
| All chips | Unselected appearance — any prior selection is hidden/cleared |
| Helper text | Not shown |

**RECURRENCE field**: Not shown in this state (no valid plan to configure recurrence for).

**Footer — Save button**: Disabled (card-alt/dim).

**Recovery path**: Tapping the banner area opens the plan picker. On valid plan selection, screen transitions to State A (New Schedule — treated as new assignment for the new plan).

> **OQ-2**: The plan banner has no chevron affordance. Confirm that the entire banner area is the tap target for re-selection, and whether a chevron should be added for clarity. *(See §10)*

---

### 3.5 State E — Saving (Loading)

**Trigger**: User taps enabled Save / Retry Save button.

**App bar** — dimmed to signal locked navigation:

| Element | CSS |
|---------|-----|
| Back icon | `color:#8a8f7a` (dim) |
| Title | `color:#8a8f7a` (dim) |

**Content area**: `opacity:0.45; pointer-events:none` — full form is dimmed and non-interactive. Previous chip selection and plan name remain visually present.

**Footer — Save button (Saving)**:

| Element | CSS |
|---------|-----|
| Background | `#c3f400` (lime — maintained during save) |
| Text color | `#131315` |
| Layout | `display:flex; align-items:center; justify-content:center; gap:10px` |
| Spinner | `width:18px; height:18px; border-radius:50%; border:2.5px solid rgba(19,19,21,0.25); border-top-color:#131315; animation:spin 0.8s linear infinite` |
| Label text | "Saving…" |
| Padding | `14px` (1px less than enabled button's 15px) |

**`@keyframes spin`**: `to { transform: rotate(360deg); }`

---

### 3.6 State F — Save Failure

**Trigger**: Drift write fails during the save operation.

**App bar**: Normal — white icon and title (back navigation restored).

**Error banner** — positioned between the app bar and the content area, **outside** the `.content` div:

| Element | CSS |
|---------|-----|
| Container | `margin:0 20px 12px; background:#2a1f1f; border:1px solid #5c3a3a; border-radius:12px; padding:12px 14px; display:flex; align-items:flex-start; gap:10px` |
| Warning icon | `width:18px; height:18px; color:#ff6b6b; stroke-width:1.8; flex:0 0 auto; margin-top:1px` |
| Bold line | "Couldn't save your schedule" · `color:#f5f6f1; font-size:13px; display:block; margin-bottom:2px` |
| Sub line | "Something went wrong writing to local storage. Nothing was changed — tap Retry to try again." · `color:#c4c9ac; font-size:12px; line-height:1.4` |

**Content**: Remains fully visible and interactive. Form values (plan name, day selection) are retained exactly as the user left them.

**Footer — Retry Save button**:

| Element | Value |
|---------|-------|
| Class | `.retry-btn` (distinct from `.save-btn`) |
| Background | `#c3f400` (lime) |
| Text | `#131315` |
| Label | **"Retry Save"** |
| Font | `weight:800; font-size:15px` |
| Shape | `border-radius:12px; padding:15px; width:100%` |

**Banner placement distinction** — Save Failure vs Invalid Plan:

| Property | State D — Invalid Plan | State F — Save Failure |
|----------|----------------------|----------------------|
| Position | Inside `.content` (replaces plan field) | Above `.content` (top of screen) |
| Border | `1.5px solid #ff6b6b` | `1px solid #5c3a3a` |
| Padding | `13px 14px` | `12px 14px` |
| Margin | None (standard content gap) | `0 20px 12px` |

---

## 4. Interactions & Behavior

| Interaction | Trigger | Outcome |
|-------------|---------|---------|
| Tap unselected chip (no conflict) | Tap | Chip → selected (lime); helper text updates to list selected days; re-evaluate Save enable |
| Tap unselected chip (conflict) | Tap | Chip → conflict (red); field error shows conflicting plan name; Save → disabled |
| Tap selected chip | Tap | Chip → unselected; helper text updates; re-evaluate Save enable |
| Tap conflict chip | Tap | Chip → unselected; if no remaining conflicts, field error clears; re-evaluate Save |
| Tap plan selector | Tap anywhere on card | Opens plan picker route (out of scope); on return, re-enter form with new plan |
| Tap Invalid Plan banner | Tap anywhere on banner | Opens plan picker; on valid selection → New Schedule state with new plan |
| Tap Recurrence toggle | Tap | No action — toggle is non-interactive in all states |
| Tap Save (enabled) | Tap | Enters Saving state — app bar dims, content dims, spinner appears |
| Tap Retry Save | Tap | Enters Saving state with same form values |
| Tap back (not saving) | Tap back icon or OS back gesture | Pop to SCR-12; no Drift write; no data changed |
| Tap back (saving) | Tap dimmed back icon | No action — navigation locked during save |
| OS back gesture (saving) | Swipe-from-edge / Android back | Intercepted and suppressed during save |

### Save button enable logic

| Condition | Save button state |
|-----------|-----------------|
| ≥1 chip selected AND no conflict chips AND plan is valid | **Enabled** (lime / `#131315`) |
| 0 chips selected | Disabled |
| ≥1 conflict chip present | Disabled |
| Plan is invalid (State D) | Disabled |

### Helper text logic (below day chips)

| Condition | Text |
|-----------|------|
| New state, no days selected | "Select at least one day to schedule this plan." |
| ≥1 day selected, no conflicts | "Scheduled on [Day name list]." |
| ≥1 conflict chip present | Replaced by field error (danger text) |

### State transition table

| From | To | Trigger |
|------|----|---------|
| State A (New) | State E (Saving) | Save tapped |
| State B (Edit) | State E (Saving) | Save tapped |
| State E (Saving) | SCR-12 | Drift write success |
| State E (Saving) | State F (Save Failure) | Drift write failure |
| State F (Save Failure) | State E (Saving) | Retry Save tapped |
| State D (Invalid Plan) | State A (New, new plan) | Valid plan selected via picker |
| Any | SCR-12 (no change) | Back tapped (not during save) |

---

## 5. Edge Cases & Error Handling

| ID | Scenario | Behavior |
|----|----------|----------|
| EC-1 | Plan referenced by edited scheduleEntry was deleted from workout_plans | State D: plan selector replaced by warning banner; days dimmed; Save disabled |
| EC-2 | User taps a day already assigned to a different plan | State C: chip turns red; field error names the conflicting plan; Save disabled |
| EC-3 | Multiple conflicting days tapped | All conflict chips show red simultaneously; field error naming is per OQ-1 (see §10) |
| EC-4 | Drift write fails on save | State F: error banner above form; form values retained; "Retry Save" offered |
| EC-5 | User taps back during save | No action — back icon dimmed, OS gesture suppressed |
| EC-6 | User taps back after Save Failure | Pop to SCR-12; no write occurred; SCR-12 shows unchanged schedule |
| EC-7 | All previously selected days are deselected in Edit mode | Save button disables; helper text reverts to "Select at least one day…" |
| EC-8 | User changes plan via picker to one whose days conflict with existing entries | Conflict chips appear for the new plan's inherited day selection; field error shows; Save disabled until resolved |
| EC-9 | Own days in Edit mode | User's existing scheduleEntry days are excluded from conflict detection — selecting a day the same scheduleEntry already owns is not treated as a conflict |

---

## 6. Responsive & Platform Considerations

**Artboard canvas**: 390×844px (iPhone 14 class).

| Band | Approach |
|------|----------|
| Compact (< 375px) | Day chip row uses `flex:1` — chips compress proportionally; `aspect-ratio:1` keeps chips square; monitor minimum touch target (see §7) |
| Standard (375–414px) | Matches artboard design |
| Large (> 414px) | `padding:0 20px 16px` provides lateral breathing room; chips expand with `flex:1`; no horizontal scroll |

**iOS**:
- Status bar 28px placeholder; devices with Dynamic Island / home indicator require `SafeArea` bottom padding in the footer.
- Back swipe (iOS edge pan gesture) must be disabled during State E (Saving) — override `WillPopScope` / `PopScope` with `canPop: false`.
- Footer `padding-bottom:20px` should integrate with `SafeArea` on notched devices.

**Android**:
- System back button and back swipe must be intercepted during State E; allow in all other states.
- Status bar color: `#131315` (matches background).
- Predictive back animation: disable during save; enable otherwise.

---

## 7. Accessibility

### Touch target audit

| Element | Rendered size | Meets 44pt? |
|---------|--------------|-------------|
| Back icon | 20×20px rendered | ❌ No — 24pt below minimum; extend hit area to 44×44pt |
| Day chips (390px screen) | `(390 - 40px padding - 48px gaps) / 7 ≈ 43.1px` | ⚠️ Borderline — fails on screens < ~395px; recommend 44pt minimum hit area |
| Plan selector card | Full width × ~44px | ✅ |
| Recurrence row | Full width × ~48px | ✅ |
| Save / Retry Save button | Full width × ~50px | ✅ |
| Invalid Plan banner tap area | Full-width × ~66px | ✅ |

**Day chip minimum**: On a 375px device: `(375 - 40 - 48) / 7 ≈ 41pt`. Engineering must extend tap area beyond visual bounds (e.g., negative margin or `HitTestBehavior.translucent` wrapper).

### Contrast

| Pair | Token names | Approx. ratio | AA pass? |
|------|-------------|--------------|----------|
| White `#f5f6f1` on bg `#131315` | white on bg | ~15.6:1 | ✅ |
| Lime `#c3f400` on bg `#131315` | lime on bg | ~10.2:1 | ✅ |
| `#131315` on lime `#c3f400` (Save button) | bg on lime | ~10.2:1 | ✅ |
| Muted `#c4c9ac` on card `#201f22` | muted on card | ~5.9:1 | ✅ |
| Dim `#8a8f7a` on card `#201f22` (sub text) | dim on card | ~3.2:1 | ❌ Fails AA (4.5 threshold for normal text) |
| Dim `#8a8f7a` on bg `#131315` (helper text) | dim on bg | ~4.0:1 | ❌ Fails AA |
| Danger `#ff6b6b` on `#2a1f1f` (conflict chip) | danger on danger-fill | ~4.2:1 | ⚠️ Borderline — just below 4.5 AA |
| White `#f5f6f1` on `#2a1f1f` (banner bold) | white on danger-fill | ~10.1:1 | ✅ |
| Muted `#c4c9ac` on `#2a1f1f` (banner sub) | muted on danger-fill | ~4.9:1 | ✅ |

*Dim-on-bg and dim-on-card contrast failures are a design-system-level issue carried across SCR-09 through SCR-13. Helper text and sub-text use dim consistently; flag for design system review rather than this spec alone.*

### Screen reader semantics

| Element | Semantic label / behaviour |
|---------|---------------------------|
| Back icon button | Label: "Back" |
| App bar title | `semanticsLabel`: "New Schedule" or "Edit Schedule" |
| Plan selector | "Workout Plan: [Plan Name]. Double-tap to change." |
| Plan banner (State D) | "This plan is no longer available. It may have been deleted. Choose a different plan to schedule. Double-tap to pick a new plan." — removes from group, announces role: button |
| Day chip (unselected) | "[Full day name]. Not selected." e.g. "Monday. Not selected." |
| Day chip (selected) | "[Full day name]. Selected." |
| Day chip (conflict) | "[Full day name]. Unavailable — conflicts with [Plan Name]." |
| Recurrence row | "Repeats weekly. Only weekly recurrence is supported. Toggle locked." — `excludeSemantics: true` for toggle (non-interactive) |
| Save button (disabled) | "Save Schedule. Button. Dimmed." — optionally announce reason via `hint` |
| Save button (enabled) | "Save Schedule. Button." |
| Spinner + "Saving…" | "Saving, please wait." — announced on state change |
| Error banner (State F) | "Couldn't save your schedule. Something went wrong writing to local storage. Nothing was changed — tap Retry to try again." — `liveRegion` / `Semantics(liveRegion: true)` so it is announced on appearance |
| Retry Save button | "Retry Save. Button." |
| Field error text (State C) | "[Day] already has [Plan Name] scheduled. Only one plan per day is allowed." — `liveRegion` so it announces on appearance |

### Focus order

Back → Plan selector → Day chips (M → T → W → T → F → S → S) → Recurrence row (non-interactive, tab-stop only) → Save / Retry Save

---

## 8. Component & Design System Mapping

| Component | Status | Screens |
|-----------|--------|---------|
| App bar with back icon | **Reused** | SCR-09, 10, 11 |
| Field label style (11px/700/uppercase/dim/.08em) | **Reused** | SCR-09 established |
| Plan selector card (card fill, 1px border, 12px radius, 13px/14px padding) | **Reused** | SCR-09 plan card pattern |
| Save button — enabled (lime, full-width, 12px radius, 15px padding) | **Reused** | SCR-09, 11 |
| Save button — disabled (card-alt fill, dim text) | **Reused** | SCR-09 |
| Spinner in button (18×18, 2.5px border, dark top, .8s) | **Reused** | SCR-11 |
| Inline field error (12px/600/danger, margin-top:8px) | **Reused** | Form error pattern |
| Top-of-screen error banner (above content, margin:0 20px 12px, #2a1f1f, #5c3a3a border) | **Reused pattern** | SCR-11 save failure |
| **Day chip — circular** (aspect-ratio:1, 50% radius, 13px/800, flex:1) | **New** | First appearance |
| Day chip — selected state (lime fill + border + `#131315` text) | **New** | First appearance |
| Day chip — conflict state (`#2a1f1f` fill, danger border + text) | **New** | First appearance; new tristate pattern |
| Recurrence locked toggle (40×22px lime, opacity:.5 in New / 1.0 in Edit, knob-right = ON) | **New** | First appearance |
| In-field plan warning banner (replaces selector; `#2a1f1f`, 1.5px danger border, 12px radius) | **New** | First appearance; distinct from top-of-screen banners |
| Helper text below chips (12px/dim, dynamic) | **New variant** | Contextual, changes on selection |
| "Retry Save" button label variant | **New label** | Same visual as enabled Save; label-only difference |

### Token gaps (carried forward)

| Non-token value | Usage | Recommendation |
|-----------------|-------|---------------|
| `#2a1f1f` (danger bg fill) | Conflict chip, plan banner, save failure banner | Token as `color.dangerFill` — used across SCR-11, 12, 13 |
| `#5c3a3a` (danger border) | Save failure banner | Token as `color.dangerBorder` — used across SCR-09–13; five screens without tokenisation |

---

## 9. Acceptance Criteria Mapping

| AC / FR | Criterion | Covered by state(s) |
|---------|-----------|---------------------|
| AC-1 (FR-1) | New state: no days selected, Save disabled | State A |
| AC-2 (FR-2) | Edit state: days pre-filled from scheduleEntry, Save enabled | State B |
| AC-3 (FR-6) | Successful save navigates back to SCR-12 | State E → Drift success → SCR-12 |
| FR-3 | Invalid / unavailable plan blocks Save; banner shown | State D |
| FR-4 | Conflicting day assignment blocked; one plan per day | State C |
| FR-5 | Loading state shown during save | State E |
| FR-7 | Save must not alter workout_sessions history | Engineering constraint — no UI; Drift write is schedule_entries only |
| EC-1 | Invalid plan → banner, dimmed days, Save disabled | State D |
| EC-2 | Conflicting day → red chip + field error + Save disabled | State C |
| EC-3 | Loading state during save | State E |
| EC-4 | Save failure → top banner, form retained, "Retry Save" | State F |

---

## 10. Open Questions / Assumptions

| # | Question | Owner | Build-blocking? | Assumption held |
|---|----------|-------|-----------------|----------------|
| OQ-1 | Multiple conflict chips simultaneously: does the field error show only the first conflict or dynamically update to name each conflicting day as chips are tapped? The artboard shows a single-day conflict example. | Design | No | Field error names the most recently tapped conflict; all conflict chips show red simultaneously |
| OQ-2 | In State D (Invalid Plan), the banner has no chevron affordance. Is the entire banner area the tap target for re-selecting a plan, or does a separate "Choose a plan" button appear? | Design | **Yes** — implementation cannot proceed without knowing the tap target | Assume entire banner is tappable and launches the plan picker, same as the plan selector card |
| OQ-3 | Recurrence toggle opacity: State A uses `opacity:0.5` (dimmed), State B uses `opacity:1.0` (full). Is this intentional — New mode dims the toggle because weekly is not yet meaningful; Edit mode shows it at full because the schedule exists? | Design | No | Intentional; implement as specified |
| OQ-4 | Data freshness on pop back to SCR-12: does SCR-12 re-read Drift on `initState`/resume, or observe a Drift listenable? *(Shared with SCR-12 OQ-4)* | Engineering | **Yes** — SCR-13's core value is writing a schedule that appears immediately on SCR-12 | SCR-12 re-reads Drift on `initState`/`onResume`; schedule update is visible immediately on return |
| OQ-5 | The Saving and Save Failure artboards show "Edit Schedule" in the app bar. In the New Schedule flow, what is the app bar title during Saving / Save Failure states? | Design | No | Title stays as entered ("New Schedule" or "Edit Schedule") throughout all states for that session |
| OQ-6 | The Recurrence section is absent from the Invalid Plan, Saving, and Save Failure artboards. Is this intentional (hidden in those states) or artboard simplification? | Design | No | Artboard simplification; implementation shows all three fields in all states (with appropriate dim/lock as per state rules), except State D where the Recurrence section is hidden because there is no valid plan |
| OQ-7 | Conflict detection for own days in Edit mode: if the user is editing a schedule for Plan A on M/W/F and taps Wednesday (their own day), should it conflict? | Engineering | No | Own days are excluded from conflict detection — the current scheduleEntry's existing days do not self-conflict |
| OQ-8 | FR-7 constraint (save does not alter workout_sessions) — is there any UI feedback of this constraint, or is it purely an engineering invariant? | PM / Engineering | No | Pure engineering invariant; no UI impact on this screen |

### Explicit assumptions

1. **Plan context at entry**: The plan selector always arrives pre-populated with a plan passed from the entry point (SCR-10 or SCR-12). The user cannot open this screen with no plan context.
2. **Day ordering**: Chips always render M T W T F S S (Monday-first), locale-independent.
3. **scheduleEntry model**: One `scheduleEntry` record per plan-to-days assignment. A plan on M/W/F is stored as a single entry with three days, not three separate entries.
4. **Plan picker route**: Tapping the plan selector or Invalid Plan banner opens a separate route (plan picker, not specced here). On return, this screen receives the newly selected plan.
5. **Retry Save**: "Retry Save" re-submits the same form values without re-validating conflict state (conflicts were clear before the first save attempt; the retry assumes no concurrent change to `schedule_entries`).
