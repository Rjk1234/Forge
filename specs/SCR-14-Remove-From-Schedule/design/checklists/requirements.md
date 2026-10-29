# Design Specification Quality Checklist: SCR-14 — Remove From Schedule Confirmation

**Purpose**: Validate design specification completeness and quality before implementation  
**Created**: 2026-09-12  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/90414205-4601-4c88-8926-46c81d29655a

---

## Specification Completeness

- [x] §1 Overview & Goal — problem, user, goal, success metric, app context, lime-vs-red design rationale documented
- [x] §2 User Flow — entry points, full state machine (all branches including retry loop), exit points, dismiss behaviour matrix
- [x] §3 Screen-by-Screen Breakdown — all 3 states covered (Confirmation, Loading, Failure); all measurements sourced from artboard CSS; shared structure documented separately to avoid repetition
- [x] §4 Interactions & Behavior — 11 interactions tabulated; dismiss behaviour table; transition notes; debounce requirement (EC-6)
- [x] §5 Edge Cases & Error Handling — 7 edge cases; scrim-lock, OS-back-lock, cancel-after-failure, rapid-retry debounce documented
- [x] §6 Responsive & Platform Considerations — 3 device bands; max-width OQ for tablet; iOS/Android back gesture; portrait-only noted
- [x] §7 Accessibility — touch target audit (2 elements, both ⚠️ borderline); contrast table (7 pairs, 2 flagged); dialog semantics and focus management; liveRegion for error
- [x] §8 Component & Design System Mapping — 10 component entries; 3 token gaps (scrim, dangerFill, dangerBorder); lime-not-red intent documented
- [x] §9 Acceptance Criteria Mapping — all ACs, FRs, and NFRs mapped; SEC-1/SEC-2 noted as app-level gates
- [x] §10 Open Questions / Assumptions — 7 OQs with owner/build-block/assumption; 5 explicit assumptions

---

## Design Grounding

- [x] All measurements taken from artboard CSS (not invented)
- [x] All copy strings taken verbatim from artboard HTML
- [x] Token values cross-checked against design system reference
- [x] Non-token values identified (`rgba(10,10,10,0.62)` scrim, `#2a1f1f` danger fill, `#5c3a3a` dangerBorder)
- [x] All 3 artboards read and accounted for in §3

---

## Blocking Issues

| # | Issue | Severity | Status |
|---|-------|---------|--------|
| OQ-3 | Sub-text copy when scheduleEntry covers multiple days: artboard shows "will no longer be scheduled on Monday" (single day), but a typical entry covers M/W/F. Removing removes all days — copy cannot be finalised without PM/Design decision on single-day vs multi-day phrasing | **Blocking** | Open — PM / Design to confirm copy template for multi-day entries |
| OQ-7 | Data freshness on modal dismiss: same issue as SCR-12 OQ-4 and SCR-13 OQ-4 — SCR-12 must reflect the removal immediately when the modal dismisses | **Blocking** | Open — Engineering to confirm Drift read strategy (shared with SCR-12 OQ-4) |

---

## Non-Blocking Open Questions

| # | Topic | Owner | Assumption held |
|---|-------|-------|----------------|
| OQ-1 | SCR-13 listed as entry dependency — can SCR-14 actually be triggered from SCR-13 UI? | PM / Design | No; SCR-12 is the only trigger |
| OQ-2 | Scrim tap dismisses modal in States A and C — confirmed behavior? | Design | Yes, follows platform-standard dialog behavior |
| OQ-4 | Dialog card border-radius 18px — canonical for modal dialogs specifically? | Design | Yes, intentional; lower values are for content cards |
| OQ-5 | Dialog enter/exit animation spec | Design | Platform-standard: iOS fade+scale ~250ms; Android fade-through ~200ms |
| OQ-6 | max-width cap on dialog for tablet screens | Engineering / Design | Recommend max-width:340px |

---

## Design Consistency Notes

- **Lime Remove button (not red)**: SCR-14 deliberately uses lime for its primary destructive action, contrasting with SCR-11's red Delete button. This establishes a two-tier destructive action color scheme in ForgeApp: **red = irreversible, high-stakes** (Delete Plan, which removes all associated history context); **lime = recoverable, low-stakes** (Remove Schedule Entry, which the user can immediately re-add via SCR-13). This distinction must be formalised as a design system guideline before more destructive actions are introduced.

- **Dialog card border-radius: 18px**: First appearance of 18px radius in the design system. Prior full-card components use 14px (schedule rows), 16px (error cards), 12px (form fields, selectors). 18px reads as "softer/more modal" — document this as the canonical value for overlay dialogs specifically.

- **Scrim color: `rgba(10,10,10,0.62)`**: The red channel and green channel are `10`, not `0` — this is a warm near-black, not pure black. Visually imperceptible but should be tokenised consistently. Confirm whether this matches SCR-11's scrim (if any) and other overlay scrims in the design system.

- **Button height borderline on touch targets**: Both action buttons at `padding:12px` result in approximately 40–42pt height — just below the 44pt accessibility minimum. This is a recurring issue (SCR-12 Start button at 9px radius was also flagged). Recommend `padding:14px` as the standard minimum for full-width and flex action buttons in dialogs.

- **Inline dialog error block vs. top-of-screen banner**: SCR-14 introduces a third distinct error presentation — an inline block inside a dialog, styled with `border-radius:10px` and `padding:9px 12px`. Compare with: SCR-12 (full-screen error card, `border-radius:16px`), SCR-13 (save failure banner above content with `margin:0 20px 12px`), SCR-13 Invalid Plan banner (replaces a form field). Each context uses a correctly scoped error form. Document all four as the error-presentation taxonomy in the design system.

- **`dangerBorder` (#5c3a3a) tokenisation**: Six screens now use this value (SCR-09–14). Tokenisation is overdue. `dangerFill` (#2a1f1f) is also at four screens (SCR-11–14). Recommend a design system token sprint before SCR-15 onwards.

- **Spinner size regression to 15×15px**: SCR-14 uses a 15×15px spinner with `border:2px` inside a dialog action button. Prior spinners (SCR-11, SCR-13) are 18×18px with `border:2.5px`. The smaller size is appropriate for the tighter button context; document both as named spinner variants (e.g. `spinner-sm` and `spinner-md`).

---

## Sign-off

| Role | Status | Date |
|------|--------|------|
| Design | Pending review — OQ-3 (copy), OQ-4 (radius), OQ-5 (animation) | — |
| Engineering | Pending OQ-7 (data freshness) | — |
| PM | Pending OQ-3 (multi-day copy template) | — |
