# Design Specification Quality Checklist: SCR-18 — Cancel Active Workout Confirmation

**Purpose**: Validate design specification completeness and quality before implementation  
**Created**: 2026-09-13  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/f8a48120-7d5c-44cf-9f2f-6e5a8b5d39de

---

## Specification Completeness

- [x] §1 Overview & Goal — problem, user, goal, success metric, app context (offline/Drift), all 3 FRs, Decisions Log §2 context documented
- [x] §2 User Flow — state machine (2 exits: Keep Going, Discard); 3 entry paths documented (Cancel button, OS back, via SCR-17); state preservation on Keep Going; navigation stack clean-up on Discard
- [x] §3 Screen-by-Screen Breakdown — single artboard fully covered; background SCR-16 dimming with exact opacity/.3 values; scrim properties; all dialog elements with CSS values; copy verbatim from artboard
- [x] §4 Interactions & Behavior — 7 interactions tabulated; Drift delete behaviour; navigation stack note; double-tap guard noted
- [x] §5 Edge Cases & Error Handling — 7 edge cases; 0-sets cancel; all-sets-then-cancel; Drift delete failure; app backgrounded; long plan name
- [x] §6 Responsive & Platform Considerations — 3 device widths tabulated; iOS/Android back gesture (OQ-1, OQ-2); portrait-only; keyboard N/A
- [x] §7 Accessibility — 2 touch targets audited; 5 contrast pairs (1 marginal; 1 icon non-text); focus management; semantic labels with extended context for destructive button
- [x] §8 Component & Design System Mapping — 10 component entries; 4 new patterns; 3 token gaps (dangerFill 7th occurrence, dangerText new, dialogBtn radius new); SCR-11 reuse hypothesis
- [x] §9 Acceptance Criteria Mapping — AC-1, AC-2 (FR-2, FR-3) mapped; implicit Keep Going path covered; explicit warning copy confirmed
- [x] §10 Open Questions / Assumptions — 8 OQs with owner / build-blocker status / assumption held

---

## Design Grounding

- [x] All measurements taken from artboard CSS (not invented)
- [x] All copy strings taken verbatim from artboard HTML ("Cancel this workout?", "Keep Going", "Discard Workout", full body copy with plan name interpolation)
- [x] Token values cross-checked against design system reference
- [x] Non-token values identified:
  - `rgba(10,10,10,.62)` — standard modal scrim (shared with SCR-11, SCR-14 — consistent)
  - `#2a1f1f` — danger fill background on icon wrap (7th occurrence — urgent token needed)
  - `#2a1010` — NEW: dark red text on danger-filled button (first occurrence)
  - `border-radius: 10px` — new dialog button radius (not tokenised)
- [x] 1 artboard read and accounted for in §3
- [x] Background suppression opacity `.3` noted (vs SCR-17's `.35` — slight difference documented)
- [x] Scrim tier taxonomy updated (SCR-18 confirmed as `.62` standard modal tier)

---

## Blocking Issues

| # | Issue | Severity | Status |
|---|-------|---------|--------|
| OQ-1 | **OS back gesture routing on SCR-16**: The user story specifies Cancel-button as the SCR-18 entry point but does not address the OS back gesture (iOS edge swipe, Android hardware back). If the back gesture is not intercepted on SCR-16, it could silently discard the workout without confirmation — the same risk SCR-18 was built to prevent. | **Blocking** | Open — Engineering to implement back-gesture interception on SCR-16 (and SCR-17) |

---

## Non-Blocking Open Questions

| # | Topic | Owner | Assumption held |
|---|-------|-------|----------------|
| OQ-2 | Tap-outside / OS back while SCR-18 is open — acts as Keep Going or is blocked? | Engineering | Treated as Keep Going (dismiss modal, resume SCR-16) |
| OQ-3 | SCR-17 Rest Timer + OS back — routing to SCR-18 | Engineering | SCR-17 dismisses, then SCR-18 appears |
| OQ-4 | Long plan name truncation in body copy | Design | Display in full; dialog grows |
| OQ-5 | "Keep Going" — confirmed copy or placeholder? | Design / PM | Confirmed from artboard |
| OQ-6 | "Discard Workout" — confirmed copy or placeholder? | Design / PM | Confirmed from artboard |
| OQ-7 | SCR-11 Delete Plan dialog — same component or separate? | Engineering | Same underlying widget, parameterised |
| OQ-8 | `margin-top: 8px` on action row — intentional extra breathing room? | Design | Intentional |

---

## Design Consistency Notes

- **Scrim tier `.62` confirmed as standard modal**: SCR-18 uses `rgba(10,10,10,.62)` — the same value as SCR-11 (Delete Plan Confirm) and SCR-14 (Edit Warning). The three-tier scrim taxonomy (`.62` modal / `.72` rest timer / no-fill pause) is now complete and documented. Recommend codifying it in the design system.

- **`#2a1010` — new colour requires a token**: "Discard Workout" button text uses `#2a1010` — a very dark reddish near-black. This is the first time a red-family colour is used as text (prior danger text usages were `#ff6b6b` for labels/icons/errors). The contrast against `#ff6b6b` is marginal WCAG AA (~4.6:1) — just above the 4.5:1 threshold. Token proposal: `color.dangerText` or `color.onDanger`.

- **`border-radius: 10px` for dialog buttons**: All modal/dialog action buttons should use 10px. This is a new tier in the radius scale. Prior button radii: 12px (mid-screen action buttons), 14px (full-width CTAs and skip-rest), 16px (entry card). Dialog buttons at 10px read as more contained — visually they belong "inside" the dialog frame rather than dominating it. Add `radius.dialogButton: 10` to the design system token set.

- **`#2a1f1f` — 7th occurrence**: Danger fill background (`#2a1f1f`) now appears on: SCR-11 (delete icon wrap), SCR-12 (error banner?), SCR-13 (invalid plan banner + save failure), SCR-14 (dialog error block), SCR-16 (invalid field input), SCR-18 (cancel icon wrap). Tokenising as `color.dangerFill: #2a1f1f` alongside the existing `color.dangerBorder: #5c3a3a` should be a design system sprint priority.

- **Equal-width 50/50 dialog buttons**: Both Keep Going and Discard Workout use `flex:1` — true equal width. No visual nudging toward either option. This is intentional for a destructive confirmation: the user must make a deliberate choice, not be steered. Contrast with other app patterns where the primary CTA is full-width and secondary is smaller. The `equal-dialog-actions` layout is a distinct pattern.

- **Background opacity `.3` vs SCR-17's `.35`**: The 5% difference in background opacity between SCR-18 (modal dialog) and SCR-17 (rest timer overlay) is subtle but consistent with intent: a modal dialog is a hard interrupt that demands complete attention, so the background is pushed further away. The rest timer is ambient — it allows the user to glance at what they've just completed — hence the slightly lighter suppression.

- **Alert triangle (SCR-18) vs alert circle (SCR-15)**: Two warning icon variants now exist in the system. SCR-15 uses alert-circle (`!` in circle) for invalid plan warnings. SCR-18 uses alert-triangle (`!` in triangle) for destructive confirmation. Both are `24×24; stroke:1.8; danger color`. Rule for usage: alert-circle = recoverable state (the plan can be fixed), alert-triangle = irreversible action (the session will be permanently deleted).

- **Dialog padding `24px 20px` vs Pause panel `26px 22px`**: Modals (SCR-14, SCR-18) have tighter padding than the Pause panel (SCR-16). This makes sense — the Pause panel is a prominent on-screen fixture that doesn't need to feel contained, while a modal dialog should feel focused. Consistent: `24px 20px` is the dialog padding constant.

- **`stroke-width: 1.8` icon style**: All outlined icons in the system (SCR-11 trash, SCR-15 alert-circle, SCR-16 pause rects, SCR-17 none, SCR-18 alert-triangle) use `stroke-width: 1.8`. This is the confirmed icon stroke constant for the ForgeApp design system.

---

## Sign-off

| Role | Status | Date |
|------|--------|------|
| Design | Pending OQ-2 (tap-outside behaviour), OQ-4 (long plan name), OQ-5/6 (copy confirmation), OQ-8 (action row margin intent) | — |
| Engineering | Pending OQ-1 (back gesture interception — blocking), OQ-2 (modal dismiss behaviour), OQ-3 (SCR-17 routing), OQ-7 (SCR-11 component reuse) | — |
| PM | Pending OQ-5/6 (button copy confirmation), OQ-1 (back gesture policy confirmation) | — |
