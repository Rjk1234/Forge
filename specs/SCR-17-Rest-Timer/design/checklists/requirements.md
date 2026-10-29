# Design Specification Quality Checklist: SCR-17 — Rest Timer

**Purpose**: Validate design specification completeness and quality before implementation  
**Created**: 2026-09-13  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/1f762b66-1595-4a86-9af1-be8bb124c3c7

---

## Specification Completeness

- [x] §1 Overview & Goal — problem, user, goal, success metric, app context, all 5 FRs, deferred background behaviour documented
- [x] §2 User Flow — single state machine; both exit paths (Skip, zero-expiry); entry trigger; auto-advance behaviour; non-interactive background noted
- [x] §3 Screen-by-Screen Breakdown — single artboard covered fully; background SCR-16 dimming layer documented with exact opacity/filter values; scrim properties; all 4 panel elements with all CSS values
- [x] §4 Interactions & Behavior — 8 interactions tabulated; ring animation mechanics; auto-advance set/exercise logic; stroke-dashoffset formula
- [x] §5 Edge Cases & Error Handling — 9 edge cases; zero duration; last-set-of-last-exercise guard; deferred backgrounding; debounce; bodyweight next-meta
- [x] §6 Responsive & Platform Considerations — 3 device widths; iOS/Android back gesture (OQ-6); portrait-only; keyboard N/A
- [x] §7 Accessibility — single touch target audited; 6 contrast pairs (1 flagged); live-region guidance for ring; screen-reader labels; reduce-motion note
- [x] §8 Component & Design System Mapping — 14 component entries; 6 new patterns identified; 3 token gaps called out
- [x] §9 Acceptance Criteria Mapping — all ACs (AC-1–3), FRs (FR-1–5), NFRs (NFR-1–2) mapped; no ECs or SEC in story
- [x] §10 Open Questions / Assumptions — 8 OQs with owner / build-blocker status / assumption held

---

## Design Grounding

- [x] All measurements taken from artboard CSS (not invented)
- [x] All copy strings taken verbatim from artboard HTML ("Resting", "Up Next", "Barbell Bench Press — Set 3 of 4", "Target: 8 reps · 60 kg", "Skip Rest")
- [x] Token values cross-checked against design system reference
- [x] Non-token values identified:
  - `rgba(10,10,10,.72)` — scrim fill (new opacity; .62 used by SCR-11/14)
  - `44px` ring-time font-size — not in current type scale
  - `letter-spacing:.08em` — highest spacing value in system, not tokenised
- [x] All 1 artboard read and accounted for in §3
- [x] Ring arc formula derived and documented (circumference = 2π×96 ≈ 603; dashoffset = elapsed/total × 603)

---

## Blocking Issues

| # | Issue | Severity | Status |
|---|-------|---------|--------|
| OQ-1 | **Rest duration source**: No specification exists for where the rest timer duration comes from. Without a defined source (plan-level, system default, user preference) the timer cannot be started. The artboard shows "00:42" as an illustrative countdown only — it is not the configured duration. | **Blocking** | Open — PM to define duration source and fallback |
| OQ-2 | **Zero rest duration**: If rest duration is 0 or undefined, should the Rest Timer overlay be skipped entirely and SCR-16 auto-advance immediately? This determines whether the overlay render is guarded by `duration > 0`. | **Blocking** | Open — PM / Design to confirm |
| OQ-6 | **OS back gesture while Rest Timer is active**: An unhandled back gesture during rest could discard the active workout session silently. The overlay must intercept back navigation explicitly. | **Blocking** | Open — Engineering to implement back interception |

---

## Non-Blocking Open Questions

| # | Topic | Owner | Assumption held |
|---|-------|-------|----------------|
| OQ-3 | "Up Next" format for cross-exercise transition | Design | `"[Exercise Name] — Set 1 of N"` |
| OQ-4 | Ring direction (lime arc = remaining vs. elapsed) | Design | Remaining — arc shrinks toward empty |
| OQ-5 | Haptics/audio at timer zero | Design / PM | No haptic or sound in v1 |
| OQ-7 | next-meta for bodyweight exercises (no weight) | Design | Show reps only: "Target: 8 reps" |
| OQ-8 | Scrim tappability (can background SCR-16 be tapped through) | Engineering | Fully blocking — no pass-through |

---

## Design Consistency Notes

- **Three-tier scrim taxonomy — now fully defined**: Three overlay patterns now coexist in the system:
  1. **Modal scrim** `rgba(10,10,10,.62)` — SCR-11 (Delete Confirm), SCR-14 (Edit Warning). Hard modal. Background non-interactive.
  2. **Rest Timer scrim** `rgba(10,10,10,.72)` — SCR-17 (Rest Timer). Slightly more opaque than modal. Background non-interactive.
  3. **No-scrim dimming** — SCR-16 Pause. No overlay fill; content dimmed via opacity + grayscale only. Background non-interactive.
  Document all three as the Overlay Taxonomy in the design system.

- **New scrim opacity: .72** — this is distinct from the existing .62 (SCR-11/14). Rationale: Rest Timer needs slightly stronger visual isolation to signal "the workout is momentarily paused for rest" vs. a disruptive modal dialog. Token proposal: `color.scrimRest` or unify to `.72` for all full-screen overlays and retire .62.

- **Cancel link suppression during Rest Timer**: While Pause (SCR-16) keeps the Cancel link at `color:#ff6b6b; opacity:.5`, Rest Timer changes the Cancel link's colour to `var(--dim)` and then applies `opacity:.35` — a two-stage suppression. This produces a much softer presentation of the Cancel affordance, reinforcing that the rest overlay is not a modal and the only intended exit is Skip Rest or timer expiry.

- **44px display type — new size tier**: The ring-time readout at `44px/800` is the largest typeface in the system by a wide margin (prior max: 22px on exercise name, SCR-16). This deserves a named token: `text.display` or `text.timerXL`. It reads as a sports-display numeral — intentionally oversized to be readable at a glance without bringing the phone close.

- **Ring arc vs. set-pill dots**: Both are lime-on-card-alt visual indicators, but they encode different semantics. Set pill dots (SCR-16) show completed/current/upcoming state across discrete slots. The ring arc (SCR-17) shows a continuous proportion of time remaining. Neither should be called a "progress indicator" without qualification — disambiguate in component naming.

- **next-card `gap:2px`**: The 2px gap between next-label / next-name / next-meta is the tightest inter-element gap in the system. Its purpose is to create a dense "label over value" format rather than a spaced list. This pattern may be useful for future compact info-rows elsewhere — document as a `dense-info-card` variant.

- **`stroke-linecap: round`**: The rounded arc endpoints on the ring foreground circle mean the arc visually appears to start and end with a semicircular cap of radius 5px (half of stroke-width:10). At very low remaining time (near zero), the single rounded dot of the arc tip is visible. Implementations must account for this at the visual extremes: near zero, the visible arc is a small dot, not a thin sliver.

- **`font-weight:700` on next-name**: 15px/700 is a new combination in the system. All prior 15px uses were 800 (Complete Set button on SCR-16). The 700 weight here creates a softer, informational read rather than a CTA. This weight-at-size combination should be documented as the `next-name` variant.

---

## Sign-off

| Role | Status | Date |
|------|--------|------|
| Design | Pending OQ-1 (duration source), OQ-2 (zero duration), OQ-3 (cross-exercise format), OQ-4 (ring direction confirmation), OQ-7 (bodyweight meta) | — |
| Engineering | Pending OQ-1 (duration source — determines timer init), OQ-2 (guard logic), OQ-6 (back gesture interception), OQ-8 (scrim passthrough) | — |
| PM | Pending OQ-1 (duration source — product decision), OQ-2 (zero rest UX — product decision), OQ-5 (haptics/audio — product decision) | — |
