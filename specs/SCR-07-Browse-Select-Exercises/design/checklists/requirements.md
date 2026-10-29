# Specification Quality Checklist: Browse & Select Exercises (SCR-07)

**Purpose**: Validate design specification completeness before proceeding to planning  
**Created**: 2026-09-11  
**Feature**: [spec.md](../spec.md)

---

## Section Completeness

- [x] §1 Overview & Goal — problem, both user contexts (browse + picker), success metrics
- [x] §2 User Flow — 2 entry points, 3 exit points, full state branching diagram covering all 6 UCs
- [x] §3 Screen-by-Screen — all 5 UI states (Loading/Skeleton, Populated Browse, Populated Picker, Empty/No Results, Error) + shared chrome
- [x] §4 Interactions — all 10 interactive elements documented, search behaviour, filter behaviour, picker add flow, transitions, keyboard, feedback
- [x] §5 Edge Cases — load failure, no-results (search vs. filter vs. empty catalogue), invalid reference, duplicate add, long name, rapid chip tap, picker back-without-select
- [x] §6 Responsive — 3 device size bands, iOS vs. Android (back gesture, keyboard, status bar), orientation noted
- [x] §7 Accessibility — touch target audit (4 elements flagged), contrast ratios for all major text pairs, focus order for all 5 states, screen reader labels for all interactive elements, shimmer/reduce-motion note
- [x] §8 Component Mapping — 8 reused DS components, 4 new/modified components with rationale
- [x] §9 AC Mapping — all 4 ACs + 2 EC edge cases from user story mapped
- [x] §10 Open Questions — 10 items with owner and impact

## Content Quality

- [x] Token values pulled from actual artboard HTML and Design System doc (not invented)
- [x] Exact copy/microcopy specified for all states (search placeholder, empty title + subtitle, error title + body, picker banner template, filter chip labels)
- [x] Data requirements mapped (`exercises` table, exerciseId validation, type flag → dot colour)
- [x] No implementation details (Bloc, widget names, file paths) in the spec body
- [x] Both modes (browse and picker) fully specified — not just one

## Open Items Requiring Resolution Before Build

| # | Item | Blocks build? |
|---|---|---|
| OQ-1 | Browse-mode entry point from SCR-06 not visible in artboards | **Yes** — entry path for browse mode is undefined; navigation gap |
| OQ-2 | Exercise row tap in browse mode — no detail screen defined | **Yes** — the chevron affordance implies navigation that doesn't exist yet |
| OQ-3 | Search debounce delay | No — 300 ms default is fine |
| OQ-4 | Success/rejection toast in picker mode | Minor — affects polish |
| OQ-5 | Empty catalogue (seed not run) empty state copy | No — edge case |
| OQ-6 | Duplicate exercise in picker mode | Minor — affects plan data |
| OQ-7 | Max exercise name lines in a row | Minor — layout detail |
| OQ-8 | Filter chip touch target below 44 pt | Minor — accessibility fix |
| OQ-9 | Back icon accessibility label in picker mode | No — accessibility wording |
| OQ-10 | Picker mode: push vs. modal presentation | Yes — affects back gesture on Android |

## Notes

- **OQ-1 and OQ-2 are the highest priority.** OQ-1 means browse mode has no confirmed entry path; OQ-2 means the chevron-right affordance on exercise rows in browse mode implies navigation that is undefined by the user story and inventory. These must be resolved before the screen can be implemented.
- **OQ-10 (push vs. modal)** is also important: if picker mode is presented modally, the Android back gesture and iOS swipe-to-dismiss behaviour differ from a standard push.
- The **type dot colour mapping** (Weighted = cyan / Time-based = lime / Bodyweight = muted) is confirmed from the artboard and Decisions Log §5 — this is not an open question.
- The **picker banner** is a new component not present anywhere else in the current design system. It should be extracted as a reusable `ContextBanner` if picker mode appears on other screens.
- All shimmer animation values (gradient stops, background-size, timing) were pulled directly from `Loading.dc.html` artboard code.
- Exact error card copy ("Couldn't load the exercise catalogue" / "Something went wrong reading local data.\nYour plans and history are unaffected.") is pulled verbatim from `Error.dc.html`.
