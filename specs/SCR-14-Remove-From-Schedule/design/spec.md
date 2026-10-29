# Design Specification: SCR-14 — Remove From Schedule Confirmation

**Screen ID**: SCR-14  
**User Story**: US-SCR14  
**Priority**: High · 3 story points  
**Created**: 2026-09-12  
**Artboard reference**: https://claude.ai/code/artifact/90414205-4601-4c88-8926-46c81d29655a  
**Artboards**: Main.dc.html · Loading.dc.html · Error.dc.html

---

## 1. Overview & Goal

SCR-14 is a **modal confirmation dialog** shown over the Weekly Schedule View (SCR-12) when the user initiates removal of a scheduled workout entry. It is not a pushed route — the underlying SCR-12 screen remains visible behind a scrim throughout the entire interaction.

**Problem**: Removing a schedule entry without confirmation is too easy to do accidentally, especially when the edit icon and remove action are on the same row. A confirmation step prevents accidental loss of a recurring schedule assignment.

**User**: Any user with the app unlocked who wants to remove a specific plan from their weekly schedule.

**Goal**: Collect the user's explicit confirmation before writing the deletion to Drift, then return the user to an immediately updated SCR-12.

**Success metric**: User can confirm or cancel the removal from a single modal interaction, with no ambiguity about which entry is being removed and a clear statement that history is unaffected.

**App context**: ForgeApp is fully offline. The remove operation is a local Drift write to the `schedule_entries` table — no network call occurs. The operation removes one `scheduleEntry` record; workout history in the `workout_sessions` table is untouched.

**Key design decision — lime, not red**: Unlike SCR-11 (Delete Plan, which uses a red Remove button because deleting a workout plan is irreversible and high-stakes), SCR-14's Remove button uses **lime** (`#c3f400`). Removing a schedule entry is a low-stakes, easily re-added action — the plan itself is unaffected. This is an intentional design distinction, not an oversight.

---

## 2. User Flow

### Entry points

| Source | Action | Modal context |
|--------|--------|--------------|
| SCR-12 (Weekly Schedule) | Remove icon / action on a plan row | Modal appears over SCR-12; row identified in modal body |
| SCR-13 (Assign/Edit Schedule) | *(indirect)* — not an entry point for SCR-14 | — |

> **OQ-1**: The user story lists SCR-12 and SCR-13 as entry dependencies, but the artboard shows SCR-14 triggered from SCR-12. Confirm whether SCR-14 can also be reached from SCR-13 (e.g., a remove option within the edit modal). *(See §10)*

### State machine

```
[SCR-12: user taps Remove on a schedule row]
  └─ [State A: Remove Confirmation] (modal appears over SCR-12 with scrim)
        ├─ User taps Cancel → dismiss modal → return to SCR-12 (no change)
        ├─ User taps Remove → [State B: Removing (Loading)]
        │       ├─ Drift write succeeds → dismiss modal → SCR-12 (entry gone)
        │       └─ Drift write fails   → [State C: Remove Failure — Retry]
        │               ├─ User taps Retry → [State B: Removing (Loading)] again
        │               └─ User taps Cancel → dismiss modal → SCR-12 (entry still present)
        └─ User taps scrim / system back → dismiss → SCR-12 (no change)
```

### Exit points

| Destination | Trigger |
|-------------|---------|
| SCR-12 (no change) | Cancel tapped in any state |
| SCR-12 (no change) | Scrim tapped in Confirmation or Failure state |
| SCR-12 (no change) | OS back gesture in Confirmation or Failure state |
| SCR-12 (entry removed) | Drift write succeeds after Remove or Retry |

---

## 3. Screen-by-Screen Breakdown

### Shared structure — all states

SCR-14 is rendered as a **modal overlay** on top of SCR-12. The underlying SCR-12 content (app bar "Schedule" 22px/800, weekly schedule rows) remains visible but is obscured by the scrim.

**Scrim**:  
`position:absolute; inset:0; background:rgba(10,10,10,0.62); display:flex; align-items:center; justify-content:center; padding:0 30px`

**Dialog card** (330px wide = 390px screen − 60px total padding):  
`width:100%; background:#201f22; border:1px solid #444933; border-radius:18px; padding:24px 20px; display:flex; flex-direction:column; align-items:center; text-align:center; gap:10px`

**Dialog icon** (same across all states):  
`width:36px; height:36px; color:#c4c9ac (muted); stroke-width:1.6; margin-bottom:2px`  
Shape: Calendar with a downward-arrow chevron (schedule removal metaphor) — not a warning triangle, not an X; icon color is muted, not danger.

**Dialog title** (same across all states):  
"Remove from schedule?" · `font-size:16px; font-weight:800; color:#f5f6f1`

**Dialog sub-text** (same across all states):  
`"[Plan Name]" will no longer be scheduled on [Day Name]. Your workout history is unaffected.`  
`font-size:13px; color:#c4c9ac; line-height:1.5`  
Example: `"Push Day — Upper Body" will no longer be scheduled on Monday. Your workout history is unaffected.`

---

### 3.1 State A — Remove Confirmation

**Trigger**: User initiates the remove action on a schedule entry in SCR-12.

**Dialog actions** (`display:flex; gap:10px; width:100%; margin-top:10px`):

| Button | CSS | Label |
|--------|-----|-------|
| Cancel (LEFT) | `flex:1; border-radius:10px; padding:12px; font-weight:800; font-size:13px; background:#2a2a2c; color:#f5f6f1; border:1px solid #444933` | "Cancel" |
| Remove (RIGHT) | `flex:1; border-radius:10px; padding:12px; font-weight:800; font-size:13px; background:#c3f400; color:#131315` | "Remove" |

Both buttons at full opacity. No loading indicators. Standard interactive state.

---

### 3.2 State B — Removing (Loading)

**Trigger**: User taps Remove in State A, or Retry in State C.

**Dialog content**: Icon, title, and sub-text remain identical to State A. No content changes.

**Dialog actions** (`margin-top:10px` — unchanged):

| Button | CSS | Content |
|--------|-----|---------|
| Cancel (LEFT) | `flex:1; border-radius:10px; padding:12px; font-weight:800; font-size:13px; background:#2a2a2c; color:#8a8f7a (dim); border:1px solid #444933; opacity:0.5` | "Cancel" (dimmed, non-interactive) |
| Removing (RIGHT) | `flex:1; border-radius:10px; padding:12px; font-weight:800; font-size:13px; background:#c3f400; color:#131315; opacity:0.85; display:flex; align-items:center; justify-content:center; gap:8px` | Spinner + "Removing…" |

**Spinner**:  
`width:15px; height:15px; border-radius:50%; border:2px solid rgba(19,19,21,0.3); border-top-color:#131315; animation:spin 0.8s linear infinite`  
`@keyframes spin { to { transform: rotate(360deg); } }`

**State notes**:
- Cancel button: text changes from `#f5f6f1` (white) in State A to `#8a8f7a` (dim), and `opacity:0.5` — visually non-interactive but remains in the DOM. Engineering must also disable pointer events.
- Remove button: `opacity:0.85` (slightly transparent during animation, not 1.0).
- Spinner is 15×15px (smaller than SCR-11/13 spinners at 18×18px) to fit within the shorter dialog action button.
- Spinner border: `2px` (vs 2.5px in SCR-11/13) consistent with the smaller size.

---

### 3.3 State C — Remove Failure (Retry)

**Trigger**: Drift write fails during the removal operation.

**Dialog content**: Icon, title, and sub-text remain unchanged from States A and B.

**Error block** — inserted between sub-text and actions:

| Element | CSS |
|---------|-----|
| Container | `font-size:12px; color:#ff6b6b; font-weight:600; background:#2a1f1f; border:1px solid #5c3a3a; border-radius:10px; padding:9px 12px; margin-top:4px; width:100%` |
| Text | "Couldn't remove this entry — something went wrong writing to local storage. It's still scheduled." |

**Dialog actions** (`margin-top:8px` — reduced from 10px to accommodate error block):

| Button | CSS | Label |
|--------|-----|-------|
| Cancel (LEFT) | `flex:1; border-radius:10px; padding:12px; font-weight:800; font-size:13px; background:#2a2a2c; color:#f5f6f1; border:1px solid #444933` | "Cancel" (FULLY ACTIVE — white text, no opacity reduction) |
| Retry (RIGHT) | `flex:1; border-radius:10px; padding:12px; font-weight:800; font-size:13px; background:#c3f400; color:#131315` | "Retry" |

**State notes**:
- Cancel is **fully interactive** in the failure state (unlike State B where it is dimmed). The user can always cancel out after a failure.
- Right button label changes from "Remove" (State A) → "Removing…" (State B) → **"Retry"** (State C). Styling is identical to the Remove button.
- `margin-top` on actions drops from `10px` to `8px` to absorb vertical space taken by the error block.

**Error block visual distinction** from SCR-13's Invalid Plan banner:

| Property | SCR-14 Error block | SCR-13 Invalid Plan banner |
|----------|--------------------|---------------------------|
| Context | Inside dialog, inline | Inside content area, replaces field |
| Border | `1px solid #5c3a3a` | `1.5px solid #ff6b6b` |
| Border-radius | `10px` | `12px` |
| Padding | `9px 12px` | `13px 14px` |
| Icon | None | Warning triangle 18×18 |
| Font weight | 600 | 700 (bold label) + 400 (sub) |

---

## 4. Interactions & Behavior

| Interaction | Trigger | Outcome |
|-------------|---------|---------|
| Tap scrim (outside dialog) — State A | Tap | Dismiss modal → SCR-12 unchanged |
| Tap scrim — State B (Loading) | Tap | No action — dismissal locked during removal |
| Tap scrim — State C (Failure) | Tap | Dismiss modal → SCR-12 unchanged |
| Tap Cancel — State A | Tap | Dismiss modal → SCR-12 unchanged |
| Tap Cancel — State B (Loading) | Tap (dimmed) | No action — Cancel is non-interactive during removal |
| Tap Cancel — State C (Failure) | Tap | Dismiss modal → SCR-12 unchanged (entry still present) |
| Tap Remove — State A | Tap | Enter State B (Loading) |
| Tap Retry — State C | Tap | Enter State B (Loading) again with same entry context |
| OS back gesture / Android back — State A | Gesture | Dismiss modal → SCR-12 unchanged |
| OS back gesture / Android back — State B | Gesture | Suppressed — cannot dismiss during removal |
| OS back gesture / Android back — State C | Gesture | Dismiss modal → SCR-12 unchanged |

### Transition notes

- **Modal appearance** (State A): animate in from below or fade-in with slight scale. No artboard specifies duration; use platform-standard dialog animation (~250–300ms, ease-out).
- **Confirmation → Loading** (State A → B): button content changes in place (Cancel dims, Remove shows spinner + text). No layout shift to the dialog card itself. The transition is instantaneous (no animation on the button change).
- **Loading → SCR-12** (success): modal dismisses; SCR-12 re-renders without the removed row. Transition: fade-out scrim and dialog, or reverse of appearance animation.
- **Loading → Failure** (State B → C): error block slides/fades into the dialog; actions row adjusts `margin-top`. Alternatively, the block appears immediately (no animation specified by artboard).

### Dismiss behaviour summary

| State | Tap scrim | OS back | Cancel |
|-------|-----------|---------|--------|
| A — Confirmation | ✅ Dismiss | ✅ Dismiss | ✅ Dismiss |
| B — Loading | ❌ Locked | ❌ Locked | ❌ Locked (dimmed) |
| C — Failure | ✅ Dismiss | ✅ Dismiss | ✅ Dismiss |

---

## 5. Edge Cases & Error Handling

| ID | Scenario | Behavior |
|----|----------|----------|
| EC-1 | Drift write fails on Remove / Retry | State C: error block appears inside dialog; "Retry" button offered; entry remains in `schedule_entries` |
| EC-2 | User taps outside dialog (scrim) during loading | No action — tap-through to scrim is suppressed during State B |
| EC-3 | OS back during loading | Suppressed — system back intercepted during State B |
| EC-4 | User cancels after failure | Modal dismissed; SCR-12 shows entry still present (as expected — nothing was written) |
| EC-5 | The schedule entry is removed by the time the user retries | Not applicable — ForgeApp is single-user, offline; no external process can remove the same entry concurrently |
| EC-6 | User taps Retry multiple times (if rapid double-tap) | Engineering must debounce the Retry button; second tap during loading must be no-op |
| EC-7 | Plan name is very long | Dialog body wraps within the 330px card width; sub-text uses `line-height:1.5`; no truncation — full plan name must be shown so the user can confirm which entry is being removed |

---

## 6. Responsive & Platform Considerations

**Artboard canvas**: 390×844px (iPhone 14 class). Dialog width = 330px (390 − 60px horizontal padding from scrim).

| Band | Approach |
|------|----------|
| Compact (< 375px) | Dialog shrinks with scrim padding; `width:100%` inside scrim ensures it fills the available width. Buttons `flex:1` keep equal widths. |
| Standard (375–414px) | Matches artboard design |
| Large (> 414px) | Dialog expands with scrim `padding:0 30px`; consider a `max-width` cap (e.g., 360px) to prevent an overly wide dialog on tablets. OQ — see §10 |

**iOS**:
- Modal uses native-feeling dialog animation (sheet-style or standard dialog fade — engineering choice; no artboard animation spec)
- Back swipe (iOS edge pan gesture) must be suppressed during State B
- Dynamic Island / home indicator: modal is vertically centered in the scrim; safe-area padding on the underlying SCR-12 is unchanged

**Android**:
- System back button / gesture: allowed in States A and C (dismisses modal), suppressed in State B
- Predictive back: disable during State B; enable in States A and C

**Orientation**: Portrait-only per ForgeApp convention (schedule view is portrait). No landscape handling required.

---

## 7. Accessibility

### Touch targets

| Element | Rendered size | Meets 44pt? |
|---------|--------------|-------------|
| Cancel button | `flex:1` × 12px padding top/bottom; approx. (330px − 10px gap) / 2 ≈ 160×~41px | ⚠️ Height ~41pt — 3pt below 44pt minimum. Recommend `padding:14px` |
| Remove / Retry button | Same as Cancel | ⚠️ Same issue |
| Scrim dismiss area | Full screen area outside dialog | ✅ |

**Button padding note**: Both buttons use `padding:12px` (top/bottom), resulting in approx. 12 + 13 (font) + 12 = 37px visual height. With line-height and font metrics, rendered height is likely ~40–42pt. Engineering should verify and adjust to 44pt minimum (`padding:14px` would bring it to ~41+font ≈ 44pt).

### Contrast

| Pair | Approx. ratio | Passes AA? |
|------|--------------|------------|
| White `#f5f6f1` on Cancel bg `#2a2a2c` | ~12.4:1 | ✅ |
| Dim `#8a8f7a` on Cancel bg `#2a2a2c` (Loading) | ~2.6:1 | ❌ Fails — but Cancel is intentionally non-interactive; acceptable at `opacity:0.5` as a disabled affordance |
| `#131315` on lime `#c3f400` (Remove/Retry) | ~10.2:1 | ✅ |
| White `#f5f6f1` on dialog bg `#201f22` | ~9.9:1 | ✅ |
| Muted `#c4c9ac` on dialog bg `#201f22` (sub-text) | ~5.9:1 | ✅ |
| Danger `#ff6b6b` on error bg `#2a1f1f` | ~4.2:1 | ⚠️ Borderline — just below 4.5 AA for normal text; carried from SCR-13 |
| White `#f5f6f1` on error bg `#2a1f1f` | ~10.1:1 | ✅ (not used — error text is danger-colored) |

### Screen reader semantics

| Element | Semantic label / behaviour |
|---------|---------------------------|
| Scrim backdrop | `semanticsLabel: "Dialog backdrop. Double-tap to dismiss."` (States A and C only) |
| Dialog container | `role: alertDialog` — announces on appearance |
| Dialog title | "Remove from schedule?" — heading level 2 within dialog |
| Dialog sub-text | Reads as body text; announces the plan name and day being removed |
| Cancel button | "Cancel. Button." / "Cancel. Dimmed." (State B) |
| Remove button | "Remove. Button." |
| Retry button | "Retry. Button." |
| Spinner + "Removing…" | "Removing, please wait." — `liveRegion` so announced when it appears |
| Error block | "Couldn't remove this entry — something went wrong writing to local storage. It's still scheduled." — `liveRegion: true` so announced immediately on State C appearance |

**Focus management**:
- On dialog appearance: focus moves to the dialog container (removes focus from SCR-12)
- Focus order within dialog: title → sub-text → [error block in State C] → Cancel → Remove / Retry
- On dialog dismiss: focus returns to the element on SCR-12 that triggered the modal (the remove icon on the affected row)

---

## 8. Component & Design System Mapping

| Component | Status | Notes |
|-----------|--------|-------|
| Modal scrim (`rgba(10,10,10,0.62)`) | **New shade** | Prior scrims (SCR-11) — confirm `rgba(10,10,10,0.62)` is the standard dialog scrim; it is not `rgba(0,0,0,0.62)` or any prior value |
| Dialog card (18px radius, card fill, 24px/20px padding) | **New shape** | 18px radius is new — previous modals/cards use 12px or 16px. Confirm 18px as the standard for modal dialogs |
| Calendar icon (36×36, muted, stroke-width:1.6) | **New** | Specific to schedule removal context |
| Dialog title (16px/800, centered) | **Reused pattern** | Matches SCR-11 modal title |
| Dialog sub-text (13px, muted, line-height:1.5, centered) | **Reused pattern** | Matches SCR-11 modal body |
| Action row (flex, gap:10px, equal flex:1 buttons) | **Reused pattern** | Same two-button layout as SCR-11; Cancel LEFT / primary RIGHT |
| Cancel button (card-alt, white text, 1px border, 10px radius) | **Reused** | Same as SCR-11 Cancel |
| Primary confirm button (lime, `#131315`, 10px radius) | **New intent** | SCR-11 uses red for Delete; SCR-14 uses lime for Remove — intentional distinction |
| Loading state in right button (spinner + text, opacity reduction) | **Reused pattern** | Similar to SCR-11 Deleting and SCR-13 Saving; spinner 15×15px here vs 18×18px there |
| Cancel dimmed in loading (dim text, `opacity:0.5`) | **Reused pattern** | Same as SCR-11 Deleting; signals locked state |
| Inline error block inside dialog (`#2a1f1f`, `#5c3a3a` border, `10px` radius) | **New** | Error inside the dialog itself — different from SCR-13's banner above content or SCR-12's full error card |

### Token gaps

| Non-token value | Usage | Recommendation |
|-----------------|-------|---------------|
| `rgba(10,10,10,0.62)` (scrim) | Dialog backdrop | Tokenise as `color.scrim` or `color.dialogScrim` — confirm whether `#0a0a0a` (warm near-black) or `#000000` (pure black) is canonical |
| `#2a1f1f` (danger fill) | Error block bg | Token as `color.dangerFill` — now across SCR-11, 12, 13, 14 |
| `#5c3a3a` (danger border) | Error block border | Token as `color.dangerBorder` — now across SCR-09–14 |

---

## 9. Acceptance Criteria Mapping

| AC / FR | Criterion | Covered by state(s) |
|---------|-----------|---------------------|
| AC-1 (FR-1) | Confirmation modal shown when user taps Remove on a scheduled entry | State A — dialog appears with plan name, day, history note |
| AC-2 (NFR-1) | Loading state shown while removal is in progress | State B — Cancel dims, Remove shows spinner + "Removing…" |
| AC-3 (FR-3) | Successful removal routes to SCR-12; entry no longer appears | State B → Drift success → modal dismissed, SCR-12 row removed |
| EC-1 (NFR-2) | Removal failure keeps entry available and provides retry | State C — error block, "Retry" button, Cancel still active, entry untouched |
| SEC-1 | App must be unlocked to access schedule removal | App-level gate (AppLockCubit); no UI in SCR-14 itself |
| SEC-2 | Removal applies only to local device's schedule entries | Engineering constraint — Drift write is device-local; no network |
| FR-2 | Selected scheduled entry is removed on confirmation | State B → Drift write (delete scheduleEntry record) |

---

## 10. Open Questions / Assumptions

| # | Question | Owner | Build-blocking? | Assumption held |
|---|----------|-------|-----------------|----------------|
| OQ-1 | The user story lists SCR-13 as an entry dependency alongside SCR-12. Can SCR-14 be reached from SCR-13 (e.g., a "Remove" option within the edit modal), or is SCR-12 the only trigger? | PM / Design | No | SCR-14 is triggered only from SCR-12; SCR-13 is listed as a dependency because editing a schedule may trigger a remove-and-replace flow, not because SCR-14 is entered from SCR-13's UI |
| OQ-2 | Tapping the scrim in States A and C: should it dismiss the modal? The artboard scrim has `display:flex; align-items:center` but no explicit tap handler is specified. | Design | No | Tapping the scrim (outside the dialog card) dismisses the modal in States A and C, matching standard mobile dialog behavior |
| OQ-3 | The dialog shows "will no longer be scheduled on Monday" for a daily-specific view, but a scheduleEntry can cover multiple days (e.g., M/W/F). If the entry covers multiple days, does removing it remove all days, and how does the sub-text describe this? | PM / Design | **Yes** — copy cannot be implemented without knowing the scope | Assumption: "Remove" removes the entire scheduleEntry (all days in the recurrence). Sub-text would read: `"[Plan Name]" will no longer be in your schedule. Your workout history is unaffected.` — exact wording must be confirmed by PM/Design |
| OQ-4 | Dialog card `border-radius:18px` is new — all prior cards/modals use 12px or 16px. Is 18px the canonical radius for modal dialogs specifically? | Design | No | 18px is intentional for the modal dialog; lower values are for content cards and footer buttons |
| OQ-5 | What animation plays on dialog appearance (enter) and dismissal (exit)? No animation spec is in the artboard. | Design | No | Use platform-standard dialog animation: iOS = fade + scale (0.95 → 1.0, ~250ms, ease-out); Android = Material fade-through (~200ms) |
| OQ-6 | Should there be a `max-width` on the dialog on larger screens (tablets)? The current spec uses `width:100%` inside a scrim with `padding:0 30px`, giving 330px on 390px. On a 768px tablet this would be 708px — likely too wide. | Engineering / Design | No | Recommend `max-width:340px` on the dialog, so it stays compact on larger screens |
| OQ-7 | Data freshness: after successful removal, does SCR-12 re-read Drift immediately on modal dismiss, or does it observe a Drift listenable that fires on the write? | Engineering | **Yes** — modal must not dismiss until SCR-12 is ready to show the updated state | Same answer as SCR-12 OQ-4 and SCR-13 OQ-4; SCR-12 must reflect the change immediately |

### Explicit assumptions

1. **Scrim blocks SCR-12 interaction**: While the modal is open, all taps on SCR-12 rows / buttons are blocked by the scrim. Only the dialog card is interactive.
2. **Entry context**: The modal receives the `scheduleEntry` (plan name + days) as context from SCR-12 at the moment the remove action is triggered. It does not re-read Drift on open.
3. **Full-entry removal**: Tapping Remove deletes the entire `scheduleEntry` record — all days in that entry's recurrence. It does not remove just the selected day.
4. **No undo**: There is no undo/undo toast after successful removal. The user must re-assign via SCR-13 if they change their mind.
5. **Single-user, offline**: No concurrent modification of `schedule_entries` is possible. The entry present when Remove was tapped will still be there on Retry if State C occurs.
