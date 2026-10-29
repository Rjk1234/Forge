# Design Specification: SCR-18 — Cancel Active Workout Confirmation

**Story ID**: US-SCR-18  
**Priority**: High  
**Created**: 2026-09-13  
**Artboard reference**: https://claude.ai/code/artifact/f8a48120-7d5c-44cf-9f2f-6e5a8b5d39de  
**Artboards read**: Main.dc.html (1 artboard)  
**Entry point**: SCR-16 (Active Workout — Cancel tapped), SCR-17 (Rest Timer — OS back gesture, if routed here)  
**Exit points**: SCR-16 (Keep Going — user resumes workout), SCR-06 (Discard Workout — session discarded)

---

## §1 — Overview & Goal

**Problem**: When a user taps Cancel during an active workout, there is no affordance to confirm their intent. Without a guard, an accidental tap or OS back gesture could silently discard all logged sets from the current session, with no way to recover. SCR-18 is the confirmation gate that prevents irreversible accidental loss.

**User**: Any user who is mid-workout on SCR-16. They may have tapped Cancel intentionally (wanting to quit) or accidentally (e.g., missed a tap, fat-fingered).

**Goal**: Present a focused, unambiguous confirmation dialog that makes the irreversibility of cancellation explicit, and gives the user a clear way to resume if they tapped Cancel by mistake.

**Success metric**: Zero sessions silently discarded without the user having confirmed intent. Any cancellation path (Cancel button, OS back gesture) must pass through this confirmation.

**App context**: ForgeApp is fully offline. Discarding the session means the in-progress `workoutSession` record is deleted without being written to the `workout_sessions` table as a completed workout. This is permanent and unrecoverable — no trash, no undo.

**Functional requirements (from user story)**:
- FR-1: When the user taps Cancel during an active workout, present a confirmation modal warning that progress will not be saved.
- FR-2: When the user confirms cancellation, discard the active workout session; do not persist it as a completed workout.
- FR-3: After cancellation is confirmed, route the user to SCR-06.

**Decisions Log context**: Per SCR-16 Decisions Log §2 (referenced in US-SCR16): "Cancel always discards, no 'incomplete' state." SCR-18 is the interstitial that enforces this decision — it does not offer a save-as-draft option or partial save.

---

## §2 — User Flow

```
SCR-16 [Cancel tapped]
  │
  ├─── [or OS back gesture intercepted] ──┐
  │                                        │
  ▼                                        ▼
SCR-18 confirmation modal appears over dimmed SCR-16
  │
  ├─ [Keep Going tapped] ──────────────────► SCR-16 (workout resumes; state preserved)
  │
  ├─ [Discard Workout tapped] ─────────────► SCR-06 (session discarded)
  │
  └─ [Modal dismissed via OS back? / tap-outside?] ── See OQ-2
```

**Entry paths**:
1. **Primary**: User taps "Cancel" link in SCR-16 app bar. Modal immediately appears over SCR-16 content.
2. **Secondary (unspecified in story)**: OS back gesture / Android hardware back button — if intercepted and routed here (see OQ-1). This would trigger the same modal.
3. **Via SCR-17 (Rest Timer)**: If the OS back gesture is triggered while SCR-17 Rest Timer is active, the routing must also ultimately reach SCR-18. Whether SCR-17 first dismisses its own overlay before SCR-18 appears is unspecified (see OQ-3).

**State preservation**: When Keep Going is selected, SCR-16 must resume exactly where the user left off — same exercise, same set index, same field values, same exercise progress bar. The modal does not advance workout state.

**No loading states**: There is no async work on this screen. Both taps are instantaneous state transitions.

---

## §3 — Screen-by-Screen Breakdown

### State A — Cancel Confirmation Modal (Only State)

One artboard; one state. The modal appears as an overlay on top of a dimmed SCR-16.

---

#### Shared Layer: SCR-16 Background (dimmed)

| Layer | Property | Value |
|-------|----------|-------|
| App bar (entire row) | `opacity` | `.3` |
| App bar title | `font-size / font-weight / color` | `15px / 800 / var(--dim)` (#8a8f7a) |
| App bar cancel link | `font-size / font-weight / color` | `13px / 700 / var(--dim)` — dim, NOT danger red |
| Progress wrap (entire row) | `opacity` | `.3` |
| Progress fill | `background` | `var(--dim)` (#8a8f7a) — NOT lime |
| Content area | `opacity` | `.2` |
| Content area | `filter` | `grayscale(.4)` |

**Background opacity `.3`** — slightly more aggressive than SCR-17 Rest Timer (`.35`) and SCR-16 Pause (also dim-coloured but app bar was `opacity` not set to a single value). The hierarchy across overlay states:

| Screen | App bar opacity | Scrim fill |
|--------|----------------|-----------|
| SCR-16 Pause | `opacity:.35` (app bar); content `opacity:.35 + grayscale(.4)` | No fill |
| SCR-17 Rest Timer | `opacity:.35` (app bar) | `rgba(10,10,10,.72)` |
| SCR-18 Cancel Confirm | `opacity:.3` (app bar) | `rgba(10,10,10,.62)` |

SCR-18 pushes the background further into the background (opacity `.3` vs `.35`) even though its scrim is less opaque than SCR-17's (`.62` vs `.72`). The net visual suppression is balanced differently.

---

#### Dark Scrim

```
position: absolute
inset: 0
background: rgba(10, 10, 10, .62)
display: flex
align-items: center
justify-content: center
padding: 0 30px
```

`rgba(10,10,10,.62)` — the **standard modal scrim** tier. This matches SCR-11 (Delete Plan Confirm) and SCR-14 (Edit Warning). Three scrim tiers now documented:

| Tier | Value | Screens |
|------|-------|---------|
| Standard modal | `rgba(10,10,10,.62)` | SCR-11, SCR-14, SCR-18 |
| Rest timer | `rgba(10,10,10,.72)` | SCR-17 |
| No fill (content-dim only) | — | SCR-16 Pause |

---

#### Dialog Box

```
width: 100%
background: var(--card)       ← #201f22
border: 1px solid var(--border)   ← #444933
border-radius: 18px
padding: 24px 20px
display: flex
flex-direction: column
align-items: center
text-align: center
gap: 10px
```

`border-radius: 18px` — the confirmed modal/overlay panel radius (also used in SCR-14 dialog and SCR-16 Pause panel). This is distinct from content cards (14px) and entry cards (16px).

`padding: 24px 20px` — asymmetric: 24px top/bottom, 20px left/right. Compare: SCR-16 Pause panel was `26px 22px`. SCR-18's dialog is slightly tighter on all sides.

---

#### Dialog Elements (in DOM order, separated by `gap: 10px`)

---

**1 — Icon wrap**

```
width: 52px
height: 52px
border-radius: 50%
background: #2a1f1f       ← danger fill (7th occurrence in system)
display: flex
align-items: center
justify-content: center
margin-bottom: 2px        ← extra nudge below the icon wrap
```

Note: `52×52` — slightly smaller than SCR-16 Pause panel icon wrap (`56×56`). Both are circular. This 4px difference is subtle; in practice both read as "medium icon circle."

---

**2 — Alert triangle icon**

```
width: 24px
height: 24px
color: var(--danger)   ← #ff6b6b
stroke: currentColor
stroke-width: 1.8
fill: none
```

SVG paths:
- Body triangle: `M10.3 3.9L2.5 18a1.8 1.8 0 0 0 1.6 2.7h15.8a1.8 1.8 0 0 0 1.6-2.7L13.7 3.9a1.8 1.8 0 0 0-3.4 0z`
- Exclamation stem: `M12 9v4`
- Exclamation dot: `cx:12; cy:16.3; r:0.6; fill:currentColor; stroke:none`

This is the **alert triangle** (warning/caution) icon. Compare to SCR-15's alert-circle icon (circle with `!` — used for Invalid Plan state). The triangle is the more severe iconographic choice — universally associated with irreversible or destructive warnings.

---

**3 — Dialog title**

```
font-size: 16px
font-weight: 800
color: var(--white)   ← inherited
```

Copy: **"Cancel this workout?"**

`16px/800` — this is the modal title weight. Matches SCR-14's dialog title size (also `16px/800`). Slightly larger than SCR-16 Pause panel title (`17px/800`) — modal titles are slightly smaller than the pause panel because they are surrounded by body copy and don't need to carry as much visual prominence.

Wait — checking the data: SCR-16 Pause was `17px/800`, SCR-14 dialog was `16px/800`, SCR-18 dialog is `16px/800`. Consistent: destructive confirmation dialogs use `16px/800`.

---

**4 — Dialog subtitle / body copy**

```
font-size: 13px
color: var(--muted)   ← #c4c9ac
line-height: 1.5
```

Copy: **"Your progress on "Push Day — Upper Body" won't be saved. This session won't appear in your workout history."**

The workout plan name ("Push Day — Upper Body") is dynamically interpolated from the active workout session. The copy uses sentence case and plain language. Two sentences: the first states what is lost (progress on this plan), the second clarifies the permanence (won't appear in history).

The quoted plan name uses straight double-quotes in the artboard copy: `"Push Day — Upper Body"`. Implementation should use the active plan's display name exactly as stored in Drift.

---

**5 — Action row**

```
display: flex
gap: 10px
width: 100%
margin-top: 8px       ← extra spacing between body copy and actions (on top of the gap:10px)
```

The `margin-top: 8px` combined with the `gap: 10px` from the dialog flex means total spacing between the subtitle and action row is effectively 18px (gap + margin).

**Keep Going button (secondary)**:
```
flex: 1
border-radius: 10px
padding: 13px
text-align: center
font-weight: 800
font-size: 13px
background: var(--card-alt)   ← #2a2a2c
color: var(--white)
border: 1px solid var(--border)   ← #444933
```

Copy: **"Keep Going"**

**Discard Workout button (destructive primary)**:
```
flex: 1
border-radius: 10px
padding: 13px
text-align: center
font-weight: 800
font-size: 13px
background: var(--danger)   ← #ff6b6b
color: #2a1010             ← NEW — dark red/burgundy text
```

Copy: **"Discard Workout"**

**`#2a1010`** — a new colour in the design system. It is a very dark reddish near-black used as text on the danger-filled button face. It creates a monochromatic "danger red" treatment where both the button fill (`#ff6b6b`) and the text (`#2a1010`) are in the red family. Prior destructive confirming actions in the system used `#131315` (near-black) text on lime buttons. The choice of `#2a1010` instead of `#131315` communicates "this is a danger action" through the button typography itself, not just the fill.

**`border-radius: 10px`** — the **smallest button radius** in the system. Dialog action buttons use 10px; all other full-width and action buttons use 12–16px. This creates a subtle visual distinction: dialog buttons feel more contained and less dominant than full-screen CTAs. Both buttons use the same radius.

**Equal sizing**: Both buttons use `flex:1` — they are exactly the same width. There is no visual size hierarchy between them; the distinction is colour only (secondary card-alt vs destructive danger). This is intentional: the user must choose deliberately, not be nudged by size toward either option.

---

## §4 — Interactions & Behavior

| Trigger | Response | Notes |
|---------|----------|-------|
| User taps "Cancel" in SCR-16 app bar | SCR-18 modal appears immediately over SCR-16 | No loading, no animation specified; assume standard modal fade-in |
| OS back gesture / hardware back while on SCR-16 | Routes to SCR-18 (assumption — see OQ-1) | Must not silently pop the workout |
| "Keep Going" tapped | Modal dismissed; SCR-16 resumes at exact same state | Exercise, set, field values, progress bar all unchanged |
| "Discard Workout" tapped | Session discarded; user routed to SCR-06 | workoutSession record deleted; NOT persisted to `workout_sessions` table |
| Tap outside dialog (on scrim) | Unspecified — see OQ-2 | Assumption: dismisses modal, resumes SCR-16 (same as Keep Going) |
| OS back while modal is open | Unspecified — see OQ-2 | Assumption: treated as "Keep Going" — dismisses modal, resumes SCR-16 |
| Double-tap "Discard Workout" | Should be safe: discard is idempotent | Button should be disabled after first tap to prevent double-fire |

**Drift write on Discard**:
- No `workoutSession` write to `workout_sessions` table.
- In-progress session object is deleted from Drift.
- Any intermediate Drift state (partial set data, etc.) is cleaned up.
- This is irreversible — no undo.

**Transition to SCR-06**:
- After discard, the user is routed to SCR-06. The navigation stack should be cleaned so the user cannot press "back" from SCR-06 and return to a discarded workout state.
- Exact navigation stack manipulation (pop, pushReplacement, etc.) is an engineering decision; the spec requires only that the result is SCR-06 with a clean stack.

---

## §5 — Edge Cases & Error Handling

| Case | Expected behaviour |
|------|-------------------|
| User taps Cancel with 0 sets logged | Modal appears normally; the warning copy is still accurate ("progress won't be saved" — even if no sets were logged, the intent to cancel is still confirmed). Discard confirms; discards the empty session. |
| User taps Cancel after completing all sets but before Finish | Modal appears. If confirmed (Discard), the session is discarded — no workout history entry written. This is an unusual edge case (completing all sets then cancelling) but is valid per the story: "cancel always discards." |
| "Keep Going" tapped while SCR-16 timer was running (e.g., rest timer in SCR-17) | Unexpected path — the Rest Timer overlay should not show Cancel (SCR-18) while SCR-17 is active. Engineering must ensure modal cannot be triggered from SCR-17 directly. If it somehow is, Keep Going should dismiss both SCR-18 and SCR-17 and return to SCR-16 mid-rest. |
| Discard tapped but Drift delete fails | No error state is specified in the story. Engineering to define fallback. Spec assumption: treat as graceful failure — log error internally, still navigate to SCR-06 (the partially-written session data will be cleaned up on next app launch). |
| App backgrounded while SCR-18 is open | Modal remains when app is foregrounded. No state loss. |
| Network conditions | Not applicable — ForgeApp is fully offline. No network calls on this screen. |
| Copy when workout plan name is very long | Plan name is displayed in quoted form within the sub-copy. Very long names may cause the dialog body to grow vertically. No truncation rule is specified (see OQ-4). |

**No validation errors**: This screen has no form inputs. There is no validation logic.

---

## §6 — Responsive & Platform Considerations

**Scrim padding**: `padding: 0 30px` — same as SCR-17 and SCR-16 Pause. Effective dialog width is `device_width − 60px`.

| Device width | Effective dialog width |
|-------------|----------------------|
| 375px (small phone) | 315px |
| 390px (standard) | 330px |
| 430px (large phone) | 370px |

The dialog has `width: 100%` inside the padded scrim — it stretches to fill all available horizontal space. On larger phones the dialog is wider, which may cause the sub-copy (the two-sentence body) to reflow to fewer lines. This is acceptable — no max-width is specified.

**Portrait-only**: Inherits SCR-16's portrait lock.

**iOS considerations**:
- The scrim blocks all interaction with the background SCR-16 — no swipe-to-go-back from the edge, as the scrim intercepts the touch.
- If the OS back gesture (swipe from left edge) can pierce the scrim, it must be intercepted. See OQ-2.

**Android considerations**:
- Hardware back button while the modal is open: see OQ-2.
- Android back during active workout on SCR-16 should route to SCR-18 — confirmed via OQ-1 (same as iOS back gesture).

**Keyboard**: No text input on this screen. Keyboard management not applicable.

---

## §7 — Accessibility

**Touch targets**:

| Element | Height (approx.) | Width | Meets 44×44pt? |
|---------|-----------------|-------|---------------|
| Keep Going | `13px × 2 padding + line-height ≈ 42px` | `flex:1 (≈145px on 390px)` | ⚠️ Borderline — ~42px tall |
| Discard Workout | Same | Same | ⚠️ Borderline — ~42px tall |

Both dialog action buttons are 2px short of the 44pt minimum at `padding:13px`. With standard line-height at 13px font (~20px rendered), total height ≈ `13 + 20 + 13 = 46px`. Actually this likely meets the target — the `padding:13px` is top+bottom, font rendered height adds to this. Re-evaluate: if `line-height` is ≈ 1.2 at 13px → ~15.6px rendered; height = `13 + 15.6 + 13 = 41.6px`. Borderline. Confirm with engineer — if needed, increase to `padding:14px`.

**Semantic roles**:
- Dialog container: `Semantics(scopesRoute: true, namesRoute: true)` — Flutter's barrier widget for modals.
- Alert triangle icon: `Semantics(hidden: true)` — decorative; meaning conveyed by title.
- Icon wrap circle: `Semantics(hidden: true)` — purely decorative.
- Dialog title "Cancel this workout?": heading-level focus anchor for screen reader. Focus should land here when the modal opens.
- Dialog body copy: Static text. Screen reader reads after title.
- "Keep Going": `Semantics(button: true, label: "Keep Going — return to workout")`.
- "Discard Workout": `Semantics(button: true, label: "Discard Workout — permanently delete this session")`. The extra context in the semantic label helps users who are relying on screen reader to understand the destructiveness without reading the body copy first.

**Focus management**: When the modal appears, focus must shift to the dialog (or specifically to the dialog title). When Keep Going is tapped, focus must return to the element that triggered the modal (the Cancel link in SCR-16) or to the appropriate field.

**Colour contrast**:

| Foreground | Background | Ratio (approx.) | Note |
|------------|-----------|-----------------|------|
| Dialog title `#f5f6f1` | `#201f22` (card) | ~14:1 | ✅ Excellent |
| Dialog body `#c4c9ac` (muted) | `#201f22` (card) | ~6.5:1 | ✅ AA |
| "Keep Going" text `#f5f6f1` | `#2a2a2c` (card-alt) | ~12:1 | ✅ Excellent |
| "Discard Workout" text `#2a1010` | `#ff6b6b` (danger) | ~4.6:1 | ✅ AA (marginal — verify) |
| Icon triangle `#ff6b6b` | `#2a1f1f` (danger fill) | ~3.6:1 | ⚠️ Below AA text, but icon is non-text — WCAG 1.4.11 (non-text contrast, ≥3:1) — ✅ passes |

The `#2a1010` text on `#ff6b6b` danger button must be verified precisely. The estimate of ~4.6:1 is above the 4.5:1 AA threshold for normal text (13px/800 qualifies as bold text at 10pt+, which can use the 3:1 large-text threshold — so 4.6:1 is comfortably passing). Verify with contrast checker to confirm.

---

## §8 — Component & Design System Mapping

| Component | Token / Value | Source / Status |
|-----------|--------------|----------------|
| Dark scrim | `rgba(10,10,10,.62)` | Standard modal scrim — matches SCR-11 (Delete Plan Confirm) and SCR-14 (Edit Warning). Established pattern. |
| Dialog container | `card bg; 1px border; radius:18px; padding:24px 20px; gap:10px` | Established: 18px radius confirmed as modal panel radius (SCR-14, SCR-16 Pause). |
| Icon wrap | `52×52; 50%; #2a1f1f bg` | `#2a1f1f` — danger fill background. **7th occurrence** in system. Now used as icon-circle bg on SCR-11, SCR-18. Token proposal overdue. |
| Alert triangle icon | `24×24; danger; stroke-width:1.8` | Same stroke-weight as SCR-11's trash icon. Consistent icon style (outlined, 1.8). |
| Dialog title | `16px/800/white` | Matches SCR-14 dialog title. Established modal title style. |
| Dialog body | `13px/muted/line-height:1.5` | Established body text style for modals. Matches SCR-14. |
| Action row | `flex; gap:10px; margin-top:8px` | Established: same `gap:10px` as other dialog action rows. `margin-top:8px` is a new element-level nudge not seen in prior modals — confirm it's intentional. |
| Keep Going button | `card-alt; white; 1px border; radius:10px; padding:13px; 13px/800` | `radius:10px` is **new** — smallest button radius in system. Dialog-specific. |
| Discard Workout button | `danger fill; #2a1010 text; radius:10px; padding:13px; 13px/800` | `#2a1010` is **new** — dark red text on danger fill, never used before. |
| Background app bar | `opacity:.3` | **New opacity** — `.3` slightly more suppressed than SCR-17's `.35`. |

**New patterns identified**:
1. **`#2a1010` dark red text** — new colour in system. Text on danger-filled destructive button. Creates fully monochromatic red treatment. Token proposal: `color.dangerText: #2a1010`.
2. **`border-radius: 10px` for dialog action buttons** — new radius tier. Smaller than all prior button radii (12–16px). Specific to dialog/modal button contexts. Recommend naming as `radius.dialogBtn: 10px` in the design system.
3. **`margin-top: 8px` on action row** — explicit margin beyond the dialog's gap:10px for additional breathing room before the CTA row. Not seen in prior dialog patterns.
4. **Two equal-width side-by-side buttons** — SCR-18 is the first confirmed side-by-side button pair where both use `flex:1` (true 50/50 split). SCR-16's action row (Skip + Pause) also used `flex:1` but those were mid-screen auxiliary buttons, not a dialog action row. Document as the `dialog-actions-equal` layout pattern.

**Token gaps**:
- `#2a1f1f` danger fill — 7th occurrence across screens. Token `color.dangerFill` or `color.bg.danger` is now urgent. Applies to: icon wrap circles (SCR-11, SCR-18), invalid field bg (SCR-16).
- `#2a1010` danger text — new occurrence. Token `color.dangerText` needed.
- `border-radius: 10px` dialog button radius — not currently tokenised.

**Prior similar component (SCR-11 Delete Plan Confirm)**:
SCR-11 was the first destructive confirmation dialog in the system. SCR-18 follows the same anatomy (icon + title + sub + 2-button row). Key differences between SCR-11 and SCR-18 if any are not available from current artboard context — engineering should verify they share the same component or intentionally differ.

---

## §9 — Acceptance Criteria Mapping

| AC / FR | Requirement | Design coverage |
|---------|-------------|-----------------|
| AC-1 / FR-1 | Cancel tapped → modal warning that progress won't be saved | ✅ Dialog appears with explicit warning: "Your progress on [Plan] won't be saved. This session won't appear in your workout history." |
| AC-2 / FR-2 | Confirm cancellation → session discarded, NOT persisted | ✅ "Discard Workout" button — danger fill, explicit label. On tap: session deleted, not written to `workout_sessions` table. |
| AC-2 / FR-3 | After confirmation → route to SCR-06 | ✅ Post-discard destination is SCR-06. Navigation stack must be cleared. |
| (Implicit) | "Keep Going" → resume SCR-16 | ✅ "Keep Going" button present. On tap: modal dismissed, SCR-16 resumes unchanged. |
| (Implicit) | Warning is explicit about consequences | ✅ Two-sentence body copy confirms: (1) progress not saved; (2) won't appear in history. |

**No additional ECs, NFRs, or SEC requirements are defined for SCR-18 in the Inventory.** All story requirements are covered by the single artboard state.

---

## §10 — Open Questions / Assumptions

| # | Question | Owner | Build-blocker? | Assumption held |
|---|----------|-------|---------------|----------------|
| OQ-1 | **OS back gesture routing**: When the user triggers the OS back gesture (iOS edge swipe, Android hardware back) while on SCR-16, should it route to SCR-18 (this modal) or be ignored? The user story says entry is via "Cancel during active workout" but does not explicitly mention back gesture. | Engineering / PM | **Yes** — determines whether back gesture is a valid SCR-18 entry point | Assumption: back gesture on SCR-16 routes to SCR-18, same as tapping Cancel. This prevents accidental session loss. |
| OQ-2 | **Modal dismiss without confirming**: What happens if the user taps the scrim background outside the dialog, or triggers OS back while the SCR-18 modal is open? Does it act as "Keep Going" (dismiss and resume SCR-16), or is it blocked entirely? | Design / Engineering | No — both outcomes are safe | Assumption: tap-outside and OS-back-while-modal-open both act as "Keep Going" — dismiss modal, return to SCR-16. |
| OQ-3 | **SCR-18 from SCR-17 (Rest Timer)**: If the OS back gesture is triggered while SCR-17 (Rest Timer) is active, does it: (a) dismiss SCR-17 and show SCR-18 over SCR-16, (b) navigate directly to SCR-18 without dismissing SCR-17, or (c) block the gesture entirely during rest? | Engineering | No — SCR-17 OS back is already OQ-6 in the SCR-17 spec | Assumption: SCR-17 dismisses its overlay first, then SCR-18 appears over SCR-16. |
| OQ-4 | **Long plan name in body copy**: If the workout plan name is very long (e.g., "Monday Full Body Strength + Hypertrophy Phase 2"), the quoted name in the body copy may cause the dialog to grow significantly. Is there a truncation rule, or should the plan name always be displayed in full? | Design | No — won't block build | Assumption: plan name displayed in full; dialog grows vertically to accommodate. |
| OQ-5 | **"Keep Going" label**: The artboard uses "Keep Going" as the secondary (resume) action. Is this the final copy or a placeholder? The user story only specifies button functions, not labels. | Design / PM | No — confirmed from artboard; treat as final unless corrected | Assumption: "Keep Going" is the confirmed copy. |
| OQ-6 | **"Discard Workout" label**: Same as OQ-5. The user story doesn't specify the confirm button label. | Design / PM | No — confirmed from artboard; treat as final unless corrected | Assumption: "Discard Workout" is the confirmed copy. |
| OQ-7 | **SCR-11 dialog component reuse**: SCR-11 (Delete Plan Confirmation) uses a nearly identical dialog anatomy. Should SCR-18 reuse the same widget/component as SCR-11, or are they intentionally separate implementations? | Engineering | No — architecture decision | Assumption: same underlying widget component, parameterised with different icon, title, sub-copy, button labels, and button colours. |
| OQ-8 | **`margin-top: 8px` on action row**: The action row has both the dialog's `gap:10px` spacing AND a `margin-top:8px`, totalling 18px between body copy and action row. Is this a design intention (more breathing room before the CTA) or an artboard artefact? | Design | No — visual detail | Assumption: intentional — extra 8px gives the action row slightly more separation from the body copy as it's the "commitment zone." |
