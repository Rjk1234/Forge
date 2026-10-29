# Specification Quality Checklist: Workout Plans List (SCR-08)

**Purpose**: Validate design specification completeness before proceeding to planning  
**Created**: 2026-09-11  
**Feature**: [spec.md](../spec.md)

---

## Section Completeness

- [x] §1 Overview & Goal — problem, user goal, business context (root Plans tab screen), success metrics table
- [x] §2 User Flow — single entry point (Plans tab), 4 states with full state-branching diagram, 4 exit points, all 4 UC rows mapped
- [x] §3 Screen-by-Screen — all 4 UI states (Loading/Skeleton, Populated, Empty, Error) + shared chrome (app bar + bottom nav)
- [x] §4 Interactions — 8 interaction types documented (tab entry, plan row tap, FAB tap, CTA tap, Retry tap, nav tab taps, pull-to-refresh ruling, transitions)
- [x] §5 Edge Cases — 7 edge cases (read failure, empty exercise count, single plan, long name, many plans, repeated Retry failure, plan deleted in child screen)
- [x] §6 Responsive — 3 device bands, iOS vs. Android platform notes, orientation decision
- [x] §7 Accessibility — touch target audit (3 elements flagged), contrast ratios for all major pairs, focus order for all 4 states, screen reader labels for all interactive elements, reduce-motion note for shimmer
- [x] §8 Component Mapping — 7 reused DS components, 4 new/modified components with rationale
- [x] §9 AC Mapping — all 4 ACs + EC-1 mapped; FR coverage table (FR-1 through FR-6 all covered)
- [x] §10 Open Questions — 10 items with owner, build impact, and working assumption

## Content Quality

- [x] Token values pulled from actual artboard HTML (Main.dc.html, Empty.dc.html, Loading.dc.html, Error.dc.html) — not invented
- [x] Exact microcopy specified for all states: screen title, plan meta ("N exercises"), empty title + subtitle + CTA label, error title + body + retry label
- [x] Data requirements mapped (`workout_plans` table, exerciseIds → count derivation, planId for SCR-10 navigation)
- [x] No implementation details (Bloc, widget names, file paths) in the spec body
- [x] Artboard delta noted: Loading shows FAB skeleton placeholder (card fill, no icon) — not the live lime button
- [x] Artboard delta noted: Empty and Error app bars use `padding:6px 20px 0` (no bottom padding) vs. Populated/Loading `padding:6px 20px 16px`
- [x] Singular/plural copy rule captured (OQ-6 assumption: "1 exercise" / "N exercises")

## Open Items Requiring Resolution Before Build

| # | Item | Blocks build? |
|---|---|---|
| OQ-1 | Database read trigger: on every tab visit or first visit only? | **Yes** — state management and BLoC/Cubit lifecycle |
| OQ-2 | FAB interactivity during Loading state | Minor — UX polish |
| OQ-3 | Pull-to-refresh gesture | No — V1 assumption is: not implemented |
| OQ-4 | Plan name truncation (1-line ellipsis vs. 2-line wrap) | Minor — layout |
| OQ-5 | Return state refresh after SCR-09 / SCR-10 child screens | **Yes** — state management when popping back to SCR-08 |
| OQ-6 | Singular/plural exercise count copy | Trivial — content rule |
| OQ-7 | Empty-state app bar bottom-padding intentionality | Minor — layout confirmation |
| OQ-8 | Navigation presentation type (push vs. modal) for SCR-09 / SCR-10 exits | **Yes** — affects back gesture on both platforms |
| OQ-9 | Exercise count source in storage record (derived vs. pre-computed) | Yes — data model |
| OQ-10 | Error body copy future-proofing | Low — V1 assumption stands |

## Notes

- **OQ-1, OQ-5, and OQ-8 are the highest priority.** OQ-1 and OQ-5 together define when SCR-08 reads Drift and whether it updates stale data after a child screen modifies plans. OQ-8 determines navigation architecture for both create (SCR-09) and detail (SCR-10) exits.
- **OQ-9 (exercise count source)** is important for the data model: if `exerciseIds` is not directly accessible on the plan record without a secondary database read, the count derivation is more expensive than a simple `.length`.
- SCR-08 is a **root screen** (bottom nav present and active on all 4 states) — unlike SCR-07 which is secondary (no bottom nav). This is confirmed by all 4 artboards.
- The **"+" FAB is absent in the Empty and Error states** — this is an intentional design decision. The Empty state provides the "Create a workout plan" CTA as the primary action; the Error state should not invite plan creation while data is unreadable.
- The **Loading state shows a FAB skeleton** (card fill, 38 × 38 pt, no icon) rather than hiding the FAB slot — this preserves layout stability between loading and populated states and avoids a layout jump when the lime FAB appears.
- Shimmer gradient and timing values (`#2a2a2c → #35342f → #2a2a2c`, 1.4 s ease infinite) are pulled directly from `Loading.dc.html` and match the SCR-07 skeleton pattern exactly — confirming a shared skeleton token.
- Error card copy ("Couldn't load your workout plans" / "Something went wrong reading local data.\nYour history is unaffected.") pulled verbatim from `Error.dc.html`.
- The plan meta `.dot` separator class (3 × 3 pt dim circle) is defined in `Main.dc.html` CSS but **not used in any plan-meta `<div>` in the artboard HTML** — the artboard shows plain text ("6 exercises") without a leading or separating dot. Do not implement a dot separator unless the artboard is updated or confirmed by design.
