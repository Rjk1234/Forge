# Design Specification: SCR-15 — Workout Pre-Start / Overview

**Story ID**: US-SCR15  
**Priority**: High | **Points**: 3  
**Created**: 2026-09-12  
**Design reference**: https://claude.ai/code/artifact/16366a19-a2a2-48fe-aa85-97478f08e10e  
**Artboards**: Main.dc.html · Loading.dc.html · Invalid.dc.html · Error.dc.html

---

## 1. Overview & Goal

### Problem
A user tapping a scheduled workout entry (SCR-12) or navigating from Plan Detail (SCR-10) needs a moment to orient before committing to an active workout session. They need to see what exercises are planned, at what targets, before tapping Begin — and if the plan is no longer available or fails to load, they must be given clear feedback with no ambiguity about whether they can proceed.

### User
Any ForgeApp user with at least one schedule entry who is about to begin a workout.

### Goal
Surface the full exercise list and configured targets for the scheduled plan so the user can confirm readiness; provide a clear, tap-one-button path into the Active Workout session (SCR-16); and gracefully block or inform the user if the plan cannot be started.

### Success metric
User can review the plan and tap "Begin Workout" in a single interaction with no loading delay visible after the skeleton resolves. Blocking states present one clear path forward (Back to Schedule) with no ambiguity.

### App context
ForgeApp is fully offline and local-only. All data is read from Drift. There is no network call; "loading" refers exclusively to local Drift read latency. This screen is a pushed route (not a modal), entered from SCR-10 or SCR-12, exiting to SCR-16 (Begin Workout) or popping back to the caller.

---

## 2. User Flow

### Entry points
- **SCR-10 (Plan Detail)**: User taps a "Start Workout" action on a plan card
- **SCR-12 (Weekly Schedule View)**: User taps a scheduled day entry to begin that plan's workout

### State machine

```
Entry (SCR-10 / SCR-12)
        │
        ▼
  [A] Loading Skeleton ──────────────────────────────────┐
        │                                                │
   Drift read                                         (never: network)
        │
   ┌────┴──────────┐
   │               │
Plan available    Plan unavailable / deleted
   │               │
   ▼               ▼
[B] Plan Preview  [C] Invalid Plan
   │               │
 "Begin Workout"  "Back to Schedule"
   │               │
   ▼               ▼
[SCR-16]         [SCR-12 pop]
   
   │ Drift read throws error
   ▼
[D] Load Failure
   │
 "Retry" ──────► [A] Loading (re-read)
   │
 "Back to Schedule" ──► [SCR-12 pop]
```

### Exit points
| Action | Destination |
|--------|-------------|
| Begin Workout (State B) | Push SCR-16 (Active Workout) |
| Back (app bar, State B/C/D) | Pop to caller (SCR-10 or SCR-12) |
| Back to Schedule (State C) | Pop to SCR-12 |
| Back to Schedule (State D) | Pop to SCR-12 |
| Retry (State D) | Re-enter State A → B / C / D |

---

## 3. Screen-by-Screen Breakdown

### Shared structure (all states)

**App bar** (`padding:6px 20px 4px`):
- Back chevron icon: `width:22px; height:22px; stroke-width:2`
- Title: `font-size:18px; font-weight:800; letter-spacing:.02em`
- Title text: "Workout Overview"

**Viewport**: 390×844px; `background:#131315`; `color:#f5f6f1`; `font-family:'Helvetica Neue', Arial, sans-serif`

---

### State A — Loading Skeleton

**When**: Immediately on entry, while Drift read is in progress.

**App bar**:
- Back icon: `color:var(--dim)` (#8a8f7a) — dimmed
- Title "Workout Overview": `color:var(--dim)` — dimmed
- Both elements match SCR-13's Saving Loading pattern: app bar conveys "in progress" through dim treatment

**Content** (`padding:14px 20px 40px; gap:16px; flex-direction:column`):

Skeleton element base class: `background:#2a2a2c; border-radius:8px; position:relative; overflow:hidden`

Shimmer animation on all skeleton elements:
```css
.sk::after {
  content:""; position:absolute; inset:0;
  background:linear-gradient(90deg, transparent, rgba(255,255,255,.06), transparent);
  animation:shimmer 1.4s infinite;
}
@keyframes shimmer { 0%{ transform:translateX(-100%); } 100%{ transform:translateX(100%); } }
```

Skeleton pieces (top to bottom):
| Class | Width | Height | Border-radius | Notes |
|-------|-------|--------|--------------|-------|
| sk-title | 70% | 22px | 6px | Mimics plan name |
| sk-sub | 45% | 12px | 6px | `margin-top:8px` — mimics plan meta |
| sk-label | 30% | 11px | 6px | `margin-top:6px` — mimics section label |

Skeleton cards (3×):
```css
.sk-card {
  background:#201f22; border:1px solid #444933; border-radius:14px;
  padding:14px; display:flex; flex-direction:column; gap:10px;
}
.sk-head { width:60%; height:14px; border-radius:6px; } /* on sk base */
.sk-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:8px; }
.sk-box { height:44px; border-radius:10px; } /* on sk base */
```

**Footer**: No footer button. No Begin Workout in loading state.

---

### State B — Plan Preview (Main)

**When**: Drift read succeeds and plan exists with valid exercises.

**App bar**:
- Back icon: `color:#f5f6f1` (white) — normal
- Title: `color:#f5f6f1` (white) — normal

**Content** (`flex:1 1 auto; overflow-y:auto; padding:14px 20px 100px; gap:16px`):
- `padding-bottom:100px` accounts for the absolute-positioned footer; content scrolls under it

**Plan hero** (`.plan-hero`, `gap:6px`):
- Plan name: `font-size:22px; font-weight:800` — largest type on screen; `color:#f5f6f1`
- Plan meta: `font-size:12px; color:#c4c9ac` — e.g. "5 exercises · scheduled for today, Monday"

**Section label**:
```css
font-size:12px; font-weight:800; text-transform:uppercase;
letter-spacing:.06em; color:#8a8f7a; margin-top:4px;
```
Text: "Exercises"

**Exercise cards** (one per exercise, `.ex-card`):
```css
background:#201f22; border:1px solid #444933; border-radius:14px;
padding:14px; display:flex; flex-direction:column; gap:10px;
```

Exercise card header (`.ex-head`, `gap:8px; align-items:center`):
- **Type dot** (`.type-dot`, `width:8px; height:8px; border-radius:50%`):
  | Type | Color |
  |------|-------|
  | Weighted | `background:#c3f400` (lime) |
  | Time-based | `background:#7df4ff` (cyan) |
  | Bodyweight | `background:#c4c9ac` (muted) |
- **Exercise name** (`.ex-name`): `font-size:14px; font-weight:700; flex:1 1 auto`
- **Type label** (`.type-label`): `font-size:10px; font-weight:700; color:#8a8f7a; text-transform:uppercase; letter-spacing:.04em`
  - Values: "Weighted" | "Time-based" | "Bodyweight"

**Field grid — Weighted (3-column)**:
```css
display:grid; grid-template-columns:repeat(3,1fr); gap:8px;
```
Columns: Sets / Reps / Weight

**Field grid — Bodyweight / Time-based (2-column)**:
```css
display:grid; grid-template-columns:repeat(2,1fr); gap:8px;
```
- Bodyweight: Sets / Reps
- Time-based: Sets / Duration (format `MM:SS`, e.g. "00:45")

**Field box** (`.field-box`):
```css
background:#2a2a2c; border:1px solid #444933; border-radius:10px;
padding:8px 6px; text-align:center;
```
- Field label (`.field-label`): `font-size:9px; color:#8a8f7a; text-transform:uppercase; letter-spacing:.04em; font-weight:700`
- Field value (`.field-value`): `font-size:14px; font-weight:800; margin-top:2px`

**Exercise examples from artboard**:
| # | Name | Type | Grid | Targets |
|---|------|------|------|---------|
| 1 | Barbell Bench Press | Weighted | 3-col | 4 sets · 8 reps · 60 kg |
| 2 | Seated Shoulder Press | Weighted | 3-col | 3 sets · 10 reps · 18 kg |
| 3 | Push-Ups | Bodyweight | 2-col | 3 sets · 15 reps |
| 4 | Plank Hold | Time-based | 2-col | 3 sets · 00:45 |
| 5 | Triceps Pushdown | Weighted | 3-col | 3 sets · 12 reps · 25 kg |

**Footer** (`.footer`):
```css
position:absolute; left:0; right:0; bottom:0;
padding:14px 20px 22px;
background:linear-gradient(180deg, rgba(19,19,21,0) 0%, var(--bg) 40%);
```
Gradient fade ensures content transition is smooth as user scrolls near the bottom.

**Begin Workout button** (`.begin-btn`):
```css
width:100%; background:#c3f400; color:#131315;
border-radius:14px; padding:16px;
text-align:center; font-weight:800; font-size:15px; letter-spacing:.01em;
```

---

### State C — Invalid Plan

**When**: Plan referenced by the schedule entry no longer exists in Drift (was deleted), or its exercise list is empty/otherwise invalid.

**App bar**: Back icon and title both white (normal — no dimming; this is a resolved/terminal state, not transitional).

**Content** (`flex:1 1 auto; display:flex; flex-direction:column; align-items:center; justify-content:center; padding:0 32px; gap:14px; text-align:center`):
- Content is vertically and horizontally centred — full contrast with State B's top-aligned scroll.

**Icon wrapper** (`.icon-wrap`):
```css
width:64px; height:64px; border-radius:50%;
background:#201f22; border:1px solid #444933;
display:flex; align-items:center; justify-content:center;
```

**Icon** (`.icon`, `width:30px; height:30px; color:#ff6b6b; stroke-width:1.6`):
Alert circle with exclamation:
```svg
<circle cx="12" cy="12" r="9"/>
<path d="M12 8v5"/>
<circle cx="12" cy="16.5" r="0.6" fill="currentColor" stroke="none"/>
```
> Note: This is a filled-circle info/alert icon, NOT the warning triangle used in SCR-13's Invalid Plan banner. These are two distinct invalid-plan presentations: SCR-13 shows the triangle inline within a form field context; SCR-15 shows the alert circle on a full-screen centred state.

**Message title** (`.msg-title`): `font-size:17px; font-weight:800`  
Text: "This plan is no longer available"

**Message sub** (`.msg-sub`): `font-size:13px; color:#c4c9ac; line-height:1.5`  
Text: `"Push Day — Upper Body" may have been deleted or changed since it was scheduled. You can't start this workout, but your past history is unaffected.`

**Footer** (`padding:14px 20px 22px` — single button, no `gap` / `flex-direction:column`):

**Back to Schedule button**:
```css
width:100%; background:#2a2a2c; color:#f5f6f1;
border:1px solid #444933; border-radius:14px;
padding:16px; text-align:center; font-weight:800; font-size:15px;
```
Single CTA — no Retry. Retrying would produce the same result (plan is genuinely gone from Drift).

---

### State D — Load Failure

**When**: Drift read throws an exception (storage corruption, read error). Plan may still exist; this is a transient failure.

**App bar**: Back icon and title both white (normal).

**Content**: Identical layout to State C (vertically/horizontally centred, `padding:0 32px; gap:14px; text-align:center`).

**Icon wrapper**: Identical to State C (`64×64; 50%; card fill; 1px border`).

**Icon** (same 30×30 danger, stroke-width:1.6, but different SVG — calendar with error mark):
```svg
<rect x="4" y="5" width="16" height="15" rx="2"/>
<path d="M4 10h16M8 3v4M16 3v4"/>
<path d="M12 13v-2M12 16.2v.1"/>
```
Calendar-with-error icon — visually distinguishes "storage error" from "plan unavailable" (State C's alert circle).

**Message title**: `font-size:17px; font-weight:800`  
Text: "Couldn't load this workout"

**Message sub**: `font-size:13px; color:#c4c9ac; line-height:1.5`  
Text: "Something went wrong reading this plan from local storage. Your data is safe — try again."

**Footer** (`display:flex; flex-direction:column; gap:10px; padding:14px 20px 22px`):
Two-button stacked layout — contrast with State C's single-button footer.

**Retry button** (`.retry-btn`, primary):
```css
width:100%; background:#c3f400; color:#131315;
border-radius:14px; padding:16px;
text-align:center; font-weight:800; font-size:15px;
```

**Back to Schedule button** (`.back-btn`, secondary):
```css
width:100%; background:#2a2a2c; color:#f5f6f1;
border:1px solid #444933; border-radius:14px;
padding:14px; text-align:center; font-weight:700; font-size:14px;
```
Secondary button is visually subordinate: `padding:14px` vs `16px` (primary); `font-weight:700` vs `800` (primary); `font-size:14px` vs `15px` (primary). First instance in the design system of a primary/secondary button pair at full-width stacked in a footer.

---

## 4. Interactions & Behavior

| Element | State | Interaction | Result |
|---------|-------|-------------|--------|
| Back chevron (app bar) | A | Tap | Pop route back to caller; loading is cancelled |
| Back chevron (app bar) | B | Tap | Pop route back to caller (SCR-10 or SCR-12) |
| Back chevron (app bar) | C | Tap | Pop route back to caller |
| Back chevron (app bar) | D | Tap | Pop route back to caller |
| Begin Workout | B | Tap | Push SCR-16; pass planId + scheduleEntryId |
| Back to Schedule | C | Tap | Pop to SCR-12 (not necessarily immediate caller — see OQ-1) |
| Retry | D | Tap | Re-trigger Drift read; transition to State A; then B, C, or D |
| Back to Schedule | D | Tap | Pop to SCR-12 |
| Content area | B | Scroll up/down | Exercise list scrolls; footer stays fixed via absolute positioning |

### State transitions
- **A → B**: Drift read returns a valid plan with at least one exercise
- **A → C**: Drift read returns no plan matching the planId, or plan has zero exercises
- **A → D**: Drift read throws an exception
- **D → A**: User taps Retry
- **B → SCR-16**: User taps Begin Workout
- **C/D → SCR-12**: User taps Back to Schedule (or app-bar back)

### Footer gradient behaviour
State B only: the footer uses a fade-from-transparent gradient so the last exercise card visually trails off as the user nears the bottom of the scroll. This is a UX affordance to indicate the list ends — do not apply to States C or D (no scrollable content).

---

## 5. Edge Cases & Error Handling

| ID | Scenario | Handling |
|----|---------|---------|
| EC-1 | Plan exists in Drift but has zero exercises | Treat as Invalid Plan → State C. "This plan is no longer available" copy is acceptable even if the plan technically exists but is empty. (OQ-2 below) |
| EC-2 | Drift read throws an exception | → State D (Load Failure). Show Retry + Back to Schedule. |
| EC-3 | User is in State A and navigates back immediately (before read completes) | Cancel Drift read future; pop normally. No state change triggered. |
| EC-4 | User taps Retry in State D rapidly (double-tap) | Debounce: only one Drift read in flight at a time. Ignore second tap until first completes. |
| EC-5 | Very long plan name (>30 chars) | Plan name in hero allows wrapping (`font-size:22px; font-weight:800`); no truncation. `padding-bottom:100px` on content accommodates multi-line hero. |
| EC-6 | Very long exercise name (>25 chars) | Exercise name (`font-size:14px; flex:1 1 auto`) wraps freely within the card header; type label and type dot remain on the same row but push to align-items:center so wrapping of name does not break layout. |
| EC-7 | Single exercise in plan | One exercise card shown. Plan meta: "1 exercise · scheduled for today, [Day]". All spacing and footer are unchanged. |
| EC-8 | Exercise has no weight configured (Weighted type, weight = 0 or null) | Show "—" or "0 kg" in the Weight field box. (OQ-3) |
| EC-9 | Plan is valid but schedule entry references a deleted plan | Indistinguishable from EC-1/EC-3 from Drift perspective; → State C. |
| EC-10 | State B, user scrolls to bottom of a long list (10+ exercises) | Last card is not clipped; `padding-bottom:100px` provides breathing room above the footer gradient. Footer remains fixed at bottom. |

---

## 6. Responsive & Platform Considerations

### Device width bands

| Band | Width | Behaviour |
|------|-------|-----------|
| Small (SE / compact) | 375px | Hero plan name and meta compress naturally; exercise cards stack; field-box values may feel tighter (14px/800 still fits 3-col at 375px minus 40px padding = 295px available, ÷3 = ~98px per column — comfortable) |
| Standard | 390–430px | Artboard baseline |
| Large (Pro Max) | 430px+ | Content pads to 20px each side; cards expand to fill; no max-width set (OQ-4) |

### iOS / Android
- **iOS**: Swipe-right from left edge pops the route (system back gesture); matches app-bar back chevron behaviour
- **Android**: Hardware/gesture back pops the route
- **Portrait only**: SCR-15 is portrait-only; landscape is not designed

### Scroll behaviour
- State B content scrolls; States A, C, D do not (skeleton and centred states fit within the viewport without scrolling)
- Overscroll bounce (iOS) is expected; no custom overscroll handling required

---

## 7. Accessibility

### Touch targets
| Element | Nominal size | Status |
|---------|-------------|--------|
| Back chevron (22×22 icon) | ~44pt with padding from `padding:6px 20px 4px` | ⚠️ Icon itself is 22×22; tappable area depends on Flutter's InkWell/GestureDetector wrapping — ensure minimum 44×44 hit target |
| Begin Workout button | `padding:16px` vertical → ~48pt height | ✅ |
| Back to Schedule (State C) | `padding:16px` vertical → ~48pt height | ✅ |
| Retry (State D) | `padding:16px` vertical → ~48pt height | ✅ |
| Back to Schedule secondary (State D) | `padding:14px` vertical → ~44pt height | ✅ borderline |

### Colour contrast
| Text | Background | Ratio (est.) | Status |
|------|-----------|-------------|--------|
| Plan name (#f5f6f1 / 22px bold) | #131315 | ~16:1 | ✅ |
| Plan meta (#c4c9ac / 12px) | #131315 | ~7.2:1 | ✅ |
| Section label (#8a8f7a / 12px bold) | #131315 | ~3.8:1 | ⚠️ Below 4.5:1 AA for normal text; passes AA for large text (bold 12px is technically large at some interpretations); review with Design |
| Exercise name (#f5f6f1 / 14px bold) | #201f22 | ~15.5:1 | ✅ |
| Type label (#8a8f7a / 10px bold) | #201f22 | ~3.5:1 | ⚠️ 10px bold is very small; does not pass AA; Design intent — decorative label secondary to the type dot |
| Field label (#8a8f7a / 9px bold) | #2a2a2c | ~3.2:1 | ⚠️ 9px is the smallest text in the design system; purely supportive of field value; Design intent |
| Field value (#f5f6f1 / 14px bold) | #2a2a2c | ~14.8:1 | ✅ |
| Begin Workout (#131315 / 15px bold) | #c3f400 | ~13.1:1 | ✅ |
| Msg title (#f5f6f1 / 17px bold) | #131315 | ~16:1 | ✅ |
| Msg sub (#c4c9ac / 13px) | #131315 | ~7.2:1 | ✅ |
| Back to Schedule (#f5f6f1 / 15px bold) | #2a2a2c | ~14.5:1 | ✅ |
| Retry (#131315 / 15px bold) | #c3f400 | ~13.1:1 | ✅ |
| Back to Schedule secondary (#f5f6f1 / 14px 700) | #2a2a2c | ~14.5:1 | ✅ |

### Semantics
- **Screen title** ("Workout Overview"): announce on route push as page heading
- **Plan name**: announce as a heading (H1 equivalent) when State B resolves from A
- **Exercise cards**: each card is a semantic group; exercise name, type, and targets are announced together — avoid announcing type dot (decorative) and field-label/field-value pairs can be grouped ("Sets: 4, Reps: 8, Weight: 60 kg")
- **Loading state**: announce "Loading workout overview" (liveRegion) on entry; suppress skeleton elements from screen reader
- **State C**: announce "This plan is no longer available" when state resolves; "Back to Schedule" button role must be clear (button semantics)
- **State D**: announce "Couldn't load this workout" as liveRegion.polite on transition from A; Retry button semantics explicit

---

## 8. Component & Design System Mapping

| Component | Usage in SCR-15 | Token / Value |
|-----------|----------------|--------------|
| AppBar | All states | `padding:6px 20px 4px`; title 18px/800; back icon 22×22 |
| BackChevron | All states | `color:white` (B/C/D); `color:dim` (A — loading) |
| PlanHeroSection | State B | plan-name 22px/800; plan-meta 12px/muted |
| SectionLabel | State B | 12px/800/uppercase/letter-spacing:.06em/dim |
| ExerciseCard | State B | card fill; 1px border; 14px radius; padding:14px; gap:10px |
| TypeDot | State B | 8×8; lime/cyan/muted by type |
| TypeLabel | State B | 10px/700/dim/uppercase |
| FieldGrid3Col | State B (Weighted) | repeat(3,1fr); gap:8px |
| FieldGrid2Col | State B (BW/Time) | repeat(2,1fr); gap:8px |
| FieldBox | State B | card-alt fill; 1px border; 10px radius; 8px 6px padding; label 9px/dim; value 14px/800 |
| FooterGradient | State B | `linear-gradient(180deg, rgba(19,19,21,0) 0%, #131315 40%)` |
| BeginWorkoutButton | State B | lime fill; #131315; 14px radius; padding:16px; 800/15px/letter-spacing:.01em |
| Skeleton / ShimmerCard | State A | card-alt base; shimmer gradient 1.4s; 3 placeholder cards |
| CentredStateLayout | States C, D | `flex-direction:column; align-items:center; justify-content:center; padding:0 32px; gap:14px; text-align:center` |
| IconWrap | States C, D | 64×64; 50% radius; card fill; 1px border |
| AlertCircleIcon | State C | 30×30; danger (#ff6b6b); stroke-width:1.6 |
| CalendarErrorIcon | State D | 30×30; danger (#ff6b6b); stroke-width:1.6 |
| MsgTitle | States C, D | 17px/800; white |
| MsgSub | States C, D | 13px/muted; line-height:1.5 |
| SingleFooterButton | State C | `padding:14px 20px 22px`; no gap |
| DualFooterStack | State D | `display:flex; flex-direction:column; gap:10px; padding:14px 20px 22px` |
| PrimaryFooterButton | States B, C (BW), D (Retry) | lime fill; #131315; 14px radius; padding:16px; 800/15px |
| SecondaryFooterButton | State D only | card-alt fill; white; 1px border; 14px radius; padding:14px; 700/14px |

### Token gaps / non-token values
- `rgba(19,19,21,0)` — transparent variant of `color.bg`; not tokenised; used for footer gradient start
- Type dot colours (lime/cyan/muted) reuse existing design tokens but the dot component itself is not formalised
- `letter-spacing:.06em` on SectionLabel — new value, not seen in prior SCR specs (SCR-13 section labels used `.08em`); confirm canonical value

### Reused from SCR-09/10
TypeDot + TypeLabel system is confirmed reuse from SCR-09 and SCR-10 exercise type flag patterns. All three dot colours (lime/cyan/muted) and the 10px/700/dim/uppercase label are consistent.

---

## 9. Acceptance Criteria Mapping

| AC / FR / NFR | Spec location | Status |
|--------------|--------------|--------|
| AC-1: Loading skeleton shows while plan data being fetched | §3 State A | ✅ Specified — shimmer cards, dimmed app bar, no Begin button |
| AC-2: Plan preview + "Begin Workout" action | §3 State B | ✅ Specified — hero, exercise cards, field grids, footer CTA |
| EC-1: Invalid/unavailable plan → blocking state, no start | §3 State C | ✅ Specified — centred state, alert-circle icon, Back to Schedule only |
| EC-2: Load failure → error + retry | §3 State D | ✅ Specified — calendar-error icon, Retry (lime) + Back to Schedule (secondary) |
| FR-1: Loading skeleton while plan data fetched | §3 State A | ✅ |
| FR-2: Display exercise preview with configured targets | §3 State B | ✅ — type dot + type label + field grid (3-col weighted, 2-col BW/time) |
| FR-3: Provide "Begin Workout" action when plan loaded | §3 State B footer | ✅ |
| FR-4: Prevent workout starting when plan invalid/unavailable | §3 State C | ✅ — no Begin Workout button; Back to Schedule only |
| FR-5: Allow user to proceed when plan available | §3 State B → SCR-16 | ✅ |
| NFR (offline): No network call; reads from Drift only | §1 App context | ✅ — all states are Drift read results; no network concept exists |

---

## 10. Open Questions / Assumptions

| # | Question | Owner | Build-block? | Assumption held |
|---|---------|-------|-------------|----------------|
| OQ-1 | "Back to Schedule" in States C and D pops to SCR-12 regardless of entry point. If the user entered from SCR-10 (Plan Detail), does "Back to Schedule" still navigate to SCR-12, or should it pop to SCR-10? | PM / Design | Yes — routing logic differs | Assumption: "Back to Schedule" always pops to SCR-12; back chevron (top-left) pops to caller (SCR-10 or SCR-12). |
| OQ-2 | Is a plan with zero exercises treated as Invalid (State C) or does it show an empty plan in State B with Begin Workout disabled? | PM / Design / Engineering | Yes — determines which state | Assumption: zero-exercise plan → State C (no valid workout exists) |
| OQ-3 | Exercise with a Weighted type but no weight configured: does the Weight field box show "0 kg", "—", or is it omitted entirely? | Design | Minor | Assumption: show "—" to indicate unset |
| OQ-4 | Is there a max-width cap on the content area for large (Pro Max+) or tablet screens? State B's exercise cards are likely too wide at full width on a 428px+ screen. | Design / Engineering | No | Assumption: none set; cards expand to fill; revisit when tablet layout is scoped |
| OQ-5 | Plan meta format: artboard shows "5 exercises · scheduled for today, Monday". Is "scheduled for today" only shown when the entry is for today's date? What is shown if the user opens from a future schedule day? | PM / Engineering | Yes — display logic | Assumption: "scheduled for [day name]" always; "today" qualifier shown only when the scheduled day equals today's date |
| OQ-6 | Does SCR-15 also serve as the workout overview for an ad-hoc (unscheduled) workout started from Plan Detail (SCR-10)? If so, plan-meta format "scheduled for today, Monday" is incorrect. | PM / Engineering | Yes — copy and routing | Assumption: entry from SCR-10 without a schedule context shows "X exercises" only, no scheduling copy |
| OQ-7 | What is the loading state duration threshold before a timeout? Drift is local — reads are typically <50ms. If a read hangs indefinitely, is there a timeout to transition to State D? | Engineering | No | Assumption: no explicit timeout; Drift future completes or throws; Flutter will surface an error via exception |

### Explicit assumptions
1. The exercise list in State B renders all exercises in their plan-defined order; no reordering by the user at this screen.
2. Duration format for Time-based exercises is always `MM:SS` (e.g. "00:45").
3. Content scroll in State B is native Flutter SingleChildScrollView (or CustomScrollView); no custom scroll physics.
4. The footer gradient in State B is purely decorative (no tap interaction); Begin Workout is the only tappable element in the footer area.
5. State A shows exactly 3 skeleton cards regardless of actual plan exercise count. The skeleton does not pre-size to match the expected count.
6. The `CentredStateLayout` (States C and D) does not scroll; all content fits within the viewport on any supported device.
