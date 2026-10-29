# Specification Quality Checklist: Plan Detail (SCR-10)

**Purpose**: Validate design specification completeness before proceeding to planning  
**Created**: 2026-09-11  
**Feature**: [spec.md](../spec.md)

---

## Section Completeness

- [x] §1 Overview & Goal — problem, goal, business context (offline/Drift), success metric
- [x] §2 User Flow — 2 entry points, full state machine (Loading → Populated / Error, all 6 exit paths), table of destinations
- [x] §3 Screen-by-Screen — all 3 UI states: Loading/Skeleton, Populated (Main), Error/Not-Found + shared chrome
- [x] §4 Interactions — 8 interactions: back (all states), edit, delete, start workout, schedule, back to plans, content scroll, loading-cancel-back
- [x] §5 Edge Cases — 10 edge cases: planId not found, database read failure, broken exercise ref (OQ-1), empty plan (OQ-3), long name (OQ-2), large exercise count, post-delete navigation, delete cancel, stale data on resume, `exercises` table unavailable
- [x] §6 Responsive — 3 device size bands, iOS back-swipe, Android system back, skeleton card count assumption
- [x] §7 Accessibility — touch target audit (5 elements, 3 flagged), contrast table (9 pairs), screen reader labels for all elements across all 3 states, focus order (populated)
- [x] §8 Component Mapping — 6 reused DS components, 6 new/modified components, full token usage table
- [x] §9 AC Mapping — FR-1 through FR-7 mapped; 7 explicit ACs from user story covered
- [x] §10 Open Questions — 9 items with owner, build-block flag, and working assumption

## Content Quality

- [x] Token values pulled from actual artboard HTML (all 3 artboards) — not invented
- [x] Exact microcopy from artboards: plan title "Push Day — Upper Body", meta "3 exercises", section label "EXERCISES", error title "This plan is no longer available", error body "It may have been deleted, or something went wrong reading local data.", footer buttons "Schedule" / "Start Workout", error button "Back to Plans"
- [x] Three exercise type field layouts specified from Main.dc.html (same structure confirmed as SCR-09): Weighted (Sets/Reps/Weight row + full-width Rest row), Time-based (Sets/Duration/Rest), Bodyweight (Sets/Reps/Rest)
- [x] Type dot color-coding specified from Main artboard CSS: `.dot.weighted` → cyan (#7df4ff), `.dot.time` → lime (#c3f400), `.dot.bodyweight` → muted (#c4c9ac)
- [x] Value display formats confirmed from artboard HTML: Rest as "Ns" (e.g. "90s"), Weight as "N kg" (space + lowercase kg), Duration as mm:ss ("00:45"), Sets/Reps as plain integers
- [x] App bar layout differences across states documented: Populated has back + edit + delete; Loading has back + 2 skeleton placeholders; Error/Not-Found has back only + no bottom padding
- [x] Error card distinct from SCR-08: X-in-circle icon (not warning triangle), no Retry button, "Back to Plans" button only
- [x] Error border #5c3a3a flagged as non-token (same as SCR-08/09) — documented in §8 and §10 (A-2)
- [x] Icon button sizing documented: 34×34px card, 10px radius; edit icon 17×17 muted; delete icon 17×17 danger
- [x] Footer button spec: flex:1 each, 12px radius, 15px padding, 14px/800; secondary (card/border/white) vs primary (lime/#131315)
- [x] Skeleton shimmer spec: gradient `linear-gradient(90deg, #2a2a2c 25%, #35342f 37%, #2a2a2c 63%)`, 400% bg-size, 1.4s ease infinite — matches SCR-08 pattern
- [x] No implementation details (Bloc event names, widget file paths, database method signatures) in spec body — confined to §8 candidate widget names

## Open Items Requiring Resolution Before Build

| # | Item | Blocks build? |
|---|------|--------------|
| OQ-1 | Broken exercise reference (exerciseId not in catalogue): what does the card show? | **Yes** — FR-2, FR-5 |
| OQ-3 | Empty plan (0 exercises): is Start Workout disabled? No artboard for this state. | **Yes** — FR-5 |
| OQ-8 | Type dot 3-colour coding: confirm applies to SCR-09 exercise cards too; SCR-09 spec needs update | No (design alignment) |

Non-blocking (working assumptions in place):

| # | Item |
|---|------|
| OQ-2 | Long plan name: wrap vs. clamp |
| OQ-4 | Skeleton card count: always 3 vs. match stored count |
| OQ-5 | Re-read from the database on resume from child screens |
| OQ-6 | Post-delete navigation stack: pop SCR-10 from SCR-11 |
| OQ-7 | SCR-10 presentation style: push (assumed) |
| OQ-9 | "N exercises" count: raw vs. resolved |

## Notes

- **OQ-1 and OQ-3 are blocking.** OQ-1 — a broken exercise reference has no artboard coverage, and the resolution affects FR-2 (display) and FR-5 (Start Workout eligibility). OQ-3 — the empty-plan state has no artboard and its Start Workout disabled/enabled state is unspecified.
- **Type dot 3-colour coding (OQ-8)** is a new design fact from this artboard not visible in the SCR-09 spec. The SCR-09 spec should be updated to confirm that the exercise type row uses `cyan / lime / muted` dots (not a uniform colour). This is non-blocking for SCR-10 itself.
- **Error card design is intentionally different from SCR-08**: SCR-08 uses a warning triangle + "Retry" because the error is transient (local storage may recover). SCR-10 uses an X-in-circle + "Back to Plans" because both error causes (plan gone or read fail) share the same recovery path — returning to the list. No retry is surfaced.
- **The Delete icon button is danger-coloured in the app bar** (`color:#ff6b6b`), unlike the Edit icon which uses `color:var(--muted)`. This is consistent with the destructive nature of the action. Both buttons have the same card-fill background.
- **"Start Workout" is the primary CTA** (lime, right) and "Schedule" is the secondary (card, left). Button order follows the convention established in SCR-10: primary right, secondary left — consistent with SCR-09 ("Keep Editing" primary right, "Discard" secondary left).
- **The scratchpad files** for this spec are at: `SCR10-Main.dc.html`, `SCR10-Loading.dc.html`, `SCR10-ErrorNotFound.dc.html` in the session scratchpad.
