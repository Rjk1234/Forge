# Design Specification: Delete Workout Plan Confirmation (SCR-11)

**Story**: US-SCR11 — Delete Workout Plan Confirmation  
**Version**: 1.0  
**Date**: 2026-09-12  
**Design reference**: https://claude.ai/code/artifact/068a136f-13f2-46a9-90b2-17153985d5f3  
**Artboards**: `Main.dc.html` (Delete Confirmation), `Loading.dc.html` (Deleting), `Error.dc.html` (Delete Failure — Retry)  
**Status**: Draft — 7 open questions flagged (see §10)

---

## §1 Overview & Goal

### Problem

Deleting a workout plan is irreversible: the plan and all its schedule assignments are permanently removed from Drift. Before the deletion executes, the user must explicitly confirm their intent and be informed of exactly what will and will not be affected — specifically that historical workout sessions are preserved. A silent delete or a delete triggered by a single accidental tap would be a data-loss risk.

### Goal

Present a focused, three-state confirmation dialog that:

1. Names the plan being deleted and clearly states what is removed (plan + schedule assignments) and what is preserved (historical sessions).
2. Provides a visually distinct **destructive button** (red fill, not lime) so the delete action is immediately recognizable as irreversible.
3. Shows a loading state while the Drift write is in flight, with the Cancel button disabled to prevent an ambiguous mid-delete cancel.
4. Shows an error state with a retry path if the Drift write fails, confirming that nothing was removed.

### UI pattern

SCR-11 is **a modal dialog**, not a pushed route. It is presented as an overlay (full-screen scrim + centred card) on top of the SCR-10 Plan Detail background. The background remains visible but is non-interactive while the dialog is open.

### Business context

ForgeApp is fully offline. Deletion is a local Drift write — there is no network condition. The only failure mode is a local storage error (EC-1 / OQ-4 in §10).

Per FR-4/SEC-2: historical `workout_sessions` rows that reference the deleted `planId` are **not** touched by the deletion.

### Success metric

A user who intentionally taps Delete successfully completes the flow (plan removed, lands on SCR-08) with no ambiguity about what was deleted and no loss of session history.

---

## §2 User Flow

### Entry points

| From | Trigger |
|------|---------|
| SCR-10 Plan Detail | Tap the Delete icon button (trash, danger red SVG) in the app bar |

### Dialog state machine

```
SCR-10 (Delete icon tap)
        │
        ▼
[Confirmation dialog — Main.dc.html]
        │                      │
    Cancel                   Delete
        │                      │
        ▼                      ▼
  Dismiss dialog       [Deleting — Loading.dc.html]
  return to SCR-10            │                │
                           Success           Failure
                              │                │
                              ▼                ▼
                         Dismiss dialog  [Delete Failure — Error.dc.html]
                         Navigate to           │              │
                         SCR-08             Cancel          Retry
                                              │              │
                                              ▼              ▼
                                         Dismiss dialog  [Deleting — Loading.dc.html]
                                         return to           (loop)
                                         SCR-10
```

### Exit points

| Destination | Trigger | Plan state |
|------------|---------|-----------|
| SCR-10 (return) | Cancel (Confirmation state) | Unchanged |
| SCR-10 (return) | Cancel (Delete Failure state) | Unchanged |
| SCR-08 (Plans List) | Successful deletion | Plan removed from Drift |

---

## §3 Screen-by-Screen Breakdown

### 3.0 Persistent background

The SCR-10 Plan Detail screen remains visible behind the scrim in all three dialog states. The scrim covers it completely:
- `position:absolute; inset:0; background:rgba(10,10,10,.62)`

The background layout (app bar with back chevron, plan title block, exercise cards) is unchanged. It is **not interactive** while the dialog is open — all taps are intercepted by the scrim / dialog.

---

### 3.1 Confirmation State (`Main.dc.html`)

**Artboard**: `Main.dc.html`

#### Scrim

`position:absolute; inset:0; background:rgba(10,10,10,.62); display:flex; align-items:center; justify-content:center; padding:0 30px`

The dialog is horizontally centred with 30 px of horizontal margin on each side, giving a maximum dialog width of 330 px on the 390 px baseline device.

#### Dialog card

```
background: var(--card)        → #201f22
border: 1px solid var(--border) → #444933
border-radius: 18px
padding: 24px 20px
display: flex; flex-direction: column; align-items: center
text-align: center
gap: 10px
```

#### Dialog contents (top to bottom)

| Element | Spec |
|---------|------|
| **Icon** | `width:36px; height:36px; color:var(--danger)` (#ff6b6b); trash-bin SVG, `stroke-width:1.6`; `margin-bottom:2px` |
| **Title** | `font-size:16px; font-weight:800; color:var(--white)` — **"Delete this workout plan?"** |
| **Subtitle** | `font-size:13px; color:var(--muted); line-height:1.5` — **""{Plan Name}" and its schedule assignments will be removed. Past workout sessions using this plan are unaffected."** — plan name is quoted and dynamically inserted |

#### Action row

`display:flex; gap:10px; width:100%; margin-top:10px`

| Button | Spec | Label |
|--------|------|-------|
| Cancel (left) | `flex:1; border-radius:10px; padding:12px; font-weight:800; font-size:13px; background:var(--card-alt); color:var(--white); border:1px solid var(--border)` | "Cancel" |
| Delete (right) | `flex:1; border-radius:10px; padding:12px; font-weight:800; font-size:13px; background:var(--danger); color:#2a1414` | "Delete" |

> **Critical design intent**: The Delete button uses **danger red fill** (`#ff6b6b`) with a very-dark near-black text (`#2a1414`). This is the only place in ForgeApp where a primary CTA uses red — all other primary actions use lime. The red fill signals an irreversible destructive action. The Cancel button is left; Delete is right (see §10 OQ-1 for the inconsistency with SCR-09 Discard dialog).

---

### 3.2 Deleting — Loading State (`Loading.dc.html`)

**Artboard**: `Loading.dc.html`

All dialog chrome, icon, title, and subtitle are identical to the Confirmation state. The only changes are in the action row.

#### Action row (loading)

`display:flex; gap:10px; width:100%; margin-top:10px`

| Button | Spec | Label |
|--------|------|-------|
| Cancel (left) — **disabled** | Same layout as Confirmation + `opacity:.5; color:var(--dim)` — not interactive | "Cancel" |
| Delete (right) — **in-progress** | `flex:1; border-radius:10px; padding:12px; font-weight:800; font-size:13px; background:var(--danger); color:#2a1414; opacity:.85; display:flex; align-items:center; justify-content:center; gap:8px` | [Spinner] + "Deleting…" |

**Spinner spec**:
```
width: 15px; height: 15px
border-radius: 50%
border: 2px solid rgba(42, 20, 20, .3)
border-top-color: #2a1414
animation: spin .8s linear infinite
@keyframes spin { to { transform: rotate(360deg) } }
```

The spinner renders in `#2a1414` (the text color) against the `#ff6b6b` danger fill — a very dark stroke on a red background.

> **Interaction lock**: During the Deleting state, both buttons are visually non-interactive. Cancel is dimmed to 50% opacity. The Delete button shows 85% opacity with spinner + "Deleting…" text. Neither responds to taps (see §4 for interaction rules).

---

### 3.3 Delete Failure State (`Error.dc.html`)

**Artboard**: `Error.dc.html`

All dialog chrome, icon, title, and subtitle are identical to the Confirmation state. An inline error message is inserted between the subtitle and the action row, and the actions change.

#### Inline error message

Inserted after `.dialog-sub`, before `.dialog-actions`:

```
font-size: 12px
font-weight: 600
color: var(--danger)             → #ff6b6b
background: #2a1f1f              ← non-token; same as SCR-09 save failure banner
border: 1px solid #5c3a3a        ← non-token; same as SCR-09/10 error border
border-radius: 10px
padding: 9px 12px
margin-top: 4px
width: 100%
```

**Error message text**: **"Couldn't delete the plan — something went wrong writing to local storage. Nothing was removed."**

#### Action row (error)

`display:flex; gap:10px; width:100%; margin-top:8px` — note `margin-top` reduced to 8px (from 10px in Confirmation) to account for the error message's margin-top:4px.

| Button | Spec | Label |
|--------|------|-------|
| Cancel (left) — **restored** | `flex:1; border-radius:10px; padding:12px; font-weight:800; font-size:13px; background:var(--card-alt); color:var(--white); border:1px solid var(--border)` — fully enabled | "Cancel" |
| Retry (right) | `flex:1; border-radius:10px; padding:12px; font-weight:800; font-size:13px; background:var(--lime); color:#131315` | "Retry" |

> **Design intent**: The Retry button is **lime**, not red — because Retry is a neutral/positive action (try again), not a destructive one. The danger association belongs to the initial Delete decision, which the user has already made. The inline error message is the signal that something went wrong; the Retry button is just "try what you already decided again".

---

## §4 Interactions & Behavior

| # | Element | State | Interaction | Outcome |
|---|---------|-------|-------------|---------|
| I-1 | Cancel button | Confirmation | Tap | Dismiss dialog; return to SCR-10 (plan unchanged) |
| I-2 | Delete button | Confirmation | Tap | Transition to Deleting state; execute Drift delete |
| I-3 | Scrim (outside dialog) | Confirmation | Tap | OQ-2 — likely same as Cancel; see §10 |
| I-4 | Cancel button | Deleting | Tap | No response — button is disabled (opacity:.5) |
| I-5 | Delete/Deleting button | Deleting | Tap | No response — in-progress |
| I-6 | Scrim (outside dialog) | Deleting | Tap | Blocked — deletion in progress, cannot dismiss |
| I-7 | Back gesture / system back | Any | Swipe / hardware back | OQ-3 — see §10 |
| I-8 | Cancel button | Delete Failure | Tap | Dismiss dialog; return to SCR-10 (plan unchanged) |
| I-9 | Retry button | Delete Failure | Tap | Transition to Deleting state; retry Drift delete |
| I-10 | Scrim (outside dialog) | Delete Failure | Tap | OQ-2 |

### Transitions

**Confirmation → Deleting**: Inline within the dialog — the Delete button label and layout swap to spinner + "Deleting…" without a dialog dismiss/re-open. Cancel dims in place.

**Deleting → Delete Failure**: Inline within the dialog — the error message appears below the subtitle, the action row changes (Cancel restored to white, Delete becomes Retry / lime).

**Deleting → Success**: Dialog dismisses (fade or slide up). Navigation pops both the dialog and SCR-10, landing on SCR-08 (Plans List) where the deleted plan no longer appears.

**Delete Failure → Deleting** (Retry): Same as Confirmation → Deleting transition — error message collapses, button changes back to spinner + "Deleting…", Cancel dims.

### Animation

The artboards show static states; transition animation is not specified. Working assumption:
- Dialog appearance: fade in with slight scale-up (standard Flutter `showDialog` transition)
- Button state changes: crossfade / opacity change within the button, no reflow of dialog height
- Error message appearance: likely a fade-in or snap-in (OQ-5)

---

## §5 Edge Cases & Error Handling

| # | Scenario | Handling |
|---|---------|---------|
| EC-1 | Drift delete of the `workout_plans` row for `planId` throws exception | Transition to Delete Failure state; show inline error; plan is unmodified |
| EC-2 | Drift schedule entries deletion succeeds but plan deletion fails | Should be treated atomically; if non-atomic, the plan-missing-but-assignments-present state creates orphaned schedules. OQ-4 — confirm transaction scope |
| EC-3 | Plan not found in Drift when delete is attempted (race condition, already deleted elsewhere) | Should be treated as success — plan is gone, navigate to SCR-08 |
| EC-4 | Very long plan name in subtitle | Subtitle wraps; dialog card grows in height. No truncation shown in artboard. OQ-6 |
| EC-5 | User taps Retry multiple times quickly | Debounce required — only one Drift write should be in flight at a time |
| EC-6 | Back gesture on iOS during Deleting state | OQ-3 — likely blocked; system-level swipe-to-dismiss of the dialog sheet could interrupt the write |
| EC-7 | Screen rotated mid-dialog | ForgeApp does not support landscape; portrait-only assumption holds |
| EC-8 | App backgrounded during Deleting state | Drift write continues in background; on foreground return, dialog shows result state |

---

## §6 Responsive & Platform Considerations

### Device width

The dialog uses `padding:0 30px` on the scrim, giving 30 px side margins on each side.

| Band | Dialog width | Notes |
|------|-------------|-------|
| 390 px (baseline) | 330 px | Artboard spec |
| 375 px (iPhone SE) | 315 px | Slightly narrower; subtitle may reflow by 1 line |
| 414–430 px (larger) | 354–370 px | Wider; more comfortable reading width |
| Tablet (768 px+) | Could use a max-width cap | OQ-7 — no artboard; recommend `max-width:420px` centred |

### iOS

- `showDialog` (or equivalent) presented over the navigation stack; back-swipe from the left edge is normally suppressed for dialogs.
- During Deleting state: the dialog must be non-dismissible (iOS modal behavior — `barrierDismissible: false`).
- During Confirmation and Delete Failure states: OQ-2 (scrim tap) and OQ-3 (back gesture) determine dismissibility.

### Android

- System back button behavior during Confirmation and Delete Failure states: OQ-3.
- During Deleting state: system back must be blocked.

---

## §7 Accessibility

### Touch targets

| Element | Visual size | Pass 44 pt? | Note |
|---------|-------------|-------------|------|
| Cancel button | `flex:1` × `12px padding + 13px text + 12px padding ≈ 37px tall` | ❌ | 7 pt short; needs `minHeight: 44` override |
| Delete button | Same | ❌ | Same; `minHeight: 44` |
| Retry button | Same | ❌ | Same |

### Screen reader

| State | Announcement |
|-------|-------------|
| Dialog opens (Confirmation) | Focus moves to dialog; VoiceOver/TalkBack reads: "Delete this workout plan? Alert. [Plan Name] and its schedule assignments will be removed. Past workout sessions using this plan are unaffected. Cancel, button. Delete, button." |
| Delete icon | Decorative (aria-hidden); title already conveys the action |
| Deleting state | "Cancel, dimmed, button. Deleting…, button." Cancel should announce as unavailable/dimmed |
| Error message appears | Should be announced via live region or by moving focus to the error message |
| Delete Failure state | "Delete this workout plan? Alert. [subtitle]. Couldn't delete the plan — something went wrong writing to local storage. Nothing was removed. Cancel, button. Retry, button." |

### Contrast

| Pair | Values | Approx ratio | Pass AA? |
|------|--------|-------------|---------|
| Dialog title on card | `--white` (#f5f6f1) on `--card` (#201f22) | ~11:1 | ✅ |
| Subtitle on card | `--muted` (#c4c9ac) on `--card` (#201f22) | ~5.5:1 | ✅ |
| Cancel label on card-alt | `--white` on `#2a2a2c` | ~12:1 | ✅ |
| Delete label on danger | `#2a1414` on `#ff6b6b` | ~4.6:1 | ✅ (just passes AA) |
| Retry label on lime | `#131315` on `#c3f400` | ~14:1 | ✅ |
| Error text on error bg | `#ff6b6b` on `#2a1f1f` | ~3.1:1 | ⚠ UI component, not body text; border provides additional context |
| Spinner on danger | `#2a1414` on `#ff6b6b` | ~4.6:1 | ✅ |
| Cancel (dim) on card-alt | `#8a8f7a` on `#2a2a2c` at 50% opacity | ~1.8:1 effective | ⚠ Intentionally low — disabled state communicates unavailability |

### Focus order

Confirmation: [Icon — decorative] → Title → Subtitle → Cancel → Delete  
Delete Failure: [Icon — decorative] → Title → Subtitle → Error message → Cancel → Retry

---

## §8 Component & Design System Mapping

### Pattern reuse from existing specs

| Pattern | Source | SCR-11 usage |
|---------|--------|-------------|
| Modal scrim | SCR-09 Discard dialog | Same: `rgba(10,10,10,.62)` — note 0.62 alpha vs SCR-09's 0.60; difference is small and may be harmonised |
| Dialog card chrome | SCR-09 Discard dialog | Identical: card fill, 1px border, 18px radius, 24px/20px padding, flex column center |
| Dialog button layout (2-button row) | SCR-09 Discard dialog | Same: flex:1 each, gap:10px, 10px radius, 12px padding, 13px/800 |
| Inline error message (pill) | SCR-09 Save Failure banner, SCR-10 error card border | Same non-token values: `#2a1f1f` fill, `#5c3a3a` border; should be extracted as a shared token `color.dangerBg` |
| Spinner | SCR-09 Saving state | Near-identical; SCR-09 uses 18×18px 2.5pt spinner (lime bg, `#131315` active); SCR-11 uses 15×15px 2pt spinner (danger bg, `#2a1414` active) |

### New components

| Component | Type | Purpose |
|-----------|------|---------|
| `DeletePlanDialog` | New widget | Root dialog widget covering all 3 states; driven by `DeletePlanBloc` |
| `DeletePlanBloc` | New Bloc | States: `DeletePlanConfirmation`, `DeletePlanDeleting`, `DeletePlanFailure`; events: `DeletePlanConfirmed`, `DeletePlanRetried`, `DeletePlanCancelled` |
| Destructive button style | Design token addition | Red fill (`#ff6b6b`) + `#2a1414` text — a new button variant; no existing component uses red fill; needs to be formalised as `ButtonStyle.destructive` |
| `InlineDialogError` | New shared widget | 12px/600 danger text, `#2a1f1f` fill, `#5c3a3a` border, 10px radius, 9px/12px padding; also reusable in other confirmation dialogs |

### Token gaps

| Gap | Non-token value | Recommendation |
|-----|----------------|---------------|
| Error background | `#2a1f1f` | Adopt as `color.dangerBg` (same as SCR-09 save-failure banner) |
| Error border | `#5c3a3a` | Already identified as `color.dangerBorder` in SCR-09/10 |
| Delete button text | `#2a1414` | Adopt as `color.onDanger` — text on danger-red fill |
| Spinner border base | `rgba(42,20,20,.3)` | Derived from `#2a1414` at 30% alpha — acceptable as inline |

---

## §9 Acceptance Criteria Mapping

| AC / FR | Description | Covered by |
|---------|-------------|-----------|
| AC-1 / FR-1 | Confirmation modal shown when Delete is tapped; copy explains plan + schedule removal and session preservation | §3.1 — dialog title, subtitle copy confirmed from artboard |
| AC-2 / FR-2 | Loading state on the confirmation action while deletion is processed | §3.2 — spinner + "Deleting…", Cancel disabled |
| AC-3 / FR-3 | On success: navigate to SCR-08; deleted plan no longer in list | §4 I-2 + Deleting → Success transition |
| FR-4 / SEC-2 | Historical sessions not removed | Drift data model constraint; confirmed in subtitle copy ("Past workout sessions using this plan are unaffected") |
| EC-1 | Delete failure: error state shown, plan remains, retry offered | §3.3 — inline error message, Retry button |

---

## §10 Open Questions / Assumptions

| # | Question | Owner | Blocks build? | Working assumption |
|---|---------|-------|--------------|-------------------|
| OQ-1 | **Button order inconsistency**: SCR-11 has Cancel (left) / Delete (right); SCR-09 Discard has Discard (left, destructive) / Keep Editing (right, safe). These are reversed. Which is the intended convention for ForgeApp? | Design | No (both work; pick one) | SCR-11 follows iOS standard (destructive right); SCR-09 intentionally inverted. Document as a design exception for SCR-09, not a systemic reversal |
| OQ-2 | Scrim tap behaviour: in Confirmation and Delete Failure states, does tapping outside the dialog dismiss it (same as Cancel)? | Design / PM | No | Yes — scrim tap = Cancel in both non-loading states; blocked in Deleting state |
| OQ-3 | Back gesture / system back during Deleting state: is it blocked? On iOS, `showDialog` suppresses the left-edge swipe. On Android, the system back event should be intercepted and no-op'd during Deleting | Engineering | No | Block all back navigation during Deleting state; allow during Confirmation and Delete Failure (treated as Cancel) |
| OQ-4 | Drift transaction scope: does the delete operation remove the `workout_plans` row AND all `schedule_entries` for that `planId` atomically? If not atomic, a partial failure creates orphaned schedule entries | Engineering | **Yes** — data integrity | Assume atomic (single Drift transaction or sequential writes that both succeed/fail together) |
| OQ-5 | Error message animation: does the inline error message in the Delete Failure state appear with a fade-in, slide-down, or snap? No artboard shows the transition | Design | No | Fade-in over 150–200 ms |
| OQ-6 | Plan name in subtitle: what happens if the plan name is very long (e.g. 80+ chars)? The subtitle wraps freely in the artboard. Is there a max character limit or truncation rule? | Design | No | Allow wrap; no truncation. Dialog grows vertically. Consistent with SCR-09 discard dialog (no truncation on plan name) |
| OQ-7 | Tablet layout: the artboard is phone-only. On tablet widths (768 px+), should the dialog have a `max-width` cap, or grow to fill the 30 px margins? | Design | No | Recommend `max-width: 420px` centred for tablets |

### Assumptions already made

- **A-1**: SCR-11 is presented as a `showDialog` / Flutter `AlertDialog`-equivalent, not as a pushed route. This means it does not appear in the navigation history and the back gesture cannot pop it without explicit handling.
- **A-2**: On successful deletion, the dialog dismisses and the navigator pops SCR-10, landing on SCR-08 — SCR-10 is not shown again. SCR-10 is not retained in the stack with a stale plan.
- **A-3**: `#2a1f1f` (error bg) and `#5c3a3a` (error border) are the same non-token values used in SCR-09 save failure and SCR-10 error card. They will be formally tokenised as `color.dangerBg` and `color.dangerBorder`.
- **A-4**: The Retry button is lime, not danger red, because the retry decision was already made at the initial Delete tap. Retry is a safe/neutral action. This is confirmed by the artboard.
- **A-5**: The Delete button text color `#2a1414` is a very dark desaturated red — not white and not black. It provides ~4.6:1 contrast on `#ff6b6b`, just passing AA. It should be tokenised as `color.onDanger`.
