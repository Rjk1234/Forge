# Design Specification Quality Checklist: SCR-15 — Workout Pre-Start / Overview

**Purpose**: Validate design specification completeness and quality before implementation  
**Created**: 2026-09-12  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/16366a19-a2a2-48fe-aa85-97478f08e10e

---

## Specification Completeness

- [x] §1 Overview & Goal — problem, user, goal, success metric, app context (offline/Drift) documented
- [x] §2 User Flow — all 4 states in state machine; all entry points (SCR-10, SCR-12); all exit points (SCR-16, back, Back to Schedule); Retry loop documented
- [x] §3 Screen-by-Screen Breakdown — all 4 states covered (Loading, Plan Preview, Invalid Plan, Load Failure); shared structure separated; all measurements sourced from artboard CSS; no invented values
- [x] §4 Interactions & Behavior — 9 interactions tabulated; state transition table; footer gradient behaviour noted
- [x] §5 Edge Cases & Error Handling — 10 edge cases; empty plan, exception, back-during-load, double-tap Retry, long names, single exercise, unset weight, scroll depth
- [x] §6 Responsive & Platform Considerations — 3 device width bands; iOS/Android back gesture; portrait-only noted; scroll behaviour per state
- [x] §7 Accessibility — touch target audit (back chevron flagged); contrast table (13 pairs, 3 flagged as Design intent); semantics per state including liveRegion annotations
- [x] §8 Component & Design System Mapping — 24 component entries; 3 token gaps (transparent bg, type dot formalisation, letter-spacing value); SCR-09/10 reuse confirmed
- [x] §9 Acceptance Criteria Mapping — all ACs, FRs, ECs, and NFR mapped; offline constraint documented
- [x] §10 Open Questions / Assumptions — 7 OQs with owner/build-block/assumption; 6 explicit assumptions

---

## Design Grounding

- [x] All measurements taken from artboard CSS (not invented)
- [x] All copy strings taken verbatim from artboard HTML
- [x] Token values cross-checked against design system reference
- [x] Non-token values identified (`rgba(19,19,21,0)` footer gradient, type dot system not formalised)
- [x] All 4 artboards read and accounted for in §3

---

## Blocking Issues

| # | Issue | Severity | Status |
|---|-------|---------|--------|
| OQ-1 | Routing ambiguity for "Back to Schedule": if entered from SCR-10 (Plan Detail), does this button navigate to SCR-12 or pop to SCR-10? The artboard shows "Back to Schedule" as a labelled action implying SCR-12 is always the target, but the user story lists both SCR-10 and SCR-12 as entry points. Incorrect routing would strand the user on the wrong screen. | **Blocking** | Open — PM / Design to confirm routing intent |
| OQ-2 | Zero-exercise plan treatment: does an empty plan (all exercises removed) render as Invalid (State C) or as an empty-list Plan Preview (State B) with Begin Workout disabled? The artboard does not show this scenario and both interpretations are design-valid. | **Blocking** | Open — PM / Design to confirm |

---

## Non-Blocking Open Questions

| # | Topic | Owner | Assumption held |
|---|-------|-------|----------------|
| OQ-3 | Weight field box when exercise is Weighted but weight is 0 / unset | Design | Show "—" |
| OQ-4 | Max-width cap for large screens / tablets | Design / Engineering | None set — revisit at tablet scope |
| OQ-5 | Plan meta format: "scheduled for today" qualifier shown only when schedule day = today | PM / Engineering | Yes, today-only qualifier |
| OQ-6 | SCR-15 entry from SCR-10 without a schedule: meta copy — "X exercises" only, no "scheduled for" | PM / Engineering | Meta omits scheduling copy |
| OQ-7 | Timeout handling for hanging Drift read | Engineering | No timeout; Flutter exception surfaces naturally |

---

## Design Consistency Notes

- **New screen-level centred error/invalid layout (States C, D)**: First instance in the design system of a full-screen vertically-centred state (not a banner, not a dialog). Compare: SCR-11's delete confirmation is a modal; SCR-13's invalid-plan state is a form-field-level banner; SCR-15's invalid state is a full-screen terminal. Document as "CentredBlockingState" in the design system.

- **Dual icon distinction for blocking states**: State C uses an alert circle (plan semantics: something about the plan itself is wrong); State D uses a calendar-with-error icon (loading semantics: something went wrong reading). This icon choice is intentional and must be preserved — they are **not** interchangeable.

- **Primary / secondary stacked footer (State D)**: First occurrence in the design system of a two-button stacked footer with explicit primary/secondary hierarchy. Primary (Retry): lime/16px padding/800/15px. Secondary (Back to Schedule): card-alt/14px padding/700/14px. The secondary button is visually subordinate in 3 ways (padding, weight, size). Document as the canonical dual-footer pattern.

- **`letter-spacing:.06em` on SectionLabel**: SCR-13 used `.08em` for field labels. SCR-15 uses `.06em` for its section label. These are different elements (section label vs. field label), but confirm whether `.06em` vs `.08em` is intentional or an artboard inconsistency.

- **Footer gradient (State B only)**: `linear-gradient(180deg, rgba(19,19,21,0) 0%, #131315 40%)` — the solid fill is reached at 40% from top, meaning the top 60% of the footer area is partially transparent. This is the first scrollable-content screen in the spec series to use a footer gradient. Other screens (SCR-13) use a solid-fill footer with a `border-top` divider. Document gradient vs. divider as context-dependent: gradient for long scrollable lists, divider for fixed-content forms.

- **Field-label at 9px**: The smallest text token in the design system so far. Three explicit contrast flags in §7 (section label, type label, field label) are all Design intent — they are secondary / decorative labels where the primary information is in the value or the icon. This should be documented as an accessibility known-trade-off rather than a bug.

- **Begin Workout button radius: 14px** vs SCR-13's Save button at 12px**: Two different primary action button radii in the same app. SCR-15's 14px matches the exercise card radius. SCR-13's 12px matches the form field radius. The button radius appears to track the surrounding card context — confirm whether this is intentional or should be standardised.

- **Back to Schedule secondary button first appearance**: `font-weight:700` (not 800) and `font-size:14px` (not 15px). This is the first secondary CTA button in any spec so far. If a SecondaryButton component is introduced, these values should be its canonical defaults.

---

## Sign-off

| Role | Status | Date |
|------|--------|------|
| Design | Pending review — OQ-1 (routing), OQ-2 (empty plan), OQ-5 (meta copy), OQ-6 (ad-hoc entry copy) | — |
| Engineering | Pending OQ-1 (routing), OQ-2 (empty plan treatment), OQ-7 (timeout) | — |
| PM | Pending OQ-1 (routing intent), OQ-2 (empty plan), OQ-5, OQ-6 | — |
