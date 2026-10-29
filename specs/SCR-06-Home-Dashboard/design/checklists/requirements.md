# Specification Quality Checklist: Home Dashboard (SCR-06)

**Purpose**: Validate design specification completeness before proceeding to planning  
**Created**: 2026-09-10  
**Feature**: [spec.md](../spec.md)

---

## Section Completeness

- [x] §1 Overview & Goal — problem, user, success metric
- [x] §2 User Flow — all entry points (5), all exit points, full state branching diagram
- [x] §3 Screen-by-Screen — all 5 UI states (Loading, Empty, Populated-Scheduled, Populated-No-Workout, Error) + Shared Chrome + Quick Links
- [x] §4 Interactions — all 16 tappable elements, transitions for all state changes, no forms on this screen, feedback mechanisms
- [x] §5 Edge Cases — network N/A, 4 empty-state variants, permissions N/A, 8 boundary conditions
- [x] §6 Responsive — 3 device size bands, iOS vs Android differences, orientation note
- [x] §7 Accessibility — touch targets with flagged issue (Retry button below 44pt), contrast ratios for all major pairs, focus order for all 5 states, semantic labels
- [x] §8 Component Mapping — 8 reused DS components, 6 new/modified components with rationale
- [x] §9 AC Mapping — all 4 ACs from user story mapped
- [x] §10 Open Questions — 10 items with owner and impact

## Content Quality

- [x] Token values pulled from actual artboard HTML and Design System doc (not invented)
- [x] Exact copy/microcopy specified for all states
- [x] Data requirements mapped to storage records and table names
- [x] No implementation details (Bloc, widget names, file paths) in the spec body
- [x] All state variants have complete component specs

## Open Items Requiring Resolution Before Build

| # | Item | Blocks build? |
|---|---|---|
| OQ-1 | Loading pattern: spinner (approved per user story) vs Design System skeleton | No — spinner is approved; skeleton would be a future upgrade |
| OQ-2 | Profile/Account access point from SCR-06 | **Yes** — Profile screen (SCR-25) must be reachable from somewhere |
| OQ-3 | Empty CTA navigation: modal vs tab-push | Yes — affects navigation stack and back behavior |
| OQ-4 | Rest period chip: mode vs first vs average | Minor — any deterministic rule works |
| OQ-5 | Deleted plan referenced by schedule entry | Yes — needs a defined data-integrity behavior |
| OQ-6 | Android back gesture from SCR-06 | Yes — platform behavior must be defined |
| OQ-7 | Retry button height below 44pt | Minor — increase padding |
| OQ-8 | Cyan on Quick Link icons violates reserved-color rule | No — but should be confirmed by designer |
| OQ-9 | Time-of-day greeting variation | No — static "Welcome back" works |
| OQ-10 | Section label on rest-day card | No — artboard shows no label; current spec matches artboard |

## Notes

- OQ-2 (Profile access point) is the highest-priority open item — without a defined entry point to SCR-25/SCR-26, the user has no way to log out or edit their profile.
- The artboard used cyan (`#7df4ff`) on Quick Link icons despite the Design System marking it as reserved. This must be confirmed or corrected before the feature is implemented (OQ-8).
- All exact microcopy was pulled from the Canvas artboard HTML — these are the strings to use verbatim unless OQ-9 or OQ-10 change them.
- The "has data" check covers all three tables (plans, schedule entries, workout sessions). If all three are empty → Empty state; if any has data → Populated state (even if today has no schedule).
