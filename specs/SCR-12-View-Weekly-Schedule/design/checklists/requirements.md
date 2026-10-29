# Design Specification Quality Checklist: SCR-12 — View Weekly Workout Schedule

**Purpose**: Validate design specification completeness and quality before implementation  
**Created**: 2026-09-12  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/197c0750-693e-409e-9034-d858cccfb0ff  

---

## Specification Completeness

- [x] §1 Overview & Goal — problem, user, goal, success metric, app context
- [x] §2 User Flow — entry points, state machine with all branches, exit points
- [x] §3 Screen-by-Screen Breakdown — all 4 states covered (Loading, Empty, Populated, Error); all measurements sourced from artboard CSS
- [x] §4 Interactions & Behavior — 11 interactions tabulated; transitions table; data freshness OQ called out
- [x] §5 Edge Cases & Error Handling — 8 edge cases; broken-plan-reference (EC-2) and post-completion state (EC-6) flagged
- [x] §6 Responsive & Platform Considerations — 3 device bands; iOS safe-area note; Android back note
- [x] §7 Accessibility — touch target audit (5 elements, 3 below 44pt); contrast table (13 pairs, 2 flagged); screen reader per state; focus order
- [x] §8 Component & Design System Mapping — 5 reused patterns; 5 new components; 2 token gaps
- [x] §9 Acceptance Criteria Mapping — AC-1 through EC-1 mapped; SEC-1/SEC-2 noted as app-level gate
- [x] §10 Open Questions / Assumptions — 8 OQs with owner/build-block/assumption; 5 explicit assumptions

---

## Design Grounding

- [x] All measurements taken from artboard CSS (not invented)
- [x] All copy strings taken verbatim from artboard HTML
- [x] Token values cross-checked against design system reference
- [x] Non-token values identified (`#35342f` shimmer, `#5c3a3a` danger border)
- [x] All 4 artboards read and accounted for in §3

---

## Blocking Issues

| # | Issue | Severity | Status |
|---|-------|---------|--------|
| OQ-4 | Data freshness: SCR-12 must re-read Drift on return from SCR-13; if stale cached data is shown the user sees an outdated schedule immediately after editing | **Blocking** | Open — Engineering to confirm `initState`/`onResume` read strategy |

---

## Non-Blocking Open Questions

| # | Topic | Owner | Assumption held |
|---|-------|-------|----------------|
| OQ-1 | Today row when no plan assigned | Design | Rest label + edit icon, same as non-today rest |
| OQ-2 | Re-tapping active Schedule tab | Engineering | Scroll-to-top |
| OQ-3 | Row body tap behaviour | Design | Only edit icon is tappable; row body is non-interactive |
| OQ-5 | Broken plan reference in scheduleEntry | Engineering | Treat as unscheduled; show "Rest day" |
| OQ-6 | Plan name truncation in row | Design | Single-line ellipsis |
| OQ-7 | Recurrence meta string format | PM / Engineering | "Weekly" is the only type; always shown as "Weekly" |
| OQ-8 | Post-completion state of Start button | PM / Design | Start button remains; no completion state on schedule view |

---

## Design Consistency Notes

- **Icon type for error state**: SCR-12 Error uses a warning triangle (transient/recoverable error), consistent with the error recovery intent. SCR-10 Error/Not-Found uses an X-in-circle (permanent/gone). This distinction should be formalised as an icon-choice guideline: warning triangle = retry possible; X-in-circle = no recovery path.
- **Day row card radius (14px)**: The day rows use `border-radius: 14px`, while SCR-08/10 exercise cards use 16px. This is a small intentional difference (list rows vs card-style panels) — confirm this is intentional and document as a pattern, not an inconsistency to fix.
- **Start button radius (9px)**: Distinctly smaller radius than the primary footer buttons (12–14px) and the CTA button (12px). The smaller radius gives the Start button a "chip" appearance appropriate for an inline action within a list row. Confirm this is intentional.
- **Safe-area bottom**: The artboard uses fixed 18px bottom padding in the nav bar. On iPhone 14+ with the Dynamic Island / home indicator, this may need to grow. Engineering should confirm `SafeArea` integration.
- **Token carry-forward**: `#5c3a3a` (dangerBorder) remains non-tokenised after SCR-09, SCR-10, SCR-11, and now SCR-12 — four screens. Tokenisation as `color.dangerBorder` is overdue.

---

## Sign-off

| Role | Status | Date |
|------|--------|------|
| Design | Pending review | — |
| Engineering | Pending OQ-4 answer | — |
| PM | Pending OQ-7 confirmation | — |
