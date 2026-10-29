# Design Specification Quality Checklist: SCR-16 — Active Workout — Exercise & Set Logging

**Purpose**: Validate design specification completeness and quality before implementation  
**Created**: 2026-09-13  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/c07e56bd-be35-430e-9d95-299de1058efd

---

## Specification Completeness

- [x] §1 Overview & Goal — problem, user, goal, success metric, app context, completion criterion (Decisions Log §1), cancel behaviour (§2), deferred background behaviour (§6b) all documented
- [x] §2 User Flow — full state machine (Active/Validation/Paused + skip path); entry point (SCR-15); all exit points (SCR-18, SCR-19, pause→resume); progress model explained
- [x] §3 Screen-by-Screen Breakdown — all 4 artboard states covered (Active, Validation, TimeBased validation, Paused); shared structure separated; all measurements sourced from artboard CSS
- [x] §4 Interactions & Behavior — 10 interactions tabulated; transition notes; input pre-fill behaviour; keyboard management noted
- [x] §5 Edge Cases & Error Handling — 12 edge cases; all FRs/ECs from user story; deferred background noted; multi-field validation; keyboard management
- [x] §6 Responsive & Platform Considerations — 3 device width bands; iOS/Android back gesture (OQ-5); keyboard management; portrait-only
- [x] §7 Accessibility — touch target audit (5 elements, 4 borderline); contrast table (18 pairs, 7 flagged as Design intent); per-state semantic annotations; liveRegion guidance
- [x] §8 Component & Design System Mapping — 30 component entries; 8 new patterns identified with rationale; token gaps; reused patterns from prior screens
- [x] §9 Acceptance Criteria Mapping — all ACs, FRs, ECs, NFRs, and SEC requirements mapped; deferred items noted
- [x] §10 Open Questions / Assumptions — 10 OQs with owner/build-block/assumption; 6 explicit assumptions

---

## Design Grounding

- [x] All measurements taken from artboard CSS (not invented)
- [x] All copy strings taken verbatim from artboard HTML
- [x] Token values cross-checked against design system reference
- [x] Non-token values identified (`#2a1f1f` danger fill — now on 5 screens; still not tokenised)
- [x] All 4 artboards read and accounted for in §3
- [x] Bodyweight exercise not mocked — gap acknowledged and documented (OQ-1)

---

## Blocking Issues

| # | Issue | Severity | Status |
|---|-------|---------|--------|
| OQ-3 | Skipped sets/exercises visual treatment: the artboard shows Skip button always present but never shows the post-skip state. Is a skipped set dot a distinct colour? Does Skip apply to the current set or the entire exercise? Incorrect implementation could either skip too much (whole exercise) or too little (one set at a time when the design intended whole-exercise skip). | **Blocking** | Open — Design / Engineering to specify skip scope and visual treatment |
| OQ-4 | Finish trigger: no "Finish Workout" button or variant label is depicted in the artboard. It's unclear whether "Complete Set" on the last set is the Finish trigger, or whether a separate Finish state/button appears after all exercises are done. This determines the SCR-19 routing logic. | **Blocking** | Open — Design / PM to confirm Finish trigger |
| OQ-5 | OS back gesture / hardware back routing: direct pop would silently discard the session without confirmation. SCR-18 must intercept this, but the artboard does not show this interaction path. | **Blocking** | Open — Engineering to implement SCR-18 interception for back gesture |

---

## Non-Blocking Open Questions

| # | Topic | Owner | Assumption held |
|---|-------|-------|----------------|
| OQ-1 | Bodyweight field layout: 1-column vs 2-column with empty right cell | Design | 1-column, full width |
| OQ-2 | EntryCard border-radius 16px — new value, is it canonical for entry cards? | Design | Yes, intentional |
| OQ-6 | Cancel tappable during Pause at opacity:.5? | Engineering | Yes, routes to SCR-18 |
| OQ-7 | Set dot row wrapping at 15+ sets | Design | Wraps to second line |
| OQ-8 | Max-width cap on large screens | Design / Engineering | None — revisit at tablet |
| OQ-9 | Blur-time vs on-attempt validation | Design | On-attempt only |
| OQ-10 | "Paused at HH:MM:SS" = elapsed time or wall-clock | PM / Engineering | Elapsed workout time |

---

## Design Consistency Notes

- **ALL CAPS muted app bar title**: "ACTIVE WORKOUT" is the only screen in the app with an ALL CAPS title in muted (#c4c9ac) colour. All other screens use mixed-case titles in white. This is intentional — it signals ambient status ("you are in a session") vs. a navigable page title. Document as the "ActiveSession" app-bar variant in the design system.

- **No back chevron**: SCR-16 is the first screen without a back navigation icon in the app bar. The Cancel link (danger red, right-aligned) is the only explicit exit. The absence of back chevron is intentional — it prevents accidental navigation away from an active session. The OS back gesture must be intercepted and routed to SCR-18.

- **Dual progress indicators**: SCR-16 is the first screen with two simultaneous progress dimensions — an exercise progress bar (top) and set progress pill dots (inline). The bar uses a conventional thin track; the dots are 26×6px pills (not circles). This pill shape is unique to this screen.

- **Set pill dots vs type dots**: Type dots (SCR-09/10/15/16) are 8×8px (SCR-15) or 9×9px (SCR-16) squares — this 1px difference between screens should be reconciled. Set pills (SCR-16) are 26×6px. These are distinct components despite both being called "dots" in conversation.

- **Paused state: no dark scrim**: Three overlay techniques now exist:
  1. **Dark scrim** (`rgba(10,10,10,0.62)`) — modal dialogs (SCR-11, SCR-14)
  2. **No-background panel** — SCR-16 Pause: content dimmed via `opacity:.35 + grayscale(.4)`, no overlay colour
  3. **Route-level full-screen states** — SCR-15 Invalid/Error: full replacement states, no overlay
  Document all three as the overlay taxonomy.

- **Inline input invalid state (field value red)**: First instance of `color:#ff6b6b` applied to the INPUT VALUE text itself (not just the border or a label below). Prior error styling (SCR-13 save failure, SCR-14 dialog error) kept field values in their normal colour. This creates a strong visual signal that the entered number itself is wrong.

- **FieldInput border-radius: 12px** — field inputs in SCR-16 use 12px, same as SCR-13 form fields. Entry card itself uses 16px. Consistent internal radius hierarchy: container 16px → field 12px.

- **PausePanel border-radius: 18px** — matches SCR-14's dialog radius (18px). Confirmed as the modal/overlay card radius (vs. 14px for content cards, 16px for entry cards).

- **Resume button vs Complete Set**: Resume uses 12px radius + 14px padding + 14px font. Complete Set uses 14px radius + 16px padding + 15px font. Resume is visually subordinate even though it fills the same width — the size delta communicates "resuming state" vs "completing a primary action". The same primary/secondary sizing logic as SCR-15's dual footer.

- **`#2a1f1f` danger fill — 5th occurrence**: Now appears on SCR-11 (Delete confirm), SCR-12 (error banner), SCR-13 (Invalid Plan banner + Save failure), SCR-14 (dialog error block), SCR-16 (invalid field input). Tokenisation is now overdue — propose `color.dangerFill: #2a1f1f` alongside the existing `color.dangerBorder: #5c3a3a` in the next design system sprint.

- **Progress bar fill percentage is illustrative**: The artboard shows 38% fill for "Exercise 2 of 5" (which would suggest 40%). Implementation should compute the exact percentage from actual exercise counts, not match the artboard value pixel-for-pixel.

- **Pause timer format**: "Paused at 00:14:22" — HH:MM:SS format with leading zeros. Confirm whether this is always HH:MM:SS or collapses to MM:SS for durations under 1 hour (OQ-10 extended).

---

## Sign-off

| Role | Status | Date |
|------|--------|------|
| Design | Pending OQ-3 (skip visual), OQ-4 (finish trigger), OQ-1 (bodyweight layout), OQ-2 (radius canonical), OQ-7 (dot wrap) | — |
| Engineering | Pending OQ-3 (skip logic), OQ-4 (finish routing), OQ-5 (back gesture), OQ-6 (pause cancel), OQ-9 (validation timing), OQ-10 (timer format) | — |
| PM | Pending OQ-4 (finish trigger definition — relates to Decisions Log §1 completion criterion) | — |
