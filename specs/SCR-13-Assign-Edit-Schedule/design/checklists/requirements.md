# Design Specification Quality Checklist: SCR-13 — Assign / Edit Schedule

**Purpose**: Validate design specification completeness and quality before implementation  
**Created**: 2026-09-12  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/6f1d9550-c79a-4ae8-a2de-f8f45d9f362a

---

## Specification Completeness

- [x] §1 Overview & Goal — problem, user, goal, success metric, app context
- [x] §2 User Flow — entry points (3 sources), full state machine with all branches, exit points
- [x] §3 Screen-by-Screen Breakdown — all 6 states covered (New, Edit, Conflict, Invalid Plan, Saving, Save Failure); all measurements sourced from artboard CSS
- [x] §4 Interactions & Behavior — 11 interactions tabulated; save enable logic; helper text logic; transition table
- [x] §5 Edge Cases & Error Handling — 9 edge cases; own-days conflict exclusion (EC-9) and post-failure back navigation (EC-6) documented
- [x] §6 Responsive & Platform Considerations — 3 device bands; iOS safe-area and back-gesture note; Android system back interception
- [x] §7 Accessibility — touch target audit (5 elements, 2 flagged); contrast table (9 pairs, 3 flagged); full semantic labels per state; focus order
- [x] §8 Component & Design System Mapping — 8 reused components; 6 new components; 2 token gaps (dangerFill, dangerBorder)
- [x] §9 Acceptance Criteria Mapping — AC-1 through EC-4 and all FRs mapped; FR-7 noted as engineering constraint
- [x] §10 Open Questions / Assumptions — 8 OQs with owner/build-block/assumption; 5 explicit assumptions

---

## Design Grounding

- [x] All measurements taken from artboard CSS (not invented)
- [x] All copy strings taken verbatim from artboard HTML
- [x] Token values cross-checked against design system reference
- [x] Non-token values identified (`#2a1f1f` danger fill, `#5c3a3a` dangerBorder)
- [x] All 6 artboards read and accounted for in §3

---

## Blocking Issues

| # | Issue | Severity | Status |
|---|-------|---------|--------|
| OQ-2 | Invalid Plan banner tap target: no chevron shown; implementation cannot determine how to launch plan picker without design confirmation of tap area | **Blocking** | Open — Design to confirm banner is tappable CTA |
| OQ-4 | Data freshness: SCR-13 writes to Drift; SCR-12 must reflect the update immediately on pop; if SCR-12 uses a stale cached read, the user sees the old schedule right after saving | **Blocking** | Open — Engineering to confirm `initState`/`onResume` read strategy (shared with SCR-12 OQ-4) |

---

## Non-Blocking Open Questions

| # | Topic | Owner | Assumption held |
|---|-------|-------|----------------|
| OQ-1 | Multiple conflict chips: field error naming single vs all conflicts | Design | Names most recently tapped conflict; all chips turn red |
| OQ-3 | Recurrence toggle opacity:.5 in New vs 1.0 in Edit — intentional? | Design | Intentional; New dims it (not yet meaningful); Edit shows at full (established cadence) |
| OQ-5 | App bar title during Saving / Failure states in New flow | Design | Stays as entered ("New Schedule" or "Edit Schedule") |
| OQ-6 | Recurrence section absent from Saving/Failure/InvalidPlan artboards — intentional or simplification? | Design | Simplification; show all fields except where §3 explicitly hides them (State D) |
| OQ-7 | Own-days conflict detection in Edit mode | Engineering | Existing days excluded from conflict detection |
| OQ-8 | FR-7 (no history alteration) — any UI confirmation? | PM / Engineering | Pure engineering invariant, no UI |

---

## Design Consistency Notes

- **New tristate chip pattern**: SCR-13 introduces the first three-state interactive component in the design system — unselected / selected (lime) / conflict (red). This should be documented as a reusable pattern with clear state token assignments once `color.dangerFill` and `color.dangerBorder` are tokenised.

- **Two distinct banner types**: SCR-13 uses two visually similar but structurally different banners:
  - *In-field banner* (Invalid Plan, State D): replaces a form field; `1.5px solid #ff6b6b` border; inside `.content`
  - *Top-of-screen banner* (Save Failure, State F): above content; `1px solid #5c3a3a` border; `margin:0 20px 12px`  
  These must not be conflated. Recommend formalising as two named banner variants in the design system.

- **Recurrence toggle opacity difference (New vs Edit)**: Toggle shows `opacity:0.5` in New state and `opacity:1.0` in Edit state despite being locked in both. This is a meaningful visual distinction (New = not yet configured, Edit = confirmed weekly) and should be documented as a locked-toggle pattern variant.

- **`dangerBorder` (#5c3a3a) tokenisation**: Now used across SCR-09, 10, 11, 12, and 13 — five screens. Tokenisation is overdue. `dangerFill` (#2a1f1f) similarly appears on SCR-11, 12, and 13.

- **App bar dim pattern during save** (State E): Back icon and title both dim to `#8a8f7a` when navigation is locked. This is the same pattern as SCR-11 delete-loading. Should be codified as a "locked route" app bar variant.

- **Day chip touch target**: At 390px width the chips are ~43pt — borderline. On smaller screens (375px) they fall to ~41pt. Engineering must extend the hit area beyond the visual bounds. This is a systemic concern for the chip component definition.

---

## Sign-off

| Role | Status | Date |
|------|--------|------|
| Design | Pending review | — |
| Engineering | Pending OQ-2 + OQ-4 answers | — |
| PM | Pending OQ-8 confirmation | — |
