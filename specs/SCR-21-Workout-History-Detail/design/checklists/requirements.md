# Design Specification Quality Checklist: SCR-21 — Workout History Detail

**Purpose**: Validate design specification completeness and quality before implementation  
**Created**: 2026-09-13  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/583b36ed-081c-470a-be28-43d80647e3b6  

---

## Specification Completeness

- [x] §1 Overview & Goal — problem, user, goal, success metric, app context (offline/Drift), all FRs/NFRs, SEC constraints noted
- [x] §2 User Flow — single entry (SCR-20 row tap); single exit (back to SCR-20); 3-state machine (Loading → Main/Error, Error → Loading retry); no navbar
- [x] §3 Screen-by-Screen Breakdown — all 3 artboards covered with exact CSS values; shared chrome documented once; Loading skeleton, Main full detail, Error card — all complete
- [x] §4 Interactions & Behaviour — 10 interactions tabulated; scroll behaviour; read-only pill note; retry guard; back navigation both platforms
- [x] §5 Edge Cases & Error Handling — 10 edge cases; partial corruption (OQ-1 flagged blocking); historical integrity (EC-3, EC-4); zero-exercise edge; long name/many sets/many exercises
- [x] §6 Responsive & Platform Considerations — 3 device widths; portrait-only; safe area (OQ-2 flagged blocking); iOS/Android back behaviour; appbar layout
- [x] §7 Accessibility — 4 touch targets audited (back arrow below 44pt flagged; retry borderline — OQ-11); 14 contrast pairs (4 failures — systemic dim issues + skipped pill noted as decorative); full semantic roles; focus management
- [x] §8 Component & Design System Mapping — 8 existing components; 9 new components/patterns; 5 token gaps; shimmer variant difference documented
- [x] §9 Acceptance Criteria Mapping — all ACs (AC-1–3), FRs (FR-1–3), NFRs (NFR-1–2), EC-1 mapped
- [x] §10 Open Questions / Assumptions — 11 OQs; 2 blocking (OQ-1, OQ-2); 9 non-blocking with assumptions held

---

## Design Grounding

- [x] All measurements taken from artboard CSS (not invented)
- [x] All copy strings taken verbatim from artboard HTML:
  - Loading: "Workout Detail" (appbar-title)
  - Main: "Workout Detail" (appbar-title), "Push Day — Upper Body" (hero-name), "Mon, Sep 7, 2026 · 6:42 PM" (hero-meta), "DURATION" / "EXERCISES" / "SETS LOGGED" (stat-labels), "38 min" / "5" / "14" (stat-values), "Performance" (section-label), all 5 exercise names, all set pill values
  - Error: "Workout Detail" (appbar-title), "Couldn't load this workout" (err-title), full err-sub, "Retry" (retry-btn)
- [x] Token values cross-checked against design system reference
- [x] Non-token values identified and documented:
  - `rgba(255,255,255,.06)` — shimmer sheen overlay (translate-shimmer variant); **new** — token proposal: `color.shimmerSheen`
  - `font-weight:600` — `set-pill.skipped` (weight.medium — 3rd+ system occurrence)
  - `border-radius:8px` — `set-pill`, `sk-pill` (radius.pill — same as SCR-19)
  - `border-radius:10px` — retry-btn (radius.dialogButton — same as SCR-20)
  - `letter-spacing:.06em` — section-label (new value; first occurrence)
- [x] All 3 artboards read and accounted for in §3
- [x] Back arrow dimming in Loading state documented (new `appbar-dim` variant — loading-only pattern where both title and back icon render in `dim`)
- [x] Shimmer variant difference from SCR-20 documented (translate vs background-position — two shimmer implementations in system now)
- [x] stat-box background difference vs SCR-19 noted (`card` in SCR-21 vs `card-alt` in SCR-19)
- [x] section-label "Performance" documented as new component (sub-section heading separator)
- [x] Error copy distinction from SCR-20 documented ("Your workout history is unaffected" vs "Your plans and schedule are unaffected")
- [x] Date/time format documented: `"Ddd, Mon D, YYYY · H:MM AM/PM"` with middle-dot U+00B7
- [x] Set pill formats documented per exercise type (weighted, bodyweight, time, skipped)
- [x] No bottom navbar on this screen (not a root-tab screen) — explicitly noted
- [x] `#5c3a3a` (dangerBorder) confirmed as design system token on err-card border

---

## Blocking Issues

### OQ-1 — Partial session data handling (Engineering/PM decision needed)
**Issue**: The spec assumes silently omitting corrupt exercise entries; showing Error only when the entire record is unreadable. This is an untested assumption.  
**Impact**: If the rule is "any corrupt entry → Error state," the Loading → Main transition has different guards. Implementation must know before building the Drift read cubit.  
**Resolution required before**: Cubit implementation of the session detail read.

### OQ-2 — Bottom safe area sufficiency
**Issue**: Content area uses `padding-bottom:28px`. On iPhone 14+ (home indicator height ≥34pt), this may clip the last exercise card's bottom. The artboard is 390×844px but does not simulate home indicator inset.  
**Impact**: Last exercise card or final set pills may be obscured on physical devices.  
**Resolution required before**: Flutter widget build of the scrollable content area.

---

## Non-Blocking Open Questions

| # | Topic | Owner | Assumption held |
|---|-------|-------|----------------|
| OQ-3 | Duration "38 min" rounding rule — nearest minute or truncated? | Engineering/Design | Rounded to nearest minute |
| OQ-4 | Time exercise pill format for >60 seconds (MM:SS vs H:MM:SS) | Design/Engineering | MM:SS ≤59:59; H:MM:SS for longer |
| OQ-5 | Weight unit display — always kg or unit preference? | PM/Engineering | As stored (kg); localisation out of scope v1 |
| OQ-6 | "Sets Logged" stat: skipped sets included or excluded from count? | PM | Total slots (including skipped) |
| OQ-7 | Scroll position on re-entry (future-proofing) | Engineering | Reset to top |
| OQ-8 | Loading appbar dim: deliberate or oversight? | Design | Deliberate — document as `appbar-dim` pattern |
| OQ-9 | translate-shimmer vs background-position-shimmer: which is canonical? | Design/Engineering | Both valid; decide in skeleton component sprint |
| OQ-10 | section-label "Performance" shown even for zero-exercise sessions? | Design | Always shown |
| OQ-11 | Retry btn height ~40px — needs padding increase to ≥44pt? | Design | Increase to `padding:13px 22px` |

---

## Design Consistency Notes

- **Overlay/detail title tier `18px/800/.02em` confirmed**: SCR-21 appbar-title matches SCR-17, SCR-18, SCR-19 — the overlay/detail screen tier. SCR-20 (root tab) used `22px/800/.02em`. Two-tier title scale fully confirmed across 5 screens.

- **New `appbar-dim` loading variant**: Loading state renders both the back arrow and title in `dim` (`#8a8f7a`) rather than `white`. This is the first screen where the loading state's appbar is visually distinct from the loaded state's appbar. Rationale: on SCR-20, the screen title "History" is constant regardless of load outcome — so it stays white. On SCR-21, "Workout Detail" is a placeholder title (the real identity — the workout name — only appears in `hero-name` once loaded). Dimming the appbar reinforces that nothing is yet confirmed. This is a sound UX decision; document as a pattern for detail screens whose identity depends on loaded data.

- **Two shimmer implementations now in the system**:
  - SCR-20 (background-position shimmer): `linear-gradient(90deg, card-alt 25%, #35342f 37%, card-alt 63%); background-size:400%; @keyframes{0%→100% background-position}` — the classic "moving band" effect baked into the gradient.
  - SCR-21 (translate shimmer): `::after { background:linear-gradient(transparent, rgba(255,255,255,.06), transparent); animation:shimmer translateX(-100%→100%) }` — a semi-transparent sheen overlay that sweeps across a solid `card-alt` base. Lighter (smaller DOM impact, no background-size trick). Both 1.4s. Decide canonical implementation in the design system skeleton sprint.

- **`hero-name` at 22px is larger than the appbar-title at 18px**: This is intentional — the workout name is the page's most important piece of information and gets more visual weight than the utility "Workout Detail" label in the appbar. The hierarchy is: appbar-title (navigation utility, 18px/dim while loading) < hero-name (content identity, 22px/white).

- **stat-box `card` vs SCR-19 `card-alt`**: In SCR-19 (Workout Summary, completion moment), stat boxes used the elevated `card-alt` background — adding visual weight to a celebratory summary. In SCR-21 (calm read-only review), they use the standard `card` background — matching every other card on the screen. This is a subtle but deliberate tonal difference.

- **section-label `letter-spacing:.06em`**: This is a new value — tighter than nothing, wider than the `.04em` on stat-label. The section-label is 12px/800 in all-caps, so the tighter tracking reads well. Different from: `.02em` appbar-title, `.03em` date-mon (SCR-20), `.04em` stat-label, `.05em` month-label (SCR-20). Each has a distinct context. No token for `.06em` yet — propose `tracking.sectionLabel`.

- **`set-tag font-weight:700`**: Set count label ("4 sets") uses `font-weight:700` — not 800 (used for headings) and not 600 (weight.medium for skipped). A subtle differentiation that keeps the set count secondary to the exercise name (`font-weight:700` also) but de-emphasised by `color:var(--dim)`.

- **Skipped pill as decorative non-informational element**: The WCAG failure on `.set-pill.skipped` (dim on card-alt, ~3.7:1) is acceptable because: (1) `text-decoration:line-through` is the primary semantic carrier — "this set was skipped"; (2) the dim colour reinforces "de-emphasised" rather than conveying new information. Screen reader semantics should label it "Skipped" with a hint. This is consistent with WCAG's allowance for decorative text that duplicates accessible information provided elsewhere.

- **No footer / no CTA bar**: SCR-21 is the first screen (among the Workout series SCR-11–21) with no bottom action bar whatsoever. The action affordance is exclusively the appbar back arrow. This is correct for a read-only historical record — no actions are available.

- **Error err-sub line break**: The error sub-text uses `<br/>` for the line break between "Something went wrong reading local data." and "Your workout history is unaffected." In Flutter this becomes `\n` in the string, rendered as a newline in a `Text` widget. Same pattern as SCR-20.

---

## Sign-off

| Role | Status | Date |
|------|--------|------|
| Design | Pending OQ-1 (partial corruption handling), OQ-8 (appbar-dim intent confirmation), OQ-9 (shimmer variant canonical), OQ-10 (section-label in zero-exercise), OQ-11 (retry btn padding) | — |
| Engineering | Pending OQ-1 (Drift read cubit guards), OQ-2 (safe area bottom padding), OQ-4 (time pill format), OQ-6 (sets-logged count rule), OQ-9 (shimmer implementation) | — |
| PM | Pending OQ-1 (partial data UX decision), OQ-5 (unit display), OQ-6 (sets-logged definition) | — |
