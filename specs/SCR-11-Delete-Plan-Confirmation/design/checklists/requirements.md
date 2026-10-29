# Design Specification Quality Checklist: SCR-11 — Delete Workout Plan Confirmation

**Purpose**: Validate design specification completeness and quality before implementation  
**Created**: 2026-09-12  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/068a136f-13f2-46a9-90b2-17153985d5f3  

---

## Specification Completeness

- [x] §1 Overview & Goal — written; includes problem, goal, UI pattern, business context, success metric
- [x] §2 User Flow — entry points, state machine diagram, exit points with plan-state column
- [x] §3 Screen-by-Screen Breakdown — all 3 states covered (Confirmation, Deleting, Delete Failure); all measurements sourced from artboard CSS
- [x] §4 Interactions & Behavior — 10 interactions tabulated; state transitions described; animation assumptions documented
- [x] §5 Edge Cases & Error Handling — 8 edge cases; EC-2 (Drift atomicity) flagged as blocking OQ-4
- [x] §6 Responsive & Platform Considerations — 3 device bands; iOS/Android platform notes
- [x] §7 Accessibility — touch targets (3 buttons all below 44 pt, all flagged); contrast table (9 pairs); screen reader annotations per state; focus order per state
- [x] §8 Component & Design System Mapping — reuse from SCR-09 patterns; 4 new components; 4 token gaps identified
- [x] §9 Acceptance Criteria Mapping — AC-1 through EC-1 mapped; FR-4 and SEC-2 covered
- [x] §10 Open Questions / Assumptions — 7 OQs with owner/build-block/assumption; 5 explicit assumptions

---

## Design Grounding

- [x] All measurements taken from artboard CSS (not invented)
- [x] All copy strings taken verbatim from artboard HTML
- [x] Token values cross-checked against design system reference
- [x] Non-token values identified and flagged for tokenisation (`#2a1f1f`, `#5c3a3a`, `#2a1414`)
- [x] All 3 artboards read and accounted for in §3

---

## Blocking Issues

| # | Issue | Severity | Status |
|---|-------|---------|--------|
| OQ-4 | Drift delete transaction atomicity — plan + schedule entries removed atomically? Non-atomic partial failure creates orphaned schedule entries | **Blocking** | Open — needs Engineering + PM answer |

---

## Non-Blocking Open Questions

| # | Topic | Owner | Assumption held |
|---|-------|-------|----------------|
| OQ-1 | Button order inconsistency vs SCR-09 Discard dialog | Design | SCR-11 is correct (iOS std); SCR-09 is the exception |
| OQ-2 | Scrim tap dismissal in Confirmation + Delete Failure states | Design | Scrim tap = Cancel |
| OQ-3 | Back gesture / system back during Deleting state | Engineering | Block navigation during Deleting; allow in other states (= Cancel) |
| OQ-5 | Error message fade-in animation | Design | 150–200 ms fade |
| OQ-6 | Plan name truncation in subtitle | Design | Free wrap, no truncation |
| OQ-7 | Tablet max-width cap | Design | `max-width: 420px` centred |

---

## Design Consistency Notes

- **New button style**: The Delete button (red fill `#ff6b6b` / text `#2a1414`) is a new variant not previously formalised. Should be registered as `ButtonStyle.destructive` in the design system.
- **Retry is lime, not red**: This is intentional — confirmed by artboard. The destructive decision was already made; Retry is a neutral action.
- **Token gap carry-forward**: `#2a1f1f` (dangerBg) and `#5c3a3a` (dangerBorder) were first seen in SCR-09 and SCR-10; SCR-11 is the third screen using them. Tokenisation is overdue.
- **OQ-8 carry-forward from SCR-10**: The 3-colour exercise type dot coding (cyan/lime/muted) confirmed in SCR-10 should be verified in SCR-09 spec. Not a SCR-11 concern but flagged for cross-spec consistency.

---

## Sign-off

| Role | Status | Date |
|------|--------|------|
| Design | Pending review | — |
| Engineering | Pending OQ-4 answer | — |
| PM | Pending OQ-4 (scope) | — |
