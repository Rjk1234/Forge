# Specification Quality Checklist: Create / Edit Workout Plan (SCR-09)

**Purpose**: Validate design specification completeness before proceeding to planning  
**Created**: 2026-09-11  
**Feature**: [spec.md](../spec.md)

---

## Section Completeness

- [x] §1 Overview & Goal — problem, dual-mode framing (create vs. edit), business context (offline/Drift), success metrics
- [x] §2 User Flow — 3 entry points, full state machine diagram (12 UCs covered), 3 exit points
- [x] §3 Screen-by-Screen — all 6 UI states: Create (blank), Edit (populated), Validation Errors, Saving (loading), Save Failure, Discard Confirmation + shared chrome
- [x] §4 Interactions — 10 interaction types: plan name field, field boxes, remove button, add exercise, save button state machine, retry save, back navigation, discard dialog, transitions, keyboard behaviour
- [x] §5 Edge Cases — 10 edge cases (blank name, invalid exercise ref, non-positive reps/weight/duration, database write failure, repeat retry, empty list save, long name, all exercises removed)
- [x] §6 Responsive — 3 device bands, iOS-specific (keyboard, swipe-to-dismiss guard), Android-specific (system back), keyboard-present layout
- [x] §7 Accessibility — touch target audit (6 elements flagged), contrast ratios for all major pairs, screen reader labels for all elements across all 6 states, focus order for each state
- [x] §8 Component Mapping — 11 reused DS components, 6 new/modified components with rationale and candidate widget names
- [x] §9 AC Mapping — all 4 ACs + 8 ECs from user story mapped; full FR-1 through FR-10 coverage table
- [x] §10 Open Questions — 12 items with owner, build-block flag, and working assumption

## Content Quality

- [x] Token values pulled from actual artboard HTML (all 6 artboards) — not invented
- [x] Exact microcopy from artboards: placeholder "e.g., Push Day", error "Plan name can't be blank.", "Reps must be greater than 0. Weight must be greater than 0.", "Duration must be greater than 00:00.", banner "Couldn't save your changes" + body, discard dialog title + subtitle + button labels
- [x] Three exercise type field grid layouts specified from Main.dc.html: Weighted (Sets/Reps/Weight row + full-width Rest row), Time-based (Sets/Duration/Rest), Bodyweight (Sets/Reps/Rest) — confirming FR-4a
- [x] Save button state machine fully specified: disabled (dim) / active (lime) / saving (spinner + "Saving…") / retry ("Retry Save")
- [x] Dual-mode title specified: "New Workout Plan" (create) vs "Edit Workout Plan" (edit)
- [x] Saving state design detail: app bar dimmed (back + title use `color.dim`), content `opacity:0.45 pointer-events:none`, spinner `border 2.5pt solid rgba(19,19,21,.25) border-top-color #131315 0.8s linear`
- [x] Save failure banner design: `#2a1f1f` fill, `#5c3a3a` border — specific non-token values documented
- [x] Discard dialog button order documented and rationale noted: "Discard" (dim, left) + "Keep Editing" (lime, right) — destructive on left, safe on right
- [x] Data requirements: exerciseId, planId, type flag → field grid variant, mm:ss display format, kg suffix as display-only
- [x] No implementation details (Bloc, widget names, file paths) in spec body — widget naming confined to §8

## Open Items Requiring Resolution Before Build

| # | Item | Blocks build? |
|---|---|---|
| OQ-1 | Edit mode entry point: SCR-08 direct → SCR-09, or SCR-08 → SCR-10 → SCR-09? | **Yes** — navigation stack |
| OQ-2 | Duration mm:ss input mechanism (masked text, two fields, picker) | **Yes** — input widget |
| OQ-3 | Weight unit (kg only?), decimal precision, storage format | Yes — data model |
| OQ-4 | Rest display format ("90s" vs "1:30") | Minor |
| OQ-5 | Empty exercise list rule — is save blocked? | Yes — save validation |
| OQ-6 | Default values for newly-added exercise targets | Minor |
| OQ-7 | Scrim tap on discard dialog — same as "Keep Editing"? | Minor |
| OQ-8 | Invalid exercise reference — what does the card UI look like? | **Yes** — design gap (FR-6) |
| OQ-9 | Plan name max character limit | Minor |
| OQ-10 | SCR-09 presentation style: push vs. modal | **Yes** — back-gesture guard |
| OQ-11 | "Add Exercise" in Save Failure state — does it reset the Retry state? | Minor |
| OQ-12 | Sets validation: error UI not shown in error artboard — confirm treatment | Minor |

## Notes

- **OQ-1, OQ-2, OQ-8, and OQ-10 are blocking.** OQ-1 defines the navigation stack; OQ-2 is a new input widget that needs design and implementation work before the screen can be built; OQ-8 means FR-6 (invalid exercise reference) has no design coverage; OQ-10 affects the unsaved-changes guard on iOS.
- **Three exercise type layouts are the most critical new pattern** in ForgeApp's design system. The weighted layout is the only one with two grid rows (Sets/Reps/Weight on row 1; Rest alone on row 2). Time-based and bodyweight both fit in a single 3-column grid. This drives the `ExercisePlanCard` widget's `exerciseType` parameter and conditional rendering.
- The **"Saving…" dimming** (`opacity:0.45 pointer-events:none`) is applied to the content area only, not the footer — the spinner + "Saving…" button is in the footer which remains at full opacity. The app bar (back icon + title) also dims to `color.dim` to signal that back navigation is disabled.
- The **save failure banner** uses `#2a1f1f` as its fill — this is **not** a named design token. It should be either adopted as `color.dangerBg` or derived from `color.dangerBorder` (#5c3a3a) with reduced opacity. Document this as a new token if the banner is reused.
- The **discard dialog icon** is a **lime circle-with-exclamation** (not a danger/red icon). This is deliberate — the action is potentially destructive, but the primary emphasis is on the choice ("do you want to keep editing?"), not on a warning. The lime icon matches the "Keep Editing" button (the safe action).
- The **"Add Exercise" dashed button padding** differs between states: 16 pt in create mode (empty list, prominent), 14 pt in edit mode (populated list, subordinate). This is a design intent, not an inconsistency.
- The **ValidationErrors artboard** does not show the Sets field in error state — it shows a 3-column grid (Reps / Weight / Rest) for the weighted exercise, omitting Sets. It is unclear whether this is intentional (Sets had valid values in the example) or an artboard gap. OQ-12 covers this.
